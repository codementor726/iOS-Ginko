//
//  FieldTableCell.m
//  ginko
//
//  Created by STAR on 15/12/23.
//  Copyright © 2015年 com.xchangewithme. All rights reserved.
//

#import "FieldTableCell.h"

@implementation FieldTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _bottomHeight.constant = 0.5f;
    
    _textField.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)deleteField:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(fieldTableCellDeleteField:)]) {
        [_delegate fieldTableCellDeleteField:self];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (_delegate && [_delegate respondsToSelector:@selector(fieldTableCell:textDidChange:)])
        [_delegate fieldTableCell:self textDidChange:text];
    
    return YES;
}
- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField{
    if (_delegate && [_delegate respondsToSelector:@selector(fieldTableCellTextFieldShouldBeginEditing:)])
        [_delegate fieldTableCellTextFieldShouldBeginEditing:self];
    return YES;
}
- (BOOL) textFieldShouldEndEditing:(UITextField *)textField{
    if (_delegate && [_delegate respondsToSelector:@selector(fieldtableCellTextfieldShouldEndEditing:)])
        [_delegate fieldtableCellTextfieldShouldEndEditing:self];
    return YES;
}
- (void) textFieldDidBeginEditing:(UITextField *)textField{
    if (_delegate && [_delegate respondsToSelector:@selector(fieldTableCellTextFieldDidBeginEditing:)])
        [_delegate fieldTableCellTextFieldDidBeginEditing:self];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (_delegate && [_delegate respondsToSelector:@selector(fieldTableCellTextFieldDidReturn:)])
        [_delegate fieldTableCellTextFieldDidReturn:self];
    return NO;
}

@end
