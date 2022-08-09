//
//  ColorConvertHelper.h
//  Album
//
//  Created by emersonmalca on 5/28/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//
#import <UIKit/UIKit.h>
@interface ColorConvertHelper : NSObject

// Creates color based on hex string color code
+ (UIColor *)colorFromHexString:(NSString *)hexString;

// Creates hex string based on color
+ (NSString *)hexStringForColor:(UIColor *)color;

// Creates a square that shows which color has been selected
+ (UIImage *)createImageWithColor:(UIColor *)color;

@end
