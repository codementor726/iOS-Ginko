//
//  UIImage+Tint.m
//  Atitio
//
//  Created by Harry on 3/25/15.
//  Copyright (c) 2015 Harry. All rights reserved.
//

#import "UIImage+Tint.h"

@implementation UIImage(Tint)
- (UIImage *)tintImageWithColor:(UIColor *)color
{
    CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);
    
    UIGraphicsBeginImageContextWithOptions(area.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect rect = (CGRect){ CGPointZero, area.size };
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    [self drawInRect:area];
    
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    [color setFill];
    CGContextFillRect(context, rect);
    
    UIImage *image  = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
