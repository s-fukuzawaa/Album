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
@property (strong, nonatomic) ParseAPIHelper *apiHelper;
@property (strong, nonatomic) NSArray *filterFriendsArr;
@property (strong, nonatomic) NSArray *filterFriendshipArr;
@property (strong, nonatomic) NSArray *filterOtherFriendshipArr;
@property (strong, nonatomic) ColorConvertHelper *colorConvertHelper;
@end

@implementation CloseFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Set API helper
    self.apiHelper = [[ParseAPIHelper alloc] init];
    self.colorConvertHelper = [[ColorConvertHelper alloc] init];
    // Assign delegate and dataSource
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.closeSearchBar.delegate = self;
    // Fetch friends
    PFQuery *friendQuery = [PFQuery queryWithClassName:classNameFriendship];
    NSLog(@"%@",self.user.objectId);
    [friendQuery whereKey:@"requesterId" equalTo:self.user.objectId];
    [friendQuery whereKey:@"hasFriended" equalTo:@(2)];
    [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *friendships, NSError *error) {
        self.friendshipArr = friendships;
        self.filterFriendshipArr = friendships;
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
            self.filterFriendsArr = friendArr;
            self.otherFriendshipArr = otherFriendships;
            self.filterOtherFriendshipArr = otherFriendships;
            dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"AYYYY");
                            [self.tableView reloadData];
                self.tableView.rowHeight = UITableViewAutomaticDimension;
                        });
        } else {
            NSLog(@"%@",
                  error.localizedDescription);
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filterFriendsArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CloseFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CloseFriendCell"];
    cell.user = self.filterFriendsArr[indexPath.row];
    cell.delegate = self;
    cell.friendship = self.filterFriendshipArr[indexPath.row];
    cell.otherFriendship = self.filterOtherFriendshipArr[indexPath.row];
    //set close friend button
    UIColor *closeFriendButtonBackgroundColor;
    NSString *closeFriendButtonText;
    UIColor *closeFriendButtonTitleColor;
    if(cell.friendship.isClose) {
        closeFriendButtonBackgroundColor = [UIColor systemIndigoColor];
        closeFriendButtonText = @"Close Friended";
        closeFriendButtonTitleColor = [UIColor whiteColor];
    }else {
        closeFriendButtonBackgroundColor = [UIColor whiteColor];
        closeFriendButtonText = @"Add to Close Friends?";
        closeFriendButtonTitleColor = [UIColor systemIndigoColor];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [cell.closeFriendButton setTitleColor:closeFriendButtonBackgroundColor forState:UIControlStateNormal];
        [cell.closeFriendButton setTitle:closeFriendButtonText forState:UIControlStateNormal];
        [cell.closeFriendButton setBackgroundColor:closeFriendButtonTitleColor];
        [cell.closeFriendButton.layer setCornerRadius:10];
        [cell.layer setCornerRadius:20];
        [cell setClipsToBounds:YES];
        CAGradientLayer *grad = [CAGradientLayer layer];
        grad.frame = cell.bounds;
        UIColor* firstColor = [self.colorConvertHelper colorFromHexString:@"8BC6EC"];
        UIColor* secondColor = [self.colorConvertHelper colorFromHexString:@"9599E2"];
        grad.colors = [NSArray arrayWithObjects:(id)[firstColor CGColor], (id)[secondColor CGColor], nil];
        grad.startPoint = CGPointMake(0.0, 0.5);
        grad.endPoint = CGPointMake(1.0, 0.5);
        [cell setBackgroundView:[[UIView alloc] init]];
        [cell.backgroundView.layer insertSublayer:grad atIndex:0];
    });
    
    return cell;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length != 0) {
        
        NSPredicate *predicateFriend = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject[@"username"] containsString:searchText];
        }];
        self.filterFriendsArr = [self.filterFriendsArr filteredArrayUsingPredicate:predicateFriend];
        NSPredicate *predicateFriendship = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject[@"recipientId"] containsString:searchText];
        }];
        self.filterFriendshipArr = [self.filterFriendshipArr filteredArrayUsingPredicate:predicateFriendship];
        NSPredicate *predicateOtherFriendship = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject[@"requesterId"] containsString:searchText];
        }];
        self.filterOtherFriendshipArr = [self.filterOtherFriendshipArr filteredArrayUsingPredicate:predicateOtherFriendship];
          
    }
    else {
        self.filterFriendsArr = self.friendsArr;
        self.filterFriendshipArr = self.friendshipArr;
        self.filterOtherFriendshipArr = self.filterOtherFriendshipArr;
    }
    
    [self.tableView reloadData];
 
}


// Used to find specfic user
- (void)fetchUser:(NSString *)userId withBlock: (PFQueryArrayResultBlock) block{
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"objectId" equalTo:userId];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable users, NSError * _Nullable error) {
        NSArray *usersArr = [[NSArray alloc] init];
        if (users != nil) {
            NSLog(@"Successfully fetched users!");
            // For each friend, find their pins
            usersArr = users;
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        block(usersArr,error);
    }];
}

#pragma mark - CloseFriendCellDelegate
- (void)closeFriendCell:(CloseFriendCell *) closeFriendCell didTap: (PFUser *)user {
    [self performSegueWithIdentifier:@"closeProfileSegue" sender:user];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"closeProfileSegue"]) {
        FriendProfileViewController *friendProfileVC = [segue destinationViewController];
        friendProfileVC.user = (PFUser*)sender;
    }
}


@end
