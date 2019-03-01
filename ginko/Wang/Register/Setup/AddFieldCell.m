//
//  AddFieldCell.m
//  ginko
//
//  Created by STAR on 15/12/27.
//  Copyright © 2015年 com.xchangewithme. All rights reserved.
//

#import "AddFieldCell.h"

@implementation AddFieldCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    
    _fieldLabel.textColor = [UIColor whiteColor];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)layoutSubviews {
    _badgeView.layer.cornerRadius = CGRectGetWidth(_badgeView.bounds) / 2;
    _badgeView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setBadgeCount:(int)badgeCount {
    _badgeView.hidden = badgeCount == 0;
    _badgeLabel.text = @(badgeCount).description;
}

- (IBAction)addField:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(didAddField:)])
        [_delegate didAddField:_fieldLabel.text];
}

@end
