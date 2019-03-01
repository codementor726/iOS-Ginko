//
//  LoginSettingViewController.h
//  GINKO
//
//  Created by Forever on 6/11/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginSettingCell.h"

@interface LoginSettingViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, LoginSettingCellDelegate, UITextFieldDelegate, UIAlertViewDelegate>
{
    IBOutlet UIView *navView;
    IBOutlet UITextField *txtFieldEmail;
    IBOutlet UITableView *tblForEmail;
    
    NSMutableArray *arrEmails;
    
    int selIndex;
}

- (IBAction)onBack:(id)sender;
- (IBAction)onAdd:(id)sender;
- (IBAction)onDelete:(id)sender;
- (IBAction)onSendConfirmation:(id)sender;

@end
