//
//  NotExchangedInfoCell.m
//  Ginko
//
//  Created by Qi Song on 29/3/14.
//  Copyright (c) 2014 Qi Song. All rights reserved.
//
// --- Headers ---;
#import "RequestInfoCell.h"
#import "UIImageView+AFNetworking.h"

// --- Defines ---;
// NotExchangedInfoCell Class;
@implementation RequestInfoCell

@synthesize profileImageView;
@synthesize username;
@synthesize lastDate;
@synthesize delegate;
@synthesize contactInfo;
@synthesize pingArea;
@synthesize isEntity;
- (void)awakeFromNib
{
    [super awakeFromNib];
    profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2.0f;
    profileImageView.layer.masksToBounds = YES;
    profileImageView.layer.borderColor = [UIColor colorWithRed:128.0/256.0 green:100.0/256.0 blue:162.0/256.0 alpha:1.0f].CGColor;
    profileImageView.layer.borderWidth = 1.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)onShareInfo:(id)sender
{
    if (!isEntity) {
        [delegate shareInfo:contactInfo];
    }else{
        [delegate getEntityFollow:contactInfo];
    }
}

- (void)setPhoto:(NSString *)photo
{
//    [profileImageView setImageWithURL:[NSURL URLWithString:photo] placeholderImage:nil];
    [profileImageView setImageWithURL:[NSURL URLWithString:photo] placeholderImage:[UIImage imageNamed:@"entity-dummy"]];
}

@end
