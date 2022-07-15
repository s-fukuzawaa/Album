//
//  FriendProfileViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/7/22.
//

#import "FriendProfileViewController.h"
#import "Friendship.h"
#import <PFImageView.h>
#import <Parse/Parse.h>
static int const REJECT = 3;
static int const PENDING = @(1);
static NSNumber* const FRIENDED = @(2);
static NSNumber* const NOT_FRIEND = @(0);

@interface FriendProfileViewController ()
@property (weak, nonatomic) IBOutlet PFImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIButton *friendButton;
@property (nonatomic) NSNumber *friendStatus;
@property (nonatomic) NSNumber *requestStatus;
@property (strong, nonatomic) Friendship *friendship;
@property (strong, nonatomic) Friendship *request;
@end

@implementation FriendProfileViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.friendMapContainer.alpha = 0.0;
	self.friendsGridContainer.alpha = 1.0;
	// Set user profile image view
	[self fetchProfile];
    [self fetchRequestStatus];
	[self fetchFriendStatus];
}
- (IBAction)viewSwitchControl:(UISegmentedControl*)sender {
	if(sender.selectedSegmentIndex == 0) {
		[UIView animateWithDuration:0.5 animations:^{
		         self.friendMapContainer.alpha = 0.0;
		         self.friendsGridContainer.alpha = 1.0;
		 }];
	} else { // Album View case
		[UIView animateWithDuration:0.5 animations:^{
		         self.friendMapContainer.alpha = 1.0;
		         self.friendsGridContainer.alpha = 0.0;
		 }];
	}
}

- (void) fetchProfile {
	PFUser *user = self.user;
	if(user[@"profileImage"]) {
		PFFileObject *file = user[@"profileImage"];
		[self.userImageView setFile:file];
		[file getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
		         if (!error) {
				 UIImage *image = [UIImage imageWithData:imageData];
				 [self.userImageView setImage:image];
				 self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height/2;
				 self.userImageView.layer.masksToBounds = YES;
			 }
		 }];
	}
}

