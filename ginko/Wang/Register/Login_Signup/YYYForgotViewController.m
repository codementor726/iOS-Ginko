//
//  YYYForgotViewController.m
//  XChangeWithMe
//
//  Created by Wang MeiHua on 5/21/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import "YYYForgotViewController.h"

#import "YYYCommunication.h"
#import "MBProgressHUD.h"

@interface YYYForgotViewController ()

@end

@implementation YYYForgotViewController

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
	
	// Do any additional setup after loading the view from its nib.
}

-(void)setupUI
{
	[self.navigationItem setTitle:@"Forgot Password"];
	
    NSAttributedString *attrForEmail = [[NSAttributedString alloc] initWithString:@"Type your email" attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    txtEmail.attributedPlaceholder = attrForEmail;
}

-(IBAction)btBackClick:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)btSubmitClick:(id)sender
{
	if (!txtEmail.text.length) {
		[self showAlert:@"Please input your Email Address" :@"Input Error" :nil];
		return;
	}
    if (![CommonMethods checkEmail:txtEmail]) {
        return;
    }
	
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
	
	void ( ^successed )( id _responseObject ) = ^( id _responseObject )
	{
		[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
		
		if ([[_responseObject objectForKey:@"success"] boolValue])
		{
			[self showAlert:[NSString stringWithFormat:@"If %@ is in our login records, the system will send your password to this email. If you are having problems receiving your password, please contact Customer Service.",txtEmail.text] :@"Forgot Password" :self];
		}
		else
		{
			[self showAlert:[NSString stringWithFormat:@"%@ is not in our login records.",txtEmail.text] :@"Oops!" :nil];
		}
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
	{
		
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        [ self  showAlert: @"An unknown error occurred" :@"Oops!" :nil] ;
		
    } ;
	
	[[YYYCommunication sharedManager] ForgotPassword:txtEmail.text
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
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
