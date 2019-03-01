//
//  ContactViewController.m
//  Ginko
//
//  Created by Qi Song on 29/3/14.
//  Copyright (c) 2014 Qi Song. All rights reserved.
//
// --- Headers ---;

#import "ContactViewController.h"
#import "TabBarController.h"
#import "TabRequestController.h"
#import "ChatViewController.h"
#import "SettingViewController.h"
#import "SearchViewController.h"
#import "MenuViewController.h"
#import "CBMainViewController.h"
#import "GreyDetailController.h"
#import "CIHomeViewController.h"
#import "GreyClient.h"
#import "ProfileRequestController.h"
#import "TutorialViewController.h"

#import "YYYCommunication.h" //chatting class
#import "YYYChatViewController.h" //chatting class

#import "EntityChatWallViewController.h"
#import "SproutProgressViewController.h"

#import "ScanMeViewController.h"
#import "PreviewProfileViewController.h"
#import "GinkoConnectViewController.h"
#import "InvitationQueryViewController.h"

#import "EntityViewController.h"
#import "GroupListViewController.h"
#import "MainEntityViewController.h"

#import "GroupsViewController.h"
#import "FavoritesViewController.h"

#import "ProfileViewController.h"

//testing
#import "VideoVoiceConferenceViewController.h"

// --- Defines ---;
NSString * ContactCellIdentifier = @"ContactCell";
int rowHeight;

// ContactViewController Class;
@interface ContactViewController ()<UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching>
{
    UIRefreshControl *refreshControl;
    SproutProgressViewController *progressVC;
    int favoriteCount;
}
@end

@implementation ContactViewController

