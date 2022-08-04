//
//  Pin.h
//  Album
//
//  Created by Airei Fukuzawa on 7/12/22.
//
#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Pin : PFObject <PFSubclassing>
@property (nonatomic, strong) NSString *captionText;
@property (nonatomic, strong) NSString *placeName;
@property (nonatomic, strong) NSString *placeID;
@property (nonatomic) double longitude;
@property (nonatomic) double latitude;
@property (nonatomic, strong) NSNumber *likeCount;
@property (nonatomic, strong) PFUser *author;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *traveledOn;
@property (nonatomic) BOOL isCloseFriendPin;
@end

NS_ASSUME_NONNULL_END
