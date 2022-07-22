//
//  SettingsViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/7/22.
//

#import "ColorConvertHelper.h"
#import "SettingsViewController.h"
#import "FCColorPickerViewController.h"
#import "LoginViewController.h"
#import "Parse/PFImageView.h"
#import "Parse/Parse.h"
#import "SceneDelegate.h"

@interface SettingsViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, FCColorPickerViewControllerDelegate>
@property (weak, nonatomic) IBOutlet PFImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *pwField;
@property (weak, nonatomic) IBOutlet UIImageView *colorView;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) ColorConvertHelper *colorHelper;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setCurrentView];
    // Tap gesture added to change profile pic
    UITapGestureRecognizer *profileTapGestureRecognizer =
    [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapUserProfile:)];
    [self.profileImageView addGestureRecognizer:profileTapGestureRecognizer];
    [self.profileImageView setUserInteractionEnabled:YES];
    // Add color converting helper object
    self.colorHelper = [[ColorConvertHelper alloc] init];
}
- (void)setCurrentView {
    // Fetch current user's profile and set it
    PFUser *user = [PFUser currentUser];
    if (user[@"profileImage"]) {
        PFFileObject *file = user[@"profileImage"];
        [self.profileImageView setFile:file];
        [file getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:imageData];
                [self.profileImageView setImage:image];
                self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height / 2;
                self.profileImageView.layer.masksToBounds = YES;
            }
        }];
    }
    
    // Display current user marker color
    if (user[@"colorHexString"]) {
        UIColor *color = [self.colorHelper colorFromHexString:user[@"colorHexString"]];
        [self.colorView setImage:[self.colorHelper createImageWithColor:color]];
    }
    self.usernameField.text = user.username;
    self.emailField.text = user.email;
    self.pwField.text = user.password;
    self.pwField.placeholder = @"Please enter non-empty password";
} /* setCurrentView */

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

- (IBAction)updateButton:(id)sender {
    PFUser *user = [PFUser currentUser];
    if (![self.usernameField.text isEqualToString:user.username]) {
        user.username = self.usernameField.text;
    }
    if (![self.pwField.text isEqualToString:user.password] && ![self.pwField.text isEqualToString:@""]) {
        user.password = self.pwField.text;
    }
    if (![self.emailField.text isEqualToString:user.email]) {
        user.email = self.emailField.text;
    }
    if (![self.profileImageView.file isEqual:user[@"profileImage"]]) {
        user[@"profileImage"] = self.profileImageView.file;
    }
    NSString *hexString = [self.colorHelper hexStringForColor:self.color];
    if (![hexString isEqualToString:user[@"colorHexString"]]) {
        user[@"colorHexString"] = [self.colorHelper hexStringForColor:self.color];
    }
    // Update user properties when necessary
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *_Nullable error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSLog(@"User updated successfully");
        }
    }];
} /* updateButton */

- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)logoutButton:(id)sender {
    SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    myDelegate.window.rootViewController = loginViewController;
    // Do not send nil for block
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
    }];
}
- (void)colorPickerViewController:(FCColorPickerViewController *)colorPicker didSelectColor:(UIColor *)color {
    self.color = color;
    [self.colorView setImage:[self.colorHelper createImageWithColor:color]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)colorPickerViewControllerDidCancel:(FCColorPickerViewController *)colorPicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)colorPickButton:(id)sender {
    // Show color picker
    FCColorPickerViewController *colorPicker = [FCColorPickerViewController colorPicker];
    colorPicker.color = self.color;
    colorPicker.delegate = self;
    
    [colorPicker setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentViewController:colorPicker animated:YES completion:nil];
}
- (IBAction)tap:(id)sender {
    [self.view endEditing:YES];
}

@end
