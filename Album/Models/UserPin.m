//
//  UserPin.m
//  Album
//
//  Created by Airei Fukuzawa on 7/22/22.
//

#import "UserPin.h"
#import "AlbumConstants.h"

@implementation UserPin
@dynamic userId;
@dynamic pinId;
@dynamic hasLiked;

+ (nonnull NSString *)parseClassName {
    return classNameUserPin;
}
@end
