//
//  ConnectNonGinkoUserCell.h
//  ginko
//
//  Created by STAR on 1/4/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ConnectNonGinkoUserCell;

@protocol ConnectNonGinkoUserCellDelegate <NSObject>

- (void)connectNonGinkoUserCellInvite:(ConnectNonGinkoUserCell *)cell;

@end

@interface ConnectNonGinkoUserCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UIButton *inviteButton;

@property (nonatomic, weak) id<ConnectNonGinkoUserCellDelegate> delegate;
- (IBAction)invite:(id)sender;
- (void)setInviteStatus:(BOOL)resend;

@end
