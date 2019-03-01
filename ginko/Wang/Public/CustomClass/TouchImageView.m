//
//  TouchImageView.m
//  XChangeWithMe
//
//  Created by Wang MeiHua on 5/22/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import "TouchImageView.h"

@implementation TouchImageView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)initData
{
	UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
	[self addGestureRecognizer:panGesture];
	
	UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
	[self addGestureRecognizer:pinchGesture];
}

-(void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self.superview];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y+translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.superview];
}

-(void)handlePinch:(UIPinchGestureRecognizer *)recognizer
{
	if(self.frame.size.height * recognizer.scale< 150) return;
	
	recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
}


@end
