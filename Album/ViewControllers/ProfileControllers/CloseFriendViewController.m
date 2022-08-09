//
//  CloseFriendViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/28/22.
//

#import "CloseFriendViewController.h"
#import "FriendProfileViewController.h"
#import "ParseAPIHelper.h"
#import "ColorConvertHelper.h"
#import "CloseFriendCell.h"
#import "AlbumConstants.h"
#import "Friendship.h"

@interface CloseFriendViewController () <UITableViewDataSource, UITableViewDelegate, CloseFriendCellDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *closeSearchBar;
@property (strong, nonatomic) NSArray *friendsArr;
@property (strong, nonatomic) NSArray *friendshipArr;
@property (strong, nonatomic) NSArray *otherFriendshipArr;
@end

@implementation CloseFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Assign delegate and dataSource
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.closeSearchBar.delegate = self;
    [self setFriendshipStructure];
}

- (void)setFriendshipStructure {
    // Fetch friends
    NSArray *friendships = [ParseAPIHelper fetchFriendships:self.user.objectId];
    self.friendshipArr = friendships;
    NSMutableArray *friendArr = [[NSMutableArray alloc] init];
    NSMutableArray *otherFriendships = [[NSMutableArray alloc] init];
    if (friendships != nil) {
        for (Friendship *friendship in friendships) {
            NSString *friendId = friendship[@"recipientId"];
            PFQuery *userQuery = [PFUser query];
            [userQuery whereKey:@"objectId" equalTo:friendId];
            PFUser *user = [userQuery findObjects][0];
            [friendArr addObject:user];

            // Fetch friendship from other side
            PFQuery *query = [PFQuery queryWithClassName:classNameFriendship];
            [query whereKey:@"recipientId" equalTo:self.user.objectId];
            [query whereKey:@"requesterId" equalTo:user.objectId];
            [otherFriendships addObject:[query findObjects][0]];
        }
        self.friendsArr = friendArr;
        self.otherFriendshipArr = otherFriendships;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            self.tableView.rowHeight = UITableViewAutomaticDimension;
        });
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.friendsArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CloseFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CloseFriendCell"];
    cell.user = self.friendsArr[indexPath.row];
    cell.delegate = self;
    cell.friendship = self.friendshipArr[indexPath.row];
    cell.otherFriendship = self.otherFriendshipArr[indexPath.row];
    //set close friend button
    UIColor *closeFriendButtonBackgroundColor;
    NSString *closeFriendButtonText;
    UIColor *closeFriendButtonTitleColor;
    if (cell.friendship.isClose) {
        closeFriendButtonBackgroundColor = [UIColor systemIndigoColor];
        closeFriendButtonText = @"Close Friended";
        closeFriendButtonTitleColor = [UIColor whiteColor];
    } else {
        closeFriendButtonBackgroundColor = [UIColor whiteColor];
        closeFriendButtonText = @"Add to Close Friends?";
        closeFriendButtonTitleColor = [UIColor systemIndigoColor];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [cell.closeFriendButton setTitleColor:closeFriendButtonBackgroundColor forState:UIControlStateNormal];
        [cell.closeFriendButton setTitle:closeFriendButtonText forState:UIControlStateNormal];
        [cell.closeFriendButton setBackgroundColor:closeFriendButtonTitleColor];
        [cell.closeFriendButton.layer setCornerRadius:20];
        [cell.layer setCornerRadius:15];
        [cell setClipsToBounds:YES];
        CAGradientLayer *grad = [CAGradientLayer layer];
        grad.frame = cell.bounds;
        UIColor *firstColor = [ColorConvertHelper colorFromHexString:@"8BC6EC"];
        UIColor *secondColor = [ColorConvertHelper colorFromHexString:@"9599E2"];
        grad.colors = [NSArray arrayWithObjects:(id)[firstColor CGColor], (id)[secondColor CGColor], nil];
        grad.startPoint = CGPointMake(0.0, 0.5);
        grad.endPoint = CGPointMake(1.0, 0.5);
        [cell setBackgroundView:[[UIView alloc] init]];
        [cell.backgroundView.layer insertSublayer:grad atIndex:0];
    });
    return cell;
}


#pragma mark - CloseFriendCellDelegate
- (void)closeFriendCell:(CloseFriendCell *)closeFriendCell didTap:(PFUser *)user {
    [self performSegueWithIdentifier:@"closeProfileSegue" sender:user];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"closeProfileSegue"]) {
        FriendProfileViewController *friendProfileVC = [segue destinationViewController];
        friendProfileVC.user = (PFUser *)sender;
    }
}
@end
