//
//  NotExchangedViewController.m
//  Ginko
//
//  Created by Qi Song on 29/3/14.
//  Copyright (c) 2014 Qi Song. All rights reserved.
//
// --- Headers ---;
#import "InviteViewController.h"
#import "ProfileRequestController.h"
#import "SettingViewController.h"

#import "UIImage+Tint.h"

#import "TabRequestController.h"
#import "ProfileViewController.h"

// --- Defines ---;
static NSString * const InviteInfoCellIdentifier = @"InviteInfoCell";

// RequestViewController Class;
@interface InviteViewController ()

@end

@implementation InviteViewController

@synthesize appDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Table View;
    [tblForContact registerNib:[UINib nibWithNibName:InviteInfoCellIdentifier bundle:nil] forCellReuseIdentifier:InviteInfoCellIdentifier];
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    contactList = [[NSMutableArray alloc] init];
    searchList = [[NSMutableArray alloc] init];
    
    tempRequest = [[NSMutableArray alloc] init];
    tempSent = [[NSMutableArray alloc] init];
    
    tblForContact.allowsMultipleSelectionDuringEditing = YES;
    contactIds = [[NSString alloc] init];
    contactIds = @"";
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    [trashBut setImage:[[UIImage imageNamed:@"TrashIcon"] tintImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:navView];
    
    appDelegate.type = 1;
    
    if (appDelegate.approveFlag)
    {
        self.tabBarController.selectedIndex = 0;
        appDelegate.approveFlag = NO;
    }
    else
        [self GetSentInvitation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [navView removeFromSuperview];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)goBackBut
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onAddInvitation
{
    [self.view endEditing:YES];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Please enter contact's email address"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Continue", nil];
    
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[alertView textFieldAtIndex:0] setTextAlignment:NSTextAlignmentCenter];
    [alertView setTag:100];
    UITextField *textField = [alertView textFieldAtIndex:0];
    [textField setKeyboardType:UIKeyboardTypeEmailAddress];
    [alertView show];
}

- (void)onEdit
{
    backBut.hidden = YES;
    addBut.hidden = YES;
    closeBut.hidden = NO;
    clearBut.hidden = NO;
    [self.tabBarController.tabBar addSubview:tabBar];
    [self.navigationItem setHidesBackButton:YES animated:NO];
    [tblForContact setEditing:YES animated:YES];
    [(TabRequestController *)self.tabBarController showTabbarImage:NO];
}

- (void)onCloseEdit
{
    backBut.hidden = NO;
    addBut.hidden = NO;
    closeBut.hidden = YES;
    clearBut.hidden = YES;
    [tabBar removeFromSuperview];
    [tblForContact setEditing:NO animated:YES];
    [(TabRequestController *)self.tabBarController showTabbarImage:YES];
}

- (void)onClearChat
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"Do you want to clear all chats?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [alertView show];
}

- (void)onTrash
{
//    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@" Delete Sprout Contact(s)" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Delete contact(s) permanently", @"Delete contact(s) for 24 hours", nil];
//    actionSheet.delegate = self;
//    [actionSheet showFromTabBar:[[self tabBarController] tabBar]];
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"Do you want to delete this contact from the Invite list?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [alertView setTag:101];
    [alertView show];
}

