//
//  ActivityCell.h
//  Album
//
//  Created by Airei Fukuzawa on 7/8/22.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Parse/PFImageView.h"

NS_ASSUME_NONNULL_BEGIN
@protocol ActivityCellDelegate;
@interface ActivityCell : UITableViewCell
@property (nonatomic, strong) PFUser *user;
@property (weak, nonatomic) IBOutlet PFImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@end
@protocol ActivityCellDelegate
// TODO: Add required methods the delegate needs to implement
- (void)activityCell:(ActivityCell *) activityCell didTap: (PFUser*)user;

@end
NS_ASSUME_NONNULL_END
