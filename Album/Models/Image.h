//
//  Image.h
//  Album
//
//  Created by Airei Fukuzawa on 7/12/22.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Image : PFObject
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *pinId;
@property (nonatomic, strong) PFFileObject *imageFile;
@property (nonatomic, strong) NSDate *createdAt;
+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image;
@end

NS_ASSUME_NONNULL_END
