//
//  ContactCell.m
//  Ginko
//
//  Created by Qi Song on 29/3/14.
//  Copyright (c) 2014 Qi Song. All rights reserved.
//
// --- Headers ---;
#import "PurpleDetailCell.h"

// --- Defines ---;
// ContactCell Class;
@implementation PurpleDetailCell

// Created by Zhun L.
@synthesize lblContent;
@synthesize type;
@synthesize imgIcon;
//------------------

@synthesize delegate;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
}

- (void)setIcons
{
    CGPoint pt;
    pt = imgIcon.center;
    
    if ([type isEqualToString:@"phone"])
    {
        [imgIcon setImage:[UIImage imageNamed:@"IconPhone"]];
        [imgIcon setFrame:CGRectMake(0, 0, 20, 22)];
    }
    else if ([type isEqualToString:@"email"])
    {
        [imgIcon setImage:[UIImage imageNamed:@"IconMail"]];
        [imgIcon setFrame:CGRectMake(0, 0, 20, 13)];
    }
    else if ([type isEqualToString:@"address"])
    {
        [imgIcon setImage:[UIImage imageNamed:@"IconAddr"]];
        [imgIcon setFrame:CGRectMake(0, 0, 20, 19)];
    }
    else
        [imgIcon setImage:nil];
    
    [imgIcon setCenter:pt];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
