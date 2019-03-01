//
//  LoginSettingViewController.m
//  GINKO
//
//  Created by Forever on 6/11/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import "LoginSettingViewController.h"

// --- Defines ---;
static NSString * const LoginSettingInfoCellIdentifier = @"LoginSettingCell";

@interface LoginSettingViewController ()

@end

@implementation LoginSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)AddLogin: (NSString *)_email
{
    if (![CommonMethods checkEmailAddress:_email]) {
        return;
    }
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        NSLog(@"%@",_responseObject);
        
        if ([[_responseObject objectForKey:@"success"] boolValue])
//            [self SendAddLink:_email];
        {
            txtFieldEmail.text = @"";
            [self GetEmails];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:[[_responseObject objectForKey:@"err"] objectForKey:@"errMsg"] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alertView show];
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        NSLog(@"Connection failed - %@", _error);
    } ;
    
    [[Communication sharedManager] AddLogin:[AppDelegate sharedDelegate].sessionId email:_email successed:successed failure:failure];
}

- (void)DeleteLogin: (NSString *)_email
{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        selIndex = -1;
        if ([[_responseObject objectForKey:@"success"] boolValue])
            [self GetEmails];
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:[[_responseObject objectForKey:@"err"] objectForKey:@"errMsg"] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alertView show];
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        NSLog(@"Connection failed - %@", _error);
    } ;
    
    [[Communication sharedManager] DeleteLogin:[AppDelegate sharedDelegate].sessionId email:_email successed:successed failure:failure];
}

- (void)SendLink: (NSString *)_email
{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:[NSString stringWithFormat:@"Confirmation link sent to %@",_email] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alertView show];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:[[_responseObject objectForKey:@"err"] objectForKey:@"errMsg"] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alertView show];
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        NSLog(@"Connection failed - %@", _error);
    } ;
    
    [[Communication sharedManager] SendValidLink:_email successed:successed failure:failure];
}

- (void)SendAddLink: (NSString *)_email
{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            txtFieldEmail.text = @"";
            [self GetEmails];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:[[_responseObject objectForKey:@"err"] objectForKey:@"errMsg"] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alertView show];
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        NSLog(@"Connection failed - %@", _error);
    } ;
    
    [[Communication sharedManager] SendValidLink:_email successed:successed failure:failure];
}

- (void)GetEmails
{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        NSLog(@"%@",_responseObject);
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            arrEmails = [_responseObject objectForKey:@"data"];
            [tblForEmail reloadData];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:[[_responseObject objectForKey:@"err"] objectForKey:@"errMsg"] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alertView show];
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        NSLog(@"Connection failed - %@", _error);
    } ;
    
    [[Communication sharedManager] GetLoginSettings:[AppDelegate sharedDelegate].sessionId successed:successed failure:failure];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [tblForEmail registerNib:[UINib nibWithNibName:LoginSettingInfoCellIdentifier bundle:nil] forCellReuseIdentifier:LoginSettingInfoCellIdentifier];
    
    selIndex = -1;
    arrEmails = [[NSMutableArray alloc] init];
    [self GetEmails];
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

- (IBAction)onAdd:(id)sender
{
    [self.view endEditing:YES];
    [self AddLogin:txtFieldEmail.text];
}

- (IBAction)onDelete:(id)sender
{
    if (selIndex != -1)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"Do you want to delete this user login?" delegate:self cancelButtonTitle:@"No" otherButtonTitles: @"Yes", nil];
        [alertView setTag:500];
        [alertView show];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"Oops!  Please select an email to delete." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        
        [alertView show];
    }
}

- (IBAction)onSendConfirmation:(id)sender
{
    if (selIndex != -1)
    {
        NSDictionary *dict = [arrEmails objectAtIndex:selIndex];
        
        if (![[dict objectForKey:@"activated"] isEqualToString:@"yes"])
            [self SendLink:[dict objectForKey:@"email"]];
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"Oops!  You cannot send a link to a confirmed email." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            
            [alertView show];
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"Oops!  Please select an email to send a confirmation link." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        
        [alertView show];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    [self onAdd:nil];
    
    return YES;
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrEmails count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LoginSettingCell *cell = [tblForEmail dequeueReusableCellWithIdentifier:LoginSettingInfoCellIdentifier forIndexPath:indexPath];
    
    if (cell == nil)
    {
        cell = [[LoginSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoginSettingInfoCellIdentifier];
    }
    
    if (indexPath.row == selIndex)
        [cell.btnCheck setImage:[UIImage imageNamed:@"SmallOn"] forState:UIControlStateNormal];
    else
        [cell.btnCheck setImage:[UIImage imageNamed:@"SmallOff"] forState:UIControlStateNormal];
    
    NSDictionary *dict = [arrEmails objectAtIndex:indexPath.row];
    cell.lblEmail.text = [dict objectForKey:@"email"];
    if ([[dict objectForKey:@"activated"] isEqualToString:@"yes"])
        cell.lblStatus.text = @"Confirmed";
    else
        cell.lblStatus.text = @"Pending";
    
    cell.delegate = self;
    cell.sessionId = @"";
    cell.contactId = @"";
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selIndex = indexPath.row;
    [tableView reloadData];
}

#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView tag] == 500)
    {
        if (buttonIndex == 1) {
            NSDictionary *dict = [arrEmails objectAtIndex:selIndex];
            [self DeleteLogin:[dict objectForKey:@"email"]];
        }
    }
}

@end
