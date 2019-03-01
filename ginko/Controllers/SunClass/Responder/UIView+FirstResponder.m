//
//  UIView+FirstResponder.m
//  Communly
//
//  Created by ccom on 6/9/15.
//  Copyright (c) 2015 Hung. All rights reserved.
//

#import "UIView+FirstResponder.h"

@implementation UIView (FirstResponder)


- (UIView *)findFirstResponder {
    if ([self isFirstResponder])
        return self;
    for (UIView * subView in self.subviews) {
        UIView * fr = [subView findFirstResponder];
        if (fr != nil)
            return fr;
    }
    return nil;
}

@end
