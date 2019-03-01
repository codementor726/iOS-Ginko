//
//  DeactivateCell.h
//  ginko
//
//  Created by Lion on 6/8/15.
//  Copyright (c) 2015 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DeactivateCellDelegate

@optional;
- (void)selectReason:(NSDictionary*)dict index:(NSInteger)index;

@end

@interface DeactivateCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIButton *btnReason;
@property (strong, nonatomic) IBOutlet UILabel *lblReason;

@property (nonatomic, strong) NSDictionary *dictReason;
@property (nonatomic) NSInteger curIndex;
@property (nonatomic) BOOL isReasonSelected;
@property (nonatomic, retain) id<DeactivateCellDelegate> delegate;

+ (DeactivateCell *)sharedCell;
- (IBAction)onReason:(id)sender;

@end
