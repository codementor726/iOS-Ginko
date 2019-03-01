//
//  FieldTableTextViewCell.m
//  ginko
//
//  Created by STAR on 15/12/29.
//  Copyright © 2015年 com.xchangewithme. All rights reserved.
//

#import "FieldTableTextViewCell.h"

@implementation FieldTableTextViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _textView.textContainerInset = UIEdgeInsetsMake(1, 0, 1, 0); // for same size as text fields
    
    _textView.textContainer.lineFragmentPadding = 0;
    
    _bottomHeight.constant = 0.5f;
    
    _textView.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)deleteField:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(fieldTableTextViewCellDeleteField:)]) {
        [_delegate fieldTableTextViewCellDeleteField:self];
    }
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    if (_delegate && [_delegate respondsToSelector:@selector(fieldTableTextViewCell:textDidChange:)])
        [_delegate fieldTableTextViewCell:self textDidChange:textView.text];
}
@end
