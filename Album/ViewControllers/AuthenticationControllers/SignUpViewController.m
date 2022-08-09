//
//  SignUpViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/6/22.
//

#import "SignUpViewController.h"
#import "ColorConvertHelper.h"
#import "FCColorPickerViewController.h"
#import "Parse/Parse.h"
#import "PFImageView.h"

@interface SignUpViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, FCColorPickerViewControllerDelegate>
@property (weak, nonatomic) IBOutlet PFImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *pwField;
@property (weak, nonatomic) IBOutlet UIImageView *colorView;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic) BOOL isPublic;
@property (nonatomic, strong) NSMutableArray *overlayViews;
@end

@implementation SignUpViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Tap profile to change configuration
    UITapGestureRecognizer *profileTapGestureRecognizer =
    [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapUserProfile:)];
    [self.profileImageView addGestureRecognizer:profileTapGestureRecognizer];
    [self.profileImageView setUserInteractionEnabled:YES];
    // Initialize confetti animation structure
    self.overlayViews = [[NSMutableArray alloc] init];
}
- (void)signUpAlert:(BOOL)success {
    NSString *message = @"Sign Up Failed!";
    if (success) {
        message = @"Sign Up Success!";
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sign Up" message:message
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    //Ok
    UIAlertAction *okay = [UIAlertAction actionWithTitle:@"OK"
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction *_Nonnull action) {
        [UIView                      transitionWithView:self.view duration:1 options:
         UIViewAnimationOptionTransitionNone animations:^(void) {
            for (
                 UIView *view in self.overlayViews)
            {
                view
                    .alpha = 0.0f;
            }
        } completion:^(BOOL finished) {
            for (UIView *view in self.overlayViews) {
                [view removeFromSuperview];
            }
        }];
    }];
    // Add the cancel action to the alert controller
    [alert addAction:okay];
    
    [self presentViewController:alert animated:YES completion:nil];
} /* signUpAlert */
#pragma mark - IBAction

- (IBAction)signUpButton:(id)sender {
    // Sign up user to Parse backend
    [self registerUser];
}

- (IBAction)didTap:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)colorPickButton:(id)sender {
    FCColorPickerViewController *colorPicker = [FCColorPickerViewController colorPicker];
    colorPicker.color = self.color;
    colorPicker.delegate = self;
    
    [colorPicker setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentViewController:colorPicker animated:YES completion:nil];
}
- (IBAction)cancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)isPublicSwitch:(id)sender {
    self.isPublic = ![(UISwitch *)sender isOn];
}

- (void)animateConfetti {
    // How many pieces to generate
    int confettiCount = 200;
    
    // What colors should the pieces be?
    NSArray *confettiColors = @[[UIColor redColor], [UIColor greenColor], [UIColor yellowColor], [UIColor blueColor]];
    
    
    // Everything else that you can configure
    int screenWidth = self.view.frame.size.width;
    int screenHeight = self.view.frame.size.height;
    int randomStartPoint;
    int randomStartConfettiLength;
    int randomEndConfettiLength;
    int randomEndPoint;
    int randomDelayTime;
    int randomFallTime;
    int randomRotation;
    
    for (int i = 0; i < confettiCount; i++) {
        randomStartPoint = arc4random_uniform(screenWidth);
        randomEndPoint = arc4random_uniform(screenWidth);
        randomDelayTime = arc4random_uniform(100);
        randomFallTime = arc4random_uniform(3);
        randomRotation = arc4random_uniform(360);
        randomStartConfettiLength = arc4random_uniform(15);
        randomEndConfettiLength = arc4random_uniform(15);
        NSUInteger randomColor = arc4random() % [confettiColors count];
        
        UIView *confetti = [[UIView alloc]initWithFrame:CGRectMake(randomStartPoint, -10, randomStartConfettiLength, 8)];
        [confetti setBackgroundColor:confettiColors[randomColor]];
        confetti.alpha = .4;
        [self.view addSubview:confetti];
        [self.overlayViews addObject:confetti];
        [UIView animateWithDuration:randomFallTime + 1 delay:randomDelayTime * .02 options:UIViewAnimationOptionRepeat animations:^{
            [confetti
             setFrame:
                 CGRectMake(
                            randomEndPoint,
                            screenHeight +
                            30,
                            randomEndConfettiLength,
                            8)];
            confetti.
            transform =
            CGAffineTransformMakeRotation(
                                          randomRotation);
        } completion:nil];
    }
} /* animateConfetti */

