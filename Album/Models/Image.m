//
//  Image.m
//  Album
//
//  Created by Airei Fukuzawa on 7/12/22.
//

#import "Image.h"

@implementation Image
@dynamic userId;
@dynamic pinId;
@dynamic createdAt;
@dynamic imageFile;

+ (nonnull NSString *)parseClassName {
    return @"Image";
}

+ (void) postImage: ( UIImage * _Nullable )image withPin: ( NSString * _Nullable )pinId withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    Image *newImage = [Image new];
    newImage.imageFile = [self getPFFileFromImage:image];
    newImage.userId = [PFUser currentUser][@"objectId"];
    newImage.pinId = pinId;
    [newImage saveInBackgroundWithBlock: completion];
}
+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
 
    // check if image is not nil
    if (!image) {
        return nil;
    }
    
    NSData *imageData = UIImagePNGRepresentation(image);
    // get image data and check if that is not nil
    if (!imageData) {
        return nil;
    }
    
    return [PFFileObject fileObjectWithName:@"image.png" data:imageData];
}
@end
