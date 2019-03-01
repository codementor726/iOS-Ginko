//
//  ContactCell.m
//  Ginko
//
//  Created by Qi Song on 29/3/14.
//  Copyright (c) 2014 Qi Song. All rights reserved.
//
// --- Headers ---;
#import "MenuCell.h"

// --- Defines ---;
// ContactCell Class;
@implementation MenuCell

@synthesize imgViewIcon;;
@synthesize lblCaption;
@synthesize backgroundView;

@synthesize delegate;
@synthesize sessionId;
@synthesize contactId;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
