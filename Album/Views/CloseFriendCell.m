//
//  CloseFriendCell.m
//  Album
//
//  Created by Airei Fukuzawa on 7/28/22.
//

#import "CloseFriendCell.h"

@implementation CloseFriendCell

- (void)awakeFromNib {
    [super awakeFromNib];
}
- (void)setUser:(PFUser *)user {
    _user = user;
    // username
    self.usernameLabel.text = [@"@" stringByAppendingString:self.user.username];
    //set profile picture
    [self fetchProfile];
    
}

- (void) fetchProfile {
    PFUser *user = self.user;
    if(user[@"profileImage"]){
        PFFileObject *file = user[@"profileImage"];
        [file getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:imageData];
                [self.profileImageView setImage:image];
                self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height/2;
                self.profileImageView.layer.masksToBounds = YES;
            }
        }];
    }
}
@end
