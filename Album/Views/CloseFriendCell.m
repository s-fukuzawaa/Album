//
//  CloseFriendCell.m
//  Album
//
//  Created by Airei Fukuzawa on 7/28/22.
//

#import "CloseFriendCell.h"
#import "AlbumConstants.h"

@implementation CloseFriendCell

- (void)awakeFromNib {
    [super awakeFromNib];
    UITapGestureRecognizer *profileTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapUserProfile:)];
    [self.profileImageView addGestureRecognizer:profileTapGestureRecognizer];
    [self.profileImageView setUserInteractionEnabled:YES];
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
- (IBAction)closeFriendButton:(id)sender {
    UIColor *closeFriendButtonBackgroundColor;
    NSString *closeFriendButtonText;
    UIColor *closeFriendButtonTitleColor;
    self.friendship.isClose = !self.friendship.isClose;
    self.otherFriendship.isClose = !self.otherFriendship.isClose;
    if(self.friendship.isClose) {
        closeFriendButtonBackgroundColor = [UIColor systemIndigoColor];
        closeFriendButtonText = @"Close Friended";
        closeFriendButtonTitleColor = [UIColor whiteColor];
    }else {
        closeFriendButtonBackgroundColor = [UIColor whiteColor];
        closeFriendButtonText = @"Add to Close Friends?";
        closeFriendButtonTitleColor = [UIColor systemIndigoColor];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.closeFriendButton setTitleColor:closeFriendButtonBackgroundColor forState:UIControlStateNormal];
        [self.closeFriendButton setTitle:closeFriendButtonText forState:UIControlStateNormal];
        [self.closeFriendButton setBackgroundColor:closeFriendButtonTitleColor];
    });
    // Update friendship
    [self.friendship saveInBackgroundWithBlock:^(BOOL succeeded, NSError *_Nullable error) {
        if (error) {
            NSLog(@"Error posting: %@", error.localizedDescription);
        } else {
            NSLog(@"Successfully saved friendship!");
        }
    }];
    // Also save from other end of friendship
    [self.otherFriendship saveInBackgroundWithBlock:^(BOOL succeeded, NSError *_Nullable error) {
        if (error) {
            NSLog(@"Error posting: %@", error.localizedDescription);
        } else {
            NSLog(@"Successfully saved friendship from other side!");
        }
    }];
}

- (void) didTapUserProfile:(UITapGestureRecognizer *)sender{
    //TODO: Call method delegate
    [self.delegate closeFriendCell:self didTap:self.user];
}
@end
