//
//  UIView+FindAndResignFirstResponder.m
//  ReactChat
//
//  Created by mobidev on 5/16/14.
//  Copyright (c) 2013 mobidev. All rights reserved.
//

@implementation UIView (FindAndResignFirstResponder)

- (BOOL)findAndResignFirstResponder
{
    if (self.isFirstResponder) {
        [self resignFirstResponder];
        return YES;
    }
    for (UIView *subView in self.subviews) {
        if ([subView findAndResignFirstResponder])
            return YES;
    }
    return NO;
}

@end