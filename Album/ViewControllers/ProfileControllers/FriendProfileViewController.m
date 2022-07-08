//
//  FriendProfileViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/7/22.
//

#import "FriendProfileViewController.h"

@interface FriendProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@end

@implementation FriendProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.friendMapContainer.alpha = 0.0;
    self.friendsGridContainer.alpha = 1.0;
    // Do any additional setup after loading the view.
}
- (IBAction)viewSwitchControl:(UISegmentedControl*)sender {
    if(sender.selectedSegmentIndex == 0){
        [UIView animateWithDuration:0.5 animations:^{
            self.friendMapContainer.alpha = 0.0;
            self.friendsGridContainer.alpha = 1.0;
        }];
    } else { // Album View case
        [UIView animateWithDuration:0.5 animations:^{
            self.friendMapContainer.alpha = 1.0;
            self.friendsGridContainer.alpha = 0.0;
        }];
    }
}
- (IBAction)friendButton:(id)sender {
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NULL;
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
