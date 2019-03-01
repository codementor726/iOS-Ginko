//
//  YYYViewController.m
//  InstantMessenger
//
//  Created by Wang MeiHua on 2/27/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import "YYYSelectContactController.h"
#import "UIImageView+AFNetworking.h"
#import "YYYCommunication.h"
#import "MBProgressHUD.h"
#import "YYYChatViewController.h"
#import "ChatViewController.h"
#import "YYYSelectContactCell.h"
#import "VideoVoiceConferenceViewController.h"

@interface YYYSelectContactController (){
    CGFloat tableHeightToFix;
}

@end

@implementation YYYSelectContactController

@synthesize boardid;
@synthesize viewcontroller;
@synthesize lstCurrentUserIds;
@synthesize bContact;
@synthesize isReturnFromConference;
@synthesize conferenceType;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	lst_searched	= [[NSMutableArray alloc] init];
	lst_user		= [[NSMutableArray alloc] init];
	lst_selected	= [[NSMutableArray alloc] init];
    lst_chatContactSelected = [[NSMutableArray alloc] init];

	[vwBottom setHidden:YES];
    CGRect tableFrame = [tbl_chat frame];
    tableHeightToFix = tableFrame.size.height;
    
    
	lst_selected = [[NSMutableArray alloc] initWithArray:lstCurrentUserIds];
	
	[btAllContact setSelected:YES];
	[btChatContact setSelected:NO];
	
	if ([lstCurrentUserIds count])
	{
		[lblTitle setText:@"Selected Contact(s)"];
		[tbl_chat setFrame:CGRectMake(0, 64, 320, self.view.frame.size.height - 64)];
		[self.view bringSubviewToFront:tbl_chat];
		[btAccept setHidden:YES];
	}

	[self GetFriend];

	// Do any additional setup after loading the view, typically from a nib.
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeThisScreenWhenAccept) name:NOTIFICATION_GINKO_VIDEO_CONFERENCE object:nil];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_GINKO_VIDEO_CONFERENCE object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
}
-(void)GetFriend
{
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
	
	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        
		[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
		
		if ([[_responseObject objectForKey:@"success"] boolValue])
		{
            if (isReturnFromConference) {
                for (NSDictionary *dict in [[_responseObject objectForKey:@"data"] objectForKey:@"contact"])
                {
                    BOOL isExist = NO;
                    for (NSDictionary *member in APPDELEGATE.conferenceMembersForVideoCalling) {
                        if ([[member objectForKey:@"user_id"] integerValue] == [[dict objectForKey:@"user_id"] integerValue]) {
                            isExist = YES;
                            break;
                        }
                    }
                    if (!isExist) {
                        [lst_user addObject:dict];
                    }
                }
            }else {
                for (NSDictionary *dict in [[_responseObject objectForKey:@"data"] objectForKey:@"contact"])
                {
                    [lst_user addObject:dict];
                }
            }
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"first_name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSMutableArray * sortDescriptors = [NSMutableArray arrayWithObject:sortDescriptor];
            [lst_user sortUsingDescriptors:sortDescriptors];
			lst_searched = [[NSMutableArray alloc] initWithArray:lst_user];
			
			if ([lstCurrentUserIds count])
			{
				[self performSelector:@selector(btChatClick:) withObject:nil];
			}
            if ([lst_searched count] == 0) {
                btSelectAll.enabled = NO;
            }else{
                btSelectAll.enabled = YES;
            }
			[tbl_chat reloadData];
		}
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
		
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        [ self  showAlert: @"Internet Connection Error!" ] ;
		
    } ;
    
	[[YYYCommunication sharedManager] GetFriend:[AppDelegate sharedDelegate].sessionId successed:successed failure:failure];
}

