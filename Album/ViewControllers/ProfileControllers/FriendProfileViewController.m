//
//  FriendProfileViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/7/22.
//

#import "FriendProfileViewController.h"
#import <PFImageView.h>

@interface FriendProfileViewController ()
@property (weak, nonatomic) IBOutlet PFImageView *userImageView;

@end

@implementation FriendProfileViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.friendMapContainer.alpha = 0.0;
	self.friendsGridContainer.alpha = 1.0;
	// Set user profile image view
	[self fetchProfile];

}
- (IBAction)viewSwitchControl:(UISegmentedControl*)sender {
	if(sender.selectedSegmentIndex == 0) {
		[UIView animateWithDuration:0.5 animations:^{
		         self.friendMapContainer.alpha = 0.0;
		         self.friendsGridContainer.alpha = 1.0;
		 }];
	} else { // Album View case
		[UIView animateWithDuration:0.5 animations:^{
		         self.friendMapContainer.alpha = 1.0;
		         self.friendsGridContainer.alpha = 0.0;
		 }];
	}
}

- (void) fetchProfile {
	PFUser *user = self.user;
	if(user[@"profileImage"]) {
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


- (IBAction)friendButton:(id)sender {

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return NULL;
}
@end
