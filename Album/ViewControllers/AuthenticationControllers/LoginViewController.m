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
    NSString *username = self.usernameField.text;
    NSString *password = self.pwField.text;
    if([self.usernameField.text isEqual:@""]|| [self.pwField.text isEqual:@""]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Empty Fields" message:@"Username or Password is empty!"
                                                                preferredStyle:(UIAlertControllerStyleAlert)];
        // create a cancel action
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * _Nonnull action) {
            // handle cancel response here. Doing nothing will dismiss the view.
        }];
        // add the cancel action to the alertController
        [alert addAction:cancelAction];
        
        // create an OK action
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
            // handle response here.
        }];
        // add the OK action to the alert controller
        [alert addAction:okAction];
        
        [self presentViewController:alert animated:YES completion:^{
            // optional code for what happens after the alert controller has finished presenting
        }];
    }
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            NSLog(@"User log in failed: %@", error.localizedDescription);
            [self authError];
        } else {
            NSLog(@"User logged in successfully");
            [self performSegueWithIdentifier:@"loginSegue" sender:nil];
        }
    }];
}

- (void) authError {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"No such user exist!"
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    // create a cancel action
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    // add the cancel action to the alertController
    [alert addAction:cancelAction];
    
    // create an OK action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    // add the OK action to the alert controller
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
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
