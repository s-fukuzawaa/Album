//
//  ComposeViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/7/22.
//

#import "ComposeViewController.h"
#import <UITextView+Placeholder.h>
#import <Photos/PHasset.h>
#import "Parse/Parse.h"
#import "Image.h"
#import "Pin.h"
@interface ComposeViewController () <UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *pinImageView;
@property (weak, nonatomic) IBOutlet UITextView *captionTextView;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *traveledDate;

@end

@implementation ComposeViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Set caption view properties
	self.captionTextView.delegate = self;
	self.captionTextView.layer.cornerRadius = 8;
	self.captionTextView.layer.borderWidth = 1.0f;
	self.captionTextView.placeholder = @"Add a caption...";
	self.captionTextView.placeholderColor = [UIColor lightGrayColor];
	self.captionTextView.layer.borderColor = [[UIColor systemBlueColor] CGColor];

	// Tap placeholder image to upload image
	UITapGestureRecognizer *imageTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapImage:)];
	[self.pinImageView addGestureRecognizer:imageTapGestureRecognizer];
	[self.pinImageView setUserInteractionEnabled:YES];

	// Set location label
	self.locationLabel.text = [self.locationLabel.text stringByAppendingString:self.placeName];
}

- (void) didTapImage:(UITapGestureRecognizer *)sender {
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
	}
	else {
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
	originalImage = [self resizeImage:originalImage withSize:self.pinImageView.image.size];
	[self.pinImageView setImage:originalImage];
	// TODO: Get date and set it to date picker default
	NSURL *mediaUrl = info[UIImagePickerControllerMediaURL];
	// Dismiss UIImagePickerController to go back to your original view controller
	[self dismissViewControllerAnimated:YES completion:nil];
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

- (void) returnMap {
	[self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)crossButton:(id)sender {
	[self returnMap];
}

- (IBAction)postButton:(id)sender {
	Pin *newPin = [Pin new];
	newPin.author = [PFUser currentUser];
	newPin.captionText = self.captionTextView.text;
	newPin.likeCount = @(0);
	newPin[@"placeName"] = self.placeName;
	newPin[@"placeID"] = self.placeID;
	newPin[@"latitude"] = @(self.coordinate.latitude);
	newPin[@"longitude"] = @(self.coordinate.longitude);
	newPin[@"traveledOn"] = self.traveledDate.date;
	[newPin saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
	         if (error) {
			 NSLog(@"Error posting: %@", error.localizedDescription);
		 } else {
			 NSLog(@"Pin saved successfully! Object Id:%@", newPin.objectId);
			 [Image postImage:self.pinImageView.image withPin:newPin.objectId withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
			          if(error) {
					  NSLog(@"Error saving image: %@", error.localizedDescription);
				  }
			          else{
					  NSLog(@"Successfully saved image");
					  [self.delegate didPost];
				  }
			  } ];
		 }
	 }];

	[self returnMap];
}
- (IBAction) tapped:(id) sender {
	[self.view endEditing:YES];
}
@end
