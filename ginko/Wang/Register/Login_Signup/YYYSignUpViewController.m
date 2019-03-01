//
//  YYYSignUpViewController.m
//  XChangeWithMe
//
//  Created by Wang MeiHua on 5/21/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import "YYYSignUpViewController.h"
#import "YYYActivateViewController.h"
#import "YYYConfirmViewController.h"
#import "YYYLoginViewController.h"
#import "SetupViewController.h"

#import "YYYCommunication.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h" //Wang Class modify
#import "OpenUDID.h"

#import "SetupLocationer.h"   //Wang class interrupt

@interface YYYSignUpViewController () <TTTAttributedLabelDelegate>

@end

@implementation YYYSignUpViewController

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
	
//	[txtEmail		setText:@"supermobile828@gmail.com"];
//	[txtName		setText:@"WangTest"];
//	[txtPassword	setText:@"superdev828"];
#ifdef DEVENV
    [txtEmail		setText:@"fff@fff.com"];
    [txtName		setText:@"fff"];
    [txtPassword	setText:@"a"];
#endif
    
	txtEmail.delegate = self;
	txtName.delegate = self;
	txtPassword.delegate = self;
	
	UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
	[scrView addGestureRecognizer:gesture];
	
    // Do any additional setup after loading the view from its nib.
    // Back button
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    // Set attributed properties for desc label
    _descLabel.font = [UIFont systemFontOfSize:11];
    _descLabel.textColor = [UIColor whiteColor];
    _descLabel.delegate = self;
    _descLabel.longPressGestureRecognizer.enabled = NO;
    _descLabel.linkAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Medium" size:11], (NSString *)kCTForegroundColorAttributeName:[UIColor whiteColor], (NSString *)kCTUnderlineStyleAttributeName:@(kCTUnderlineStyleSingle)};
    _descLabel.activeLinkAttributes = @{(NSString *)kCTForegroundColorAttributeName:[UIColor colorWithWhite:1 alpha:0.5]};
    NSString *descText = @"By joining you agree to our Terms and Privacy Policy";
    NSRange termRange = [descText rangeOfString:@"Terms" options:NSCaseInsensitiveSearch];
    NSRange privacyRange = [descText rangeOfString:@"Privacy Policy" options:NSCaseInsensitiveSearch];
    [_descLabel setText:descText];
    // add hyperlinks
    [_descLabel addLinkToURL:[NSURL URLWithString:@"http://www.ginko.mobi/terms"] withRange:termRange];
    [_descLabel addLinkToURL:[NSURL URLWithString:@"http://www.ginko.mobi/privacypolicy"] withRange:privacyRange];
    _descLabel.extendsLinkTouchArea = YES;
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

