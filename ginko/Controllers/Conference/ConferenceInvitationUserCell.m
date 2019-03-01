//
//  ConferenceInvitationUserCell.m
//  ginko
//
//  Created by stepanekdavid on 3/6/17.
//  Copyright © 2017 com.xchangewithme. All rights reserved.
//

#import "ConferenceInvitationUserCell.h"

@implementation ConferenceInvitationUserCell
+ (ConferenceInvitationUserCell *)sharedCell
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"ConferenceInvitationUserCell" owner:nil options:nil];
    ConferenceInvitationUserCell *cell = [array objectAtIndex:0];
    
    return cell;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onInvitation:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(conferenceGinkoUserCellInvite:)])
        [_delegate conferenceGinkoUserCellInvite:self];
}
@end
