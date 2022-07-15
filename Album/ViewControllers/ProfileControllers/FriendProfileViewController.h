//
//  FriendProfileViewController.h
//  Album
//
//  Created by Airei Fukuzawa on 7/7/22.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
NS_ASSUME_NONNULL_BEGIN
@protocol FriendProfileViewControllerDelegate

- (void)didPost;

@end
@interface FriendProfileViewController : UIViewController
@property (nonatomic, strong) PFUser *user;
@property (weak, nonatomic) IBOutlet UIView *friendMapContainer;
@property (weak, nonatomic) IBOutlet UIView *friendsGridContainer;
@property (nonatomic, weak) id<FriendProfileViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
