//
//  Friendship.m
//  Album
//
//  Created by Airei Fukuzawa on 7/14/22.
//

#import "Friendship.h"
#import "AlbumConstants.h"

@implementation Friendship
@dynamic objectId;
@dynamic requesterId;
@dynamic recipientId;
@dynamic hasFriended;
@dynamic isClose;

+ (nonnull NSString *)parseClassName {
    return classNameFriendship;
}
@end