- (void) updateButton {
    if(self.request != NULL && [self.requestStatus intValue]== [PENDING intValue]) {
        [self.friendButton setTintColor:[UIColor whiteColor]];
        [self.friendButton setTitle:@"Received Request" forState:UIControlStateNormal];
        [self.friendButton setTitleColor:[UIColor colorWithRed: 0.39 green: 0.28 blue: 0.22 alpha: 1.00] forState:UIControlStateNormal];
    }
	else if(self.friendStatus == FRIENDED) {
		[self.friendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[self.friendButton setTitle:@"Friended" forState:UIControlStateNormal];
        [self.friendButton setTintColor:[UIColor colorWithRed: 0.39 green: 0.28 blue: 0.22 alpha: 1.00]];
	}else if(self.friendStatus == PENDING) {
        [self.friendButton setTintColor:[UIColor whiteColor]];
		[self.friendButton setTitle:@"Pending" forState:UIControlStateNormal];
		[self.friendButton setTitleColor:[UIColor colorWithRed: 0.39 green: 0.28 blue: 0.22 alpha: 1.00] forState:UIControlStateNormal];
	}else{
		[self.friendButton setTintColor:[UIColor whiteColor]];
		[self.friendButton setTitle:@"Request Friend?" forState:UIControlStateNormal];
        [self.friendButton setTitleColor: [UIColor colorWithRed: 0.39 green: 0.28 blue: 0.22 alpha: 1.00] forState:UIControlStateNormal];

	}
}

- (void) fetchFriendStatus {
	// Query to find markers that belong to current user
	PFQuery *query = [PFQuery queryWithClassName:@"Friendship"];
	PFUser *currentUser = [PFUser currentUser];
	[query whereKey:@"requestId" equalTo:currentUser.objectId];
	[query whereKey:@"recipientId" equalTo:self.user.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable friendships, NSError * _Nullable error) {
        if (friendships != nil) {
            // do something with the array of object returned by the call
            if(friendships.count == 0) {
                [self updateFriendship];
            }else{
                self.friendship = friendships[0];
                self.friendStatus = self.friendship.hasFriended;
                [self updateButton];
            }
            
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void) fetchRequestStatus {
    // Query to find markers that belong to current user
    PFQuery *query = [PFQuery queryWithClassName:@"Friendship"];
    PFUser *currentUser = [PFUser currentUser];
    [query whereKey:@"recipientId" equalTo:currentUser.objectId];
    [query whereKey:@"requesterId" equalTo:self.user.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable requests, NSError * _Nullable error) {
        if (requests != nil) {
            // do something with the array of object returned by the call
            if(requests.count != 0) {
                self.request = requests[0];
                self.requestStatus = self.request.hasFriended;
                [self updateButton];
            }
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void) updateFriendship {
    if(self.friendship == NULL) {
        PFUser *currentUser = [PFUser currentUser];
        Friendship *friendship = [Friendship new];
        friendship.requesterId = currentUser.objectId;
        friendship.recipientId = self.user.objectId;
        friendship.hasFriended = NOT_FRIEND;
        [friendship saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                 if (error) {
                 NSLog(@"Error posting: %@", error.localizedDescription);
             } else {
                 NSLog(@"Friendship saved successfully! Status:%@", self.friendStatus);

             }
         }];
        self.friendship=friendship;
        self.friendStatus = NOT_FRIEND;
        return;
    }
    self.friendship.hasFriended = self.friendStatus;
    [self.friendship saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error){
            NSLog(@"Error posting: %@", error.localizedDescription);
        }
        else{
            NSLog(@"Successfully saved friendship!");
        }
    }];
}

- (void) updateRequest {
    if(self.request != NULL) {
        self.request.hasFriended = self.requestStatus;
        [self.request saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                 if (error) {
                 NSLog(@"Error posting: %@", error.localizedDescription);
             } else {
                 NSLog(@"Request saved successfully! Status:%@", self.requestStatus);

             }
         }];
        return;
    }
}

- (IBAction)friendButton:(id)sender {
    // Current user being requested to be friends
    // Present accept or reject follow request
    // Accept: Update friendStatus = FRIENDED. Update requestStatus = FRIENDED, give friended button ui
    // Reject: Update friendStatus = UNFRIENDED. Update requestStatus = UNFRIENDED, give UNFRIEND button ui
    
    // Current user request to be friends
    // Request: Update friendStatus = PENDING
    if(self.friendStatus == PENDING) {
        return;
    }else if(self.requestStatus!=NULL && PENDING) {
        [self requestAlert];
        [self updateRequest];
    }else if(self.friendStatus == FRIENDED) {
        self.requestStatus = NOT_FRIEND;
        self.friendStatus = NOT_FRIEND;
        [self updateRequest];
    }else if(self.friendStatus == NOT_FRIEND) {
        self.friendStatus = PENDING;
    }
	[self updateFriendship];
	[self updateButton];
}

- (void) requestAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"FRIEND REQUEST" message:@"Choose"
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    // Create a accept action
    UIAlertAction *acceptAction = [UIAlertAction actionWithTitle:@"Accept"
                                                          style:UIAlertActionStyleCancel
                                                        handler:^(UIAlertAction * _Nonnull action) {
        self.requestStatus = FRIENDED;
        self.friendStatus = FRIENDED;
    }];
    [alert addAction:acceptAction];
    // Create a reject action
    UIAlertAction *rejectAction = [UIAlertAction actionWithTitle:@"Reject"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
        self.requestStatus = NOT_FRIEND;
        self.friendStatus = NOT_FRIEND;
    }];
    // add the OK action to the alert controller
    [alert addAction:rejectAction];
    //cancel
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleDefault
                                                   handler: nil];
    // add the OK action to the alert controller
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return NULL;
}
@end