#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if ([alertView tag] == 100 && buttonIndex == 1)
    {
        UITextField *textField = [alertView textFieldAtIndex:0];
        [self AddInvitation: textField.text];
    }
    else if ([alertView tag] == 101 && buttonIndex == 1)
    {
        NSArray *selectedRows = [tblForContact indexPathsForSelectedRows];
        
        for (int i = [selectedRows count] - 1 ; i >= 0  ; i--)
        {
            NSIndexPath * selectRow = [selectedRows objectAtIndex:i];
            NSDictionary * dict = [searchList objectAtIndex:selectRow.row];
            if (![contactIds isEqualToString:@""])
            {
                contactIds = [NSString stringWithFormat:@"%@,", contactIds];
            }
            contactIds = [NSString stringWithFormat:@"%@%@", contactIds, [dict objectForKey:@"email"]];
        }
        
        [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
        void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
            [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
            NSLog(@"%@",[_responseObject objectForKey:@"data"]);
            contactIds = @"";
            [self GetSentInvitation];
        } ;
        
        void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
            contactIds = @"";
            [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
            [appDelegate GetContactList];
            NSLog(@"Request Cancel failed");
        } ;
        
        [[Communication sharedManager] DeleteInvitation:[AppDelegate sharedDelegate].sessionId emails:contactIds successed:successed failure:failure];
        
        [self onCloseEdit];
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [searchList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72.0f;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([searchList count] < indexPath.row + 1)
    {
        return nil;
    }
    InviteInfoCell *cell = [tblForContact dequeueReusableCellWithIdentifier:InviteInfoCellIdentifier forIndexPath:indexPath];
    if (cell == nil)
    {
        cell = [[InviteInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:InviteInfoCellIdentifier];
    }

    NSDictionary * dict = [searchList objectAtIndex:indexPath.row];
//    NSString * firstName = [dict objectForKey:@"first_name"];
//    NSString * lastName = [dict objectForKey:@"last_name"];
    BOOL pendingFlag = [[dict objectForKey:@"is_pending"] boolValue];
    
    NSLog(@"%@", dict);
    cell.shareBut.selected = pendingFlag;
    cell.lastDate.hidden = pendingFlag;
    
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setTimeZone:[NSTimeZone localTimeZone]];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSDate * lastTime = [df dateFromString:[dict objectForKey:@"found_time"]];
    NSDate * lastTime = [df dateFromString:[dict objectForKey:@"created"]];
    [df setDateFormat:@"MMMM dd, yyyy"];
    NSString * lastDate = [df stringFromDate:lastTime];
    cell.lastDate.text = lastDate;
    cell.contactInfo = dict;
    [cell setPhoto:[dict objectForKey:@"photo_url"]];
    cell.username.text = [dict objectForKey:@"email"];
    
    cell.delegate = self;
    // Set;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tblForContact.editing)
    {
        trashBut.enabled = YES;
        return;
    }
    NSDictionary * dict = [searchList objectAtIndex:indexPath.row];
    if ([dict objectForKey:@"detected_location"] && ![[dict objectForKey:@"detected_location"] isEqualToString:@""])
    {
        ProfileViewController * controller = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
        controller.contactInfo = dict;
        [self.navigationController pushViewController:controller animated:YES];
    }else{
        ProfileRequestController * controller = [[ProfileRequestController alloc] initWithNibName:@"ProfileRequestController" bundle:nil];
        controller.contactInfo = dict;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *selectedRows = [tblForContact indexPathsForSelectedRows];
    if ([selectedRows count] == 0)
    {
        trashBut.enabled = NO;
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
//    searchStartFlag = YES;
//    [self showCancelBut:YES];
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    searchFlag = YES;
    if ([searchText isEqualToString:@""])
    {
        [searchList removeAllObjects];
        searchList = [contactList mutableCopy];
        searchFlag = NO;
        [tblForContact reloadData];
    }
    else
    {
        [searchList removeAllObjects];
        for (int i = 0 ; i < [contactList count] ; i++)
        {
            NSDictionary * dict = [contactList objectAtIndex:i];
            NSRange range = [[[NSString stringWithFormat:@"%@", [dict objectForKey:@"email"]] uppercaseString] rangeOfString:[searchText uppercaseString]];
            if (range.location != NSNotFound) {
                [searchList addObject:dict];
                continue;
            }
            
            NSString * firstName = [[dict objectForKey:@"first_name"] uppercaseString];
            NSString * lastName = [[dict objectForKey:@"last_name"] uppercaseString];
            if (![firstName isEqualToString:@""] || ![lastName isEqualToString:@""]) {
                range = [[NSString stringWithFormat:@"%@ %@", firstName, lastName]rangeOfString:[searchText uppercaseString]];
                if (range.location != NSNotFound) {
                    [searchList addObject:dict];
                    continue;
                }
            }
        }
        [tblForContact reloadData];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    searchStartFlag = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    searchList = [contactList mutableCopy];
    searchFlag = NO;
    [tblForContact reloadData];
}

#pragma mark - Function

- (IBAction)onCancelSearch:(id)sender
{
    [contactSearch resignFirstResponder];
    [self showCancelBut:NO];
}

- (void)showCancelBut:(BOOL)flag
{
    if (flag)
    {
        [UIView animateWithDuration:0.3f animations:^(void){
            [contactSearch setFrame:CGRectMake(contactSearch.frame.origin.x, contactSearch.frame.origin.y, 242, 44)];
            [cancelBut setFrame:CGRectMake(285, cancelBut.frame.origin.y, 35, 44)];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3f animations:^(void){
            [contactSearch setFrame:CGRectMake(contactSearch.frame.origin.x, contactSearch.frame.origin.y, 276, 44)];
            [cancelBut setFrame:CGRectMake(320, cancelBut.frame.origin.y, 35, 44)];
        }];
    }
}

- (void)shareInfo:(NSDictionary *)contactInfo
{
    if ([contactInfo objectForKey:@"detected_location"] && ![[contactInfo objectForKey:@"detected_location"] isEqualToString:@""])
    {
        ProfileViewController * controller = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
        controller.contactInfo = contactInfo;
        [self.navigationController pushViewController:controller animated:YES];
    }else{
        ProfileRequestController * controller = [[ProfileRequestController alloc] initWithNibName:@"ProfileRequestController" bundle:nil];
        controller.contactInfo = contactInfo;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma UIAlertView Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSArray *selectedRows = [tblForContact indexPathsForSelectedRows];
    
    if (buttonIndex == 0)
    {
        remove_type = @"1";
    }
    else if (buttonIndex == 1)
    {
        remove_type = @"2";
    }
    else
    {
        return;
    }
    
    for (int i = [selectedRows count] - 1 ; i >= 0  ; i--)
    {
        NSIndexPath * selectRow = [selectedRows objectAtIndex:i];
        NSDictionary * dict = [searchList objectAtIndex:selectRow.row];
        if (![contactIds isEqualToString:@""])
        {
            contactIds = [NSString stringWithFormat:@"%@,", contactIds];
        }
        contactIds = [NSString stringWithFormat:@"%@%@", contactIds, [dict objectForKey:@"email"]];
        [searchList removeObject:dict];
        [contactList removeObject:dict];
    }
    
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        NSLog(@"%@",[_responseObject objectForKey:@"data"]);
        contactIds = @"";
        NSLog(@"%@", appDelegate.contactList);
        [tblForContact reloadData];
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        contactIds = @"";
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        [appDelegate GetContactList];
        NSLog(@"Request Cancel failed");
    } ;
    
    [[Communication sharedManager] DeleteDetectedFriends:[AppDelegate sharedDelegate].sessionId contactIds:contactIds remove_type:remove_type successed:successed failure:failure];
    
    searchList = [contactList mutableCopy];
    
    [self onCloseEdit];
}

# pragma - Web Service Part

- (void)AddInvitation : (NSString*)email
{
////    if (![CommonMethods checkEmailAddress:email]) {
////        return;
////    }
//    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
//        if ([[_responseObject objectForKey:@"success"] boolValue])
//            [self GetSentInvitation];
//        else
//        {
////            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:[[_responseObject objectForKey:@"err"] objectForKey:@"errMsg"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
////            [alertView show];
//            [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"The parameter email must be a valid email."];
//        }
//    } ;
//    
//    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
//        NSLog(@"Connection failed - %@", _error);
//    } ;
//    
//    [[Communication sharedManager] AddInvitations:[AppDelegate sharedDelegate].sessionId :email successed:successed failure:failure];
}

- (void)GetInvitation
{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;

	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
		if ([[_responseObject objectForKey:@"success"] boolValue])
		{
            contactList = [[_responseObject objectForKey:@"data"] objectForKey:@"results"];
            searchList = [contactList mutableCopy];
            
            if ([searchList count] == 0)
                [self.tabBarItem setBadgeValue:nil];
            else
                [self.tabBarItem setBadgeValue:[NSString stringWithFormat:@"%lu", (unsigned long)[searchList count]]];
            
            if ([tempRequest count] == 0)
                [[self.tabBarController.tabBar.items objectAtIndex:2] setBadgeValue:nil];
            else
                [[self.tabBarController.tabBar.items objectAtIndex:2] setBadgeValue:[NSString stringWithFormat:@"%lu", (unsigned long)[tempRequest count]]];
            
            if ([tempSent count] == 0)
                [[self.tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:nil];
            else
                [[self.tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:[NSString stringWithFormat:@"%lu", (unsigned long)[tempSent count]]];
            
            [tblForContact reloadData];
		}
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;

        NSLog(@"Connection failed - %@", _error);
    } ;
    
    [[Communication sharedManager] GetInvitations:[AppDelegate sharedDelegate].sessionId successed:successed failure:failure];
}

- (void)GetRequests
{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    
	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        NSLog(@"OKOKOKOKGetRequests");
        NSLog(@"%@",[_responseObject objectForKey:@"data"]);
		if ([[_responseObject objectForKey:@"success"] boolValue])
		{
            tempRequest = [[_responseObject objectForKey:@"data"] objectForKey:@"results"];
            
            [self GetInvitation];
		}
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        NSLog(@"Connection failed - %@", _error);
    } ;
    
    [[Communication sharedManager] GetRequests:[AppDelegate sharedDelegate].sessionId successed:successed failure:failure];
}

- (void)GetSentInvitation
{
    if ([AppDelegate sharedDelegate].sessionId) {
        [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
        
        void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
            [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
            
            NSLog(@"OKOKOKOKGetSentInvitation");
            NSLog(@"%@",[_responseObject objectForKey:@"data"]);
            if ([[_responseObject objectForKey:@"success"] boolValue])
            {
                tempSent = [[_responseObject objectForKey:@"data"] objectForKey:@"results"];
                
                [self GetRequests];
            }
        } ;
        
        void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
            [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
            
            NSLog(@"Connection failed - %@", _error);
        } ;
        
        [[Communication sharedManager] GetSentInvitations:[AppDelegate sharedDelegate].sessionId successed:successed failure:failure];
    }
}

@end
