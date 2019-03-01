//
//  NotExchangedViewController.m
//  Ginko
//
//  Created by Qi Song on 29/3/14.
//  Copyright (c) 2014 Qi Song. All rights reserved.
//
// --- Headers ---;
#import "NotExchangedViewController.h"
#import "ProfileViewController.h"
#import "SettingViewController.h"
#import "UIImageView+AFNetworking.h"
#import "TabBarController.h"
#import "YYYCommunication.h"
#import "EntityViewController.h"
#import "MainEntityViewController.h"

#import "UIImage+Tint.h"

// --- Defines ---;
static NSString * const NotExchangedInfoCellIdentifier = @"NotExchangedInfoCell";

// NotExchangedViewController Class;
@interface NotExchangedViewController ()

@end

@implementation NotExchangedViewController

@synthesize appDelegate, tblForContact;

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
    [tblForContact registerNib:[UINib nibWithNibName:NotExchangedInfoCellIdentifier bundle:nil] forCellReuseIdentifier:NotExchangedInfoCellIdentifier];
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    contactList = [[NSMutableArray alloc] init];
    searchList = [[NSMutableArray alloc] init];
    
    contactList = [appDelegate.notExchangedList mutableCopy];
    searchList = [contactList mutableCopy];
    
    tblForContact.allowsMultipleSelectionDuringEditing = YES;
    contactIds = [[NSString alloc] init];
    contactIds = @"";
    entityIds = [[NSString alloc] init];
    entityIds = @"";
    
//    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:230.0/256.0 green:1.0f blue:190.0/256.0 alpha:1.0f];
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    [trashBut setImage:[[UIImage imageNamed:@"TrashIcon"] tintImageWithColor:[UIColor blackColor]] forState:UIControlStateNormal];
    
}

- (void)receiveContactListNotification:(NSNotification *) notification
{
    NSLog(@"Received notification");

    if (appDelegate.isGPSOn && !appDelegate.thumbDown) { // if thumb is up, turn off gps
        [appDelegate changeGPSSetting:0];
        appDelegate.isGPSOn = NO;
    } else {
        NSDictionary * dict = notification.userInfo;
        contactList = [dict objectForKey:@"NotExchangedList"];
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
    contactList = appDelegate.notExchangedList;
    searchList = [contactList mutableCopy];
    [tblForContact reloadData];
    contactSearch.text = @"";
    [self setInitialBadges];//to show badge on next item
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:LOCATION_CHANGE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveContactListNotification:) name:GET_CONTACTLIST_NOTIFICATION object:nil];
    
    [appDelegate GetContactList];
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
//    [self displayGPSButton];
    
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

    // enable tab bar buttons again
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
//    NSString *badgeValue = (searchList.count > 0) ? [@(searchList.count) stringValue] : nil;
//    [self.tabBarItem setBadgeValue:badgeValue];
    NSString *badgeValue = [@(searchList.count) stringValue];
    TabBarController *tbc = (TabBarController*)self.tabBarController;
    [tbc setBadgeOnItem:1 value:badgeValue];
    lblSorry.hidden = (searchList.count > 0);
    return [searchList count];
