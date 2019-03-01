//
//  ConferenceInvitationUserCell.h
//  ginko
//
//  Created by stepanekdavid on 3/6/17.
//  Copyright © 2017 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ConferenceInvitationUserCell;

@protocol ConferenceInvitationUserCellDelegate <NSObject>

- (void)conferenceGinkoUserCellInvite:(ConferenceInvitationUserCell *)cell;

@end

@interface ConferenceInvitationUserCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *userFullName;
@property (weak, nonatomic) IBOutlet UIButton *inviteBtn;

+ (ConferenceInvitationUserCell *)sharedCell;
@property (nonatomic, weak) id<ConferenceInvitationUserCellDelegate> delegate;


- (IBAction)onInvitation:(id)sender;

@end
