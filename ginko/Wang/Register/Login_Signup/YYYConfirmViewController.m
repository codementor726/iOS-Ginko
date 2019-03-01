//
//  YYYConfirmViewController.m
//  XChangeWithMe
//
//  Created by Wang MeiHua on 5/21/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import "YYYConfirmViewController.h"
#import "YYYActivateViewController.h"

#import "YYYCommunication.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "OpenUDID.h"

@interface YYYConfirmViewController ()

@end

@implementation YYYConfirmViewController

@synthesize email;
@synthesize name;
@synthesize lname;

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
	
	[txtEmail setText:email];
	[txtNewEmail setText:email];
	
	[txtEmail setEnabled:NO];
	[txtNewEmail setEnabled:NO];
	
	UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
	[self.view addGestureRecognizer:gesture];
	
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationController setNavigationBarHidden:YES];
	
	[scvContent setContentSize:CGSizeMake(320, 568)];
}

-(void)handleTap
{
	[self.view endEditing:YES];
}

-(IBAction)btAgreeClick:(id)sender
{
	if (!txtPassword.text.length)
	{
		[self showAlert:@"Please input Password" :@"Input Error" :nil];
		return;
	}
	
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
	
	void ( ^successed )( id _responseObject ) = ^( id _responseObject )
	{
		[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
		
		if ([[_responseObject objectForKey:@"success"] boolValue])
		{
            //wang class interrupt
            _globalData.scbEmail = txtEmail.text;
            _globalData.scbPassword = txtPassword.text;
            _globalData.scbValidType = [[[_responseObject objectForKey:@"data"] objectForKey:@"status_code"] intValue];
            //wang class interrupt end
			if([[[_responseObject objectForKey:@"data"] objectForKey:@"status_code"] intValue] == 0)
			{
				[self getContactInfo:[[_responseObject objectForKey:@"data"] objectForKey:@"sessionId"] :[[_responseObject objectForKey:@"data"] objectForKey:@"user_id"]];
                //wang comment:validate
			}
			else if([[[_responseObject objectForKey:@"data"] objectForKey:@"status_code"] intValue] == 1)
			{
				YYYActivateViewController *viewcontroller = [[YYYActivateViewController alloc] initWithNibName:@"YYYActivateViewController" bundle:nil];
				viewcontroller.email = txtEmail.text;
				[self.navigationController pushViewController:viewcontroller animated:YES];
			}
			else if([[[_responseObject objectForKey:@"data"] objectForKey:@"status_code"] intValue] == 2)
			{
				[self showAlert:@"Oops! Email credentials could not be validated." :@"Sign Up Error" :nil];
			}
			else
			{
				[ self  showAlert: @"An unknown error occurred" :@"Oops!" :nil] ;
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
				[ self  showAlert: @"Oops! Email credentials could not be validated." :@"Sign Up Error" :nil] ;
			}
			else if([[[_responseObject objectForKey:@"err"] objectForKey:@"errCode"] intValue] == 128)
			{
				YYYActivateViewController *viewcontroller = [[YYYActivateViewController alloc] initWithNibName:@"YYYActivateViewController" bundle:nil];
				viewcontroller.email = email;
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
		
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        [ self  showAlert: @"An unknown error occurred" :@"Oops!" :nil] ;
		
    } ;
	
    if (![AppDelegate sharedDelegate].strDeviceToken)
	{
		[AppDelegate sharedDelegate].strDeviceToken = @"11111111111111";
	}
	
	[[YYYCommunication sharedManager] SignUP:txtEmail.text
                                   firstname:name
                                    lastname:lname
                                    password:txtPassword.text
                                        udid:[OpenUDID value]
                                       token:[AppDelegate sharedDelegate].strDeviceToken
                                   voipToken:APPDELEGATE.voIPDeviceToken
                                   successed:successed
                                     failure:failure];
}

-(IBAction)btBackClick:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)btSendLinkClick:(id)sender
{
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
	
	void ( ^successed )( id _responseObject ) = ^( id _responseObject )
	{
		[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
		
		if ([[_responseObject objectForKey:@"success"] boolValue])
		{
			YYYActivateViewController *viewcontroller = [[YYYActivateViewController alloc] initWithNibName:@"YYYActivateViewController" bundle:nil];
			viewcontroller.email = txtEmail.text;
			[self.navigationController pushViewController:viewcontroller animated:YES];
		}
		else
		{
			[self showAlert:@"An unknown error occurred" :@"Oops!" :nil];
		}
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
	{
		[self showAlert:@"An unknown error occurred" :@"Oops!" :nil];
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
    } ;
    
	[[YYYCommunication sharedManager] SendValidationEmail:txtNewEmail.text
												successed:successed
												  failure:failure];
}

-(void)getContactInfo:(NSString*)sessionId :(NSString*)userid
{
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
	
	void ( ^successed )( id _responseObject ) = ^( id _responseObject )
	{
		[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
		
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
		}
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
	{
		
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        [ self  showAlert: @"An unknown error occurred" :@"Oops!" :nil] ;
		
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

-(void)showAlert:(NSString*)msg :(NSString*)title :(id)delegate
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:delegate cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
