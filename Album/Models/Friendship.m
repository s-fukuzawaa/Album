//
//  Friendship.m
//  Album
//
//  Created by Airei Fukuzawa on 7/14/22.
//

#import "Friendship.h"

@implementation Friendship
@dynamic requesterId;
@dynamic recipientId;
@dynamic hasFriended;

+ (nonnull NSString *)parseClassName {
    return @"Friendship";
}
@end
