//
//  Friendship.h
//  Album
//
//  Created by Airei Fukuzawa on 7/14/22.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Friendship : PFObject<PFSubclassing>
@property (nonatomic, strong) NSString *requesterId;
@property (nonatomic, strong) NSString *recipientId;
@property (nonatomic, strong) NSNumber *hasFriended;
@end

NS_ASSUME_NONNULL_END
