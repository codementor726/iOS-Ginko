//
//  GroupListCell.m
//  ginko
//
//  Created by STAR on 7/16/15.
//  Copyright (c) 2015 com.xchangewithme. All rights reserved.
//

#import "GroupListCell.h"

@implementation GroupListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)chat:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(didTapChatButton:)]) {
        [_delegate didTapChatButton:self];
    }
}
@end
