//
//  SettingsViewController.h
//  Album
//
//  Created by Airei Fukuzawa on 7/7/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SettingsViewControllerDelegate

- (void)didUpdate;

@end
@interface SettingsViewController : UIViewController
@property (nonatomic, weak) id<SettingsViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
