//
//  ParseAPIHelper.m
//  Album
//
//  Created by Airei Fukuzawa on 7/21/22.
//

#import "ParseAPIHelper.h"
#import "Parse.h"
#import "Friendship.h"
#import "AlbumConstants.h"

@interface ParseAPIHelper ()
@end
@implementation ParseAPIHelper
// Used to find specfic user
- (NSArray *)fetchUser:(NSString *)userId {
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"objectId" equalTo:userId];
    return [userQuery findObjects];
}

- (NSArray*)fetchFriends: (NSString *)userId {
    // Create returning friend set
    NSMutableArray *friendArr = [[NSMutableArray alloc] init];
    // Query to find markers that belong to current user and current user's friend
    PFQuery *friendQuery = [PFQuery queryWithClassName:classNameFriendship];
    [friendQuery whereKey:@"requesterId" equalTo:userId];
    [friendQuery whereKey:@"hasFriended" equalTo:@(2)];
    [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *friendships, NSError *error) {
        if (friendships != nil) {
            NSLog(@"Successfully fetched friendships!");
            // For each friend, find their pins
            for (Friendship *friendship in friendships) {
                NSString *friendId = friendship[@"recipientId"];
                PFUser *friend = [self fetchUser:friendId][0];
                [friendArr addObject:friend];
            }
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    return friendArr;
} /* fetchFriends */
@end
