//
//  SearchViewController.m
//  GINKO
//
//  Created by Zhun L. on 6/2/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import "SearchViewController.h"
#import "ProfileRequestController.h"
#import "GreyDetailController.h"
#import "PreviewProfileViewController.h"
#import "YYYCommunication.h" //chatting class
#import "YYYChatViewController.h" //chatting class

#import "EntityViewController.h"
#import "MainEntityViewController.h"

#import "ProfileViewController.h"
// --- Defines ---;
@interface SearchViewController ()<UIGestureRecognizerDelegate> {
    BOOL searchAllLoaded;
    BOOL doingLocalSearch;
    
    int currentSearchPage;
    int numbersPerPage;
}
@end

@implementation SearchViewController

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
    
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    totalList = [[NSMutableArray alloc] init];
//    totalList = [NSMutableArray arrayWithArray:appDelegate.totalList];
//    [tblForContact reloadData];
    
    orgTotalList = [[NSMutableArray alloc] init];
    
    NSString * SearchCellIdentifier = @"SearchCell";
    [tblForContact registerNib:[UINib nibWithNibName:SearchCellIdentifier bundle:nil] forCellReuseIdentifier:SearchCellIdentifier];
    
    searchBarForList.text = @"";
//    [self getSearchContacts:@" "];
//    [totalList removeAllObjects];
    
    // back button will not have title
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    searchAllLoaded = NO;
    currentSearchPage = 1;
    numbersPerPage = 20;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    // tapGestureRecognizer.cancelsTouchesInView = NO;
    tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
  
    if (searchBarForList.text && ![searchBarForList.text  isEqual: @""] && ![searchBarForList.text  isEqual: @" "]) {
        //[self searchBar:searchBarForList textDidChange:searchBarForList.text];
        [self searchBarSearchButtonClicked:searchBarForList];
    }
    
    [self.navigationController.navigationBar addSubview:navView];
    //self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:230.0/256.0 green:1.0f blue:190.0/256.0 alpha:1.0f];
    [self.navigationController.navigationItem setHidesBackButton:YES animated:NO];
    
//    if (![searchBarForList.text isEqualToString:@""]) {
//        [self getSearchContacts:searchBarForList.text];
//    }
}

