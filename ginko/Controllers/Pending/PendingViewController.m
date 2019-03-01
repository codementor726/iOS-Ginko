//
//  NotExchangedViewController.m
//  Ginko
//
//  Created by Qi Song on 29/3/14.
//  Copyright (c) 2014 Qi Song. All rights reserved.
//
// --- Headers ---;
#import "PendingViewController.h"
#import "ProfileRequestController.h"
#import "SettingViewController.h"
#import "YYYCommunication.h"

#import "UIImage+Tint.h"

#import "TabRequestController.h"
#import "ProfileViewController.h"

// --- Defines ---;
static NSString * const PendingInfoCellIdentifier = @"PendingInfoCell";

// RequestViewController Class;
@interface PendingViewController ()<UIGestureRecognizerDelegate>{
    BOOL isEditing;
    NSMutableArray *arrSelectedContacts;
    NSMutableArray *arrSelectedDirectorys;
}

@end

@implementation PendingViewController

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
    isEditing = NO;
    arrSelectedContacts = [[NSMutableArray alloc] init];
    arrSelectedDirectorys = [[NSMutableArray alloc] init];
    // Table View;
    [tblForContact registerNib:[UINib nibWithNibName:PendingInfoCellIdentifier bundle:nil] forCellReuseIdentifier:PendingInfoCellIdentifier];
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    contactList = [[NSMutableArray alloc] init];
    searchList = [[NSMutableArray alloc] init];
    tempRequest = [[NSMutableArray alloc] init];
    tempInvite = [[NSMutableArray alloc] init];
    
    tblForContact.allowsMultipleSelectionDuringEditing = YES;
    contactIds = [[NSString alloc] init];
    directoryIds = [[NSString alloc] init];
    contactIds = @"";
    directoryIds = @"";
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    [trashBut setImage:[[UIImage imageNamed:@"TrashIcon"] tintImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    // tapGestureRecognizer.cancelsTouchesInView = NO;
    tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    //[tblForContact addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:navView];
    
    appDelegate.type = 2;
    
    if (appDelegate.locationFlag)
        gpsBut.selected = YES;
    else
        gpsBut.selected = NO;
    
    if (appDelegate.approveFlag)
    {
//        self.tabBarController.selectedIndex = 1;
        appDelegate.approveFlag = NO;
    }

    [self reloadInvitesAndBadgeValue];
    
}
- (void)reloadInvitesAndBadgeValue{
    [self GetRequests];
    [self GetSentInvitation];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [navView removeFromSuperview];
    
    [tabBar removeFromSuperview];
    [tblForContact setEditing:NO animated:YES];
    [(TabRequestController *)self.tabBarController showTabbarImage:YES];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (isEditing) {
        [self.tabBarController.tabBar addSubview:tabBar];
        [self.navigationItem setHidesBackButton:YES animated:NO];
        [tblForContact setEditing:YES animated:YES];
        [(TabRequestController *)self.tabBarController showTabbarImage:NO];
    }else{
        [tabBar removeFromSuperview];
        [tblForContact setEditing:NO animated:YES];
        [(TabRequestController *)self.tabBarController showTabbarImage:YES];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
-(void)dismissKeyboard {
    [contactSearch resignFirstResponder];
}
-(void)goBackBut
{
    [self.navigationController popViewControllerAnimated:YES];
    if (appDelegate.isCreateEntityViewController) {
        [self.navigationController.navigationBar setBarTintColor:COLOR_PURPLE_THEME];
    }
    appDelegate.isCreateEntityViewController = NO;
}

- (void)onEdit
{
    [contactSearch resignFirstResponder];
//    if ([searchList count] == 0) {
//        trashBut.enabled = NO;
//    }
    [self setTrashButtonEnabled];
    if (!btEdit.selected) {
        [btEdit setSelected:YES];
        isEditing = YES;
        backBut.hidden = YES;
        closeBut.hidden = NO;
        clearBut.hidden = NO;
        [self.tabBarController.tabBar addSubview:tabBar];
        [self.navigationItem setHidesBackButton:YES animated:NO];
        [tblForContact setEditing:YES animated:YES];
        [(TabRequestController *)self.tabBarController showTabbarImage:NO];
    }else{
        [btEdit setSelected:NO];
        isEditing = NO;
        backBut.hidden = NO;
        closeBut.hidden = YES;
        clearBut.hidden = YES;
        [tabBar removeFromSuperview];
        [tblForContact setEditing:NO animated:YES];
        [(TabRequestController *)self.tabBarController showTabbarImage:YES];
    }
}

- (void)onCloseEdit
{
    //[contactSearch resignFirstResponder];
    isEditing = NO;
    [btEdit setSelected:NO];
    backBut.hidden = NO;
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
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"Do you want to cancel the request to exchange information?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [alertView setTag:101];
    [alertView show];
}

#pragma mark - Function

- (void)setTrashButtonEnabled {
    NSArray *indexPaths = [tblForContact indexPathsForSelectedRows];
    trashBut.enabled = (tblForContact.editing && indexPaths.count);
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [contactSearch resignFirstResponder];
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
    PendingInfoCell *cell = [tblForContact dequeueReusableCellWithIdentifier:PendingInfoCellIdentifier forIndexPath:indexPath];
    if (cell == nil)
    {
        cell = [[PendingInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PendingInfoCellIdentifier];
    }

    NSDictionary * dict = [searchList objectAtIndex:indexPath.row];
    if ([dict objectForKey:@"email"]) {
        NSString * firstName = [dict objectForKey:@"first_name"];
        NSString * lastName = [dict objectForKey:@"last_name"];
        BOOL pendingFlag = [[dict objectForKey:@"is_pending"] boolValue];
        cell.shareBut.selected = pendingFlag;
        //    cell.pingArea.hidden = pendingFlag;
        //cell.lastDate.hidden = pendingFlag;
        
        NSDateFormatter * df = [[NSDateFormatter alloc] init];
        [df setTimeZone:[NSTimeZone localTimeZone]];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate * lastTime = [df dateFromString:[dict objectForKey:@"sent_time"]];
        [df setDateFormat:@"MMMM dd, yyyy"];
        NSString * lastDate = [df stringFromDate:lastTime];
        cell.lastDate.text = lastDate;
        //    [cell setPingLocation:[[dict objectForKey:@"latitude"] floatValue] pingLongitude:[[dict objectForKey:@"longitude"] floatValue]];
        cell.contactInfo = dict;
        [cell setPhoto:[dict objectForKey:@"photo_url"]];
        
        if ([firstName isEqualToString:@""] && [lastName isEqualToString:@""]) {
            cell.username.text = [dict objectForKey:@"email"];
        } else {
            cell.username.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        }
    }else{
        cell.username.text = [dict objectForKey:@"name"];
        cell.contactInfo = dict;
        if (![[dict objectForKey:@"profile_image"] isEqualToString:@""]) {
            [cell setPhoto:[dict objectForKey:@"profile_image"]];
        }else{
            [cell.profileImageView setImage:[UIImage imageNamed:@"group_chat_img"]];
        }
        NSDateFormatter * df = [[NSDateFormatter alloc] init];
        [df setTimeZone:[NSTimeZone localTimeZone]];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate * lastTime = [df dateFromString:[dict objectForKey:@"sent_time"]];
        [df setDateFormat:@"MMMM dd, yyyy"];
        NSString * lastDate = [df stringFromDate:lastTime];
        cell.lastDate.text = lastDate;
        cell.shareBut.selected = NO;
        //cell.lastDate.hidden = YES;
    }
    
    if (tblForContact.editing)
    {
        if ([dict objectForKey:@"email"]) {
            if ([arrSelectedContacts containsObject:[dict objectForKey:@"id"]]) {
                [tableView selectRowAtIndexPath:indexPath
                                       animated:NO
                                 scrollPosition:UITableViewScrollPositionNone];
            }
        }else{
            if ([arrSelectedDirectorys containsObject:[dict objectForKey:@"id"]]) {
                [tableView selectRowAtIndexPath:indexPath
                                       animated:NO
                                 scrollPosition:UITableViewScrollPositionNone];
            }
        }
    }
    cell.delegate = self;
    // Set;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [contactSearch resignFirstResponder];
    
    NSDictionary * dict = [searchList objectAtIndex:indexPath.row];
    if (tblForContact.editing)
    {
        trashBut.enabled = YES;
        
        if ([dict objectForKey:@"email"]) {
            [arrSelectedContacts addObject:[dict objectForKey:@"id"]];
        }else{
            [arrSelectedDirectorys addObject:[dict objectForKey:@"id"]];
        }
        return;
    }
    if ([dict objectForKey:@"email"]) {
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
    }else{
        
        //[tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self getPermissionForDirectory:dict];
        //APPDELEGATE.type = 6;
        //ProfileRequestController * controller = [[ProfileRequestController alloc] initWithNibName:@"ProfileRequestController" bundle:nil];
        //controller.directoryId = [dict objectForKey:@"id"];
        //controller.directoryName = [dict objectForKey:@"name"];
        //[self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dict = [searchList objectAtIndex:indexPath.row];
    [self setTrashButtonEnabled];
    if ([dict objectForKey:@"email"]) {
        [arrSelectedContacts removeObject:[dict objectForKey:@"id"]];
    }else{
        [arrSelectedDirectorys removeObject:[dict objectForKey:@"id"]];
    }
}

- (void)getPermissionForDirectory:(NSDictionary *)directoryInfo{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            
            APPDELEGATE.type = 8;
            ProfileRequestController * controller = [[ProfileRequestController alloc] initWithNibName:@"ProfileRequestController" bundle:nil];
            //controller.contactInfo = contactDict;
            controller.directoryId = [directoryInfo objectForKey:@"id"];
            controller.directoryName = [directoryInfo objectForKey:@"name"];
            controller.contactInfo = [_responseObject objectForKey:@"data"];
            [self.navigationController pushViewController:controller animated:YES];
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Internet Connection Error!"];
    } ;
    
    [[YYYCommunication sharedManager] GetPermissionMemberDirectory:APPDELEGATE.sessionId directoryId:[directoryInfo objectForKey:@"id"]  successed:successed failure:failure];
}
#pragma UISearchBar Delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
//    searchStartFlag = YES;
//    [self showCancelBut:YES];
    [searchBar setShowsCancelButton:YES animated:YES];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:NO animated:YES];
    
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    searchFlag = YES;
    if ([searchText isEqualToString:@""])
    {
        [searchList removeAllObjects];
        searchList = [contactList mutableCopy];
        searchFlag = NO;
        if ([searchList count] == 0) {
            lblNoContact.hidden = NO;
        }else{
            lblNoContact.hidden = YES;
        }
        if ([searchList count] > 0) {
            btEdit.enabled = YES;
        }else {
            btEdit.enabled = NO;
        }
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
        if ([searchList count] == 0) {
            lblNoContact.hidden = NO;
            btEdit.enabled = NO;
        }else{
            lblNoContact.hidden = YES;
            btEdit.enabled = YES;
        }
        [tblForContact reloadData];
    }
   // [self setTrashButtonEnabled];
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
    if ([searchList count] == 0) {
        lblNoContact.hidden = NO;
        btEdit.enabled = NO;
    }else{
        lblNoContact.hidden = YES;
        btEdit.enabled = YES;
    }
    [tblForContact reloadData];
    
}

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
    if ([contactInfo objectForKey:@"email"]) {
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
}

#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([alertView tag] == 101 && buttonIndex == 1)
    {
        NSArray *selectedRows = [tblForContact indexPathsForSelectedRows];
        
        for (int i = [selectedRows count] - 1 ; i >= 0  ; i--)
        {
            NSIndexPath * selectRow = [selectedRows objectAtIndex:i];
            NSDictionary * dict = [searchList objectAtIndex:selectRow.row];
            if ([dict objectForKey:@"email"]) {
                if (![contactIds isEqualToString:@""])
                {
                    contactIds = [NSString stringWithFormat:@"%@,", contactIds];
                }
                contactIds = [NSString stringWithFormat:@"%@%@", contactIds, [dict objectForKey:@"email"]];
            }else{
                if (![directoryIds isEqualToString:@""])
                {
                    directoryIds = [NSString stringWithFormat:@"%@,", directoryIds];
                }
                directoryIds = [NSString stringWithFormat:@"%@%@", directoryIds, [dict objectForKey:@"id"]];
            }
        }
        
        [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
        void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
            [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
            contactIds = @"";
            
            void ( ^successed )( id _responseObject ) = ^( id _responseObject )
            {
                [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
                NSDictionary *result = _responseObject;
                if ([[result objectForKey:@"success"] boolValue]) {
                    
                    directoryIds = @"";
                    [self reloadInvitesAndBadgeValue];
                    
                } else {
                    directoryIds = @"";
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    NSDictionary *dictError = [result objectForKey:@"err"];
                    if (dictError) {
                        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:[dictError objectForKey:@"errMsg"]];
                    } else {
                        [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Failed to connect to server!"];
                    }
                }
            };
            
            void ( ^failure )( NSError* _error ) = ^( NSError* _error )
            {
                directoryIds = @"";
                [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
                [CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Internet Connection Error!"];
            };
            
            if (![directoryIds isEqualToString:@""]) {
                [[YYYCommunication sharedManager] CancelJoinRequestDirectory:APPDELEGATE.sessionId directoryIds:directoryIds successed:successed failure:failure];
            }else{
                [self reloadInvitesAndBadgeValue];
            }
            
            
        } ;
        
        void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
            contactIds = @"";
            directoryIds = @"";
            [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
            [appDelegate GetContactList];
            NSLog(@"Request Cancel failed");
        } ;
        
        [[Communication sharedManager] DeleteSentInvitation:[AppDelegate sharedDelegate].sessionId emails:contactIds successed:successed failure:failure];
        
        [self onCloseEdit];
    }
}

#pragma - Web Service Part
- (void)getSentInvitationDirectory{
    if ([AppDelegate sharedDelegate].sessionId ) {
        void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
            [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
            
            if ([[_responseObject objectForKey:@"success"] boolValue])
            {
                for (NSDictionary *dic in [[_responseObject objectForKey:@"data"] objectForKey:@"data"]) {
                    [contactList addObject:dic];
                }
                NSSortDescriptor *sortDescriptor;
                sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sent_time" ascending:NO selector:@selector(localizedStandardCompare:)];
                NSMutableArray * sortDescriptors = [NSMutableArray arrayWithObject:sortDescriptor];
                [contactList sortUsingDescriptors:sortDescriptors];
                
                searchList = [contactList mutableCopy];
                
                if ([searchList count] == 0)
                    [self.tabBarItem setBadgeValue:nil];
                else
                    [self.tabBarItem setBadgeValue:[NSString stringWithFormat:@"%lu", (unsigned long)[searchList count]]];
                if ([searchList count] == 0) {
                    lblNoContact.hidden = NO;
                }else{
                    lblNoContact.hidden = YES;
                }
                if (contactSearch.text && ![contactSearch.text  isEqual: @""]) {
                    [self searchBar:contactSearch textDidChange:contactSearch.text];
                }
                if ([searchList count] > 0) {
                    btEdit.enabled = YES;
                }else {
                    btEdit.enabled = NO;
                }
                [tblForContact reloadData];
            }
        } ;
        
        void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
            [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
            
            NSLog(@"Connection failed - %@", _error);
        } ;
        [[YYYCommunication sharedManager] GetListSentRequestMemberDirectory:APPDELEGATE.sessionId pageNum:@"1" countPerPage:[NSString stringWithFormat:@"%lu", (unsigned long)[APPDELEGATE.totalList count]] successed:successed failure:failure];
    }
}
- (void)GetSentInvitation
{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    if ([AppDelegate sharedDelegate].sessionId ) {
        void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
            
            if ([[_responseObject objectForKey:@"success"] boolValue])
            {
                [contactList removeAllObjects];
                contactList = [[[_responseObject objectForKey:@"data"] objectForKey:@"results"] mutableCopy];
                [self getSentInvitationDirectory];
            }else{
                [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
            }
        } ;
        
        void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
            [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
            
            NSLog(@"Connection failed - %@", _error);
        } ;
        
        [[Communication sharedManager] GetSentInvitations:[AppDelegate sharedDelegate].sessionId successed:successed failure:failure];
    }
    
    
}

- (void)GetRequests
{
	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
		if ([[_responseObject objectForKey:@"success"] boolValue])
		{
            [tempRequest removeAllObjects];
            tempRequest = [[[_responseObject objectForKey:@"data"] objectForKey:@"results"] mutableCopy];
            [self getSentRequestDirectory];
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        NSLog(@"Connection failed - %@", _error);
    } ;
    
    [[Communication sharedManager] GetRequests:[AppDelegate sharedDelegate].sessionId successed:successed failure:failure];
}
- (void)getSentRequestDirectory{
    if ([AppDelegate sharedDelegate].sessionId ) {
        void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
            if ([[_responseObject objectForKey:@"success"] boolValue])
            {
                appDelegate.isShownSpinner = NO;
                for (NSDictionary *dic in [[_responseObject objectForKey:@"data"] objectForKey:@"data"]) {
                    [tempRequest addObject:dic];
                }
                
                if ([tempRequest count] == 0)
                    [[self.tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:nil];
                else
                    [[self.tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:[NSString stringWithFormat:@"%lu", (unsigned long)[tempRequest count]]];
            }
        } ;
        
        void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
            NSLog(@"Connection failed - %@", _error);
        } ;
        [[YYYCommunication sharedManager] GetListReceivedInviteMemberDirectory:APPDELEGATE.sessionId pageNum:@"1" countPerPage:[NSString stringWithFormat:@"%lu", (unsigned long)[APPDELEGATE.totalList count]] successed:successed failure:failure];
    }
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isKindOfClass:[UIScrollView class]]) {
        return YES;
    }
    if ([searchList count] > 0) {
        return NO;
    }
    return YES;
}
- (void) hideKeyboard{
    [contactSearch resignFirstResponder];
}
@end
