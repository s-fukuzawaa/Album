//
//  Image.h
//  Album
//
//  Created by Airei Fukuzawa on 7/12/22.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Image : PFObject<PFSubclassing>
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *pinId;
@property (nonatomic, strong) PFFileObject *imageFile;
@property (nonatomic, strong) NSDate *createdAt;
+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image;
+ (void) postImage: ( UIImage * _Nullable )image withPin: ( NSString * _Nullable )pinId withCompletion: (PFBooleanResultBlock  _Nullable)completion;
@end

NS_ASSUME_NONNULL_END
