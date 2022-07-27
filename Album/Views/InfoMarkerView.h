//
//  InfoMarkerView.h
//  Album
//
//  Created by Airei Fukuzawa on 7/13/22.
//

#import <UIKit/UIKit.h>
#import <Parse/PFImageView.h>

NS_ASSUME_NONNULL_BEGIN

@interface InfoMarkerView : UIView
@property (weak, nonatomic) IBOutlet PFImageView *pinImageView;
@property (weak, nonatomic) IBOutlet UILabel *placeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

NS_ASSUME_NONNULL_END
