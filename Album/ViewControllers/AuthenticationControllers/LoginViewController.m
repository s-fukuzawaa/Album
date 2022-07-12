//
//  LoginViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/6/22.
//

#import "LoginViewController.h"
#import "SignUpViewController.h"
#import "Parse/Parse.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *pwField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)loginButton:(id)sender {
    [self performSegueWithIdentifier:@"loginSegue" sender:nil];
}
- (IBAction)signUpButton:(id)sender {
    [self performSegueWithIdentifier:@"signupSegue" sender:nil];
}

- (IBAction) tap:(id) sender{
    [self.view endEditing:YES];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqual:@"loginSegue"]){
        UITabBarController *navigationController = [segue destinationViewController];
    }else{
        SignUpViewController *signupVC = [segue destinationViewController];
    }
}


@end
