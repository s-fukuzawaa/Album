//
//  ActivitiesViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/7/22.
//

#import "ActivitiesViewController.h"
#import "FriendProfileViewController.h"
#import "ColorConvertHelper.h"
#import "ActivityCell.h"
#import "Parse/Parse.h"
#import "AlbumConstants.h"

@interface ActivitiesViewController ()<UITableViewDataSource, UITableViewDelegate, ActivityCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *friendRequests;
@end

@implementation ActivitiesViewController

#pragma mark - UIViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchFriendRequests];
    [self.tableView reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Assign tableview data source and delegate
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.friendRequests = [[NSMutableArray alloc] init];
    self.tableView.rowHeight = UITableViewAutomaticDimension;    
}

#pragma mark - IBAction

- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Parse API

- (void)fetchFriendRequests {
    // Query to find pending friend requests for this user
    self.friendRequests = [[NSMutableArray alloc] init];
    PFQuery *query = [PFQuery queryWithClassName:classNameFriendship];
    PFUser *currentUser = [PFUser currentUser];
    [query whereKey:@"recipientId" equalTo:currentUser.objectId];
    [query whereKey:@"hasFriended" equalTo:@(PENDING)];
    [query orderByDescending:@"updatedAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *friendships, NSError *error) {
        if (friendships != nil) {
            for (PFObject *friendship in friendships) {
                PFQuery *query = [PFUser query];
                [query whereKey:@"objectId" equalTo:friendship[@"requesterId"]];
                PFUser *user = [query findObjects][0];
                [self.friendRequests addObject:user];
            }
            [self.tableView reloadData];
        } else {
            [self errorAlert:error.localizedDescription];
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.friendRequests.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActivityCell"];
    [cell.layer setCornerRadius:20];
    [cell setClipsToBounds:YES];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = cell.bounds;
    UIColor* firstColor = [ColorConvertHelper colorFromHexString:pinkColor1];
    UIColor* secondColor = [ColorConvertHelper colorFromHexString:pinkColor2];
    UIColor* thirdColor = [ColorConvertHelper colorFromHexString:pinkColor3];
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[firstColor CGColor], (id)[secondColor CGColor], (id)[thirdColor CGColor], nil];
    gradientLayer.startPoint = CGPointMake(0.0, 0.5);
    gradientLayer.endPoint = CGPointMake(1.0, 0.5);
    [cell setBackgroundView:[[UIView alloc] init]];
    [cell.backgroundView.layer insertSublayer:gradientLayer atIndex:0];
    cell.user = self.friendRequests[indexPath.row];
    return cell;
}

#pragma mark - ActivityCellDelegate

- (void)activityCell:(ActivityCell *)activityCell didTap:(PFUser *)user {
    [self fetchFriendRequests];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(ActivityCell *)sender];
    FriendProfileViewController *friendProfVC = [segue destinationViewController];
    friendProfVC.user = self.friendRequests[indexPath.row];
}

#pragma mark - UIAlert

- (void) errorAlert: (NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:message
                                                            preferredStyle:(UIAlertControllerStyleAlert)];

    
    // Create an OK action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}
@end
