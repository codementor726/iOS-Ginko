//
//  Ginko
//
//  Created by Mobile on 4/2/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import "ProfileRequestController.h"
#import "ProfileCell.h"
#import "MapViewController.h"
#import "Communication.h"
#import "YYYCommunication.h"
#import "LoginSettingViewController.h"

#import "UIImage+Tint.h"

#import "ManageDirectoryViewController.h"

static NSString * const ProfileCellIdentifier = @"ProfileCell";

@interface ProfileRequestController (){
    NSMutableArray *allCurrentUserInforIDsForSharing;
    NSMutableArray *allInfosIdsToShared;
    BOOL isAllShared;
    
    UIAlertView *closeAlertWhenConferenceView;
}

@end

@implementation ProfileRequestController

#define ALERT_REMOVE_CONTACT            210
#define ALERT_CANCEL_REQUEST_BY_ID      211
#define ALERT_CANCEL_REQUEST_BY_EMAIL   212

@synthesize contactInfo;
@synthesize myInfo;
@synthesize appDelegate;
@synthesize navBarColor, isRequestForDirectoryUser;

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
    
    closeAlertWhenConferenceView = [[UIAlertView alloc] init];
    
    if (!navBarColor) {
        navView.backgroundColor = self.navigationController.navigationBar.barTintColor;
        
        backButton.tintColor = approveBut.tintColor = shareYourLeafLabel.textColor = contactName.textColor = self.navigationController.navigationBar.tintColor;
        leafImageView.image = [[UIImage imageNamed:@"leaf_line.png"] tintImageWithColor:self.navigationController.navigationBar.tintColor];
        
    }else{
        [self.navigationController.navigationBar setBarTintColor:COLOR_GREEN_THEME];
    }
    [mainTable registerNib:[UINib nibWithNibName:ProfileCellIdentifier bundle:nil] forCellReuseIdentifier:ProfileCellIdentifier];
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    NSDate * send_request_date = [formatter dateFromString:[contactInfo objectForKey:@"send_request_date"]];
	[formatter setDateFormat:@"MMMM dd, yyyy"];
    date.text = [formatter stringFromDate:send_request_date];
    
    myInfo = [NSDictionary dictionary];
    profileDict = [[NSMutableDictionary alloc] init];
    homeDict = [[NSMutableDictionary alloc] init];
    workDict = [[NSMutableDictionary alloc] init];
    homeIdDict = [[NSMutableDictionary alloc] init];
    workIdDict = [[NSMutableDictionary alloc] init];
    
    _sharingInfo = [[NSString alloc] init];
    _sharedFieldIds = [[NSString alloc] init];
    _shareHomeFieldIds = [[NSString alloc] init];
    _shareWorkFieldIds = [[NSString alloc] init];
    
    allCurrentUserInforIDsForSharing = [[NSMutableArray alloc] init];
    allInfosIdsToShared = [[NSMutableArray alloc] init];
    isAllShared = NO;
    
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    // self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:230.0/256.0 green:1.0f blue:190.0/256.0 alpha:1.0f];
    
    // Zhun's
    totalArr = [[NSMutableArray alloc] init];
    lstField = [[NSMutableArray alloc] initWithObjects:@"Mobile",@"Mobile#2",@"Phone",@"Phone#2",@"Phone#3",@"Fax",@"Email",@"Email#2",@"Address",@"Address#2",@"Birthday",@"Facebook",@"Twitter",@"Website",@"Custom",@"Custom#2",@"Custom#3", nil];
    
    [self getMyInfo];
