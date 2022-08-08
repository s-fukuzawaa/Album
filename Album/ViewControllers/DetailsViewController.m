//
//  DetailsViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/7/22.
//

#import "DetailsViewController.h"
#import "AlbumConstants.h"
#import "ParseAPIHelper.h"
#import "UserPin.h"
#import <Parse/PFImageView.h>
#import "PhotoCollectionCell.h"
#import <UPCarouselFlowLayout/UPCarouselFlowLayout-Swift.h>

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *placeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITextView *captionTextView;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIImageView *closeFriendPost;
@property (nonatomic) int currentIndex;
@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) UserPin *likeStatus;
@property (nonatomic) CGSize pageSize;
@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Set current user
    self.currentUser = [PFUser currentUser];
    // Set view outlets
    [self setView];
    // Photo carousel
    self.imageCarouselView.delegate = self;
    self.imageCarouselView.dataSource = self;
    // Set up like status
    [self setLikeStatus];
} /* viewDidLoad */

#pragma mark - UIView
- (void)setView {
    // Set location
    self.placeNameLabel.text = self.pin.placeName;
    // Set date
    NSString *date = [[ParseAPIHelper dateFormatter] stringFromDate:self.pin.traveledOn];
    self.dateLabel.text = date;
    // Set caption
    NSString *captionBegin = [@"@" stringByAppendingString:self.username];
    captionBegin = [captionBegin stringByAppendingString:@": "];
    self.captionTextView.text = [captionBegin stringByAppendingString:self.pin.captionText];
    // Set up page control
    self.currentIndex = 0;
    self.pageControl.numberOfPages = 0;
    // Set button
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLiked:)];
    tapGesture.numberOfTapsRequired = 2;
    [self.likeButton addGestureRecognizer:tapGesture];
    // Set close friend status
    if (self.pin.isCloseFriendPin) {
        [self.closeFriendPost setImage:[UIImage systemImageNamed:@"star.fill"]];
    } else {
        [self.closeFriendPost setHidden:YES];
    }
    UPCarouselFlowLayout *layout = [[UPCarouselFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(416, 432);
    self.pageSize = layout.itemSize;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.imageCarouselView.collectionViewLayout = layout;
} /* viewDidLoad */

- (void)setLikeStatus {
    PFQuery *likeQuery = [PFQuery queryWithClassName:classNameUserPin];
    [likeQuery whereKey:@"userId" equalTo:self.currentUser.objectId];
    [likeQuery whereKey:@"pinId" equalTo:self.pin.objectId];
    [likeQuery findObjectsInBackgroundWithBlock:^(NSArray *statuses, NSError *error) {
        if (statuses != nil) {
            NSLog(@"Successfully fetched like statuses!");
            // If no like status, create one
            if (statuses.count == 0) {
                self.likeStatus = [[UserPin alloc] init];
                self.likeStatus.userId = self.currentUser.objectId;
                self.likeStatus.pinId = self.pin.objectId;
                self.likeStatus.hasLiked = NO;
                [self.likeStatus saveInBackground];
                [self.likeButton setImage:[UIImage systemImageNamed:@"heart"] forState:UIControlStateNormal];
            } else {
                // Set like button corresponding to the hasLiked field
                self.likeStatus = statuses[0];
                if (self.likeStatus.hasLiked == YES) {
                    [self.likeButton setImage:[UIImage systemImageNamed:@"heart.fill"] forState:UIControlStateNormal];
                } else {
                    [self.likeButton setImage:[UIImage systemImageNamed:@"heart"] forState:UIControlStateNormal];
                }
            }
            NSString *formattedString = [NSString stringWithFormat:@"%@ likes", self.pin.likeCount];
            [self.likeButton setTitle:formattedString forState:UIControlStateNormal];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
} /* setLikeStatus */

- (void)tapLiked:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        // Update like status of pin
        self.likeStatus.hasLiked = !self.likeStatus.hasLiked;
        // Update count and button view accordingly
        if (self.likeStatus.hasLiked == YES) {
            self.pin.likeCount = @([self.pin.likeCount intValue] + 1);
            if ([self.pin.likeCount intValue] < 0) {
                self.pin.likeCount = @(0);
            }
            [self.likeButton setImage:[UIImage systemImageNamed:@"heart.fill"] forState:UIControlStateNormal];
        } else {
            self.pin.likeCount = @([self.pin.likeCount intValue] - 1);
            if ([self.pin.likeCount intValue] < 0) {
                self.pin.likeCount = @(0);
            }
            [self.likeButton setImage:[UIImage systemImageNamed:@"heart"] forState:UIControlStateNormal];
        }
        NSString *formattedString = [NSString stringWithFormat:@"%@ likes", self.pin.likeCount];
        [self.likeButton setTitle:formattedString forState:UIControlStateNormal];
        [self.pin saveInBackground];
        // Save the status object in background
        [self.likeStatus saveInBackground];
    }
} /* tapLiked */

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int pageSide = self.pageSize.width;
    self.currentIndex = scrollView.contentOffset.x / self.imageCarouselView.frame.size.width;
    self.pageIndicator.currentPage = (int)(floorf((scrollView.contentOffset.x - pageSide / 2) / pageSide) + 1);
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.imagesFromPin.count == 0) {
        return 1;
    }
    return self.imagesFromPin.count;
}

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
    self.pageControl.numberOfPages = self.imagesFromPin.count;
    return photoCell;
}
@end
