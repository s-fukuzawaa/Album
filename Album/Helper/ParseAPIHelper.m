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
- (void)constructQuery:(PFQuery *)query radius:(int) radius coordinate:(CLLocationCoordinate2D) coordinate{
    [query orderByDescending:(@"traveledOn")];
    [query includeKey:@"objectId"];
    double dLat = (double)(radius) / earthR;
    double dLon = (double)(radius) / (earthR * cos(M_PI * coordinate.latitude / 180));
    [query whereKey:@"latitude" lessThanOrEqualTo:@(coordinate.latitude + dLat * 180 / M_PI)];
    [query whereKey:@"latitude" greaterThanOrEqualTo:@(coordinate.latitude - dLat * 180 / M_PI)];
    [query whereKey:@"longitude" lessThanOrEqualTo:@(coordinate.longitude + dLon * 180 / M_PI)];
    [query whereKey:@"longitude" greaterThanOrEqualTo:@(coordinate.longitude - dLon * 180 / M_PI)];
}
- (NSArray *)fetchUser:(NSString *)userId {
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"objectId" equalTo:userId];
    return [userQuery findObjects];
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
//                [self fetchUser:friendId withBlock:^(NSArray * _Nullable friends, NSError * _Nullable error) {
//                    if(friends != nil) {
//                        NSLog(@"Successfully fetched friends!");
//                        [friendArr addObject:friends[0]];
//                    }else {
//                        NSLog(@"%@", error.localizedDescription);
//                    }
//                }];
                [friendArr addObject:[self fetchUser:friendId][0]];
            }
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        block(friendArr,error);
    }];
}

@end
