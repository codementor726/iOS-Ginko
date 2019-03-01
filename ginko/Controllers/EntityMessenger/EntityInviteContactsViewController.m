//
//  EntityInviteContactsViewController.m
//  GINKO
//
//  Created by mobidev on 7/24/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import "EntityInviteContactsViewController.h"
#import "SearchCell.h"
#import "YYYCommunication.h"
#import "UIImage+Tint.h"

#import "VideoVoiceConferenceViewController.h"

#import "YYYChatViewController.h"

@interface EntityInviteContactsViewController ()<UIGestureRecognizerDelegate>
{
    NSMutableArray *arrContacts;
    NSMutableArray *arrNormalContacts;
    NSMutableArray *arrInvitedContacts;
    NSMutableArray *arrAcceptedContacts;
    NSMutableArray *arrFilteredList;
    
    NSMutableArray *arrSelectedNormal;
    NSMutableArray *arrSelectedInvited;
    NSMutableArray *arrSelectedAccepted;
    int inviteStatus;
}
@end

@implementation EntityInviteContactsViewController
@synthesize navView, btnDone;
@synthesize btnSelectAll, searchBarForList, tblForContact, viewBottom, viewDelete;
@synthesize btnAccepted, btnAllContacts, btnInvited;
@synthesize entityID;
@synthesize navBarColor;
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
    
    [_trashButton setImage:[[UIImage imageNamed:@"TrashIcon"] tintImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    if (navBarColor) {
        navView.backgroundColor = self.navigationController.navigationBar.barTintColor;
        
        _backButton.tintColor = btnDone.tintColor = _navigationTextLabel.textColor = self.navigationController.navigationBar.tintColor;
        //[btnDone setImage:[UIImage imageNamed:@"Checkmark"] forState:UIControlStateNormal]
        
    }else{
        [self.navigationController.navigationBar setBarTintColor:COLOR_GREEN_THEME];
    }
    arrContacts = [[NSMutableArray alloc] init];
    arrNormalContacts = [[NSMutableArray alloc] init];
    arrInvitedContacts = [[NSMutableArray alloc] init];
    arrAcceptedContacts = [[NSMutableArray alloc] init];
    arrFilteredList = [[NSMutableArray alloc] init];
    
    arrSelectedNormal = [[NSMutableArray alloc] init];
    arrSelectedInvited = [[NSMutableArray alloc] init];
    arrSelectedAccepted = [[NSMutableArray alloc] init];
    
    btnSelectAll.selected = NO;
    NSString * SearchCellIdentifier = @"SearchCell";
    [tblForContact registerNib:[UINib nibWithNibName:SearchCellIdentifier bundle:nil] forCellReuseIdentifier:SearchCellIdentifier];
    inviteStatus = 0;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    // tapGestureRecognizer.cancelsTouchesInView = NO;
    tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [tblForContact deselectRowAtIndexPath:[tblForContact indexPathForSelectedRow] animated:animated];
    [self.navigationController.navigationBar addSubview:navView];
    [self.navigationItem setHidesBackButton:YES animated:NO];
    [self.navigationController.navigationItem setHidesBackButton:YES animated:NO];
    searchBarForList.text = @"";
    
    [self getEntityContacts:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [navView removeFromSuperview];
}

- (BOOL)isShowingDoneButton
{
    
   // NSArray * selectedRows = [tblForContact indexPathsForSelectedRows];
    NSMutableArray *selectedArray = [[NSMutableArray alloc] init];
    switch (inviteStatus) {
        case 0:
            selectedArray = [arrSelectedNormal mutableCopy];
            break;
        case 1:
            selectedArray = [arrSelectedInvited mutableCopy];
            break;
        case 2:
            selectedArray = [arrSelectedAccepted mutableCopy];
            break;
    }
    
    BOOL isContain = YES;
    if ([selectedArray count] >= [arrFilteredList count] && [arrFilteredList count] > 0) {
        for (int j = 0; j < [arrFilteredList count]; j ++) {
            NSDictionary *dict = [arrFilteredList objectAtIndex:j];
            if (![selectedArray containsObject:[dict objectForKey:@"user_id"]]) {
                isContain = NO;
            }
        }
    }else{
        isContain = NO;
    }
    if (tblForContact.editing) {
        if ([selectedArray count] && [arrFilteredList count] > 0) {
            
            if (isContain) {
                btnSelectAll.selected = YES;
            } else {
                btnSelectAll.selected = NO;
            }
            viewDelete.hidden = NO;
        } else {
            btnSelectAll.selected = NO;
            viewDelete.hidden = YES;
        }
        return !viewBottom.hidden;
    } else {
        if ([selectedArray count]) {
            if (isContain) {
                btnSelectAll.selected = YES;
            } else {
                btnSelectAll.selected = NO;
            }
            btnDone.hidden = NO;
            return YES;
        }
        btnSelectAll.selected = NO;
        btnDone.hidden = YES;
        return NO;
    }
}

- (void)reloadContent
{
    [arrFilteredList removeAllObjects];
    btnInvited.selected = NO;
    btnAccepted.selected = NO;
    btnAllContacts.selected = NO;
    switch (inviteStatus) {
        case 0:
            btnAllContacts.selected = YES;
            arrFilteredList = [[NSMutableArray alloc] initWithArray:arrNormalContacts];
            _navigationTextLabel.text = @"Invite Contact(s)";
            break;
        case 1:
            btnInvited.selected = YES;
            arrFilteredList = [[NSMutableArray alloc] initWithArray:arrInvitedContacts];
            _navigationTextLabel.text = @"Pending";
            break;
        case 2:
            btnAccepted.selected = YES;
            arrFilteredList = [[NSMutableArray alloc] initWithArray:arrAcceptedContacts];
            _navigationTextLabel.text = @"Confirmed";
            break;
        default:
            break;
    }
    
    if (inviteStatus == 0) {
        [tblForContact setEditing:NO];
    } else {
        [tblForContact setEditing:YES];
    }
    
    [tblForContact reloadData];
    [self isShowingDoneButton];
}

#pragma mark - Scroll View Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [searchBarForList resignFirstResponder];
}

#pragma mark - UITableView DataSource, Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrFilteredList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 82.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * SearchCellIdentifier = @"SearchCell";
    SearchCell *cell = [tblForContact dequeueReusableCellWithIdentifier:SearchCellIdentifier forIndexPath:indexPath];
    
    if (cell == nil)
    {
        cell = [[SearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SearchCellIdentifier];
    }
    
    if (inviteStatus != 0) {
        CGRect frmImage = cell.profileImageView.frame;
        if (frmImage.origin.x <= 14) {
            frmImage.origin.x += 10;
            cell.profileImageView.frame = frmImage;
            CGRect frmFirstName = cell.firstName.frame;
            frmFirstName.origin.x += 10;
            cell.firstName.frame = frmFirstName;
            CGRect frmLastName = cell.lastName.frame;
            frmLastName.origin.x += 10;
            cell.lastName.frame = frmLastName;
        }
    } else {
        CGRect frmImage = cell.profileImageView.frame;
        if (frmImage.origin.x > 14) {
            frmImage.origin.x -= 10;
            cell.profileImageView.frame = frmImage;
            CGRect frmFirstName = cell.firstName.frame;
            frmFirstName.origin.x -= 10;
            cell.firstName.frame = frmFirstName;
            CGRect frmLastName = cell.lastName.frame;
            frmLastName.origin.x -= 10;
            cell.lastName.frame = frmLastName;
        }
    }
    
    NSString * firstName = @"";
    NSString * middleName = @"";
    NSString * lastName = @"";
    
    NSDictionary *dict = [arrFilteredList objectAtIndex:indexPath.row];
    firstName = [dict objectForKey:@"fname"];
    middleName = [dict objectForKey:@"mname"];
    lastName = [dict objectForKey:@"lname"];
    
    [cell setPhoto:[dict objectForKey:@"photo_url"]];
    cell.firstName.text = [NSString stringWithFormat:@"%@ %@",firstName, middleName];
    cell.lastName.text = lastName;
    cell.actionBtn.hidden = YES;
    cell.lblCaption.hidden = YES;
    
    switch (inviteStatus) {
        case 0:
            if ([arrSelectedNormal containsObject:[dict valueForKey:@"user_id"]]) {
                [tableView selectRowAtIndexPath:indexPath
                                       animated:NO
                                 scrollPosition:UITableViewScrollPositionNone];
            }
            break;
        case 1:
            if ([arrSelectedInvited containsObject:[dict valueForKey:@"user_id"]]) {
                [tableView selectRowAtIndexPath:indexPath
                                       animated:NO
                                 scrollPosition:UITableViewScrollPositionNone];
            }
            break;
        case 2:
            if ([arrSelectedAccepted containsObject:[dict valueForKey:@"user_id"]]) {
                [tableView selectRowAtIndexPath:indexPath
                                       animated:NO
                                 scrollPosition:UITableViewScrollPositionNone];
            }
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [searchBarForList resignFirstResponder];
    switch (inviteStatus) {
        case 0:
            [arrSelectedNormal addObject:[[arrFilteredList objectAtIndex:indexPath.row] valueForKey:@"user_id"]];
            break;
        case 1:
            [arrSelectedInvited addObject:[[arrFilteredList objectAtIndex:indexPath.row] valueForKey:@"user_id"]];
            break;
        case 2:
            [arrSelectedAccepted addObject:[[arrFilteredList objectAtIndex:indexPath.row] valueForKey:@"user_id"]];
            break;
    }
    
    [self isShowingDoneButton];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [searchBarForList resignFirstResponder];
    switch (inviteStatus) {
        case 0:
            [arrSelectedNormal removeObject:[[arrFilteredList objectAtIndex:indexPath.row] valueForKey:@"user_id"]];
            break;
        case 1:
            [arrSelectedInvited removeObject:[[arrFilteredList objectAtIndex:indexPath.row] valueForKey:@"user_id"]];
            break;
        case 2:
            [arrSelectedAccepted removeObject:[[arrFilteredList objectAtIndex:indexPath.row] valueForKey:@"user_id"]];
            break;
    }
    
    [self isShowingDoneButton];
}

#pragma - SearchBar Delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    
    [self reloadContent];
    [tblForContact reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBarForList resignFirstResponder];
    //[self getSearchContacts:searchBar.text];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText isEqualToString:@""]) {
        [self reloadContent];
        [tblForContact reloadData];
        return;
    }
    
    NSDictionary *dict;
    NSString *firstName, *middleName, *lastName;
    
    [arrFilteredList removeAllObjects];
    
    for (int i = 0; i < [arrContacts count]; i++)
    {
        dict = [arrContacts objectAtIndex:i];
        
        if ([[dict objectForKey:@"invite_status"] intValue] != inviteStatus) {
            continue;
        }
        
        firstName = [[dict objectForKey:@"fname"] uppercaseString];
        middleName = [[dict objectForKey:@"mname"] uppercaseString];
        lastName = [[dict objectForKey:@"lname"] uppercaseString];
        
        if ([firstName rangeOfString:[searchText uppercaseString]].location == NSNotFound) {
            if ([middleName rangeOfString:[searchText uppercaseString]].location == NSNotFound) {
                if ([lastName rangeOfString:[searchText uppercaseString]].location == NSNotFound) {
                }
                else
                    [arrFilteredList addObject:dict];
            }
            else
                [arrFilteredList addObject:dict];
        }
        else
            [arrFilteredList addObject:dict];
    }
    
    [tblForContact reloadData];
    [self isShowingDoneButton];
}
#pragma mark - WebApi Integration
- (void)getEntityContacts:(BOOL)isAccepted
{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        [arrContacts removeAllObjects];
        [arrFilteredList removeAllObjects];
        [arrNormalContacts removeAllObjects];
        [arrInvitedContacts removeAllObjects];
        [arrAcceptedContacts removeAllObjects];
        if ([[_responseObject objectForKey:@"success"] boolValue])
		{
            for (NSDictionary *dict in [[_responseObject objectForKey:@"data"] objectForKey:@"data"]) {
                [arrContacts addObject:dict];
                switch ([[dict objectForKey:@"invite_status"] intValue]) {
                    case 0:
                        [arrNormalContacts addObject:dict];
                        break;
                    case 1:
                        [arrInvitedContacts addObject:dict];
                        break;
                    case 2:
                        [arrAcceptedContacts addObject:dict];
                        break;
                    default:
                        break;
                }
            }
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"fname" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSMutableArray * sortDescriptors = [NSMutableArray arrayWithObject:sortDescriptor];
            [arrContacts sortUsingDescriptors:sortDescriptors];
            [arrNormalContacts sortUsingDescriptors:sortDescriptors];
            [arrInvitedContacts sortUsingDescriptors:sortDescriptors];
            [arrAcceptedContacts sortUsingDescriptors:sortDescriptors];
            
            [self reloadContent];
//            arrFilteredList = [[NSMutableArray alloc] initWithArray:arrContacts];
            
//            [tblForContact reloadData];
//            [self isShowingDoneButton];
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Internet Connection Error!"];
    } ;
    
    [[YYYCommunication sharedManager] getEntityContacts:[AppDelegate sharedDelegate].sessionId entityid:entityID invited:isAccepted ? @"true" : @"false" successed:successed failure:failure];
}

