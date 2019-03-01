//
//  PasswordViewController.m
//  GINKO
//
//  Created by Forever on 6/3/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import "PasswordViewController.h"

@interface PasswordViewController ()

@end

@implementation PasswordViewController

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
    // Do any additional setup after loading the view from its nib.
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnView)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.delegate = self;
    [scrView addGestureRecognizer:tapGesture];
    
    originalHeight = scrView.frame.size.height;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [navView removeFromSuperview];
}

- (void)tapOnView
{
    [scrView setContentSize:CGSizeMake(scrView.frame.size.width, originalHeight)];
    
    [txtFieldCurPass resignFirstResponder];
    [txtFieldNewPass resignFirstResponder];
    [txtFieldConfirmPass resignFirstResponder];
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    UIView *hitView = [gestureRecognizer.view hitTest:[gestureRecognizer locationInView:gestureRecognizer.view] withEvent:nil];
    return [hitView isKindOfClass:[UIScrollView class]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar addSubview:navView];
    // self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:230.0/256.0 green:1.0f blue:190.0/256.0 alpha:1.0f];
    [self.navigationItem setHidesBackButton:YES animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onChange:(id)sender
{
    
    [scrView setContentSize:CGSizeMake(scrView.frame.size.width, originalHeight)];
    
    [txtFieldCurPass resignFirstResponder];
    [txtFieldNewPass resignFirstResponder];
    [txtFieldConfirmPass resignFirstResponder];
    if (txtFieldNewPass.text.length < 6 && txtFieldNewPass.text.length != 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Input Error" message:@"Password should have at least 6 characters" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if ([[txtFieldCurPass.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] || [[txtFieldNewPass.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] || [[txtFieldConfirmPass.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"Oops!  All fields must be completed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
    else if ([txtFieldNewPass.text isEqualToString:txtFieldConfirmPass.text])
        [self ChangePassword:txtFieldCurPass.text newPwd:txtFieldNewPass.text];
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"Oops!  New passwords do not match. Please re-enter." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [scrView setContentSize:CGSizeMake(scrView.frame.size.width, scrView.frame.size.height + 150)];
    if (textField == txtFieldCurPass) {
        txtFieldCurPass.text = @"";
    } else if (textField == txtFieldNewPass) {
        txtFieldNewPass.text = @"";
    } else if (textField == txtFieldConfirmPass) {
        txtFieldConfirmPass.text = @"";
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == txtFieldCurPass) {
        [txtFieldNewPass becomeFirstResponder];
    } else if (textField == txtFieldNewPass) {
        [txtFieldConfirmPass becomeFirstResponder];
    } else if (textField == txtFieldConfirmPass) {
        [txtFieldConfirmPass resignFirstResponder];
        [self onChange:nil];
    }
    return YES;
}

- (void)ChangePassword : (NSString *)_curPwd
                    newPwd: (NSString *)_newPwd
{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        NSLog(@"%@",_responseObject);
		if ([[_responseObject objectForKey:@"success"] boolValue])
		{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"Password successfully changed!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            alertView.tag = 100;
            [alertView show];
        }
        else
        {
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:[[_responseObject objectForKey:@"err"] objectForKey:@"errMsg" ] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"Oops!  Current password does not match our records. Please re-enter." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        NSLog(@"Connection failed - %@", _error);
    } ;
    
    [[Communication sharedManager] ChangePwd:[AppDelegate sharedDelegate].sessionId curPwd:_curPwd newPwd:_newPwd successed:successed failure:failure];
}

#pragma mark - UIAelrtView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
