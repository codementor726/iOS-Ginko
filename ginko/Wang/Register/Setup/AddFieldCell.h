//
//  AddFieldCell.h
//  ginko
//
//  Created by STAR on 15/12/27.
//  Copyright © 2015年 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddFieldCellDelegate <NSObject>

- (void)didAddField:(NSString *)fieldName;

@end

@interface AddFieldCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UILabel *fieldLabel;
@property (weak, nonatomic) IBOutlet UIView *badgeView;
@property (weak, nonatomic) IBOutlet UILabel *badgeLabel;

- (void)setBadgeCount:(int)badgeCount;
- (IBAction)addField:(id)sender;

@property (weak, nonatomic) id<AddFieldCellDelegate> delegate;
@end
