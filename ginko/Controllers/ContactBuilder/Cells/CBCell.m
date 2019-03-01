//
//  CBCell.m
//  GINKO
//
//  Created by mobidev on 5/17/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import "CBCell.h"

@implementation CBCell
@synthesize delegate;
@synthesize curCBEmail = _curCBEmail;
@synthesize imgValid, lblEmail;

+ (CBCell *)sharedCell
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"CBCell" owner:nil options:nil];
    CBCell *cell = [array objectAtIndex:0];
    
    return cell;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCurCBEmail:(CBEmail *)curCBEmail
{
    _curCBEmail = curCBEmail;
    [imgValid setImage:curCBEmail.valid ? [UIImage imageNamed:@"IconConfirm"] : [UIImage imageNamed:@"IconWarning"]];
    [lblEmail setText:curCBEmail.email];
}

@end