-(void)showAlert:(NSString*)_message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:_message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}
- (void)closeThisScreenWhenAccept{
    if (isReturnFromConference) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
-(IBAction)btBackClick:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)btAcceptClick:(id)sender
{
	if (![lst_selected count]) {
		return;
	}
	
	NSString *strIds = @"";
	
	for (NSString *str in lst_selected) {
		strIds = [NSString stringWithFormat:@"%@,%@",strIds,str];
	}
	
	strIds = [strIds substringFromIndex:1];
	
    if (!isReturnFromConference) {
        if (!boardid) {
            [self CreateMessageBoard:strIds];
        }else{
            [self AddMember:strIds];
        }
    }else{//conference
        if (!boardid) {
            [self CreateBoardAndAddMemberOnConference:strIds];
        }else{
            [self AddMemberOnConference:strIds];
        }
    }
}
- (void)CreateBoardAndAddMemberOnConference:(NSString *)ids{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            NSString *boardIdForConference = [[_responseObject objectForKey:@"data"] objectForKey:@"board_id"];

            for (NSDictionary *dict in lst_user)
            {
                if ([lst_selected containsObject:[dict objectForKey:@"user_id"]])
                {
                    NSMutableDictionary *dictOfUser = [[NSMutableDictionary alloc] init];
                    [dictOfUser setObject:[dict objectForKey:@"user_id"] forKey:@"user_id"];
                    [dictOfUser setObject:[NSString stringWithFormat:@"%@ %@", [dict objectForKey:@"first_name"], [dict objectForKey:@"last_name"]] forKey:@"name"];
                    [dictOfUser setObject:[dict objectForKey:@"photo_url"] forKey:@"photo_url"];
                    
                    
                    [dictOfUser setObject:@"on" forKey:@"videoStatus"];
                    [dictOfUser setObject:@"on" forKey:@"voiceStatus"];
                    [dictOfUser setObject:@(1) forKey:@"conferenceStatus"];
                    [dictOfUser setObject:@(0) forKey:@"isOwner"];
                    [dictOfUser setObject:@(0) forKey:@"isInvited"];
                    [dictOfUser setObject:@(1) forKey:@"isInvitedByMe"];
                    
                    [APPDELEGATE.conferenceMembersForVideoCalling addObject:dictOfUser];
                }
            }
            //NSLog(@"%@", APPDELEGATE.conferenceMembersForVideoCalling);
            APPDELEGATE.conferenceId = boardIdForConference;
            ((VideoVoiceConferenceViewController*)viewcontroller).boardId = boardIdForConference;
            NSString *confName = @"Ginko Call";
            if ([APPDELEGATE.conferenceMembersForVideoCalling count] == 0) {
                confName = @"Ginko Call";
            }else if ([APPDELEGATE.conferenceMembersForVideoCalling count] == 1){
                confName = [[APPDELEGATE.conferenceMembersForVideoCalling objectAtIndex:0] objectForKey:@"name"];
            }else {
                for (NSDictionary *dicOfName in APPDELEGATE.conferenceMembersForVideoCalling) {
                    if (!APPDELEGATE.isOwnerForConference && [[dicOfName objectForKey:@"isOwner"] boolValue]) {
                        confName = [NSString stringWithFormat:@"%@ + %lu", [dicOfName objectForKey:@"name"], [APPDELEGATE.conferenceMembersForVideoCalling count] - 1];
                        break;
                    }else if (APPDELEGATE.isOwnerForConference && [[dicOfName objectForKey:@"isOwner"] boolValue]){
                        
                    }else{
                        confName = [NSString stringWithFormat:@"%@ + %lu", [dicOfName objectForKey:@"name"], [APPDELEGATE.conferenceMembersForVideoCalling count] - 1];
                        break;
                    }
                }
            }
            ((VideoVoiceConferenceViewController*)viewcontroller).conferenceName = confName;
            ((VideoVoiceConferenceViewController*)viewcontroller).conferenceType = 1;
            [((VideoVoiceConferenceViewController*)viewcontroller) openConferenceFromMenu];
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }else{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self showAlert:[[_responseObject objectForKey:@"err"] objectForKey:@"errMsg"]];
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        [ self  showAlert: @"Internet Connection Error!" ] ;
        
    } ;
    
    [[YYYCommunication sharedManager] CreateChatBoard:[AppDelegate sharedDelegate].sessionId userids:ids successed:successed failure:failure];
    
}
- (void)AddMemberOnConference:(NSString *)ids{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {

            for (NSDictionary *dict in lst_user)
            {
                if ([lst_selected containsObject:[dict objectForKey:@"user_id"]])
                {
                    NSMutableDictionary *dictOfUser = [[NSMutableDictionary alloc] init];
                    [dictOfUser setObject:[dict objectForKey:@"user_id"] forKey:@"user_id"];
                    [dictOfUser setObject:[NSString stringWithFormat:@"%@ %@", [dict objectForKey:@"first_name"], [dict objectForKey:@"last_name"]] forKey:@"name"];
                    [dictOfUser setObject:[dict objectForKey:@"photo_url"] forKey:@"photo_url"];
                    
                    
                    [dictOfUser setObject:@"on" forKey:@"videoStatus"];
                    [dictOfUser setObject:@"on" forKey:@"voiceStatus"];
                    [dictOfUser setObject:@(1) forKey:@"conferenceStatus"];
                    [dictOfUser setObject:@(0) forKey:@"isOwner"];
                    [dictOfUser setObject:@(0) forKey:@"isInvited"];
                    [dictOfUser setObject:@(1) forKey:@"isInvitedByMe"];
                    
                    [APPDELEGATE.conferenceMembersForVideoCalling addObject:dictOfUser];
                }
            }
            //NSLog(@"%@", APPDELEGATE.conferenceMembersForVideoCalling);
            [((VideoVoiceConferenceViewController*)viewcontroller) senddingOfferToInvitionMembers];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } ;
    [[YYYCommunication sharedManager] InviteNewMembersOnConference:APPDELEGATE.sessionId boardId:[NSString stringWithFormat:@"%@", boardid] userIds:ids successed:successed failure:failure];
}
-(void)AddMember:(NSString*)ids
{
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
	
	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        
		[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
		
		if ([[_responseObject objectForKey:@"success"] boolValue])
		{
			NSMutableArray *lstIds = [[NSMutableArray alloc] init];
			for (NSDictionary *dict in ((YYYChatViewController*)viewcontroller).lstUsers)
			{
				[lstIds addObject:[NSNumber numberWithInt:[[dict objectForKey:@"user_id"] intValue]]];
			}
			
			for (NSDictionary *dict in lst_user)
			{
				if ([lst_selected containsObject:[dict objectForKey:@"user_id"]])
				{
					if (![lstIds containsObject:[NSNumber numberWithInt:[[dict objectForKey:@"user_id"] intValue]]])
					{
						NSMutableDictionary *dictTemp = [[NSMutableDictionary alloc] init];
						
						[dictTemp setObject:[dict objectForKey:@"first_name"] forKey:@"fname"];
						[dictTemp setObject:[dict objectForKey:@"last_name"] forKey:@"lname"];
						[dictTemp setObject:[dict objectForKey:@"photo_url"] forKey:@"photo_url"];
						[dictTemp setObject:[dict objectForKey:@"user_id"] forKey:@"user_id"];
						
						[((YYYChatViewController*)viewcontroller).lstUsers addObject:dictTemp];
					}
				}
			}

			[self dismissViewControllerAnimated:YES completion:nil];
		}
		else
		{
			[self dismissViewControllerAnimated:YES completion:nil];
		}
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
		
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
		[self dismissViewControllerAnimated:YES completion:nil];
		
    } ;
    
	[[YYYCommunication sharedManager] AddNewMember:[AppDelegate sharedDelegate].sessionId boardid:boardid userids:ids successed:successed failure:failure];
}

