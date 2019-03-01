//
//  ExchangedViewController.m
//  Ginko
//
//  Created by Qi Song on 29/3/14.
//  Copyright (c) 2014 Qi Song. All rights reserved.
//
// --- Headers ---;
#import "ExchangedViewController.h"
#import "ExchangedInfoCell.h"
#import "SettingViewController.h"
#import "ProfileRequestController.h"
#import "YYYCommunication.h"
#import "YYYChatViewController.h"
#import "TabBarController.h"
#import "PreviewProfileViewController.h"
#import "UIImage+Tint.h"
#import "ProfileViewController.h"


// --- Defines ---;
static NSString * const ExchangedInfoCellIdentifier = @"ExchangedInfoCell";

// ExchangedViewController Class;
@interface ExchangedViewController ()

@end

@implementation ExchangedViewController

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
    
//    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:230.0/256.0 green:1.0f blue:190.0/256.0 alpha:1.0f];
    // Table View;
    [tblForContact registerNib:[UINib nibWithNibName:ExchangedInfoCellIdentifier bundle:nil] forCellReuseIdentifier:ExchangedInfoCellIdentifier];
    
    contactList = [[NSMutableArray alloc] init];
    searchList = [[NSMutableArray alloc] init];
//    if (appDelegate.locationFlag == NO)
//    {
//        [contactList removeAllObjects];
//        [searchList removeAllObjects];
//    }
    
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    contactList = [appDelegate.exchangedList mutableCopy];
    searchList = [contactList mutableCopy];
    
    tblForContact.allowsMultipleSelectionDuringEditing = YES;
    [self.navigationItem setHidesBackButton:YES animated:NO];
    contactIds = @"";
    entityIds = @"";
    
    [trashBut setImage:[[UIImage imageNamed:@"TrashIcon"] tintImageWithColor:[UIColor blackColor]] forState:UIControlStateNormal];
    
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    // back button will not have title
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:LOCATION_CHANGE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveContactListNotification:) name:GET_CONTACTLIST_NOTIFICATION object:nil];
}

- (void)receiveContactListNotification:(NSNotification *) notification
{
    NSLog(@"Received notification");

    if (appDelegate.isGPSOn && !appDelegate.thumbDown) { // if thumb is up, turn off gps
        [appDelegate changeGPSSetting:0];
        appDelegate.isGPSOn = NO;
    } else {
        NSDictionary * dict = notification.userInfo;
        contactList = [dict objectForKey:@"ExchangedList"];
        searchList = [contactList mutableCopy];
        
        [tblForContact reloadData];
    }
}

- (void)receiveNotification:(NSNotification *) notification
{
    [self displayGPSButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:navView];
    
    [self displayGPSButton];
    contactList = appDelegate.exchangedList;
    searchList = [contactList mutableCopy];
    [tblForContact reloadData];
    contactSearch.text = @"";
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [navView removeFromSuperview];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LOCATION_CHANGE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GET_CONTACTLIST_NOTIFICATION object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)goBackBut
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)displayGPSButton
{
    if (appDelegate.locationFlag)
    {
        [gpsBut setImage:[UIImage imageNamed:@"GPSOn"] forState:UIControlStateNormal];
        if (appDelegate.intervalIndex != 0) {
            lblOn1.hidden = NO;
        } else lblOn1.hidden = YES;
        [(TabBarController *)self.tabBarController changeThumbEnabled:NO];
    }
    else {
        [gpsBut setImage:[UIImage imageNamed:@"GPSOff"] forState:UIControlStateNormal];
        lblOn1.hidden = YES;
        [(TabBarController *)self.tabBarController changeThumbEnabled:YES];
    }
}


- (void)onGPSBut
{
    if (appDelegate.locationFlag)
    {
        if (appDelegate.intervalIndex == 0) {
            [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeClear];
            [appDelegate changeGPSSetting:2];
        } else if (appDelegate.intervalIndex == 1) {
            [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeClear];
            [appDelegate changeGPSSetting:0];
        }
    }
    else {
        [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeClear];
        [appDelegate changeGPSSetting:1];
    }
//    SettingViewController * controller = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
//    [self.navigationController pushViewController:controller animated:YES];
}