@synthesize appDelegate;
@synthesize viewChatBadge, viewSproutBadge, viewExchangeBadge, lblChatBadge, lblExchangeBadge, lblSproutBadge;

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
    if ([AppDelegate sharedDelegate].isShowTutorial) {
        [AppDelegate sharedDelegate].isShowTutorial = NO;
        TutorialViewController *viewController = [[TutorialViewController alloc] initWithNibName:@"TutorialViewController" bundle:nil];
        [self presentViewController:viewController animated:YES completion:nil];
    }
    
    contactList = [NSMutableDictionary new];
    //totalList = [[NSMutableArray alloc] init];
    keyList = [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
    
    callFuncForUpdatingUserlocation = YES;
    //Timer for thumbprint
    _gpsCallTimerForThumbPrint = [[NSTimer alloc] init];
    
    _locationManagerForThumbPrint = [[CLLocationManager alloc] init];
    _locationManagerForThumbPrint.delegate = self;
    _locationManagerForThumbPrint.distanceFilter = kCLDistanceFilterNone;
    _locationManagerForThumbPrint.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([_locationManagerForThumbPrint respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_locationManagerForThumbPrint requestWhenInUseAuthorization];
    }
    
    favoriteCount = 0;
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    viewType = appDelegate.viewType;
    gpsBut.selected = appDelegate.locationFlag;
    [gpsBut setImage:[gpsBut imageForState:UIControlStateNormal] forState:UIControlStateHighlighted];
    [gpsBut setImage:[gpsBut imageForState:UIControlStateSelected] forState:UIControlStateHighlighted | UIControlStateSelected];
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    pushFlag = YES;
    
    [tblForContact registerNib:[UINib nibWithNibName:@"TileViewCell" bundle:nil] forCellReuseIdentifier:@"TileViewCell"];
    [tblForContact registerNib:[UINib nibWithNibName:@"ContactCell" bundle:nil] forCellReuseIdentifier:@"ContactCell"];
    [tblForContact registerNib:[UINib nibWithNibName:@"TitleEntityCell" bundle:nil] forCellReuseIdentifier:@"TitleEntityCell"];
    [tblForContact registerNib:[UINib nibWithNibName:@"ListEntityCellCell" bundle:nil] forCellReuseIdentifier:@"ListEntityCellCell"];
    
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [tblForContact addSubview:refreshControl];
    
    [self.view addSubview:blankView];
    [blankView setHidden:YES];
    
    //    [backgroundImgView setHidden:YES];
    [tblForContact setHidden:YES];
    [tblForContact setSectionIndexColor:[UIColor lightGrayColor]];
    
    filterType = 3;
    btnAll.selected = YES;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *userId = appDelegate.userId;
    NSNumber *oldUserId = [userDefaults objectForKey:@"userId"];
    if (!userId) {
        [appDelegate deleteLoginData];
        [appDelegate goToSplash];
    }
    if (oldUserId && userId && ![oldUserId isEqualToNumber:userId]) { // first login
        // reset timestamp
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:@"sync_timestamp"];
        [userDefaults synchronize];
        
        NSManagedObjectContext *context = [AppDelegate sharedDelegate].managedObjectContext;
        NSFetchRequest *allContacts = [[NSFetchRequest alloc] init];
        [allContacts setEntity:[NSEntityDescription entityForName:@"Contact" inManagedObjectContext:context]];
        [allContacts setIncludesPropertyValues:NO]; //only fetch the managedObjectID
        
        NSError *error = nil;
        NSArray *contacts = [context executeFetchRequest:allContacts error:&error];
        
        //error handling goes here
        for (Contact *contact in contacts) {
            [context deleteObject:contact];
        }
        
        NSError *saveError = nil;
        [context save:&saveError];
        if (saveError) {
            NSLog(@"Error when saving managed object context : %@", saveError);
        }
    }
    
    [userDefaults setObject:userId forKey:@"userId"];
    [userDefaults synchronize];
    
    sort = [userDefaults objectForKey:@"GINKOSORTBY"];
    if (sort == nil) {
        sort = @"first_name";
        [userDefaults setObject:@"first_name" forKey:@"GINKOSORTBY"];
        [userDefaults synchronize];
    }
    
    NSNumber *timestamp = [userDefaults objectForKey:@"sync_timestamp"];
    if (timestamp) { // there is saved data
        NSManagedObjectContext *context = [AppDelegate sharedDelegate].managedObjectContext;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"Contact" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        NSMutableArray *tempList = [NSMutableArray new];
        for (Contact *contact in fetchedObjects) {
            id parsed = [NSJSONSerialization JSONObjectWithData:[contact.data dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
            [tempList addObject:parsed];
        }
        //totalList = [tempList.copy;
        appDelegate.totalList = tempList.copy;
        if ([appDelegate.totalList count] > 0)
        {
            [tblForContact setHidden:NO];
            [blankView setHidden:YES];
        }
        else
        {
            [tblForContact setHidden:YES];
            [blankView setHidden:NO];
        }
        [self sortContactsByLetters];
        [tblForContact reloadData];
    } else { // no saved data, need to load from api
        [self GetContacts:sort search:nil category:nil contactType:nil];
    }
    
    [appDelegate GetContactList];
    
    progressVC = [[SproutProgressViewController alloc] initWithNibName:@"SproutProgressViewController" bundle:nil];
    
    // Disable swipe gesture
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    //Clear searchedContacts
    
    
    //Get user's last saved location
    [[Communication sharedManager] getPurpleContacts:SESSIONID pageNum:0 countPerPage:0 keyword:@"" successed:^(id _responseObject) {
        NSDictionary *contactsDic = [_responseObject objectForKey:@"data"];
        NSDictionary *locs = contactsDic[@"my_location"];
        APPDELEGATE.latitude = [locs[@"latitude"] floatValue];
        APPDELEGATE.longitude = [locs[@"longitude"] floatValue];
    } failure:^(NSError *err) { }];
    //    [self performSelector:@selector(testReloadContacts) withObject:nil afterDelay:10];
    
    //To refresh not exchange num
    [CommonMethods loadDetectedContacts];
    //[CommonMethods loadFetchAllEntity];
    
    [CommonMethods loadFetchAllEntityNew];

    [self performFetch];
    
    if (APPDELEGATE.isOpenApp) {
        if ([APPDELEGATE.arrhandlePush count] > 0) {
            for (int i = 1 ; i <= [APPDELEGATE.arrhandlePush count]; i ++) {
                NSDictionary *onePush = [APPDELEGATE.arrhandlePush objectAtIndex:[APPDELEGATE.arrhandlePush count] - i];
                [APPDELEGATE HandlePushNotification:onePush];
                
                if ([onePush objectForKey:@"board_id"] || [onePush objectForKey:@"request_id"] || [onePush objectForKey:@"entity_id"] || ([onePush objectForKey:@"id"] && [[onePush objectForKey:@"type"] isEqualToString:@"directory"])) {
                }
            }
            [APPDELEGATE.arrhandlePush removeAllObjects];
        }
    }
    
}

- (void)testReloadContacts {
    NSString *responseString = @"{\
    \"data\":{\
    \"contacts\":[\
    {\
    \"contact_id\":4355,\
    \"contact_type\":2,\
    \"email\":\"\",\
    \"emails\":[\
    ],\
    \"first_name\":\"GGG\",\
    \"id\":4355,\
    \"is_pending\":0,\
    \"is_read\":1,\
    \"last_name\":\"\",\
    \"middle_name\":\"\",\
    \"notes\":\"tytttt\",\
    \"phones\":[\
    7343340259\
    ],\
    \"photo_url\":\"http: //www.xchangewith.me/api/v2/Photos/greyblank.png\",\
    \"type\":0\
    }\
    ],\
    \"removed_contacts\":[  \
    {  \
    \"contact_id\":4498,\
    \"contact_type\":2\
    }\
    ]\
    }\
    }";
    
    NSDictionary *_responseObject = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    
    NSDictionary *data = [_responseObject objectForKey:@"data"];
    
    NSManagedObjectContext *context = [AppDelegate sharedDelegate].managedObjectContext;
    
    NSFetchRequest *allContacts = [[NSFetchRequest alloc] init];
    [allContacts setEntity:[NSEntityDescription entityForName:@"Contact" inManagedObjectContext:context]];
    
    NSError *error = nil;
    NSArray *contacts = [context executeFetchRequest:allContacts error:&error];
    
    // remove contacts
    for (NSDictionary *removedContactDic in data[@"removed_contacts"]) {
        NSString *contactId;
        if ([removedContactDic[@"contact_type"] integerValue] == 3) // entity
            contactId = [NSString stringWithFormat:@"%@", removedContactDic[@"entity_id"]];
        else
            contactId = [NSString stringWithFormat:@"%@", removedContactDic[@"contact_id"]];
        NSArray *foundContacts = [contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"contact_id == %@ AND contact_type == %@", contactId, removedContactDic[@"contact_type"]]];
        if (foundContacts.count > 0) {
            [context deleteObject:foundContacts[0]];
        }
    }
    
    // add or edit contacts
    for (NSDictionary *contactDic in data[@"contacts"]) {
        NSString *contactId;
        if ([contactDic[@"contact_type"] integerValue] == 3) // entity
            contactId = [NSString stringWithFormat:@"%@", contactDic[@"entity_id"]];
        else
            contactId = [NSString stringWithFormat:@"%@", contactDic[@"contact_id"]];
        NSArray *foundContacts = [contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"contact_id == %@ AND contact_type == %@", contactId, contactDic[@"contact_type"]]];
        if (foundContacts.count > 0) { // existing
            Contact *contact = foundContacts[0];
            contact.data = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:contactDic options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
        } else { // new
            Contact *contact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:context];
            if ([contactDic[@"contact_type"] integerValue] == 3) // entity
                contact.contact_id = [NSString stringWithFormat:@"%@", contactDic[@"entity_id"]];
            else
                contact.contact_id = [NSString stringWithFormat:@"%@", contactDic[@"contact_id"]];
            contact.contact_type = contactDic[@"contact_type"];
            contact.data = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:contactDic options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
        }
    }
    
    NSError *saveError = nil;
    [context save:&saveError];
    if (saveError) {
        NSLog(@"Error when saving managed object context : %@", saveError);
    }
    
    NSMutableArray *tempList = [NSMutableArray new];
    NSArray *fetchedObjects = [context executeFetchRequest:allContacts error:&error];
    for (Contact *contact in fetchedObjects) {
        id parsed = [NSJSONSerialization JSONObjectWithData:[contact.data dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
        [tempList addObject:parsed];
    }
    appDelegate.totalList = tempList.copy;
    
    if ([appDelegate.totalList count] > 0)
    {
        [tblForContact setHidden:NO];
        [blankView setHidden:YES];
    }
    else
    {
        [tblForContact setHidden:YES];
        [blankView setHidden:NO];
    }
    
    [self sortContactsByLetters];
    [tblForContact reloadData];
}

- (void)receiveNotification:(NSNotification *) notification
{
    NSDictionary * dict = notification.userInfo;
    NSString * flag = [dict objectForKey:@"LOCATION_FLAG"];
    if ([flag isEqualToString:@"NO"])
    {
        gpsBut.selected = NO;
        _thumbButton.enabled = YES;
        
    }
    else if ([flag isEqualToString:@"YES"])
    {
        gpsBut.selected = YES;
        _thumbButton.enabled = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:NO];
    [self.navigationController.navigationBar addSubview:navView];
    //self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:186.0/256.0 green:1.0f blue:182.0/256.0 alpha:1.0f];
    [self.navigationController.navigationItem setHidesBackButton:YES animated:NO];
    gpsBut.selected = appDelegate.locationFlag;
    [self.view endEditing:YES];
    if (appDelegate.viewType == 0)
    {
        rowHeight = 405.0f;
        ContactCellIdentifier = @"TileViewCell";
    }
    else if (appDelegate.viewType == 1)
    {
        rowHeight = 72.0f;
        ContactCellIdentifier = @"ContactCell";
    }
    
    BOOL tableViewNeedsRefresh = NO;
    if (viewType != appDelegate.viewType) {
        viewType = appDelegate.viewType;
        tableViewNeedsRefresh = YES;
    }
    
    NSString *newSort = [[NSUserDefaults standardUserDefaults] objectForKey:@"GINKOSORTBY"];
    if (newSort == nil) {
        sort = @"first_name";
    }
    else if (![newSort isEqualToString:sort]) {
        sort = newSort;
        [self sortContactsByLetters];
        tableViewNeedsRefresh = YES;
    }
    
    if (tableViewNeedsRefresh) {
        [tblForContact reloadData];
    }
    
    // Created by Zhun L.
    //    [self onSortBtn:nil];
    //-------------------
    
    
    [self GetCBEmailValid];
    
    [self displayGPSButton];
    
    NSLog(@"viewwill appear for contact list");
    
    appDelegate.isCalledContactsReload = YES;
    appDelegate.isCalledSyncContacts = YES;
    
    [self reloadContacts];
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    NSLog(@"refesh contact list");
    [self reloadContacts];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:LOCATION_CHANGE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadContacts) name:CONTACT_SYNC_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveContactListNotification:) name:GET_CONTACTLIST_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:ApplicationWillResignActive object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:NOTIFICATION_GINKO_VIDEO_CONFERENCE object:nil];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [navView removeFromSuperview];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LOCATION_CHANGE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GET_CONTACTLIST_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ApplicationWillResignActive object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_GINKO_VIDEO_CONFERENCE object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CONTACT_SYNC_NOTIFICATION object:nil];
}

