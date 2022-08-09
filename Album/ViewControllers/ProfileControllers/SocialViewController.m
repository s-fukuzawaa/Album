//
//  SocialViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/27/22.
//

#import "SocialViewController.h"
#import "CloseFriendViewController.h"

@interface SocialViewController ()

@end

@implementation SocialViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchUserContainer.alpha = 1.0;
    self.searchFriendContainer.alpha = 0.0;
}

#pragma mark - IBAction

- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)switchControl:(UISegmentedControl*)sender {
    if(sender.selectedSegmentIndex == 0) {
        [UIView animateWithDuration:0.5 animations:^{
            self.searchUserContainer.alpha = 1.0;
            self.searchFriendContainer.alpha = 0.0;
        }];
    }else{
        [UIView animateWithDuration:0.5 animations:^{
            self.searchUserContainer.alpha = 0.0;
            self.searchFriendContainer.alpha = 1.0;
        }];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"searchFriendSegue"]) {
        CloseFriendViewController *closeFriendVC = [segue destinationViewController];
        closeFriendVC.user = [PFUser currentUser];
    }
}


@end
