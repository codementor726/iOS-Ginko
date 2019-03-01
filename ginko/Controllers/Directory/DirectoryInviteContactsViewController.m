//
//  DirectoryInviteContactsViewController.m
//  ginko
//
//  Created by stepanekdavid on 12/27/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "DirectoryInviteContactsViewController.h"

#import "SearchCell.h"
#import "YYYCommunication.h"
#import "UIImage+Tint.h"
#import "TabRequestController.h"

@interface DirectoryInviteContactsViewController ()<UIGestureRecognizerDelegate>{
    NSMutableArray *arrContacts;
    NSMutableArray *arrNormalContacts;
    NSMutableArray *arrInvitedContacts;
    NSMutableArray *arrAcceptedContacts;
    NSMutableArray *arrDirectoryContacts;
    NSMutableArray *arrFilteredList;
    
    NSMutableArray *arrSelectedNormal;
    NSMutableArray *arrSelectedInvited;
    NSMutableArray *arrSelectedAccepted;
    NSMutableArray *arrSelectedDirectory;
    int inviteStatus;
}

@end

@implementation DirectoryInviteContactsViewController
@synthesize navView, btnDone;
@synthesize btnSelectAll, searchBarForList, tblForContact, viewBottom, viewDelete;
@synthesize btnAccepted, btnAllContacts, btnInvited, btnDirectoryUser;
@synthesize directoryID;
@synthesize navBarColor, statusFromNavi;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
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
    arrDirectoryContacts = [[NSMutableArray alloc] init];
    arrFilteredList = [[NSMutableArray alloc] init];
    
    arrSelectedNormal = [[NSMutableArray alloc] init];
    arrSelectedInvited = [[NSMutableArray alloc] init];
    arrSelectedDirectory = [[NSMutableArray alloc] init];
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
    
    [arrContacts removeAllObjects];
    [arrFilteredList removeAllObjects];
    [arrNormalContacts removeAllObjects];
    [arrInvitedContacts removeAllObjects];
    [arrAcceptedContacts removeAllObjects];
    [arrDirectoryContacts removeAllObjects];
    
    if (statusFromNavi && statusFromNavi == 4) {
        [self onDirectoryUser:nil];
    }else{
        [self getDirectoryAllContacts];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [navView removeFromSuperview];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - WebApi Integration
- (void)getDirectoryAllContacts
{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        
        [arrContacts removeAllObjects];
        [arrFilteredList removeAllObjects];
        [arrNormalContacts removeAllObjects];
        [arrInvitedContacts removeAllObjects];
        [arrAcceptedContacts removeAllObjects];
        [arrDirectoryContacts removeAllObjects];
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            void ( ^successed )( id _response ) = ^( id _response ) {
                [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
                if ([[_response objectForKey:@"success"] boolValue])
                {
                    NSMutableArray *confirmedMembers = [[NSMutableArray alloc] init];
                    NSMutableArray *requestedMembers = [[NSMutableArray alloc] init];
                    confirmedMembers = [[[_response objectForKey:@"data"] objectForKey:@"member"] mutableCopy];
                    requestedMembers = [[[_response objectForKey:@"data"] objectForKey:@"requested"] mutableCopy];
                    for (NSDictionary *dict in APPDELEGATE.totalList) {
                        if ([[dict objectForKey:@"contact_type"] integerValue] == 1) {
                            BOOL isInvited = NO;
                            for (NSDictionary *dc in [[_responseObject objectForKey:@"data"] objectForKey:@"data"]) {
                                if ([[dc objectForKey:@"user_id"] integerValue] == [[dict objectForKey:@"contact_id"] integerValue]) {
                                    isInvited = YES;
                                }
                            }
                            if (!isInvited && ![confirmedMembers containsObject:[dict objectForKey:@"contact_id"]] && ![requestedMembers containsObject:[dict objectForKey:@"contact_id"]]) {
                                [arrContacts addObject:dict];
                                [arrNormalContacts addObject:dict];
                            }
                        }
                    }
                    NSSortDescriptor *sortDescriptor;
                    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"first_name" ascending:YES selector:@selector(localizedStandardCompare:)];
                    NSMutableArray * sortDescriptors = [NSMutableArray arrayWithObject:sortDescriptor];
                    [arrContacts sortUsingDescriptors:sortDescriptors];
                    [arrNormalContacts sortUsingDescriptors:sortDescriptors];
                    inviteStatus = 0;
                    [self reloadContent];
                    [self filteredSearch:searchBarForList.text];
                }
            } ;
            
            void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
                [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
                
                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Internet Connection Error!"];
            } ;
            
            [[YYYCommunication sharedManager] GetConfirmedAndResquestedIdsDirectory:APPDELEGATE.sessionId directoryId:directoryID successed:successed failure:failure];
            
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Internet Connection Error!"];
    } ;
    
    [[YYYCommunication sharedManager] GetListInviteDirectory:APPDELEGATE.sessionId directoryId:directoryID pageNum:@"1" countPerPage:[NSString stringWithFormat:@"%lu", (unsigned long)[APPDELEGATE.totalList count]] successed:successed failure:failure];
    
}
- (void)getInvitedCotnacts{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        [arrInvitedContacts removeAllObjects];
        [arrContacts removeAllObjects];
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            for (NSDictionary *dict in APPDELEGATE.totalList) {
                if ([[dict objectForKey:@"contact_type"] integerValue] == 1) {
                    BOOL isInvited = NO;
                    for (NSDictionary *dc in [[_responseObject objectForKey:@"data"] objectForKey:@"data"]) {
                        if ([[dc objectForKey:@"user_id"] integerValue] == [[dict objectForKey:@"contact_id"] integerValue]) {
                            isInvited = YES;
                        }
                    }
                    if (isInvited) {
                        [arrContacts addObject:dict];
                        [arrInvitedContacts addObject:dict];
                    }
                }
            }
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"first_name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSMutableArray * sortDescriptors = [NSMutableArray arrayWithObject:sortDescriptor];
            [arrInvitedContacts sortUsingDescriptors:sortDescriptors];
            [arrContacts sortUsingDescriptors:sortDescriptors];
            inviteStatus = 1;
            [self reloadContent];
            [self filteredSearch:searchBarForList.text];
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Internet Connection Error!"];
    } ;
    
    [[YYYCommunication sharedManager] GetListInviteDirectory:APPDELEGATE.sessionId directoryId:directoryID pageNum:@"1" countPerPage:[NSString stringWithFormat:@"%lu", (unsigned long)[APPDELEGATE.totalList count]] successed:successed failure:failure];
}
- (void)getConfirmedContacts{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        [arrAcceptedContacts removeAllObjects];
        [arrContacts removeAllObjects];
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            
            for (NSDictionary *dc in [[_responseObject objectForKey:@"data"] objectForKey:@"data"]) {
                
                [arrContacts addObject:dc];
                [arrAcceptedContacts addObject:dc];
            }
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"fname" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSMutableArray * sortDescriptors = [NSMutableArray arrayWithObject:sortDescriptor];
            [arrAcceptedContacts sortUsingDescriptors:sortDescriptors];
            [arrContacts sortUsingDescriptors:sortDescriptors];
            inviteStatus = 2;
            [self reloadContent];
            [self filteredSearch:searchBarForList.text];
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Internet Connection Error!"];
    } ;
    
    [[YYYCommunication sharedManager] GetListConfirmedDirectory:APPDELEGATE.sessionId directoryId:directoryID pageNum:@"1" countPerPage:@"40" successed:successed failure:failure];
}
-(void)getDiectoryRequest{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        [arrDirectoryContacts removeAllObjects];
        [arrContacts removeAllObjects];
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            for (NSDictionary *dc in [[_responseObject objectForKey:@"data"] objectForKey:@"data"]) {
                [arrContacts addObject:dc];
                [arrDirectoryContacts addObject:dc];
            }
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"first_name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSMutableArray * sortDescriptors = [NSMutableArray arrayWithObject:sortDescriptor];
            [arrDirectoryContacts sortUsingDescriptors:sortDescriptors];
            [arrContacts sortUsingDescriptors:sortDescriptors];
            inviteStatus = 3;
            [self reloadContent];
            [self filteredSearch:searchBarForList.text];
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Internet Connection Error!"];
    } ;
    
    [[YYYCommunication sharedManager] GetListRequestDirectory:APPDELEGATE.sessionId directoryId:directoryID pageNum:@"1" countPerPage:@"40" successed:successed failure:failure];
}
- (void)reloadContent
{
    [arrFilteredList removeAllObjects];
    btnInvited.selected = NO;
    btnAccepted.selected = NO;
    btnAllContacts.selected = NO;
    btnDirectoryUser.selected = NO;
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
        case 3:
            btnDirectoryUser.selected = YES;
            arrFilteredList = [[NSMutableArray alloc] initWithArray:arrDirectoryContacts];
            _navigationTextLabel.text = @"Requests";
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
        case 3:
            selectedArray = [arrSelectedDirectory mutableCopy];
            break;
    }
    
    BOOL isContain = YES;
    if ([selectedArray count] >= [arrFilteredList count] && [arrFilteredList count] > 0) {
        for (int j = 0; j < [arrFilteredList count]; j ++) {
            NSDictionary *dict = [arrFilteredList objectAtIndex:j];
            if (inviteStatus == 3 || inviteStatus == 2){
                if (![selectedArray containsObject:[dict objectForKey:@"user_id"]]) {
                    isContain = NO;
                }
            }else{
                if (![selectedArray containsObject:[dict objectForKey:@"contact_id"]]) {
                    isContain = NO;
                }
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
            if (inviteStatus == 3) {
                btnDone.hidden = NO;
            }
            viewDelete.hidden = NO;
        } else {
            if (inviteStatus == 3) {
                btnDone.hidden = YES;
            }
            btnSelectAll.selected = NO;
            viewDelete.hidden = YES;
        }
        return !viewBottom.hidden;
    } else {
        if ([selectedArray count] && [arrFilteredList count] > 0) {
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
    if (inviteStatus ==3 || inviteStatus ==2) {
        firstName = [dict objectForKey:@"fname"];
        middleName = [dict objectForKey:@"mname"];
        lastName = [dict objectForKey:@"lname"];
        
        [cell setPhoto:[dict objectForKey:@"photo_url"]];
        cell.firstName.text = [NSString stringWithFormat:@"%@ %@",firstName, middleName];
        cell.lastName.text = lastName;
        cell.actionBtn.hidden = YES;
        cell.lblCaption.hidden = YES;
    }else{
        firstName = [dict objectForKey:@"first_name"];
        middleName = [dict objectForKey:@"middle_name"];
        lastName = [dict objectForKey:@"last_name"];
        
        [cell setPhoto:[dict objectForKey:@"profile_image"]];
        cell.firstName.text = [NSString stringWithFormat:@"%@ %@",firstName, middleName];
        cell.lastName.text = lastName;
        cell.actionBtn.hidden = YES;
        cell.lblCaption.hidden = YES;
    }
    
    switch (inviteStatus) {
        case 0:
            if ([arrSelectedNormal containsObject:[dict valueForKey:@"contact_id"]]) {
                [tableView selectRowAtIndexPath:indexPath
                                       animated:NO
                                 scrollPosition:UITableViewScrollPositionNone];
            }
            break;
        case 1:
            if ([arrSelectedInvited containsObject:[dict valueForKey:@"contact_id"]]) {
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
        case 3:
            if ([arrSelectedDirectory containsObject:[dict valueForKey:@"user_id"]]) {
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
            [arrSelectedNormal addObject:[[arrFilteredList objectAtIndex:indexPath.row] valueForKey:@"contact_id"]];
            break;
        case 1:
            [arrSelectedInvited addObject:[[arrFilteredList objectAtIndex:indexPath.row] valueForKey:@"contact_id"]];
            break;
        case 2:
            [arrSelectedAccepted addObject:[[arrFilteredList objectAtIndex:indexPath.row] valueForKey:@"user_id"]];
            break;
        case 3:
            [arrSelectedDirectory addObject:[[arrFilteredList objectAtIndex:indexPath.row] valueForKey:@"user_id"]];
            break;
    }
    
    [self isShowingDoneButton];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [searchBarForList resignFirstResponder];
    switch (inviteStatus) {
        case 0:
            [arrSelectedNormal removeObject:[[arrFilteredList objectAtIndex:indexPath.row] valueForKey:@"contact_id"]];
            break;
        case 1:
            [arrSelectedInvited removeObject:[[arrFilteredList objectAtIndex:indexPath.row] valueForKey:@"contact_id"]];
            break;
        case 2:
            [arrSelectedAccepted removeObject:[[arrFilteredList objectAtIndex:indexPath.row] valueForKey:@"user_id"]];
            break;
        case 3:
            [arrSelectedDirectory removeObject:[[arrFilteredList objectAtIndex:indexPath.row] valueForKey:@"user_id"]];
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
        
        if (inviteStatus == 2 || inviteStatus ==3) {
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
        }else{
            firstName = [[dict objectForKey:@"first_name"] uppercaseString];
            middleName = [[dict objectForKey:@"middle_name"] uppercaseString];
            lastName = [[dict objectForKey:@"last_name"] uppercaseString];
            
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
    }
    
    [tblForContact reloadData];
    [self isShowingDoneButton];
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        if (alertView.tag == 100) {
            NSArray * selectedRows = [tblForContact indexPathsForSelectedRows];
            NSString *strIDs = @"";
            for (int i = 0 ; i < [selectedRows count] ; i++)
            {
                NSIndexPath * indexPath = [selectedRows objectAtIndex:i];
                NSDictionary *dict = [arrFilteredList objectAtIndex:indexPath.row];
                strIDs = [NSString stringWithFormat:@"%@%@,", strIDs, [dict objectForKey:@"contact_id"]];
            }
            if ([strIDs length]) {
                strIDs = [strIDs substringToIndex:[strIDs length] - 1];
            }
            [self deleteFollowers:strIDs];
        }else if (alertView.tag == 101){
            
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
            [self deleteRequestsForDirectory:strIDs];
        }else if (alertView.tag == 102){
            
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
            [self deleteConfirmForDirectory:strIDs];
        }
    }
}

- (void)deleteConfirmForDirectory : (NSString *)contact_uids{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        NSDictionary *result = _responseObject;
        if ([[result objectForKey:@"success"] boolValue]) {
            [tblForContact deselectRowAtIndexPath:[tblForContact indexPathForSelectedRow] animated:NO];
            inviteStatus = 2;
            viewDelete.hidden = YES;
            [arrSelectedAccepted removeAllObjects];
            searchBarForList.text = @"";
            btnSelectAll.selected = NO;
            [self getConfirmedContacts];
            
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
    
    [[YYYCommunication sharedManager] RemoveMemberDirectory:APPDELEGATE.sessionId directoryId:directoryID mUids:contact_uids successed:successed failure:failure];
}
- (void)deleteRequestsForDirectory : (NSString *)contact_uids{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        NSDictionary *result = _responseObject;
        if ([[result objectForKey:@"success"] boolValue]) {
            [tblForContact deselectRowAtIndexPath:[tblForContact indexPathForSelectedRow] animated:NO];
            inviteStatus = 3;
            viewDelete.hidden = YES;
            [arrSelectedDirectory removeAllObjects];
            searchBarForList.text = @"";
            btnSelectAll.selected = NO;
            [self getDiectoryRequest];
            
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
    
    [[YYYCommunication sharedManager] DeleteRequestDirectory:APPDELEGATE.sessionId directoryId:directoryID mUids:contact_uids successed:successed failure:failure];
}
- (void)deleteFollowers : (NSString *)contact_uids
{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        NSDictionary *result = _responseObject;
        if ([[result objectForKey:@"success"] boolValue]) {
            [tblForContact deselectRowAtIndexPath:[tblForContact indexPathForSelectedRow] animated:NO];
            inviteStatus = 0;
            viewDelete.hidden = YES;
            [arrSelectedNormal removeAllObjects];
            [arrSelectedInvited removeAllObjects];
            [arrSelectedAccepted removeAllObjects];
            [arrSelectedDirectory removeAllObjects];
            searchBarForList.text = @"";
            btnSelectAll.selected = NO;
            [self getDirectoryAllContacts];
            
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
    
    [[YYYCommunication sharedManager] RemoveInviteDrectoryMember:APPDELEGATE.sessionId directoryId:directoryID mUids:contact_uids successed:successed failure:failure];
    
}
- (void)approveRequestsForDiectory : (NSString *)contact_uids{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        NSDictionary *result = _responseObject;
        if ([[result objectForKey:@"success"] boolValue]) {
            [tblForContact deselectRowAtIndexPath:[tblForContact indexPathForSelectedRow] animated:NO];
            inviteStatus = 3;
            
            [arrSelectedDirectory removeAllObjects];
            searchBarForList.text = @"";
            btnSelectAll.selected = NO;
            [self getDiectoryRequest];
            
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
    
    [[YYYCommunication sharedManager] ApproveRequestDirectory:APPDELEGATE.sessionId directoryId:directoryID mUids:contact_uids successed:successed failure:failure];
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
    
    [[YYYCommunication sharedManager] InviteDirectoryMember:APPDELEGATE.sessionId directoryId:directoryID mUids:contact_uids successed:successed failure:failure];
    
}
- (IBAction)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onDone:(id)sender{
    if (btnDone.hidden) {
        return;
    }
    NSString *strIDs = @"";
    if (inviteStatus !=3) {
        for (int i = 0; i < [arrNormalContacts count]; i ++) {
            NSDictionary *dict = [arrNormalContacts objectAtIndex:i];
            if ([arrSelectedNormal containsObject:[dict valueForKey:@"contact_id"]]) {
                strIDs = [NSString stringWithFormat:@"%@%@,", strIDs, [dict objectForKey:@"contact_id"]];
            }
        }
        if ([strIDs length]) {
            strIDs = [strIDs substringToIndex:[strIDs length] - 1];
        }
        [self inviteFriends:strIDs];
    }else{
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
        [self approveRequestsForDiectory:strIDs];
    }
}

- (IBAction)onSelectAll:(id)sender{
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
        case 3:
            [arrSelectedDirectory removeAllObjects];
            break;
    }
    for (int i=0; i<[arrFilteredList count]; i++) {
        if (btnSelectAll.selected) {
            [tblForContact deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO];
        } else {
            [tblForContact selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            switch (inviteStatus) {
                case 0:
                    [arrSelectedNormal addObject:[[arrFilteredList objectAtIndex:i] valueForKey:@"contact_id"]];
                    break;
                case 1:
                    [arrSelectedInvited addObject:[[arrFilteredList objectAtIndex:i] valueForKey:@"contact_id"]];
                    break;
                case 2:
                    [arrSelectedAccepted addObject:[[arrFilteredList objectAtIndex:i] valueForKey:@"user_id"]];
                    break;
                case 3:
                    [arrSelectedDirectory addObject:[[arrFilteredList objectAtIndex:i] valueForKey:@"user_id"]];
                    break;
            }
        }
    }
    [self isShowingDoneButton];
}

- (IBAction)onDirectoryUser:(id)sender{
    if (inviteStatus == 3) {
        return;
    }
    inviteStatus = 3;
    // [arrSelectedNormal removeAllObjects];
    btnDone.hidden = YES;
    [self getDiectoryRequest];

}
- (IBAction)onInvitedContacts:(id)sender{
    if (inviteStatus == 1) {
        return;
    }
    btnDone.hidden = YES;
    inviteStatus = 1;
    //[arrSelectedInvited removeAllObjects];
    [self getInvitedCotnacts];

}
- (IBAction)onAllContacts:(id)sender{
    if (inviteStatus == 0) {
        return;
    }
    inviteStatus = 0;
    // [arrSelectedNormal removeAllObjects];
    [self getDirectoryAllContacts];

}
- (IBAction)onAcceptContacts:(id)sender{
    if (inviteStatus == 2) {
        return;
    }
    
    
    btnDone.hidden = YES;
    inviteStatus = 2;
    [self getConfirmedContacts];

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
        if (inviteStatus == 2 || inviteStatus == 3) {
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
        }else{
            if ([[dict objectForKey:@"invite_status"] intValue] != inviteStatus) {
                continue;
            }
            
            firstName = [[dict objectForKey:@"first_name"] uppercaseString];
            middleName = [[dict objectForKey:@"middle_name"] uppercaseString];
            lastName = [[dict objectForKey:@"last_name"] uppercaseString];
            
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
        
    }
    
    [tblForContact reloadData];
    [self isShowingDoneButton];
}
- (IBAction)onDelete:(id)sender{
    
    NSArray * selectedRows = [tblForContact indexPathsForSelectedRows];
    NSString *alertStr = @"";
    if (inviteStatus == 3){
        if ([selectedRows count] == 1) {
            alertStr = @"Do you want to delete this request?";
        }else{
            alertStr = @"Do you want to delete this requests?";
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:alertStr delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        alert.delegate = self;
        alert.tag = 101;
        [alert show];
    }else if (inviteStatus == 2){
        if ([selectedRows count] == 1) {
            alertStr = @"Do you want to delete this Member?";
        }else{
            alertStr = @"Do you want to delete this Members?";
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:alertStr delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        alert.delegate = self;
        alert.tag = 102;
        [alert show];
    }else {
        if ([selectedRows count] == 1) {
            alertStr = @"Do you want to delete this invite?";
        }else{
            alertStr = @"Do you want to delete this invites?";
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:alertStr delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        alert.delegate = self;
        alert.tag = 100;
        [alert show];
    }
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
- (void)movePushNotificationViewController{
    TabRequestController *tabRequestController = [TabRequestController sharedController];
    tabRequestController.selectedIndex = 1;
    [self.navigationController pushViewController:tabRequestController animated:YES];
}
@end
