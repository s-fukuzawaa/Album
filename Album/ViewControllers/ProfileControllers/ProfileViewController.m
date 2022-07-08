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

@interface ProfileViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UICollectionView *friendsCollectionView;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Assign collection view delegate and dataSource
    self.friendsCollectionView.dataSource = self;
    self.friendsCollectionView.delegate = self;
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

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
//    int totalwidth = self.gridView.bounds.size.width;
//    int numberOfCellsPerRow = 3;
//    int dimensions = (CGFloat)(totalwidth / numberOfCellsPerRow) - 10;
//    return CGSizeMake(dimensions, dimensions);
    return CGSizeMake(3, 3);
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
//    GridViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GridViewCell" forIndexPath:indexPath];
//    PFFileObject *file = self.posts[indexPath.row][@"image"];
//    [file getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
//        if (!error) {
//            UIImage *image = [UIImage imageWithData:imageData];
//            [cell.image setImage:image];
//        }
//    }];
//    cell.post =self.posts[indexPath.row];
//    return cell;
    return NULL;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"activitiesSegue"]){
        UINavigationController *navigationController = [segue destinationViewController];
        ActivitiesViewController *activitiesController = (ActivitiesViewController*)navigationController.topViewController;
//        activitiesController.delegate = self; TODO: Add delegate later
        
    }else if([segue.identifier isEqualToString:@"addFriendSegue"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        AddFriendViewController *addFriendController = (AddFriendViewController*)navigationController.topViewController;
//        addFriendController.delegate = self; TODO: Add delegate later
    }else if([segue.identifier isEqualToString:@"settingsSegue"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        SettingsViewController *settingsController = (SettingsViewController*)navigationController.topViewController;
//        settingsController.delegate = self; TODO: Add delegate later
    }
}


@end