- (void)applicationWillResignActive
{
    if (appDelegate.thumbDown)
        [self touchUpThumb:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSString *)isContactIdExist:(NSString *)contactId {
    NSManagedObjectContext *context = [AppDelegate sharedDelegate].managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contact_id == %@", contactId];
    request.predicate = predicate;
    [request setEntity:[NSEntityDescription entityForName:@"Contact" inManagedObjectContext:context]];
    // [request setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError *error = nil;
    NSArray *contacts = [context executeFetchRequest:request error:&error];
    if (contacts.count > 0) {
        NSString *contactDic = ((Contact *)contacts[0]).data;
        NSDictionary *user = [NSJSONSerialization JSONObjectWithData:[contactDic dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
        return [NSString stringWithFormat:@"%@ %@",[user objectForKey:@"first_name"],[user objectForKey:@"last_name"]];
    }
    return nil;
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [keyList count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if([contactList[keyList[section]] count] == 0)
        return nil;
    return keyList[section];
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
//
//    [view setBackgroundColor:[UIColor clearColor]];
//    [view setAlpha:0.6f];
//    UILabel *lblCaption = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
//    [lblCaption setBackgroundColor:[UIColor clearColor]];
//    [lblCaption setText:[keyList objectAtIndex:section]];
//    [view addSubview:lblCaption];
//
//    return view;
//}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return keyList;
}

- (NSInteger)tableView:(UITableView *)tableView
sectionForSectionIndexTitle:(NSString *)title
               atIndex:(NSInteger)index
{
    int keyIndex = -1;
    
    for (int i = 0; i < [keyList count]; i++)
        if ([[keyList objectAtIndex:i] isEqualToString:title])
        {
            keyIndex = i;
            break;
        }
    
    return keyIndex;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [contactList[keyList[section]] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (appDelegate.viewType == 0) // Tile view
    {
        NSDictionary * dict = contactList[keyList[indexPath.section]][indexPath.row];
        
        if ([dict objectForKey:@"entity_id"]) {
            
            TitleEntityCell *cell = [tblForContact dequeueReusableCellWithIdentifier:@"TitleEntityCell"];
            
            if(cell == nil)
            {
                cell = [TitleEntityCell sharedCell];
            }
            
            [cell setDelegate:self] ;
            
            cell.curDict = dict;
            
            return cell;
        }
        
        TileViewCell *cell = [tblForContact dequeueReusableCellWithIdentifier:ContactCellIdentifier forIndexPath:indexPath];
        // Set;
        if (cell == nil)
        {
            cell = [[TileViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ContactCellIdentifier];
        }
        
        NSString * firstName = [dict objectForKey:@"first_name"];
        NSString * middleName = [dict objectForKey:@"middle_name"];
        NSString * lastName = [dict objectForKey:@"last_name"];
        
        if ([[dict objectForKey:@"is_read"] boolValue])
            [cell.imgViewNew setHidden:YES];
        else
            [cell.imgViewNew setHidden:NO];
        
        //        NSURL * imageURL = [NSURL URLWithString:[dict objectForKey:@"photo_url"]];
        //        NSData *data = [NSData dataWithContentsOfURL:imageURL];
        //        UIImage *profileImage = [[UIImage alloc] initWithData:data];
        //        [cell.profileImageView setImage:profileImage];
        if ([[dict objectForKey:@"contact_type"] integerValue] == 1) { // purple
            [cell setPhoto:[dict objectForKey:@"profile_image"]];
        } else if ([[dict objectForKey:@"contact_type"] integerValue] == 2) { // grey
            [cell setPhoto:[dict objectForKey:@"photo_url"]];
        }
        
        cell.firstName.text = [NSString stringWithFormat:@"%@ %@", firstName, middleName];
        cell.lastName.text = lastName;
        cell.delegate = self;
        cell.sessionId = @"";
        cell.contactId = [dict objectForKey:@"contact_id"];
        cell.curContact = dict;
        
        if ([[dict objectForKey:@"contact_type"] integerValue] == 1) // purple
        {
            [cell.contactBut setImage:[UIImage imageNamed:@"BtnChat.png"] forState:UIControlStateNormal];
            
            CGPoint centerPt = cell.contactBut.center;
            
            [cell.contactBut setFrame:CGRectMake(0, 0, 32, 32)];
            [cell.contactBut setCenter:centerPt];
            [cell.statusImageView setHidden:NO];
            
            if ([dict objectForKey:@"online"])
                [cell.statusImageView setImage:[UIImage imageNamed:@"online"]];
            else
                [cell.statusImageView setImage:[UIImage imageNamed:@"offline"]];
            
            // Phone Button
            centerPt = cell.phoneBut.center;
            
            [cell.phoneBut setFrame:CGRectMake(0, 0, 32, 32)];
            [cell.phoneBut setCenter:centerPt];
            
            if ([[dict objectForKey:@"sharing_status"] integerValue] != 4)
                [cell.phoneBut setImage:[UIImage imageNamed:@"BtnPhone.png"] forState:UIControlStateNormal];
            else
                [cell.phoneBut setImage:[UIImage imageNamed:@"EditContact.png"] forState:UIControlStateNormal];
            // End
            
            cell.type = 1;
            cell.arrPhone = [dict objectForKey:@"phones"];
            cell.arrEmail = [dict objectForKey:@"emails"];
            
            [cell.firstName setTextColor:[UIColor colorWithRed:110.0f/255.0f green:75.0f/255.0f blue:154.0f/255.0f alpha:1.0f]];
            [cell.lastName setTextColor:[UIColor colorWithRed:110.0f/255.0f green:75.0f/255.0f blue:154.0f/255.0f alpha:1.0f]];
        }
        else if ([[dict objectForKey:@"contact_type"] integerValue] == 2) // grey
        {
            [cell.contactBut setImage:[UIImage imageNamed:@"BtnMailGrey"] forState:UIControlStateNormal];
            
            CGPoint centerPt = cell.contactBut.center;
            
            [cell.contactBut setFrame:CGRectMake(0, 0, 32, 20)];
            [cell.contactBut setCenter:centerPt];
            [cell.statusImageView setHidden:YES];
            
            // Phone Button
            centerPt = cell.phoneBut.center;
            
            [cell.phoneBut setFrame:CGRectMake(0, 0, 32, 32)];
            [cell.phoneBut setCenter:centerPt];
            [cell.phoneBut setImage:[UIImage imageNamed:@"BtnPhoneGrey.png"] forState:UIControlStateNormal];
            // End
            
            cell.type = 2;
            cell.arrPhone = [dict objectForKey:@"phones"];
            cell.arrEmail = [dict objectForKey:@"emails"];
            
            [cell.firstName setTextColor:[UIColor colorWithRed:86.0f/255.0f green:86.0f/255.0f blue:86.0f/255.0f alpha:1.0f]];
            [cell.lastName setTextColor:[UIColor colorWithRed:86.0f/255.0f green:86.0f/255.0f blue:86.0f/255.0f alpha:1.0f]];
        }
        
        [cell setBorder];
        
        return cell;
    }
    else if (appDelegate.viewType == 1)
    {
        NSDictionary * dict = contactList[keyList[indexPath.section]][indexPath.row];
        
        if ([dict objectForKey:@"entity_id"]) {
            
            ListEntityCellCell *cell = [tblForContact dequeueReusableCellWithIdentifier:@"ListEntityCellCell"];
            
            if(cell == nil)
            {
                cell = [ListEntityCellCell sharedCell];
            }
            
            [cell setDelegate:self] ;
            
            cell.curDict = dict;
            
            return cell;
        }
        
        ContactCell *cell = [tblForContact dequeueReusableCellWithIdentifier:ContactCellIdentifier forIndexPath:indexPath];
        // Set;
        if (cell == nil)
        {
            cell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ContactCellIdentifier];
        }
        
        NSString * firstName = [dict objectForKey:@"first_name"];
        NSString * middleName = [dict objectForKey:@"middle_name"];
        NSString * lastName = [dict objectForKey:@"last_name"];
        
        if ([[dict objectForKey:@"is_read"] boolValue])
            [cell.imgViewNew setHidden:YES];
        else
            [cell.imgViewNew setHidden:NO];
        
        //        NSURL * imageURL = [NSURL URLWithString:[dict objectForKey:@"photo_url"]];
        //        NSData *data = [NSData dataWithContentsOfURL:imageURL];
        //        UIImage *profileImage = [[UIImage alloc] initWithData:data];
        //        [cell.profileImageView setImage:profileImage];
        if ([[dict objectForKey:@"contact_type"] integerValue] == 1) {
            [cell setPhoto:[dict objectForKey:@"profile_image"]];
        } else if ([[dict objectForKey:@"contact_type"] integerValue] == 2) {
            [cell setPhoto:[dict objectForKey:@"photo_url"]];
        }
        cell.firstName.text = [NSString stringWithFormat:@"%@ %@", firstName, middleName];
        cell.lastName.text = lastName;
        cell.delegate = self;
        cell.sessionId = @"";
        cell.contactId = [dict objectForKey:@"contact_id"];
        cell.curContact = dict;
        
        if ([[dict objectForKey:@"contact_type"] integerValue] == 1)
        {
            [cell.contactBut setImage:[UIImage imageNamed:@"BtnChat.png"] forState:UIControlStateNormal];
            
            CGPoint centerPt = cell.contactBut.center;
            
            [cell.contactBut setFrame:CGRectMake(0, 0, 32, 32)];
            [cell.contactBut setCenter:centerPt];
            [cell.statusImageView setHidden:NO];
            
            if ([dict objectForKey:@"online"])
                [cell.statusImageView setImage:[UIImage imageNamed:@"online"]];
            else
                [cell.statusImageView setImage:[UIImage imageNamed:@"offline"]];
            
            // Phone Button
            centerPt = cell.phoneBut.center;
            
            [cell.phoneBut setFrame:CGRectMake(0, 0, 32, 32)];
            [cell.phoneBut setCenter:centerPt];
            
            if ([[dict objectForKey:@"sharing_status"] integerValue] != 4)
                [cell.phoneBut setImage:[UIImage imageNamed:@"BtnPhone.png"] forState:UIControlStateNormal];
            else
                [cell.phoneBut setImage:[UIImage imageNamed:@"EditContact.png"] forState:UIControlStateNormal];
            //End
            
            cell.type = 1;
            cell.arrPhone = [dict objectForKey:@"phones"];
            cell.arrEmail = [dict objectForKey:@"emails"];
            
            [cell.firstName setTextColor:[UIColor colorWithRed:110.0f/255.0f green:75.0f/255.0f blue:154.0f/255.0f alpha:1.0f]];
            [cell.lastName setTextColor:[UIColor colorWithRed:110.0f/255.0f green:75.0f/255.0f blue:154.0f/255.0f alpha:1.0f]];
        }
        else if ([[dict objectForKey:@"contact_type"] integerValue] == 2)
        {
            [cell.contactBut setImage:[UIImage imageNamed:@"BtnMailGrey.png"] forState:UIControlStateNormal];
            
            CGPoint centerPt = cell.contactBut.center;
            
            [cell.contactBut setFrame:CGRectMake(0, 0, 32, 20)];
            [cell.contactBut setCenter:centerPt];
            [cell.statusImageView setHidden:YES];
            
            // Phone Button
            centerPt = cell.phoneBut.center;
            
            [cell.phoneBut setFrame:CGRectMake(0, 0, 32, 32)];
            [cell.phoneBut setCenter:centerPt];
            [cell.phoneBut setImage:[UIImage imageNamed:@"BtnPhoneGrey.png"] forState:UIControlStateNormal];
            // End
            
            cell.type = 2;
            cell.arrPhone = [dict objectForKey:@"phones"];
            NSMutableArray *emails = [[NSMutableArray alloc] init];
            for (NSString *oneemail in [dict objectForKey:@"emails"]) {
                if (![emails containsObject:oneemail]) {
                    [emails addObject:oneemail];
                }
            }
            cell.arrEmail = emails;
            
            [cell.firstName setTextColor:[UIColor colorWithRed:86.0f/255.0f green:86.0f/255.0f blue:86.0f/255.0f alpha:1.0f]];
            [cell.lastName setTextColor:[UIColor colorWithRed:86.0f/255.0f green:86.0f/255.0f blue:86.0f/255.0f alpha:1.0f]];
        }
        
        [cell setBorder];
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary * dict = contactList[keyList[indexPath.section]][indexPath.row];
    
    if ([dict objectForKey:@"entity_id"]) {
        [self getEntityFollowerView:[dict objectForKey:@"entity_id"] following:YES notes:[dict objectForKey:@"notes"]];
        return;
    }
    
    [self updateIsRead:[dict objectForKey:@"contact_id"] contactType:[[dict objectForKey:@"contact_type"] stringValue]];
    
    if ([[dict objectForKey:@"contact_type"] integerValue] == 1)
    {
        if ([[dict objectForKey:@"sharing_status"] integerValue] == 0)
            return;
        else if ([[dict objectForKey:@"sharing_status"] integerValue] == 4)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"GINKO" message:@"Oops! Contact would like to chat only" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            
            [alertView show];
            [self reloadContacts];
        }
        else
        {
            [self getContactDetail:dict :1];
        }
    }
    else if ([[dict objectForKey:@"contact_type"] integerValue] == 2)
    {
        [self getContactDetail:dict :2];
    }
}

#pragma mark - ContactCellDelegate
- (void)viewChat:(NSString *)sessionId contactId:(NSString *)contactId
{
    
}

- (void)sendMail:(NSString *)_email
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    
    if ([mailClass canSendMail])
        [self displayComposerSheet: _email];
}

- (void)didChat:(NSDictionary *)contactDict
{
    [self updateIsRead:[contactDict objectForKey:@"contact_id"] contactType:[[contactDict objectForKey:@"contact_type"] stringValue]];
    [self CreateMessageBoard:[contactDict objectForKey:@"contact_id"] dict:contactDict];
}

- (void)didEdit:(NSDictionary *)contactDict
{
    appDelegate.type = 4;
    
    [self getContactDetail:contactDict :0];
}
- (void)didCallVideo:(NSDictionary *)contactDict{
    
    [self updateIsRead:[contactDict objectForKey:@"contact_id"] contactType:[[contactDict objectForKey:@"contact_type"] stringValue]];
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
                            [self CreateVideoAndVoiceConferenceBoard:[contactDict objectForKey:@"contact_id"] dict:contactDict type:1];
                        }
                    }];
                }
            });
        }];
    }
    
}
- (void)didCallVoice:(NSDictionary *)contactDict{
    
    [self updateIsRead:[contactDict objectForKey:@"contact_id"] contactType:[[contactDict objectForKey:@"contact_type"] stringValue]];
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
                            [self CreateVideoAndVoiceConferenceBoard:[contactDict objectForKey:@"contact_id"] dict:contactDict type:2];
                        }
                    }];
                }
            });
        }];
    }
}
#pragma mark - Events
- (IBAction)onImportContact:(id)sender
{
    //    _globalData.isFromMenu = YES;
    CIHomeViewController *vc = [[CIHomeViewController alloc] initWithNibName:@"CIHomeViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onScan:(id)sender {
    ScanMeViewController *vc = [[ScanMeViewController alloc] initWithNibName:@"ScanMeViewController" bundle:nil];
    vc.parentVC = self;
    [self.navigationController pushViewController:vc animated:YES];
}

// Created by Zhun L.
- (IBAction)onBtnRequests:(id)sender
{
    self.navigationItem.title = @"";
    TabRequestController *tabRequestController = [TabRequestController sharedController];
    tabRequestController.selectedIndex = 1;
    // Push;
    [self.navigationController pushViewController:tabRequestController animated:YES];
}

- (IBAction)onBtnContacts:(id)sender {
    BOOL showOrg = NO;
    if (showOrg) {
        [appDelegate GetContactList];
        self.navigationItem.title = @"";
        TabBarController *tabBarController = [TabBarController sharedController];
        tabBarController.selectedIndex = 1;
        [self.navigationController pushViewController:tabBarController animated:YES];
    }
    else {
        UIViewController *nav = [SB_GINKOME instantiateViewControllerWithIdentifier:@"GinkoMeNav"];
        [self presentViewController:nav animated:YES completion:nil];
        //        [self.navigationController pushViewController:nav animated:YES];
    }
}

- (IBAction)onGinkoMe:(id)sender {
    [appDelegate GetContactList];
    //self.navigationItem.title = @"";
    //TabBarController *tabBarController = [TabBarController sharedController];
    //tabBarController.selectedIndex = 1;
    // Push;
    //[self.navigationController pushViewController:tabBarController animated:YES];
    [appDelegate changeGPSSetting:1];
    UIViewController *nav = [SB_GINKOME instantiateViewControllerWithIdentifier:@"GinkoMeNav"];
    [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)onInviteContacts:(id)sender {
    self.navigationItem.title = @"";
    TabRequestController *tabRequestController = [TabRequestController sharedController];
    tabRequestController.selectedIndex = 1;
    // Push;
    [self.navigationController pushViewController:tabRequestController animated:YES];
}

- (IBAction)onSortBtn:(id)sender
{
    int newFilterType;
    if (sender != nil)
        newFilterType = (int)[sender tag] - 100;
    else
        newFilterType = 3;
    if (filterType == newFilterType)
        return;
    filterType = newFilterType;
    
    [btnAll setSelected:NO];
    [btnHome setSelected:NO];
    [btnWork setSelected:NO];
    [btnEntity setSelected:NO];
    [btnFavorite setSelected:NO];
    
    switch (filterType) {
        case 0:
            [btnEntity setSelected:YES];
            break;
        case 1:
            [btnWork setSelected:YES];
            break;
        case 2:
            [btnHome setSelected:YES];
            break;
        case 3:
            [btnAll setSelected:YES];
            break;
        case 4:
            [btnFavorite setSelected:YES];
            break;
        default:
            break;
    }
    
    [self sortContactsByLetters];
    [tblForContact reloadData];
    if ([self numberOfSectionsInTableView:tblForContact] > 0)
    {
        NSIndexPath* top = [NSIndexPath indexPathForRow:NSNotFound inSection:0];
        [tblForContact scrollToRowAtIndexPath:top atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    
    //    [self getFriends];
}

//- (void)getFriends
//{
////    [tblForContact reloadData];
//    [btnAll setSelected:NO];
//    [btnHome setSelected:NO];
//    [btnWork setSelected:NO];
//    [btnEntity setSelected:NO];
//
//    switch (filterType) {
//        case 0:
//            [btnEntity setSelected:YES];
//            [self GetContacts:sort search:nil category:@"0" contactType:nil];
//            break;
//        case 1:
//            [btnWork setSelected:YES];
//            [self GetContacts:sort search:nil category:@"2" contactType:nil];
//            break;
//        case 2:
//            [btnHome setSelected:YES];
//            [self GetContacts:sort search:nil category:@"1" contactType:nil];
//            break;
//        case 3:
//            [btnAll setSelected:YES];
//            [self GetContacts:sort search:nil category:nil contactType:nil];
//            break;
//        default:
//            break;
//    }
//}

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
                }            } else {
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

- (void)reloadContacts {
    
    //if (appDelegate.isCalledContactsReload) {
        appDelegate.isCalledContactsReload = NO;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSNumber *timestamp = [userDefaults objectForKey:@"sync_timestamp"];
        NSLog(@"it was called reloadcontacts function");
        if (!timestamp) // seems it's still loading and don't need to get updated contacts
        {
            [refreshControl endRefreshing];
            return;
        }
        
        void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
            [refreshControl endRefreshing];
            if ([[_responseObject objectForKey:@"success"] boolValue])
            {
                // save current timestamp
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                //NSLog(@"_response----%@",_responseObject);
                NSDictionary *data = [_responseObject objectForKey:@"data"];
                id receivedTimeStamp = data[@"new_sync_timestamp"];
                if (![receivedTimeStamp isKindOfClass:[NSNumber class]])
                    receivedTimeStamp = @([receivedTimeStamp intValue]);
                [userDefaults setObject:receivedTimeStamp forKey:@"sync_timestamp"];
                [userDefaults synchronize];
                
                NSManagedObjectContext *context = [AppDelegate sharedDelegate].managedObjectContext;
                
                NSFetchRequest *allContacts = [[NSFetchRequest alloc] init];
                [allContacts setEntity:[NSEntityDescription entityForName:@"Contact" inManagedObjectContext:context]];
                
                NSError *error = nil;
                NSArray *contacts = [context executeFetchRequest:allContacts error:&error];
                
                // remove contacts
                for (NSDictionary *removedContactDic in data[@"removed_contacts"]) {
                    NSString *contactId;
                    contactId = [NSString stringWithFormat:@"%@", removedContactDic[@"contact_id"]];
                    NSArray *foundContacts = [contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"contact_id == %@ AND contact_type == %@", contactId, removedContactDic[@"contact_type"]]];
                    if (foundContacts.count > 0) {
                        [context deleteObject:foundContacts[0]];
                    }
                }
                
                // add or edit contacts
                for (NSDictionary *contactDic in data[@"contacts"]) {
                    NSString *contactId;
                    if ([contactDic[@"contact_type"] integerValue] == 3) // entity
                        contactId = [NSString stringWithFormat:@"%@", contactDic[@"entity_id"]];
                    else
                        contactId = [NSString stringWithFormat:@"%@", contactDic[@"contact_id"]];
                    NSArray *foundContacts = [contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"contact_id == %@ AND contact_type == %@", contactId, contactDic[@"contact_type"]]];
                    if (foundContacts.count > 0) { // existing
                        Contact *contact = foundContacts[0];
                        contact.data = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:contactDic options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
                    } else { // new
                        Contact *contact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:context];
                        if ([contactDic[@"contact_type"] integerValue] == 3) // entity
                            contact.contact_id = [NSString stringWithFormat:@"%@", contactDic[@"entity_id"]];
                        else
                            contact.contact_id = [NSString stringWithFormat:@"%@", contactDic[@"contact_id"]];
                        contact.contact_type = contactDic[@"contact_type"];
                        contact.data = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:contactDic options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
                    }
                }
                
                NSError *saveError = nil;
                [context save:&saveError];
                if (saveError) {
                    NSLog(@"Error when saving managed object context : %@", saveError);
                }
                
                NSMutableArray *tempList = [NSMutableArray new];
                NSArray *fetchedObjects = [context executeFetchRequest:allContacts error:&error];
                for (Contact *contact in fetchedObjects) {
                    id parsed = [NSJSONSerialization JSONObjectWithData:[contact.data dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
                    [tempList addObject:parsed];
                }
                //totalList = tempList.copy;
                appDelegate.totalList = tempList.copy;
                if ([appDelegate.totalList count] > 0)
                {
                    [tblForContact setHidden:NO];
                    [blankView setHidden:YES];
                }
                else
                {
                    [tblForContact setHidden:YES];
                    [blankView setHidden:NO];
                }
                if ([appDelegate.existedContactIDs count] > 0) {
                    [appDelegate.existedContactIDs removeAllObjects];
                }
                //NSLog(@"total---%@",totalList);
                for (int i =0; i < [appDelegate.totalList count]; i ++) {
                    if ([[[appDelegate.totalList objectAtIndex:i] objectForKey:@"contact_type"] integerValue] == 1) {
                        [appDelegate.existedContactIDs addObject:[[appDelegate.totalList objectAtIndex:i] objectForKey:@"contact_id"]];
                    }
                    
                }
                
                [self sortContactsByLetters];
                [tblForContact reloadData];
                appDelegate.isCalledContactsReload = YES;
                
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CONTACTGPS_CHANGED object:nil];
                
                if (appDelegate.isCalledSyncContacts) {
                    appDelegate.isCalledSyncContacts = NO;
                    
                    //Sync Updated Contacts
                    [[Communication sharedManager] updatedContactsSynced:[AppDelegate sharedDelegate].sessionId timeStamp:[receivedTimeStamp stringValue] successed:^(id res) {
                        appDelegate.isCalledSyncContacts = YES;
                    } failure:^(NSError *err) {
                        appDelegate.isCalledSyncContacts = YES;
                        NSLog(@"failure");
                    }];
                }
            }
        };
        
        void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
            [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
            [refreshControl endRefreshing];
            appDelegate.isCalledContactsReload = YES;
            NSLog(@"Connection failed - %@", _error);
        } ;
        
        [[Communication sharedManager] syncUpdatedContacts:[AppDelegate sharedDelegate].sessionId timeStamp:[timestamp stringValue] successed:successed failure:failure];
    //}
    
}

