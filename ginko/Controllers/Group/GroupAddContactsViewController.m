//
//  GroupAddContactsViewController.m
//  GINKO
//
//  Created by Xian on 7/22/14.
//  Copyright (c) 2014 Xian. All rights reserved.
//

#import "GroupAddContactsViewController.h"
#import "SearchCell.h"
#import "YYYCommunication.h"

@interface GroupAddContactsViewController ()
{
    NSMutableArray *arrContacts;
    NSMutableArray *arrFilteredList;
    
    NSMutableArray *arrSelectedContacts;
}
@end

@implementation GroupAddContactsViewController
@synthesize navView, btnDone;
@synthesize btnSelectAll, searchBarForList, tblForContact;
@synthesize groupID;

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
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    arrContacts = [[NSMutableArray alloc] init];
    arrFilteredList = [[NSMutableArray alloc] init];
    arrSelectedContacts = [[NSMutableArray alloc] init];
    btnSelectAll.selected = NO;
    NSString * SearchCellIdentifier = @"SearchCell";
    [tblForContact registerNib:[UINib nibWithNibName:SearchCellIdentifier bundle:nil] forCellReuseIdentifier:SearchCellIdentifier];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [tblForContact deselectRowAtIndexPath:[tblForContact indexPathForSelectedRow] animated:animated];
    [self.navigationController.navigationBar addSubview:navView];
    
    searchBarForList.text = @"";
    
//    [self getOnlyContacts];
    [self getRemainingContacts];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [navView removeFromSuperview];
}

- (BOOL)isShowingDoneButton
{
//    NSArray * selectedRows = [tblForContact indexPathsForSelectedRows];
//    if ([selectedRows count]) {
//        if ([selectedRows count] == [arrFilteredList count]) {
//            btnSelectAll.selected = YES;
//        } else {
//            btnSelectAll.selected = NO;
//        }
//        btnDone.hidden = NO;
//        return YES;
//    }
//    btnSelectAll.selected = NO;
//    btnDone.hidden = YES;
//    return NO;
    
    BOOL isCheckedSeletedall = YES;
    for (int i = 0; i < [arrFilteredList count]; i ++) {
        if (![arrSelectedContacts containsObject:[[arrFilteredList objectAtIndex:i] valueForKey:@"contact_id"]]) {
            isCheckedSeletedall = NO;
        }
    }
    if ([arrFilteredList count] == 0) {
        isCheckedSeletedall = NO;
    }
    btnSelectAll.selected = isCheckedSeletedall;
    if ([arrSelectedContacts count] > 0) {
        btnDone.hidden = NO;
    }else{
        btnDone.hidden = YES;
    }
    return isCheckedSeletedall;
    
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
    return 83.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * SearchCellIdentifier = @"SearchCell";
    SearchCell *cell = [tblForContact dequeueReusableCellWithIdentifier:SearchCellIdentifier forIndexPath:indexPath];
    
    if (cell == nil)
    {
        cell = [[SearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SearchCellIdentifier];
    }
    
    NSString * firstName = @"";
    NSString * middleName = @"";
    NSString * lastName = @"";
    
    NSDictionary *dict = [arrFilteredList objectAtIndex:indexPath.row];
    firstName = [dict objectForKey:@"first_name"];
    middleName = [dict objectForKey:@"middle_name"];
    lastName = [dict objectForKey:@"last_name"];
    
    if ([[dict objectForKey:@"contact_type"] intValue] == 2) {
        [cell setPhoto:[dict objectForKey:@"photo_url"]];
        cell.profileImageView.layer.borderColor = [UIColor grayColor].CGColor;
    } else {
        [cell setPhoto:[dict objectForKey:@"profile_image"]];
        cell.profileImageView.layer.borderColor = [UIColor colorWithRed:128.0/256.0 green:100.0/256.0 blue:162.0/256.0 alpha:1.0f].CGColor;
    }
    
    if ([arrSelectedContacts containsObject:[dict valueForKey:@"contact_id"]]) {
        [tableView selectRowAtIndexPath:indexPath
                                animated:NO
                          scrollPosition:UITableViewScrollPositionNone];
    }
    cell.firstName.text = [NSString stringWithFormat:@"%@ %@",firstName, middleName];
    cell.lastName.text = lastName;
    cell.actionBtn.hidden = YES;
    cell.lblCaption.hidden = YES;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [arrSelectedContacts addObject:[[arrFilteredList objectAtIndex:indexPath.row] valueForKey:@"contact_id"]];
    [self isShowingDoneButton];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [arrSelectedContacts removeObject:[[arrFilteredList objectAtIndex:indexPath.row] valueForKey:@"contact_id"]];
    [self isShowingDoneButton];
}

#pragma mark - SearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self onSearchCancel:searchBar];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBarForList resignFirstResponder];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText isEqualToString:@""]) {
        [self onSearchCancel:nil];
        return;
    }
    
    NSDictionary *dict;
    NSString *firstName, *middleName, *lastName;
    
    [arrFilteredList removeAllObjects];
    
    for (int i = 0; i < [arrContacts count]; i++)
    {
        dict = [arrContacts objectAtIndex:i];
        
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
    
    [tblForContact reloadData];
    [self isShowingDoneButton];
}

