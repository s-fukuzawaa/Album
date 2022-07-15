//
//  FriendProfileViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/7/22.
//

#import "FriendProfileViewController.h"
#import "Friendship.h"
#import "AlbumConstants.h"
#import <PFImageView.h>
#import <Parse/Parse.h>

@interface FriendProfileViewController ()
@property (weak, nonatomic) IBOutlet PFImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIButton *friendButton;
@property (nonatomic) NSNumber *friendStatus; // Friend status from current user's point of view
@property (nonatomic) NSNumber *requestStatus; // Friend status from requester's pov
@property (strong, nonatomic) Friendship *friendship; // Friendship where requester = current user
@property (strong, nonatomic) Friendship *request; // Friendship where requester = tapped user
@end

@implementation FriendProfileViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.friendMapContainer.alpha = 0.0;
	self.friendsGridContainer.alpha = 1.0;
	// Set user profile image view
	[self fetchProfile];
	// Set request statuses
	[self fetchRequestStatus];
	// Set friend statuses
	[self fetchFriendStatus];
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
	if(self.request != NULL && [self.requestStatus intValue]== PENDING) {
		[self.friendButton setTintColor:[UIColor whiteColor]];
		[self.friendButton setTitle:@"Received Request" forState:UIControlStateNormal];
		[self.friendButton setTitleColor:[UIColor colorWithRed: 0.39 green: 0.28 blue: 0.22 alpha: 1.00] forState:UIControlStateNormal];
	}
	else if([self.friendStatus intValue] == FRIENDED) {
		[self.friendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[self.friendButton setTitle:@"Friended" forState:UIControlStateNormal];
		[self.friendButton setTintColor:[UIColor colorWithRed: 0.39 green: 0.28 blue: 0.22 alpha: 1.00]];
	}else if([self.friendStatus intValue] == PENDING) {
		[self.friendButton setTintColor:[UIColor whiteColor]];
		[self.friendButton setTitle:@"Pending" forState:UIControlStateNormal];
		[self.friendButton setTitleColor:[UIColor colorWithRed: 0.39 green: 0.28 blue: 0.22 alpha: 1.00] forState:UIControlStateNormal];
	}else{
		[self.friendButton setTintColor:[UIColor whiteColor]];
		[self.friendButton setTitle:@"Request Friend?" forState:UIControlStateNormal];
		[self.friendButton setTitleColor: [UIColor colorWithRed: 0.39 green: 0.28 blue: 0.22 alpha: 1.00] forState:UIControlStateNormal];
	}
}

- (void) fetchFriendStatus {
	// Query to fetch friend status
	PFQuery *query = [PFQuery queryWithClassName:classNameFriendship];
	PFUser *currentUser = [PFUser currentUser];
	[query whereKey:@"requesterId" equalTo:currentUser.objectId];
	[query whereKey:@"recipientId" equalTo:self.user.objectId];
	[query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable friendships, NSError * _Nullable error) {
	         if (friendships != nil) {
			 // Check if friendships exist between tapped user and current user
			 if(friendships.count == 0) {
				 // If not, add friendship
				 [self updateFriendship];
			 }else{
				 // Otherwise, store
				 self.friendship = friendships[0];
				 self.friendStatus = self.friendship.hasFriended;
				 // Update button UI
				 [self updateButton];
			 }

		 } else {
			 NSLog(@"%@", error.localizedDescription);
		 }
	 }];
}

- (void) fetchRequestStatus {
	// Query to find markers that belong to current user
	PFQuery *query = [PFQuery queryWithClassName:classNameFriendship];
	PFUser *currentUser = [PFUser currentUser];
	[query whereKey:@"recipientId" equalTo:currentUser.objectId];
	[query whereKey:@"requesterId" equalTo:self.user.objectId];
	[query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable requests, NSError * _Nullable error) {
	         if (requests != nil) {
			 // Check if friend requests made to current user from tapped user
			 if(requests.count != 0) {
				 // Store properties
				 self.request = requests[0];
				 self.requestStatus = self.request.hasFriended;
				 // UPdate button UI
				 [self updateButton];
			 }
		 } else {
			 NSLog(@"%@", error.localizedDescription);
		 }
	 }];
}

