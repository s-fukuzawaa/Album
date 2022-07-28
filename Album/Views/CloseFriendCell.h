//
//  CloseFriendCell.h
//  Album
//
//  Created by Airei Fukuzawa on 7/28/22.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
NS_ASSUME_NONNULL_BEGIN

@interface CloseFriendCell : UITableViewCell
@property (nonatomic, strong) PFUser *user;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *closeFriendButton;

@end

NS_ASSUME_NONNULL_END
