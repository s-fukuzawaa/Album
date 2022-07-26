//
//  ParseAPIHelper.m
//  Album
//
//  Created by Airei Fukuzawa on 7/21/22.
//

#import "ParseAPIHelper.h"
#import "Parse/Parse.h"
#import "Friendship.h"
#import "AlbumConstants.h"

@interface ParseAPIHelper ()
@end
@implementation ParseAPIHelper
// Used to find specfic user
- (NSArray *)fetchUser:(NSString *)userId coordinate:(CLLocationCoordinate2D) coordinate radius:(int) radius{
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"objectId" equalTo:userId];
    [userQuery whereKey:@"latitude" lessThanOrEqualTo:@(coordinate.latitude+radius)];
    [userQuery whereKey:@"latitude" greaterThanOrEqualTo:@(coordinate.latitude-radius)];
    [userQuery whereKey:@"longitude" lessThanOrEqualTo:@(coordinate.longitude+radius)];
    [userQuery whereKey:@"longitude" greaterThanOrEqualTo:@(coordinate.longitude-radius)];
    return [userQuery findObjects];
}
- (NSArray *)fetchUserNoLimit:(NSString *)userId{
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"objectId" equalTo:userId];
    return [userQuery findObjects];
}

- (void)fetchFriends: (NSString *)userId coordinate:(CLLocationCoordinate2D) coordinate radius:(int) radius withBlock: (PFQueryArrayResultBlock) block{
    // Query to find markers that belong to current user and current user's friend
    PFQuery *friendQuery = [PFQuery queryWithClassName:classNameFriendship];
    [friendQuery whereKey:@"requesterId" equalTo:userId];
    [friendQuery whereKey:@"hasFriended" equalTo:@(2)];
    [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *friendships, NSError *error) {
        NSMutableArray *friendArr = [[NSMutableArray alloc] init];
        if (friendships != nil) {
            NSLog(@"Successfully fetched friendships!");
            // For each friend, find their pins
            for (Friendship *friendship in friendships) {
                NSString *friendId = friendship[@"recipientId"];
                PFUser *friend = [self fetchUser:friendId coordinate:coordinate radius:radius][0];
                [friendArr addObject:friend];
            }
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        block(friendArr,error);
    }];
} /* fetchFriends */

- (void)fetchFriendsNoLimit: (NSString *)userId withBlock: (PFQueryArrayResultBlock) block{
    // Query to find markers that belong to current user and current user's friend
    PFQuery *friendQuery = [PFQuery queryWithClassName:classNameFriendship];
    [friendQuery whereKey:@"requesterId" equalTo:userId];
    [friendQuery whereKey:@"hasFriended" equalTo:@(2)];
    [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *friendships, NSError *error) {
        NSMutableArray *friendArr = [[NSMutableArray alloc] init];
        if (friendships != nil) {
            NSLog(@"Successfully fetched friendships!");
            // For each friend, find their pins
            for (Friendship *friendship in friendships) {
                NSString *friendId = friendship[@"recipientId"];
                PFUser *friend = [self fetchUserNoLimit:friendId][0];
                [friendArr addObject:friend];
            }
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        block(friendArr,error);
    }];
} /* fetchFriends */

@end
