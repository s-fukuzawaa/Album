//
//  FriendCell.h
//  Album
//
//  Created by Airei Fukuzawa on 7/8/22.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <PFImageView.h>

NS_ASSUME_NONNULL_BEGIN
@protocol FriendCellDelegate;
@interface FriendCell : UITableViewCell
@property (nonatomic, strong) PFUser *user;
@property (weak, nonatomic) IBOutlet PFImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) id<FriendCellDelegate> delegate;
@end
@protocol FriendCellDelegate
// TODO: Add required methods the delegate needs to implement
- (void)friendCell:(FriendCell *) friendCell didTap: (PFUser*)user;

@end
NS_ASSUME_NONNULL_END