-(void)CreateMessageBoard:(NSString*)ids
{
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
	
	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        
		[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
		
		if ([[_responseObject objectForKey:@"success"] boolValue])
		{
			((ChatViewController*)viewcontroller).bGoToChat = YES;
			((ChatViewController*)viewcontroller).strIds = ids;
			
			NSMutableArray *lstTemp = [[NSMutableArray alloc] init];
			for (NSDictionary *dict in lst_user)
			{
				if ([lst_selected containsObject:[dict objectForKey:@"user_id"]])
				{
					NSMutableDictionary *dictTemp = [[NSMutableDictionary alloc] init];
					
					[dictTemp setObject:[dict objectForKey:@"first_name"] forKey:@"fname"];
					[dictTemp setObject:[dict objectForKey:@"last_name"] forKey:@"lname"];
					[dictTemp setObject:[dict objectForKey:@"photo_url"] forKey:@"photo_url"];
					[dictTemp setObject:[dict objectForKey:@"user_id"] forKey:@"user_id"];
					
					[lstTemp addObject:dictTemp];
				}
			}
			
			NSMutableDictionary *dictTemp = [[NSMutableDictionary alloc] init];
			
			[dictTemp setObject:[AppDelegate sharedDelegate].firstName forKey:@"fname"];
			[dictTemp setObject:[AppDelegate sharedDelegate].lastName forKey:@"lname"];
			[dictTemp setObject:[AppDelegate sharedDelegate].photoUrl forKey:@"photo_url"];
			[dictTemp setObject:[AppDelegate sharedDelegate].userId forKey:@"user_id"];
			
			[lstTemp addObject:dictTemp];
						
			((ChatViewController*)viewcontroller).lstBoardUser = [[NSMutableArray alloc] initWithArray:lstTemp];
			((ChatViewController*)viewcontroller).boardid = [[_responseObject objectForKey:@"data"] objectForKey:@"board_id"];
			
			[self dismissViewControllerAnimated:YES completion:nil];
		
		}else{
			[self showAlert:[[_responseObject objectForKey:@"err"] objectForKey:@"errMsg"]];
		}
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
		
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        [ self  showAlert: @"Internet Connection Error!" ] ;
		
    } ;
    
	[[YYYCommunication sharedManager] CreateChatBoard:[AppDelegate sharedDelegate].sessionId userids:ids successed:successed failure:failure];
}

