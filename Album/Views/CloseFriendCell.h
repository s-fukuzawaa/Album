//
//  CloseFriendCell.h
//  Album
//
//  Created by Airei Fukuzawa on 7/28/22.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Friendship.h"

NS_ASSUME_NONNULL_BEGIN
@protocol CloseFriendCellDelegate;

@interface CloseFriendCell : UITableViewCell
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) Friendship *friendship;
@property (nonatomic, strong) Friendship *otherFriendship;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *closeFriendButton;
@property (nonatomic, weak) id<CloseFriendCellDelegate> delegate;
@end

@protocol CloseFriendCellDelegate
// TODO: Add required methods the delegate needs to implement
- (void)closeFriendCell:(CloseFriendCell *) closeFriendCell didTap: (PFUser *)user;
@end
NS_ASSUME_NONNULL_END
