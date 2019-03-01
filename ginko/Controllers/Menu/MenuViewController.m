//
//  MenuViewController.m
//  GINKO
//
//  Created by Forever on 6/3/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import "MenuViewController.h"
#import "TabRequestController.h"
#import "SearchViewController.h"
#import "PasswordViewController.h"
#import "NotificationViewController.h"
#import "MenuSettingViewController.h"
#import "LoginSettingViewController.h"
#import "ScanMeViewController.h"
#import "CBMainViewController.h"
#import "GreyDetailController.h"
#import "TutorialViewController.h"

#import "CIHomeViewController.h"

//chatting class
#import "ChatViewController.h"

//ee class
#import "YYYCommunication.h"
#import "UIImageView+AFNetworking.h"
#import "GroupListViewController.h"
#import "TabBarController.h"
#import "UIImage+Tint.h"
#import "PreviewProfileViewController.h"

#import "CreateEntityViewController.h"
#import "PreviewEntityViewController.h"
#import "ManageEntityViewController.h"
#import "PreviewMainEntityViewController.h"

#import "CreateDirectoryViewController.h"
//directory
#import "Communication.h"
#import "ManageDirectoryViewController.h"
#import "PreDirectoryViewController.h"

#import "SelectUserForConferenceViewController.h"


#import "VideoVoiceConferenceViewController.h"
// --- Defines ---;
NSString * MenuCellIdentifier = @"MenuCell";
NSString * GroupName = @"GINKO";

@interface MenuViewController ()
{
    BOOL newLoadFlag;
    BOOL isConnectionStatus;
    int limits;
}
@end

@implementation MenuViewController
@synthesize lblChatBadge, viewChatBadge;

@synthesize appDelegate;

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
    
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [tblForMenu registerNib:[UINib nibWithNibName:MenuCellIdentifier bundle:nil] forCellReuseIdentifier:MenuCellIdentifier];

    arrSections = [NSArray arrayWithObjects:@"Function",@"Directory", @"Pages",@"Admin", nil];
    
    arrMenuCaptions = [[NSMutableArray alloc] init];
    arrMenuImages = [[NSMutableArray alloc] init];
    limits = 2;
//    NSArray *arrFunctionCaptions = [NSArray arrayWithObjects:@"Find Contacts", @"Import Contacts", @"Add Contact", @"Builder", @"Exchange", @"Groups", @"Sync to Device", nil];
    //NSArray *arrFunctionCaptions = [NSArray arrayWithObjects:@"Find Contacts", @"Groups", @"Builder", @"Import Contacts", @"Add Contact", @"Sync to Device", nil];
    NSArray *arrFunctionCaptions = [NSArray arrayWithObjects:@"Ginko Call", @"Backup Contacts", @"Find Contacts", @"Builder", @"Add Contact", @"Sync to Device", nil];
    NSArray *arrDirectoryCaptions = [NSArray arrayWithObjects:@"New", nil];
    NSArray *arrPagesCaptions = [NSArray arrayWithObjects:@"New", nil];
    NSArray *arrAdminCaptions = [NSArray arrayWithObjects:@"Settings", @"Login", @"Password", @"Notifications", @"Tutorial", @"Sign out", nil];
    
    [arrMenuCaptions addObject:arrFunctionCaptions];
    [arrMenuCaptions addObject:arrDirectoryCaptions];
    [arrMenuCaptions addObject:arrPagesCaptions];
    [arrMenuCaptions addObject:arrAdminCaptions];
    
    //NSArray *arrFunctionImgs = [NSArray arrayWithObjects:@"MenuFindContacts", @"MenuGroups", @"MenuBuilder", @"MenuImportContacts", @"MenuAddContact", @"MenuSync", nil];
    NSArray *arrFunctionImgs = [NSArray arrayWithObjects:@"MenuGinkoCall", @"MenuImportContacts", @"MenuFindContacts", @"MenuBuilder",  @"MenuAddContact", @"MenuSync", nil];
    NSArray *arrDirectorysImgs = [NSArray arrayWithObjects:@"BtnNew", @"BtnNew", nil];
    NSArray *arrPagesImgs = [NSArray arrayWithObjects:@"BtnNew", nil];
    NSArray *arrAdminImgs = [NSArray arrayWithObjects:@"BtnSetting", @"BtnLogin", @"BtnPassword", @"BtnNotification", @"Tutorial", @"BtnSignOut", nil];
    
    [arrMenuImages addObject:arrFunctionImgs];
    [arrMenuImages addObject:arrDirectorysImgs];
    [arrMenuImages addObject:arrPagesImgs];
    [arrMenuImages addObject:arrAdminImgs];
    
    totalList = [[NSMutableArray alloc] init];
    
    newLoadFlag = YES;
//    [self GetUserInformation];
    
    imgViewPhoto.layer.cornerRadius = imgViewPhoto.frame.size.height / 2.0f;
    imgViewPhoto.layer.masksToBounds = YES;
    imgViewPhoto.layer.borderColor = [UIColor colorWithRed:128.0/256.0 green:100.0/256.0 blue:162.0/256.0 alpha:1.0f].CGColor;
    imgViewPhoto.layer.borderWidth = 1.0f;
    
    arrEntities = [[NSMutableArray alloc] init]; //Sun class
    arrDirectories = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setHidden:NO];
    [self.navigationController.navigationBar addSubview:navView];
    // self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:230.0/256.0 green:1.0f blue:190.0/256.0 alpha:1.0f];
    [self.navigationItem setHidesBackButton:YES animated:NO];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    btnChat.enabled = YES;
    
    if (appDelegate.viewType == 0) // Tile View
    {
        [btnTile setImage:[UIImage imageNamed:@"TileSelect.png"] forState:UIControlStateNormal];
        [btnTile setImage:[UIImage imageNamed:@"TileSelect.png"] forState:UIControlStateHighlighted];
        [btnList setImage:[UIImage imageNamed:@"ListUnSelect"] forState:UIControlStateNormal];
        [btnList setImage:[UIImage imageNamed:@"ListUnSelect"] forState:UIControlStateHighlighted];
    }
    else // List View
    {
        [btnTile setImage:[UIImage imageNamed:@"TileUnSelect.png"] forState:UIControlStateNormal];
        [btnTile setImage:[UIImage imageNamed:@"TileUnSelect.png"] forState:UIControlStateHighlighted];
        [btnList setImage:[UIImage imageNamed:@"ListSelect"] forState:UIControlStateNormal];
        [btnList setImage:[UIImage imageNamed:@"ListSelect"] forState:UIControlStateHighlighted];
    }
    
//    if (!newLoadFlag) {
//        [self ListEntity];
//    }
    
    appDelegate.isEditEntity = NO;
    appDelegate.isProfileEdit = NO;
    
    //btnProfilePreView.enabled = NO;
    //isConnectionStatus = NO;
    
    [self GetUserInformation];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [navView removeFromSuperview];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [navView removeFromSuperview];
}

- (IBAction)onBack:(id)sender
{
    //[self.navigationController popViewControllerAnimated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//chatting class
- (IBAction)onChat:(id)sender
{
    //chatting class
    btnChat.enabled = NO;
    ChatViewController * controller = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
    controller.isWall = NO;
    [self.navigationController pushViewController:controller animated:YES];
}

//PE class
- (IBAction)onProfileEdit:(id)sender
{
    appDelegate.isProfileEdit = YES;
    
    PreviewProfileViewController *vc = [[PreviewProfileViewController alloc] initWithNibName:@"PreviewProfileViewController" bundle:nil];
    vc.userData = arrMyInfo;
    
    BOOL isWork;
    if ([arrMyInfo[@"work"][@"fields"] count] > 0) {
        isWork = YES;
    } else {    // really new and show profile selection screen
        isWork = NO;
    }
    vc.isWork = isWork;
    vc.isSetup = NO;
    
    [self.navigationController pushViewController:vc animated:YES];
}

//EE class
- (IBAction)onEditEntity:(id)sender
{
//    [self getEntityDetail];
}

//directory
- (void)getDerectoryDetail:(NSString *)directoryId{
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (![_responseObject objectForKey:@"data"]) {
            [self gotoInputScreenForDirectory:[_responseObject objectForKey:@"data"]];
        }
        else {
            [self makeDictionaryFordirectory:[_responseObject objectForKey:@"data"] ID:directoryId];
        }
    };
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Internet Connection Error!"];
    };
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[YYYCommunication sharedManager] GetDirectoryDetails:[AppDelegate sharedDelegate].sessionId directoryId:directoryId successed:successed failure:failure];
}
- (void)gotoInputScreenForDirectory:(NSDictionary *)dict
{
    ManageDirectoryViewController *vc = [[ManageDirectoryViewController alloc] initWithNibName:@"ManageDirectoryViewController" bundle:nil];
    vc.isCreate = NO;
    vc.directoryInfo = [dict mutableCopy];
    [self.navigationController pushViewController:vc animated:YES];
}