-(IBAction)btChatClick:(id)sender
{
	[btChatContact setSelected:YES];
	[btAllContact setSelected:NO];
	
	[btSelectAll setHidden:YES];
	[lblSelectAll setHidden:YES];
	
	[lst_searched removeAllObjects];
	for (NSDictionary *dict in lst_user) {
		if ([lst_selected containsObject:[dict objectForKey:@"user_id"]]) {
			[lst_searched addObject:dict];
		}
	}
    lst_chatContactSelected = [lst_searched mutableCopy];
    if ([lst_searched count] == 0) {
        btSelectAll.enabled = NO;
    }else{
        btSelectAll.enabled = YES;
    }
	[tbl_chat reloadData];
    if (srb_chat.text) {
        [self searchKeyword:srb_chat.text];
    }
	if ([lst_selected count] == [lst_searched count])
	{
		[btSelectAll setSelected:YES];
	}
	else
	{
		[btSelectAll setSelected:NO];
	}
    [tbl_chat setAllowsSelection:NO];
}

-(IBAction)btContactClick:(id)sender
{
	[btChatContact setSelected:NO];
	[btAllContact setSelected:YES];
	
	[btSelectAll setHidden:NO];
	[lblSelectAll setHidden:NO];
	
	lst_searched = [[NSMutableArray alloc] initWithArray:lst_user];
    lst_chatContactSelected = [lst_searched mutableCopy];
    if ([lst_searched count] == 0) {
        btSelectAll.enabled = NO;
    }else{
        btSelectAll.enabled = YES;
    }
	[tbl_chat reloadData];
    
    if (srb_chat.text) {
        [self searchKeyword:srb_chat.text];
    }
	if ([lst_selected count] == [lst_searched count])
	{
		[btSelectAll setSelected:YES];
	}
	else
	{
		[btSelectAll setSelected:NO];
	}
    [tbl_chat setAllowsSelection:YES];
}