- (void)onEdit
{
    gpsBut.hidden = YES;
    backBut.hidden = YES;
    closeBut.hidden = NO;
    lblOn1.hidden = YES;
    trashBut.hidden = NO;
    trashBut.enabled = NO;
    [self.navigationItem setHidesBackButton:YES animated:NO];
    [tblForContact setEditing:YES animated:YES];
    
    // disable tab bar buttons
    [(TabBarController *)self.tabBarController enableButtons:NO];
}

- (void)onCloseEdit
{
    gpsBut.hidden = NO;
    backBut.hidden = NO;
    closeBut.hidden = YES;
//    lblOn1.hidden = NO;
    trashBut.hidden = YES;
    [tblForContact setEditing:NO animated:YES];
    
    // enable tab bar buttons
    [(TabBarController *)self.tabBarController enableButtons:YES];
    
    [self displayGPSButton];
    
}

- (void)onTrash
{
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"Delete Sprout Contact(s)" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Delete contact(s) permanently", @"Delete contact(s) for 24 hours", nil];
    actionSheet.delegate = self;
    [actionSheet showFromTabBar:[[self tabBarController] tabBar]];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    lblSorry.hidden = ([searchList count] > 0);
    NSString *badgeValue = [@(searchList.count) stringValue];
//    [self.tabBarItem setBadgeValue:badgeValue];
    TabBarController *tbc = (TabBarController*)self.tabBarController;
    [tbc setBadgeOnItem:0 value:badgeValue];
    return [searchList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([searchList count] < indexPath.row + 1)
    {
        return nil;
    }
    ExchangedInfoCell *cell = [tblForContact dequeueReusableCellWithIdentifier:ExchangedInfoCellIdentifier forIndexPath:indexPath];
    if (cell == nil)
    {
        cell = [[ExchangedInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ExchangedInfoCellIdentifier];
    }
    
    NSDictionary * dict = [searchList objectAtIndex:indexPath.row];
    NSString * firstName = [dict objectForKey:@"first_name"];
    NSString * lastName = [dict objectForKey:@"last_name"];
    [cell setPhoto:[dict objectForKey:@"profile_image"]];
    cell.username.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    cell.contactId = [dict objectForKey:@"contact_id"];
    
    [cell setPingLocation:[[dict objectForKey:@"latitude"] floatValue] pingLongitude:[[dict objectForKey:@"longitude"] floatValue]];
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setTimeZone:[NSTimeZone localTimeZone]];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate * lastTime = [df dateFromString:[dict objectForKey:@"found_time"]];
    [df setDateFormat:@"MMMM dd, yyyy"];
    NSString * lastDate = [df stringFromDate:lastTime];
    cell.lastDate.text = lastDate;
    
    cell.contactInfo = dict;
    
    cell.sessionId = @"";
    if ([[dict objectForKey:@"sharing_status"] integerValue] != 4)
        [cell.btnPhone setImage:[UIImage imageNamed:@"BtnPhone.png"] forState:UIControlStateNormal];
    else
        [cell.btnPhone setImage:[UIImage imageNamed:@"EditContact.png"] forState:UIControlStateNormal];
    
    cell.arrPhone = [self GetPhonesFromPurple:dict];
    
    // Set;
    cell.delegate = self;
    return cell;
}

- (NSMutableArray *)GetPhonesFromPurple : (NSDictionary *)_dict
{
    NSArray * homeArray = [[_dict objectForKey:@"home"] objectForKey:@"fields"];
    NSArray * workArray = [[_dict objectForKey:@"work"] objectForKey:@"fields"];
    
    NSMutableArray *arrPhone = [[NSMutableArray alloc] init];
    
    for (int i = 0 ; i < [homeArray count] ; i++)
    {
        NSDictionary * dict = [homeArray objectAtIndex:i];
        if ([[dict objectForKey:@"field_type"] isEqualToString:@"phone"] || [[dict objectForKey:@"field_name"] isEqualToString:@"Mobile"] || [[dict objectForKey:@"field_name"] isEqualToString:@"Mobile#2"] || [[dict objectForKey:@"field_name"] isEqualToString:@"Phone#2"] || [[dict objectForKey:@"field_name"] isEqualToString:@"Phone#3"])
            [arrPhone addObject:[dict objectForKey:@"field_value"]];
    }
    
    for (int i = 0 ; i < [workArray count] ; i++)
    {
        NSDictionary * dict = [workArray objectAtIndex:i];
        if ([[dict objectForKey:@"field_type"] isEqualToString:@"phone"] || [[dict objectForKey:@"field_name"] isEqualToString:@"Mobile"] || [[dict objectForKey:@"field_name"] isEqualToString:@"Mobile#2"] || [[dict objectForKey:@"field_name"] isEqualToString:@"Phone#2"] || [[dict objectForKey:@"field_name"] isEqualToString:@"Phone#3"])
            [arrPhone addObject:[dict objectForKey:@"field_value"]];
    }
    
    return arrPhone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tblForContact.editing)
    {
        trashBut.enabled = YES;
        return;
    }
    else
    {
        NSDictionary *dict = [searchList objectAtIndex:indexPath.row];

            if ([[dict objectForKey:@"sharing_status"] integerValue] == 4)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"GINKO" message:@"Oops! Contact would like to chat only" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alertView show];
                return;
            }

        [self getContactDetail:[dict objectForKey:@"contact_id"]];
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

