//
//  YYYLoginViewController.m
//  XChangeWithMe
//
//  Created by Wang MeiHua on 5/21/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import "YYYLoginViewController.h"
#import "YYYForgotViewController.h"

#import "YYYCommunication.h"
#import "MBProgressHUD.h"
#import "OpenUDID.h"
#import "AppDelegate.h"

#import "Communication.h" //Wang class interrupt
#import "ContactViewController.h" //Wang class interrupt
#import "SetupLocationer.h"   //Wang class interrupt

#import "YYYActivateViewController.h"

#import "LocalDBManager.h"

@interface YYYLoginViewController ()
{

}

@end


@implementation YYYLoginViewController

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
	
	[self setupUI];
    
    [self.navigationController.navigationBar setTranslucent:YES];
    
    showKeyboard = NO;
    
	UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
	[scrView addGestureRecognizer:gesture];
		
#ifdef DEVENV
    txtPassword.text = @"123456";
    txtEmail.text = @"bb105@bb.com";
    txtPassword.text = @"aaaaaa";
    txtEmail.text = @"a@a.com";
//    txtPassword.text = @"Great123";
//    txtEmail.text = @"q1@mailinator.com";
//    txtEmail.text = @"b@b.com";
    
//    txtEmail.text = @"cosi@cosi.com";
    txtEmail.text = @"tom@tom.com";
    txtPassword.text = @"123456";
//    txtEmail.text = @"liujie.king.1023@hotmail.com";
//    txtPassword.text = @"jellastar1023";
    txtEmail.text = @"onedaywillsuccess@gmail.com";
    txtPassword.text = @"Scar19920210";
    //ginkomarketing@gmail.com
    //Yzerman19