- (void) updateFriendship {
	// If friendship doesn't exist
	if(self.friendship == NULL) {
		// Add friendship to data base
		PFUser *currentUser = [PFUser currentUser];
		Friendship *friendship = [Friendship new];
		friendship.requesterId = currentUser.objectId;
		friendship.recipientId = self.user.objectId;
		friendship.hasFriended = @(NOT_FRIEND);
		[friendship saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
		         if (error) {
				 NSLog(@"Error posting: %@", error.localizedDescription);
			 } else {
				 NSLog(@"Friendship saved successfully! Status:%@", self.friendStatus);

			 }
		 }];
		// Store properties
		self.friendship=friendship;
		self.friendStatus = @(NOT_FRIEND);
		return;
	}
	// Otherwise, update friendship status in the database
	self.friendship.hasFriended = self.friendStatus;
	[self.friendship saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
	         if(error) {
			 NSLog(@"Error posting: %@", error.localizedDescription);
		 }
	         else{
			 NSLog(@"Successfully saved friendship!");
		 }
	 }];
}

- (void) updateRequest {
	// If there's request from tapped user
	if(self.request != NULL) {
		// Update friendship in the backend
		self.request.hasFriended = self.requestStatus;
		[self.request saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
		         if (error) {
				 NSLog(@"Error posting: %@", error.localizedDescription);
			 } else {
				 NSLog(@"Request saved successfully! Status:%@", self.requestStatus);

			 }
		 }];
		return;
	}
}

- (IBAction)friendButton:(id)sender {
	if([self.friendStatus intValue] == PENDING) {
		// If pending friendStatus, no action
		return;
	}else if(self.requestStatus!=NULL && [self.requestStatus intValue]==PENDING) {
		// If there's pending incoming friendrequest, alert to accept or reject
		[self requestAlert];
		// Update database for request side
		[self updateRequest];
	}else if([self.friendStatus intValue] == FRIENDED) {
		// If they are already friends, but tapped the button, unfriend
		self.requestStatus = @(NOT_FRIEND);
		self.friendStatus = @(NOT_FRIEND);
		// Update database for request side
		[self updateRequest];
	}else if([self.friendStatus intValue] == NOT_FRIEND) {
		// If current user requests to be friends with the tapped user
		self.friendStatus = @(PENDING);
	}
	// Update databased for current user's side
	[self updateFriendship];
	// Update button UI
	[self updateButton];
}

- (void) requestAlert {
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"FRIEND REQUEST" message:@"Choose"
	                            preferredStyle:(UIAlertControllerStyleAlert)];
	// Create a accept action
	UIAlertAction *acceptAction = [UIAlertAction actionWithTitle:@"Accept"
	                               style:UIAlertActionStyleCancel
	                               handler:^(UIAlertAction * _Nonnull action) {
	                                       // Update statuses
	                                       self.requestStatus = @(FRIENDED);
	                                       self.friendStatus = @(FRIENDED);
	                                       // Update database
	                                       [self updateFriendship];
	                                       [self updateRequest];
	                                       [self updateButton];
				       }];
	[alert addAction:acceptAction];
	// Create a reject action
	UIAlertAction *rejectAction = [UIAlertAction actionWithTitle:@"Reject"
	                               style:UIAlertActionStyleDefault
	                               handler:^(UIAlertAction * _Nonnull action) {
	                                       // Update statuses
	                                       self.requestStatus = @(NOT_FRIEND);
	                                       self.friendStatus = @(NOT_FRIEND);
	                                       // Update database
	                                       [self updateFriendship];
	                                       [self updateRequest];
	                                       [self updateButton];

				       }];
	[alert addAction:rejectAction];
	// Cancel action
	UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
	                         style:UIAlertActionStyleDefault
	                         handler: nil];
	[alert addAction:cancel];
	[self presentViewController:alert animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return NULL;
}
@end
