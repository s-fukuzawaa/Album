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
#import "AlbumConstants.h"
#import "Parse/Parse.h"
#import "PFImageView.h"


@interface ProfileViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *friendsCollectionView;
@property (weak, nonatomic) IBOutlet PFImageView *profileImageView;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Assign collection view delegate and dataSource
    self.friendsCollectionView.dataSource = self;
    self.friendsCollectionView.delegate = self;
    // Load profile image
    [self fetchProfile];
}
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
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(
                                                                                                                                          NSIndexPath *)indexPath {
                                                                                                                                              return CGSizeMake(3, 3);
                                                                                                                                          }

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return NULL;
}

- (void)fetchProfile {
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

@end
