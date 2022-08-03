//
//  ActivityCell.m
//  Album
//
//  Created by Airei Fukuzawa on 7/8/22.
//

#import "ActivityCell.h"

@implementation ActivityCell

- (void)setUser:(PFUser *)user {
// Since we're replacing the default setter, we have to set the underlying private storage _movie ourselves.
// _movie was an automatically declared variable with the @propery declaration.
// You need to do this any time you create a custom setter.

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
        [self.userImageView setFile:file];
        [file getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:imageData];
                [self.userImageView setImage:image];
                self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height/2;
                self.userImageView.layer.masksToBounds = YES;
            }
        }];
    }
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
