//
//  Pin.m
//  Album
//
//  Created by Airei Fukuzawa on 7/12/22.
//

#import "Pin.h"

@implementation Pin
@dynamic createdAt;
@dynamic captionText;
@dynamic author;
@dynamic likeCount;
@dynamic placeName;
@dynamic placeID;
@dynamic longitude;
@dynamic latitude;
@dynamic traveledOn;


+ (nonnull NSString *)parseClassName {
    return @"Pin";
}
@end
