//
//  UserPin.h
//  Album
//
//  Created by Airei Fukuzawa on 7/22/22.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserPin : PFObject<PFSubclassing>
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *pinId;
@property (nonatomic) BOOL hasLiked;
@end

NS_ASSUME_NONNULL_END
