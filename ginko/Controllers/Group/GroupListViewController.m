//
//  GroupListViewController.m
//  GINKO
//
//  Created by Xian on 7/22/14.
//  Copyright (c) 2014 Xian. All rights reserved.
//

#import "GroupListViewController.h"
#import "YYYCommunication.h"
#import "GroupContactsViewController.h"
#import "YYYChatViewController.h"
#import "GroupListCell.h"

@interface GroupListViewController () <GroupListCellDelegate>
{
    NSMutableArray *arrGroups;
}
@end

@implementation GroupListViewController
@synthesize navView, tblGroups, emptyView;


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
    arrGroups = [[NSMutableArray alloc] init];
    
    [tblGroups registerNib:[UINib nibWithNibName:@"GroupListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"GroupListCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [tblGroups deselectRowAtIndexPath:[tblGroups indexPathForSelectedRow] animated:animated];
    [self.navigationController.navigationBar addSubview:navView];
    
    [self getGroups];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [navView removeFromSuperview];
}

#pragma mark - UITableView DataSoruce, Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrGroups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GroupListCell *cell = [tblGroups dequeueReusableCellWithIdentifier:@"GroupListCell"];
    
    if(cell == nil)
    {
        cell = [[GroupListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GroupCell"];
    }
    
    [cell.nameLabel setText:[(NSDictionary *)[arrGroups objectAtIndex:indexPath.row] objectForKey:@"name"]];
    cell.delegate = self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GroupContactsViewController *vc = [[GroupContactsViewController alloc] initWithNibName:@"GroupContactsViewController" bundle:nil];
    vc.groupDict = [arrGroups objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        [self addGroup:[[alertView textFieldAtIndex:0] text]];
    }
}

#pragma mark - WebApi Integration
- (void)getGroups
{
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
	{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [arrGroups removeAllObjects];
        NSDictionary *result = _responseObject;
        if ([[result objectForKey:@"success"] boolValue]) {
            for (NSDictionary *dict in [result objectForKey:@"data"]) {
                [arrGroups addObject:dict];
            }
            
            if ([arrGroups count]) {
                tblGroups.hidden = NO;
                emptyView.hidden = YES;
            } else {
                tblGroups.hidden = YES;
                emptyView.hidden = NO;
            }
            
            [tblGroups reloadData];
            
        } else {
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
        [MBProgressHUD hideHUDForView:self.view animated:YES];
		[CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Internet Connection Error!"];
	};
	
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[YYYCommunication sharedManager] getGroupList:[AppDelegate sharedDelegate].sessionId successed:successed failure:failure];
}

- (void)addGroup:(NSString *)groupName
{
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
	{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary *result = _responseObject;
        if ([[result objectForKey:@"success"] boolValue]) {
            [arrGroups addObject:[result objectForKey:@"data"]];
            tblGroups.hidden = NO;
            emptyView.hidden = YES;
            [tblGroups reloadData];
            GroupContactsViewController *vc = [[GroupContactsViewController alloc] initWithNibName:@"GroupContactsViewController" bundle:nil];
            vc.groupDict = [result objectForKey:@"data"];
            [self.navigationController pushViewController:vc animated:YES];
            
        } else {
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
        [MBProgressHUD hideHUDForView:self.view animated:YES];
		[CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Internet Connection Error!"];
	};
	
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[YYYCommunication sharedManager] addGroup:[AppDelegate sharedDelegate].sessionId name:groupName successed:successed failure:failure];
}

- (void)getUsersForGroup:(NSString *)groupID
{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        if ([[_responseObject objectForKey:@"success"] boolValue])
		{
            NSMutableArray *arrContacts = [[_responseObject objectForKey:@"data"] objectForKey:@"data"];
            NSString *strIds = @"";
            
            for (NSDictionary *dict in arrContacts) {
                if ([[dict objectForKey:@"contact_type"] intValue] == 1) {
                    strIds = [NSString stringWithFormat:@"%@,%@", strIds, [dict objectForKey:@"contact_id"]];
                }
            }
            
            if ([strIds length]) {
                strIds = [strIds substringFromIndex:1];
            }
            if (![strIds length]) {
                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Oops, no purple contacts."];
                return;
            }
            [self CreateMessageBoard:strIds :arrContacts];
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Internet Connection Error!"];
    } ;
    
    [[YYYCommunication sharedManager] getUsersForGroup:[AppDelegate sharedDelegate].sessionId groupID:groupID successed:successed failure:failure];
}

-(void)CreateMessageBoard:(NSString*)ids :(NSArray *)arrContacts
{
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
	
	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        
		[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
		
		if ([[_responseObject objectForKey:@"success"] boolValue])
		{
			NSMutableArray *lstTemp = [[NSMutableArray alloc] init];
            
            
            for (NSDictionary *dict in arrContacts)
            {
                if ([[dict objectForKey:@"contact_type"] intValue] == 1)
                {
                    NSMutableDictionary *dictTemp = [[NSMutableDictionary alloc] init];
                    
                    [dictTemp setObject:[dict objectForKey:@"first_name"] forKey:@"fname"];
                    [dictTemp setObject:[dict objectForKey:@"last_name"] forKey:@"lname"];
                    [dictTemp setObject:[dict objectForKey:@"photo_url"] forKey:@"photo_url"];
                    [dictTemp setObject:[dict objectForKey:@"contact_id"] forKey:@"user_id"];
                    
                    [lstTemp addObject:dictTemp];
                }
            }
			
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

#pragma mark - Actions
- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onAddContact:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Create a new Group" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GroupListCellDelegate
- (void)didTapChatButton:(id)sender {
    NSIndexPath *indexPath = [tblGroups indexPathForCell:sender];
    if(indexPath) {
        NSDictionary *dict = [arrGroups objectAtIndex:indexPath.row];
        [self getUsersForGroup:[dict objectForKey:@"id"]];
    }
}

@end
