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
    // Alert for empty fields
    if ([self.usernameField.text isEqual:@""] || [self.pwField.text isEqual:@""]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Empty Fields" message:@"Username or Password is empty!"
                                                                preferredStyle:(UIAlertControllerStyleAlert)];
        // Create a cancel action
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        [alert addAction:cancelAction];
        
        // Create an OK action
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    // Ask Parse to login
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
        if (error != nil) {
            NSLog(@"User log in failed: %@", error.localizedDescription);
            // Present auth error alert
            [self authError];
        } else {
            NSLog(@"User logged in successfully");
            // Segue to main home view
            [self performSegueWithIdentifier:@"loginSegue" sender:nil];
        }
    }];
} /* loginButton */

- (void)authError {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"No such user exist!"
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    // Create a cancel action
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alert addAction:cancelAction];
    
    // Create an OK action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}
- (IBAction)signUpButton:(id)sender {
    [self performSegueWithIdentifier:@"signupSegue" sender:nil];
}

- (IBAction)tap:(id)sender {
    [self.view endEditing:YES];
}
@end
