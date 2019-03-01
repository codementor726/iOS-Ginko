//
//  EntityPreviewMapCell.m
//  ginko
//
//  Created by Harry on 1/16/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "EntityPreviewMapCell.h"

@implementation EntityPreviewMapCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