#pragma mark - WebApi Integration
- (void)getOnlyContacts
{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        [arrContacts removeAllObjects];
        [arrFilteredList removeAllObjects];
        if ([[_responseObject objectForKey:@"success"] boolValue])
		{
            for (NSDictionary *dict in [_responseObject objectForKey:@"data"]) {
                if (![dict objectForKey:@"entity_id"]) {
                    [arrContacts addObject:dict];
                }
            }
            
            arrFilteredList = [[NSMutableArray alloc] initWithArray:arrContacts];
            
            [tblForContact reloadData];
            [self isShowingDoneButton];
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Internet Connection Error!"];
    } ;
    
    [[Communication sharedManager] GetContacts:[AppDelegate sharedDelegate].sessionId sortby:nil search:nil category:nil contactType:nil successed:successed failure:failure];
}

- (void)getRemainingContacts
{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        if ([[_responseObject objectForKey:@"success"] boolValue])
		{
            [arrContacts removeAllObjects];
            [arrFilteredList removeAllObjects];
            
            for (NSDictionary *dict in [[_responseObject objectForKey:@"data"] objectForKey:@"data"]) {
                if (![dict objectForKey:@"entity_id"]) {
                    [arrContacts addObject:dict];
                }
            }
            
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"first_name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSMutableArray * sortDescriptors = [NSMutableArray arrayWithObject:sortDescriptor];
            [arrContacts sortUsingDescriptors:sortDescriptors];
            
            arrFilteredList = [[NSMutableArray alloc] initWithArray:arrContacts];
            
            [tblForContact reloadData];
            [self isShowingDoneButton];
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Internet Connection Error!"];
    } ;
    
    [[YYYCommunication sharedManager] getRemainingContacts:[AppDelegate sharedDelegate].sessionId groupID:groupID successed:successed failure:failure];
}

- (void)addUsersToGroup
{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        if ([[_responseObject objectForKey:@"success"] boolValue])
		{
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            NSDictionary *dictError = [_responseObject objectForKey:@"err"];
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
    
    NSString *strKeys = @"";
    for (int i = 0; i < [arrContacts count]; i ++) {
        NSDictionary *dict = [arrContacts objectAtIndex:i];
        if ([arrSelectedContacts containsObject:[dict valueForKey:@"contact_id"]]) {
            strKeys = [NSString stringWithFormat:@"%@%@_%@,", strKeys, [dict objectForKey:@"contact_id"], [dict objectForKey:@"contact_type"]];
        }
    }
    
//    NSArray * selectedRows = [tblForContact indexPathsForSelectedRows];
//    NSString *strKeys = @"";
//    for (int i = 0 ; i < [selectedRows count] ; i++)
//    {
//        NSIndexPath * indexPath = [selectedRows objectAtIndex:i];
//        NSDictionary * dict = [arrFilteredList objectAtIndex:indexPath.row];
//        strKeys = [NSString stringWithFormat:@"%@%@_%@,", strKeys, [dict objectForKey:@"contact_id"], [dict objectForKey:@"contact_type"]];
//    }
    if ([strKeys length]) {
        strKeys = [strKeys substringToIndex:[strKeys length] - 1];
    }
    
    [[YYYCommunication sharedManager] addUserToGroup:[AppDelegate sharedDelegate].sessionId groupID:groupID contactKeys:strKeys successed:successed failure:failure];
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
    [self addUsersToGroup];
}
- (IBAction)onSelectAll:(id)sender
{
    [arrSelectedContacts removeAllObjects];
    for (int i=0; i<[arrFilteredList count]; i++) {
        if (btnSelectAll.selected) {
            [tblForContact deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO];
        } else {
            [tblForContact selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            [arrSelectedContacts addObject:[[arrFilteredList objectAtIndex:i] valueForKey:@"contact_id"]];
        }
        
    }
    [self isShowingDoneButton];
}

- (IBAction)onSearchCancel:(id)sender
{
    searchBarForList.text = @"";
    arrFilteredList = [[NSMutableArray alloc] initWithArray:arrContacts];
    [tblForContact reloadData];
    [self isShowingDoneButton];
    if (sender) {
        [searchBarForList setShowsCancelButton:NO animated:YES];
        [searchBarForList resignFirstResponder];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
