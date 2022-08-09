//
//  ParseAPIHelper.h
//  Album
//
//  Created by Airei Fukuzawa on 7/21/22.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface ParseAPIHelper : NSObject
// Fetch a user based on given id
+ (NSArray *)fetchUser:(NSString *)userId;

// Fetch array of friends of a given user
+ (void)fetchFriends: (NSString *)userId withBlock: (PFQueryArrayResultBlock) block;

// Fetch array of friendship objects of a given user
+ (NSArray *)fetchFriendships: (NSString *)userId;

// Fetch images from a specific pin
+ (void)imagesFromPin:(NSString *)pinId withBlock:(PFQueryArrayResultBlock)block;

// Formate date
+ (NSDateFormatter *) dateFormatter;

// Fetch profile picture
+ (UIImage *) fetchProfile: (PFUser *) user;

@end

NS_ASSUME_NONNULL_END
