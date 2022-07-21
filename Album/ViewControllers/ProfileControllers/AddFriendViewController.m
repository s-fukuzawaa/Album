//
//  AddFriendViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/7/22.
//

#import "AddFriendViewController.h"
#import "FriendCell.h"
#import "Parse/Parse.h"
#import "FriendProfileViewController.h"

@interface AddFriendViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchFriendField;
@property (strong, nonatomic) NSMutableArray *friendsArr;

@end

@implementation AddFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (IBAction)searchButton:(id)sender {
    PFQuery *query = [PFUser query];
    PFUser *currentUser = [PFUser currentUser];
    [query whereKey:@"username" notEqualTo:currentUser.username];
    [query whereKey:@"username" equalTo:self.searchFriendField.text];
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
               if (users != nil) {
               self.friendsArr = (NSMutableArray *)users;
               // Set up table view
               self.tableView.dataSource = self;
               self.tableView.delegate = self;
               [self.tableView reloadData];
               self.tableView.rowHeight = UITableViewAutomaticDimension;
               } else {
               NSLog(@"%@", error.localizedDescription);
               }
           }];
}
- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.friendsArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendCell"];
    cell.user = self.friendsArr[indexPath.row];
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(FriendCell *)sender];
    FriendProfileViewController *friendProfVC = [segue destinationViewController];
    friendProfVC.user = self.friendsArr[indexPath.row];
}


@end
