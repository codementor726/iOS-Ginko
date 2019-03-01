//
//  GroupCollectionViewCell.h
//  ginko
//
//  Created by stepanekdavid on 3/19/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GroupCollectionViewCellDelegate
@optional;
- (void)deleteCurrentGroup:(NSString *)_groupId type:(NSInteger)_type;
@end

@interface GroupCollectionViewCell : UICollectionViewCell<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *groupImg;
@property (weak, nonatomic) IBOutlet UIView *borderView;

@property (weak, nonatomic) IBOutlet UIView *groupCellsView;
@property (weak, nonatomic) IBOutlet UIImageView *groupCellsImg;
@property (weak, nonatomic) IBOutlet UILabel *countOfGroup;

@property (weak, nonatomic) IBOutlet UIView *deleteView;
@property (weak, nonatomic) IBOutlet UIButton *btRemoveGroup;

@property (weak, nonatomic) IBOutlet UILabel *groupName;


@property (nonatomic, retain) NSString *GroupId;
@property (nonatomic, retain) NSDictionary *GroupInfo;
@property (nonatomic, retain) id<GroupCollectionViewCellDelegate> delegate;

- (IBAction)onRemoveGroup:(id)sender;
@end
