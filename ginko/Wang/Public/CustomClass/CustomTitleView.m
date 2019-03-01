//
//  HomeInfoView.m
//  Xchangewithme
//
//  Created by Xin YingTai on 20/5/14.
//  Copyright (c) 2014 Xin YingTai. All rights reserved.
//

#import "CustomTitleView.h"

@implementation CustomTitleView

+ (CustomTitleView *)homeInfoView
{
    CustomTitleView *_sharedView = [[[NSBundle mainBundle] loadNibNamed:@"CustomTitleView" owner:nil options:nil] objectAtIndex:0];
    return _sharedView;
}

+ (CustomTitleView *)homeaddInfoView
{
    CustomTitleView *_sharedView = [[[NSBundle mainBundle] loadNibNamed:@"CustomTitleView" owner:nil options:nil] objectAtIndex:1];
    return _sharedView;
}

+ (CustomTitleView *)workInfoView
{
    CustomTitleView *_sharedView = [[[NSBundle mainBundle] loadNibNamed:@"CustomTitleView" owner:nil options:nil] objectAtIndex:2];
    return _sharedView;
}

+ (CustomTitleView *)workaddInfoView
{
    CustomTitleView *_sharedView = [[[NSBundle mainBundle] loadNibNamed:@"CustomTitleView" owner:nil options:nil] objectAtIndex:3];
    return _sharedView;
}

+ (CustomTitleView *)homePreviewView
{
	CustomTitleView *_sharedView = [[[NSBundle mainBundle] loadNibNamed:@"CustomTitleView" owner:nil options:nil] objectAtIndex:4];
    return _sharedView;
}

+ (CustomTitleView *)homeEditView
{
	CustomTitleView *_sharedView = [[[NSBundle mainBundle] loadNibNamed:@"CustomTitleView" owner:nil options:nil] objectAtIndex:5];
    return _sharedView;
}

+ (CustomTitleView *)workPreviewView
{
	CustomTitleView *_sharedView = [[[NSBundle mainBundle] loadNibNamed:@"CustomTitleView" owner:nil options:nil] objectAtIndex:6];
    return _sharedView;
}

+ (CustomTitleView *)workEditView
{
	CustomTitleView *_sharedView = [[[NSBundle mainBundle] loadNibNamed:@"CustomTitleView" owner:nil options:nil] objectAtIndex:7];
    return _sharedView;
}

+ (CustomTitleView *)entityView :(NSString*)title
{
	CustomTitleView *_sharedView = [[[NSBundle mainBundle] loadNibNamed:@"CustomTitleView" owner:nil options:nil] objectAtIndex:8];
	
	UIImageView *imvIcon = (UIImageView*)[_sharedView viewWithTag:101];
	
	UILabel *lblTitle = (UILabel*)[_sharedView viewWithTag:100];
	[lblTitle setText:title];
	[lblTitle sizeToFit];
	
	int nOffset = (160 - 26 - 5 - lblTitle.frame.size.width)/2;
	
	CGRect rt = imvIcon.frame;
	rt.origin.x = rt.origin.x + nOffset;
	[imvIcon setFrame:rt];
	
	rt = lblTitle.frame;
	rt.origin.x = rt.origin.x + nOffset;
	[lblTitle setFrame:rt];
	
	return _sharedView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

@end
