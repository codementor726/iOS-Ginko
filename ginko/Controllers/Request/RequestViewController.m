//
//  NotExchangedViewController.m
//  Ginko
//
//  Created by Qi Song on 29/3/14.
//  Copyright (c) 2014 Qi Song. All rights reserved.
//
// --- Headers ---;
#import "RequestViewController.h"
#import "ProfileRequestController.h"
#import "SettingViewController.h"

#import "YYYCommunication.h"
#import "EntityViewController.h"

#import "UIImage+Tint.h"

#import "TabRequestController.h"

#import "MainEntityViewController.h"
#import "ProfileViewController.h"
// --- Defines ---;
static NSString * const RequestInfoCellIdentifier = @"RequestInfoCell";

// RequestViewController Class;
@interface RequestViewController ()<UIGestureRecognizerDelegate>{
    BOOL isEditing;
    NSMutableArray *arrSelectedContacts;
    NSMutableArray *arrSelectedEntitys;
    NSMutableArray *arrSelectedDirectorys;
    
    BOOL isCalling;
    BOOL isCallingToInvite;
}

@end

@implementation RequestViewController

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
    arrSelectedEntitys = [[NSMutableArray alloc] init];
    arrSelectedDirectorys = [[NSMutableArray alloc] init];
    
    // Table View;
    [tblForContact registerNib:[UINib nibWithNibName:RequestInfoCellIdentifier bundle:nil] forCellReuseIdentifier:RequestInfoCellIdentifier];
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    tempInvite = [[NSMutableArray alloc] init];
    tempSent = [[NSMutableArray alloc] init];
    contactList = [[NSMutableArray alloc] init];
    searchList = [[NSMutableArray alloc] init];
    
    tblForContact.allowsMultipleSelectionDuringEditing = YES;
    contactIds = [[NSString alloc] init];
    contactIds = @"";
    entityIds = @"";
    directoryIds = @"";
    
    isCalling = NO;
    isCallingToInvite = NO;
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    [trashBut setImage:[[UIImage imageNamed:@"TrashIcon"] tintImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];

    self.navigationItem.title = @"Requests";
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
   // tapGestureRecognizer.cancelsTouchesInView = NO;
    tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:navView];
    
    [AppDelegate sharedDelegate].isRequestScreen = YES;
    appDelegate.type = 0;
    
    if (appDelegate.approveFlag)
    {
//        self.tabBarController.selectedIndex = 1;
        appDelegate.approveFlag = NO;
    }

    //[self GetSentInvitation];
    [self reloadRequestsAndBadgeValue];
}
- (void)reloadRequestsAndBadgeValue{
    [self GetSentInvitation];
    [self GetRequests];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadRequestsAndBadgeValue) name:CONTACT_SYNC_NOTIFICATION object:nil];
    
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
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CONTACT_SYNC_NOTIFICATION object:nil];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [AppDelegate sharedDelegate].isRequestScreen = NO;
    [navView removeFromSuperview];
    
    [tabBar removeFromSuperview];
    [tblForContact setEditing:NO animated:YES];
    [(TabRequestController *)self.tabBarController showTabbarImage:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)reloadContacts {

}
-(void)goBackBut
{
    [self.navigationController popViewControllerAnimated:YES];
    if (appDelegate.isCreateEntityViewController) {
        [self.navigationController.navigationBar setBarTintColor:COLOR_PURPLE_THEME];
    }
    appDelegate.isCreateEntityViewController = NO;
}
- (void)setTrashButtonEnabled {
    NSArray *indexPaths = [tblForContact indexPathsForSelectedRows];
    trashBut.enabled = (tblForContact.editing && indexPaths.count);
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
        realCloseBut.hidden = NO;
        clearBut.hidden = NO;
        [self.tabBarController.tabBar addSubview:tabBar];
        [self.navigationItem setHidesBackButton:YES animated:NO];
        [tblForContact setEditing:YES animated:YES];
        [(TabRequestController *)self.tabBarController showTabbarImage:NO];
    }
    else{
        [btEdit setSelected:NO];
        isEditing = NO;
        backBut.hidden = NO;
        closeBut.hidden = YES;
        realCloseBut.hidden = YES;
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
    backBut.hidden = NO;
    closeBut.hidden = YES;
    realCloseBut.hidden = YES;
    clearBut.hidden = YES;
    [btEdit setSelected:NO];
    [tabBar removeFromSuperview];
    [tblForContact setEditing:NO animated:YES];
    [(TabRequestController *)self.tabBarController showTabbarImage:YES];
}