-(IBAction)btSelectAllClick:(id)sender
{
	if (btSelectAll.isSelected)
	{
		[btSelectAll setSelected:NO];
		
		for (NSDictionary *dict in lst_searched)
		{
			[lst_selected removeObject:[dict objectForKey:@"user_id"]];
		}
	}
	else{
		[btSelectAll setSelected:YES];
        [lst_selected removeAllObjects];
		for (NSDictionary *dict in lst_searched)
		{
			[lst_selected addObject:[dict objectForKey:@"user_id"]];
		}
	}
	if ([lst_selected count])
	{
        if (!isReturnFromConference) {
            [vwBottom setHidden:NO];
        }
        
        [self tableViewHeightChanged:YES];
		
		if ([lstCurrentUserIds count] != [lst_user count])
		{
			[btAccept setHidden:NO];
		}
	}
	else
	{
        if (!isReturnFromConference) {
            [vwBottom setHidden:YES];
        }
        [self tableViewHeightChanged:NO];
		[btAccept setHidden:YES];
	}
    if ([lst_searched count] == 0) {
        btSelectAll.enabled = NO;
    }else{
        btSelectAll.enabled = YES;
    }
	[tbl_chat reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [lst_searched count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *dict = [lst_searched objectAtIndex:indexPath.row];
	
	NSString *strIdentifier = @"Cell";
	YYYSelectContactCell *cell = [tableView dequeueReusableCellWithIdentifier:strIdentifier];
	if (cell == nil) {
		cell = [YYYSelectContactCell sharedCell];
	}
	
    UIImageView *profileImageView = (UIImageView*)[cell viewWithTag:100];
    
    profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2.0f;
    profileImageView.layer.masksToBounds = YES;
    profileImageView.layer.borderColor = [UIColor colorWithRed:128.0/256.0 green:100.0/256.0 blue:162.0/256.0 alpha:1.0f].CGColor;
    profileImageView.layer.borderWidth = 1.0f;
    
	[(UIImageView*)[cell viewWithTag:100] setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"photo_url"]]];
	[(UILabel*)[cell viewWithTag:101] setText:[NSString stringWithFormat:@"%@ %@",[dict objectForKey:@"first_name"],[dict objectForKey:@"last_name"]]];

	if ([lst_selected containsObject:[dict objectForKey:@"user_id"]])
	{
		[cell setBackgroundColor:[UIColor colorWithRed:223/255.0f green:209/255.0f blue:237/255.0f alpha:1.0f]];
	}else{
		[cell setBackgroundColor:[UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f]];
	}
	
	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.view endEditing:YES];
	
	NSDictionary *dict = [lst_searched objectAtIndex:indexPath.row];
	
	if ([lstCurrentUserIds containsObject:[dict objectForKey:@"user_id"]])
	{
		return;
	}
	
	if ([lst_selected containsObject:[dict objectForKey:@"user_id"]])
	{
		[lst_selected removeObject:[dict objectForKey:@"user_id"]];
	}
	else
	{
        if (isReturnFromConference) {
            if ((lst_selected.count + [AppDelegate sharedDelegate].conferenceMembersForVideoCalling.count) > 6) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Oops, you selected more than 7 contacts" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                [alert show];
            }else{
                [lst_selected addObject:[dict objectForKey:@"user_id"]];
            }
        }else{
            [lst_selected addObject:[dict objectForKey:@"user_id"]];
        }
	}
	
	if ([lst_selected count])
	{
        if (!isReturnFromConference) {
            [vwBottom setHidden:NO];
        }
        [self tableViewHeightChanged:YES];
        
		if ([lstCurrentUserIds count] != [lst_user count])
		{
			[btAccept setHidden:NO];
		}
		
	}else{
        if (!isReturnFromConference) {
            [vwBottom setHidden:YES];
        }
        [self tableViewHeightChanged:NO];
		[btAccept setHidden:YES];
	}
	
    //NSLog(@"lst_selected_count(in table)-----%lu",(unsigned long)[lst_selected count]);
	if ([lst_selected count] == [lst_searched count])
	{
		[btSelectAll setSelected:YES];
	}
	else
	{
		[btSelectAll setSelected:NO];
	}
    if ([lst_searched count] == 0) {
        btSelectAll.enabled = NO;
    }else{
        btSelectAll.enabled = YES;
    }
	[tbl_chat reloadData];
}

