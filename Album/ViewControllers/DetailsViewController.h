//
//  DetailsViewController.h
//  Album
//
//  Created by Airei Fukuzawa on 7/7/22.
//

#import <UIKit/UIKit.h>
#import "Pin.h"
#import <Parse/Parse.h>
NS_ASSUME_NONNULL_BEGIN

@interface DetailsViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) Pin *pin;
@property (strong, nonatomic) NSMutableArray *imagesFromPin;
@property (weak, nonatomic) IBOutlet UICollectionView *imageCarouselView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageIndicator;

@end

NS_ASSUME_NONNULL_END