- (void)onTrash
{
//    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@" Delete Sprout Contact(s)" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Delete contact(s) permanently", @"Delete contact(s) for 24 hours", nil];
//    actionSheet.delegate = self;
//    [actionSheet showFromTabBar:[[self tabBarController] tabBar]];
    NSArray *selectedRows = [tblForContact indexPathsForSelectedRows];
    NSString *msg = @"";
    if (arrSelectedContacts.count > 0 && arrSelectedEntitys.count == 0 && arrSelectedDirectorys.count == 0) {
        if (arrSelectedContacts.count > 1) {
            msg = @"Do you want to delete contacts from the Request list?";
        }else{
            msg = @"Do you want to delete a contact from the Request list?";
        }
    }else if (arrSelectedContacts.count == 0 && arrSelectedEntitys.count > 0 && arrSelectedDirectorys.count == 0) {
        if (arrSelectedEntitys.count > 1) {
            msg = @"Do you want to delete entities from the Request list?";
        }else{
            msg = @"Do you want to delete a entity from the Request list?";
        }
    }else if (arrSelectedContacts.count == 0 && arrSelectedEntitys.count == 0 && arrSelectedDirectorys.count > 0) {
        if (arrSelectedDirectorys.count > 1) {
            msg = @"Do you want to delete directories from the Request list?";
        }else{
            msg = @"Do you want to delete a directory from the Request list?";
        }
    }else{
        if (selectedRows.count > 1) {
            msg = @"Do you want to delete contacts from the Request list?";
        }else{
            msg = @"Do you want to delete a contact from the Request list?";
        }
    }
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:msg delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [alertView setTag:101];
    [alertView show];
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
            if ([dict objectForKey:@"contact_type"]) {
                if ([dict[@"contact_type"] integerValue] == 3) {
                    if (![entityIds isEqualToString:@""])
                    {
                        entityIds = [NSString stringWithFormat:@"%@,", entityIds];
                    }
                    entityIds = [NSString stringWithFormat:@"%@%@", entityIds, dict[@"entity_id"]];
                }
                else {
                    if (![contactIds isEqualToString:@""])
                    {
                        contactIds = [NSString stringWithFormat:@"%@,", contactIds];
                    }
                    contactIds = [NSString stringWithFormat:@"%@%@", contactIds, dict[@"contact_id"]];
                }
            }else{
                if (![directoryIds isEqualToString:@""])
                {
                    directoryIds = [NSString stringWithFormat:@"%@,", directoryIds];
                }
                directoryIds = [NSString stringWithFormat:@"%@%@", directoryIds, dict[@"id"]];
            }
//            NSString *contact_id = ([dict[@"contact_type"] integerValue] == 3) ? dict[@"entity_id"] : dict[@"contact_id"];
//            contactIds = [NSString stringWithFormat:@"%@%@", contactIds, contact_id];
        }
        
        [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
        void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
            NSLog(@"%@",[_responseObject objectForKey:@"data"]);
            contactIds = @"";
            entityIds = @"";
            if (directoryIds && ![directoryIds isEqualToString:@""]) {
                void ( ^successed )( id _responseObject ) = ^( id _responseObject )
                {
                    [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
                    NSDictionary *result = _responseObject;
                    if ([[result objectForKey:@"success"] boolValue]) {
                        
                        directoryIds = @"";
                        [self reloadRequestsAndBadgeValue];
                        
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
                
                [[YYYCommunication sharedManager] RemoveJoinInviteDirectory:APPDELEGATE.sessionId directoryIds:directoryIds successed:successed failure:failure];
            }else{
                [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
                [self reloadRequestsAndBadgeValue];
            }
            
            
       
        } ;
        
        void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
            contactIds = @"";
            entityIds = @"";
            directoryIds = @"";
            [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
            [appDelegate GetContactList];
            NSLog(@"Request Cancel failed");
        } ;
        
        [[Communication sharedManager] DeleteRequest:[AppDelegate sharedDelegate].sessionId contactIds:contactIds entityIds:entityIds successed:successed failure:failure];
        
        [self onCloseEdit];
    }
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
    
    RequestInfoCell *cell = [tblForContact dequeueReusableCellWithIdentifier:RequestInfoCellIdentifier forIndexPath:indexPath];
    
    if (cell == nil)
    {
        cell = [[RequestInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RequestInfoCellIdentifier];
    }

    NSDictionary * dict = [searchList objectAtIndex:indexPath.row];
    if ([dict objectForKey:@"contact_type"]) {
        NSString * firstName = [dict objectForKey:@"first_name"];
        NSString * lastName = [dict objectForKey:@"last_name"];
        
        //    BOOL pendingFlag = [[dict objectForKey:@"is_pending"] boolValue];
        //    cell.shareBut.selected = pendingFlag;
        //    cell.pingArea.hidden = pendingFlag;
        //    cell.lastDate.hidden = pendingFlag;
        
        NSDateFormatter * df = [[NSDateFormatter alloc] init];
        [df setTimeZone:[NSTimeZone localTimeZone]];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate * lastTime = [df dateFromString:[dict objectForKey:@"create_time"]];
        if ([[dict objectForKey:@"contact_type"] integerValue] == 1) {
            lastTime = [df dateFromString:[dict objectForKey:@"request_time"]];
        }
        [df setDateFormat:@"MMMM dd, yyyy"];
        NSString * lastDate = [df stringFromDate:lastTime];
        cell.lastDate.text = lastDate;
        
        cell.contactInfo = dict;
        if ([[dict objectForKey:@"contact_type"] integerValue] == 3)
        {
            cell.username.text = [dict objectForKey:@"name"];
            cell.isEntity = YES;
            [cell setPhoto:[dict objectForKey:@"profile_image"]];
        }
        else
        {
            cell.username.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            cell.isEntity = NO;
            [cell setPhoto:[dict objectForKey:@"photo_url"]];
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
        cell.isEntity = NO;
        //cell.lastDate.hidden = YES;
    }
    
    if (tblForContact.editing)
    {
        if ([dict objectForKey:@"contact_type"]) {
            if ([[dict objectForKey:@"contact_type"] integerValue] == 3)
            {
                if ([arrSelectedEntitys containsObject:[dict objectForKey:@"entity_id"]]) {
                    [tableView selectRowAtIndexPath:indexPath
                                           animated:NO
                                     scrollPosition:UITableViewScrollPositionNone];
                }
            }else{
                if ([arrSelectedContacts containsObject:[dict objectForKey:@"contact_id"]]) {
                    [tableView selectRowAtIndexPath:indexPath
                                           animated:NO
                                     scrollPosition:UITableViewScrollPositionNone];
                }
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
        if ([dict objectForKey:@"contact_type"]) {
            if ([[dict objectForKey:@"contact_type"] integerValue] == 3)
            {
                [arrSelectedEntitys addObject:[dict objectForKey:@"entity_id"]];
            }else {
                [arrSelectedContacts addObject:[dict objectForKey:@"contact_id"]];
            }
        }else{
            [arrSelectedDirectorys addObject:[dict objectForKey:@"id"]];
        }
        return;
    }
    
    if ([dict objectForKey:@"contact_type"]) {
        if ([[dict objectForKey:@"contact_type"] integerValue] == 3)
        {
            [self getEntityFollowerView:[dict objectForKey:@"entity_id"] following:NO notes:[dict objectForKey:@"notes"]];
        }
        else
        {
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
    }else{
            APPDELEGATE.type = 6;
            ProfileRequestController * controller = [[ProfileRequestController alloc] initWithNibName:@"ProfileRequestController" bundle:nil];
            //controller.contactInfo = contactDict;
            controller.directoryId = [dict objectForKey:@"id"];
            controller.directoryName = [dict objectForKey:@"name"];
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
    NSDictionary * dict = [searchList objectAtIndex:indexPath.row];
    if ([dict objectForKey:@"contact_type"]) {
        if ([[dict objectForKey:@"contact_type"] integerValue] == 3)
        {
            [arrSelectedEntitys removeObject:[dict objectForKey:@"entity_id"]];
        }else{
            [arrSelectedContacts removeObject:[dict objectForKey:@"contact_id"]];
        }
    }else{
        [arrSelectedDirectorys removeObject:[dict objectForKey:@"id"]];
    }
}

#pragma mark - Go to Entity View
//em classes
-(void)getEntityFollowerView:(NSString *)entityID following:(BOOL)isFollowing notes:(NSString *)notes
{
	void ( ^successed )( id _responseObject ) = ^( id _responseObject )
	{
        NSDictionary *result = _responseObject;
        if ([[result objectForKey:@"success"] boolValue]) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if ([_responseObject[@"data"][@"infos"] count] > 1){
                MainEntityViewController *vc = [[MainEntityViewController alloc] initWithNibName:@"MainEntityViewController" bundle:nil];
                vc.entityData = _responseObject[@"data"];
                vc.isFollowing = isFollowing;
                vc.isFavorite = [[_responseObject[@"data"] objectForKey:@"is_favorite"] boolValue];
                vc.locationsTotal = [[_responseObject[@"data"] objectForKey:@"info_total"] integerValue];
                [self.navigationController pushViewController:vc animated:YES];
            }else if ([_responseObject[@"data"][@"infos"] count] == 1){
                EntityViewController *vc = [[EntityViewController alloc] initWithNibName:@"EntityViewController" bundle:nil];
                vc.entityData = _responseObject[@"data"];
                vc.isFollowing = isFollowing;
                vc.isFavorite = [[_responseObject[@"data"] objectForKey:@"is_favorite"] boolValue];
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"GINKO" message:@"Oops! Current Entity hasn't informations!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                
                [alertView show];
            }
        } else {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSDictionary *dictError = [result objectForKey:@"err"];
            if (dictError) {
                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:[dictError objectForKey:@"errMsg"]];
                if ([[NSString stringWithFormat:@"%@",[dictError objectForKey:@"errCode"]] isEqualToString:@"700"]) {
                   [CommonMethods loadFetchAllEntityNew];
                    [[NSNotificationCenter defaultCenter] postNotificationName:CONTACT_SYNC_NOTIFICATION object:nil];
                }
            } else {
                [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Failed to connect to server!"];
            }
        }
	};
	
	void ( ^failure )( NSError* _error ) = ^( NSError* _error )
	{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
		[CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Internet Connection Error!"];
	};
	
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    //[[YYYCommunication sharedManager] GetEntityByFollowr:[AppDelegate sharedDelegate].sessionId entityid:entityID successed:successed failure:failure];
    [[YYYCommunication sharedManager] GetEntityByFollowrNew:[AppDelegate sharedDelegate].sessionId entityid:entityID infoFrom:@"0" infoCount:@"20" latitude:[AppDelegate sharedDelegate].currentLocationforMultiLocations.latitude longitude:[AppDelegate sharedDelegate].currentLocationforMultiLocations.longitude successed:successed failure:failure];
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
            tblForContact.hidden = YES;
            btEdit.enabled = NO;
        }else{
            lblNoContact.hidden = YES;
            tblForContact.hidden = NO;
            btEdit.enabled = YES;
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
            
            NSRange range_name = [[[NSString stringWithFormat:@"%@", [dict objectForKey:@"name"]] uppercaseString] rangeOfString:[searchText uppercaseString]];
            if (range_name.location != NSNotFound) {
                [searchList addObject:dict];
                continue;
            }
        }
        if ([searchList count] == 0) {
            lblNoContact.hidden = NO;
            tblForContact.hidden = YES;
            btEdit.enabled = NO;
        }else{
            lblNoContact.hidden = YES;
            tblForContact.hidden = NO;
            btEdit.enabled = YES;
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
    if ([searchList count] == 0) {
        lblNoContact.hidden = NO;
        tblForContact.hidden = YES;
        btEdit.enabled = NO;
    }else{
        lblNoContact.hidden = YES;
        tblForContact.hidden = NO;
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
    if ([contactInfo objectForKey:@"contact_type"]) {
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
    }else{
        APPDELEGATE.type = 6;
        ProfileRequestController * controller = [[ProfileRequestController alloc] initWithNibName:@"ProfileRequestController" bundle:nil];
        //controller.contactInfo = contactDict;
        controller.directoryId = [contactInfo objectForKey:@"id"];
        controller.directoryName = [contactInfo objectForKey:@"name"];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)getEntityFollow:(NSDictionary *)contactInfo{
    if ([[contactInfo objectForKey:@"contact_type"] integerValue] == 3)
    {
        [self getEntityFollowerView:[contactInfo objectForKey:@"entity_id"] following:NO notes:[contactInfo objectForKey:@"notes"]];
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
        contactIds = [NSString stringWithFormat:@"%@%@", contactIds, [dict objectForKey:@"contact_id"]];
        [searchList removeObject:dict];
        [contactList removeObject:dict];
        [appDelegate.contactList removeObject:dict];
        [appDelegate.notExchangedList removeObject:dict];
    }
    
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        NSLog(@"%@",[_responseObject objectForKey:@"data"]);
        contactIds = @"";
        NSLog(@"%@", appDelegate.contactList);
        if ([searchList count] == 0) {
            lblNoContact.hidden = NO;
            tblForContact.hidden = YES;
            btEdit.enabled = NO;
        }else{
            lblNoContact.hidden = YES;
            tblForContact.hidden = NO;
            btEdit.enabled = YES;
        }
        [tblForContact reloadData];
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        contactIds = @"";
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        appDelegate.isShownSpinner = NO;
        [appDelegate GetContactList];
        NSLog(@"Request Cancel failed");
    } ;
    
    [[Communication sharedManager] DeleteDetectedFriends:[AppDelegate sharedDelegate].sessionId contactIds:contactIds remove_type:remove_type successed:successed failure:failure];
    
    searchList = [contactList mutableCopy];
    
    [self onCloseEdit];
}

#pragma - Web Service Part
- (void)getSentRequestDirectory{
    if ([AppDelegate sharedDelegate].sessionId ) {
        void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
            [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
            
            if ([[_responseObject objectForKey:@"success"] boolValue])
            {
                isCalling = NO;
                appDelegate.isShownSpinner = NO;
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
                    tblForContact.hidden = YES;
                }else{
                    lblNoContact.hidden = YES;
                    tblForContact.hidden = NO;
                }
                if (contactSearch.text && ![contactSearch.text  isEqual: @""]) {
                    [self searchBar:contactSearch textDidChange:contactSearch.text];
                }
                if ([searchList count] == 0) {
                    btEdit.enabled = NO;
                }else{
                    btEdit.enabled = YES;
                }
                [tblForContact reloadData];
            }else{
                isCalling = NO;
                appDelegate.isShownSpinner = NO;
            }
        } ;
        
        void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
            [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
            isCalling = NO;
            appDelegate.isShownSpinner = NO;
            NSLog(@"Connection failed - %@", _error);
        } ;
        
        
        [[YYYCommunication sharedManager] GetListReceivedInviteMemberDirectory:APPDELEGATE.sessionId pageNum:@"1" countPerPage:[NSString stringWithFormat:@"%lu", (unsigned long)[APPDELEGATE.totalList count]] successed:successed failure:failure];
    }
}
- (void)GetRequests
{
    if ([AppDelegate sharedDelegate].sessionId ) {
        if (!appDelegate.isShownSpinner && appDelegate.isRequestScreen) {
            [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
            appDelegate.isShownSpinner = YES;
        }
        if (isCalling) {
            return;
        }
        
        isCalling = YES;
        void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
            
            if ([[_responseObject objectForKey:@"success"] boolValue])
            {
                [contactList removeAllObjects];
                contactList = [[[_responseObject objectForKey:@"data"] objectForKey:@"results"] mutableCopy];
                [self getSentRequestDirectory];
            }else{
                isCalling = NO;
                appDelegate.isShownSpinner = NO;
                [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
            }
        } ;
        
        void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
            [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
            appDelegate.isShownSpinner = NO;
            isCalling = NO;
            NSLog(@"Connection failed - %@", _error);
        } ;
        
        [[Communication sharedManager] GetRequests:[AppDelegate sharedDelegate].sessionId successed:successed failure:failure];
    }
}
- (void)GetSentInvitation
{
    if ([AppDelegate sharedDelegate].sessionId ) {
        if (isCallingToInvite) {
            return;
        }
        isCallingToInvite = YES;
        void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
            if ([[_responseObject objectForKey:@"success"] boolValue])
            {
                [tempSent removeAllObjects];
                tempSent = [[[_responseObject objectForKey:@"data"] objectForKey:@"results"] mutableCopy];
                
                [self getSentInvitationDirectory];
            }else{
                
                isCallingToInvite = NO;
            }
        };
        
        void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
            isCallingToInvite = NO;
            NSLog(@"Connection failed - %@", _error);
        } ;
        
        [[Communication sharedManager] GetSentInvitations:[AppDelegate sharedDelegate].sessionId successed:successed failure:failure];
    }
    
}
- (void)getSentInvitationDirectory{
    if ([AppDelegate sharedDelegate].sessionId ) {
        void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
            isCallingToInvite = NO;
            if ([[_responseObject objectForKey:@"success"] boolValue])
            {
                for (NSDictionary *dic in [[_responseObject objectForKey:@"data"] objectForKey:@"data"]) {
                    [tempSent addObject:dic];
                }
                if ([tempSent count] == 0)
                    [[self.tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:nil];
                else
                    [[self.tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:[NSString stringWithFormat:@"%lu", (unsigned long)[tempSent count]]];
            }
        } ;
        
        void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
            NSLog(@"Connection failed - %@", _error);
            isCallingToInvite = NO;
        } ;
        [[YYYCommunication sharedManager] GetListSentRequestMemberDirectory:APPDELEGATE.sessionId pageNum:@"1" countPerPage:[NSString stringWithFormat:@"%lu", (unsigned long)[APPDELEGATE.totalList count]] successed:successed failure:failure];
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