#endif
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
-(void)handleTap
{
    if (showKeyboard)
    {
        [self.view endEditing:YES];
        [scrView setContentSize:CGSizeMake(0, 0)];
        showKeyboard = NO;
    }
}
- (void)keyboardWasShown:(NSNotification*)aNotification {
    if (!showKeyboard)
    {
        showKeyboard = YES;
        [scrView setContentSize:CGSizeMake(320, scrView.frame.size.height + 216.0f)];
        if (IS_IPHONE_5) {
            [scrView setContentOffset:CGPointMake(0, 110) animated:YES];
        } else [scrView setContentOffset:CGPointMake(0, 160) animated:YES];
        
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    if (showKeyboard)
    {
        [self.view endEditing:YES];
        [scrView setContentSize:CGSizeMake(0, 0)];
        showKeyboard = NO;
    }
}
-(void)setupUI
{
	[self.navigationItem setTitle:@"Login"];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    // self.navigationController.navigationBar.tintColor = [UIColor blackColor];
	
//	UIButton *btBack = [UIButton buttonWithType:UIButtonTypeCustom];
//	[btBack setImage:[UIImage imageNamed:@"img_bt_back"] forState:UIControlStateNormal];
//	[btBack setFrame:CGRectMake(0, 0, 60, 30)];
//	[btBack addTarget:self action:@selector(btBackClick:) forControlEvents:UIControlEventTouchUpInside];
//	
//	UIBarButtonItem *btBarBack = [[UIBarButtonItem alloc] initWithCustomView:btBack];
//	[self.navigationItem setLeftBarButtonItem:btBarBack];
	
    btLogin = [UIButton buttonWithType:UIButtonTypeCustom];
	[btLogin setFrame:CGRectMake(0, 0, 60, 30)];
	[btLogin setTitle:@"Login" forState:UIControlStateNormal];
	[btLogin setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[btLogin addTarget:self action:@selector(btLoginClick:) forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *btBarLogin = [[UIBarButtonItem alloc] initWithCustomView:btLogin];
	[self.navigationItem setRightBarButtonItem:btBarLogin];
    
    NSAttributedString *attrForEmail = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    NSAttributedString *attrForPassword = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    
    txtEmail.attributedPlaceholder = attrForEmail;
    txtPassword.attributedPlaceholder = attrForPassword;
}

//wang class interrupt end

-(IBAction)btBackClick:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)btLoginClick:(id)sender
{
    NSString *encodeEmail = [txtEmail.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    encodeEmail = [encodeEmail stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
	if (!txtEmail.text.length)
	{
		[self showAlert:@"Please input your Email Address" :@"Input Error"];
		return;
	}
	if (!txtPassword.text.length)
	{
		[self showAlert:@"Please input Password" :@"Input Error"];
		return;
	}
    [self.view endEditing:YES];
    [scrView setContentSize:CGSizeMake(0, 0)];
    showKeyboard = NO;
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
	
	void ( ^successed )( id _responseObject ) = ^( id _responseObject )
	{
		[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
		
		if ([[_responseObject objectForKey:@"success"] boolValue])
		{
            _globalData.scbEmail = encodeEmail;
			[AppDelegate sharedDelegate].sessionId	= [[_responseObject objectForKey:@"data"] objectForKey:@"sessionId"];
			[AppDelegate sharedDelegate].userId		= [[_responseObject objectForKey:@"data"] objectForKey:@"user_id"];
            [AppDelegate sharedDelegate].firstName	= [[_responseObject objectForKey:@"data"] objectForKey:@"first_name"];
            [AppDelegate sharedDelegate].lastName = [[_responseObject objectForKey:@"data"] objectForKey:@"last_name"];
            [AppDelegate sharedDelegate].userName = _responseObject[@"data"][@"user_name"];
            [AppDelegate sharedDelegate].photoUrl = _responseObject[@"data"][@"photo_url"];
            [AppDelegate sharedDelegate].gpsFilterType = [_responseObject[@"data"][@"gps_filter_type"] integerValue];
            [AppDelegate sharedDelegate].syncTimeStamp = [[_responseObject objectForKey:@"data"] objectForKey:@"sync_timestamp"];
            [AppDelegate sharedDelegate].qrCode = [[_responseObject objectForKey:@"data"] objectForKey:@"qrcode"];
            [AppDelegate sharedDelegate].phoneVerified = [[[_responseObject objectForKey:@"data"] objectForKey:@"phone_verified"] boolValue];
            
            //deleted
//			[[AppDelegate sharedDelegate] goToSetupCB];
//            return;
            //wang class interrupt
            SetupLocationer *locationer = [[SetupLocationer alloc] init];
            [locationer configAfterSignIn:_responseObject];
            //wang class interrupt end
            
            [AppDelegate sharedDelegate].deactiveForAccount = NO;
		}
		else
		{
            if (_responseObject && _responseObject[@"err"] && _responseObject[@"err"][@"errMsg"])
                [self showAlert:_responseObject[@"err"][@"errMsg"] :@"Login Error"];
            else
                [self showAlert:@"Email or password may be incorrect. Check them and try again." :@"Login Error"];
		}
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
	{
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        [ self  showAlert: @"No Internet Connection." :@"Oops!"] ;
		
    } ;
    
	if (![AppDelegate sharedDelegate].strDeviceToken)
	{
		[AppDelegate sharedDelegate].strDeviceToken = @"11111111111111";
	}
    
    NSLog(@"token = %@", [AppDelegate sharedDelegate].strDeviceToken);
	
	[[YYYCommunication sharedManager] UserLogin:encodeEmail
									   password:txtPassword.text
										   udid:[OpenUDID value]
										  token:[AppDelegate sharedDelegate].strDeviceToken
                                      voipToken:APPDELEGATE.voIPDeviceToken
									  successed:successed
										failure:failure];
}

-(IBAction)btForgotClick:(id)sender
{
	YYYForgotViewController *viewcontroller = [[YYYForgotViewController alloc] initWithNibName:@"YYYForgotViewController" bundle:nil];
	[self.navigationController pushViewController:viewcontroller animated:YES];
}

-(IBAction)btFBLoginClick:(id)sender
{
//	NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location",@"email"];
//    
//    // Login PFUser using facebook
//    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
//        [MBProgressHUD hideAllHUDsForView:self.view animated:YES]; // Hide loading indicator
//        
//        [AppDelegate sharedDelegate].facebookAccessToke = [FBSession activeSession].accessTokenData.accessToken;
//        
//        if (!user) {
//            if (!error) {
//                NSLog(@"Uh oh. The user cancelled the Facebook login.");
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Uh oh. The user cancelled the Facebook login." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
//                [alert show];
//            } else {
//                NSLog(@"Uh oh. An error occurred: %@", error);
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"We tried to connect with your Facebook account but Facebook doesn't allow Ginko to access. Please make sure your Facebook allows access from Ginko." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
//                [alert show];
////                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:error.localizedDescription delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
////                [alert show];
//            }
//        }
//		else if (user.isNew)
//		{
//			FBRequest *request = [FBRequest requestForMe];
//			[MBProgressHUD showHUDAddedTo:self.view animated:YES];
//			
//			// Send request to Facebook
//			[request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
//			{
//				[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//				
//				if (!error) {
//					// result is a dictionary with the user's Facebook data
//					NSDictionary *userData = (NSDictionary *)result;
//					[self loginByOpenID:userData];
//				}
//				else
//				{
//					[ self  showAlert: @"An unknown error occurred" :@"Oops!"] ;
//				}
//			}];
//		}
//		else
//		{
//			FBRequest *request = [FBRequest requestForMe];
//			[MBProgressHUD showHUDAddedTo:self.view animated:YES];
//			
//			// Send request to Facebook
//			[request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
//			{
//				[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//				
//				if (!error) {
//					// result is a dictionary with the user's Facebook data
//					NSDictionary *userData = (NSDictionary *)result;
//					[self loginByOpenID:userData];
//				}
//				else
//				{
//					[ self  showAlert: @"An unknown error occurred" :@"Oops!"] ;
//				}
//			}];
//		}
//    }];
//    
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

-(void)loginByOpenID:(NSDictionary*)user
{
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
	
	void ( ^successed )( id _responseObject ) = ^( id _responseObject )
	{
		[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
		
		if ([[_responseObject objectForKey:@"success"] boolValue])
		{
			[AppDelegate sharedDelegate].sessionId	= [[_responseObject objectForKey:@"data"] objectForKey:@"sessionId"];
            id userId = [[_responseObject objectForKey:@"data"] objectForKey:@"user_id"];
            if ([userId isKindOfClass:[NSString class]])
                userId = [NSNumber numberWithInteger:[userId integerValue]];
			[AppDelegate sharedDelegate].userId		= [[_responseObject objectForKey:@"data"] objectForKey:@"user_id"];
            [AppDelegate sharedDelegate].firstName	= [[_responseObject objectForKey:@"data"] objectForKey:@"first_name"];
            [AppDelegate sharedDelegate].lastName = [[_responseObject objectForKey:@"data"] objectForKey:@"last_name"];
            [AppDelegate sharedDelegate].photoUrl = _responseObject[@"data"][@"photo_url"];
			[AppDelegate sharedDelegate].qrCode = [[_responseObject objectForKey:@"data"] objectForKey:@"qrcode"];
            
//			[[AppDelegate sharedDelegate] goToSetup];
            //wang class interrupt
            SetupLocationer *locationer = [[SetupLocationer alloc] init];
            [locationer configAfterSignIn:_responseObject];
            //wang class interrupt end
		} else {
            NSDictionary *dictError = [_responseObject objectForKey:@"err"];
            if (dictError) {
                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:[dictError objectForKey:@"errMsg"]];
            } else {
                [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Failed to connect to server!"];
            }
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
	{
		
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        [ self  showAlert: @"No Internet Connection." :@"Oops!"] ;
		
    } ;
    
	if (![AppDelegate sharedDelegate].strDeviceToken)
	{
		[AppDelegate sharedDelegate].strDeviceToken = @"11111111111111";
	}
	
	[[YYYCommunication sharedManager] UserLoginOpenID:[user objectForKey:@"email"]
                                                 code:[AppDelegate sharedDelegate].facebookAccessToke
										   clienttype:@"2"
												 udid:[OpenUDID value]
												token:[AppDelegate sharedDelegate].strDeviceToken
											successed:successed
											  failure:failure];
}

-(void)showAlert:(NSString*)msg :(NSString*)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}
/*
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (!showKeyboard)
    {
        showKeyboard = YES;
        [scrView setContentSize:CGSizeMake(320, scrView.frame.size.height + 216.0f)];
        [scrView setContentOffset:CGPointMake(0, 130) animated:YES];
    }
    
    return YES;
}*/



-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
	[super viewWillAppear:animated];
    
    [self.view endEditing:YES];
    [scrView setContentSize:CGSizeMake(0, 0)];
    showKeyboard = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [scrView setContentSize:CGSizeMake(320, scrView.frame.size.height + 216.0f)];
    if (IS_IPHONE_5) {
        [scrView setContentOffset:CGPointMake(0, 110) animated:YES];
    } else [scrView setContentOffset:CGPointMake(0, 160) animated:YES];
    
    if (textField == txtEmail)
    {
        [txtPassword becomeFirstResponder];
    } else {
        //        showKeyboard = NO;
        //        [scrView setContentSize:CGSizeMake(0, 0)];
        //        [textField resignFirstResponder];
        [self btLoginClick:nil];
    }
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [scrView setContentSize:CGSizeMake(320, scrView.frame.size.height + 216.0f)];
    if (IS_IPHONE_5) {
        [scrView setContentOffset:CGPointMake(0, 110) animated:YES];
    } else [scrView setContentOffset:CGPointMake(0, 160) animated:YES];
    return YES;
}
@end
