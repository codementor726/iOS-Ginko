//
//  ConnectGinkoUserCell.m
//  ginko
//
//  Created by STAR on 1/4/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "ConnectGinkoUserCell.h"

@implementation ConnectGinkoUserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _profileImageView.clipsToBounds = YES;
    _profileImageView.contentMode = UIViewContentModeScaleAspectFill;
    _profileImageView.layer.cornerRadius = CGRectGetWidth(_profileImageView.bounds) / 2;
    _profileImageView.layer.borderWidth = 0.5;
    _profileImageView.layer.borderColor = COLOR_PURPLE_THEME.CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)doExchange:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(connectGinkoUserCellDoExchange:)])
        [_delegate connectGinkoUserCellDoExchange:self];
}
- (void)setInviteStatus:(BOOL)pendding {
    if (pendding) {
        _btInContact.hidden = YES;
        _penddingbtn.hidden = NO;
        //[_btInContact setImage:[UIImage imageNamed:@"ginko_pendding_button"] forState:UIControlStateNormal];
    } else {
        _btInContact.hidden = NO;
        _penddingbtn.hidden = YES;
        //[_btInContact setImage:[UIImage imageNamed:@"ginko_connect_icon"] forState:UIControlStateNormal];
    }
}
@end
