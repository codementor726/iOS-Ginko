//
//  ProfileNamePictureCell.m
//  ginko
//
//  Created by STAR on 15/12/23.
//  Copyright © 2015年 com.xchangewithme. All rights reserved.
//

#import "ProfileNamePictureCell.h"

@implementation ProfileNamePictureCell

- (void)awakeFromNib {
    _nameTextView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Your Name" attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:20], NSForegroundColorAttributeName: [UIColor colorWithWhite:178.f/255 alpha:1]}];
    
    _nameTextView.textContainerInset = UIEdgeInsetsMake(1, 0, 1, 0); // for same size as text fields
    _nameTextView.textContainer.lineFragmentPadding = 0;
    _nameTextView.delegate = self;
    
    _textField.placeholder = @"Your Name";
    _textField.returnKeyType = UIReturnKeyNext;
    _textField.delegate = self;
    
    _borderHeight.constant = 0.5f;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _profileImageButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    _profileImageButton.clipsToBounds = YES;
}

- (void)layoutSubviews {
    [super awakeFromNib];
    if (_roundCornerImage)
        _profileImageButton.layer.cornerRadius = CGRectGetWidth(_profileImageButton.frame) / 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)tapProfileImage:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(tapProfileImage:)])
        [_delegate tapProfileImage:self];
}

- (void)setProfileImage:(UIImage *)image placeholderImage:(UIImage *)placeholder {
    if (image)
        [_profileImageButton setImage:image forState:UIControlStateNormal];
    else
        [_profileImageButton setImage:placeholder forState:UIControlStateNormal];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    if (_delegate && [_delegate respondsToSelector:@selector(profileNameDidChange:)])
        [_delegate profileNameDidChange:textView.text];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (_delegate && [_delegate respondsToSelector:@selector(profileNameDidChange:)])
        [_delegate profileNameDidChange:text];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (_delegate && [_delegate respondsToSelector:@selector(profileNameDidReturn)])
        [_delegate profileNameDidReturn];
    
    return NO;
}

@end