- (void)inviteFriends : (NSString *)contact_uids
{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        NSDictionary *result = _responseObject;
        if ([[result objectForKey:@"success"] boolValue]) {
            [self.navigationController popViewControllerAnimated:YES];
            
        } else {
            NSDictionary *dictError = [result objectForKey:@"err"];
            if (dictError) {
                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:[dictError objectForKey:@"errMsg"]];
            } else {
                [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Failed to connect to server!"];
            }
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Internet Connection Error!"];
    } ;
    
    [[YYYCommunication sharedManager] InviteEntityFriends:[AppDelegate sharedDelegate].sessionId entityid:entityID contacts:contact_uids successed:successed failure:failure];

}


- (void)deleteFollowers : (NSString *)contact_uids
{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        NSDictionary *result = _responseObject;
        if ([[result objectForKey:@"success"] boolValue]) {
            [tblForContact deselectRowAtIndexPath:[tblForContact indexPathForSelectedRow] animated:NO];
            switch (inviteStatus) {
                case 0:
                    break;
                case 1:
                    [arrSelectedInvited removeAllObjects];
                    break;
                case 2:
                    [arrSelectedAccepted removeAllObjects];
                    break;
            }
            inviteStatus = 0;
            viewDelete.hidden = YES;
            searchBarForList.text = @"";
            btnSelectAll.selected = NO;
            [self getEntityContacts:NO];
            
        } else {
            NSDictionary *dictError = [result objectForKey:@"err"];
            if (dictError) {
                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:[dictError objectForKey:@"errMsg"]];
            } else {
                [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Failed to connect to server!"];
            }
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Internet Connection Error!"];
    } ;
    
    [[YYYCommunication sharedManager] deleteFollowers:[AppDelegate sharedDelegate].sessionId entityid:entityID contacts:contact_uids successed:successed failure:failure];
    
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        NSArray * selectedRows = [tblForContact indexPathsForSelectedRows];
        NSString *strIDs = @"";
        for (int i = 0 ; i < [selectedRows count] ; i++)
        {
            NSIndexPath * indexPath = [selectedRows objectAtIndex:i];
            NSDictionary *dict = [arrFilteredList objectAtIndex:indexPath.row];
            strIDs = [NSString stringWithFormat:@"%@%@,", strIDs, [dict objectForKey:@"user_id"]];
        }
        if ([strIDs length]) {
            strIDs = [strIDs substringToIndex:[strIDs length] - 1];
        }
        [self deleteFollowers:strIDs];
    }
}