-(void)tableViewHeightChanged:(BOOL)is_show{
    if (!isReturnFromConference) {
        CGRect tableFrame = [tbl_chat frame];
        if (is_show) {
            tableFrame.size.height = tableHeightToFix - 50.0f;
        }else{
            tableFrame.size.height = tableHeightToFix;
        }
        [tbl_chat setFrame:tableFrame];
    }
}
-(NSString*)getDate : (NSString*)strDiff
{
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:-strDiff.intValue];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if ([[[date description] substringToIndex:10] isEqualToString:[[[NSDate date] description] substringToIndex:10]]) {
        formatter.timeStyle = NSDateFormatterShortStyle;
    }else{
        formatter.dateStyle = NSDateFormatterShortStyle;
    }
    return [formatter stringFromDate:date];
}

//Search0
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    if (btChatContact.selected) {
        [lst_searched removeAllObjects];
        for (NSDictionary *dict in lst_user) {
            if ([lst_selected containsObject:[dict objectForKey:@"user_id"]]) {
                [lst_searched addObject:dict];
            }
        }
        lst_chatContactSelected = [lst_searched mutableCopy];
    }else
    {
        lst_chatContactSelected = [lst_user mutableCopy];
    }
    [searchBar setShowsCancelButton:YES animated:YES];
    return TRUE;
}
-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:NO animated:YES];
    return TRUE;
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [self searchKeyword:@""];
	[self.view endEditing:YES];
    [searchBar setShowsCancelButton:NO animated:YES];
}

-(BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	NSString *strKeyword = searchBar.text;
	if ([text isEqualToString:@""])
	{
		//Backspace
		if ([strKeyword length]) {
			strKeyword = [strKeyword substringToIndex:[strKeyword length] - 1];
		}
	}
	else
	{
		strKeyword = [NSString stringWithFormat:@"%@%@",strKeyword,text];
	}
	
	[self searchKeyword:strKeyword];
	
	return YES;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	if ([searchText isEqualToString:@""]) {
		[self searchKeyword:@""];
	}
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[self searchKeyword:searchBar.text];
	[self.view endEditing:YES];
    [searchBar setShowsCancelButton:NO animated:YES];
}

-(void)searchKeyword:(NSString*)keyword
{
	if ([keyword isEqualToString:@""])
	{
		lst_searched = [[NSMutableArray alloc] initWithArray:lst_chatContactSelected];
	}
	else
	{
		[lst_searched removeAllObjects];
		
		for (NSDictionary *dict in lst_chatContactSelected) {
			if ([[[dict objectForKey:@"first_name"] lowercaseString] rangeOfString:keyword.lowercaseString].location != NSNotFound || [[[dict objectForKey:@"last_name"] lowercaseString] rangeOfString:keyword.lowercaseString].location != NSNotFound) {
				[lst_searched addObject:dict];
			}
		}
	}
	
	//Set SelectAll Button
	BOOL bSelectAll = YES;
	
	for (NSDictionary *dict in lst_searched) {
		if (![lst_selected containsObject:[dict objectForKey:@"user_id"]]) {
			bSelectAll = NO;
			break;
		}
	}
	
	if (![lst_searched count]) {
		bSelectAll = NO;
	}
	
	if (bSelectAll) {
		[btSelectAll setSelected:YES];
	}else{
		[btSelectAll setSelected:NO];
	}
	
    if ([lst_searched count] == 0) {
        btSelectAll.enabled = NO;
    }else{
        btSelectAll.enabled = YES;
    }
    
	[tbl_chat reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
