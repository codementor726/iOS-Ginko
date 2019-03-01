//
//  YYYViewController.m
//  XChangeWithMe
//
//  Created by Wang MeiHua on 5/21/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import "YYYViewController.h"
#import "YYYLoginViewController.h"
#import "YYYSignUpViewController.h"
#import "OpenUDID.h"
#import "AppDelegate.h"
#import "YYYCommunication.h"

@interface YYYViewController ()

@end

@implementation YYYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [AppDelegate sharedDelegate].dictInfoHome = [[NSMutableDictionary alloc] init];
    [AppDelegate sharedDelegate].dictInfoWork = [[NSMutableDictionary alloc] init];
    
    [[AppDelegate sharedDelegate].dictInfoHome setObject:@"0" forKey:@"Private"];
    [[AppDelegate sharedDelegate].dictInfoWork setObject:@"0" forKey:@"Private"];
    
    [[AppDelegate sharedDelegate].dictInfoHome setObject:@"0" forKey:@"Abbr"];
    [[AppDelegate sharedDelegate].dictInfoWork setObject:@"0" forKey:@"Abbr"];
    
    _globalData.strWorkProfilePhoto = nil;
    _globalData.strHomeProfilePhoto = nil;
    _globalData.imgHomeProflePhoto = nil;
    _globalData.imgWorkProflePhoto = nil;
    
    _loginButton.hidden = YES;
    _registerButton.hidden = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
	[super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self performSelector:@selector(checkSession) withObject:nil afterDelay:1.0f];
}
- (void)checkSession{
    NSString *sessionId = [[NSUserDefaults standardUserDefaults] objectForKey:@"sessionId"];
    if (sessionId) {
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];

        NSLog(@"device_token : %@", [AppDelegate sharedDelegate].strDeviceToken);
        NSLog(@"voip_token : %@", [AppDelegate sharedDelegate].voIPDeviceToken);
        [[YYYCommunication sharedManager] checkSession:sessionId udid:[OpenUDID value]  token:[AppDelegate sharedDelegate].strDeviceToken voipToken:APPDELEGATE.voIPDeviceToken successed:^(id _responseObject) {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            if ([_responseObject[@"success"] integerValue] == 1) {
                [[AppDelegate sharedDelegate] loadLoginData];
                [[AppDelegate sharedDelegate] goToMainContact];
            } else {
                [[AppDelegate sharedDelegate] deleteLoginData];
                _loginButton.hidden = NO;
                _registerButton.hidden = NO;
            }
        } failure:^(NSError *_error) {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            [[AppDelegate sharedDelegate] deleteLoginData];
            _loginButton.hidden = NO;
            _registerButton.hidden = NO;
            
            [CommonMethods showAlertUsingTitle:@"Error" andMessage:[[_error userInfo] objectForKey:@"NSLocalizedDescription"]];
        }];
    } else {
        _loginButton.hidden = NO;
        _registerButton.hidden = NO;
    }

}
-(IBAction)btLoginClick:(id)sender
{
	YYYLoginViewController *viewcontroller = [[YYYLoginViewController alloc] initWithNibName:@"YYYLoginViewController" bundle:nil];
	[self.navigationController pushViewController:viewcontroller animated:YES];
}

-(IBAction)btSignupClick:(id)sender
{
//	if ([self hasFourInchDisplay])
//	{
		YYYSignUpViewController *viewcontroller = [[YYYSignUpViewController alloc] initWithNibName:@"YYYSignUpViewController" bundle:nil];
		[self.navigationController pushViewController:viewcontroller animated:YES];
//	}
//	else
//	{
//		YYYSignUpViewController *viewcontroller = [[YYYSignUpViewController alloc] initWithNibName:@"YYYSignUpViewController_iPhone4" bundle:nil];
//		[self.navigationController pushViewController:viewcontroller animated:YES];
//	}	
}

- (BOOL)hasFourInchDisplay {
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height >= 568.0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
