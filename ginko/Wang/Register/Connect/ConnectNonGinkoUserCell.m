//
//  ConnectNonGinkoUserCell.m
//  ginko
//
//  Created by STAR on 1/4/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "ConnectNonGinkoUserCell.h"

@implementation ConnectNonGinkoUserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)invite:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(connectNonGinkoUserCellInvite:)])
        [_delegate connectNonGinkoUserCellInvite:self];
}

- (void)setInviteStatus:(BOOL)resend {
    if (resend) {
        [_inviteButton setImage:[UIImage imageNamed:@"ginko_resend_invite_button"] forState:UIControlStateNormal];
    } else {
        [_inviteButton setImage:[UIImage imageNamed:@"ginko_invite_button"] forState:UIControlStateNormal];
    }
}

@end