#pragma mark - ExchangedInfoCell Delegate
- (void)didChat:(NSDictionary *)contactDict
{
    [self CreateMessageBoard:[contactDict objectForKey:@"contact_id"] dict:contactDict];
}

- (void)didEdit:(NSDictionary *)contactDict
{
    appDelegate.type = 4;
    
    if ([contactDict objectForKey:@"detected_location"] && ![[contactDict objectForKey:@"detected_location"] isEqualToString:@""])
    {
        ProfileViewController * controller = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
        controller.contactInfo = contactDict;
        [self.navigationController pushViewController:controller animated:YES];
    }else{
        ProfileRequestController * controller = [[ProfileRequestController alloc] initWithNibName:@"ProfileRequestController" bundle:nil];
        controller.contactInfo = contactDict;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

-(void)CreateMessageBoard:(NSString*)ids dict:(NSDictionary *)contactInfo
{
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
	
	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        
		[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
		
		if ([[_responseObject objectForKey:@"success"] boolValue])
		{
			NSMutableArray *lstTemp = [[NSMutableArray alloc] init];
            NSMutableDictionary *dictTemp = [[NSMutableDictionary alloc] init];
            
            [dictTemp setObject:[contactInfo objectForKey:@"first_name"] forKey:@"fname"];
            [dictTemp setObject:[contactInfo objectForKey:@"last_name"] forKey:@"lname"];
            [dictTemp setObject:[contactInfo objectForKey:@"profile_image"] forKey:@"photo_url"];
            [dictTemp setObject:[contactInfo objectForKey:@"contact_id"] forKey:@"user_id"];
            
            [lstTemp addObject:dictTemp];
			
			NSMutableDictionary *dictTemp1 = [[NSMutableDictionary alloc] init];
			
			[dictTemp1 setObject:[AppDelegate sharedDelegate].firstName forKey:@"fname"];
			[dictTemp1 setObject:[AppDelegate sharedDelegate].lastName forKey:@"lname"];
			[dictTemp1 setObject:[AppDelegate sharedDelegate].photoUrl forKey:@"photo_url"];
			[dictTemp1 setObject:[AppDelegate sharedDelegate].userId forKey:@"user_id"];
			
			[lstTemp addObject:dictTemp1];
            
            YYYChatViewController *viewcontroller = [[YYYChatViewController alloc] initWithNibName:@"YYYChatViewController" bundle:nil];
            viewcontroller.boardid = [[_responseObject objectForKey:@"data"] objectForKey:@"board_id"];
            viewcontroller.lstUsers = [[NSMutableArray alloc] initWithArray:lstTemp];;
            [self.navigationController pushViewController:viewcontroller animated:YES];
            
		}else{
            [CommonMethods showAlertUsingTitle:@"Error!" andMessage:[[_responseObject objectForKey:@"err"] objectForKey:@"errMsg"]];
		}
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
		
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Internet Connection Error!"];
		
    } ;
    
	[[YYYCommunication sharedManager] CreateChatBoard:[AppDelegate sharedDelegate].sessionId userids:ids successed:successed failure:failure];
}

#pragma UISearchBar Delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
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
            NSString * firstName = [dict objectForKey:@"first_name"];
            NSString * lastName = [dict objectForKey:@"last_name"];
            NSRange range = [[[NSString stringWithFormat:@"%@ %@", firstName, lastName] uppercaseString] rangeOfString:[searchText uppercaseString]];
            if (range.location != NSNotFound)
                [searchList addObject:dict];
        }
        [tblForContact reloadData];
    }
    trashBut.enabled = NO;
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
    trashBut.enabled = NO;
}

