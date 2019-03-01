//
//  ToggleButton.m
//  JamTracks
//
//  Created by Harry on 8/29/14.
//
//

#import "ToggleButton.h"
#import "UIColor+LightAndDark.h"

@implementation ToggleButton
{
    UIColor *_highlightedColor;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.layer.cornerRadius = kCornerRadius;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
//        self.layer.cornerRadius = kCornerRadius;
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if(highlighted)
        self.backgroundColor = _highlightedColor;
    else
        self.backgroundColor = self.bgColor;
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    if(enabled)
        self.alpha = 1;
    else
        self.alpha = 0.5;
}

- (void)setBgColor:(UIColor *)bgColor
{
    _bgColor = bgColor;
    self.backgroundColor = bgColor;
    _highlightedColor = [bgColor darkerColor];
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    [self setTitleColor:_titleColor forState:UIControlStateNormal];
    [self setTitleColor:[_titleColor darkerColor] forState:UIControlStateHighlighted];
}

@end
