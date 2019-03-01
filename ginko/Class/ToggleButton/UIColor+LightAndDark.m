//
//  UIColor+LightAndDark.m
//  Golugolu
//
//  Created by Harry on 2/7/15.
//  Copyright (c) 2015 Harry. All rights reserved.
//

#import "UIColor+LightAndDark.h"

@implementation UIColor(LightAndDark)

- (UIColor *)lighterColor
{
    CGFloat h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:MIN(b * 1.3, 1.0)
                               alpha:a];
    return nil;
}

- (UIColor *)darkerColor
{
    CGFloat h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:b * 0.96
                               alpha:a];
    return nil;
}

- (UIColor *)littleDarkerColor
{
    CGFloat h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:b * 0.9
                               alpha:a];
    return nil;
}

@end
