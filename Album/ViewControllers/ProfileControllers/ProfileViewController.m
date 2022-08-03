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
#import "ColorConvertHelper.h"
#import "PhotoCollectionCell.h"
#import "AlbumConstants.h"
#import "ParseAPIHelper.h"
#import "Friendship.h"
#import "Parse/Parse.h"
#import "PFImageView.h"

@interface ProfileViewController () <UICollectionViewDataSource, UICollectionViewDelegate, SettingsViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *friendsCollectionView;
@property (weak, nonatomic) IBOutlet PFImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) NSArray *friendships;
@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) ParseAPIHelper *apiHelper;
@property (strong, nonatomic) NSArray *friendsArray;
@property (strong, nonatomic) ColorConvertHelper *colorConvertHelper;
@end

@implementation ProfileViewController

#pragma mark - UIViewController

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
    [self.apiHelper fetchFriends:self.currentUser.objectId withBlock:^(NSArray *friendArr, NSError *error) {
        if (friendArr != nil) {
            self.friendsArray = friendArr;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.friendsCollectionView reloadData];
            });
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    // Load profile image
    [self setProfile];
} /* viewDidLoad */

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.currentUser = [PFUser currentUser];
    // Fetch friends
    [self.apiHelper fetchFriends:self.currentUser.objectId withBlock:^(NSArray *friendArr, NSError *error) {
        if (friendArr != nil) {
            self.friendsArray = friendArr;
            dispatch_async(dispatch_get_main_queue(), ^{
                CAGradientLayer *grad = [CAGradientLayer layer];
                grad.frame = self.friendsCollectionView.bounds;
                UIColor* firstColor = [self.colorConvertHelper colorFromHexString:@"8EC5FC"];
                UIColor* secondColor = [self.colorConvertHelper colorFromHexString:@"E0C3FC"];
                grad.colors = [NSArray arrayWithObjects:(id)[firstColor CGColor], (id)[secondColor CGColor], nil];
                grad.startPoint = CGPointMake(0.0, 0.5);
                grad.endPoint = CGPointMake(1.0, 0.5);
                [self.friendsCollectionView setBackgroundView:[[UIView alloc] init]];
                [self.friendsCollectionView.backgroundView.layer insertSublayer:grad atIndex:0];
                [self.friendsCollectionView.layer setShadowRadius:4];
                [self.friendsCollectionView.layer setShadowColor:[[UIColor grayColor] CGColor]];
                [self.friendsCollectionView.layer setShadowOpacity:1];
                [self.friendsCollectionView.layer setShadowOffset:CGSizeMake(0,0)];
                self.friendsCollectionView.layer.masksToBounds = NO;
                self.friendsCollectionView.clipsToBounds = NO;
                [self.friendsCollectionView reloadData];
            });
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    [self.friendsCollectionView reloadData];
}

#pragma mark - Parse API
- (void)setProfile {
    PFUser *user = [PFUser currentUser];
    [self.usernameLabel setText:@"@"];
    [self.usernameLabel setText:[self.usernameLabel.text stringByAppendingString:user.username]];
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

#pragma mark - IBAction

- (IBAction)activitiesButton:(id)sender {
    [self performSegueWithIdentifier:segueActivities sender:nil];
}
- (IBAction)addFriendButton:(id)sender {
    [self performSegueWithIdentifier:segueAddFriend sender:nil];
}
- (IBAction)settingsButton:(id)sender {
    [self performSegueWithIdentifier:segueSettings sender:nil];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.friendsArray.count;
}

#pragma mark - UICollectionViewDataSource

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCollectionCell *profileCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"profileCell" forIndexPath:indexPath];
    // Default place holder cell
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

- (CGSize)  collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int totalwidth = self.friendsCollectionView.bounds.size.width;
    int numberOfCellsPerRow = 3;
    int dimensions = (CGFloat)(totalwidth / numberOfCellsPerRow) - 10;
    return CGSizeMake(dimensions, dimensions);
}

#pragma mark - SettingsViewControllerDelegate
- (void)didUpdate {
    self.currentUser = [PFUser currentUser];
    [self viewDidLoad];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"settingsSegue"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        SettingsViewController *settingsController = (SettingsViewController *)navigationController.topViewController;
        settingsController.delegate = self;
    } else if ([segue.identifier isEqualToString:@"friendProfileSegue"]) {
        NSIndexPath *indexPath = [self.friendsCollectionView indexPathForCell:(PhotoCollectionCell *)sender];
        FriendProfileViewController *friendVC = [segue destinationViewController];
        friendVC.user = self.friendsArray[indexPath.row];
    }
}
@end
