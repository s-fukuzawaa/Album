//
//  ProfileViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/7/22.
//

#import "ProfileViewController.h"
#import "ActivitiesviewController.h"
#import "AddFriendViewController.h"
#import "SettingsViewController.h"

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)activitiesButton:(id)sender {
    [self performSegueWithIdentifier:@"activitiesSegue" sender:nil];
}
- (IBAction)addFriendButton:(id)sender {
    [self performSegueWithIdentifier:@"addFriendSegue" sender:nil];
}
- (IBAction)settingsButton:(id)sender {
    [self performSegueWithIdentifier:@"settingsSegue" sender:nil];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"activitiesSegue"]){
        UINavigationController *navigationController = [segue destinationViewController];
        ActivitiesViewController *activitiesController = (ActivitiesViewController*)navigationController.topViewController;
//        activitiesController.delegate = self; TODO: Add delegate later
        
    }else if([segue.identifier isEqualToString:@"addFriendSegue"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        AddFriendViewController *addFriendController = (AddFriendViewController*)navigationController.topViewController;
//        addFriendController.delegate = self; TODO: Add delegate later
    }else if([segue.identifier isEqualToString:@"setttingsSegue"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        SettingsViewController *settingsController = (SettingsViewController*)navigationController.topViewController;
//        settingsController.delegate = self; TODO: Add delegate later
    }
}


@end
