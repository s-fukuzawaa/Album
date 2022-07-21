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
    self.friendsCollectionView.dataSource = self;
    self.friendsCollectionView.delegate = self;
    // Load profile image
    [self setProfile];
    // Fetch friends
    self.friendsArray = [self.apiHelper fetchFriends:self.currentUser.objectId];
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
    }
}


@end
