//
//  CloseFriendViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/28/22.
//

#import "CloseFriendViewController.h"
#import "FriendProfileViewController.h"
#import "ParseAPIHelper.h"
#import "CloseFriendCell.h"
#import "AlbumConstants.h"
#import "Friendship.h"

@interface CloseFriendViewController () <UITableViewDataSource, UITableViewDelegate, CloseFriendCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *friendsArr;
@property (strong, nonatomic) NSArray *friendshipArr;
@property (strong, nonatomic) NSArray *otherFriendshipArr;
@property (strong, nonatomic) ParseAPIHelper *apiHelper;

@end

@implementation CloseFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Set API helper
    self.apiHelper = [[ParseAPIHelper alloc] init];
    // Assign collection view delegate and dataSource
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    // Fetch friends
    PFQuery *friendQuery = [PFQuery queryWithClassName:classNameFriendship];
    NSLog(@"%@",self.user.objectId);
    [friendQuery whereKey:@"requesterId" equalTo:self.user.objectId];
    [friendQuery whereKey:@"hasFriended" equalTo:@(2)];
    [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *friendships, NSError *error) {
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
    if(cell.friendship.isClose) {
        closeFriendButtonBackgroundColor = [UIColor colorWithRed:0.39 green:0.28 blue:0.22 alpha:1.00];
        closeFriendButtonText = @"Close Friended";
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell.closeFriendButton.imageView setImage:[UIImage systemImageNamed:@"checkmark"]];
        });
        closeFriendButtonTitleColor = [UIColor whiteColor];
    }else {
        closeFriendButtonBackgroundColor = [UIColor whiteColor];
        closeFriendButtonText = @"Add to Close Friends?";
        closeFriendButtonTitleColor = [UIColor colorWithRed:0.39 green:0.28 blue:0.22 alpha:1.00];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [cell.closeFriendButton setTitleColor:closeFriendButtonBackgroundColor forState:UIControlStateNormal];
        [cell.closeFriendButton setTitle:closeFriendButtonText forState:UIControlStateNormal];
        [cell.closeFriendButton setBackgroundColor:closeFriendButtonTitleColor];
    });
    return cell;
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
