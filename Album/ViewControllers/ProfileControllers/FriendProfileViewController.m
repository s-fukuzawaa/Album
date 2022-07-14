//
//  FriendProfileViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/7/22.
//

#import "FriendProfileViewController.h"
#import "Friendship.h"
#import <PFImageView.h>
#import <Parse/Parse.h>
static int const PENDING = 1;
static int const FRIENDED = 2;
static int const NOT_FRIEND = 0;

@interface FriendProfileViewController ()
@property (weak, nonatomic) IBOutlet PFImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIButton *friendButton;
@property (nonatomic) int friendStatus;
@property (weak, nonatomic) Friendship *friendship;
@end

@implementation FriendProfileViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.friendMapContainer.alpha = 0.0;
	self.friendsGridContainer.alpha = 1.0;
	// Set user profile image view
	[self fetchProfile];
	self.friendStatus = [self fetchFriendStatus];
	[self updateButton];

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

- (void) updateButton {
	if(self.friendStatus == FRIENDED) {
		[self.friendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[self.friendButton setTitle:@"Friended" forState:UIControlStateNormal];
        [self.friendButton setTintColor:[UIColor colorWithRed: 0.39 green: 0.28 blue: 0.22 alpha: 1.00]];
	}else if(self.friendStatus == PENDING) {
        [self.friendButton setTintColor:[UIColor whiteColor]];
		[self.friendButton setTitle:@"Pending" forState:UIControlStateNormal];
		[self.friendButton setTitleColor:[UIColor colorWithRed: 0.39 green: 0.28 blue: 0.22 alpha: 1.00] forState:UIControlStateNormal];
	}else{
		[self.friendButton setTintColor:[UIColor whiteColor]];
		[self.friendButton setTitle:@"Request Friend?" forState:UIControlStateNormal];
        [self.friendButton setTitleColor: [UIColor colorWithRed: 0.39 green: 0.28 blue: 0.22 alpha: 1.00] forState:UIControlStateNormal];

	}
}

- (int) fetchFriendStatus {
	// Query to find markers that belong to current user
	PFQuery *query = [PFQuery queryWithClassName:@"Friendship"];
	PFUser *currentUser = [PFUser currentUser];
	[query whereKey:@"requestId" equalTo:currentUser.objectId];
	[query whereKey:@"recipientId" equalTo:self.user.objectId];
	if(self.friendship!=NULL) {
		[query whereKey:@"objectId" equalTo:self.friendship.objectId];
	}
	NSArray *friendships = [query findObjects];

	if(friendships==nil||friendships.count==0) {
        [self updateFriendship];
		return NOT_FRIEND;
	}else{
		self.friendship=friendships[0];
		if(self.friendship[@"hasFriended"]) {
			return FRIENDED;
		}else {
			return PENDING;
		}
	}
}

- (void) updateFriendship {
	PFUser *currentUser = [PFUser currentUser];
    if(self.friendship == NULL) {
        Friendship *friendship = [Friendship new];
        friendship.requesterId = currentUser.objectId;
        friendship.recipientId = self.user.objectId;
        friendship.hasFriended = @(self.friendStatus);
        [friendship saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                 if (error) {
                 NSLog(@"Error posting: %@", error.localizedDescription);
             } else {
                 NSLog(@"Friendship saved successfully! Status:%d", self.friendStatus);

             }
         }];
        self.friendship = friendship;
        return;
    }
	self.friendship.requesterId = currentUser.objectId;
    self.friendship.recipientId = self.user.objectId;
    self.friendship.hasFriended = @(self.friendStatus);
	[self.friendship saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
	         if (error) {
			 NSLog(@"Error posting: %@", error.localizedDescription);
		 } else {
			 NSLog(@"Friendship saved successfully! Status:%d", self.friendStatus);

		 }
	 }];
}



- (IBAction)friendButton:(id)sender {
	if(self.friendStatus==FRIENDED || self.friendStatus == PENDING) {
		self.friendStatus = NOT_FRIEND;
	}else {
		self.friendStatus = PENDING;
	}
	[self updateFriendship];
	[self updateButton];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return NULL;
}
/*
 #pragma mark - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   // Get the new view controller using [segue destinationViewController].
   // Pass the selected object to the new view controller.
   }
 */

@end
