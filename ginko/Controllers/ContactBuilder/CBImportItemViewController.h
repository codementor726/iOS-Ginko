//
//  CBImportItemViewController.h
//  GINKO
//
//  Created by mobidev on 8/7/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CBImportItemViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, retain) IBOutlet UIView *navView;
@property (nonatomic, assign) IBOutlet UIButton *btnBack;
@property (nonatomic, assign) IBOutlet UIButton *btnDone;
@property (nonatomic, assign) IBOutlet UIButton *btnDoneFake;
@property (nonatomic, assign) IBOutlet UIImageView *imgIcon;
@property (nonatomic, assign) IBOutlet UILabel *lblInstruction;
@property (nonatomic, assign) IBOutlet UITextField *txtEmail;
@property (nonatomic, assign) IBOutlet UITextField *txtPassword;
@property (nonatomic, assign) IBOutlet UITextField *txtUsername;
@property (nonatomic, assign) IBOutlet UITextField *txtWebmailLink;

@property (nonatomic, assign) IBOutlet UIView *viewBottom;
@property (nonatomic, assign) IBOutlet UIView *viewDescription;

@property (nonatomic) int type;

- (void)goToCBDetail:(NSString *)redirectURL;

- (IBAction)onBack:(id)sender;
- (IBAction)onDone:(id)sender;
- (IBAction)onNext:(id)sender;
- (IBAction)onSkip:(id)sender;

@end
