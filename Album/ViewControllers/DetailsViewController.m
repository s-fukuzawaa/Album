//
//  DetailsViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/7/22.
//

#import "DetailsViewController.h"
#import <Parse/PFImageView.h>

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *placeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet PFImageView *pinImageView;
@property (weak, nonatomic) IBOutlet UITextView *captionTextView;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	// Set location
	self.placeNameLabel.text = self.placeName;
	// Set date
	self.dateLabel.text = self.date;
	// Set caption
	self.captionTextView.text = self.caption;
	// Set image
	[self.pinImageView setFile:self.pinImage];
	[self.pinImage getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
	         if (!error) {
			 UIImage *image = [UIImage imageWithData:imageData];
			 [self.pinImageView setImage:image];
		 }
	 }];
}
@end
