//
//  TouchTextField.m
//  XChangeWithMe
//
//  Created by Wang MeiHua on 5/22/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import "TouchLabel.h"

@implementation TouchLabel

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
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
	[self addGestureRecognizer:tapGesture];
	
	UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
	[self addGestureRecognizer:panGesture];
	
	self.layer.borderColor = [[UIColor redColor] CGColor];
}

-(void)handleTap
{
	[delegate tappedLabel:self];
//	[self setBackgroundColor:[UIColor whiteColor]];
//	[self setTextColor:[UIColor blackColor]];
	
	self.layer.borderWidth = 1.0f;
}

-(void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self.superview];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y+translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.superview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
