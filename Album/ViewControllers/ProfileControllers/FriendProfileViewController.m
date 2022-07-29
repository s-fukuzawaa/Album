//
//  FriendProfileViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/7/22.
//

#import "FriendProfileViewController.h"
#import "FriendMapViewController.h"
#import "FriendGridViewController.h"
#import "DetailsViewController.h"
#import "Friendship.h"
#import "AlbumConstants.h"
#import "Pin.h"
#import <PFImageView.h>
#import <Parse/Parse.h>

@interface FriendProfileViewController () <FriendMapViewControllerDelegate>
@property (weak, nonatomic) IBOutlet PFImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIButton *friendButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *isPublicLabel;
@property (weak, nonatomic) IBOutlet UIImageView *closeFriendStarView;
@property (nonatomic) NSNumber *friendStatus; // Friend status from current user's point of view
@property (nonatomic) NSNumber *requestStatus; // Friend status from requester's pov
@property (strong, nonatomic) Friendship *friendship; // Friendship where requester = current user
@property (strong, nonatomic) Friendship *request; // Friendship where requester = tapped user
@property (strong, nonatomic) NSArray *imagesToDetail;
@property (strong, nonatomic) Pin *pin;

@end

@implementation FriendProfileViewController

#pragma mark - UIViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Initial view to friend map view
    self.friendMapContainer.alpha = 0.0;
    self.friendsGridContainer.alpha = 1.0;
    // Set user profile image view
    [self fetchProfile];
    // Set request statuses
    [self fetchRequestStatus];
    // Set friend statuses
    [self fetchFriendStatus];
    // Update button UI
    [self updateButton];
    // Update isPublic status
    [self setIsPublicLabel];
    // Set close friend star to be invisible in general
    [self.closeFriendStarView setHidden:YES];
}

- (void) setIsPublicLabel {
    if(self.user[@"isPublic"]) {
        [self.isPublicLabel setText: @"Public Account"];
    }else{
        [self.isPublicLabel setText: @"Private Account"];
    }
}
- (void)fetchProfile {
    PFUser *user = self.user;
    if (user[@"profileImage"]) {
        PFFileObject *file = user[@"profileImage"];
        [self.userImageView setFile:file];
        [file getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:imageData];
                [self.userImageView setImage:image];
                self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height / 2;
                self.userImageView.layer.masksToBounds = YES;
            }
        }];
    }
}
#pragma mark - UIView

- (void)updateButton {
    UIColor *friendshipButtonBackgroundColor;
    NSString *friendshipButtonText;
    UIColor *friendshipButtonTitleColor;
    if (self.request != NULL && [self.requestStatus intValue] == PENDING) {
        friendshipButtonBackgroundColor = [UIColor whiteColor];
        friendshipButtonText = @"Received Request";
        friendshipButtonTitleColor = [UIColor colorWithRed:0.39 green:0.28 blue:0.22 alpha:1.00];
        [self.closeFriendStarView setHidden:YES];
    } else if ([self.friendStatus intValue] == FRIENDED) {
        friendshipButtonBackgroundColor = [UIColor colorWithRed:0.39 green:0.28 blue:0.22 alpha:1.00];
        friendshipButtonText = @"Friended";
        friendshipButtonTitleColor = [UIColor whiteColor];
        [self.closeFriendStarView setHidden:NO];
        if(self.friendship.isClose) {
            [self.closeFriendStarView setImage:[UIImage systemImageNamed:@"star.fill"]];
        }else{
            [self.closeFriendStarView setImage:[UIImage systemImageNamed:@"star"]];
        }
    } else if ([self.friendStatus intValue] == PENDING) {
        friendshipButtonBackgroundColor = [UIColor whiteColor];
        friendshipButtonText = @"Pending";
        friendshipButtonTitleColor = [UIColor colorWithRed:0.39 green:0.28 blue:0.22 alpha:1.00];
        [self.closeFriendStarView setHidden:YES];
    } else {
        friendshipButtonBackgroundColor = [UIColor whiteColor];
        friendshipButtonText = @"Request Friend?";
        friendshipButtonTitleColor = [UIColor colorWithRed:0.39 green:0.28 blue:0.22 alpha:1.00];
        [self.closeFriendStarView setHidden:YES];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.friendButton setTitleColor:friendshipButtonTitleColor forState:UIControlStateNormal];
        [self.friendButton setTitle:friendshipButtonText forState:UIControlStateNormal];
        [self.friendButton setBackgroundColor:friendshipButtonBackgroundColor];
    });
} /* updateButton */

- (void)requestAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"FRIEND REQUEST" message:@"Choose"
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    // Create a accept action
    UIAlertAction *acceptAction = [UIAlertAction actionWithTitle:@"Accept"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *_Nonnull action) {
        // Update statuses
        self.requestStatus = @(FRIENDED);
        self.friendStatus = @(FRIENDED);
        // Update database
        [self updateFriendship];
        [self updateRequest];
        // Update button UI
        [self updateButton];
    }];
    [alert addAction:acceptAction];
    // Create a reject action
    UIAlertAction *rejectAction = [UIAlertAction actionWithTitle:@"Reject"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *_Nonnull action) {
        // Update statuses
        self.requestStatus = @(NOT_FRIEND);
        self.friendStatus = @(NOT_FRIEND);
        // Update database
        [self updateFriendship];
        [self updateRequest];
        // Update button UI
        [self updateButton];
    }];
    [alert addAction:rejectAction];
    // Cancel action
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleDefault
                                                   handler:nil];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
} /* requestAlert */

#pragma mark - Parse API

