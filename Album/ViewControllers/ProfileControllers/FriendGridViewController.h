//
//  FriendGridViewController.h
//  Album
//
//  Created by Airei Fukuzawa on 7/21/22.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface FriendGridViewController : UIViewController
@property (nonatomic, strong) PFUser *user;
@end

NS_ASSUME_NONNULL_END
