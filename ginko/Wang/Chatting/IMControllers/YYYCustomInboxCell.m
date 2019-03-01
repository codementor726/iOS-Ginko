//
//  YYYCustomInboxCell.m
//  InstantMessenger
//
//  Created by Wang MeiHua on 3/31/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import "YYYCustomInboxCell.h"

@implementation YYYCustomInboxCell

@synthesize delegate;

+ (YYYCustomInboxCell *)sharedCell
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"YYYCustomInboxCell" owner:nil options:nil];
    YYYCustomInboxCell *cell = [array objectAtIndex:0];
    
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)initWithData:(int)_index
{
	index = _index;
}

-(IBAction)btSelectClick:(id)sender
{
	UIButton *btCheck = (UIButton*)sender;
	if ([btCheck isSelected])
	{
		[btCheck setSelected:NO];
		[delegate selectAction:index :0];
	
	}else
	{
		[btCheck setSelected:YES];
		[delegate selectAction:index :1];
	}
}

@end
