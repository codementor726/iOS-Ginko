//
//  ConnectGinkoUserCell.h
//  ginko
//
//  Created by STAR on 1/4/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ConnectGinkoUserCell;

@protocol ConnectGinkoUserCellDelegate <NSObject>

- (void)connectGinkoUserCellDoExchange:(ConnectGinkoUserCell *)cell;

@end

@interface ConnectGinkoUserCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
- (IBAction)doExchange:(id)sender;

@property (nonatomic, weak) id<ConnectGinkoUserCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *btInContact;
@property (weak, nonatomic) IBOutlet UIButton *penddingbtn;

- (void)setInviteStatus:(BOOL)pendding;
@end
