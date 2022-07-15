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
static int const PENDING = 1;
@interface ActivitiesViewController ()<UITableViewDataSource, UITableViewDelegate, ActivityCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *requests;

@end

@implementation ActivitiesViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Assign tableview data source and delegate
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	[self.tableView reloadData];
	self.requests = [[NSMutableArray alloc] init];
	[self fetchActivities];
	self.tableView.rowHeight = UITableViewAutomaticDimension;
}
- (IBAction)backButton:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.requests.count;
}

- (void) fetchActivities {
	[self fetchRequests];
}

- (void) fetchRequests {
	// Query to find pending friend requests for this user
	PFQuery *query = [PFQuery queryWithClassName:@"Friendship"];
	PFUser *currentUser = [PFUser currentUser];
	[query whereKey:@"recipientId" equalTo:currentUser.objectId];
	[query whereKey:@"hasFriended" equalTo:@(PENDING)];
	[query orderByDescending:@"updatedAt"];
	[query findObjectsInBackgroundWithBlock:^(NSArray *friendships, NSError *error) {
	         if (friendships != nil) {
			 int i=0;
			 while(i<friendships.count) {
				 PFObject *friendship=friendships[i];
				 PFQuery *query = [PFUser query];
				 [query whereKey:@"objectId" equalTo:friendship[@"requesterId"]];
				 PFUser *user = [query findObjects][0];
				 [self.requests addObject:user];
				 i++;
			 }
			 [self.tableView reloadData];
		 } else {
			 NSLog(@"%@", error.localizedDescription);
		 }
	 }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	ActivityCell *cell=[tableView dequeueReusableCellWithIdentifier:@"ActivityCell"];
	cell.user = self.requests[indexPath.row];
	return cell;
}

- (void)activityCell:(ActivityCell *) activityCell didTap: (PFUser*)user {
	[self fetchActivities];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	NSIndexPath *indexPath = [self.tableView indexPathForCell:(ActivityCell *)sender];
	FriendProfileViewController *friendProfVC = [segue destinationViewController];
	friendProfVC.user = self.requests[indexPath.row];
}
@end
