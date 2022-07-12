//
//  Pin.m
//  Album
//
//  Created by Airei Fukuzawa on 7/12/22.
//

#import "Pin.h"

@implementation Pin
@dynamic userId;
@dynamic createdAt;
@dynamic captionText;
@dynamic author;
@dynamic likeCount;

+ (nonnull NSString *)parseClassName {
    return @"Post";
}
@end
