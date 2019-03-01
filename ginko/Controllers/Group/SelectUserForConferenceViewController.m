//
//  SelectUserForConferenceViewController.m
//  ginko
//
//  Created by stepanekdavid on 6/7/17.
//  Copyright © 2017 com.xchangewithme. All rights reserved.
//

#import "SelectUserForConferenceViewController.h"
#import "YYYSelectContactCell.h"
#import "UIImageView+AFNetworking.h"
#import "YYYCommunication.h"
#import "MBProgressHUD.h"
#import "VideoVoiceConferenceViewController.h"
#import "GroupContactsViewController.h"
#import "MenuViewController.h"

@interface SelectUserForConferenceViewController ()<UIActionSheetDelegate>
{
    NSString *availableIdsWithConfere;
}
@end

@implementation SelectUserForConferenceViewController
@synthesize isReturnFromGruopView, isDirectory, isReturnFromMenu, isReturnFromGroupChat;
@synthesize arrayUsers;
@synthesize viewcontroller;
@synthesize boardid, conferenceType, isReturnFromConference;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    lst_searched	= [[NSMutableArray alloc] init];
    lst_user		= [[NSMutableArray alloc] init];
    lst_selected	= [[NSMutableArray alloc] init];
    arraySelectedUsers = [[NSMutableArray alloc] init];
    availableIdsWithConfere = @"";
    if (arrayUsers) {        
        lst_user = arrayUsers;
        NSSortDescriptor *sortDescriptor;
        if (isDirectory)
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"fname" ascending:YES selector:@selector(localizedStandardCompare:)];
        else
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"first_name" ascending:YES selector:@selector(localizedStandardCompare:)];
        NSMutableArray * sortDescriptors = [NSMutableArray arrayWithObject:sortDescriptor];
        [lst_user sortUsingDescriptors:sortDescriptors];
        lst_searched = [[NSMutableArray alloc] initWithArray:lst_user];
        [tbl_chat reloadData];
    }
    if (isReturnFromMenu || isReturnFromConference) {
        [self GetFriend];
    }
    
    
    if (isReturnFromConference) {
        lblSelectUp.text = [NSString stringWithFormat:@"Select up to %lu", 7-APPDELEGATE.conferenceMembersForVideoCalling.count];
    }
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)GetFriend
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            if (isReturnFromMenu){
                for (NSDictionary *dict in [[_responseObject objectForKey:@"data"] objectForKey:@"contact"])
                {
                    if ([[dict objectForKey:@"sharing_status"] integerValue] != 4) {
                        [lst_user addObject:dict];
                    }
                }
            }else if (isReturnFromConference) {
                for (NSDictionary *dict in [[_responseObject objectForKey:@"data"] objectForKey:@"contact"])
                {
                    BOOL isExist = NO;
                    for (NSDictionary *member in APPDELEGATE.conferenceMembersForVideoCalling) {
                        if ([[member objectForKey:@"user_id"] integerValue] == [[dict objectForKey:@"user_id"] integerValue]) {
                            isExist = YES;
                            break;
                        }
                    }
                    if (!isExist && [[dict objectForKey:@"sharing_status"] integerValue] != 4) {
                        [lst_user addObject:dict];
                    }
                }
            }
            
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"first_name" ascending:YES selector:@selector(localizedStandardCompare:)];
            NSMutableArray * sortDescriptors = [NSMutableArray arrayWithObject:sortDescriptor];
            [lst_user sortUsingDescriptors:sortDescriptors];
            lst_searched = [[NSMutableArray alloc] initWithArray:lst_user];
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
    
    if (isReturnFromGruopView) {
        [self sendPreScreenWithIds:strIds availUsers:arraySelectedUsers];
    }else if (isReturnFromMenu){
        [self sendPreScreenWithIdsAfterInitialConferenceMember:strIds];
    }else if (isReturnFromConference) {//conference
        if (!boardid) {
            [self CreateBoardAndAddMemberOnConference:strIds];
        }else{
            [self AddMemberOnConference:strIds];
        }
    }else if (isReturnFromGroupChat)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        [(YYYChatViewController*)viewcontroller getSelectedItems: strIds callType:conferenceType];
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
            ((VideoVoiceConferenceViewController*)viewcontroller).removeInviteNotification = YES;
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
- (void)sendPreScreenWithIds:(NSString *)ids availUsers:(NSMutableArray *)users{
    [((GroupContactsViewController *)viewcontroller) startVideoCallingWithSelectedContact:ids availContacts:users];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendPreScreenWithIdsAfterInitialConferenceMember:(NSString *)ids{
    availableIdsWithConfere = ids;
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    [sheet setTag:100];
    [sheet addButtonWithTitle:@"Ginko Video Call"];
    [sheet addButtonWithTitle:@"Ginko Voice Call"];
    [sheet addButtonWithTitle:@"Cancel"];
    sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
    [sheet showInView:self.view];
}
#pragma - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != (actionSheet.numberOfButtons - 1))
    {
        switch ([actionSheet tag]) {
            case 100:
            {
                
                if (buttonIndex == 0) {
                    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
                        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (!granted) {
                                    [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your Camera or Microphone is disabled.\nPlease go to settings and grant access to it."];
                                }
                                else {
                                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                                        if (!granted) {
                                            [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your Camera or Microphone is disabled.\nPlease go to settings and grant access to it."];
                                        }
                                        else {
                                            [self CreateVideoAndVoiceConferenceBoard:availableIdsWithConfere dict:nil type:1];
                                        }
                                    }];
                                }
                            });
                        }];
                    }
                }else if(buttonIndex == 1){
                    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
                        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (!granted) {
                                    [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your Camera or Microphone is disabled.\nPlease go to settings and grant access to it."];
                                }
                                else {
                                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                                        if (!granted) {
                                            [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your Camera or Microphone is disabled.\nPlease go to settings and grant access to it."];
                                        }
                                        else {
                                            [self CreateVideoAndVoiceConferenceBoard:availableIdsWithConfere dict:nil type:2];
                                        }
                                    }];
                                }
                            });
                        }];
                    }
                }
                break;
            }
            default:
                break;
        }
    }
}
-(void)CreateVideoAndVoiceConferenceBoard:(NSString*)ids dict:(NSDictionary *)contactInfo type:(NSInteger)_type
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            [APPDELEGATE.conferenceMembersForVideoCalling removeAllObjects];
            
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
            APPDELEGATE.isOwnerForConference = YES;
            APPDELEGATE.isJoinedOnConference = YES;
            APPDELEGATE.conferenceId = [[_responseObject objectForKey:@"data"] objectForKey:@"board_id"];
            
            [self dismissViewControllerAnimated:YES completion:nil];
             [((MenuViewController *)viewcontroller) startVideoCallingWithSelectedContact:[[_responseObject objectForKey:@"data"] objectForKey:@"board_id"] type:_type];
            
            
            
        }else{
            [CommonMethods showAlertUsingTitle:@"Error!" andMessage:[[_responseObject objectForKey:@"err"] objectForKey:@"errMsg"]];
        }
    };
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Internet Connection Error!"];
        
    } ;
    
    [[YYYCommunication sharedManager] CreateChatBoard:[AppDelegate sharedDelegate].sessionId userids:ids successed:successed failure:failure];
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
    
    
    
    if (isDirectory || isReturnFromMenu|| isReturnFromConference) {
        if (isDirectory) {
            [(UIImageView*)[cell viewWithTag:100] setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"profile_image"]]];
            [(UILabel*)[cell viewWithTag:101] setText:[NSString stringWithFormat:@"%@ %@",[dict objectForKey:@"fname"],[dict objectForKey:@"lname"]]];
        }else if (isReturnFromMenu || isReturnFromConference){
            [(UIImageView*)[cell viewWithTag:100] setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"photo_url"]]];
            [(UILabel*)[cell viewWithTag:101] setText:[NSString stringWithFormat:@"%@ %@",[dict objectForKey:@"first_name"],[dict objectForKey:@"last_name"]]];
        }
        if ([lst_selected containsObject:[dict objectForKey:@"user_id"]])
        {
            [cell setBackgroundColor:[UIColor colorWithRed:223/255.0f green:209/255.0f blue:237/255.0f alpha:1.0f]];
        }else{
            [cell setBackgroundColor:[UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f]];
        }
    }else{
        [(UIImageView*)[cell viewWithTag:100] setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"photo_url"]]];
        [(UILabel*)[cell viewWithTag:101] setText:[NSString stringWithFormat:@"%@ %@",[dict objectForKey:@"first_name"],[dict objectForKey:@"last_name"]]];
        if ([lst_selected containsObject:[dict objectForKey:@"contact_id"]])
        {
            [cell setBackgroundColor:[UIColor colorWithRed:223/255.0f green:209/255.0f blue:237/255.0f alpha:1.0f]];
        }else{
            [cell setBackgroundColor:[UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f]];
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    
    NSDictionary *dict = [lst_searched objectAtIndex:indexPath.row];

    if (isDirectory || isReturnFromMenu || isReturnFromConference) {
        if ([lst_selected containsObject:[dict objectForKey:@"user_id"]])
        {
            [lst_selected removeObject:[dict objectForKey:@"user_id"]];
            [arraySelectedUsers removeObject:dict];
        }
        else
        {
            if (isReturnFromConference) {
                if ((lst_selected.count + APPDELEGATE.conferenceMembersForVideoCalling.count) > 6) {
                    NSString *msg = @"Oops, you selected more than 7 contacts";
                    if (isReturnFromConference) {
                        msg = [NSString stringWithFormat:@"Oops, you selected more than  %lu contacts", 7-APPDELEGATE.conferenceMembersForVideoCalling.count];
                    }
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                    [alert show];
                }else{
                    [lst_selected addObject:[dict objectForKey:@"user_id"]];
                    [arraySelectedUsers addObject:dict];
                }
            }else{
                if (lst_selected.count > 6) {
                    NSString *msg = @"Oops, you selected more than 7 contacts";
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                    [alert show];
                }else{
                    [lst_selected addObject:[dict objectForKey:@"user_id"]];
                    [arraySelectedUsers addObject:dict];
                }
            }
            
        }
    }else{
        if ([lst_selected containsObject:[dict objectForKey:@"contact_id"]])
        {
            [lst_selected removeObject:[dict objectForKey:@"contact_id"]];
            [arraySelectedUsers removeObject:dict];
        }
        else
        {
            if (lst_selected.count > 6) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Oops, you selected more than 7 contacts" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                [alert show];
            }else{
                [lst_selected addObject:[dict objectForKey:@"contact_id"]];
                [arraySelectedUsers addObject:dict];
            }
        }
    }
    
    if ([lst_selected count])
    {
        [btAccept setHidden:NO];
    }else{
        [btAccept setHidden:YES];
    }

    [tbl_chat reloadData];
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
        lst_searched = [[NSMutableArray alloc] initWithArray:lst_user];
    }
    else
    {
        [lst_searched removeAllObjects];
        
        for (NSDictionary *dict in lst_user) {
            if ([dict objectForKey:@"first_name"]) {
                if ([[[dict objectForKey:@"first_name"] lowercaseString] rangeOfString:keyword.lowercaseString].location != NSNotFound || [[[dict objectForKey:@"last_name"] lowercaseString] rangeOfString:keyword.lowercaseString].location != NSNotFound) {
                    [lst_searched addObject:dict];
                }
            }else{
                if ([[[dict objectForKey:@"fname"] lowercaseString] rangeOfString:keyword.lowercaseString].location != NSNotFound || [[[dict objectForKey:@"lname"] lowercaseString] rangeOfString:keyword.lowercaseString].location != NSNotFound) {
                    [lst_searched addObject:dict];
                }
            }
        }
    }

    [tbl_chat reloadData];
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
