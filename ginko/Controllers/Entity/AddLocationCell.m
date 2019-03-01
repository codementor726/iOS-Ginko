//
//  AddLocationCell.m
//  ginko
//
//  Created by stepanekdavid on 4/17/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "AddLocationCell.h"

@implementation AddLocationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _bottomHeight.constant = 0.5f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