//    [self performSelector:@selector(GetShareCells)
//               withObject:nil
//               afterDelay:0.1f];
    
    // Do any additional setup after loading the view from its nib.
    
    [_btnTrash setImage:[[UIImage imageNamed:@"TrashIcon"] tintImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    
    NSLog(@"***************** type ********** : %d", APPDELEGATE.type);
}

- (void)getMyInfo
{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES];
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            myInfo = [_responseObject objectForKey:@"data"];
            NSArray * profileArray = [[myInfo objectForKey:@"profile"] objectForKey:@"fields"];
            NSArray * homeArray = [[myInfo objectForKey:@"home"] objectForKey:@"fields"];
            NSArray * workArray = [[myInfo objectForKey:@"work"] objectForKey:@"fields"];
            
            // Set Profile and Set Name on Nav Bar
            [profileDict setObject:@"" forKey:@"firstname"];
            [profileDict setObject:@"" forKey:@"lastname"];
            [profileDict setObject:@"" forKey:@"Birthday"];
        
            for (int i = 0 ; i < [profileArray count] ; i++)
            {
                NSDictionary * dict = [profileArray objectAtIndex:i];
                if ([[dict objectForKey:@"field_name"] isEqualToString:@"First Name"])
                {
                    [profileDict setObject:[dict objectForKey:@"field_value"] forKey:@"firstname"];
                }
                else if ([[dict objectForKey:@"field_name"] isEqualToString:@"Middle Name"])
                {
                    [profileDict setObject:[dict objectForKey:@"field_value"] forKey:@"middlename"];
                }
                else if ([[dict objectForKey:@"field_name"] isEqualToString:@"Last Name"])
                {
                    [profileDict setObject:[dict objectForKey:@"field_value"] forKey:@"lastname"];
                }
                else if ([[dict objectForKey:@"field_name"] isEqualToString:@"Birthday"])
                {
                    [profileDict setObject:[dict objectForKey:@"field_value"] forKey:@"Birthday"];
                }
            }
            
            NSString *strName = @"";
            
            if (contactInfo.count == 1) {
                if (![[myInfo[@"contact_info"] objectForKey:@"first_name"] isKindOfClass:[NSNull class]])
                    strName = [myInfo[@"contact_info"] objectForKey:@"first_name"];
                if (![[myInfo[@"contact_info"] objectForKey:@"last_name"] isKindOfClass:[NSNull class]])
                    strName = [NSString stringWithFormat:@"%@ %@", strName, [myInfo[@"contact_info"] objectForKey:@"last_name"]];
            } else {
                if (![[contactInfo objectForKey:@"first_name"] isKindOfClass:[NSNull class]])
                    strName = [contactInfo objectForKey:@"first_name"];
                if (![[contactInfo objectForKey:@"last_name"] isKindOfClass:[NSNull class]])
                    strName = [NSString stringWithFormat:@"%@ %@", strName, [contactInfo objectForKey:@"last_name"]];
                strName = [strName stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
                if ([strName isEqualToString:@""])
                    strName = [contactInfo objectForKey:@"email"];
            }
//            if (![[profileDict objectForKey:@"firstname"] isEqualToString:@""])
//                strName = [profileDict objectForKey:@"firstname"];
//            if (![[profileDict objectForKey:@"middlename"] isEqualToString:@""])
//                strName = [NSString stringWithFormat:@"%@ %@", strName, [profileDict objectForKey:@"middlename"]];
//            if (![[profileDict objectForKey:@"lastname"] isEqualToString:@""])
//                strName = [NSString stringWithFormat:@"%@ %@", strName, [profileDict objectForKey:@"lastname"]];
            
            if (isRequestForDirectoryUser) {
                if (contactInfo.count == 1) {
                    if (![[myInfo[@"contact_info"] objectForKey:@"first_name"] isKindOfClass:[NSNull class]])
                        strName = [myInfo[@"contact_info"] objectForKey:@"first_name"];
                    if (![[myInfo[@"contact_info"] objectForKey:@"last_name"] isKindOfClass:[NSNull class]])
                        strName = [NSString stringWithFormat:@"%@ %@", strName, [myInfo[@"contact_info"] objectForKey:@"last_name"]];
                } else {
                    if (![[contactInfo objectForKey:@"fname"] isKindOfClass:[NSNull class]])
                        strName = [contactInfo objectForKey:@"fname"];
                    if (![[contactInfo objectForKey:@"lname"] isKindOfClass:[NSNull class]])
                        strName = [NSString stringWithFormat:@"%@ %@", strName, [contactInfo objectForKey:@"lname"]];
                    strName = [strName stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
                    if ([strName isEqualToString:@""])
                        strName = [contactInfo objectForKey:@"email"];
                }
            }
            contactName.text = strName;
            
            if (_directoryId && (appDelegate.type == 6 || appDelegate.type == 7 || appDelegate.type == 8 || appDelegate.type == 9)) {
                contactName.text = _directoryName;
            }
            // Set Home Info
            
            for (int i = 0 ; i < [homeArray count] ; i++)
            {
                NSDictionary * dict = [homeArray objectAtIndex:i];
                
                if ([lstField containsObject:[dict objectForKey:@"field_name"]])
                {
                    [homeDict setObject:[dict objectForKey:@"field_value"] forKey:[dict objectForKey:@"field_name"]];
                    [homeIdDict setObject:[dict objectForKey:@"field_id"] forKey:[dict objectForKey:@"field_name"]];
                }
            }
            
            // Set Work Info
            for (int i = 0 ; i < [workArray count] ; i++)
            {
                NSDictionary * dict = [workArray objectAtIndex:i];
                
                if ([lstField containsObject:[dict objectForKey:@"field_name"]])
                {
                    [workDict setObject:[dict objectForKey:@"field_value"] forKey:[dict objectForKey:@"field_name"]];
                    [workIdDict setObject:[dict objectForKey:@"field_id"] forKey:[dict objectForKey:@"field_name"]];
                }
            }
            
            // Set Total Array
            if ([homeDict count] > 0)
            {
                NSMutableDictionary * tempDict = [[NSMutableDictionary alloc] init];
                
                [tempDict setObject:@"Home" forKey:@"type"];
                [tempDict setObject:@"header" forKey:@"field_name"];
                [tempDict setObject:@"" forKey:@"field_value"];
                [tempDict setObject:@"" forKey:@"field_id"];
                
                [totalArr addObject:tempDict];
                
                NSArray *keyArr = [homeDict allKeys];
                
                for (NSString *keyValue in lstField)
                {
                    for (int i = 0; i < [keyArr count]; i++)
                    {
                        if ([keyValue isEqualToString:[keyArr objectAtIndex:i]]) {
                            NSMutableDictionary * tempDict = [[NSMutableDictionary alloc] init];
                            
                            [tempDict setObject:@"Home" forKey:@"type"];
                            [tempDict setObject:[keyArr objectAtIndex:i] forKey:@"field_name"];
                            [tempDict setObject:[homeDict objectForKey:[keyArr objectAtIndex:i]] forKey:@"field_value"];
                            [tempDict setObject:[homeIdDict objectForKey:[keyArr objectAtIndex:i]] forKey:@"field_id"];
                            
                            [totalArr addObject:tempDict];
                            [allCurrentUserInforIDsForSharing addObject:[homeIdDict objectForKey:[keyArr objectAtIndex:i]]];
                            break;
                        }
                    }
                }
            }
            
            if ([workDict count] > 0)
            {
                NSMutableDictionary * tempDict = [[NSMutableDictionary alloc] init];
                
                [tempDict setObject:@"Work" forKey:@"type"];
                [tempDict setObject:@"header" forKey:@"field_name"];
                [tempDict setObject:@"" forKey:@"field_value"];
                [tempDict setObject:@"" forKey:@"field_id"];
                
                [totalArr addObject:tempDict];
                
                NSArray *keyArr = [workDict allKeys];
                
                for (NSString *keyValue in lstField)
                {
                    for (int i = 0; i < [keyArr count]; i++)
                    {
                        if ([keyValue isEqualToString:[keyArr objectAtIndex:i]]) {
                            NSMutableDictionary * tempDict = [[NSMutableDictionary alloc] init];
                            
                            [tempDict setObject:@"Work" forKey:@"type"];
                            [tempDict setObject:[keyArr objectAtIndex:i] forKey:@"field_name"];
                            [tempDict setObject:[workDict objectForKey:[keyArr objectAtIndex:i]] forKey:@"field_value"];
                            [tempDict setObject:[workIdDict objectForKey:[keyArr objectAtIndex:i]] forKey:@"field_id"];
                            
                            [totalArr addObject:tempDict];
                            [allCurrentUserInforIDsForSharing addObject:[workIdDict objectForKey:[keyArr objectAtIndex:i]]];
                            break;
                        }
                    }
                }
            }
            
            // Reload Table and Select Cells
            [mainTable reloadData];
            [self performSelector:@selector(GetShareCells)
                       withObject:nil
                       afterDelay:0.1f];
        }
    } ;

    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"Connection Error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    } ;
    
    NSString * contactId = @"";
    if (isRequestForDirectoryUser) {
        contactId= [contactInfo objectForKey:@"user_id"];
    }else{
        contactId= [contactInfo objectForKey:@"contact_id"];
    }
    [[Communication sharedManager] GetMyInfo:[AppDelegate sharedDelegate].sessionId contact_uid:contactId successed:successed failure:failure];
}

