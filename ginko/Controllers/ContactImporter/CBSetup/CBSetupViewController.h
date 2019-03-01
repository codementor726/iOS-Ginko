//
//  CBSetupViewController.h
//  ContactImporter
//
//  Created by mobidev on 6/12/14.
//  Copyright (c) 2014 Ron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBEmail.h"

@interface CBSetupViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate>
{
    NSMutableArray * totalArr;
    NSMutableArray *lstField;
    NSMutableDictionary * homeIdDict;
    NSMutableDictionary * workIdDict;
}

@property (nonatomic) int validType; // 0: valide success 1: another types of email 2: no valid cridential
@property (nonatomic, strong) NSString *strEmail;
@property (nonatomic, strong) NSString *strPass;

@property (nonatomic, retain) IBOutlet UIView *navView;
@property (nonatomic, assign) IBOutlet UITableView *tblInfo;

@property (nonatomic, assign) IBOutlet UIView *viewOn;
@property (nonatomic, assign) IBOutlet UIView *viewOff;
@property (nonatomic, assign) IBOutlet UIButton *btnOn;
@property (nonatomic, assign) IBOutlet UIButton *btnOff;
@property (nonatomic, assign) IBOutlet UITextField *txtEmail;
@property (nonatomic, assign) IBOutlet UITextField *txtPass;
@property (nonatomic, assign) IBOutlet UIButton *btnChatOnly;
@property (nonatomic, assign) IBOutlet UIButton *btnCheck;

@property (nonatomic, assign) IBOutlet UIButton *btnNext;
@property (nonatomic, assign) IBOutlet UIButton *btnSkip;
@property (nonatomic, assign) IBOutlet UIView *viewTap;

@property (nonatomic, assign) IBOutlet UILabel *lblTopLine;
@property (nonatomic, assign) IBOutlet UILabel *lblMiddleLine;
@property (nonatomic, assign) IBOutlet UILabel *lblBottomLine;

@property (nonatomic, assign) IBOutlet UIImageView *imgAm;

- (IBAction)onOff:(id)sender;
- (IBAction)onBack:(id)sender;
- (IBAction)onChatOnly:(id)sender;
- (IBAction)onCheck:(id)sender;
- (IBAction)onNext:(id)sender;
- (IBAction)onSkip:(id)sender;

- (void)configureUI;

@end
