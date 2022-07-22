//
//  ProfileViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/7/22.
//

#import "ProfileViewController.h"
#import "ActivitiesviewController.h"
#import "AddFriendViewController.h"
#import "SettingsViewController.h"
#import "FriendProfileViewController.h"
#import "PhotoCollectionCell.h"
#import "AlbumConstants.h"
#import "ParseAPIHelper.h"
#import "Friendship.h"
#import "Parse/Parse.h"
#import "PFImageView.h"


@interface ProfileViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *friendsCollectionView;
@property (weak, nonatomic) IBOutlet PFImageView *profileImageView;
@property (strong, nonatomic) NSArray* friendships;
@property (strong, nonatomic) PFUser* currentUser;
@property (strong, nonatomic) ParseAPIHelper *apiHelper;
@property (strong, nonatomic) NSArray *friendsArray;
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Set API helper
    self.apiHelper = [[ParseAPIHelper alloc] init];
    // Store current user
    self.currentUser = [PFUser currentUser];
    // Assign collection view delegate and dataSource
    self.friendsCollectionView.delegate = self;
    self.friendsCollectionView.dataSource = self;
    // Fetch friends
    self.friendsArray = [self.apiHelper fetchFriends:self.currentUser.objectId];
//    self.friendsArray = [[NSMutableArray alloc]init];
    [self.friendsCollectionView reloadData];
    // Load profile image
    [self setProfile];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self fetchFriend];
    [self.friendsCollectionView reloadData];
}
- (IBAction)activitiesButton:(id)sender {
    [self performSegueWithIdentifier:@"activitiesSegue" sender:nil];
}
- (IBAction)addFriendButton:(id)sender {
    [self performSegueWithIdentifier:@"addFriendSegue" sender:nil];
}
- (IBAction)settingsButton:(id)sender {
    [self performSegueWithIdentifier:@"settingsSegue" sender:nil];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.friendsArray.count;
}

//- (void)fetchFriend {
//    // Query to find markers that belong to current user and current user's friend
//    PFQuery *friendQuery = [PFQuery queryWithClassName:classNameFriendship];
//    [friendQuery whereKey:@"requesterId" equalTo:self.currentUser.objectId];
//    [friendQuery whereKey:@"hasFriended" equalTo:@(2)];
//    [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *friendships, NSError *error) {
//        if (friendships != nil) {
//            NSLog(@"Successfully fetched friendships!");
//            // For each friend, find their pins
//            for (Friendship *friendship in friendships) {
//                NSString *friendId = friendship[@"recipientId"];
//                PFUser *friend = [self.apiHelper fetchUser:friendId][0];
//                [self.friendsArray addObject:friend];
//            }
//            [self.friendsCollectionView reloadData];
//        } else {
//            NSLog(@"%@", error.localizedDescription);
//        }
//    }];
//} /* fetchFriends */

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCollectionCell *profileCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"profileCell" forIndexPath:indexPath];
    if (self.friendsArray.count == 0) {
        profileCell.photoImageView.contentMode = UIViewContentModeScaleAspectFit;
        profileCell.photoImageView.image = [UIImage imageNamed:@"profile_tab"];
    } else {
        profileCell.photoImageView.contentMode = UIViewContentModeScaleAspectFit;
        PFFileObject *file = self.friendsArray[indexPath.row][@"profileImage"];
        profileCell.photoImageView.image = [UIImage imageWithData:[file getData]];
    }
    return profileCell;
}

- (void)setProfile {
    PFUser *user = [PFUser currentUser];
    if (user[@"profileImage"]) {
        PFFileObject *file = user[@"profileImage"];
        [self.profileImageView setFile:file];
        [file getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:imageData];
                [self.profileImageView setImage:image];
                self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height / 2;
                self.profileImageView.layer.masksToBounds = YES;
            }
        }];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    int totalwidth = self.friendsCollectionView.bounds.size.width;
    int numberOfCellsPerRow = 3;
    int dimensions = (CGFloat)(totalwidth / numberOfCellsPerRow) - 10;
    return CGSizeMake(dimensions, dimensions);
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"activitiesSegue"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        ActivitiesViewController *activitiesController = (ActivitiesViewController *)navigationController.topViewController;
        //        activitiesController.delegate = self; TODO: Add delegate later
    } else if ([segue.identifier isEqualToString:@"addFriendSegue"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        AddFriendViewController *addFriendController = (AddFriendViewController *)navigationController.topViewController;
        //        addFriendController.delegate = self; TODO: Add delegate later
    } else if ([segue.identifier isEqualToString:@"settingsSegue"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        SettingsViewController *settingsController = (SettingsViewController *)navigationController.topViewController;
        //        settingsController.delegate = self; TODO: Add delegate later
    } else if([segue.identifier isEqualToString:@"friendProfileSegue"]){
        NSIndexPath *indexPath = [self.friendsCollectionView indexPathForCell:(PhotoCollectionCell *)sender];
        FriendProfileViewController *friendVC = [segue destinationViewController];
        friendVC.user = self.friendsArray[indexPath.row];
    }
}


@end
