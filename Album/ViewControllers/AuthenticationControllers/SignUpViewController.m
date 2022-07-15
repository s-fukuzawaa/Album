//
//  SignUpViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/6/22.
//

#import "SignUpViewController.h"
#import "Parse/Parse.h"
#import "PFImageView.h"

@interface SignUpViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet PFImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *pwField;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	// Tap profile to change configuration
	UITapGestureRecognizer *profileTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapUserProfile:)];
	[self.profileImageView addGestureRecognizer:profileTapGestureRecognizer];
	[self.profileImageView setUserInteractionEnabled:YES];
}

- (IBAction)signUpButton:(id)sender {
	[self registerUser];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTap:(id)sender {
	[self.view endEditing:YES];
}
- (void)registerUser {
	// Initialize a user object
	PFUser *newUser = [PFUser user];
	// Set user properties
	newUser.username = self.usernameField.text;
	newUser.email = self.emailField.text;
	newUser.password = self.pwField.text;
	newUser[@"profileImage"] = self.profileImageView.file;
	// Call sign up function on the object
	[newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
	         if (error != nil) {
			 NSLog(@"Error: %@", error.localizedDescription);
			 UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Error signing up! Please try again."
			                             preferredStyle:(UIAlertControllerStyleAlert)];
			 // create an OK action
			 UIAlertAction *uploadAction = [UIAlertAction actionWithTitle:@"OK"
			                                style:UIAlertActionStyleDefault
			                                handler:nil];
			 // add the OK action to the alert controller
			 [alert addAction:uploadAction];
			 [self presentViewController:alert animated:YES completion:nil];
		 } else {
			 NSLog(@"User registered successfully");

			 // manually segue to logged in view
		 }
	 }];
}

- (void) didTapUserProfile:(UITapGestureRecognizer *)sender {
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Media" message:@"Choose"
		                            preferredStyle:(UIAlertControllerStyleAlert)];
		// Create a cancel action
		UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"Take Photo"
		                              style:UIAlertActionStyleCancel
		                              handler:^(UIAlertAction * _Nonnull action) {
		                                      UIImagePickerController *imagePickerVC = [UIImagePickerController new];
		                                      imagePickerVC.delegate = self;
		                                      imagePickerVC.allowsEditing = YES;
		                                      imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
		                                      [self presentViewController:imagePickerVC animated:YES completion:nil];
					      }];
		// Add the cancel action to the alertController
		[alert addAction:photoAction];
		// Create an OK action
		UIAlertAction *uploadAction = [UIAlertAction actionWithTitle:@"Upload from Library"
		                               style:UIAlertActionStyleDefault
		                               handler:^(UIAlertAction * _Nonnull action) {
		                                       UIImagePickerController *imagePickerVC = [UIImagePickerController new];
		                                       imagePickerVC.delegate = self;
		                                       imagePickerVC.allowsEditing = YES;
		                                       imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		                                       [self presentViewController:imagePickerVC animated:YES completion:nil];
					       }];
		// Add the OK action to the alert controller
		[alert addAction:uploadAction];
		//Cancel
		UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
		                         style:UIAlertActionStyleDefault
		                         handler: nil];
		// Add the OK action to the alert controller
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
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
	// Get the image captured by the UIImagePickerController
	UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
	originalImage = [self resizeImage:originalImage withSize:self.profileImageView.image.size];
	[self.profileImageView setImage:originalImage];
	PFFileObject *file = [self getPFFileFromImage:originalImage];
	[self.profileImageView setFile:file];
	// Dismiss UIImagePickerController to go back to your original view controller
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
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

@end
