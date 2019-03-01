//
//  CBImportOtherViewController.m
//  GINKO
//
//  Created by mobidev on 8/7/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import "CBImportOtherViewController.h"
#import "CBEmail.h"
#import "CBDetailViewController.h"
#import "CBMainViewController.h"
#import "ContactBuilderClient.h"

@interface CBImportOtherViewController ()
{
    CGRect frmOrigin;
}
@end

@implementation CBImportOtherViewController
@synthesize curCBEmail;
@synthesize navView;
@synthesize btnDoneFake, btnDone, txtPassword, txtEmail, txtInserverPort, txtInserverType, txtServerName, viewBottom, viewDescription, vwMain;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    if (_globalData.cbIsFromMenu) {
        [self layoutMenuLink];
    }
    
    //deleted
//    txtServerName.text = @"https://outlook.office365.com/EWS/Exchange.asmx";
//    txtEmail.text = @"ron@worktyme.onmicrosoft.com";
//    txtPassword.text = @"Pentagon1";
    
    if (curCBEmail) {
        txtEmail.text = curCBEmail.email;
        txtEmail.enabled = false;
        txtEmail.borderStyle = UITextBorderStyleNone;
        btnDoneFake.hidden = NO;
        btnDone.hidden = NO;
    }
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
	[self.view addGestureRecognizer:gesture];
}

-(void)handleTap
{
	[self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar addSubview:navView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    frmOrigin = vwMain.frame;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    if (vwMain.frame.origin.y == frmOrigin.origin.y) {
        if (IS_IPHONE_5) {
            vwMain.frame = CGRectMake(vwMain.frame.origin.x, vwMain.frame.origin.y - 20, vwMain.frame.size.width, vwMain.frame.size.height);
        } else {
            vwMain.frame = CGRectMake(vwMain.frame.origin.x, vwMain.frame.origin.y - 80, vwMain.frame.size.width, vwMain.frame.size.height);
        }
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [vwMain setFrame:frmOrigin];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [navView removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)layoutMenuLink
{
    viewBottom.hidden = YES;
    CGRect frame = viewDescription.frame;
    frame.origin.y += 48;
    [viewDescription setFrame:frame];
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == txtEmail) {
        [txtPassword becomeFirstResponder];
    } else if (textField == txtPassword) {
        [txtServerName becomeFirstResponder];
    } else if (textField == txtServerName) {
        [txtInserverType becomeFirstResponder];
    } else if (textField == txtInserverType) {
        [txtInserverPort becomeFirstResponder];
    } else if (textField == txtInserverPort) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (!_globalData.cbIsFromMenu) {
        return YES;
    }
    if (textField != txtEmail) {
        return YES;
    }
    NSString *chagedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([chagedString length]) {
        btnDoneFake.hidden = NO;
        btnDone.hidden = NO;
    } else {
        btnDoneFake.hidden = YES;
        btnDone.hidden = YES;
    }
    return YES;
}

- (void)goToCBDetail
{
    CBEmail *newCBEmail = [[CBEmail alloc] init];
    newCBEmail.email = txtEmail.text;
    newCBEmail.authType = @"password";
    newCBEmail.inserver = txtServerName.text;
    newCBEmail.inservertype = [txtInserverType.text isEqualToString:@""] ? @"POP3" : txtInserverType.text;
    newCBEmail.inserverport = [txtInserverPort.text isEqualToString:@""] ? nil : txtInserverPort.text;
    newCBEmail.password = txtPassword.text;
    if (curCBEmail) {
        curCBEmail.authType = @"password";
        curCBEmail.inserver = txtServerName.text;
        curCBEmail.inservertype = [txtInserverType.text isEqualToString:@""] ? @"POP3" : txtInserverType.text;
        curCBEmail.inserverport = [txtInserverPort.text isEqualToString:@""] ? nil : txtInserverPort.text;
        curCBEmail.password = txtPassword.text;
        [self modifyCBEmail];
        
    } else {
        CBDetailViewController *vc = [[CBDetailViewController alloc] initWithNibName:@"CBDetailViewController" bundle:nil];
        [vc setCurCBEmail:newCBEmail];
        vc.oauth_token = @"other";
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)modifyCBEmail
{
    void (^successed)(id responseObject) = ^(id responseObject) {
        NSDictionary *result = responseObject;
        if ([[result objectForKey:@"success"] boolValue]) {
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:@"Succeeded"];
            NSArray *arrControllers = [self.navigationController viewControllers];
            for (UIViewController *vc in arrControllers) {
                if ([vc isKindOfClass:[CBMainViewController class]]) {
                    [self.navigationController popToViewController:vc animated:YES];
                }
            };
            
        } else {
            NSDictionary *dictError = [result objectForKey:@"err"];
            if (dictError) {
                [SVProgressHUD showErrorWithStatus:[dictError objectForKey:@"errMsg"]];
            } else {
                [SVProgressHUD showErrorWithStatus:@"Failed to connect to server!"];
            }
        }
    };
    
    void (^failure)(NSError* error) = ^(NSError* error) {
        [SVProgressHUD showErrorWithStatus:@"Failed to connect to server!"];
    };
    
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeClear];
    
    [[ContactBuilderClient sharedClient] addOrUpdateCBEmail:[AppDelegate sharedDelegate].sessionId cbID:curCBEmail.cbID email:curCBEmail.email password:curCBEmail.password sharing:curCBEmail.sharing_status sharedHomeFieldIds:curCBEmail.shareHomeFields sharedWorkFieldIds:curCBEmail.shareWorkFields active:curCBEmail.active authType:curCBEmail.authType provider:curCBEmail.provider oauthToken:nil username:curCBEmail.username inserver:curCBEmail.inserver inserverType:curCBEmail.inservertype inserverPort:curCBEmail.inserverport successed:successed failure:failure];
}

#pragma mark - Actions
- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onDone:(id)sender
{
    [self.view endEditing:YES];
    
    if (![CommonMethods checkBlankField:[NSArray arrayWithObjects:txtEmail, txtPassword, txtServerName, txtInserverPort, nil] titles:[NSArray arrayWithObjects:@"Email Adress", @"Password", @"Sever Name", @"Inserver Port", nil]]) {
        return;
    }
    if (![CommonMethods checkEmail:txtEmail]) {
        return;
    }
    
    if ([txtInserverPort.text intValue] == 0) {
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Inserver Port should be number format."];
        return;
    }
    
    [self goToCBDetail];
}

- (IBAction)onNext:(id)sender
{
    [self onDone:nil];
}

- (IBAction)onSkip:(id)sender
{
    [[AppDelegate sharedDelegate] setWizardPage:@"2"];
}

@end
