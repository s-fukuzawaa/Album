//
//  InfoPOIView.h
//  Album
//
//  Created by Airei Fukuzawa on 7/11/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol InfoPOIViewDelegate

- (void)didPost;

@end
@interface InfoPOIView : UIView
@property (weak, nonatomic) IBOutlet UILabel *placeName;
@property (nonatomic, weak) id<InfoPOIViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
