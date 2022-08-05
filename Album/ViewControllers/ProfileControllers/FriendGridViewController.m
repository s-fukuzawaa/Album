//
//  FriendGridViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/21/22.
//

#import "FriendGridViewController.h"
#import "FriendProfileViewController.h"
#import "ParseAPIHelper.h"
#import "ColorConvertHelper.h"
#import "PhotoCollectionCell.h"

@interface FriendGridViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *friendCollectionView;
@property (strong, nonatomic) ParseAPIHelper *apiHelper;
@property (strong, nonatomic) ColorConvertHelper *colorConvertHelper;
@property (strong, nonatomic) NSArray *friendsArray;
@end

@implementation FriendGridViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Set API helper
    self.apiHelper = [[ParseAPIHelper alloc] init];
    self.colorConvertHelper = [[ColorConvertHelper alloc]init];
    // Assign collection view delegate and dataSource
    self.friendCollectionView.delegate = self;
    self.friendCollectionView.dataSource = self;
    // Fetch friends
    [self.apiHelper fetchFriends:self.user.objectId withBlock:^(NSArray *friendArr, NSError *error) {
        if (friendArr != nil) {
            self.friendsArray = friendArr;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.friendCollectionView reloadData];
            });
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    [self.friendCollectionView reloadData];
} /* viewDidLoad */
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.friendCollectionView reloadData];
}

#pragma mark - UICollectionDataSource

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
    dispatch_async(dispatch_get_main_queue(), ^{
        profileCell.photoImageView.layer.cornerRadius = profileCell.photoImageView.frame.size.width / 2;
        profileCell.photoImageView.layer.masksToBounds = YES;
        [profileCell.photoImageView.layer setBorderColor:[[self.colorConvertHelper colorFromHexString:self.friendsArray[indexPath.row][
                                                                                                                                       @"colorHexString"]] CGColor]];
        [profileCell.photoImageView.layer setBorderWidth:1];
    });
    return profileCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(
        NSIndexPath *)indexPath {
    int totalwidth = self.friendCollectionView.bounds.size.width;
    int numberOfCellsPerRow = 3;
    int dimensions = (CGFloat)(totalwidth / numberOfCellsPerRow) - 10;
    return CGSizeMake(dimensions, dimensions);
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.friendCollectionView indexPathForCell:(PhotoCollectionCell *)sender];
    FriendProfileViewController *friendVC = [segue destinationViewController];
    friendVC.user = self.friendsArray[indexPath.row];
}


@end