#pragma mark - TitleEntityCell Delegate
- (void)didPhone:(NSDictionary *)entityDict
{
    
}

- (void)didWall:(NSDictionary *)entityDict
{
    EntityChatWallViewController *vc = [[EntityChatWallViewController alloc] initWithNibName:@"EntityChatWallViewController" bundle:nil];
    vc.entityID = [entityDict objectForKey:@"entity_id"];
    vc.entityName = [entityDict objectForKey:@"name"];
    vc.entityImageURL = [entityDict objectForKey:@"profile_image"];
    [self.navigationController pushViewController:vc animated:YES];
}

//em classes
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
            }else if([_responseObject[@"data"][@"infos"] count] == 1){
                EntityViewController *vc = [[EntityViewController alloc] initWithNibName:@"EntityViewController" bundle:nil];
                vc.entityData = _responseObject[@"data"];
                vc.isFollowing = isFollowing;
                vc.isFavorite = [[_responseObject[@"data"] objectForKey:@"is_favorite"] boolValue];
                [self.navigationController pushViewController:vc animated:YES];
            }else {
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

//em classes end

//chatting class

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
            [dictTemp setObject:[contactInfo objectForKey:@"profile_image"] forKey:@"photo_url"];
            [dictTemp setObject:[contactInfo objectForKey:@"contact_id"] forKey:@"user_id"];
            [dictTemp setObject:[contactInfo objectForKey:@"phones"] forKey:@"phones"];
            
            [lstTemp addObject:dictTemp];
            
            NSMutableDictionary *dictTemp1 = [[NSMutableDictionary alloc] init];
            
            [dictTemp1 setObject:[AppDelegate sharedDelegate].firstName forKey:@"fname"];
            [dictTemp1 setObject:[AppDelegate sharedDelegate].lastName forKey:@"lname"];
            [dictTemp1 setObject:[AppDelegate sharedDelegate].photoUrl forKey:@"photo_url"];
            [dictTemp1 setObject:[AppDelegate sharedDelegate].userId forKey:@"user_id"];
            
            [lstTemp addObject:dictTemp1];
            
            YYYChatViewController *viewcontroller = [[YYYChatViewController alloc] initWithNibName:@"YYYChatViewController" bundle:nil];
            viewcontroller.boardid = [[_responseObject objectForKey:@"data"] objectForKey:@"board_id"];
            viewcontroller.lstUsers = [[NSMutableArray alloc] initWithArray:lstTemp];
            if ([[contactInfo objectForKey:@"sharing_status"] integerValue] == 4) {
                viewcontroller.isAbleVideoConference = YES;
            }
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

-(void)CreateVideoAndVoiceConferenceBoard:(NSString*)ids dict:(NSDictionary *)contactInfo type:(NSInteger)_type
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            [APPDELEGATE.conferenceMembersForVideoCalling removeAllObjects];
            NSMutableDictionary *dictOfUser = [[NSMutableDictionary alloc] init];
            
            [dictOfUser setObject:[contactInfo valueForKey:@"contact_id"] forKey:@"user_id"];
            [dictOfUser setObject:[NSString stringWithFormat:@"%@ %@", [contactInfo objectForKey:@"first_name"], [contactInfo objectForKey:@"last_name"]] forKey:@"name"];
            [dictOfUser setObject:[contactInfo objectForKey:@"profile_image"] forKey:@"photo_url"];
            if (_type == 1) {
                [dictOfUser setObject:@"on" forKey:@"videoStatus"];
            }else{
                [dictOfUser setObject:@"off" forKey:@"videoStatus"];
            }
            [dictOfUser setObject:@"on" forKey:@"voiceStatus"];
            [dictOfUser setObject:@(1) forKey:@"conferenceStatus"];
            [dictOfUser setObject:@(0) forKey:@"isOwner"];
            [dictOfUser setObject:@(0) forKey:@"isInvited"];
            [dictOfUser setObject:@(1) forKey:@"isInvitedByMe"];
            
            [APPDELEGATE.conferenceMembersForVideoCalling addObject:dictOfUser];
            
            VideoVoiceConferenceViewController *viewcontroller = [[VideoVoiceConferenceViewController alloc] initWithNibName:@"VideoVoiceConferenceViewController" bundle:nil];
            APPDELEGATE.isOwnerForConference = YES;
            APPDELEGATE.isJoinedOnConference = YES;
            APPDELEGATE.conferenceId = [[_responseObject objectForKey:@"data"] objectForKey:@"board_id"];
            viewcontroller.boardId = [[_responseObject objectForKey:@"data"] objectForKey:@"board_id"];
            viewcontroller.conferenceType = _type;
            viewcontroller.conferenceName =[NSString stringWithFormat:@"%@ %@", [contactInfo objectForKey:@"first_name"], [contactInfo objectForKey:@"last_name"]];
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

// Displays an email composition interface inside the application. Populates all the Mail fields.
-(void)displayComposerSheet : (NSString *)email
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setSubject:@""];
    
    
    // Set up recipients
    NSArray *toRecipients = [NSArray arrayWithObjects:email, nil];
    NSArray *ccRecipients = [NSArray arrayWithObject:@""];
    NSArray *bccRecipients = [NSArray arrayWithObject:@""];
    
    [picker setToRecipients:toRecipients];
    [picker setCcRecipients:ccRecipients];
    [picker setBccRecipients:bccRecipients];
    
    [picker setMessageBody:@"" isHTML:YES];
    
    [self presentViewController:picker animated:YES completion:nil];
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    NSString * messageResult ;
    switch (result)
    {
        case MFMailComposeResultCancelled:
            messageResult = @"Mail cancelled.";
            break;
        case MFMailComposeResultSaved:
            messageResult = @"Mail saved.";
            break;
        case MFMailComposeResultSent:
            messageResult = @"Mail successfully sent";
            [[[UIAlertView alloc] initWithTitle: nil message:messageResult delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            break;
        case MFMailComposeResultFailed:
            messageResult = @"Mail failed.";
            break;
        default:
            messageResult = @"Mail don't send.";
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onSearch
{
    //    [self.navigationController popViewControllerAnimated:YES];
    SearchViewController *viewController = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
    viewController.contactList = appDelegate.totalList;
    viewController.isMenu = NO;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)onMenu
{
    //    [self.navigationController popViewControllerAnimated:YES];
    MenuViewController *viewController = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)onContactBuilder
{
    _globalData.cbIsFromMenu = YES;
    CBMainViewController *vc = [[CBMainViewController alloc] initWithNibName:@"CBMainViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onClose
{
    
}

- (IBAction)onInviteContact:(id)sender {
    if ([AppDelegate sharedDelegate].phoneVerified) {//if(appDelegate.phoneVerified)
        GinkoConnectViewController *vc = [[GinkoConnectViewController alloc] initWithNibName:@"GinkoConnectViewController" bundle:nil];
        vc.isFromContacts = YES;
        UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
        navVC.navigationBar.translucent = NO;
        [[AppDelegate sharedDelegate].window.rootViewController presentViewController:navVC animated:YES completion:nil];
    } else {
        InvitationQueryViewController *vc = [[InvitationQueryViewController alloc] initWithNibName:@"InvitationQueryViewController" bundle:nil];
        vc.isFromContacts = YES;
        UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
        navVC.navigationBar.translucent = NO;
        [[AppDelegate sharedDelegate].window.rootViewController presentViewController:navVC animated:YES completion:nil];
    }
}

- (IBAction)onAddGroups:(id)sender {
    //GroupListViewController *vc = [[GroupListViewController alloc] initWithNibName:@"GroupListViewController" bundle:nil];
    GroupsViewController *vc = [[GroupsViewController alloc] initWithNibName:@"GroupsViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}


//chatting class
- (IBAction)onChat:(id)sender
{
    ChatViewController * controller = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
    controller.isWall = NO;
    [self.navigationController pushViewController:controller animated:YES];
}

// Created by Zhun L.

- (void)GetContacts : (NSString *)_sortby
              search: (NSString *)_search
            category: (NSString *)_category
         contactType: (NSString *)_contactType
{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            if ([AppDelegate sharedDelegate].syncTimeStamp)
            {
                // save current timestamp
                [userDefaults setObject:appDelegate.syncTimeStamp forKey:@"sync_timestamp"];
            } else {
                [userDefaults setObject:@0 forKey:@"sync_timestamp"];
            }
            [userDefaults synchronize];
            
            appDelegate.totalList = [_responseObject objectForKey:@"data"];
            
            if ([appDelegate.totalList count] > 0)
            {
                [tblForContact setHidden:NO];
                [blankView setHidden:YES];
            }
            else
            {
                [tblForContact setHidden:YES];
                [blankView setHidden:NO];
            }
            
            // fetch 'em and delete 'em all
            NSManagedObjectContext *context = [AppDelegate sharedDelegate].managedObjectContext;
            NSFetchRequest *allContacts = [[NSFetchRequest alloc] init];
            [allContacts setEntity:[NSEntityDescription entityForName:@"Contact" inManagedObjectContext:context]];
            [allContacts setIncludesPropertyValues:NO]; //only fetch the managedObjectID
            
            NSError *error = nil;
            NSArray *contacts = [context executeFetchRequest:allContacts error:&error];
            
            //error handling goes here
            for (Contact *contact in contacts) {
                [context deleteObject:contact];
            }
            
            // add contacts
            for (NSDictionary *contactDic in appDelegate.totalList) {
                Contact *contact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:context];
                if ([contactDic[@"contact_type"] integerValue] == 3) // entity
                    contact.contact_id = [NSString stringWithFormat:@"%@", contactDic[@"entity_id"]];
                else
                    contact.contact_id = [NSString stringWithFormat:@"%@", contactDic[@"contact_id"]];
                contact.contact_type = contactDic[@"contact_type"];
                contact.data = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:contactDic options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
            }
            
            NSError *saveError = nil;
            [context save:&saveError];
            if (saveError) {
                NSLog(@"Error when saving managed object context : %@", saveError);
            }
            
            [self sortContactsByLetters];
            [tblForContact reloadData];
            
            //            //Sync Updated Contacts
            //            [[Communication sharedManager] updatedContactsSynced:[AppDelegate sharedDelegate].sessionId timeStamp:[@(timeStamp) stringValue] successed:^(id res) {
            //                NSLog(@"success");
            //            } failure:^(NSError *err) {
            //                NSLog(@"failure");
            //            }];
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        NSLog(@"Connection failed - %@", _error);
    } ;
    
    [[Communication sharedManager] GetContacts:[AppDelegate sharedDelegate].sessionId sortby:_sortby search:_search category:_category contactType:_contactType successed:successed failure:failure];
}

- (void)sortContactsByLetters
{
    [contactList removeAllObjects];
    NSMutableDictionary *organizedFriends = [NSMutableDictionary new];
    
    appDelegate.totalList = [appDelegate.totalList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *name1, *name2;
        if ([obj1[@"contact_type"] intValue] == 3) // entity
            name1 = obj1[@"name"];
        else if ([sort isEqualToString:@"first_name"])
            name1 = [NSString stringWithFormat:@"%@%@%@", obj1[@"first_name"], obj1[@"middle_name"], obj1[@"last_name"]];
        else
            name1 = [NSString stringWithFormat:@"%@%@%@", obj1[@"last_name"], obj1[@"middle_name"], obj1[@"first_name"]];
        if ([obj2[@"contact_type"] intValue] == 3) // entity
            name2 = obj2[@"name"];
        else if ([sort isEqualToString:@"first_name"])
            name2 = [NSString stringWithFormat:@"%@%@%@", obj2[@"first_name"], obj2[@"middle_name"], obj2[@"last_name"]];
        else
            name2 = [NSString stringWithFormat:@"%@%@%@", obj2[@"last_name"], obj2[@"middle_name"], obj2[@"first_name"]];
        return [name1 compare:name2 options:NSNumericSearch];
    }];
    
    for (int i = 0; i < [appDelegate.totalList count]; i++)
    {
        NSDictionary *dict = [appDelegate.totalList objectAtIndex:i];
        
        if (filterType == 0) { // entity
            if(!([dict[@"contact_type"] integerValue] == 3 || ([dict[@"contact_type"] integerValue] == 2 && [dict[@"type"] integerValue] == 0)))
                continue;
        } else if (filterType == 1) { // work
            if (!((dict[@"sharing_status"] && ([dict[@"sharing_status"] integerValue] == 2 || [dict[@"sharing_status"] integerValue] == 3)) || ([dict[@"contact_type"] integerValue] == 2 && [dict[@"type"] integerValue] == 2)))
                continue;
        } else if (filterType == 2) { // home
            if (!((dict[@"sharing_status"] && ([dict[@"sharing_status"] integerValue] == 1 || [dict[@"sharing_status"] integerValue] == 3)) || ([dict[@"contact_type"] integerValue] == 2 && [dict[@"type"] integerValue] == 1)))
                continue;
        } else if (filterType == 4){
            if (!(dict[@"is_favorite"] && [dict[@"is_favorite"] boolValue])) {
                continue;
            }
            favoriteCount = favoriteCount + 1;
        }
        
        NSString *tempStr = @"";
        
        if ([dict objectForKey:@"entity_id"]) {
            tempStr = [[[dict objectForKey:@"name"] uppercaseString] substringToIndex:1];
        } else {
            if ([sort isEqualToString:@"first_name"])
            {
                if (![[dict objectForKey:@"first_name"] isEqualToString:@""])
                    tempStr = [[[dict objectForKey:@"first_name"] uppercaseString] substringToIndex:1];
                else if (![[dict objectForKey:@"middle_name"] isEqualToString:@""])
                    tempStr = [[[dict objectForKey:@"middle_name"] uppercaseString] substringToIndex:1];
                else  if (![[dict objectForKey:@"last_name"] isEqualToString:@""])
                    tempStr = [[[dict objectForKey:@"last_name"] uppercaseString] substringToIndex:1];
                else continue;
            }
            else
            {
                if (![[dict objectForKey:@"last_name"] isEqualToString:@""])
                    tempStr = [[[dict objectForKey:@"last_name"] uppercaseString] substringToIndex:1];
                else if (![[dict objectForKey:@"first_name"] isEqualToString:@""])
                    tempStr = [[[dict objectForKey:@"first_name"] uppercaseString] substringToIndex:1];
                else if (![[dict objectForKey:@"middle_name"] isEqualToString:@""])
                    tempStr = [[[dict objectForKey:@"middle_name"] uppercaseString] substringToIndex:1];
                else continue;
            }
        }
        
        NSUInteger index = NSNotFound;
        index = [keyList indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return [[obj lowercaseStringWithLocale:[NSLocale currentLocale]] isEqualToString:[tempStr lowercaseStringWithLocale:[NSLocale currentLocale]]];
        }];
        
        NSString *key;
        if(index == NSNotFound)
        {
            key = @"#";
        } else {
            key = keyList[index];
        }
        
        if(organizedFriends[key])
        {
            [organizedFriends[key] addObject:dict];
        } else {
            organizedFriends[key] = [@[dict] mutableCopy];
        }
    }
    
    for(NSString *key in keyList)
    {
        if(!organizedFriends[key])
            organizedFriends[key] = [@[] mutableCopy];
    }
    
    contactList = organizedFriends;
    
    //from bug
    if (filterType == 3 && ![contactList count]) {
        [tblForContact setHidden:YES];
        [blankView setHidden:NO];
    }
    if ([appDelegate.totalList count] > 0) {
        if (filterType == 4 && favoriteCount == 0){
            [tblForContact setHidden:YES];
            [emptyView setHidden:NO];
        }else{
            [tblForContact setHidden:NO];
            [emptyView setHidden:YES];
            favoriteCount = 0;
        }
    }
}

- (void)updateIsRead: (NSString *)_contactID
        contactType : (NSString *)_contactType
{
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        // NSLog(@"%@",_responseObject);
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        NSLog(@"Connection failed - %@", _error);
    } ;
    
    [[Communication sharedManager] UpdateIsRead:[AppDelegate sharedDelegate].sessionId contactIds:_contactID contactType:_contactType isRead:@"true" successed:successed failure:failure];
}

- (void)GetCBEmailValid
{
    //    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        //        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        //NSLog(@"%@",_responseObject);
        
        NSDictionary *arrCount = [[_responseObject objectForKey:@"data"] objectForKey:@"contact_counts"];
        
        int homeCount = [[arrCount objectForKey:@"home"] intValue];
        int workCount = [[arrCount objectForKey:@"work"] intValue];
        int entityCount = [[arrCount objectForKey:@"entity"] intValue];
        
        if (homeCount > 0)
            [btnHome setEnabled:YES];
        else
            [btnHome setEnabled:NO];
        
        if (workCount > 0)
            [btnWork setEnabled:YES];
        else
            [btnWork setEnabled:NO];
        
        if (entityCount > 0)
            [btnEntity setEnabled:YES];
        else
            [btnEntity setEnabled:NO];
        
        appDelegate.bValid = [[[_responseObject objectForKey:@"data"] objectForKey:@"all_cb_valid"] boolValue];
        appDelegate.newChatNum = [[[_responseObject objectForKey:@"data"] objectForKey:@"new_chat_msg_num"] intValue];
        appDelegate.notExchangeNum = [[[_responseObject objectForKey:@"data"] objectForKey:@"not_xcg_sprout_num"] intValue];
        appDelegate.xchageReqNum = [[[_responseObject objectForKey:@"data"] objectForKey:@"xcg_req_num"] intValue];
        [self showCountNum];
        
        //        [self sortContactsByLetters];
        //        [tblForContact reloadData];
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        NSLog(@"Connection failed - %@", _error);
    } ;
    
    [[Communication sharedManager] GetCBEmailValid:[AppDelegate sharedDelegate].sessionId successed:successed failure:failure];
}

- (void)showCountNum
{
    if (appDelegate.bValid)
        [imgViewInvalid setHidden:YES];
    else
        [imgViewInvalid setHidden:NO];
    
    lblChatBadge.text = [NSString stringWithFormat:@"%d", appDelegate.newChatNum];
    lblSproutBadge.text = [NSString stringWithFormat:@"%d", appDelegate.notExchangeNum];
    lblExchangeBadge.text = [NSString stringWithFormat:@"%d", appDelegate.xchageReqNum];
    
    if (appDelegate.newChatNum > 0) {
        viewChatBadge.hidden = NO;
    } else viewChatBadge.hidden = YES;
    
    if (appDelegate.notExchangeNum > 0) {
        viewSproutBadge.hidden = NO;
    } else {
        viewSproutBadge.hidden = YES;
    }
    if (appDelegate.xchageReqNum > 0) {
        viewExchangeBadge.hidden = NO;
    } else viewExchangeBadge.hidden = YES;
}

#pragma mark - Sprout action
- (IBAction)touchDownThumb:(id)sender {
    [progressVC presentWindow];
    appDelegate.thumbDown = YES;
    //    appDelegate.notCallFlag = YES;
    //    appDelegate.isGPSOn = NO;
    //    [appDelegate performSelector:@selector(touchThumb) withObject:nil afterDelay:0.5f];
    
    gpsBut.selected = YES;
    _thumbButton.enabled = NO;
    //[self performSelector:@selector(printDetectedCotnact) withObject:nil waitUntilDone:1.0f];
    
    [self performSelector:@selector(printDetectedCotnact) withObject:nil afterDelay:1.0f];
}

-(void)printDetectedCotnact{
    appDelegate.isGPSOn = NO;
    if (appDelegate.thumbDown) {
        void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
            
            
            if ([[_responseObject objectForKey:@"success"] boolValue])
            {
                [_gpsCallTimerForThumbPrint invalidate];
                _gpsCallTimerForThumbPrint = nil;
                if (appDelegate.thumbDown) {
                    [_locationManagerForThumbPrint startUpdatingLocation];
                    _gpsCallTimerForThumbPrint = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(repeatUpdatingForThumbPrint) userInfo:nil repeats:YES];
                    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"INTERVAL_INDEX"];
                    
                    [CommonMethods loadDetectedContacts];
                    appDelegate.isGPSOn = YES;
                }
                
            }
        } ;
        
        void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
            [SVProgressHUD dismiss];
            [self printDetectedCotnact];
            NSLog(@"Change GPS Status failed");
        } ;
        
        [[Communication sharedManager] ChangeGPSStatus:[AppDelegate sharedDelegate].sessionId trun_on:@"true" successed:successed failure:failure];
    }
}
- (void) repeatUpdatingForThumbPrint{
    if (appDelegate.thumbDown) {
        [_locationManagerForThumbPrint startUpdatingLocation];
    }else{
        [_gpsCallTimerForThumbPrint invalidate];
        _gpsCallTimerForThumbPrint = nil;
    }
}
- (IBAction)touchUpThumb:(id)sender {
    [progressVC hideWindow];
    appDelegate.thumbDown = NO;
    //    if (appDelegate.notCallFlag) {
    //        [NSObject cancelPreviousPerformRequestsWithTarget:appDelegate selector:@selector(touchThumb) object:nil];
    //        return;
    //    }
    //    if (appDelegate.isGPSOn) {
    //        [appDelegate changeGPSSetting:0];
    //        appDelegate.isGPSOn = NO;
    //    }
    //    appDelegate.isGPSOn = YES;
    //    [appDelegate GetContactList]; // refresh contact list once after thumb is up
    
    [_gpsCallTimerForThumbPrint invalidate];
    _gpsCallTimerForThumbPrint = nil;
    
    //if (appDelegate.isGPSOn) {
    [self offGPS];
    appDelegate.isGPSOn = NO;
    //}
}
- (void) offGPS{
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        
        
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"INTERVAL_INDEX"];
            
            gpsBut.selected = NO;
            _thumbButton.enabled = YES;
            [appDelegate GetContactList];
            appDelegate.locationFlag = NO;
            //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GPSSETTING_CHANGED object:nil];
            
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [SVProgressHUD dismiss];
        [self offGPS];
        NSLog(@"Change GPS Status failed");
    } ;
    
    [[Communication sharedManager] ChangeGPSStatus:[AppDelegate sharedDelegate].sessionId trun_on:@"false" successed:successed failure:failure];
    
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation *location = locations.lastObject;
    
    [_locationManagerForThumbPrint stopUpdatingLocation];
    
    if (appDelegate.thumbDown && callFuncForUpdatingUserlocation) {
        callFuncForUpdatingUserlocation = NO;
        appDelegate.currentLocation = location.coordinate;
        void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
            
            if ([[_responseObject objectForKey:@"success"] boolValue])
            {
                callFuncForUpdatingUserlocation = YES;
                [appDelegate GetContactList];
            }
        } ;
        
        void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
            
            callFuncForUpdatingUserlocation = YES;
            NSLog(@"Connection Error - %@", _error);
        } ;
        
        [[Communication sharedManager] SetUpdateLocation:appDelegate.sessionId longitude:[NSString stringWithFormat:@"%f", appDelegate.currentLocation.longitude] latitude:[NSString stringWithFormat:@"%f", appDelegate.currentLocation.latitude] successed:successed failure:failure];
        
    }
}
- (void)displayGPSButton
{
    if (appDelegate.locationFlag)
    {
        gpsBut.selected = YES;
        _thumbButton.enabled = NO;
    }
    else {
        gpsBut.selected = NO;
        _thumbButton.enabled = YES;
    }
}

