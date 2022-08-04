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
- (void)fetchUser:(NSString *)userId withBlock: (PFQueryArrayResultBlock) block{
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"objectId" equalTo:userId];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable users, NSError * _Nullable error) {
        NSArray *usersArr = [[NSArray alloc] init];
        if (users != nil) {
            NSLog(@"Successfully fetched users!");
            // For each friend, find their pins
            usersArr = users;
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        block(usersArr,error);
    }];
}

- (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, YYYY"];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    return dateFormatter;
}

- (void)fetchFriends: (NSString *)userId withBlock: (PFQueryArrayResultBlock) block{
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
                [self fetchUser:friendId withBlock:^(NSArray * _Nullable friends, NSError * _Nullable error) {
                    if(friends != nil) {
                        NSLog(@"Successfully fetched friends!");
                        [friendArr addObject:friends[0]];
                    }else {
                        NSLog(@"%@", error.localizedDescription);
                    }
                }];
            }
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        block(friendArr,error);
    }];
}

@end
