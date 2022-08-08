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
+ (NSArray *)fetchUser:(NSString *)userId;
+ (void)fetchFriends: (NSString *)userId withBlock: (PFQueryArrayResultBlock) block;
+ (NSArray *)fetchFriendships: (NSString *)userId;
+ (void)imagesFromPin:(NSString *)pinId withBlock:(PFQueryArrayResultBlock)block;
+ (NSDateFormatter *) dateFormatter;
+ (void)constructQuery:(PFQuery *)query radius:(int) radius coordinate:(CLLocationCoordinate2D) coordinate;
@end

NS_ASSUME_NONNULL_END
