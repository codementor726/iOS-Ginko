//
//  MenuSettingViewController.h
//  GINKO
//
//  Created by Forever on 6/11/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeactivateCell.h"

@interface MenuSettingViewController : UIViewController <UIActionSheetDelegate, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, DeactivateCellDelegate>
{
    IBOutlet UIView *navView;
    int selIndex;
    IBOutlet UIButton *btnSort;
    IBOutlet UIButton *btnLanguage;
    IBOutlet UITableView *tblReason;

}

- (IBAction)onBack:(id)sender;
- (IBAction)onDeactivate:(id)sender;
- (IBAction)onBtnSort:(id)sender;

@end
