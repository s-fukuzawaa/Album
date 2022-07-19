//
//  DetailsViewController.h
//  Album
//
//  Created by Airei Fukuzawa on 7/7/22.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface DetailsViewController : UIViewController
@property (strong, nonatomic) NSString *placeName;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) PFFileObject *pinImage;
@property (strong, nonatomic) NSString *caption;

@end

NS_ASSUME_NONNULL_END
