//
//  ColorConvertHelper.h
//  Album
//
//  Created by emersonmalca on 5/28/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface ColorConvertHelper : NSObject

- (UIColor *)colorFromHexString:(NSString *)hexString;

- (NSString *)hexStringForColor:(UIColor *)color;

- (UIImage *)createImageWithColor: (UIColor *)color;

@end
