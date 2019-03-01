//
//  UIBubbleTableViewCell.m
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import <QuartzCore/QuartzCore.h>
#import "UIBubbleTableViewCell.h"
#import "NSBubbleData.h"
#import "UIImageView+AFNetworking.h"

#define RADIOWIDTH	25

@interface UIBubbleTableViewCell ()

@property (nonatomic, retain) UIView *customView;
@property (nonatomic, retain) UIImageView *bubbleImage;
@property (nonatomic, retain) UIImageView *avatarImage;
@property (nonatomic, retain) UILabel *lblUsername;
@property (nonatomic, retain) UIButton *btnCheck;

- (void) setupInternalData;

@end

@implementation UIBubbleTableViewCell

@synthesize data = _data;
@synthesize customView = _customView;
@synthesize bubbleImage = _bubbleImage;
@synthesize showAvatar = _showAvatar;
@synthesize avatarImage = _avatarImage;
@synthesize btnCheck = _btnCheck;
@synthesize bEdit;
@synthesize delegate;
@synthesize bSelected;
@synthesize lblUsername = _lblUsername;

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
	[self setupInternalData];
}

#if !__has_feature(objc_arc)
- (void) dealloc
{
    self.data = nil;
    self.customView = nil;
    self.bubbleImage = nil;
    self.avatarImage = nil;
	[super dealloc];
}
#endif

- (void)setDataInternal:(NSBubbleData *)value
{
	self.data = value;
	[self setupInternalData];
}

- (void) setupInternalData
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (!self.bubbleImage)
    {
#if !__has_feature(objc_arc)
        self.bubbleImage = [[[UIImageView alloc] init] autorelease];
#else
        self.bubbleImage = [[UIImageView alloc] init];        
#endif
        [self addSubview:self.bubbleImage];
    }
    
    NSBubbleType type = self.data.type;
    
    CGFloat width = self.data.view.frame.size.width;
    CGFloat height = self.data.view.frame.size.height;

    CGFloat x = (type == BubbleTypeSomeoneElse) ? 0 : self.frame.size.width - width - self.data.insets.left - self.data.insets.right;
    CGFloat y = 0;
//
//    // Adjusting the x coordinate for avatar
//    if (self.showAvatar)
//    {
//        [self.avatarImage removeFromSuperview];
//#if !__has_feature(objc_arc)
//        self.avatarImage = [[[UIImageView alloc] initWithImage:(self.data.avatar ? self.data.avatar : [UIImage imageNamed:@"missingAvatar.png"])] autorelease];
//#else
//        self.avatarImage = [[UIImageView alloc] initWithImage:(self.data.avatar ? self.data.avatar : [UIImage imageNamed:@"missingAvatar.png"])];
//#endif
//        self.avatarImage.layer.cornerRadius = 9.0;
//        self.avatarImage.layer.masksToBounds = YES;
//        self.avatarImage.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.2].CGColor;
//        self.avatarImage.layer.borderWidth = 1.0;
//        
//        CGFloat avatarX = (type == BubbleTypeSomeoneElse) ? 2 : self.frame.size.width - 52;
//        CGFloat avatarY = self.frame.size.height - 50;
//        
//        self.avatarImage.frame = CGRectMake(avatarX, avatarY, 50, 50);
//        [self addSubview:self.avatarImage];
//        
//        CGFloat delta = self.frame.size.height - (self.data.insets.top + self.data.insets.bottom + self.data.view.frame.size.height);
//        if (delta > 0) y = delta;
//        
//        if (type == BubbleTypeSomeoneElse) x += 54;
//        if (type == BubbleTypeMine) x -= 54;
//    }
	
	y = 5;
	
    // Adjusting the x coordinate for avatar
    if (self.showAvatar)
    {
        [self.avatarImage removeFromSuperview];
		[self.lblUsername removeFromSuperview];
		
#if !__has_feature(objc_arc)
        self.avatarImage = [[[UIImageView alloc] init] autorelease];
        [self.avatarImage setImageWithURL:self.data.avatar_url placeholderImage:[UIImage imageNamed:@"anonymousUser.png"]];
#else
        self.avatarImage = [[UIImageView alloc] init];
        [self.avatarImage setImageWithURL:self.data.avatar_url placeholderImage:[UIImage imageNamed:@"anonymousUser.png"]];
#endif
		
        self.avatarImage.layer.masksToBounds = YES;
        self.avatarImage.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.2].CGColor;
        self.avatarImage.layer.borderWidth = 1.0;
        self.avatarImage.contentMode = UIViewContentModeScaleAspectFill;
		
        CGFloat avatarX = (type == BubbleTypeSomeoneElse) ? 2 : self.frame.size.width - 52;
