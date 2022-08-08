//
//  FriendCell.m
//  Album
//
//  Created by Airei Fukuzawa on 7/8/22.
//

#import "FriendCell.h"
#import "ParseAPIHelper.h"

@implementation FriendCell

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
        [self.userImageView setImage:[ParseAPIHelper fetchProfile:user]];
        self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height/2;
        self.userImageView.layer.masksToBounds = YES;
    }
}
@end
