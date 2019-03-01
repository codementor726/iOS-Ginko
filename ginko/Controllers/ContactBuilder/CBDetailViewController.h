//
//  CBDetailViewController.h
//  GINKO
//
//  Created by mobidev on 5/17/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBEmail.h"

@interface CBDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
{
    NSMutableArray * totalArr;
    NSMutableArray *lstField;
    NSMutableDictionary * homeIdDict;
    NSMutableDictionary * workIdDict;
}
@property (nonatomic, retain) IBOutlet UIView *navView;
@property (nonatomic, assign) IBOutlet UITableView *tblInfo;

@property (nonatomic, assign) IBOutlet UIImageView *imgValid;
@property (nonatomic, assign) IBOutlet UIView *viewOn;
@property (nonatomic, assign) IBOutlet UIView *viewOff;
@property (nonatomic, assign) IBOutlet UIView *viewDel;
@property (nonatomic, assign) IBOutlet UIButton *btnOn;
@property (nonatomic, assign) IBOutlet UIButton *btnOff;
@property (nonatomic, assign) IBOutlet UIButton *btnChatOnly;
@property (nonatomic, assign) IBOutlet UIButton *btnCheck;

@property (nonatomic, assign) IBOutlet UIButton *btnDone;
@property (nonatomic, assign) IBOutlet UIButton *btnDoneFake;
@property (nonatomic, assign) IBOutlet UIView *viewTap;

@property (nonatomic, assign) IBOutlet UILabel *lblTopLine;
@property (nonatomic, assign) IBOutlet UILabel *lblMiddleLine;
@property (nonatomic, assign) IBOutlet UILabel *lblBottomLine;

@property (nonatomic, assign) IBOutlet UILabel *lblEmail;
@property (nonatomic, assign) IBOutlet UILabel *lblOther;
@property (nonatomic, assign) IBOutlet UILabel *lblRevalidateOther;
@property (nonatomic, assign) IBOutlet UIView *viewRevalidate;
@property (nonatomic, assign) IBOutlet UIImageView *imgRevalidate;
@property (nonatomic, assign) IBOutlet UIImageView *imgProvider;

@property (nonatomic, assign) IBOutlet UIView *viewBottom;

@property (nonatomic, retain) CBEmail *curCBEmail;
@property (nonatomic, strong) NSString *oauth_token;
@property (weak, nonatomic) IBOutlet UIButton *trashBut;

- (void)modifyCBEmail:(NSString *)redirectURL;

- (IBAction)onOff:(id)sender;
- (IBAction)onBack:(id)sender;
- (IBAction)onDone:(id)sender;
- (IBAction)onChatOnly:(id)sender;
- (IBAction)onCheck:(id)sender;
- (IBAction)onDelete:(id)sender;
- (IBAction)onRevalidate:(id)sender;

- (IBAction)onSkip:(id)sender;
- (IBAction)onNext:(id)sender;

@end