//        CGFloat avatarY = self.frame.size.height - 60;
        CGFloat avatarY = 2;
		if (bEdit && type == BubbleTypeSomeoneElse) {
			self.avatarImage.frame = CGRectMake(RADIOWIDTH + avatarX, avatarY, 45, 45);
		}else{
			self.avatarImage.frame = CGRectMake(avatarX, avatarY, 45, 45);
		}
        
		self.avatarImage.layer.cornerRadius = self.avatarImage.frame.size.height/2.0f;
		
        if (type == BubbleTypeSomeoneElse)
		{
			CGRect rt = self.avatarImage.frame;
			self.lblUsername = [[UILabel alloc] initWithFrame:CGRectMake(rt.origin.x, rt.origin.y + rt.size.height + 1, rt.size.width, 15)];
			self.lblUsername.textColor = [UIColor grayColor];
			self.lblUsername.font = [UIFont systemFontOfSize:16];
			self.lblUsername.text = [NSString stringWithFormat:@"%@%@",[[self.data.msg_userfname substringToIndex:self.data.msg_userfname.length?1:0] uppercaseString],[[self.data.msg_userlname substringToIndex:self.data.msg_userlname.length?1:0] uppercaseString]];
            if (self.data.msg_entityname) {
                self.lblUsername.text = self.data.msg_entityname;
            }
			self.lblUsername.textAlignment = NSTextAlignmentCenter;
			
			[self addSubview:self.avatarImage];
			[self addSubview:self.lblUsername];
        }
        
        CGFloat delta = self.frame.size.height - (self.data.insets.top + self.data.insets.bottom + self.data.view.frame.size.height);
        if (delta > 0) y = delta / 2;
        
        if (type == BubbleTypeSomeoneElse) x += 54;
        if (type == BubbleTypeMine) x -= 4;
		
		
		self.avatarImage.userInteractionEnabled = YES;
		UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProfile)];
		[self.avatarImage addGestureRecognizer:tapGesture];
	}
	
    [self.customView removeFromSuperview];
    self.customView = self.data.view;
	
	if (bEdit && type == BubbleTypeSomeoneElse) {
        self.customView.frame = CGRectMake(RADIOWIDTH + x + self.data.insets.left, y + self.data.insets.top, width, height);

	}else{
		self.customView.frame = CGRectMake(x + self.data.insets.left, y + self.data.insets.top, width, height);
	}
    
    [self.contentView addSubview:self.customView];

    if (type == BubbleTypeSomeoneElse)
    {
        self.bubbleImage.image = [[UIImage imageNamed:@"bubbleSomeone.png"] stretchableImageWithLeftCapWidth:21 topCapHeight:14];
    }
    else
	{
        self.bubbleImage.image = [[UIImage imageNamed:@"bubbleMine.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:14];
    }

	if (bEdit && type == BubbleTypeSomeoneElse)
	{
		self.bubbleImage.frame = CGRectMake(x + RADIOWIDTH , y, width + self.data.insets.left + self.data.insets.right, height + self.data.insets.top + self.data.insets.bottom);
	}
	else
	{
		self.bubbleImage.frame = CGRectMake(x , y, width + self.data.insets.left + self.data.insets.right, height + self.data.insets.top + self.data.insets.bottom);
	}
	
	self.btnCheck = [UIButton buttonWithType:UIButtonTypeCustom];
    y = self.avatarImage.center.y;
	if (bEdit)
	{
		[self.btnCheck setFrame:CGRectMake(5, y, 20, 20)];
	}
	else
	{
		[self.btnCheck setFrame:CGRectMake(5 - RADIOWIDTH , y, 20, 20)];
	}
	
	[self.btnCheck setImage:[UIImage imageNamed:@"btn_check_normal.png"] forState:UIControlStateNormal];
	[self.btnCheck setImage:[UIImage imageNamed:@"btn_check_sel.png"] forState:UIControlStateSelected];
	[self.btnCheck addTarget:self action:@selector(btnCheckClick:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:self.btnCheck];
    [self bringSubviewToFront:self.btnCheck];
	if (bSelected)
	{
		[self.btnCheck setSelected:YES];
	}
	else
	{
		[self.btnCheck setSelected:NO];
	}
}

-(void)tapProfile
{
	[self.delegate profileAction:self.data.msg_userid];
}

-(IBAction)btnCheckClick:(id)sender
{
	if (self.btnCheck.selected)
	{
		self.btnCheck.selected = NO;
		[delegate checkAction:self.data.msg_id :0];
	}
	else
	{
		self.btnCheck.selected = YES;
		[delegate checkAction:self.data.msg_id :1];
	}
}

@end