#pragma mark = Actions
- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onDone:(id)sender
{
    if (btnDone.hidden) {
        return;
    }
    NSString *strIDs = @"";
    for (int i = 0; i < [arrNormalContacts count]; i ++) {
        NSDictionary *dict = [arrNormalContacts objectAtIndex:i];
        if ([arrSelectedNormal containsObject:[dict valueForKey:@"user_id"]]) {
            strIDs = [NSString stringWithFormat:@"%@%@,", strIDs, [dict objectForKey:@"user_id"]];
        }
    }
    
//    NSArray * selectedRows = [tblForContact indexPathsForSelectedRows];
//    NSString *strIDs = @"";
//    for (int i = 0 ; i < [selectedRows count] ; i++)
//    {
//        NSIndexPath * indexPath = [selectedRows objectAtIndex:i];
//        NSDictionary *dict = [arrFilteredList objectAtIndex:indexPath.row];
//        strIDs = [NSString stringWithFormat:@"%@%@,", strIDs, [dict objectForKey:@"user_id"]];
//    }
    if ([strIDs length]) {
        strIDs = [strIDs substringToIndex:[strIDs length] - 1];
    }
    [self inviteFriends:strIDs];
}
- (IBAction)onSelectAll:(id)sender
{
//    if (inviteStatus != 0) {
//        return;
//    }
    switch (inviteStatus) {
        case 0:
            [arrSelectedNormal removeAllObjects];
            break;
        case 1:
            [arrSelectedInvited removeAllObjects];
            break;
        case 2:
            [arrSelectedAccepted removeAllObjects];
            break;
    }
    for (int i=0; i<[arrFilteredList count]; i++) {
        if (btnSelectAll.selected) {
            [tblForContact deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO];
        } else {
            [tblForContact selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            switch (inviteStatus) {
                case 0:
                    [arrSelectedNormal addObject:[[arrFilteredList objectAtIndex:i] valueForKey:@"user_id"]];
                    break;
                case 1:
                    [arrSelectedInvited addObject:[[arrFilteredList objectAtIndex:i] valueForKey:@"user_id"]];
                    break;
                case 2:
                    [arrSelectedAccepted addObject:[[arrFilteredList objectAtIndex:i] valueForKey:@"user_id"]];
                    break;
            }
        }
    }
    [self isShowingDoneButton];
}

- (IBAction)onAcceptedContacts:(id)sender
{
    if (inviteStatus == 2) {
        return;
    }
    btnDone.hidden = YES;
    inviteStatus = 2;
    //[arrSelectedAccepted removeAllObjects];
    [self reloadContent];
    [self filteredSearch:searchBarForList.text];
}

- (IBAction)onInvitedContacts:(id)sender
{
    if (inviteStatus == 1) {
        return;
    }
    btnDone.hidden = YES;
    inviteStatus = 1;
    //[arrSelectedInvited removeAllObjects];
    [self reloadContent];
    [self filteredSearch:searchBarForList.text];
}

- (IBAction)onAllContacts:(id)sender
{
    if (inviteStatus == 0) {
        return;
    }
    inviteStatus = 0;
   // [arrSelectedNormal removeAllObjects];
    
    [self reloadContent];
    [self filteredSearch:searchBarForList.text];
}
- (void)filteredSearch:(NSString *)key{
    if ([key isEqualToString:@""]) {
        [self reloadContent];
        [tblForContact reloadData];
        return;
    }
    
    NSDictionary *dict;
    NSString *firstName, *middleName, *lastName;
    
    [arrFilteredList removeAllObjects];
    
    for (int i = 0; i < [arrContacts count]; i++)
    {
        dict = [arrContacts objectAtIndex:i];
        
        if ([[dict objectForKey:@"invite_status"] intValue] != inviteStatus) {
            continue;
        }
        
        firstName = [[dict objectForKey:@"fname"] uppercaseString];
        middleName = [[dict objectForKey:@"mname"] uppercaseString];
        lastName = [[dict objectForKey:@"lname"] uppercaseString];
        
        if ([firstName rangeOfString:[key uppercaseString]].location == NSNotFound) {
            if ([middleName rangeOfString:[key uppercaseString]].location == NSNotFound) {
                if ([lastName rangeOfString:[key uppercaseString]].location == NSNotFound) {
                }
                else
                    [arrFilteredList addObject:dict];
            }
            else
                [arrFilteredList addObject:dict];
        }
        else
            [arrFilteredList addObject:dict];
    }
    
    [tblForContact reloadData];
    [self isShowingDoneButton];
}
- (IBAction)onDelete:(id)sender
{
    NSArray * selectedRows = [tblForContact indexPathsForSelectedRows];
    NSString *alertStr = @"";
    if ([selectedRows count] == 1) {
        alertStr = @"Do you want to delete this invite?";
    }else{
        alertStr = @"Do you want to delete this invites?";
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:alertStr delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    alert.delegate = self;
    [alert show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isKindOfClass:[UIScrollView class]]) {
        return YES;
    }
    if ([arrFilteredList count] > 0) {
        return NO;
    }
    return YES;
}
- (void) hideKeyboard{
    [searchBarForList resignFirstResponder];
}
- (void)movePushNotificationChatViewController:(NSNumber *)boardID isDeletedFriend:(BOOL)isDetetedFriend users:(NSMutableArray *)lstUsers isDirectory:(NSDictionary *)directoryInfo{
    YYYChatViewController *viewcontroller = [[YYYChatViewController alloc] initWithNibName:@"YYYChatViewController" bundle:nil];
    viewcontroller.isDeletedFriend = isDetetedFriend;
    viewcontroller.boardid = boardID;
    viewcontroller.lstUsers = lstUsers;
    BOOL isMembersSameDirectory = NO;
    if ([[directoryInfo objectForKey:@"is_group"] boolValue]) {//directory chat for members
        viewcontroller.isDeletedFriend = NO;
        viewcontroller.groupName = [directoryInfo objectForKey:@"board_name"];
        viewcontroller.isMemberForDiectory = YES;
        viewcontroller.isDirectory = YES;
    }else{
        viewcontroller.lstUsers = lstUsers;
        
        viewcontroller.isDeletedFriend = YES;
        for (NSDictionary *memberDic in directoryInfo[@"members"]) {
            if ([memberDic[@"in_same_directory"] boolValue]) {
                isMembersSameDirectory = YES;
            }
        }
        if (isMembersSameDirectory) {
            viewcontroller.isDeletedFriend = NO;
            viewcontroller.groupName = [directoryInfo objectForKey:@"board_name"];
            viewcontroller.isMemberForDiectory = YES;
            viewcontroller.isDirectory = NO;
        }
    }
    [self.navigationController pushViewController:viewcontroller animated:YES];
}
- (void)movePushNotificationConferenceViewController:(NSDictionary *)dic{
    VideoVoiceConferenceViewController *vc = [[VideoVoiceConferenceViewController alloc] initWithNibName:@"VideoVoiceConferenceViewController" bundle:nil];
    vc.infoCalling = dic;
    vc.boardId = [dic objectForKey:@"board_id"];
    if ([[dic objectForKey:@"callType"] integerValue] == 1) {
        vc.conferenceType = 1;
    }else{
        vc.conferenceType = 2;
    }
    vc.conferenceName = [dic objectForKey:@"uname"];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
