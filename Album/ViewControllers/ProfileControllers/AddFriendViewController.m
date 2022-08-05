//
//  AddFriendViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/7/22.
//

#import "AddFriendViewController.h"
#import "FriendCell.h"
#import "Parse/Parse.h"
#import "ColorConvertHelper.h"
#import "FriendProfileViewController.h"

@interface AddFriendViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchFriendField;
@property (strong, nonatomic) NSMutableArray *friendsArr;
@property (strong, nonatomic) ColorConvertHelper *colorConvertHelper;
@property (nonatomic, strong) UIView* overlayView;
@end

@implementation AddFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.colorConvertHelper = [[ColorConvertHelper alloc] init];
}

#pragma mark - IBAction

- (IBAction)searchButton:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
//        self.overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
//
//        self.overlayView.backgroundColor = [UIColor whiteColor];
//        self.overlayView.alpha = 1;
//        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] init];
//        activityView.center = self.view.center;
//        [self.overlayView addSubview:activityView];
//        [activityView startAnimating];
//        [self.view addSubview:self.overlayView];
//        [self.view bringSubviewToFront:self.overlayView];
        // Search user by username
        PFQuery *query = [PFUser query];
        PFUser *currentUser = [PFUser currentUser];
        [query whereKey:@"objectId" notEqualTo:currentUser.objectId];
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
//            [UIView transitionWithView:self.view duration:2 options:UIViewAnimationOptionTransitionNone animations:^(void){self.overlayView .alpha=0.0f;} completion:^(BOOL finished){[self.overlayView  removeFromSuperview];}];
        }];
    });
    
}
- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.friendsArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendCell"];
    cell.user = self.friendsArr[indexPath.row];
    [cell setBackgroundColor:[UIColor clearColor]];

    CAGradientLayer *grad = [CAGradientLayer layer];
    grad.frame = cell.bounds;
    UIColor* firstColor = [self.colorConvertHelper colorFromHexString:@"8EC5FC"];
    UIColor* secondColor = [self.colorConvertHelper colorFromHexString:@"E0C3FC"];
    grad.colors = [NSArray arrayWithObjects:(id)[firstColor CGColor], (id)[secondColor CGColor], nil];
    grad.startPoint = CGPointMake(0.0, 0.5);
    grad.endPoint = CGPointMake(1.0, 0.5);
    [cell setBackgroundView:[[UIView alloc] init]];
    [cell.backgroundView.layer insertSublayer:grad atIndex:0];
    [cell.layer setShadowRadius:4];
    [cell.layer setShadowColor:[[UIColor grayColor] CGColor]];
    [cell.layer setShadowOpacity:1];
    [cell.layer setShadowOffset:CGSizeMake(0,0)];
    cell.layer.masksToBounds = NO;
    cell.clipsToBounds = NO;
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(FriendCell *)sender];
    FriendProfileViewController *friendProfVC = [segue destinationViewController];
    friendProfVC.user = self.friendsArr[indexPath.row];
}


@end
