//
//  YYYSelectContactCell.m
//  GINKO
//
//  Created by mobidev on 7/3/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import "YYYSelectContactCell.h"

@implementation YYYSelectContactCell

+ (YYYSelectContactCell *)sharedCell
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"YYYSelectContactCell" owner:nil options:nil];
    YYYSelectContactCell *cell = [array objectAtIndex:0];
    
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

@end
