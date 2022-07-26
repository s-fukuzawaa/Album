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
- (NSArray *)fetchUser:(NSString *)userId coordinate:(CLLocationCoordinate2D) coordinate radius:(int) radius;
- (void)fetchFriends: (NSString *)userId coordinate:(CLLocationCoordinate2D) coordinate radius:(int) radius withBlock: (PFQueryArrayResultBlock) block;
- (void)fetchFriendsNoLimit: (NSString *)userId withBlock: (PFQueryArrayResultBlock) block;
@end

NS_ASSUME_NONNULL_END
