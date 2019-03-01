//
//  ContactCell.m
//  Ginko
//
//  Created by Qi Song on 29/3/14.
//  Copyright (c) 2014 Qi Song. All rights reserved.
//
// --- Headers ---;
#import "LoginSettingCell.h"

// --- Defines ---;
// ContactCell Class;
@implementation LoginSettingCell


// Created by Zhun L.
@synthesize lblEmail;
@synthesize lblStatus;
//------------------

@synthesize delegate;
@synthesize sessionId;
@synthesize contactId;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
}

- (void)setPhoto:(NSString *)photo
{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
