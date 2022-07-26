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
- (void)fetchFriends: (NSString *)userId withBlock: (PFQueryArrayResultBlock) block;
@end

NS_ASSUME_NONNULL_END