- (void)fetchFriendStatus {
    // Query to fetch friend status
    PFQuery *query = [PFQuery queryWithClassName:classNameFriendship];
    PFUser *currentUser = [PFUser currentUser];
    [query whereKey:@"requesterId" equalTo:currentUser.objectId];
    [query whereKey:@"recipientId" equalTo:self.user.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *_Nullable friendships, NSError *_Nullable error) {
        if (friendships != nil) {
            // Check if friendships exist between tapped user and current user
            if (friendships.count == 0) {
                // If not, add friendship
                [self updateFriendship];
            } else {
                // Otherwise, store
                self.friendship = friendships[0];
                self.friendStatus = self.friendship.hasFriended;
                // Update button UI
                [self updateButton];
            }
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
} /* fetchFriendStatus */

- (void)fetchRequestStatus {
    // Query to find markers that belong to current user
    PFQuery *query = [PFQuery queryWithClassName:classNameFriendship];
    PFUser *currentUser = [PFUser currentUser];
    [query whereKey:@"recipientId" equalTo:currentUser.objectId];
    [query whereKey:@"requesterId" equalTo:self.user.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *_Nullable requests, NSError *_Nullable error) {
        if (requests != nil) {
            // Check if friend requests made to current user from tapped user
            if (requests.count != 0) {
                // Store properties
                self.request = requests[0];
                self.requestStatus = self.request.hasFriended;
                // UPdate button UI
                [self updateButton];
            }
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
} /* fetchRequestStatus */

- (void)updateFriendship {
    // If friendship doesn't exist
    if (self.friendship == NULL) {
        // Add friendship to data base
        PFUser *currentUser = [PFUser currentUser];
        Friendship *friendship = [Friendship new];
        friendship.requesterId = currentUser.objectId;
        friendship.recipientId = self.user.objectId;
        friendship.hasFriended = @(NOT_FRIEND);
        [friendship saveInBackgroundWithBlock:^(BOOL succeeded, NSError *_Nullable error) {
            if (error) {
                NSLog(@"Error posting: %@", error.localizedDescription);
            } else {
                NSLog(@"Friendship saved successfully! Status:%@", self.friendStatus);
            }
        }];
        // Store properties
        self.friendship = friendship;
        self.friendStatus = @(NOT_FRIEND);
        return;
    }
    // Otherwise, update friendship status in the database
    self.friendship.hasFriended = self.friendStatus;
    [self.friendship saveInBackgroundWithBlock:^(BOOL succeeded, NSError *_Nullable error) {
        if (error) {
            NSLog(@"Error posting: %@", error.localizedDescription);
        } else {
            NSLog(@"Successfully saved friendship!");
        }
    }];
} /* updateFriendship */

- (void)updateRequest {
    // If there's request from tapped user
    if (self.request != NULL) {
        // Update friendship in the backend
        self.request.hasFriended = self.requestStatus;
        [self.request saveInBackgroundWithBlock:^(BOOL succeeded, NSError *_Nullable error) {
            if (error) {
                NSLog(@"Error posting: %@", error.localizedDescription);
            } else {
                NSLog(@"Request saved successfully! Status:%@", self.requestStatus);
            }
        }];
        return;
    }
}

#pragma mark - IBAction

- (IBAction)viewSwitchControl:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        [UIView animateWithDuration:0.5 animations:^{
            self.friendsGridContainer.alpha = 1.0;
            self.friendMapContainer.alpha = 0.0;
        }];
    } else { // Album View case
        [UIView animateWithDuration:0.5 animations:^{
            self.friendMapContainer.alpha = 1.0;
            self.friendsGridContainer.alpha = 0.0;
        }];
    }
}

- (IBAction)friendButton:(id)sender {
    if ([self.friendStatus intValue] == PENDING) {
        // If pending friendStatus, no action
        return;
    } else if (self.requestStatus != NULL && [self.requestStatus intValue] == PENDING) {
        // If there's pending incoming friendrequest, alert to accept or reject
        [self requestAlert];
        // Update database for request side
        [self updateRequest];
    } else if ([self.friendStatus intValue] == FRIENDED) {
        // If they are already friends, but tapped the button, unfriend
        self.requestStatus = @(NOT_FRIEND);
        self.friendStatus = @(NOT_FRIEND);
        // Update database for request side
        [self updateRequest];
    } else if ([self.friendStatus intValue] == NOT_FRIEND) {
        // If current user requests to be friends with the tapped user
        self.friendStatus = @(PENDING);
    }
    // Update databased for current user's side
    [self updateFriendship];
    // Update button UI
    [self updateButton];
} /* friendButton */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NULL;
}
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqual:segueFriendMap]) {
        FriendMapViewController *friendMapVC = [segue destinationViewController];
        friendMapVC.user = self.user;
        friendMapVC.delegate = self;
    } else if ([segue.identifier isEqual:@"friendGridSegue"]) {
        FriendGridViewController *friendGridVC = [segue destinationViewController];
        friendGridVC.user = self.user;
    } else if ([segue.identifier isEqual:@"friendProfileDetailsSegue"]) {
        DetailsViewController *detailsVC = [segue destinationViewController];
        detailsVC.pin = self.pin;
        detailsVC.imagesFromPin = self.imagesToDetail;
    }
}

#pragma mark - FriendMapViewControllerDelegate

- (void)didTapWindow:(Pin *)pin imagesFromPin:(NSArray *)imageFiles {
    self.pin = pin;
    // Set Images array
    NSMutableArray *pinImages = [[NSMutableArray alloc] init];
    // For each image object, get the image file and convert to UIImage
    for (PFObject *imageObj in imageFiles) {
        PFFileObject *file = imageObj[@"imageFile"];
        [file getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:imageData];
                [pinImages addObject:image];
            }
        }];
    }
    self.imagesToDetail = pinImages;
    [self performSegueWithIdentifier:@"friendProfileDetailsSegue" sender:nil];
}
@end