#pragma mark - Parse API

- (void)registerUser {
    // Initialize a user object
    PFUser *newUser = [PFUser user];
    // Set user properties
    newUser.username = self.usernameField.text;
    newUser.email = self.emailField.text;
    newUser.password = self.pwField.text;
    newUser[@"profileImage"] = [self getPFFileFromImage:self.profileImageView.image];
    newUser[@"colorHexString"] = [ColorConvertHelper hexStringForColor:self.color];
    newUser[@"isPublic"] = @(self.isPublic);
    // Check for empty fields
    if ([self.usernameField.text isEqual:@""] || [self.pwField.text isEqual:@""] || [self.emailField.text isEqual:@""]) {
        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Empty Fields" message:
         @"Username or Password or Email is empty!"
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
        return;
    }
    // Call sign up function on the object
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
            [self signUpAlert:NO];
        } else {
            NSLog(@"User registered successfully");
            [self animateConfetti];
            [self signUpAlert:YES];
        }
    }];
} /* registerUser */

- (void)didTapUserProfile:(UITapGestureRecognizer *)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Media" message:@"Choose"
                                                                preferredStyle:(UIAlertControllerStyleAlert)];
        // Take photo action
        UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"Take Photo"
                                                              style:UIAlertActionStyleCancel
                                                            handler:^(UIAlertAction *_Nonnull action) {
            UIImagePickerController *imagePickerVC = [UIImagePickerController new];
            imagePickerVC.delegate = self;
            imagePickerVC.allowsEditing = YES;
            imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:imagePickerVC animated:YES completion:nil];
        }];
        // Add the take photo action to the alertController
        [alert addAction:photoAction];
        // Create an upload from library action
        UIAlertAction *uploadAction = [UIAlertAction actionWithTitle:@"Upload from Library"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *_Nonnull action) {
            UIImagePickerController *imagePickerVC = [UIImagePickerController new];
            imagePickerVC.delegate = self;
            imagePickerVC.allowsEditing = YES;
            imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:imagePickerVC animated:YES completion:nil];
        }];
        // Add the upload from library action to the alert controller
        [alert addAction:uploadAction];
        //Cancel
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                         style:UIAlertActionStyleDefault
                                                       handler:nil];
        // Add the cancel action to the alert controller
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        NSLog(@"Camera 🚫 available so we will use photo library instead");
        UIImagePickerController *imagePickerVC = [UIImagePickerController new];
        imagePickerVC.delegate = self;
        imagePickerVC.allowsEditing = YES;
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePickerVC animated:YES completion:nil];
    }
} /* didTapUserProfile */

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info {
    // Get the image captured by the UIImagePickerController
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    originalImage = [self resizeImage:originalImage withSize:self.profileImageView.image.size];
    [self.profileImageView setImage:originalImage];
    PFFileObject *file = [self getPFFileFromImage:originalImage];
    [self.profileImageView setFile:file];
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (PFFileObject *)getPFFileFromImage:(UIImage *_Nullable)image {
    // Check if image is not nil
    if (!image) {
        return nil;
    }
    NSData *imageData = UIImagePNGRepresentation(image);
    // Get image data and check if that is not nil
    if (!imageData) {
        return nil;
    }
    return [PFFileObject fileObjectWithName:@"image.png" data:imageData];
}

- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - FCColorPickerViewControllerDelegate Methods

- (void)colorPickerViewController:(FCColorPickerViewController *)colorPicker didSelectColor:(UIColor *)color {
    // Save color and display in color box
    self.color = color;
    [self.colorView setImage:[ColorConvertHelper createImageWithColor:color]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)colorPickerViewControllerDidCancel:(FCColorPickerViewController *)colorPicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