//Ee class
-(void)makeDictionaryFordirectory:(NSDictionary*)data ID:(NSString *)directoryId
{
    PreDirectoryViewController *vc = [[PreDirectoryViewController alloc] initWithNibName:@"PreDirectoryViewController" bundle:nil];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    vc.isCreate = NO;
    vc.directoryInfoForPreview = [data mutableCopy];
    [self presentViewController:nc animated:YES completion:nil];
}
//Ee class
-(void)getEntityDetail:(NSString *)entityID
{
	void ( ^successed )( id _responseObject ) = ^( id _responseObject )
	{
        //[MBProgressHUD hideHUDForView:self.view animated:YES];
        if (![[[_responseObject objectForKey:@"data"] objectForKey:@"infos"] count]) {
            [self gotoInputScreen:[_responseObject objectForKey:@"data"]];
        } else {
            [self makeDictionary:[_responseObject objectForKey:@"data"] ID:entityID];
        }
	};
	
	void ( ^failure )( NSError* _error ) = ^( NSError* _error )
	{
        //[MBProgressHUD hideHUDForView:self.view animated:YES];
		[CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Internet Connection Error!"];
	};
	
	//[MBProgressHUD showHUDAddedTo:self.view animated:YES];
	[[YYYCommunication sharedManager] GetEntityDetail:[AppDelegate sharedDelegate].sessionId
											 entityid:entityID
											successed:successed
											  failure:failure];
}

- (void)gotoInputScreen:(NSDictionary *)dict
{
    ManageEntityViewController *vc = [[ManageEntityViewController alloc] initWithNibName:@"ManageEntityViewController" bundle:nil];
    vc.isCreate = NO;
    vc.isSubEntity = NO;
    vc.entityData = [dict mutableCopy];;
    [self.navigationController pushViewController:vc animated:YES];
//    YYYEntityInfoInputViewController *viewcontroller = [[YYYEntityInfoInputViewController alloc] initWithNibName:@"YYYEntityInfoInputViewController" bundle:nil];
//    viewcontroller.dcEntity = [NSMutableDictionary dictionaryWithDictionary:dict];
//    viewcontroller.entityName = [dict objectForKey:@"name"];
//    viewcontroller.entityKeysearch = [dict objectForKey:@"search_words"];
//    
//    [self.navigationController pushViewController:viewcontroller animated:NO];
}

//Ee class
-(void)makeDictionary:(NSDictionary*)data ID:(NSString *)entityID
{
//	NSMutableDictionary *dictEntity = [[NSMutableDictionary alloc] init];
//	
//	[dictEntity setObject:[data objectForKey:@"name"] forKey:@"Name"];
//	[dictEntity setObject:[data objectForKey:@"search_words"] forKey:@"Keysearch"];
//	[dictEntity setObject:[NSString stringWithFormat:@"%@",[data objectForKey:@"privilege"]] forKey:@"Private"];
//	[dictEntity setObject:[data objectForKey:@"video_url"] forKey:@"Video"];
//    
//	NSMutableArray *lstInfo = [[NSMutableArray alloc] init];
//	NSMutableArray *lstRect = [[NSMutableArray alloc] init];
//	NSMutableArray *lstColor = [[NSMutableArray alloc] init];
//	NSMutableArray *lstInfoId = [[NSMutableArray alloc] init];
//	NSMutableArray *lstFont = [[NSMutableArray alloc] init];
//    NSMutableArray *lstLocInfo = [[NSMutableArray alloc] init];
//	
//	for (NSDictionary *_dictInfo in [data objectForKey:@"infos"])
//	{
//		NSMutableDictionary *dictRect = [[NSMutableDictionary alloc] init];
//		NSMutableDictionary *dictColor = [[NSMutableDictionary alloc] init];
//		NSMutableDictionary *dictFont = [[NSMutableDictionary alloc] init];
//		NSMutableDictionary *dictInfo = [[NSMutableDictionary alloc] init];
//        NSMutableDictionary *dictLocInfo = [[NSMutableDictionary alloc] init];
//        
//        if ([[_dictInfo objectForKey:@"address_confirmed"] boolValue]) {
//            [dictLocInfo setObject:@"true" forKey:@"address_confirmed"];
//        } else [dictLocInfo setObject:@"false" forKey:@"address_confirmed"];
//        if ([_dictInfo objectForKey:@"latitude"] == [NSNull null]) {
//            [dictLocInfo setObject:@"0" forKey:@"latitude"];
//        } else [dictLocInfo setObject:[_dictInfo objectForKey:@"latitude"] forKey:@"latitude"];
//        if ([_dictInfo objectForKey:@"longitude"] == [NSNull null]) {
//            [dictLocInfo setObject:@"0" forKey:@"longitude"];
//        } else [dictLocInfo setObject:[_dictInfo objectForKey:@"latitude"] forKey:@"longitude"];
//        
//		
//		[lstInfoId addObject:[NSString stringWithFormat:@"%@",[_dictInfo objectForKey:@"info_id"]]];
//		
//		[dictInfo setObject:[data objectForKey:@"search_words"]		forKey:@"Keysearch"];
//		
//		for (NSDictionary *_dictField in [_dictInfo objectForKey:@"fields"])
//		{
//			if ([[_dictField objectForKey:@"field_name"] isEqualToString:@"Keysearch"])
//			{
//				
//			}
//			else if ([[_dictField objectForKey:@"field_name"] isEqualToString:@"Video"])
//			{
//				
//			}
//			else if ([[_dictField objectForKey:@"field_name"] isEqualToString:@"Privilege"])
//			{
//				
//			}
//			else if ([[_dictField objectForKey:@"field_name"] isEqualToString:@"Abbr"])
//			{
//				[dictEntity setObject:[_dictField objectForKey:@"field_value"] forKey:@"Abbr"];
//			}
//			else
//			{
//				[dictInfo	setObject:[_dictField objectForKey:@"field_value"]		forKey:[_dictField objectForKey:@"field_name"]];
//				[dictRect	setObject:[NSValue valueWithCGRect:CGRectFromString([_dictField objectForKey:@"field_position"])]	forKey:[_dictField objectForKey:@"field_name"]];
//				[dictColor	setObject:[_dictField objectForKey:@"field_color"]		forKey:[_dictField objectForKey:@"field_name"]];
//				[dictFont	setObject:[_dictField objectForKey:@"field_font"]		forKey:[_dictField objectForKey:@"field_name"]];
//			}
//		}
//		
//		[lstInfo	addObject:dictInfo];
//		[lstRect	addObject:dictRect];
//		[lstColor	addObject:dictColor];
//		[lstFont	addObject:dictFont];
//        [lstLocInfo addObject:dictLocInfo];
//	}
//	
//	[dictEntity setObject:lstInfo forKey:@"Info"];
//	[dictEntity setObject:lstFont forKey:@"Font"];
//	[dictEntity setObject:lstRect forKey:@"Rect"];
//	[dictEntity setObject:lstColor forKey:@"Color"];
//	[dictEntity setObject:lstInfoId forKey:@"InfoID"];
//    [dictEntity setObject:lstLocInfo forKey:@"LocInfo"];
//    
//    NSMutableArray *dictImages = [data objectForKey:@"images"];
//    NSMutableDictionary *dictImage = [[NSMutableDictionary alloc] init];
//    
//    for (NSDictionary *dictII in dictImages) {
//        if ([[dictII objectForKey:@"z_index"] integerValue] == 0) {
//            [dictImage setObject:dictII forKey:@"Background"];
//        } else if ([[dictII objectForKey:@"z_index"] integerValue] == 1) {
//            [dictImage setObject:dictII forKey:@"Foreground"];
//        }
//    }
//    
//    [dictEntity setObject:dictImage forKey:@"images"];
	
    if ([data[@"infos"] count] >1) {
        PreviewMainEntityViewController *vc = [[PreviewMainEntityViewController alloc] initWithNibName:@"PreviewMainEntityViewController" bundle:nil];
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
        vc.isCreate = NO;
        vc.entityId = entityID;
        vc.isMultiLocation = YES;
        [self presentViewController:nc animated:YES completion:nil];
    }else{
        PreviewEntityViewController *vc = [[PreviewEntityViewController alloc] initWithNibName:@"PreviewEntityViewController" bundle:nil];
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
        vc.isCreate = NO;
        vc.entityId = entityID;
        vc.isMultiLocation = NO;
        [self presentViewController:nc animated:YES completion:nil];
    }
    
    
//	YYYEntityPreviewViewController_ *viewcontroller = [[YYYEntityPreviewViewController_ alloc] initWithNibName:@"YYYEntityPreviewViewController_" bundle:nil];
//	viewcontroller.dictEntity = dictEntity;
//	viewcontroller.entityID = entityID;
//    _globalData.strEntityPhoto = [data objectForKey:@"profile_image"];
//    
//    appDelegate.isEditEntity = YES;
//    
//	[self.navigationController pushViewController:viewcontroller animated:YES];
}

- (IBAction)onBtnViewType:(id)sender
{
    if ([sender tag] == 101) // Tile View
    {
        appDelegate.viewType = 0;
        
        [btnTile setImage:[UIImage imageNamed:@"TileSelect.png"] forState:UIControlStateNormal];
        [btnTile setImage:[UIImage imageNamed:@"TileSelect.png"] forState:UIControlStateHighlighted];
        [btnList setImage:[UIImage imageNamed:@"ListUnSelect"] forState:UIControlStateNormal];
        [btnList setImage:[UIImage imageNamed:@"ListUnSelect"] forState:UIControlStateHighlighted];
    }
    else // List View
    {
        appDelegate.viewType = 1;
        
        [btnTile setImage:[UIImage imageNamed:@"TileUnSelect.png"] forState:UIControlStateNormal];
        [btnTile setImage:[UIImage imageNamed:@"TileUnSelect.png"] forState:UIControlStateHighlighted];
        [btnList setImage:[UIImage imageNamed:@"ListSelect"] forState:UIControlStateNormal];
        [btnList setImage:[UIImage imageNamed:@"ListSelect"] forState:UIControlStateHighlighted];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [arrSections count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    UILabel *lblCaption = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, 320, 20)];

    [lblCaption setBackgroundColor:[UIColor clearColor]];
    [lblCaption setTextColor:[UIColor colorWithRed:130.0f/255.0f green:87.0f/255.0f blue:131.0f/255.0f alpha:1.0f]];
    [lblCaption setFont:[UIFont boldSystemFontOfSize:14.0f]];
    lblCaption.text = [arrSections objectAtIndex:section];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Seperator"]];
    [imgView setFrame:CGRectMake(75, 10, 210, 1)];
    
    [view addSubview:lblCaption];
    [view addSubview:imgView];
    
    [view setBackgroundColor:[UIColor clearColor]];
    
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // sun interrupt
    if (section == 1) {
        return [[arrMenuCaptions objectAtIndex:section] count] + [arrDirectories count];
    }
    if (section == 2) {
        return [[arrMenuCaptions objectAtIndex:section] count] + [arrEntities count];
    }
    
    return [[arrMenuCaptions objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 61.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MenuCell *cell = [tblForMenu dequeueReusableCellWithIdentifier:MenuCellIdentifier forIndexPath:indexPath];
    
    if (cell == nil)
    {
        cell = [[MenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MenuCellIdentifier];
    }
    
    if (indexPath.section == 3 && indexPath.row == 5) {
        cell.arrowImage.hidden = YES;
    } else {
        cell.arrowImage.hidden = NO;
    }
    if (indexPath.section == 1 && indexPath.row > 0) {
        [cell.imgViewIcon setImage:nil];
        NSDictionary *dict = [arrDirectories objectAtIndex:indexPath.row - 1];
        //        [cell.lblCaption setText:[NSString stringWithFormat:@"Entity %d", indexPath.row]];
        [cell.lblCaption setText:[dict objectForKey:@"name"]];
        return cell;
    }
    if (indexPath.section == 2 && indexPath.row > 0) {
        [cell.imgViewIcon setImage:nil];
        NSDictionary *dict = [arrEntities objectAtIndex:indexPath.row - 1];
//        [cell.lblCaption setText:[NSString stringWithFormat:@"Entity %d", indexPath.row]];
        [cell.lblCaption setText:[dict objectForKey:@"name"]];
        return cell;
    }
    
    [cell.lblCaption setText:[[arrMenuCaptions objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    [cell.imgViewIcon setImage:[UIImage imageNamed:[[arrMenuImages objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]]];
    
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0: // Function
            if (indexPath.row == 0) // Ginko Call
            {
                SelectUserForConferenceViewController *viewcontroller = [[SelectUserForConferenceViewController alloc] initWithNibName:@"SelectUserForConferenceViewController" bundle:nil];
                viewcontroller.viewcontroller = self;
                viewcontroller.isReturnFromMenu = YES;
                UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:viewcontroller];
                [self presentViewController:nc animated:YES completion:nil];
                
                
//                if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
//                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            if (!granted) {
//                                [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your Camera or Microphone is disabled.\nPlease go to settings and grant access to it."];
//                            }
//                            else {
//                                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
//                                    if (!granted) {
//                                        [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your Camera or Microphone is disabled.\nPlease go to settings and grant access to it."];
//                                    }
//                                    else {
//                                        VideoVoiceConferenceViewController *viewcontroller = [[VideoVoiceConferenceViewController alloc] initWithNibName:@"VideoVoiceConferenceViewController" bundle:nil];
//                                        APPDELEGATE.isOwnerForConference = YES;
//                                        APPDELEGATE.isJoinedOnConference = YES;
//                                        viewcontroller.conferenceType = 1;
//                                        viewcontroller.conferenceName =@"Conference";
//                                        [self.navigationController pushViewController:viewcontroller animated:YES];
//                                    }
//                                }];
//                            }
//                        });
//                    }];
//                }
            }else if (indexPath.row == 1) // Backup Contacts
            {
                //                _globalData.isFromMenu = YES;
                CIHomeViewController *vc = [[CIHomeViewController alloc] initWithNibName:@"CIHomeViewController" bundle:nil];
                [self.navigationController pushViewController:vc animated:YES];
            }
            /*else if (indexPath.row == 1) // Groups
            {
                GroupListViewController *vc = [[GroupListViewController alloc] initWithNibName:@"GroupListViewController" bundle:nil];
                [self.navigationController pushViewController:vc animated:YES];
            }*/
//            else if (indexPath.row == 2) // Scan me
//            {
//                ScanMeViewController *vc = [[ScanMeViewController alloc] initWithNibName:@"ScanMeViewController" bundle:nil];
//                [self.navigationController pushViewController:vc animated:YES];
//            }
//            else if (indexPath.row == 3) // Sprout
//            {
//                [appDelegate GetContactList];
//                self.navigationItem.title = @"";
//                TabBarController *tabBarController = [TabBarController sharedController];
//                tabBarController.selectedIndex = 1;
//                // Push;
//                [self.navigationController pushViewController:tabBarController animated:YES];
//            }
            else if (indexPath.row == 2) // Find Contacts
            {
                SearchViewController *viewController = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
                viewController.isMenu = YES;
                [self.navigationController pushViewController:viewController animated:YES];
            }
//            else if (indexPath.row == 5) // Exchange
//            {
//                TabRequestController *tabRequestController = [TabRequestController sharedController];
//                tabRequestController.selectedIndex = 2;
//                // Push;
//                [self.navigationController pushViewController:tabRequestController animated:YES];
//            }
            else if (indexPath.row == 3) // Contact Builder
            {
                _globalData.cbIsFromMenu = YES;
                CBMainViewController *vc = [[CBMainViewController alloc] initWithNibName:@"CBMainViewController" bundle:nil];
                [self.navigationController pushViewController:vc animated:YES];
            }
            else if (indexPath.row == 4) // Add Contacts
            {
                GreyDetailController *vc = [[GreyDetailController alloc] initWithNibName:@"GreyDetailController" bundle:nil];
                vc.isEditing = YES;
                [self.navigationController pushViewController:vc animated:YES];
            }
            else if (indexPath.row == 5) // Sync to Device
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Do you want sync your Ginko Address Book to your phone?" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
                alert.tag = 100;
                [alert show];
                //[self GetContacts:nil search:nil category:nil contactType:nil];
            }
            break;
        case 1: // Directory
            //ae class
            if (indexPath.row == 0) { //Add Directory
                CreateDirectoryViewController *vc = [[CreateDirectoryViewController alloc] initWithNibName:@"CreateDirectoryViewController" bundle:nil];
                UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
                nc.navigationBar.translucent = NO;
                [self presentViewController:nc animated:YES completion:nil];
            } else {
                [self getDerectoryDetail:[[arrDirectories objectAtIndex:indexPath.row - 1] objectForKey:@"id"]];
            }
            break;
        case 2: // Pages
            //ae class
            if (indexPath.row == 0) {  //Add Entity
                CreateEntityViewController *vc = [[CreateEntityViewController alloc] initWithNibName:@"CreateEntityViewController" bundle:nil];
                UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
                nc.navigationBar.translucent = NO;
                [self presentViewController:nc animated:YES completion:nil];
            } else { //sun interrupt Edit Entity
                [self getEntityDetail:[[arrEntities objectAtIndex:indexPath.row - 1] objectForKey:@"entity_id"]];
                
                //if (![[[arrEntities objectAtIndex:indexPath.row - 1] objectForKey:@"infos"] count]) {
                //    [self gotoInputScreen:[arrEntities objectAtIndex:indexPath.row - 1]];
               // } else {
                    //[self makeDictionary:[arrEntities objectAtIndex:indexPath.row - 1] ID:[[arrEntities objectAtIndex:indexPath.row - 1] objectForKey:@"entity_id"]];
                //}
            }
            break;
        case 3: // Admin
            if (indexPath.row == 0) // Settings
            {
                MenuSettingViewController *viewController = [[MenuSettingViewController alloc] initWithNibName:@"MenuSettingViewController" bundle:nil];
                [self.navigationController pushViewController:viewController animated:YES];
            }
            else if (indexPath.row == 1)    // login
            {
                LoginSettingViewController *viewController = [[LoginSettingViewController alloc] initWithNibName:@"LoginSettingViewController" bundle:nil];
                [self.navigationController pushViewController:viewController animated:YES];
            }
            else if (indexPath.row == 2)    // Password
            {
                PasswordViewController *viewController = [[PasswordViewController alloc] initWithNibName:@"PasswordViewController" bundle:nil];
                [self.navigationController pushViewController:viewController animated:YES];
            }
            else if (indexPath.row == 3)    // Notifications
            {
                NotificationViewController *viewController = [[NotificationViewController alloc] initWithNibName:@"NotificationViewController" bundle:nil];
                [self.navigationController pushViewController:viewController animated:YES];
            }
            else if (indexPath.row == 4)    // Tutorial
            {
                TutorialViewController *viewController = [[TutorialViewController alloc] initWithNibName:@"TutorialViewController" bundle:nil];
                [self presentViewController:viewController animated:YES completion:nil];
            }
            else if (indexPath.row == 5)    // SignOut
            {
                [self LogOut];
            }
            
            break;
        default:
            break;
    }
}
- (void)startVideoCallingWithSelectedContact:(NSString *)conferecenBoardId type:(NSInteger)_type{
    VideoVoiceConferenceViewController *vc = [[VideoVoiceConferenceViewController alloc] initWithNibName:@"VideoVoiceConferenceViewController" bundle:nil];
    vc.boardId = conferecenBoardId;
    vc.conferenceType = _type;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)removeGINKOFromAddressBook
{
    CFErrorRef error;
    ABAddressBookRef ab = ABAddressBookCreateWithOptions(NULL, &error);
//weird, addgrey
    NSArray *groups = (__bridge NSArray *) ABAddressBookCopyArrayOfAllGroups(ab);
    int indexGroup = -1;
    
    for (id _group in groups)
    {
        indexGroup++;
        
        NSString *currentGroupName = [[NSString alloc] init];
        currentGroupName = (__bridge NSString*) ABRecordCopyValue((__bridge ABRecordRef)(_group), kABGroupNameProperty);
        
        if ([GroupName isEqualToString:currentGroupName])
        {
            ABRecordRef groupRef = (__bridge ABRecordRef)([groups objectAtIndex:indexGroup]);
            
            CFArrayRef members = ABGroupCopyArrayOfAllMembers(groupRef);
            
            if(members) {
                NSUInteger count = CFArrayGetCount(members);
                for(NSUInteger idx=0; idx<count; ++idx) {
                    ABRecordRef person = CFArrayGetValueAtIndex(members, idx);
                    
                    ABAddressBookRemoveRecord (ab,person,NULL);
                    // your code
                }
                
                CFRelease(members);
            }
            
            ABAddressBookRemoveRecord(ab, (__bridge ABRecordRef)(_group), &error);
            ABAddressBookSave(ab, nil);
        }
    }
}

- (void)exportContactsToAddressBook
{
    // Request to authorise the app to use addressbook
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(nil, nil);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                // If the app is authorized to access the first time then add the contact
                [self addContact];
            } else {
                // Show an alert here if user denies access telling that the contact cannot be added because you didn't allow it to access the contacts
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Attention" message:@"Oops!  You did not permit the GINKO to access your contacts. Please give GINKO access from your phone settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:@"Settings",nil];
                [alertView show];
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // If the user user has earlier provided the access, then add the contact
        [self addContact];
    }
    else {
        // If the user user ha/-s NOT earlier provided the access, create an alert to tell the user to go to Settings app and allow access
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Attention" message:@"Oops!  You did not permit the GINKO to access your contacts. Please give GINKO access from your phone settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        if (alertView.tag == 100) {
            [self GetContacts:nil search:nil category:nil contactType:nil];
        }else if (alertView.tag == 109){
            [self GetUserInformation];
        }else if (alertView.tag == 108){
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            groupId = -100;
            [self addContact];
        }
    }
}

- (void)addContact
{
    if (groupId != -100) {
        [self createNewGroup:GroupName];
        if (!groupId) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"This device can't create group on addressbook. Do you want to continue sync contacts without group name? " delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
            [alert show];
            return;
        }
    }
    
    CFErrorRef error;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    ABRecordRef group = ABAddressBookGetGroupWithRecordID(addressBook, groupId);
    
    for (int i = 0; i < [totalList count]; i++)
    {
        // Make Person Info
        ABRecordRef person = ABPersonCreate(); // create a person
        
        NSDictionary *dict = [totalList objectAtIndex:i];
        
        if (![dict objectForKey:@"entity_id"]) {
            ABRecordSetValue(person, kABPersonFirstNameProperty, (__bridge CFTypeRef)([NSString stringWithFormat:@"%@ %@", [dict objectForKey:@"first_name"], [dict objectForKey:@"middle_name"]]) , nil); // first name of the new person
            ABRecordSetValue(person, kABPersonLastNameProperty, (__bridge CFTypeRef)([dict objectForKey:@"last_name"]), nil); // his last name
        } else {
            ABRecordSetValue(person, kABPersonFirstNameProperty, (__bridge CFTypeRef)([dict objectForKey:@"name"]) , nil);
        }
        
        if ([dict objectForKey:@"entity_id"]) {
            ABMutableMultiValueRef phoneNumberMultiValue = ABMultiValueCreateMutable(kABPersonPhoneProperty);
            //Email is a list of emails, so create a multivalue
            ABMutableMultiValueRef emailMultiValue = ABMultiValueCreateMutable(kABPersonEmailProperty);
            //Social is a list of emails, so create a multivalue
            ABMutableMultiValueRef socialMultiValue = ABMultiValueCreateMutable(kABPersonSocialProfileProperty);
            //Website is a list of emails, so create a multivalue
            ABMutableMultiValueRef urlMultiValue = ABMultiValueCreateMutable(kABPersonURLProperty);
            ABMutableMultiValueRef addressMultiValue = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
            
            for (NSDictionary *_dictInfo in [dict objectForKey:@"infos"])
            {
                NSArray *arrFields = [_dictInfo objectForKey:@"fields"];
                
                for (int i = 0; i < [arrFields count]; i++)
                {
                    NSDictionary * tempDict = [arrFields objectAtIndex:i];
                    if ([[tempDict objectForKey:@"field_type"] isEqualToString:@"phone"] || [[tempDict objectForKey:@"field_name"] isEqualToString:@"Mobile"] || [[tempDict objectForKey:@"field_name"] isEqualToString:@"Mobile#2"] || [[tempDict objectForKey:@"field_name"] isEqualToString:@"Phone#2"] || [[tempDict objectForKey:@"field_name"] isEqualToString:@"Phone#3"])
                        ABMultiValueAddValueAndLabel(phoneNumberMultiValue ,(__bridge CFTypeRef)([tempDict objectForKey:@"field_value"]),kABPersonPhoneMobileLabel, NULL);
                    else if ([[tempDict objectForKey:@"field_name"] isEqualToString:@"Email"] || [[tempDict objectForKey:@"field_name"] isEqualToString:@"Email#2"])
                        ABMultiValueAddValueAndLabel(emailMultiValue ,(__bridge CFTypeRef)([tempDict objectForKey:@"field_value"]), kABHomeLabel, NULL);
                    else if ([[tempDict objectForKey:@"field_name"] isEqualToString:@"Fax"])
                        ABMultiValueAddValueAndLabel(phoneNumberMultiValue ,(__bridge CFTypeRef)([tempDict objectForKey:@"field_value"]),kABPersonPhoneHomeFAXLabel, NULL);
                    else if ([[tempDict objectForKey:@"field_name"] isEqualToString:@"Facebook"])
                        ABMultiValueAddValueAndLabel(socialMultiValue ,(__bridge CFTypeRef)([tempDict objectForKey:@"field_value"]),kABPersonSocialProfileServiceFacebook, NULL);
                    else if ([[tempDict objectForKey:@"field_name"] isEqualToString:@"Twitter"])
                        ABMultiValueAddValueAndLabel(socialMultiValue ,(__bridge CFTypeRef)([tempDict objectForKey:@"field_value"]),kABPersonSocialProfileServiceTwitter, NULL);
                    else if ([[tempDict objectForKey:@"field_name"] isEqualToString:@"Website"])
                        ABMultiValueAddValueAndLabel(urlMultiValue ,(__bridge CFTypeRef)([tempDict objectForKey:@"field_value"]),kABPersonHomePageLabel, NULL);
                    else if ([[tempDict objectForKey:@"field_name"] isEqualToString:@"Birthday"])
                    {
                        NSDate *date = [CommonMethods str2date:[tempDict objectForKey:@"field_value"] withFormat:@"YYYY-MM-dd"];
                        
                        ABRecordSetValue(person, kABPersonBirthdayProperty,(__bridge CFDateRef)date, &error);
                    }
                    else if ([[tempDict objectForKey:@"field_name"] isEqualToString:@"Address"] || [[tempDict objectForKey:@"field_name"] isEqualToString:@"Address#2"])
                    {
                        NSString *strAddress = [tempDict objectForKey:@"field_value"];
                        // first divide into array separated with new line character
                        NSArray *lines = [strAddress componentsSeparatedByString:@"\n"];
                        NSMutableDictionary *values = [NSMutableDictionary new];
                        if (lines.count > 0) { // first line is Street
                            values[(NSString *)kABPersonAddressStreetKey] = [lines[0] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ,"]];
                        }
                        if (lines.count > 1) { // second line is "City, State ZIP"
                            // let's find comma
                            NSArray *components = [lines[1] componentsSeparatedByString:@","];
                            if (components.count > 0) {
                                values[(NSString *)kABPersonAddressCityKey] = [[components[0] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ,"]] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ,"]];
                            }
                            if (components.count > 1) {
                                NSString *stateAndZip = [[[[components subarrayWithRange:NSMakeRange(1, components.count - 1)] componentsJoinedByString:@" "] stringByReplacingOccurrencesOfString:@"," withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ,"]]; // in case state and zip is separated by comma
                                
                                // find last space location
                                NSRange range = [stateAndZip rangeOfString:@" " options:NSBackwardsSearch];
                                if (range.location != NSNotFound) {
                                    // now separate into 2 strings, first is City, second is Zip
                                    values[(NSString *)kABPersonAddressStateKey] = [[stateAndZip substringWithRange:NSMakeRange(0, range.location)] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ,"]];
                                    values[(NSString *)kABPersonAddressZIPKey] = [[stateAndZip substringWithRange:NSMakeRange(range.location, stateAndZip.length - range.location)] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ,"]];
                                } else { // there is no space, so set whole as state?
                                    values[(NSString *)kABPersonAddressStateKey] = stateAndZip;
                                }
                            }
                        }
                        if (lines.count > 2) { // rare case, let's set this as country
                            values[(NSString *)kABPersonAddressCountryKey] = [lines[2] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ,"]];
                        } else {
                            values[(NSString *)kABPersonAddressCountryKey] = @"United States";
                        }
                        values[(NSString *)kABPersonAddressCountryCodeKey] = [[NSLocale localeWithLocaleIdentifier:@"en_US"] objectForKey:NSLocaleCountryCode];
                        
                        ABMultiValueAddValueAndLabel(addressMultiValue, (__bridge CFDictionaryRef)values, kABHomeLabel, NULL);
                    }
                }
            }
            ABRecordSetValue(person, kABPersonPhoneProperty, phoneNumberMultiValue, &error); // set the phone number property
            ABRecordSetValue(person, kABPersonEmailProperty, emailMultiValue, &error); // set the email property
            ABRecordSetValue(person, kABPersonSocialProfileProperty, socialMultiValue, &error); // set the social property
            ABRecordSetValue(person, kABPersonURLProperty, urlMultiValue, &error); // set the url property
            ABRecordSetValue(person, kABPersonAddressProperty, addressMultiValue, &error);
        }
        else if ([[dict objectForKey:@"contact_type"] intValue] == 1)    // purple contact
        {
            NSArray * homeArray = [[dict objectForKey:@"home"] objectForKey:@"fields"];
            NSArray * workArray = [[dict objectForKey:@"work"] objectForKey:@"fields"];
            //            NSArray * profileArray = [[dict objectForKey:@"profile"] objectForKey:@"fields"];
            
            //Phone number is a list of phone number, so create a multivalue
            ABMutableMultiValueRef phoneNumberMultiValue = ABMultiValueCreateMutable(kABPersonPhoneProperty);
            //Email is a list of emails, so create a multivalue
            ABMutableMultiValueRef emailMultiValue = ABMultiValueCreateMutable(kABPersonEmailProperty);
            //Social is a list of emails, so create a multivalue
            ABMutableMultiValueRef socialMultiValue = ABMultiValueCreateMutable(kABPersonSocialProfileProperty);
            //Website is a list of emails, so create a multivalue
            ABMutableMultiValueRef urlMultiValue = ABMultiValueCreateMutable(kABPersonURLProperty);
            ABMutableMultiValueRef addressMultiValue = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
            /*@"Name",@"Mobile",@"Mobile#2",@"Phone",@"Phone#2",@"Phone#3",@"Fax",@"Email",@"Email#2",@"Address",@"Address#2",@"Birthday",@"Facebook",@"Twitter",@"Website",@"Custom",@"Custom#2",@"Custom#3"*/
            // home phone and email
            for (int i = 0; i < [homeArray count]; i++)
            {
                NSDictionary * tempDict = [homeArray objectAtIndex:i];
                if ([[tempDict objectForKey:@"field_type"] isEqualToString:@"phone"] || [[tempDict objectForKey:@"field_name"] isEqualToString:@"Mobile"] || [[tempDict objectForKey:@"field_name"] isEqualToString:@"Mobile#2"] || [[tempDict objectForKey:@"field_name"] isEqualToString:@"Phone#2"] || [[tempDict objectForKey:@"field_name"] isEqualToString:@"Phone#3"])
                    ABMultiValueAddValueAndLabel(phoneNumberMultiValue ,(__bridge CFTypeRef)([tempDict objectForKey:@"field_value"]),kABPersonPhoneMobileLabel, NULL);
                else if ([[tempDict objectForKey:@"field_name"] isEqualToString:@"Email"] || [[tempDict objectForKey:@"field_name"] isEqualToString:@"Email#2"])
                    ABMultiValueAddValueAndLabel(emailMultiValue ,(__bridge CFTypeRef)([tempDict objectForKey:@"field_value"]), kABHomeLabel, NULL);
                else if ([[tempDict objectForKey:@"field_name"] isEqualToString:@"Fax"])
                    ABMultiValueAddValueAndLabel(phoneNumberMultiValue ,(__bridge CFTypeRef)([tempDict objectForKey:@"field_value"]),kABPersonPhoneHomeFAXLabel, NULL);
                else if ([[tempDict objectForKey:@"field_name"] isEqualToString:@"Facebook"])
                    ABMultiValueAddValueAndLabel(socialMultiValue ,(__bridge CFTypeRef)([NSDictionary dictionaryWithObjectsAndKeys:
                                                                                         (NSString *)kABPersonSocialProfileServiceFacebook, kABPersonSocialProfileServiceKey,
                                                                                         [tempDict objectForKey:@"field_value"], kABPersonSocialProfileUsernameKey,
                                                                                         nil]),kABPersonSocialProfileServiceFacebook, NULL);
                else if ([[tempDict objectForKey:@"field_name"] isEqualToString:@"Twitter"])
                    ABMultiValueAddValueAndLabel(socialMultiValue ,(__bridge CFTypeRef)([NSDictionary dictionaryWithObjectsAndKeys:
                                                                                         (NSString *)kABPersonSocialProfileServiceTwitter, kABPersonSocialProfileServiceKey,
                                                                                         [tempDict objectForKey:@"field_value"], kABPersonSocialProfileUsernameKey,
                                                                                         nil]),kABPersonSocialProfileServiceTwitter, NULL);
                else if ([[tempDict objectForKey:@"field_name"] isEqualToString:@"Website"])
                    ABMultiValueAddValueAndLabel(urlMultiValue ,(__bridge CFTypeRef)([tempDict objectForKey:@"field_value"]),kABPersonHomePageLabel, NULL);
                else if ([[tempDict objectForKey:@"field_name"] isEqualToString:@"Birthday"])
                {
                    NSDate *date = [CommonMethods str2date:[tempDict objectForKey:@"field_value"] withFormat:@"YYYY-MM-dd"];
                    
                    ABRecordSetValue(person, kABPersonBirthdayProperty,(__bridge CFDateRef)date, &error);
                }
                else if ([[tempDict objectForKey:@"field_name"] isEqualToString:@"Address"] || [[tempDict objectForKey:@"field_name"] isEqualToString:@"Address#2"])
                {
                    NSString *strAddress = [tempDict objectForKey:@"field_value"];
                    // first divide into array separated with new line character
                    NSArray *lines = [strAddress componentsSeparatedByString:@"\n"];
                    NSMutableDictionary *values = [NSMutableDictionary new];
                    if (lines.count > 0) { // first line is Street
                        values[(NSString *)kABPersonAddressStreetKey] = [lines[0] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ,"]];
                    }
                    if (lines.count > 1) { // second line is "City, State ZIP"
                        // let's find comma
                        NSArray *components = [lines[1] componentsSeparatedByString:@","];
                        if (components.count > 0) {
                            values[(NSString *)kABPersonAddressCityKey] = [[components[0] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ,"]] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ,"]];
                        }
                        if (components.count > 1) {
                            NSString *stateAndZip = [[[[components subarrayWithRange:NSMakeRange(1, components.count - 1)] componentsJoinedByString:@" "] stringByReplacingOccurrencesOfString:@"," withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ,"]]; // in case state and zip is separated by comma
                            
                            // find last space location
                            NSRange range = [stateAndZip rangeOfString:@" " options:NSBackwardsSearch];
                            if (range.location != NSNotFound) {
                                // now separate into 2 strings, first is City, second is Zip
                                values[(NSString *)kABPersonAddressStateKey] = [[stateAndZip substringWithRange:NSMakeRange(0, range.location)] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ,"]];
                                values[(NSString *)kABPersonAddressZIPKey] = [[stateAndZip substringWithRange:NSMakeRange(range.location, stateAndZip.length - range.location)] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ,"]];
                            } else { // there is no space, so set whole as state?
                                values[(NSString *)kABPersonAddressStateKey] = stateAndZip;
                            }
                        }
                    }
                    if (lines.count > 2) { // rare case, let's set this as country
                        values[(NSString *)kABPersonAddressCountryKey] = [lines[2] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ,"]];
                    } else {
                        values[(NSString *)kABPersonAddressCountryKey] = @"United States";
                    }
                    values[(NSString *)kABPersonAddressCountryCodeKey] = [[NSLocale localeWithLocaleIdentifier:@"en_US"] objectForKey:NSLocaleCountryCode];
                    
                    ABMultiValueAddValueAndLabel(addressMultiValue, (__bridge CFDictionaryRef)values, kABHomeLabel, NULL);
                }
            }
            
            // work phone and email
            for (int i = 0; i < [workArray count]; i++)
            {
                NSDictionary * tempDict = [workArray objectAtIndex:i];
                if ([[tempDict objectForKey:@"field_type"] isEqualToString:@"phone"] || [[tempDict objectForKey:@"field_name"] isEqualToString:@"Mobile"] || [[tempDict objectForKey:@"field_name"] isEqualToString:@"Mobile#2"] || [[tempDict objectForKey:@"field_name"] isEqualToString:@"Phone#2"] || [[tempDict objectForKey:@"field_name"] isEqualToString:@"Phone#3"])
                    ABMultiValueAddValueAndLabel(phoneNumberMultiValue ,(__bridge CFTypeRef)([tempDict objectForKey:@"field_value"]),kABWorkLabel, NULL);
                else if ([[tempDict objectForKey:@"field_name"] isEqualToString:@"Email"] || [[tempDict objectForKey:@"field_name"] isEqualToString:@"Email#2"])
                    ABMultiValueAddValueAndLabel(emailMultiValue ,(__bridge CFTypeRef)([tempDict objectForKey:@"field_value"]), kABWorkLabel, NULL);
                else if ([[tempDict objectForKey:@"field_name"] isEqualToString:@"Fax"])
                    ABMultiValueAddValueAndLabel(phoneNumberMultiValue ,(__bridge CFTypeRef)([tempDict objectForKey:@"field_value"]),kABPersonPhoneWorkFAXLabel, NULL);
                else if ([[tempDict objectForKey:@"field_name"] isEqualToString:@"Facebook"])
                    ABMultiValueAddValueAndLabel(socialMultiValue ,(__bridge CFTypeRef)([NSDictionary dictionaryWithObjectsAndKeys:
                                                                                         (NSString *)kABPersonSocialProfileServiceFacebook, kABPersonSocialProfileServiceKey,
                                                                                         [tempDict objectForKey:@"field_value"], kABPersonSocialProfileUsernameKey,
                                                                                         nil]),kABPersonSocialProfileServiceFacebook, NULL);
                else if ([[tempDict objectForKey:@"field_name"] isEqualToString:@"Twitter"])
                    ABMultiValueAddValueAndLabel(socialMultiValue ,(__bridge CFTypeRef)([NSDictionary dictionaryWithObjectsAndKeys:
                                                                                         (NSString *)kABPersonSocialProfileServiceTwitter, kABPersonSocialProfileServiceKey,
                                                                                         [tempDict objectForKey:@"field_value"], kABPersonSocialProfileUsernameKey,
                                                                                         nil]),kABPersonSocialProfileServiceTwitter, NULL);
                else if ([[tempDict objectForKey:@"field_name"] isEqualToString:@"Website"])
                    ABMultiValueAddValueAndLabel(urlMultiValue ,(__bridge CFTypeRef)([tempDict objectForKey:@"field_value"]),kABPersonHomePageLabel, NULL);
                else if ([[tempDict objectForKey:@"field_name"] isEqualToString:@"Birthday"])
                {
                    NSDate *date = [CommonMethods str2date:[tempDict objectForKey:@"field_value"] withFormat:@"YYYY-MM-dd"];
                    
                    ABRecordSetValue(person, kABPersonBirthdayProperty,(__bridge CFDateRef)date, &error);
                }
                else if ([[tempDict objectForKey:@"field_name"] isEqualToString:@"Address"] || [[tempDict objectForKey:@"field_name"] isEqualToString:@"Address#2"])
                {
                    NSString *strAddress = [tempDict objectForKey:@"field_value"];
                    // first divide into array separated with new line character
                    NSArray *lines = [strAddress componentsSeparatedByString:@"\n"];
                    NSMutableDictionary *values = [NSMutableDictionary new];
                    if (lines.count > 0) { // first line is Street
                        values[(NSString *)kABPersonAddressStreetKey] = [lines[0] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ,"]];
                    }
                    if (lines.count > 1) { // second line is "City, State ZIP"
                        // let's find comma
                        NSArray *components = [lines[1] componentsSeparatedByString:@","];
                        if (components.count > 0) {
                            values[(NSString *)kABPersonAddressCityKey] = [[components[0] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ,"]] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ,"]];
                        }
                        if (components.count > 1) {
                            NSString *stateAndZip = [[[[components subarrayWithRange:NSMakeRange(1, components.count - 1)] componentsJoinedByString:@" "] stringByReplacingOccurrencesOfString:@"," withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ,"]]; // in case state and zip is separated by comma
                            
                            // find last space location
                            NSRange range = [stateAndZip rangeOfString:@" " options:NSBackwardsSearch];
                            if (range.location != NSNotFound) {
                                // now separate into 2 strings, first is City, second is Zip
                                values[(NSString *)kABPersonAddressStateKey] = [[stateAndZip substringWithRange:NSMakeRange(0, range.location)] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ,"]];
                                values[(NSString *)kABPersonAddressZIPKey] = [[stateAndZip substringWithRange:NSMakeRange(range.location, stateAndZip.length - range.location)] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ,"]];
                            } else { // there is no space, so set whole as state?
                                values[(NSString *)kABPersonAddressStateKey] = stateAndZip;
                            }
                        }
                    }
                    if (lines.count > 2) { // rare case, let's set this as country
                        values[(NSString *)kABPersonAddressCountryKey] = [lines[2] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ,"]];
                    } else {
                        values[(NSString *)kABPersonAddressCountryKey] = @"United States";
                    }
                    values[(NSString *)kABPersonAddressCountryCodeKey] = [[NSLocale localeWithLocaleIdentifier:@"en_US"] objectForKey:NSLocaleCountryCode];
                    
                    ABMultiValueAddValueAndLabel(addressMultiValue, (__bridge CFDictionaryRef)values, kABWorkLabel, NULL);
                }
            }
            
            // profile
            //            for (int i = 0; i < [profileArray count]; i++)
            //            {
            //                NSDictionary * tempDict = [profileArray objectAtIndex:i];
            //
            //                if ([[tempDict objectForKey:@"field_type"] isEqualToString:@"date"])
            //                {
            //                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            //                    [dateFormatter setDateFormat:@"MM"];
            //                    NSDate *date = [dateFormatter dateFromString:@"2013-02-01T06:25:47Z"];
            //
            //                    ABRecordSetValue(person, kABPersonBirthdayProperty, [tempDict objectForKey:@"field_value"], &error);
            //                }
            //            }
            
            ABRecordSetValue(person, kABPersonPhoneProperty, phoneNumberMultiValue, &error); // set the phone number property
            ABRecordSetValue(person, kABPersonEmailProperty, emailMultiValue, &error); // set the email property
            ABRecordSetValue(person, kABPersonSocialProfileProperty, socialMultiValue, &error); // set the social property
            ABRecordSetValue(person, kABPersonURLProperty, urlMultiValue, &error); // set the url property
            ABRecordSetValue(person, kABPersonAddressProperty, addressMultiValue, &error);
        }
        else  if ([[dict objectForKey:@"contact_type"] intValue] == 2)   // grey contact
        {
            NSArray * dataArray = [dict objectForKey:@"fields"];
            
            //Phone number is a list of phone number, so create a multivalue
            ABMutableMultiValueRef phoneNumberMultiValue = ABMultiValueCreateMutable(kABPersonPhoneProperty);
            //Email is a list of emails, so create a multivalue
            ABMutableMultiValueRef emailMultiValue = ABMultiValueCreateMutable(kABPersonEmailProperty);
            //Social is a list of emails, so create a multivalue
            ABMutableMultiValueRef socialMultiValue = ABMultiValueCreateMutable(kABPersonSocialProfileProperty);
            //Website is a list of emails, so create a multivalue
            ABMutableMultiValueRef urlMultiValue = ABMultiValueCreateMutable(kABPersonURLProperty);
            ABMutableMultiValueRef addressMultiValue = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
            
            // home phone and email
            
            for (int i = 0; i < [dataArray count]; i++)
            {
                NSDictionary * tempDict = [dataArray objectAtIndex:i];
                if ([[tempDict objectForKey:@"field_type"] isEqualToString:@"phone"])
                    ABMultiValueAddValueAndLabel(phoneNumberMultiValue ,(__bridge CFTypeRef)([tempDict objectForKey:@"field_value"]),kABPersonPhoneMobileLabel, NULL);
                else if ([[tempDict objectForKey:@"field_type"] isEqualToString:@"email"])
                    ABMultiValueAddValueAndLabel(emailMultiValue ,(__bridge CFTypeRef)([tempDict objectForKey:@"field_value"]), kABHomeLabel, NULL);
                else if ([[tempDict objectForKey:@"field_type"] isEqualToString:@"fax"])
                    ABMultiValueAddValueAndLabel(phoneNumberMultiValue ,(__bridge CFTypeRef)([tempDict objectForKey:@"field_value"]),kABPersonPhoneHomeFAXLabel, NULL);
                else if ([[tempDict objectForKey:@"field_name"] isEqualToString:@"Birthday"])
                {
                    NSDate *date = [CommonMethods str2date:[tempDict objectForKey:@"field_value"] withFormat:@"YYYY-MM-dd"];
                    
                    ABRecordSetValue(person, kABPersonBirthdayProperty,(__bridge CFDateRef)date, &error);
                }
                else if ([[tempDict objectForKey:@"field_type"] isEqualToString:@"address"])
                {
                    NSString *strAddress = [tempDict objectForKey:@"field_value"];
                    NSArray *arrSplitAddress = [strAddress componentsSeparatedByString:@" "];
                    NSDictionary *values = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [arrSplitAddress count] ? [arrSplitAddress objectAtIndex:0] : @"", (NSString *)kABPersonAddressStreetKey,
                                            [arrSplitAddress count] > 1 ? [arrSplitAddress objectAtIndex:1] : @"", (NSString *)kABPersonAddressCityKey,[arrSplitAddress count] > 2 ? [arrSplitAddress objectAtIndex:2] : @"", (NSString *)kABPersonAddressStateKey,[arrSplitAddress count] > 3 ? [arrSplitAddress objectAtIndex:3] : @"", (NSString *)kABPersonAddressCountryKey,[arrSplitAddress count] > 4 ? [arrSplitAddress objectAtIndex:4] : @"", (NSString *)kABPersonAddressZIPKey,
                                            nil];
                    
                    ABMultiValueAddValueAndLabel(addressMultiValue, (__bridge CFDictionaryRef)values, kABHomeLabel, NULL);
                }
                else if ([[tempDict objectForKey:@"field_type"] isEqualToString:@"facebook"])
                    ABMultiValueAddValueAndLabel(socialMultiValue ,(__bridge CFTypeRef)([NSDictionary dictionaryWithObjectsAndKeys:
                                                                                         (NSString *)kABPersonSocialProfileServiceFacebook, kABPersonSocialProfileServiceKey,
                                                                                         [tempDict objectForKey:@"field_value"], kABPersonSocialProfileUsernameKey,
                                                                                         nil]),kABPersonSocialProfileServiceFacebook, NULL);
                else if ([[tempDict objectForKey:@"field_type"] isEqualToString:@"twitter"])
                    ABMultiValueAddValueAndLabel(socialMultiValue ,(__bridge CFTypeRef)([NSDictionary dictionaryWithObjectsAndKeys:
                                                                                         (NSString *)kABPersonSocialProfileServiceTwitter, kABPersonSocialProfileServiceKey,
                                                                                         [tempDict objectForKey:@"field_value"], kABPersonSocialProfileUsernameKey,
                                                                                         nil]),kABPersonSocialProfileServiceTwitter, NULL);
                else if ([[tempDict objectForKey:@"field_type"] isEqualToString:@"website"])
                    ABMultiValueAddValueAndLabel(urlMultiValue ,(__bridge CFTypeRef)([tempDict objectForKey:@"field_value"]),kABPersonHomePageLabel, NULL);
            }
            
            ABRecordSetValue(person, kABPersonPhoneProperty, phoneNumberMultiValue, &error); // set the phone number property
            ABRecordSetValue(person, kABPersonEmailProperty, emailMultiValue, &error); // set the email property
            ABRecordSetValue(person, kABPersonSocialProfileProperty, socialMultiValue, &error); // set the social property
            ABRecordSetValue(person, kABPersonURLProperty, urlMultiValue, &error); // set the url property
            
            ABRecordSetValue(person, kABPersonAddressProperty, addressMultiValue, &error);//for address
        }
        
        ABAddressBookAddRecord(addressBook, person, nil); //add the new person to the record
        
        ABGroupAddMember(group, person, &error); // add the person to the group
        
        ABAddressBookSave(addressBook, nil); //save the record
        
        CFRelease(person); // relase the ABRecordRef  variable
    }
}

-(void) createNewGroup:(NSString*)groupName {
    
    CFErrorRef error;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    ABRecordRef newGroup = ABGroupCreate();
    ABRecordSetValue(newGroup, kABGroupNameProperty,(__bridge CFTypeRef)(groupName), nil);
    ABAddressBookAddRecord(addressBook, newGroup, nil);
    ABAddressBookSave(addressBook, nil);
    CFRelease(addressBook);
    
    //!!! important - save groupID for later use
    groupId = ABRecordGetRecordID(newGroup);
    CFRelease(newGroup);
}

- (void)GetContacts : (NSString *)_sortby
              search: (NSString *)_search
            category: (NSString *)_category
         contactType: (NSString *)_contactType
{
    NSLog(@"GetContacts For Sync");
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
		if ([[_responseObject objectForKey:@"success"] boolValue])
		{
            totalList = [_responseObject objectForKey:@"data"];
            
            [self removeGINKOFromAddressBook];
            [self exportContactsToAddressBook];
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        NSLog(@"Connection failed - %@", _error);
    } ;
    
    [[Communication sharedManager] GetContactsSync:[AppDelegate sharedDelegate].sessionId sortby:_sortby search:_search category:_category contactType:_contactType successed:successed failure:failure];
}

- (void)GetUserInformation
{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    
	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        

        
		if ([[_responseObject objectForKey:@"success"] boolValue])
		{
            arrMyInfo = [_responseObject objectForKey:@"data"];
            btnProfilePreView.enabled = YES;
            isConnectionStatus = YES;
            if ([[[arrMyInfo objectForKey:@"home"] objectForKey:@"fields"] count]!=0) {
                [lblFirstName setText:[NSString stringWithFormat:@"%@ %@",[arrMyInfo objectForKey:@"fname"], [arrMyInfo objectForKey:@"mname"]]];
                [lblLastName setText:[arrMyInfo objectForKey:@"lname"]];
                
                NSString *strImage = [[arrMyInfo objectForKey:@"home"] objectForKey:@"profile_image"];
                
                [imgViewPhoto setImageWithURL:[NSURL URLWithString:strImage]];
            }else{
                NSDictionary *arrMyInfoWork;
                arrMyInfoWork = [arrMyInfo objectForKey:@"work"];
                NSArray * fieldArray = arrMyInfoWork[@"fields"];
                for (NSDictionary * arrFieldsOfWork in fieldArray){
                    if ([arrFieldsOfWork[@"field_type"]  isEqual: @"name"]) {
                        [lblFirstName setText:arrFieldsOfWork[@"field_value"]];
                    }
                }
                [lblLastName setText:@""];
                NSString *strImage = [arrMyInfoWork objectForKey:@"profile_image"];
                
                [imgViewPhoto setImageWithURL:[NSURL URLWithString:strImage]];
            }
            
            
            [self ListEntity];
            
//            [self GetMyPhoto];
            
		}
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        NSLog(@"Connection failed - %@", [[_error userInfo] objectForKey:@"NSLocalizedDescription"]);
//        [CommonMethods showAlertUsingTitle:@"Error" andMessage:[[_error userInfo] objectForKey:@"NSLocalizedDescription"]];
        if (limits > 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry, No connection" delegate:self cancelButtonTitle:@"Try again" otherButtonTitles:nil, nil];
            alert.tag = 109;
            [alert show];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Try again after checking your connection!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alert.tag = 108;
            [alert show];
        }
        limits--;
    } ;
    
    [[Communication sharedManager] GetMyInfo:[AppDelegate sharedDelegate].sessionId contact_uid:nil successed:successed failure:failure];
}

- (void)getNewChatNum
{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        appDelegate.newChatNum = [[[_responseObject objectForKey:@"data"] objectForKey:@"new_chat_msg_num"] intValue];
        [self showChatNum];
        
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        NSLog(@"Connection failed - %@", _error);
    } ;
    
    [[Communication sharedManager] GetCBEmailValid:[AppDelegate sharedDelegate].sessionId successed:successed failure:failure];
}

- (void)showChatNum
{
    lblChatBadge.text = [NSString stringWithFormat:@"%d", appDelegate.newChatNum];

    if (appDelegate.newChatNum > 0) {
        viewChatBadge.hidden = NO;
    } else viewChatBadge.hidden = YES;
}
//directory
- (void)ListDirectory
{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            [arrDirectories removeAllObjects];
            for (NSDictionary *dict in [_responseObject objectForKey:@"data"]) {
                [arrDirectories addObject:dict];
            }
            newLoadFlag = NO;
            [tblForMenu reloadData];
            
            [self getNewChatNum];
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        NSLog(@"Connection failed - %@", _error);
    } ;
    
    [[YYYCommunication sharedManager] GetDirectoryList:[AppDelegate sharedDelegate].sessionId
                                       successed:successed
                                         failure:failure];
}
//sun class
- (void)ListEntity
{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    
	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        
		if ([[_responseObject objectForKey:@"success"] boolValue])
		{
            [arrEntities removeAllObjects];
            for (NSDictionary *dict in [_responseObject objectForKey:@"data"]) {
                [arrEntities addObject:dict];
            }
            [self ListDirectory];
		}
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        NSLog(@"Connection failed - %@", _error);
    } ;
    
    [[YYYCommunication sharedManager] ListEntity:[AppDelegate sharedDelegate].sessionId
											successed:successed
											  failure:failure];
}

- (void)GetMyPhoto
{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    
	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
		if ([[_responseObject objectForKey:@"success"] boolValue])
		{
            NSDictionary *dict = [_responseObject objectForKey:@"data"];
            
            NSURL * imageURL = [NSURL URLWithString:[dict objectForKey:@"photo_url"]];
            [imgViewPhoto setImageWithURL:imageURL];
            
            [self ListEntity];
		}
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        NSLog(@"Connection failed - %@", _error);
    } ;
    
    [[Communication sharedManager] GetMyPhoto:[AppDelegate sharedDelegate].sessionId successed:successed failure:failure];
}

- (void)LogOut
{
    
    NSLog(@"logou with gps turn off");
    [[AppDelegate sharedDelegate] turnOffGPS];
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    
	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
		if ([[_responseObject objectForKey:@"success"] boolValue])
		{
            [navView removeFromSuperview];
            appDelegate.isCalledContactsReload = YES;
            [[AppDelegate sharedDelegate] deleteLoginData];
            [AppDelegate sharedDelegate].sessionId = nil;
            appDelegate.notExchangeNum = 0;
            appDelegate.newChatNum = 0;
            appDelegate.xchageReqNum = 0;
//            [self.navigationController popToRootViewControllerAnimated:YES];
            [[AppDelegate sharedDelegate] goToSplash];
		}
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        NSLog(@"Connection failed - %@", _error);
    } ;
    
    [[Communication sharedManager] Logout:[AppDelegate sharedDelegate].sessionId deviceUID:nil successed:successed failure:failure];
}
- (void)OffGPS
{
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        NSLog(@"%@",[_responseObject objectForKey:@"data"]);
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            NSLog(@"logou with gps turn off");
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        NSLog(@"Change GPS Status failed");
    } ;
    
    [[Communication sharedManager] ChangeGPSStatus:[AppDelegate sharedDelegate].sessionId trun_on:@"false" successed:successed failure:failure];
}
@end
