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
#import "Image.h"

@interface ParseAPIHelper ()
@end
@implementation ParseAPIHelper

+ (NSArray *)fetchUser:(NSString *)userId {
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"objectId" equalTo:userId];
    return [userQuery findObjects];
}

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, YYYY"];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    return dateFormatter;
}

+ (void)fetchFriends:(NSString *)userId withBlock:(PFQueryArrayResultBlock)block {
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
                [friendArr addObject:[self fetchUser:friendId][0]];
            }
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        block(friendArr, error);
    }];
}

// Fetch images from a pin
+ (void)imagesFromPin:(NSString *)pinId withBlock:(PFQueryArrayResultBlock)block {
    // Fetch images related to specific pin
    PFQuery *query = [PFQuery queryWithClassName:classNameImage];
    [query whereKey:@"pinId" equalTo:pinId];
    [query orderByAscending:(@"createdAt")];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *_Nullable imageObjs, NSError *_Nullable error) {
        NSMutableArray *images = [[NSMutableArray alloc] init];
        if (imageObjs != nil) {
            for (Image *imageObject in imageObjs) {
                [imageObject[@"imageFile"] getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                    if (!error) {
                        UIImage *image = [UIImage imageWithData:imageData];
                        [images addObject:image];
                    }
                }];
            }
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        block(images, error);
    }];
}

+ (NSArray *)fetchFriendships:(NSString *)userId {
    // Query to find markers that belong to current user and current user's friend
    PFQuery *friendQuery = [PFQuery queryWithClassName:classNameFriendship];
    [friendQuery whereKey:@"requesterId" equalTo:userId];
    [friendQuery whereKey:@"hasFriended" equalTo:@(2)];
    return [friendQuery findObjects];
}

+ (UIImage *)fetchProfile:(PFUser *)user {
    PFFileObject *file = user[@"profileImage"];
    return [UIImage imageWithData:[file getData]];
}

@end