- (void)GetShareCells
{
    NSDictionary *dict;
    NSInteger share_status = @"";
    if (appDelegate.type == 7 || appDelegate.type == 8) {
        dict = contactInfo;
        share_status = [[dict objectForKey:@"sharing"] integerValue];
    }else{
        dict = [myInfo objectForKey:@"share"];
        share_status = [[dict objectForKey:@"sharing_status"] integerValue];
    }
    NSString * share_home_field = [dict objectForKey:@"shared_home_fids"];
    NSString * share_work_field = [dict objectForKey:@"shared_work_fids"];
    
    
    
    if (appDelegate.type == 2 && contactInfo.count != 1) // Pending
    {
        share_status = [[contactInfo objectForKey:@"sharing_status"] integerValue];
        share_home_field = [contactInfo objectForKey:@"shared_home_fids"];
        share_work_field = [contactInfo objectForKey:@"shared_work_fids"];
    }
    
    if ((share_status == 3 && [share_home_field isEqualToString:@""] && [share_work_field isEqualToString:@""]) ||
        (share_status == 1 && [share_home_field isEqualToString:@""] && workDict.count == 0) ||
        (share_status == 2 && [share_work_field isEqualToString:@""] && homeDict.count == 0))  // select all
    {
        checkBut.selected = YES;
        
        for (int i = 0; i < [totalArr count]; i++)
            [mainTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        
        return;
    }
    else if (share_status == 4) // chat only
    {
        chatBut.selected = YES;
        
        return;
    }
//    else if ([share_home_field isEqualToString:@""] && [share_work_field isEqualToString:@""])
//        return;
    
    NSArray *sharedHomeArrayIds = [share_home_field componentsSeparatedByString:@","];
    NSArray *sharedWorkArrayIds = [share_work_field componentsSeparatedByString:@","];
    int index = 0;
    [allInfosIdsToShared removeAllObjects];
    for (index = 0; index < [sharedHomeArrayIds count]; index ++) {
        [allInfosIdsToShared addObject:[NSString stringWithFormat:@"%@",[sharedHomeArrayIds objectAtIndex:index]]];
    }
    for (index = 0; index < [sharedWorkArrayIds count]; index ++) {
        [allInfosIdsToShared addObject:[NSString stringWithFormat:@"%@",[sharedWorkArrayIds objectAtIndex:index]]];
    }
    isAllShared = YES;
    for (index = 0; index < [allCurrentUserInforIDsForSharing count]; index ++) {
        if (![allInfosIdsToShared containsObject:[NSString stringWithFormat:@"%@",[allCurrentUserInforIDsForSharing objectAtIndex:index]]])
        {
            isAllShared = NO;
        }
    }
    
    if (isAllShared) {
        checkBut.selected = YES;
    }
    
    if ([share_home_field isEqualToString:@""] && (share_status == 1 || share_status == 3)) {
        for (int j = 0; j < [totalArr count]; j++)
        {
            NSDictionary *tempDict = [totalArr objectAtIndex:j];
            if ([[tempDict objectForKey:@"type"] isEqualToString:@"Home"])
                [mainTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    } else if ([share_work_field isEqualToString:@""] && (share_status == 2 || share_status == 3)) {
        for (int j = 0; j < [totalArr count]; j++)
        {
            NSDictionary *tempDict = [totalArr objectAtIndex:j];
            if ([[tempDict objectForKey:@"type"] isEqualToString:@"Work"])
                [mainTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    
    NSArray * h_split_items = [share_home_field componentsSeparatedByString:@","];
    NSArray * w_split_items = [share_work_field componentsSeparatedByString:@","];
    
    
    for (int i = 0 ; i < [h_split_items count] ; i++)
    {
        for (int j = 0; j < [totalArr count]; j++)
        {
            NSDictionary *tempDict = [totalArr objectAtIndex:j];
            
            if ([[tempDict objectForKey:@"field_id"] intValue] == [h_split_items[i] intValue] && ![[tempDict objectForKey:@"field_name"] isEqualToString:@"header"])
                [mainTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    
    for (int i = 0 ; i < [w_split_items count] ; i++)
    {
        for (int j = 0; j < [totalArr count]; j++)
        {
            NSDictionary *tempDict = [totalArr objectAtIndex:j];
            
            if ([[tempDict objectForKey:@"field_id"] intValue] == [w_split_items[i] intValue] && ![[tempDict objectForKey:@"field_name"] isEqualToString:@"header"])
                [mainTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    
    // check cells and select header
    int homeCount = 0;
    int workCount = 0;
    
    NSArray * selectedRows = [mainTable indexPathsForSelectedRows];
    for (int i = 0 ; i < [selectedRows count] ; i++)
    {
        NSIndexPath * selectRow = [selectedRows objectAtIndex:i];
        NSDictionary *tempDict = [totalArr objectAtIndex:selectRow.row];
        
        if ([[tempDict objectForKey:@"type"] isEqualToString:@"Home"])
            homeCount++;
        else
            workCount++;
    }
    if (homeCount >= [homeDict count] && homeCount > 0)
        [mainTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    if (workCount >= [workDict count] && workCount > 0)
    {
        if ([homeDict count] == 0)
            [mainTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        else
            [mainTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:([homeDict count] + 1) inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:navView];
    [self.navigationItem setHidesBackButton:YES animated:NO];
    [self.navigationController.navigationItem setHidesBackButton:YES animated:NO];
    
    if (appDelegate.type == 4 || appDelegate.type == 7)
    {
        [mainTable setFrame:CGRectMake(mainTable.frame.origin.x, mainTable.frame.origin.y, mainTable.frame.size.width, mainTable.frame.size.height - viewDelete.frame.size.height)];
        viewDelete.hidden = NO;
    }
    else
        viewDelete.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [navView removeFromSuperview];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeCurrentAlertWhenConferenceView) name:CLOSE_ALERT_WHEN_CONFERENCEVIEW_NOTIFICATION object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CLOSE_ALERT_WHEN_CONFERENCEVIEW_NOTIFICATION object:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)closeCurrentAlertWhenConferenceView{
    [closeAlertWhenConferenceView dismissWithClickedButtonIndex:-1 animated:YES];
}

- (void)onApprove:(id)sender
{
//    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"Oops!  Approved failed." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    [alertView show];
//    return;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            appDelegate.approveFlag = YES;
//            if (appDelegate.type == 4)
//                [self.navigationController popToRootViewControllerAnimated:YES];
//            else
            
            NSString *dirName = @"";
            if (_directoryId && (appDelegate.type == 6 || appDelegate.type == 7 || appDelegate.type == 8 || appDelegate.type == 9)) {
                dirName = _directoryName;
            }
            
            if (appDelegate.type == 6 || appDelegate.type == 9) {
                switch ([[[_responseObject objectForKey:@"data"] objectForKey:@"status_code"] integerValue]) {
                    case 1:{
                        if (appDelegate.type == 9) {
                            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                        }else{
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                        
                        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Congratulations!" message:[NSString stringWithFormat:@"You joined the %@ directory. A directory icon will appear in Groups", dirName] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
                        [alertView show];
                    }
                        break;
                    case 2:{
                        [self.navigationController popViewControllerAnimated:YES];
                        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Thank you!" message:@"This is a private directory. A message has been sent to the directory admin to provide you access." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
                        [alertView show];
                    }
                        break;
                    case 3:{
                        [self.navigationController popViewControllerAnimated:YES];
                        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Almost done!" message:@"The admin just sent you a validation link to your registration email. Please confirm link to gain access." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
                        [alertView show];
                    }
                        break;
                    case 4:{
                        [self.navigationController popViewControllerAnimated:YES];
                        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Fantastic!" message:@"Your access to the directory is pending directory admin approval." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
                        [alertView show];
                    }
                        break;
                    case 5:{
                        [self.navigationController popViewControllerAnimated:YES];
                        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Almost done!" message:@"A validation link was resent to the email you used for Giko registration. Please confirm link to gain access to the directory. Check your junk filter." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
                        [alertView show];
                    }
                        break;
                    case 6:{
                        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:[NSString stringWithFormat:@"Your Ginko registered email must have a domain of %@ to join this directory.\n\n Go to Ginko Login to add and validate a matching email domain based on the admin's directory requirement then try again.", [[_responseObject objectForKey:@"data"] objectForKey:@"domain"]] delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"OKay", nil];
                        alertView.tag = 1009;
                        [alertView show];
                    }
                        break;
                    default:
                        break;
                }
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        else
        {
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:[[_responseObject objectForKey:@"err"] objectForKey:@"errMsg"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"Oops!  Approved failed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    } ;
    
    
   
    
    if ([self GetInfo] == YES)
    {
        if (appDelegate.type == 0)
        {
            NSInteger contactType = [[contactInfo objectForKey:@"contact_type"] integerValue];
            NSString *contactId = [contactInfo objectForKey:@"contact_id"];
            if (contactType == 3) {
                [[Communication sharedManager] followEntity:[AppDelegate sharedDelegate].sessionId entity_id:[contactInfo objectForKey:@"entity_id"] successed:successed failure:failure];
            }
            else {
                [[Communication sharedManager] AnswerRequest:[AppDelegate sharedDelegate].sessionId contactId:contactId sharingInfo:_sharingInfo sharedHomeFieldIds:_shareHomeFieldIds sharedWorkFieldIds:_shareWorkFieldIds phoneOnly:phoneOnly emailOnly:emailOnly successed:successed failure:failure];
            }
        }
        else if (appDelegate.type == 1)
            if (contactInfo.count == 1)
                [[Communication sharedManager] RequestSend:[AppDelegate sharedDelegate].sessionId contactId:[contactInfo objectForKey:@"contact_id"] sharingInfo:_sharingInfo sharedHomeFieldIds:_shareHomeFieldIds sharedWorkFieldIds:_shareWorkFieldIds phoneOnly:phoneOnly emailOnly:emailOnly successed:successed failure:failure];
            else
                [[Communication sharedManager] SendInvitation:[AppDelegate sharedDelegate].sessionId sharingInfo:_sharingInfo email:[contactInfo objectForKey:@"email"] sharedHomeFieldIds:_shareHomeFieldIds sharedWorkFieldIds:_shareWorkFieldIds phoneOnly:phoneOnly emailOnly:emailOnly successed:successed failure:failure];
        else if (appDelegate.type == 2) {
            if (contactInfo.count == 1 || contactInfo.count == 6)
                [[Communication sharedManager] RequestSend:[AppDelegate sharedDelegate].sessionId contactId:[contactInfo objectForKey:@"contact_id"] sharingInfo:_sharingInfo sharedHomeFieldIds:_shareHomeFieldIds sharedWorkFieldIds:_shareWorkFieldIds phoneOnly:phoneOnly emailOnly:emailOnly successed:successed failure:failure];
            else
                [[Communication sharedManager] SendInvitation:[AppDelegate sharedDelegate].sessionId sharingInfo:_sharingInfo email:[contactInfo objectForKey:@"email"] sharedHomeFieldIds:_shareHomeFieldIds sharedWorkFieldIds:_shareWorkFieldIds phoneOnly:phoneOnly emailOnly:emailOnly successed:successed failure:failure];

        }
        else if (appDelegate.type == 3)
            [[Communication sharedManager] SendInvitation:[AppDelegate sharedDelegate].sessionId sharingInfo:_sharingInfo email:[contactInfo objectForKey:@"email"] sharedHomeFieldIds:_shareHomeFieldIds sharedWorkFieldIds:_shareWorkFieldIds phoneOnly:phoneOnly emailOnly:emailOnly successed:successed failure:failure];
        else if (appDelegate.type == 4)
            [[Communication sharedManager] UpdateExchangePermission:[AppDelegate sharedDelegate].sessionId contactId:[[contactInfo objectForKey:@"contact_id"] stringValue] sharingInfo:_sharingInfo sharedHomeFieldIds:_shareHomeFieldIds sharedWorkFieldIds:_shareWorkFieldIds phoneOnly:phoneOnly emailOnly:emailOnly successed:successed failure:failure];
        
        else if (appDelegate.type == 5){
            
            if (isRequestForDirectoryUser) {
                [[Communication sharedManager] RequestSend:[AppDelegate sharedDelegate].sessionId contactId:[contactInfo objectForKey:@"user_id"] sharingInfo:_sharingInfo sharedHomeFieldIds:_shareHomeFieldIds sharedWorkFieldIds:_shareWorkFieldIds phoneOnly:phoneOnly emailOnly:emailOnly successed:successed failure:failure];
            }else{
                [[Communication sharedManager] RequestSend:[AppDelegate sharedDelegate].sessionId contactId:[contactInfo objectForKey:@"contact_id"] sharingInfo:_sharingInfo sharedHomeFieldIds:_shareHomeFieldIds sharedWorkFieldIds:_shareWorkFieldIds phoneOnly:phoneOnly emailOnly:emailOnly successed:successed failure:failure];
            }
        }
        else if ((appDelegate.type == 6 || appDelegate.type == 8 || appDelegate.type == 9 )&& _directoryId)
            [[YYYCommunication sharedManager]  JoinMemberDirectory:appDelegate.sessionId directoryId:_directoryId sharing:_sharingInfo sharedHomeFids:_shareHomeFieldIds shareWorkFids:_shareWorkFieldIds successed:successed failure:failure];
        else if ((appDelegate.type == 7 || appDelegate.type == 8)&& _directoryId)
            [[YYYCommunication sharedManager]  UpdatePermissionMemberDirectory:appDelegate.sessionId directoryId:_directoryId sharing:_sharingInfo sharedHomeFids:_shareHomeFieldIds shareWorkFids:_shareWorkFieldIds successed:successed failure:failure];
        
    }
    else
    {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"Oops! Please select contact info to share." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)onBackBut:(id)sender
{
    if (appDelegate.type == 9) {
//        UIViewController *visibleController = [(UINavigationController *)[self.navigationController.viewControllers objectAtIndex:1] visibleViewController];
//        if (visibleController) {
//            if ([visibleController isKindOfClass:[ManageDirectoryViewController class]]) {
//                 [(ManageDirectoryViewController *)visibleController];
//            }
//        }
//        ManageDirectoryViewController *viewController = [self.navigationController.viewControllers objectAtIndex:1];
//        viewController.directoryName = _directoryName;
//        viewController.directoryInfo = directory
//        viewController.isCreate = YES;
//        viewController.isSetup = NO;
//        viewController.isJoinOwn = YES;
//        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
//        
        void ( ^successed )( id _responseObject ) = ^( id _responseObject )
        {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if ([[_responseObject objectForKey:@"success"] boolValue]) {
                ManageDirectoryViewController *viewController = [self.navigationController.viewControllers objectAtIndex:1];
                viewController.directoryName = [[_responseObject objectForKey:@"data"] objectForKey:@"name"];
                viewController.directoryInfo = [[_responseObject objectForKey:@"data"] mutableCopy];
                viewController.isCreate = YES;
                viewController.isSetup = NO;
                viewController.isJoinOwn = YES;
                [self.navigationController popToViewController:viewController animated:YES];
            }
        };
        
        void ( ^failure )( NSError* _error ) = ^( NSError* _error )
        {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Internet Connection Error!"];
        };
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[YYYCommunication sharedManager] GetDirectoryDetails:[AppDelegate sharedDelegate].sessionId directoryId:_directoryId successed:successed failure:failure];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)onTrashBut:(id)sender
{
    if (appDelegate.type != 7) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"Do you want to remove a contact?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        [alertView setTag:ALERT_REMOVE_CONTACT];
        [alertView show];
        closeAlertWhenConferenceView = alertView;
    }else{
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"Do you want to quit from this directory?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        [alertView setTag:ALERT_REMOVE_CONTACT];
        [alertView show];
        closeAlertWhenConferenceView = alertView;
    }
}

- (void)onMapBut:(id)sender
{
    CLLocationCoordinate2D pingLocation;
    pingLocation.latitude = [[contactInfo objectForKey:@"latitude"] floatValue];
    pingLocation.longitude = [[contactInfo objectForKey:@"longitude"] floatValue];
    MapViewController * controller = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
    controller.pingLocation = pingLocation;
    controller.locationName = address.text;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)onChatOnlyBut:(id)sender
{
    approveBut.hidden = NO;
    chatBut.selected = !chatBut.selected;
    checkBut.selected = NO;
    
    if (!chatBut.selected)
    {
        approveBut.hidden = YES;
        if (appDelegate.type == 7) {
            
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"Do you want to quit from this directory?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
            [alertView setTag:ALERT_REMOVE_CONTACT];
            [alertView show];
            closeAlertWhenConferenceView = alertView;
        }else if (appDelegate.type == 8) {
            [self showCancelAlert];
        }else{
            if (appDelegate.type == 2)
                [self showCancelAlert];
            else if ([[myInfo objectForKey:@"share"] objectForKey:@"is_pending"]) {
                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"Do you want to cancel the contact exchange request?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
                alertView.tag = ALERT_CANCEL_REQUEST_BY_ID;
                [alertView show];
                closeAlertWhenConferenceView = alertView;
            }
        }
        return;
    }
    
    for (int i = 0 ; i < [totalArr count] ; i++)
        [mainTable deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO];
    
    [self GetInfo];
}

- (void)onCheckBut:(id)sender
{
    approveBut.hidden = NO;
    chatBut.selected = NO;
    
    if (checkBut.selected)
    {
        checkBut.selected = NO;
        
        for (int i = 0 ; i < [totalArr count] ; i++)
            [mainTable deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO];

        if (!navBarColor) {
            approveBut.hidden = YES;
        }
        
        if (appDelegate.type == 7) {
            approveBut.hidden = YES;
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"Do you want to quit from this directory?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
            [alertView setTag:ALERT_REMOVE_CONTACT];
            [alertView show];
            closeAlertWhenConferenceView = alertView;
        }else if (appDelegate.type == 8) {
            approveBut.hidden = YES;
            [self showCancelAlert];
        }else{
            if ((contactInfo.count == 1 && myInfo[@"share"]) || contactInfo.count != 1)
            {
                approveBut.hidden = YES;
                
                if (appDelegate.type == 2)
                    [self showCancelAlert];
                else if ([[myInfo objectForKey:@"share"] objectForKey:@"is_pending"]) {
                    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"Do you want to cancel the contact exchange request?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
                    alertView.tag = ALERT_CANCEL_REQUEST_BY_ID;
                    [alertView show];
                    closeAlertWhenConferenceView = alertView;
                }
            }
        }
    }
    else
    {
        checkBut.selected = YES;
        
        for (int i = 0 ; i < [totalArr count] ; i++)
            [mainTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
    
    [self GetInfo];
}

#pragma UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [totalArr count] ;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProfileCell * cell = (ProfileCell *)[[[NSBundle mainBundle] loadNibNamed:@"ProfileCell" owner:nil options:nil] objectAtIndex:0];
//    if (cell == nil)
//    {
//        cell = [[ProfileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ProfileCellIdentifier];
//    }
    
    NSDictionary *dict = [totalArr objectAtIndex:indexPath.row];
    
    if ([cell viewWithTag:100])
        [[cell viewWithTag:100] removeFromSuperview];
    
    if ([[dict objectForKey:@"field_name"] isEqualToString:@"header"])
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        UILabel *lblCaption = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, 320, 50)];
        
        [lblCaption setBackgroundColor:[UIColor clearColor]];
        [lblCaption setTextColor:[UIColor colorWithRed:130.0f/255.0f green:87.0f/255.0f blue:131.0f/255.0f alpha:1.0f]];
        [lblCaption setFont:[UIFont boldSystemFontOfSize:14.0f]];
        lblCaption.text = [dict objectForKey:@"type"];
        
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Seperator"]];
        [imgView setFrame:CGRectMake(75, 25, 210, 1)];
        
        [view addSubview:lblCaption];
        [view addSubview:imgView];
        
        [view setBackgroundColor:[UIColor clearColor]];
        [view setTag:100];
        
        [cell addSubview:view];
    }
    else
    {
        cell.typeLabel.text = [NSString stringWithFormat:@"%@.", [dict objectForKey:@"field_name"]];
        cell.nameLabel.text = [dict objectForKey:@"field_value"];
    }
    
    // this is where you set your color view
    UIView *customColorView = [[UIView alloc] init];
    customColorView.backgroundColor = [UIColor colorWithRed:180/255.0
                                                      green:138/255.0
                                                       blue:171/255.0
                                                      alpha:0.3];
    cell.selectedBackgroundView =  customColorView;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    chatBut.selected = NO;
    
    NSDictionary *dict = [totalArr objectAtIndex:indexPath.row];
    
    // Select Header
    if ([[dict objectForKey:@"field_name"] isEqualToString:@"header"])
    {
        if ([[dict objectForKey:@"type"] isEqualToString:@"Home"]) // Select Home
        {
            [mainTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];

            for (long i = indexPath.row + 1; i < [totalArr count] ; i++)
            {
                NSDictionary *tempDict = [totalArr objectAtIndex:i];
                
                if ([[tempDict objectForKey:@"field_name"] isEqualToString:@"header"])
                    break;
                else
                    [mainTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
        else if ([[dict objectForKey:@"type"] isEqualToString:@"Work"]) // Select Work
        {
            for (long i = indexPath.row; i < [totalArr count] ; i++)
                [mainTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    else    // check the cells and select header
    {
        int homeCount = 0;
        int workCount = 0;
        
        NSArray * selectedRows = [tableView indexPathsForSelectedRows];
        for (int i = 0 ; i < [selectedRows count] ; i++)
        {
            NSIndexPath * selectRow = [selectedRows objectAtIndex:i];
            NSDictionary *tempDict = [totalArr objectAtIndex:selectRow.row];
            
            if ([[tempDict objectForKey:@"type"] isEqualToString:@"Home"])
                homeCount++;
            else
                workCount++;
        }
        if (homeCount >= [homeDict count] && homeCount > 0)
            [mainTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        if (workCount >= [workDict count] && workCount > 0)
        {
            if ([homeDict count] == 0)
                [mainTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            else
                [mainTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:([homeDict count] + 1) inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    
    // if all things is checked
    NSArray * selectedRows = [tableView indexPathsForSelectedRows];
    
    if ([selectedRows count] == [totalArr count])
        checkBut.selected = YES;
    
    [self GetInfo];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    checkBut.selected = NO;
    
    NSDictionary *dict = [totalArr objectAtIndex:indexPath.row];
    
    // Select Header
    if ([[dict objectForKey:@"field_name"] isEqualToString:@"header"])
    {
        if ([[dict objectForKey:@"type"] isEqualToString:@"Home"]) // Select Home
        {
            [mainTable deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO];
            
            for (int i = indexPath.row + 1; i < [totalArr count] ; i++)
            {
                NSDictionary *tempDict = [totalArr objectAtIndex:i];
                
                if ([[tempDict objectForKey:@"field_name"] isEqualToString:@"header"])
                    break;
                else
                    [mainTable deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO];
            }
        }
        else if ([[dict objectForKey:@"type"] isEqualToString:@"Work"]) // Select Work
        {
            for (int i = indexPath.row; i < [totalArr count] ; i++)
                [mainTable deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO];
        }
    }
    else    // check the cells and deSelect header
    {
        if ([[dict objectForKey:@"type"] isEqualToString:@"Home"])
            [mainTable deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO];
        else
        {
            for (int i = indexPath.row; i >= 0; i--)
            {
                NSDictionary *tempDict = [totalArr objectAtIndex:i];
                
                if ([[tempDict objectForKey:@"field_name"] isEqualToString:@"header"])
                {
                    [mainTable deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO];
                    break;
                }
            }
        }
    }
    
    NSArray *selectedRows = [tableView indexPathsForSelectedRows];
    if ([selectedRows count] == 0 && appDelegate.type == 2)
    {
        if ([contactInfo objectForKey:@"contact_id"])
        {
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"Do you want to cancel the contact exchange request?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
            alertView.tag = ALERT_CANCEL_REQUEST_BY_ID;
            [alertView show];
            closeAlertWhenConferenceView = alertView;
        }
        else
        {
            [self showCancelAlert];
        }
        approveBut.hidden = YES;
    } else if (selectedRows.count == 0) {
        approveBut.hidden = YES;
    }
    if (appDelegate.type == 7) {
        if ([selectedRows count] == 0){
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"Do you want to quit from this directory?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
            alertView.tag = ALERT_REMOVE_CONTACT;
            [alertView show];
            closeAlertWhenConferenceView = alertView;
        }
   
    }else if (appDelegate.type == 8) {
        if ([selectedRows count] == 0){
            [self showCancelAlert];
        }
        
    }else{
        if ([selectedRows count] == 0 && [[[myInfo objectForKey:@"share"] objectForKey:@"is_pending"] boolValue]){
            if ([contactInfo objectForKey:@"contact_id"])
            {
                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"Do you want to cancel the contact exchange request?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
                alertView.tag = ALERT_CANCEL_REQUEST_BY_ID;
                [alertView show];
                closeAlertWhenConferenceView = alertView;
            }
            else
            {
                [self showCancelAlert];
            }
        }
    }
    [self GetInfo];
}

- (BOOL)GetInfo
{
    NSArray * selectedRows = [mainTable indexPathsForSelectedRows];
    
    phoneOnly = NO;
    emailOnly = NO;
    _sharingInfo = @"1";
    _shareHomeFieldIds = @"";
    _shareWorkFieldIds = @"";
    
    if ([selectedRows count] == [totalArr count])
    {
        if (workDict.count == 0) // no work profile
            _sharingInfo = @"1";
        else if (homeDict.count == 0) // no home profile
            _sharingInfo = @"2";
        else
            _sharingInfo = @"3";

        if (appDelegate.type == 7 || appDelegate.type == 8) {
            approveBut.hidden = ([contactInfo[@"sharing"] integerValue] == [_sharingInfo integerValue] && [contactInfo[@"shared_home_fids"] isEqualToString:@""] && [contactInfo[@"shared_work_fids"] isEqualToString:@""]);
        }else{
            approveBut.hidden = ([[myInfo objectForKey:@"share"][@"sharing_status"] integerValue] == [_sharingInfo integerValue] && [[myInfo objectForKey:@"share"][@"shared_home_fids"] isEqualToString:@""] && [[myInfo objectForKey:@"share"][@"shared_work_fids"] isEqualToString:@""]);
        }
        return YES;
    }
    else if (chatBut.selected)
    {
        _sharingInfo = @"4";
        approveBut.hidden = ([[myInfo objectForKey:@"share"][@"sharing_status"] integerValue] == [_sharingInfo integerValue]);

        return YES;
    }
    else if ([selectedRows count] == 0 && !chatBut.selected)
        return NO;
    
    int homeCount, workCount;
    
    homeCount = workCount = 0;
    
    for (int i = 0 ; i < [selectedRows count] ; i++)
    {
        NSIndexPath * indexPath = [selectedRows objectAtIndex:i];
        NSDictionary *dict = [totalArr objectAtIndex:indexPath.row];
        if (![[dict objectForKey:@"field_name"] isEqualToString:@"header"])
        {
            if ([[dict objectForKey:@"type"] isEqualToString:@"Home"])
            {
                homeCount++;
                if ([_shareHomeFieldIds isEqualToString:@""])
                    _shareHomeFieldIds = [NSString stringWithFormat:@"%@", [dict objectForKey:@"field_id"]];
                else
                    _shareHomeFieldIds = [NSString stringWithFormat:@"%@,%@",_shareHomeFieldIds, [dict objectForKey:@"field_id"]];
            }
            if ([[dict objectForKey:@"type"] isEqualToString:@"Work"])
            {
                workCount++;
                if ([_shareWorkFieldIds isEqualToString:@""])
                    _shareWorkFieldIds = [NSString stringWithFormat:@"%@", [dict objectForKey:@"field_id"]];
                else
                    _shareWorkFieldIds = [NSString stringWithFormat:@"%@,%@",_shareWorkFieldIds, [dict objectForKey:@"field_id"]];
            }
        }
    }
    
    if (homeCount > 0 && workCount > 0)
    {
        _sharingInfo = @"3";
        if (homeCount == [[homeDict allKeys] count]) {
            _shareHomeFieldIds = @"";
        }
        if (workCount == [[workDict allKeys] count]) {
            _shareWorkFieldIds = @"";
        }
    }
    else if (homeCount > 0)
    {
        _sharingInfo = @"1";
        if (homeCount == [[homeDict allKeys] count]) {
            _shareHomeFieldIds = @"";
        }
    }
    else if (workCount > 0)
    {
        _sharingInfo = @"2";
        if (workCount == [[workDict allKeys] count]) {
            _shareWorkFieldIds = @"";
        }
    }
    
    NSDictionary *dict;
    NSInteger share_status;
    if (appDelegate.type == 7 || appDelegate.type == 8) {
        dict= contactInfo;
        share_status = [[dict objectForKey:@"sharing"] integerValue];
    }else{
        dict= [myInfo objectForKey:@"share"];
        share_status = [[dict objectForKey:@"sharing_status"] integerValue];
    }
    NSString * share_home_field = [dict objectForKey:@"shared_home_fids"];
    NSString * share_work_field = [dict objectForKey:@"shared_work_fids"];
    
    if (appDelegate.type == 2 && contactInfo.count != 1)
    {
        share_status = [[contactInfo objectForKey:@"sharing_status"] integerValue];
        share_home_field = [contactInfo objectForKey:@"shared_home_fids"];
        share_work_field = [contactInfo objectForKey:@"shared_work_fids"];
    }
    
    if([[NSSet setWithArray:[share_home_field componentsSeparatedByString:@","]] isEqualToSet:[NSSet setWithArray:[_shareHomeFieldIds componentsSeparatedByString:@","]]] && [[NSSet setWithArray:[share_work_field componentsSeparatedByString:@","]] isEqualToSet:[NSSet setWithArray:[_shareWorkFieldIds componentsSeparatedByString:@","]]] && share_status == [_sharingInfo integerValue])
        approveBut.hidden = YES;
    else
        approveBut.hidden = NO;
    
    return YES;
}

- (void)showCancelAlert
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"Do you want to cancel the contact exchange request?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [alertView setTag:ALERT_CANCEL_REQUEST_BY_EMAIL];
    [alertView show];
    closeAlertWhenConferenceView = alertView;
}

#pragma UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView tag] == ALERT_REMOVE_CONTACT)
    {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
            void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
                [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
                NSLog(@"%@",[_responseObject objectForKey:@"data"]);
                [self.navigationController popToRootViewControllerAnimated:YES];
            } ;
            
            void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
                [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
                NSLog(@"Remove Contact Failed");
            } ;
            if (appDelegate.type == 7) {
                [[YYYCommunication sharedManager] QuitMemberDirectory:[AppDelegate sharedDelegate].sessionId directoryId:_directoryId successed:successed failure:failure];
            }else{
                [[Communication sharedManager] RemoveContact:[AppDelegate sharedDelegate].sessionId contactIds:[contactInfo objectForKey:@"contact_id"] successed:successed failure:failure];
            }
        }
    }
    else if ([alertView tag] == ALERT_CANCEL_REQUEST_BY_EMAIL)
    {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
            void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
                [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
                NSLog(@"%@",[_responseObject objectForKey:@"data"]);
                [self.navigationController popViewControllerAnimated:YES];
            } ;
            
            void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
                [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
                NSLog(@"Request Cancel failed");
            } ;
            if (viewDelete.hidden) {
                if (appDelegate.type == 8) {
                    [[YYYCommunication sharedManager] CancelJoinRequestDirectory:APPDELEGATE.sessionId directoryIds:_directoryId successed:successed failure:failure];
                }else{
                    [[Communication sharedManager] DeleteSentInvitation:[AppDelegate sharedDelegate].sessionId emails:[contactInfo objectForKey:@"email"] successed:successed failure:failure];
                }
            }else{
                [[Communication sharedManager] RemoveContact:[AppDelegate sharedDelegate].sessionId contactIds:[contactInfo objectForKey:@"contact_id"] successed:successed failure:failure];
            }
            
        } else if (appDelegate.type == 2 || appDelegate.type == 8) { // Pending, so we revert back the old fields to selected state
            [self GetShareCells];
        }
    }
    else if ([alertView tag] == ALERT_CANCEL_REQUEST_BY_ID)
    {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
            void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
                [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
                if ([[_responseObject objectForKey:@"success"] boolValue])
                {
                    if (appDelegate.type == 5){
                        [self.navigationController popViewControllerAnimated:YES];
                    }else {
                        //Checkpoint for future
                        if (APPDELEGATE.isPreviewPhoneVerifyView) {
                            [self.navigationController popViewControllerAnimated:YES];
                        }else{
                            [self.navigationController popToRootViewControllerAnimated:YES];
                        }
                        [appDelegate GetContactList];
                            
                    }
                }
            };
            
            void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
                [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
                if (viewDelete.hidden) {
                    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"Oops!  Request failed.  Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alertView show];
                }else{
                    NSLog(@"");
                }
            } ;
            if (viewDelete.hidden) {
                NSString * contactId = [contactInfo objectForKey:@"contact_id"];
                if (isRequestForDirectoryUser) {
                    contactId = [contactInfo objectForKey:@"user_id"];
                }
                [[Communication sharedManager] RequestCancel:[AppDelegate sharedDelegate].sessionId contactIds:contactId successed:successed failure:failure];
            }else{
                [[Communication sharedManager] RemoveContact:[AppDelegate sharedDelegate].sessionId contactIds:[contactInfo objectForKey:@"contact_id"] successed:successed failure:failure];
            }
            
        } else if (appDelegate.type == 2) { // Pending, so we revert back the old fields to selected state
            [self GetShareCells];
        }
    }else if ([alertView tag] == 1009)
    {
        [self.navigationController popViewControllerAnimated:YES];
        if (buttonIndex != alertView.cancelButtonIndex) {
            LoginSettingViewController *viewController = [[LoginSettingViewController alloc] initWithNibName:@"LoginSettingViewController" bundle:nil];
            [self.navigationController pushViewController:viewController animated:YES];
        }else{
        
        }
    }
    if (buttonIndex == 1)
    {
        approveBut.hidden = YES;
//        [self GetShareCells];
    }
}

@end
