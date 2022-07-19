//
//  ComposeViewController.h
//  Album
//
//  Created by Airei Fukuzawa on 7/7/22.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
NS_ASSUME_NONNULL_BEGIN
@protocol ComposeViewControllerDelegate

- (void)didPost;

@end

@interface ComposeViewController : UIViewController <UIImagePickerControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, weak) id<ComposeViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *placeName;
@property (nonatomic, strong) NSString *placeID;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (weak, nonatomic) IBOutlet UICollectionView *imageCarouselView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageIndicator;
@end

NS_ASSUME_NONNULL_END
