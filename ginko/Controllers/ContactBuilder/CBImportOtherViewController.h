//
//  CBImportOtherViewController.h
//  GINKO
//
//  Created by mobidev on 8/7/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBEmail.h"

@interface CBImportOtherViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, retain) IBOutlet UIView *navView;
@property (nonatomic, assign) IBOutlet UIButton *btnDone;
@property (nonatomic, assign) IBOutlet UIButton *btnDoneFake;
@property (nonatomic, assign) IBOutlet UITextField *txtEmail;
@property (nonatomic, assign) IBOutlet UITextField *txtPassword;
@property (nonatomic, assign) IBOutlet UITextField *txtServerName;
@property (nonatomic, assign) IBOutlet UITextField *txtInserverType;
@property (nonatomic, assign) IBOutlet UITextField *txtInserverPort;
@property (assign, nonatomic) IBOutlet UIScrollView *scvFields;
@property (assign, nonatomic) IBOutlet UIView *vwMain;

@property (nonatomic, assign) IBOutlet UIView *viewBottom;
@property (nonatomic, assign) IBOutlet UIView *viewDescription;

@property (nonatomic, strong) CBEmail *curCBEmail;

- (IBAction)onBack:(id)sender;
- (IBAction)onDone:(id)sender;
- (IBAction)onNext:(id)sender;
- (IBAction)onSkip:(id)sender;

@end
