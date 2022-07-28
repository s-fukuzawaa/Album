//
//  CloseFriendViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/28/22.
//

#import "CloseFriendViewController.h"
#import "ParseAPIHelper.h"
#import "CloseFriendCell.h"
@interface CloseFriendViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *friendsArr;
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
    [self.apiHelper fetchFriends:self.user.objectId withBlock:^(NSArray *friendArr, NSError *error) {
        if (friendArr != nil) {
            self.friendsArr = friendArr;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        } else {
            NSLog(@"%@", error.localizedDescription);
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
    return cell;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
