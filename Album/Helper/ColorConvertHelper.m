//
//  ColorConvertHelper.m
//  Album
//
//  Created by Airei Fukuzawa on 7/19/22.
//

#import <Foundation/Foundation.h>
#import "ColorConvertHelper.h"

@interface ColorConvertHelper ()

@end
@implementation ColorConvertHelper

- (UIImage *)createImageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 57, 57);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned int rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >>
                                  16) / 255.0 green:((rgbValue & 0xFF00) >> 8) / 255.0 blue:(rgbValue & 0xFF) / 255.0 alpha:1.0];
}

- (NSString *)hexStringForColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    int r = (int)components[0] * 255;
    int g = (int)components[1] * 255;
    int b = (int)components[2] * 255;
    NSString *hexString = [NSString stringWithFormat:@"%02X%02X%02X", r, g, b];
    return hexString;
}
@end