-(void)setupUI
{
	[self.navigationItem setTitle:@"SignUp"];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    // self.navigationController.navigationBar.tintColor = [UIColor blackColor];
	
    //	UIButton *btBack = [UIButton buttonWithType:UIButtonTypeCustom];
    //	[btBack setImage:[UIImage imageNamed:@"img_bt_back"] forState:UIControlStateNormal];
    //	[btBack setFrame:CGRectMake(0, 0, 60, 30)];
    //	[btBack addTarget:self action:@selector(btBackClick:) forControlEvents:UIControlEventTouchUpInside];
    //
    //	UIBarButtonItem *btBarBack = [[UIBarButtonItem alloc] initWithCustomView:btBack];
    //	[self.navigationItem setLeftBarButtonItem:btBarBack];
	
    UIButton *btLogin;
    
    btLogin = [UIButton buttonWithType:UIButtonTypeCustom];
	[btLogin setFrame:CGRectMake(0, 0, 60, 30)];
	[btLogin setTitle:@"Signup" forState:UIControlStateNormal];
	[btLogin setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[btLogin addTarget:self action:@selector(btAgreeClick:) forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *btBarLogin = [[UIBarButtonItem alloc] initWithCustomView:btLogin];
	[self.navigationItem setRightBarButtonItem:btBarLogin];
    
    NSAttributedString *attrForName = [[NSAttributedString alloc] initWithString:@"Name" attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    NSAttributedString *attrForEmail = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    NSAttributedString *attrForPassword = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    
    txtName.attributedPlaceholder = attrForName;
    txtEmail.attributedPlaceholder = attrForEmail;
    txtPassword.attributedPlaceholder = attrForPassword;
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
/*
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (!showKeyboard)
    {
        showKeyboard = YES;
        [scrView setContentSize:CGSizeMake(320, scrView.frame.size.height + 216.0f)];
        if (IS_IPHONE_5) {
            [scrView setContentOffset:CGPointMake(0, 110) animated:YES];
        } else [scrView setContentOffset:CGPointMake(0, 160) animated:YES];
        
    }
    
    return YES;
}*/

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [scrView setContentSize:CGSizeMake(320, scrView.frame.size.height + 216.0f)];
    if (IS_IPHONE_5) {
        [scrView setContentOffset:CGPointMake(0, 110) animated:YES];
    } else [scrView setContentOffset:CGPointMake(0, 160) animated:YES];
    
	if (textField == txtEmail)
	{
		[txtPassword becomeFirstResponder];
	}
	else if (textField == txtName)
	{
		[txtEmail becomeFirstResponder];
	} else {
//        showKeyboard = NO;
//        [scrView setContentSize:CGSizeMake(0, 0)];
        [self btAgreeClick:nil];
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
-(void)handleTap
{
	if (showKeyboard)
    {
        [self.view endEditing:YES];
        [scrView setContentSize:CGSizeMake(0, 0)];
        showKeyboard = NO;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (BOOL)checkEmail:(UITextField *)checkText
{
    BOOL filter = YES ;
    NSString *filterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = filter ? filterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    if([emailTest evaluateWithObject:checkText.text] == NO)
    {
        [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Please enter a valid email address."];
        return NO ;
    }
    
    return YES ;
}

-(IBAction)btAgreeClick:(id)sender
{
    NSString *encodeName = [txtName.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	if (!encodeName.length)
	{
		[self showAlert:@"Please input Name" :@"Input Error" :nil];
		return;
	}
	if (!txtEmail.text.length)
	{
		[self showAlert:@"Please input your Email Address" :@"Input Error" :nil];
		return;
	}
#ifndef DEVENV
	if (txtPassword.text.length < 6)
	{
        [self showAlert:@"Password should have at least 6 characters" :@"Input Error" :nil];
		return;
	}
#endif
    if ([txtEmail.text rangeOfString:@" "].length != 0) {
        [self showAlert:@"Email field contains space. Please input again" :@"Input Error" :nil];
        return;
    }
	
    if (![CommonMethods checkEmail:txtEmail]) {
        return;
    }
    [self.view endEditing:YES];
    NSString *strLastName = @"";
	
	if ([[encodeName componentsSeparatedByString:@" "] count] >= 3 )
	{
		[self showAlert:@"Please input first name and last name" :@"Oops!" :nil];
		return;
	}
	
	if ([encodeName rangeOfString:@" "].location != NSNotFound)
	{
		encodeName = [encodeName substringToIndex:[encodeName rangeOfString:@" "].location];
		strLastName = [encodeName substringFromIndex:[encodeName rangeOfString:@" "].location + 1];
	}
    
	[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	
	void ( ^successed )( id _responseObject ) = ^( id _responseObject )
	{
		[MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        NSLog(@"%@", _responseObject);
		
		if ([[_responseObject objectForKey:@"success"] boolValue])
		{
            //wang class interrupt
            _globalData.scbEmail = txtEmail.text;
            _globalData.scbPassword = txtPassword.text;
            _globalData.scbValidType = [[[_responseObject objectForKey:@"data"] objectForKey:@"status_code"] intValue];
            [AppDelegate sharedDelegate].qrCode = [[_responseObject objectForKey:@"data"] objectForKey:@"qrcode"];
            //wang class interrupt end
			if([[[_responseObject objectForKey:@"data"] objectForKey:@"status_code"] intValue] == 0)//initial signup
			{
				[self getContactInfo:[[_responseObject objectForKey:@"data"] objectForKey:@"sessionId"] :[[_responseObject objectForKey:@"data"] objectForKey:@"user_id"]];
			}
			else if([[[_responseObject objectForKey:@"data"] objectForKey:@"status_code"] intValue] == 1)
			{
				YYYActivateViewController *viewcontroller = [[YYYActivateViewController alloc] initWithNibName:@"YYYActivateViewController" bundle:nil];
				viewcontroller.email = txtEmail.text;
				[self.navigationController pushViewController:viewcontroller animated:YES];
			}
			else if([[[_responseObject objectForKey:@"data"] objectForKey:@"status_code"] intValue] == 2)
			{
				YYYConfirmViewController *viewcontroller = [[YYYConfirmViewController alloc] initWithNibName:@"YYYConfirmViewController" bundle:nil];
				viewcontroller.name = encodeName;
				viewcontroller.email = txtEmail.text;
				viewcontroller.lname = strLastName;
				[self.navigationController pushViewController:viewcontroller animated:YES];
			}
			else
			{
				[ self  showAlert: @"No Internet Connection" :@"Oops!" :nil] ;
			}
		}
		else
		{
			if([[[_responseObject objectForKey:@"err"] objectForKey:@"errCode"] intValue] == 109)
			{
				[ self  showAlert: @"Email already registered, please login." :@"Sign Up" :self] ;
			}
			else if([[[_responseObject objectForKey:@"err"] objectForKey:@"errCode"] intValue] == 127)
			{
				YYYConfirmViewController *viewcontroller = [[YYYConfirmViewController alloc] initWithNibName:@"YYYConfirmViewController" bundle:nil];
				viewcontroller.name = encodeName;
				viewcontroller.email = txtEmail.text;
				viewcontroller.lname = strLastName;
				[self.navigationController pushViewController:viewcontroller animated:YES];
			}
			else if([[[_responseObject objectForKey:@"err"] objectForKey:@"errCode"] intValue] == 128)
			{
				YYYActivateViewController *viewcontroller = [[YYYActivateViewController alloc] initWithNibName:@"YYYActivateViewController" bundle:nil];
				viewcontroller.email = txtEmail.text;
				[self.navigationController pushViewController:viewcontroller animated:YES];
			}
			else
			{
				[self showAlert:[[_responseObject objectForKey:@"err"] objectForKey:@"errMsg"] :@"Oops!" :nil];
			}
		}
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
	{
		
        [ MBProgressHUD hideHUDForView : self.navigationController.view animated : YES ] ;
        [ self  showAlert: @"No Internet Connection" :@"Oops!" :nil] ;
		
    } ;
    
    if (![AppDelegate sharedDelegate].strDeviceToken)
	{
		[AppDelegate sharedDelegate].strDeviceToken = @"11111111111111";
	}
	
	[[YYYCommunication sharedManager] SignUP:txtEmail.text
                                   firstname:encodeName
                                    lastname:strLastName
                                    password:txtPassword.text
                                        udid:[OpenUDID value]
                                       token:[AppDelegate sharedDelegate].strDeviceToken
                                   voipToken:APPDELEGATE.voIPDeviceToken
                                   successed:successed
                                     failure:failure];
}

-(void)getContactInfo:(NSString*)sessionId :(NSString*)userid
{
	[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	
	void ( ^successed )( id _responseObject ) = ^( id _responseObject )
	{
		[MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
		
        //NSLog(@"info----%@",_responseObject);
		if ([[_responseObject objectForKey:@"success"] boolValue])
		{
			[AppDelegate sharedDelegate].sessionId	= [[_responseObject objectForKey:@"data"] objectForKey:@"sessionId"];
			[AppDelegate sharedDelegate].userId		= [[_responseObject objectForKey:@"data"] objectForKey:@"user_id"];
            [AppDelegate sharedDelegate].firstName	= [[_responseObject objectForKey:@"data"] objectForKey:@"first_name"];
            [AppDelegate sharedDelegate].lastName = [[_responseObject objectForKey:@"data"] objectForKey:@"last_name"];
            [AppDelegate sharedDelegate].userName = _responseObject[@"data"][@"user_name"];
            [AppDelegate sharedDelegate].photoUrl = _responseObject[@"data"][@"photo_url"];
            [AppDelegate sharedDelegate].phoneVerified = NO;
            
//			[[AppDelegate sharedDelegate] goToSetup];
            //wang class interrupt
            SetupLocationer *locationer = [[SetupLocationer alloc] init];
            [locationer configAfterSignIn:_responseObject];
            //wang class interrupt end
		}
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
	{
		
        [ MBProgressHUD hideHUDForView : self.navigationController.view animated : YES ] ;
        [ self  showAlert: @"No Internet Connection" :@"Oops!" :nil] ;
		
    } ;
    
	if (![AppDelegate sharedDelegate].strDeviceToken)
	{
		[AppDelegate sharedDelegate].strDeviceToken = @"11111111111111";
	}
	
	[[YYYCommunication sharedManager] UserLogin:txtEmail.text
									   password:txtPassword.text
										   udid:[OpenUDID value]
										  token:[AppDelegate sharedDelegate].strDeviceToken
                                      voipToken:APPDELEGATE.voIPDeviceToken
									  successed:successed
										failure:failure];
}

-(IBAction)btFBLoginClick:(id)sender
{
//	NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location",@"email"];
//    
//    // Login PFUser using facebook
//    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
//        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES]; // Hide loading indicator
//        [AppDelegate sharedDelegate].facebookAccessToke = [FBSession activeSession].accessTokenData.accessToken;
//        if (!user) {
//            if (!error) {
//                NSLog(@"Uh oh. The user cancelled the Facebook login.");
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Uh oh. The user cancelled the Facebook login." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
//                [alert show];
//            } else {
//                NSLog(@"Uh oh. An error occurred: %@", error);
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"We tried to connect with your Facebook account but Facebook doesn't allow Ginko to access. Please make sure your Facebook allows access from Ginko." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
////                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:error.localizedDescription delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
//                [alert show];
//            }
//        }
//		else if (user.isNew)
//		{
//			FBRequest *request = [FBRequest requestForMe];
//			[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//			
//			// Send request to Facebook
//			[request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
//			 {
//				[MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
//				
//				if (!error) {
//					// result is a dictionary with the user's Facebook data
//					NSDictionary *userData = (NSDictionary *)result;
//					[self loginByOpenID:userData];
//				}
//				else
//				{
//					[ self  showAlert: @"No Internet Connection" :@"Oops!" :nil] ;
//				}
//			}];
//		}
//		else
//		{
//			FBRequest *request = [FBRequest requestForMe];
//			[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//			
//			// Send request to Facebook
//			[request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
//			{				
//				[MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
//				
//				if (!error) {
//					// result is a dictionary with the user's Facebook data
//					NSDictionary *userData = (NSDictionary *)result;
//					[self loginByOpenID:userData];
//				}
//				else
//				{
//					[ self  showAlert: @"No Internet Connection" :@"Oops!" :nil] ;
//				}
//			}];
//		}
//    }];
//    
//    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
}

-(void)loginByOpenID:(NSDictionary*)user
{
	[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	
	void ( ^successed )( id _responseObject ) = ^( id _responseObject )
	{
		[MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
		
		if ([[_responseObject objectForKey:@"success"] boolValue])
		{
			[AppDelegate sharedDelegate].sessionId	= [[_responseObject objectForKey:@"data"] objectForKey:@"sessionId"];
			[AppDelegate sharedDelegate].userId		= [[_responseObject objectForKey:@"data"] objectForKey:@"user_id"];
            [AppDelegate sharedDelegate].firstName	= [[_responseObject objectForKey:@"data"] objectForKey:@"first_name"];
            [AppDelegate sharedDelegate].lastName = [[_responseObject objectForKey:@"data"] objectForKey:@"last_name"];
            [AppDelegate sharedDelegate].photoUrl = _responseObject[@"data"][@"photo_url"];
			
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
		
        [ MBProgressHUD hideHUDForView : self.navigationController.view animated : YES ] ;
        [ self  showAlert: @"No Internet Connection" :@"Oops!" :nil] ;
		
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

-(IBAction)btBackClick:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)showAlert:(NSString*)msg :(NSString*)title :(id)delegate
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:delegate cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	//Go to Login Screen
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url
{
    UIViewController *viewController = [[UIViewController alloc] init];
    NSLog(@"%@", url.absoluteString);
    if ([url.absoluteString rangeOfString:@"privacypolicy"].location != NSNotFound)
        viewController.title = @"Privacy Policy";
    else
        viewController.title = @"Terms of Use";
    viewController.view.backgroundColor = [UIColor whiteColor];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:viewController.view.bounds];
    [viewController.view addSubview:webView];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
