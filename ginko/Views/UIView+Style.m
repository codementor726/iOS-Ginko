//
//  UIView+Style.m
//  ginko
//
//  Created by STAR on 9/21/15.
//  Copyright © 2015 com.xchangewithme. All rights reserved.
//

#import "UIView+Style.h"
#import <objc/runtime.h>

@implementation UIView (Style)

- (void)setStyleInfo:(id)styleInfo
{
    objc_setAssociatedObject( self, "_styleInfo", styleInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC ) ;
}

-(id)styleInfo
{
    return objc_getAssociatedObject( self, "_styleInfo" ) ;
}

@end
