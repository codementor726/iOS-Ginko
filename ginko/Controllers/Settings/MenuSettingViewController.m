//
//  MenuSettingViewController.m
//  GINKO
//
//  Created by Forever on 6/11/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import "MenuSettingViewController.h"

@interface MenuSettingViewController ()
{
    NSArray *arrReasons;
}

@end

@implementation MenuSettingViewController

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
    selIndex = -1;
    
    [[btnSort layer] setBorderWidth: 0.5f];
    [[btnSort layer] setBorderColor:[UIColor blackColor].CGColor];
    
    [[btnLanguage layer] setBorderWidth: 0.5f];
    [[btnLanguage layer] setBorderColor:[UIColor blackColor].CGColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar addSubview:navView];
    // self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:230.0/256.0 green:1.0f blue:190.0/256.0 alpha:1.0f];
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    NSString *sort = [[NSUserDefaults standardUserDefaults] objectForKey:@"GINKOSORTBY"];
    
    if (sort != nil && [sort isEqualToString:@"first_name"])
        [btnSort setTitle:@"First Name" forState:UIControlStateNormal];
    else if (sort != nil && [sort isEqualToString:@"last_name"])
        [btnSort setTitle:@"Last Name" forState:UIControlStateNormal];
    
    [self GetDeactivateReason];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [navView removeFromSuperview];
}

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onDeactivate:(id)sender
{
    if (selIndex == -1)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Please select a deactivation reason." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE
															message:@"Please enter your password to deactivate your account."
														   delegate:self
												  cancelButtonTitle:@"Cancel"
												  otherButtonTitles:@"Okay", nil];
        
		alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [[alertView textFieldAtIndex:0] setTextAlignment:NSTextAlignmentCenter];
        [[alertView textFieldAtIndex:0] setSecureTextEntry:YES];
        [alertView setTag:500];
        [alertView show];
    }
}

- (IBAction)onBtnSort:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    [sheet addButtonWithTitle:@"Sort by Last Name"];
    [sheet addButtonWithTitle:@"Sort by First Name"];

    [sheet addButtonWithTitle:@"Cancel"];
    sheet.cancelButtonIndex = 2;
    
    [sheet showInView:self.view];
}

#pragma - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"last_name" forKey:@"GINKOSORTBY"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [btnSort setTitle:@"Last Name" forState:UIControlStateNormal];
    }
    else if (buttonIndex == 1)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"first_name" forKey:@"GINKOSORTBY"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [btnSort setTitle:@"First Name" forState:UIControlStateNormal];
    }
}

#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView tag] == 500)
    {
        if (buttonIndex == 1) {
            NSString *pass = @"";
            
            pass = [alertView textFieldAtIndex:0].text;
            
            [self DeactivateAccount:pass];
        }
    } else if([alertView tag] == 1000) {
        // Sign out
//        [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
//        
//        void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
//            [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
//            
//            if ([[_responseObject objectForKey:@"success"] boolValue])
//            {
//                [navView removeFromSuperview];
//                //            [self.navigationController popToRootViewControllerAnimated:YES];
                [[AppDelegate sharedDelegate] goToSplash];
//            }
//        } ;
//        
//        void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
//            [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
//            
//            NSLog(@"Connection failed - %@", _error);
//        } ;
        
//        [[Communication sharedManager] Logout:[AppDelegate sharedDelegate].sessionId deviceUID:nil successed:successed failure:failure];
    }
}

- (void)DeactivateAccount:(NSString *)_password
{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        NSLog(@"%@",_responseObject);
		if ([[_responseObject objectForKey:@"success"] boolValue])
		{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"Your account has been deactivated." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            alertView.tag = 1000;
            [alertView show];
            [AppDelegate sharedDelegate].deactiveForAccount = YES;
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:[[_responseObject objectForKey:@"err"] objectForKey: @"errMsg"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        NSLog(@"Connection failed - %@", _error);
    } ;
    
    NSString *otherReason = nil;
    NSString *reasonCode = nil;
    if (selIndex == 100) {
        otherReason = @"Other";
    } else {
        reasonCode = [(NSDictionary *)[arrReasons objectAtIndex:selIndex] objectForKey:@"id"];
    }
    [[Communication sharedManager] Deactivate:[AppDelegate sharedDelegate].sessionId curPwd:_password reasonCode:reasonCode otherReason:otherReason successed:successed failure:failure];
}

- (void)GetDeactivateReason
{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        NSLog(@"%@",[_responseObject objectForKey:@"data"]);
        arrReasons = (NSArray *)[_responseObject objectForKey:@"data"];
        [tblReason reloadData];
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        NSLog(@"Connection failed - %@", _error);
    } ;
    
    [[Communication sharedManager] GetDeactivateReason:[AppDelegate sharedDelegate].sessionId successed:successed failure:failure];
}

#pragma mark - DeactivateCell Delegate
- (void)selectReason:(NSDictionary*)dict index:(NSInteger)index
{
    if (selIndex == index) {
        selIndex = -1;
    } else {
        selIndex = (int)index;
    }
    [tblReason reloadData];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([arrReasons count] < 1) {
        return 0;
    }
    return [arrReasons count] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 25.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DeactivateCell *cell = [tblReason dequeueReusableCellWithIdentifier:@"DeactivateCell"];
    if(cell == nil)
    {
        cell = [DeactivateCell sharedCell];
    }
    [cell setDelegate:self] ;
    
    if (indexPath.row < [arrReasons count]) {
        
        cell.dictReason = (NSDictionary *)[arrReasons objectAtIndex:indexPath.row];
        
        cell.curIndex = indexPath.row;
        
        if (selIndex == indexPath.row) {
            cell.isReasonSelected = YES;
        } else cell.isReasonSelected = NO;
        
        return cell;
    } else {
        cell.dictReason = nil;
        cell.curIndex = 100;
        if (selIndex == indexPath.row) {
            cell.isReasonSelected = YES;
        } else if (selIndex == 100) {
            cell.isReasonSelected = YES;
        } else  cell.isReasonSelected = NO;
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
