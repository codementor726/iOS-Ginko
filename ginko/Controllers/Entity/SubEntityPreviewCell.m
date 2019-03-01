//
//  SubEntityPreviewCell.m
//  ginko
//
//  Created by stepanekdavid on 4/18/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "SubEntityPreviewCell.h"

@implementation SubEntityPreviewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _subEntityImg .layer.borderWidth = 1;
    _subEntityImg.layer.borderColor = COLOR_PURPLE_THEME.CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