//    return 3;
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
/*    NotExchangedInfoCell *cell = [tblForContact dequeueReusableCellWithIdentifier:NotExchangedInfoCellIdentifier forIndexPath:indexPath];
    if (cell == nil)
    {
        cell = [[NotExchangedInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NotExchangedInfoCellIdentifier];
    }
    
    switch (indexPath.row) {
        case 0:
        {
            NSString * firstName = @"Ann";
            NSString * lastName = @"Wilson";
            [cell.profileImageView setImageWithURL:[NSURL URLWithString:@"http://www.xchangewith.me/api/v2/Photos/no-face.png"]];
            BOOL pendingFlag = NO;
            cell.shareBut.selected = pendingFlag;
            cell.pingArea.hidden = pendingFlag;
            cell.lastDate.hidden = pendingFlag;
            
            cell.lastDate.text = @"April 07, 2015";
            cell.username.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            
            cell.pingArea.text = @"Chicago, IL, United States";
            
            cell.delegate = self;
            break;
        }
        case 1:
        {
            NSString * firstName = @"Jackson";
            [cell.profileImageView setImageWithURL:[NSURL URLWithString:@"http://www.xchangewith.me/api/v2/Photos/no-face.png"]];
            BOOL pendingFlag = NO;
            cell.shareBut.selected = pendingFlag;
            cell.pingArea.hidden = pendingFlag;
            cell.lastDate.hidden = pendingFlag;
            
            cell.lastDate.text = @"April 07, 2015";
            cell.username.text = firstName;
            
            cell.pingArea.text = @"Chicago, IL, United States";
            
            cell.delegate = self;
            break;
        }
        case 2:
        {
            NSString * firstName = @"Jennifer";
            NSString * lastName = @"Lee";
            [cell.profileImageView setImageWithURL:[NSURL URLWithString:@"http://www.xchangewith.me/api/v2/Photos/no-face.png"]];
            BOOL pendingFlag = NO;
            cell.shareBut.selected = pendingFlag;
            cell.pingArea.hidden = pendingFlag;
            cell.lastDate.hidden = pendingFlag;
            
            cell.lastDate.text = @"April 07, 2015";
            cell.username.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            
            cell.pingArea.text = @"Chicago, IL, United States";
            
            cell.delegate = self;
            break;
        }
            
        default:
            break;
    }
    
    return cell;
*/
    if ([searchList count] < indexPath.row + 1)
    {
        return nil;
    }
    NSDictionary * dict = [searchList objectAtIndex:indexPath.row];
    
    if ([dict objectForKey:@"entity_id"]) {
        EntityCell *cell = [tblForContact dequeueReusableCellWithIdentifier:@"EntityCell"];
        
        if(cell == nil)
        {
            cell = [EntityCell sharedCell];
        }
        
        [cell setDelegate:self] ;
        
        cell.curDict = dict;

        cell.isFollowing = NO;
        
        return cell;
    } else {
    
        NotExchangedInfoCell *cell = [tblForContact dequeueReusableCellWithIdentifier:NotExchangedInfoCellIdentifier forIndexPath:indexPath];
        if (cell == nil)
        {
            cell = [[NotExchangedInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NotExchangedInfoCellIdentifier];
        }
        
        NSString * firstName = [dict objectForKey:@"first_name"];
        NSString * lastName = [dict objectForKey:@"last_name"];
       [cell.profileImageView setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"profile_image"]]];
        BOOL pendingFlag = [[dict objectForKey:@"is_pending"] boolValue];
        cell.shareBut.selected = pendingFlag;
        cell.pingArea.hidden = pendingFlag;
        cell.lastDate.hidden = pendingFlag;
        
        NSDateFormatter * df = [[NSDateFormatter alloc] init];
        [df setTimeZone:[NSTimeZone localTimeZone]];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate * lastTime = [df dateFromString:[dict objectForKey:@"found_time"]];
        [df setDateFormat:@"MMMM dd, yyyy"];
        NSString * lastDate = [df stringFromDate:lastTime];
        cell.lastDate.text = lastDate;
        [cell setPingLocation:[[dict objectForKey:@"latitude"] floatValue] pingLongitude:[[dict objectForKey:@"longitude"] floatValue]];
        cell.contactInfo = dict;
        cell.username.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        
        cell.delegate = self;
        // Set;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tblForContact.editing)
    {
        trashBut.enabled = YES;
        return;
    }
    NSDictionary * dict = [searchList objectAtIndex:indexPath.row];
    if ([dict objectForKey:@"entity_id"]) {
        BOOL isFollowing = [[dict objectForKey:@"invite_status"] intValue];
        [self getEntityFollowerView:[dict objectForKey:@"entity_id"] following:isFollowing notes:[dict objectForKey:@"notes"]];
    } else {
        ProfileViewController * controller = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
        controller.contactInfo = dict;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

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

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *selectedRows = [tblForContact indexPathsForSelectedRows];
    if ([selectedRows count] == 0)
    {
        trashBut.enabled = NO;
    }
}

#pragma mark - UISearchBar Delegate

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
            if ([dict objectForKey:@"entity_id"]) {
                NSString* entityName = [[dict objectForKey:@"name"] uppercaseString];
                NSString* entitySearchWord = [[dict objectForKey:@"search_words"] uppercaseString];
                if ([entityName rangeOfString:[searchText uppercaseString]].location == NSNotFound) {
                    if ([entitySearchWord rangeOfString:[searchText uppercaseString]].location == NSNotFound){
                        
                    }
                    else
                        [searchList addObject:dict];
                }
                else
                    [searchList addObject:dict];
            } else {
                NSString * firstName = [dict objectForKey:@"first_name"];
                NSString * lastName = [dict objectForKey:@"last_name"];
                NSRange range = [[[NSString stringWithFormat:@"%@ %@", firstName, lastName] uppercaseString] rangeOfString:[searchText uppercaseString]];
                if (range.location != NSNotFound)
                    [searchList addObject:dict];
            }
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

#pragma mark - Actions

- (IBAction)touchDownThumb:(id)sender
{
    NSLog(@"Touch Down");
    appDelegate.notCallFlag = YES;
    [self performSelector:@selector(touchThumb) withObject:nil afterDelay:0.5f];
}

- (IBAction)touchUpInside:(id)sender
{
    NSLog(@"Touch Up Inside");
    if (appDelegate.notCallFlag) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(touchThumb) object:nil];
//        return;
    }
    
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

#pragma mark - Function

- (void)setInitialBadges {
    TabBarController *tbc = (TabBarController*)self.tabBarController;
    [tbc setBadgeOnItem:0 value:[@(appDelegate.exchangedList.count) stringValue]];
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
        [searchList removeObject:dict];
        [contactList removeObject:dict];
        [appDelegate.contactList removeObject:dict];
        [appDelegate.notExchangedList removeObject:dict];
    }
    
    
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        contactIds = @"";
        entityIds = @"";
        [tblForContact reloadData];
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        contactIds = @"";
        entityIds = @"";
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        [appDelegate GetContactList];
    } ;
    
    if (![contactIds isEqualToString:@""] || ![entityIds isEqualToString:@""]) {
        [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
        [[Communication sharedManager] DeleteDetectedContacts:[AppDelegate sharedDelegate].sessionId userIDs:contactIds entityIDs:entityIds remove_type:remove_type successed:successed failure:failure];
    } else {
        contactIds = @"";
        entityIds = @"";
    }
    
    searchList = [contactList mutableCopy];
    
    [self onCloseEdit];
}

@end
