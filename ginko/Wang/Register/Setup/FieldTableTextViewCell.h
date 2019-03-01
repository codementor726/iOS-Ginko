//
//  FieldTableTextViewCell.h
//  ginko
//
//  Created by STAR on 15/12/29.
//  Copyright © 2015年 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SAMTextView.h>

@class FieldTableTextViewCell;

@protocol FieldTableTextViewCellDelegate <NSObject>

- (void)fieldTableTextViewCellDeleteField:(FieldTableTextViewCell *)cell;
- (void)fieldTableTextViewCell:(FieldTableTextViewCell *)cell textDidChange:(NSString *)text;
@end

@interface FieldTableTextViewCell : UITableViewCell <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomHeight;
@property (weak, nonatomic) IBOutlet SAMTextView *textView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
- (IBAction)deleteField:(id)sender;

@property (weak, nonatomic) id<FieldTableTextViewCellDelegate> delegate;
@end
