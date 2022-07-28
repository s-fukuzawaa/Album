//
//  DetailsViewController.h
//  Album
//
//  Created by Airei Fukuzawa on 7/7/22.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface DetailsViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) NSString *placeName;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSMutableArray *imagesFromPin;
@property (strong, nonatomic) NSString *caption;
@property (weak, nonatomic) IBOutlet UICollectionView *imageCarouselView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageIndicator;

@end

NS_ASSUME_NONNULL_END
