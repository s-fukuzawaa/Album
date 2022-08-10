//
//  ComposeViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/7/22.
//

#import "ComposeViewController.h"
#import "PhotoCollectionCell.h"
#import <UITextView+Placeholder.h>
#import <PhotosUI/PHPicker.h>
#import <Photos/PHAsset.h>
#import "Parse/Parse.h"
#import "Image.h"
#import "Pin.h"

@interface ComposeViewController () <UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate,
PHPickerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *pinImageView;
@property (weak, nonatomic) IBOutlet UITextView *captionTextView;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *traveledDate;
@property (weak, nonatomic) IBOutlet UIButton *closeFriendPinButton;
@property (strong, nonatomic) PHPickerConfiguration *config;
@property (strong, nonatomic) NSMutableArray *photos;
@property (nonatomic) int currentIndex;
@property (nonatomic) BOOL isClosePost;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation ComposeViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Set caption view properties
    [self setCaptionTextView];
    // Set image carousel
    [self setImageCarouselView];
    // Set location label
    self.locationLabel.text = [self.locationLabel.text stringByAppendingString:self.placeName];
    // Config PHPicker
    self.config = [[PHPickerConfiguration alloc] init];
    self.config.selectionLimit = 10;
    self.config.filter = [PHPickerFilter imagesFilter];
    
    // Set up photos array
    self.photos = [[NSMutableArray alloc] init];
    self.currentIndex = 0;
    // Set up page control
    self.pageControl.numberOfPages = self.photos.count;
    // Set up close friend post button
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.closeFriendPinButton setImage:[UIImage systemImageNamed:@"star"] forState:UIControlStateNormal];
    });
    self.isClosePost = NO;
} /* viewDidLoad */

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.imageCarouselView reloadData];
}

#pragma mark - UIView

- (void)setCaptionTextView {
    self.captionTextView.delegate = self;
    self.captionTextView.layer.cornerRadius = 8;
    self.captionTextView.layer.borderWidth = 1.0f;
    self.captionTextView.placeholder = @"Add a caption...";
    self.captionTextView.placeholderColor = [UIColor lightGrayColor];
    self.captionTextView.layer.borderColor = [[UIColor systemBlueColor] CGColor];
}

- (void)setImageCarouselView {
    // Tap placeholder image to upload image
    UITapGestureRecognizer *imageTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapImage:)];
    [self.imageCarouselView addGestureRecognizer:imageTapGestureRecognizer];
    [self.imageCarouselView setUserInteractionEnabled:YES];
    // Photo carousel
    self.imageCarouselView.delegate = self;
    self.imageCarouselView.dataSource = self;
    self.imageCarouselView.layer.borderWidth = 1.0f;
    self.imageCarouselView.layer.borderColor = [[UIColor blackColor] CGColor];
}
- (void)didTapImage:(UITapGestureRecognizer *)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Media" message:@"Choose"
                                                                preferredStyle:(UIAlertControllerStyleAlert)];
        // Create a take photo action
        UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"Take Photo"
                                                              style:UIAlertActionStyleCancel
                                                            handler:^(UIAlertAction *_Nonnull action) {
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
                                                             handler:^(UIAlertAction *_Nonnull action) {
            PHPickerViewController *pickerViewController =
            [[PHPickerViewController alloc] initWithConfiguration:self.config];
            pickerViewController.delegate = self;
            [self presentViewController:pickerViewController animated:YES completion:nil];
        }];
        // Add the OK action to the alert controller
        [alert addAction:uploadAction];
        //Cancel
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                         style:UIAlertActionStyleDefault
                                                       handler:nil];
        // Add the OK action to the alert controller
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        NSLog(@"Camera 🚫 available so we will use photo library instead");
        PHPickerViewController *pickerViewController = [[PHPickerViewController alloc] initWithConfiguration:self.config];
        pickerViewController.delegate = self;
        [self presentViewController:pickerViewController animated:YES completion:nil];
    }
} /* didTapImage */

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.currentIndex = scrollView.contentOffset.x / self.imageCarouselView.frame.size.width;
    self.pageIndicator.currentPage = self.currentIndex;
}

#pragma mark - PHPickerViewControllerDelegate

- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results {
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self.photos removeAllObjects];
    self.pageControl.numberOfPages = 0;
    for (PHPickerResult *result in results) {
        // Get UIImage
        if ([result.itemProvider canLoadObjectOfClass:[UIImage class]]) {
            [result.itemProvider loadObjectOfClass:[UIImage class] completionHandler:^(__kindof id<NSItemProviderReading>  _Nullable object,
                                                                                       NSError *_Nullable error)
             {
                if ([object isKindOfClass:[UIImage class]]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.pageControl.numberOfPages =
                        self.pageControl.numberOfPages + 1;
                        [self.photos addObject:[self resizeImage:object withSize:((UIImage*)object).size]];
                        [self.imageCarouselView reloadData];
                    });
                }
            }];
        }
    }
} /* picker */

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info {
    // Get the image captured by the UIImagePickerController
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    CGSize size = CGSizeMake(300, 300);
    originalImage = [self resizeImage:originalImage withSize:size];
    [self.photos addObject:originalImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    resizeImageView.contentMode = UIViewContentModeScaleAspectFit;
    resizeImageView.image = image;
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


#pragma mark - IBAction

- (IBAction)crossButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)makeCloseFriendPin:(id)sender {
    self.isClosePost = !self.isClosePost;
    if (self.isClosePost) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.closeFriendPinButton setImage:[UIImage systemImageNamed:@"star.fill"] forState:UIControlStateNormal];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.closeFriendPinButton setImage:[UIImage systemImageNamed:@"star"] forState:UIControlStateNormal];
        });
    }
}

- (IBAction)postButton:(id)sender {
    // Post new Pin
    Pin *newPin = [Pin new];
    newPin.author = [PFUser currentUser];
    newPin.captionText = self.captionTextView.text;
    newPin.likeCount = @(0);
    newPin[@"placeName"] = self.placeName;
    newPin[@"placeID"] = self.placeID;
    newPin[@"latitude"] = @(self.coordinate.latitude);
    newPin[@"longitude"] = @(self.coordinate.longitude);
    newPin[@"traveledOn"] = self.traveledDate.date;
    newPin[@"isCloseFriendPin"] = @(self.isClosePost);
    [newPin saveInBackgroundWithBlock:^(BOOL succeeded, NSError *_Nullable error) {
        if (error) {
            NSLog(@"Error posting: %@", error.localizedDescription);
        } else {
            NSLog(@"Pin saved successfully! Object Id:%@", newPin.objectId);
            for (UIImage *image in self.photos) {
                [Image postImage:[self resizeImage:image withSize:CGSizeMake(416,432)] withPin:newPin.objectId withCompletion:^(BOOL succeeded, NSError *_Nullable error) {
                    if (error) {
                        NSLog(@"Error saving image: %@", error.localizedDescription);
                        [self imageAlert:NO];
                    } else {
                        NSLog(@"Successfully saved image");
                        [self imageAlert:YES];
                    }
                } ];
            }
            [self.delegate didPost:newPin imageArr:self.photos];
        }
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
} /* postButton */

- (IBAction)tapped:(id)sender {
    [self.view endEditing:YES];
}

#pragma mark - UICollectionViewDataSource

- (void)imageAlert:(BOOL)saved {
    UIAlertController *alert;
    if (!saved) {
        alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Couldn't save image"
                                             preferredStyle:(UIAlertControllerStyleAlert)];
    } else {
        alert = [UIAlertController alertControllerWithTitle:@"Success!" message:@"Image was saved"
                                             preferredStyle:(UIAlertControllerStyleAlert)];
    }
    //OK
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                 style:UIAlertActionStyleDefault
                                               handler:nil];
    // Add the OK action to the alert controller
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photos.count == 0 ? 1 : self.photos.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCollectionCell *photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoCell" forIndexPath:indexPath];
    // Add placeholder image cell when there are no images
    photoCell.photoImageView.contentMode = UIViewContentModeScaleAspectFit;
    photoCell.photoImageView.image = self.photos.count == 0 ? [UIImage imageNamed:@"image_placeholder"] : self.photos[indexPath.row];
    return photoCell;
}

@end
