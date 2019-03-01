//
//  CIImportViewController.h
//  ContactImporter
//
//  Created by mobidev on 6/12/14.
//  Copyright (c) 2014 Ron. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CIImportViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, retain) IBOutlet UIView *navView;
@property (nonatomic, assign) IBOutlet UIImageView *imgIcon;
@property (nonatomic, assign) IBOutlet UILabel *lblInstruction;
@property (nonatomic, assign) IBOutlet UITextField *txtEmail;
@property (nonatomic, assign) IBOutlet UITextField *txtPassword;
@property (nonatomic, assign) IBOutlet UITextField *txtUsername;
@property (nonatomic, assign) IBOutlet UITextField *txtWebmailLink;

@property (nonatomic, assign) IBOutlet UIView *viewBottom;
@property (nonatomic, assign) IBOutlet UIView *viewDescription;
@property (nonatomic, assign) IBOutlet UIButton *btnImport;

@property (nonatomic) int type;

- (void)importContacts:(NSString *)redirectURL; //unuseful
- (void)syncContactByOauth:(NSString *)redirectURL;

- (IBAction)onBack:(id)sender;
- (IBAction)onNext:(id)sender;

- (IBAction)onSkip:(id)sender;

- (IBAction)onImport:(id)sender;

@end