//sun interrupt
- (void)viewWillDisappear:(BOOL)animated
{
    [navView removeFromSuperview];
    [super viewWillDisappear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onCloseBtn:(id)sender
{
    if (_isMenu) {
        [self.navigationController popViewControllerAnimated:YES];
    }else
        [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [searchBarForList resignFirstResponder];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [totalList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 82.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //emclass
    NSDictionary *dict = [totalList objectAtIndex:indexPath.row];
    
    if ([dict objectForKey:@"entity_id"]) {
        EntityCell *cell = [tblForContact dequeueReusableCellWithIdentifier:@"EntityCell"];
        
        if(cell == nil)
        {
            cell = [EntityCell sharedCell];
        }
        
        [cell setDelegate:self] ;
        
        cell.curDict = dict;
        
        if ([[dict objectForKey:@"invite_status"] intValue]) {
            cell.isFollowing = YES;
        } else {
            cell.isFollowing = NO;
        }
        
        return cell;
    } else { //em class end
    
        NSString * SearchCellIdentifier = @"SearchCell";
        SearchCell *cell = [tblForContact dequeueReusableCellWithIdentifier:SearchCellIdentifier forIndexPath:indexPath];
        
        if (cell == nil)
        {
            cell = [[SearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SearchCellIdentifier];
        }
        
        NSString * firstName = @"";
        NSString * middleName = @"";
        NSString * lastName = @"";
        
        dict = [totalList objectAtIndex:indexPath.row];
        firstName = [dict objectForKey:@"first_name"];
        middleName = [dict objectForKey:@"middle_name"];
        lastName = [dict objectForKey:@"last_name"];

        if ([[dict objectForKey:@"contact_type"] intValue] == 1) {
            [cell setPhoto:[dict objectForKey:@"profile_image"]];
        } else if ([[dict objectForKey:@"contact_type"] intValue] == 2) {
            [cell setPhoto:[dict objectForKey:@"photo_url"]];
        }
        cell.firstName.text = [NSString stringWithFormat:@"%@ %@",firstName, middleName];
        cell.lastName.text = lastName;

        CGPoint pt = cell.actionBtn.center;
        CGPoint phonePt = cell.phoneBtn.center;
        CGPoint chatormailPt = cell.chatOrEmailBtn.center;
        if (![dict objectForKey:@"sharing_status"])
        {
            if ([[dict objectForKey:@"contact_type"] integerValue] == 1) {
                if ([dict objectForKey:@"share"]) {
                    [cell.actionBtn setImage:[UIImage imageNamed:@"Pending.png"] forState:UIControlStateNormal];
                    [cell.actionBtn setFrame:CGRectMake(0, 0, 20, 21)];
                    [cell.actionBtn setCenter:pt];
                    [cell.actionBtn setHidden:NO];
                    [cell.phoneBtn setHidden:YES];
                    [cell.chatOrEmailBtn setHidden:YES];
                    [cell.lblCaption setHidden:YES];
                
                }else{
                    [cell.actionBtn setImage:[UIImage imageNamed:@"Exchanged.png"] forState:UIControlStateNormal];
                    [cell.actionBtn setFrame:CGRectMake(0, 0, 20, 21)];
                    [cell.actionBtn setCenter:pt];
                    [cell.actionBtn setHidden:NO];
                    [cell.phoneBtn setHidden:YES];
                    [cell.chatOrEmailBtn setHidden:YES];
                    [cell.lblCaption setHidden:YES];
                }
            }else if ([[dict objectForKey:@"contact_type"] integerValue] == 2){
                [cell.phoneBtn setImage:[UIImage imageNamed:@"BtnPhoneGrey.png"] forState:UIControlStateNormal];
                [cell.chatOrEmailBtn setImage:[UIImage imageNamed:@"BtnMailGrey.png"] forState:UIControlStateNormal];
                [cell.phoneBtn setHidden:NO];
                [cell.chatOrEmailBtn setFrame:CGRectMake(0, 0, 20, 15)];
                [cell.chatOrEmailBtn setCenter:chatormailPt];
                [cell.chatOrEmailBtn setHidden:NO];
                [cell.actionBtn setHidden:YES];
                [cell.lblCaption setHidden:YES];
            }
            
        }else{
            if ([[dict objectForKey:@"sharing_status"] integerValue] != 4)
            {
//                [cell.actionBtn setImage:[UIImage imageNamed:@"Pending.png"] forState:UIControlStateNormal];
//                [cell.actionBtn setFrame:CGRectMake(0, 0, 20, 21)];
//                [cell.actionBtn setCenter:pt];
                [cell.phoneBtn setImage:[UIImage imageNamed:@"BtnPhone.png"] forState:UIControlStateNormal];
                [cell.chatOrEmailBtn setImage:[UIImage imageNamed:@"BtnChat.png"] forState:UIControlStateNormal];
                [cell.chatOrEmailBtn setFrame:CGRectMake(0, 0, 20, 20)];
                [cell.chatOrEmailBtn setCenter:chatormailPt];
                [cell.phoneBtn setHidden:NO];
                [cell.chatOrEmailBtn setHidden:NO];
                [cell.actionBtn setHidden:YES];
                [cell.lblCaption setHidden:YES];
            }
            else
            {
                [cell.phoneBtn setImage:[UIImage imageNamed:@"EditContact.png"] forState:UIControlStateNormal];
                [cell.chatOrEmailBtn setImage:[UIImage imageNamed:@"BtnChat.png"] forState:UIControlStateNormal];
                [cell.chatOrEmailBtn setFrame:CGRectMake(0, 0, 20, 20)];
                [cell.chatOrEmailBtn setCenter:chatormailPt];
                [cell.phoneBtn setHidden:YES];
                [cell.chatOrEmailBtn setHidden:NO];
                [cell.actionBtn setHidden:YES];
                [cell.lblCaption setHidden:YES];
            }
        }
        
        cell.delegate = self;
        cell.sessionId = @"";
        cell.contactId = @"";
        
        return cell;
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
            [dictTemp setObject:[contactInfo objectForKey:@"photo_url"] forKey:@"photo_url"];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view findAndResignFirstResponder];
    
    NSDictionary * dict = [totalList objectAtIndex:indexPath.row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([dict objectForKey:@"entity_id"]) {
        BOOL isFollowing = [[dict objectForKey:@"invite_status"] intValue];
        [self getEntityFollowerView:[dict objectForKey:@"entity_id"] following:isFollowing notes:[dict objectForKey:@"notes"]];
    } else {
        
        dict = [totalList objectAtIndex:indexPath.row];
        
        if ([[dict objectForKey:@"contact_type"] integerValue] == 1)
        {
            if ([dict objectForKey:@"sharing_status"] == nil) { // this is non-contact
                [AppDelegate sharedDelegate].type = 5;
                if ([dict objectForKey:@"share"]) {
                    NSMutableDictionary *pendingDict = [NSMutableDictionary new];
                    [pendingDict setObject:dict[@"contact_id"] forKey:@"contact_id"];
                    [pendingDict setObject:dict[@"first_name"] forKey:@"first_name"];
                    [pendingDict setObject:dict[@"last_name"] forKey:@"last_name"];
                    [pendingDict setObject:dict[@"profile_image"] forKey:@"photo_url"];
                    [pendingDict setObject:dict[@"share"][@"share_limit"] forKey:@"share_limit"];
                    [pendingDict setObject:dict[@"share"][@"shared_home_fids"] forKey:@"shared_home_fids"];
                    [pendingDict setObject:dict[@"share"][@"shared_work_fids"] forKey:@"shared_work_fids"];
                    [pendingDict setObject:dict[@"share"][@"sharing_status"] forKey:@"sharing_status"];
                    ProfileRequestController * controller = [[ProfileRequestController alloc] initWithNibName:@"ProfileRequestController" bundle:nil];
                    controller.contactInfo = pendingDict;
                    [self.navigationController pushViewController:controller animated:YES];
                    
                    
                }else{
                    if ([dict objectForKey:@"detected_location"] && ![[dict objectForKey:@"detected_location"] isEqualToString:@""])
                    {
                        ProfileViewController * controller = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
                        controller.contactInfo = dict;
                        [self.navigationController pushViewController:controller animated:YES];
                    }else{
                        ProfileRequestController * controller = [[ProfileRequestController alloc] initWithNibName:@"ProfileRequestController" bundle:nil];
                        controller.contactInfo = dict;
                        [self.navigationController pushViewController:controller animated:YES];
                    }
                }
                
            } else if ([[dict objectForKey:@"sharing_status"] integerValue] == 4)
            {
                // Here is for Chat
                [self CreateMessageBoard:[dict objectForKey:@"contact_id"] dict:dict];
            }
            else
            {
                if (!doingLocalSearch) {
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
                } else {
                    [self getContactDetail:dict :[[dict objectForKey:@"contact_type"] intValue]];
                }
            }
        }
        else
        {
            if (!doingLocalSearch) {
                GreyDetailController *vc = [[GreyDetailController alloc] initWithNibName:@"GreyDetailController" bundle:nil];
                vc.curContactDict = dict;
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                [self getContactDetail:dict :[[dict objectForKey:@"contact_type"] intValue]];
            }
        }
    }
}

-(void)getContactDetail:(NSDictionary *)contactInfo :(int)type
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        NSDictionary *result = _responseObject;
        if ([[result objectForKey:@"success"] boolValue]) {
            NSDictionary *dict = [_responseObject objectForKey:@"data"];
            if (type == 0) {  //did edit
                if ([dict objectForKey:@"detected_location"] && ![[dict objectForKey:@"detected_location"] isEqualToString:@""])
                {
                    ProfileViewController * controller = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
                    controller.contactInfo = dict;
                    [self.navigationController pushViewController:controller animated:YES];
                }else{
                    ProfileRequestController * controller = [[ProfileRequestController alloc] initWithNibName:@"ProfileRequestController" bundle:nil];
                    controller.contactInfo = dict;
                    [self.navigationController pushViewController:controller animated:YES];
                }
            } else if (type == 1) { //purple detail
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
                
                //                PurpleDetailViewController * viewController = [[PurpleDetailViewController alloc] initWithNibName:@"PurpleDetailViewController" bundle:nil];
                //                viewController.contactInfo = dict;
                //                [self.navigationController pushViewController:viewController animated:YES];
            } else if (type == 2) { //grey detail
                GreyDetailController *vc = [[GreyDetailController alloc] initWithNibName:@"GreyDetailController" bundle:nil];
                vc.curContactDict = dict;
                [self.navigationController pushViewController:vc animated:YES];
            }
        } else {
            NSDictionary *dictError = [result objectForKey:@"err"];
            if (dictError) {
                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:[dictError objectForKey:@"errMsg"]];
                if ([[NSString stringWithFormat:@"%@",[dictError objectForKey:@"errCode"]] isEqualToString:@"350"]) {
                    [[AppDelegate sharedDelegate] GetContactList];
                }
            } else {
                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Failed to connect to server!"];
            }
        }
        
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Failed to connect to server!"];
    } ;
    
    [[Communication sharedManager] getContactDetail:[AppDelegate sharedDelegate].sessionId contactId:[contactInfo objectForKey:@"contact_id"] contactType:[contactInfo objectForKey:@"contact_type"] successed:successed failure:failure];
}

//em classes
-(void)getEntityFollowerView:(NSString *)entityID following:(BOOL)isFollowing notes:(NSString *)notes
{
	void ( ^successed )( id _responseObject ) = ^( id _responseObject )
	{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary *result = _responseObject;
        if ([[result objectForKey:@"success"] boolValue]) {
            NSLog(@"reponse---%@",_responseObject);
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

-(void)getSearchContacts:(NSString *)seachKey
{
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //NSString *searchStr = [seachKey stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        
		[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
		
		if ([[_responseObject objectForKey:@"success"] boolValue])
		{
            doingLocalSearch = NO;
            [totalList removeAllObjects];
            for (NSDictionary *dict in [_responseObject objectForKey:@"data"]) {
                [totalList addObject:dict];
            }
            NSArray *listArray =[totalList copy];
            listArray = [listArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSString *name1, *name2;
                name1 = [NSString stringWithFormat:@"%@%@%@", obj1[@"first_name"], obj1[@"middle_name"], obj1[@"last_name"]];
                name2 = [NSString stringWithFormat:@"%@%@%@", obj2[@"first_name"], obj2[@"middle_name"], obj2[@"last_name"]];
                return [name1 compare:name2 options:NSNumericSearch];
            }];
            totalList = [listArray mutableCopy];
            [tblForContact reloadData];
            
		}else{
            [CommonMethods showAlertUsingTitle:@"Error!" andMessage:[[_responseObject objectForKey:@"err"] objectForKey:@"errMsg"]];
		}
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
		
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Internet Connection Error!"];
		
    } ;
    
    [[YYYCommunication sharedManager] listSearchContacts:[AppDelegate sharedDelegate].sessionId searchKey:seachKey successed:successed failure:failure];
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
    [tblForContact reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *rawString = searchBar.text;
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
    if ([rawString length] == 0 || [trimmed isEqualToString:@""]) {
        [CommonMethods showAlertUsingTitle:@"Error!" andMessage:@"Please enter a valid searchkey!"];
        searchBar.text = @"";
    }else{
         [searchBarForList resignFirstResponder];
        [self getSearchContacts:searchBar.text];
    }
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length != 0) {
        doingLocalSearch = YES;
        totalList = [NSMutableArray new];
        for (NSDictionary *contactDic in appDelegate.totalList) {
            NSString *name = @"";
            
            if ([contactDic[@"contact_type"] intValue] == 3) {
                if (contactDic[@"name"])
                    name = contactDic[@"name"];
            } else {
                if (contactDic[@"first_name"] && ![contactDic[@"first_name"] isEqualToString:@""]) {
                    name = contactDic[@"first_name"];
                }
                if (contactDic[@"middle_name"] && ![contactDic[@"middle_name"] isEqualToString:@""]) {
                    if (![name isEqualToString:@""])
                        name = [name stringByAppendingString:@" "];
                    name = [name stringByAppendingString:contactDic[@"middle_name"]];
                }
                if (contactDic[@"last_name"] && ![contactDic[@"last_name"] isEqualToString:@""]) {
                    if (![name isEqualToString:@""])
                        name = [name stringByAppendingString:@" "];
                    name = [name stringByAppendingString:contactDic[@"last_name"]];
                }
            }
            if ([[name lowercaseString] rangeOfString:searchText.lowercaseString].location != NSNotFound) {
                [totalList addObject:contactDic];
            }
        }
    } else {
        [totalList removeAllObjects];
    }
    
    [tblForContact reloadData];
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isKindOfClass:[UIScrollView class]]) {
        return YES;
    }
    if ([totalList count] > 0) {
        return NO;
    }
    return YES;
}
- (void) hideKeyboard{
    [searchBarForList resignFirstResponder];
}
@end
