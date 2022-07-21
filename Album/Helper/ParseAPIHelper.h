//
//  ParseAPIHelper.h
//  Album
//
//  Created by Airei Fukuzawa on 7/21/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ParseAPIHelper : NSObject
- (NSArray *)fetchUser:(NSString *)userId;
- (NSArray*)fetchFriends: (NSString *)userId;
@end

NS_ASSUME_NONNULL_END