// received contacts
- (void)receiveContactListNotification:(NSNotification *) notification
{
    //[self reloadContacts];
    if (appDelegate.thumbDown) {
        NSDictionary * dict = notification.userInfo;
        if(dict && dict[@"NotExchangedList"] && [dict[@"NotExchangedList"] isKindOfClass:[NSArray class]] && [dict[@"NotExchangedList"] count] > 0) {
            if (dict[@"FoundNew"]) {
                //self.navigationItem.title = @"";
                //TabBarController *tabBarController = [TabBarController sharedController];
                //tabBarController.selectedIndex = 1;
                // Push;
                [progressVC hideWindow];
                //[self.navigationController pushViewController:tabBarController animated:YES];
                UIViewController *nav = [SB_GINKOME instantiateViewControllerWithIdentifier:@"GinkoMeNav"];
                [AppDelegate sharedDelegate].isNewContactFind = YES;
                [self presentViewController:nav animated:YES completion:nil];
                [self touchUpThumb:self];
                
                if (appDelegate.isGPSOn) { // turn off gps if found
                    [appDelegate changeGPSSetting:0];
                    appDelegate.isGPSOn = NO;
                }
            }
        }
    } else if (appDelegate.isGPSOn) { // if thumb is up, turn off gps
        [appDelegate changeGPSSetting:0];
        appDelegate.isGPSOn = NO;
    }
}

#pragma mark -
#pragma mark - NSFetchedResultsController

- (void)performFetch {
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        return;
        //        exit(-1);  // Fail
    }
    NSArray *results = self.fetchedResultsController.fetchedObjects;
    //appDelegate.notExchangeNum = results.count;
    [self showCountNum];
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    _fetchedResultsController = [SearchedContact frcForContacts];
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    //    NSLog(@"GinkoMe controllerDidChangeContent");
    [self performFetch];
}
@end
