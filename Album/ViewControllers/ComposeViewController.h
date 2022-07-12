//
//  ComposeViewController.h
//  Album
//
//  Created by Airei Fukuzawa on 7/7/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol ComposeViewControllerDelegate

- (void)didPost;

@end

@interface ComposeViewController : UIViewController <UIImagePickerControllerDelegate>
@property (nonatomic, weak) id<ComposeViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *placeName;
@end

NS_ASSUME_NONNULL_END
