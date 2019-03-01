//
//  FilterCell.m
//  Xchangewithme
//
//  Created by Xin YingTai on 21/5/14.
//  Copyright (c) 2014 Xin YingTai. All rights reserved.
//

#import "FilterCell.h"

@implementation FilterCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void)setNameOfFilter:(NSString *)name
{
    imgForFilter.image = [UIImage imageNamed:[NSString stringWithFormat:@"filter_image_%@.png", name]];
    lblForFilter.text = name;
}

@end
