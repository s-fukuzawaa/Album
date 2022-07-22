//
//  DetailsViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/7/22.
//

#import "DetailsViewController.h"
#import "AlbumConstants.h"
#import <Parse/PFImageView.h>
#import "PhotoCollectionCell.h"
@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *placeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITextView *captionTextView;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (nonatomic) int currentIndex;
@property (strong, nonatomic) PFUser* currentUser;
@property (strong, nonatomic) PFObject* likeStatus;
@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Set current user
    self.currentUser = [PFUser currentUser];
    // Set location
    self.placeNameLabel.text = self.pin.placeName;
    // Set date
    // Set the date formatter
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd, YYYY"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *date = [formatter stringFromDate:self.pin.traveledOn];
    self.dateLabel.text = date;
    // Set caption
    self.captionTextView.text = self.pin.captionText;
    // Photo carousel
    self.imageCarouselView.delegate = self;
    self.imageCarouselView.dataSource = self;
    // Set up photos array
    self.currentIndex = 0;
    // Set up like status
    [self setLikeStatus];
}

- (void) setLikeStatus {
    PFQuery *likeQuery = [PFQuery queryWithClassName:classNameUserPin];
    [likeQuery whereKey:@"userId" equalTo:self.currentUser.objectId];
    [likeQuery whereKey:@"pinId" equalTo:self.pin.objectId];
    [likeQuery findObjectsInBackgroundWithBlock:^(NSArray *statuses, NSError *error) {
        if (statuses != nil) {
            NSLog(@"Successfully fetched like statuses!");
            // For each friend, find their pins
            self.likeStatus = statuses[0];
            if((BOOL)self.likeStatus[@"hasLiked"] == YES) {
                [self.likeButton setImage:[UIImage systemImageNamed:@"heart.fill"] forState:UIControlStateNormal];
            }else {
                [self.likeButton setImage:[UIImage systemImageNamed:@"heart"] forState:UIControlStateNormal];
            }
            NSString *formattedString = [NSString stringWithFormat:@"%@ likes",self.pin.likeCount];
            [self.likeButton setTitle:formattedString forState:UIControlStateNormal];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}
- (IBAction)tapLiked:(id)sender {
    // Update count of pin
    if ((BOOL)self.likeStatus[@"hasLiked"] == YES) {
        [self.likeButton setImage:[UIImage systemImageNamed:@"heart"] forState:UIControlStateNormal];
        self.pin.likeCount = @([self.pin.likeCount intValue]-1);
        if([self.pin.likeCount intValue] < 0) {
            self.pin.likeCount = @(0);
        }
        self.currentUser[@"hasLiked"] = @(NO);
    } else {
        [self.likeButton setImage:[UIImage systemImageNamed:@"heart.fill"] forState:UIControlStateNormal];
        self.pin.likeCount = @([self.pin.likeCount intValue]+1);
        self.currentUser[@"hasLiked"] = @(YES);
    }
    [self.pin saveInBackground];
    [self.currentUser saveInBackground];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.imagesFromPin.count == 0) {
        return 1;
    }
    return self.imagesFromPin.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCollectionCell *photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"detailCell" forIndexPath:indexPath];
    // Add placeholder cell when no images are found
    if (self.imagesFromPin.count == 0) {
        photoCell.photoImageView.contentMode = UIViewContentModeScaleAspectFit;
        photoCell.photoImageView.image = [UIImage imageNamed:@"image_placeholder"];
    } else {
        photoCell.photoImageView.contentMode = UIViewContentModeScaleAspectFit;
        photoCell.photoImageView.image = self.imagesFromPin[indexPath.row];
    }
    return photoCell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.currentIndex = scrollView.contentOffset.x / self.imageCarouselView.frame.size.width;
    self.pageIndicator.currentPage = self.currentIndex;
}
@end
