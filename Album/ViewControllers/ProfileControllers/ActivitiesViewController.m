//
//  ActivitiesViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/7/22.
//

#import "ActivitiesViewController.h"
#import "FriendProfileViewController.h"
#import "ActivityCell.h"
#import "Parse/Parse.h"
#import "AlbumConstants.h"

@interface ActivitiesViewController ()<UITableViewDataSource, UITableViewDelegate, ActivityCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *requests;

@end

@implementation ActivitiesViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchActivities];
    [self.tableView reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Assign tableview data source and delegate
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.requests = [[NSMutableArray alloc] init];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}
- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)fetchActivities {
    [self fetchRequests];
}

- (void)fetchRequests {
    // Query to find pending friend requests for this user
    self.requests = [[NSMutableArray alloc] init];
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
                [self.requests addObject:user];
            }
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
} /* fetchRequests */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.requests.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActivityCell"];
    cell.user = self.requests[indexPath.row];
    return cell;
}

- (void)activityCell:(ActivityCell *)activityCell didTap:(PFUser *)user {
    [self fetchActivities];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(ActivityCell *)sender];
    FriendProfileViewController *friendProfVC = [segue destinationViewController];
    friendProfVC.user = self.requests[indexPath.row];
}
@end
