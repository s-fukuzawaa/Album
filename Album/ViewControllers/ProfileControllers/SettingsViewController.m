//
//  SettingsViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/7/22.
//

#import "SettingsViewController.h"
#import "LoginViewController.h"
#import "Parse/Parse.h"
#import "SceneDelegate.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *pwField;

@end

@implementation SettingsViewController

- (IBAction)updateButton:(id)sender {
}
- (IBAction)backButton:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)logoutButton:(id)sender {
	SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
	LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
	myDelegate.window.rootViewController = loginViewController;
	[PFUser logOutInBackgroundWithBlock:nil];
}
@end
