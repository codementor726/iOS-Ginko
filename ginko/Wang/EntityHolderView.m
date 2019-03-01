//
//  EntityHolderView.m
//  ginko
//
//  Created by STAR on 9/20/15.
//  Copyright © 2015 com.xchangewithme. All rights reserved.
//

#import "EntityHolderView.h"
#import "TouchLabel.h"

@implementation EntityHolderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *touchView = [super hitTest:point withEvent:event];
    
    if ([touchView isKindOfClass:[TouchLabel class]]) {
        return touchView;
    }
    
    if (_foregroundView) {
        CGPoint pointInB = [_foregroundView convertPoint:point fromView:self];
        
        if ([_foregroundView pointInside:pointInB withEvent:event])
            return _foregroundView;
    }
    
    return touchView;
}

@end
