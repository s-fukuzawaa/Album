//
//  DetailsViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/7/22.
//

#import "DetailsViewController.h"
#import <Parse/PFImageView.h>
#import "PhotoCollectionCell.h"
@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *placeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITextView *captionTextView;
@property (nonatomic) int currentIndex;
@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Set location
    self.placeNameLabel.text = self.placeName;
    // Set date
    self.dateLabel.text = self.date;
    // Set caption
    self.captionTextView.text = self.caption;
    // Photo carousel
    self.imageCarouselView.delegate = self;
    self.imageCarouselView.dataSource = self;
    // Set up photos array
    self.currentIndex = 0;
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
