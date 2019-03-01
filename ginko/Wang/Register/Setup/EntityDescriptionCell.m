//
//  EntityDescriptionCell.m
//  ginko
//
//  Created by Harry on 1/15/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "EntityDescriptionCell.h"

@implementation EntityDescriptionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _descTextView.delegate = self;
    _borderHeight.constant = 0.5f;
    _descTextView.placeholder = @"Enter description (optional)";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    if (_delegate && [_delegate respondsToSelector:@selector(didChangeEntityDescription:)])
        [_delegate didChangeEntityDescription:textView.text];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return textView.text.length + (text.length - range.length) <= 160;
}

@end
