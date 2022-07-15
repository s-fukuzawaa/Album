//
//  FriendProfileViewController.h
//  Album
//
//  Created by Airei Fukuzawa on 7/7/22.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
NS_ASSUME_NONNULL_BEGIN
@interface FriendProfileViewController : UIViewController
@property (nonatomic, strong) PFUser *user;
@property (weak, nonatomic) IBOutlet UIView *friendMapContainer;
@property (weak, nonatomic) IBOutlet UIView *friendsGridContainer;
@end

NS_ASSUME_NONNULL_END
