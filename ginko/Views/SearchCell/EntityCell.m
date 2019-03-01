//
//  EntityCell.m
//  GINKO
//
//  Created by mobidev on 7/23/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import "EntityCell.h"
#import "UIImageView+AFNetworking.h"

@implementation EntityCell
@synthesize delegate;
@synthesize curDict = _curDict;
@synthesize isFollowing = _isFollowing;
@synthesize imgProfile, lblFollowers, lblName, imgStatus;

+ (EntityCell *)sharedCell
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"EntityCell" owner:nil options:nil];
    EntityCell *cell = [array objectAtIndex:0];
    
    return cell;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    imgProfile.layer.cornerRadius = imgProfile.frame.size.width / 2.0f;
    imgProfile.layer.masksToBounds = YES;
    imgProfile.layer.borderColor = [UIColor colorWithRed:128.0/256.0 green:100.0/256.0 blue:162.0/256.0 alpha:1.0f].CGColor;
    imgProfile.layer.borderWidth = 1.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCurDict:(NSDictionary *)curDict
{
    _curDict = curDict;
    [imgProfile setImageWithURL:[NSURL URLWithString:[_curDict objectForKey:@"profile_image"]] placeholderImage:[UIImage imageNamed:@"entity-dummy"]];
    lblName.text = [_curDict objectForKey:@"name"];
    lblFollowers.text = [NSString stringWithFormat:@"%@ followers", [_curDict objectForKey:@"follower_total"]];
}

- (void)setIsFollowing:(BOOL)isFollowing
{
    _isFollowing = isFollowing;
    if (isFollowing) {
        imgStatus.image = [UIImage imageNamed:@"leaf_solid"];
    } else {
        imgStatus.image = [UIImage imageNamed:@"leaf_line"];
    }
}

@end
