//
//  ManageProfileViewController.h
//  ginko
//
//  Created by STAR on 15/12/23.
//  Copyright © 2015年 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ProfileModePersonal,
    ProfileModeWork,
    ProfileModeBoth
} ProfileMode;

@interface ManageProfileViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *fieldTable;

@property (weak, nonatomic) IBOutlet UILabel *lockNoticeLabel;

@property (weak, nonatomic) IBOutlet UIButton *lockButton;

@property (weak, nonatomic) IBOutlet UIButton *addFieldButton;

@property (weak, nonatomic) IBOutlet UIButton *addFieldButton2;

@property (weak, nonatomic) IBOutlet UIView *addFieldView;

@property (weak, nonatomic) IBOutlet UITableView *addFieldTable;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpacing;

- (IBAction)addField:(id)sender;

- (IBAction)hideAddFieldView:(id)sender;

- (IBAction)doLockOrUnlock:(id)sender;

// set from outside
@property (nonatomic, assign) BOOL isCreate;        // 1 for create new, 0 for edit existing

@property (nonatomic, assign) ProfileMode mode;   // 0: create personal, 1: create work, 2: create both

@property (nonatomic, assign) BOOL isWork;          // 0: personal, 1: work

@property (nonatomic, assign) BOOL isSelected;

@property (nonatomic, assign) BOOL isSecond;        // 0: first in both or only one, 1: one profile is created and creating another

@property (nonatomic, strong) NSDictionary *userData;

@property (nonatomic, assign) BOOL isSetup;         // for preview profile vc

@end
