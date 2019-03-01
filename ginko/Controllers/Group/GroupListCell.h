//
//  GroupListCell.h
//  ginko
//
//  Created by STAR on 7/16/15.
//  Copyright (c) 2015 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GroupListCellDelegate <NSObject>

- (void)didTapChatButton:(id)sender;

@end

@interface GroupListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) id<GroupListCellDelegate> delegate;
- (IBAction)chat:(id)sender;
@end
