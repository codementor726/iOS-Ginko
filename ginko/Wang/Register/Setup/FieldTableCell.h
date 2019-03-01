//
//  FieldTableCell.h
//  ginko
//
//  Created by STAR on 15/12/23.
//  Copyright © 2015年 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FieldTableCell;

@protocol FieldTableCellDelegate <NSObject>

- (void)fieldTableCellDeleteField:(FieldTableCell *)cell;
- (void)fieldTableCell:(FieldTableCell *)cell textDidChange:(NSString *)text;
- (void)fieldTableCellTextFieldDidReturn:(FieldTableCell *)cell;
- (void)fieldTableCellTextFieldShouldBeginEditing:(FieldTableCell *)cell;
- (void)fieldtableCellTextfieldShouldEndEditing:(FieldTableCell *)cell;
- (void)fieldTableCellTextFieldDidBeginEditing:(FieldTableCell *)cell;
@end

@interface FieldTableCell : UITableViewCell <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomHeight;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
- (IBAction)deleteField:(id)sender;

@property (weak, nonatomic) id<FieldTableCellDelegate> delegate;
@end