- (void)touchDown
{
    NSLog(@"Touch Down");
    appDelegate.thumbDown = YES;
    appDelegate.notCallFlag = YES;
    appDelegate.isGPSOn = NO;
    [appDelegate performSelector:@selector(touchThumb) withObject:nil afterDelay:0.5f];
}

- (void)touchUp
{
    NSLog(@"Touch Up Inside");
    appDelegate.thumbDown = NO;
    if (appDelegate.notCallFlag) {
        [NSObject cancelPreviousPerformRequestsWithTarget:appDelegate selector:@selector(touchThumb) object:nil];
        return;
    }
    appDelegate.isGPSOn = YES;
    [appDelegate GetContactList]; // refresh contact list once after thumb is up
}

#pragma mark - UIActionSheetDelegate Methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSArray *selectedRows = [tblForContact indexPathsForSelectedRows];
    
    NSString *remove_type;
    
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
    
    for (int i = (int)[selectedRows count] - 1 ; i >= 0  ; i--)
    {
        NSIndexPath * selectRow = [selectedRows objectAtIndex:i];
        NSDictionary * dict = [searchList objectAtIndex:selectRow.row];
        if (![dict objectForKey:@"entity_id"]) {
            if (![contactIds isEqualToString:@""])
            {
                contactIds = [NSString stringWithFormat:@"%@,", contactIds];
            }
            contactIds = [NSString stringWithFormat:@"%@%@", contactIds, [dict objectForKey:@"contact_id"]];
        } else {
            if (![entityIds isEqualToString:@""])
            {
                entityIds = [NSString stringWithFormat:@"%@,", entityIds];
            }
            entityIds = [NSString stringWithFormat:@"%@%@", entityIds, [dict objectForKey:@"entity_id"]];
        }
        [contactList removeObjectAtIndex:selectRow.row];
    }
    
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            [appDelegate GetContactList];
        }
        contactIds = @"";
        entityIds = @"";
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        contactIds = @"";
        entityIds = @"";
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        NSLog(@"Request Cancel failed");
    };
    
    if (![contactIds isEqualToString:@""] || ![entityIds isEqualToString:@""]) {
        [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
        [[Communication sharedManager] DeleteDetectedContacts:[AppDelegate sharedDelegate].sessionId userIDs:contactIds entityIDs:entityIds remove_type:remove_type successed:successed failure:failure];
    } else {
        contactIds = @"";
        entityIds = @"";
    }
    
    searchList = [contactList mutableCopy];
    [tblForContact reloadData];
    
    [self onCloseEdit];
}

- (void)getContactDetail : (NSString *)_contactId
{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        NSLog(@"%@",_responseObject);
        if ([[_responseObject objectForKey:@"success"] boolValue])
		{
            NSDictionary *dict = [_responseObject objectForKey:@"data"];
            
            PreviewProfileViewController *vc = [[PreviewProfileViewController alloc] initWithNibName:@"PreviewProfileViewController" bundle:nil];
            vc.userData = dict;
            
            BOOL isWork;
            if ([dict[@"work"][@"fields"] count] > 0) {
                isWork = YES;
            } else {    // really new and show profile selection screen
                isWork = NO;
            }
            vc.isWork = isWork;
            vc.isViewOnly = YES;
            vc.isChat = NO;
            
            [self.navigationController pushViewController:vc animated:YES];
        }else {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSDictionary *dictError = [_responseObject objectForKey:@"err"];
            if (dictError) {
                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:[dictError objectForKey:@"errMsg"]];
                if ([[NSString stringWithFormat:@"%@",[dictError objectForKey:@"errCode"]] isEqualToString:@"350"]) {
                    [[AppDelegate sharedDelegate] GetContactList];
                }
            } else {
                [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Failed to connect to server!"];
            }
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        NSLog(@"Connection failed - %@", _error);
    } ;
    
    [[Communication sharedManager] getContactDetail:[AppDelegate sharedDelegate].sessionId contactId:_contactId contactType:@"1" successed:successed failure:failure];
}

@end
