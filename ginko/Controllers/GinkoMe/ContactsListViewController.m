//
//  ContactsListViewController.m
//  ginko
//
//  Created by ccom on 1/8/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "ContactsListViewController.h"
#import "ProfileViewController.h"
#import "ProfileRequestController.h"
#import "YYYCommunication.h"
#import "YYYChatViewController.h"
#import "EntityViewController.h"
#import "PreviewProfileViewController.h"
#import <objc/runtime.h>
#import "MainEntityViewController.h"
#import "VideoVoiceConferenceViewController.h"

@interface ContactsListViewController ()<UIGestureRecognizerDelegate>

@end
static NSString * const ExchangedInfoCellIdentifier = @"ExchangedInfoCell";
static NSString * const NotExchangedInfoCellIdentifier = @"NotExchangedInfoCell";
static NSString * const EntityCellIdentifier = @"EntityCell";

#define AssociatingKey @"AssociatingKey"


@implementation ContactsListViewController {
    BOOL showingContacts;
    BOOL isEditing;
    GinkoMeTabController *tabController;
    NSArray *contacts;
    NSArray *greys;
    NSString *searchWord;
    
    BOOL isSearchBarSelected;
    
    UIActionSheet *disWithConferenceCallingActionSheet;
}
@synthesize contactsTableView;
@synthesize greyTableView;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
    
    // back button will not have title
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    UISwipeGestureRecognizer *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    [leftSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [contactsTableView addGestureRecognizer:leftSwipeRecognizer];
    
    UISwipeGestureRecognizer *rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    [rightSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [greyTableView addGestureRecognizer:rightSwipeRecognizer];
    
    leftSwipeRecognizer.delegate = self;
    rightSwipeRecognizer.delegate = self;
    
    isSearchBarSelected = NO;
}
- (void)swipeLeft:(id)sender
{
    if (self.greysButton.enabled && !isSearchBarSelected) {
        [self btGreysClick:self];
    }
    
}

- (void)swipeRight:(id)sender
{
    if (self.contactsButton.enabled && !isSearchBarSelected) {
        [self btContactsClick:self];
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    tabController.cDelegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    [self onClose:nil];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeCurrentActionWhenConferenceView) name:CLOSE_ALERT_WHEN_CONFERENCEVIEW_NOTIFICATION object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CLOSE_ALERT_WHEN_CONFERENCEVIEW_NOTIFICATION object:nil];
}
#pragma mark -
#pragma mark - Function

- (void)initialize {
    contactsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    greyTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [contactsTableView registerNib:[UINib nibWithNibName:ExchangedInfoCellIdentifier bundle:nil] forCellReuseIdentifier:ExchangedInfoCellIdentifier];
    [greyTableView registerNib:[UINib nibWithNibName:NotExchangedInfoCellIdentifier bundle:nil] forCellReuseIdentifier:NotExchangedInfoCellIdentifier];
    [greyTableView registerNib:[UINib nibWithNibName:EntityCellIdentifier bundle:nil] forCellReuseIdentifier:EntityCellIdentifier];
    contactsTableView.backgroundView = self.contactsBgView;
    greyTableView.backgroundView = self.greyBgView;
    tabController = (GinkoMeTabController*)self.tabBarController;
    [tabController.closeButton addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
    [tabController.trashButton addTarget:self action:@selector(onTrash:) forControlEvents:UIControlEventTouchUpInside];
    
    searchWord = @"";
    [self reloadTables];
    [self viewSwitched];
    [self initializeSelectedIndexPaths];
}

- (void)viewSwitched {
    self.contactsTableView.hidden = !showingContacts;
    self.contactsIndicator.hidden = !showingContacts;
    self.greyTableView.hidden = showingContacts;
    self.greysIndicator.hidden = showingContacts;
    self.titleLabel.text = (showingContacts) ? @"Contacts around town" : @"Exchange info with these contacts";
//    _lblNoContact.text = (showingContacts) ? @"Sorry no contacts detected around town." : @"Sorry no potential contacts detected.";
    if (showingContacts) {
        if ([contacts count] == 0){
            contactsTableView.backgroundView = self.contactsBgView;
            _contactsBgView.hidden = NO;
            _btnEdit.enabled = NO;
        }
        else{
            contactsTableView.backgroundView = nil;
            _contactsBgView.hidden = YES;
            _btnEdit.enabled =YES;
        }
    }else
        if ([greys count] == 0) {
            greyTableView.backgroundView = self.greyBgView;
            _greyBgView.hidden = NO;
            _btnEdit.enabled = NO;
        }else{
            greyTableView.backgroundView = nil;
            _greyBgView.hidden = YES;
            _btnEdit.enabled = YES;
        }
}

- (void)editingStatusChanged {
    [contactsTableView setEditing:isEditing animated:YES];
    [greyTableView setEditing:isEditing animated:YES];
    [tabController setEditMode:isEditing];
    [self initializeSelectedIndexPaths];
}

- (void)reloadTables {
    NSMutableArray *contactsTmp = [[NSMutableArray alloc] init];
    NSMutableArray *greysTmp = [[NSMutableArray alloc] init];
    for (SearchedContact *oneForContact in [tabController.contacts mutableCopy]) {
        if (oneForContact.contact.data) {
            [contactsTmp addObject:oneForContact];
        }
    }
    
    contacts = [contactsTmp copy];
    greys = tabController.greys;
    if (showingContacts) {
        if ([contacts count] == 0 ){
           _btnEdit.enabled = NO;
            if (isEditing) {
                isEditing = NO;
                [self editingStatusChanged];
            }
        }
        else{
            if (isEditing) {
                _btnEdit.enabled = NO;
            }else{
                _btnEdit.enabled = YES;
            }
        }
    }else{
        if ([greys count] == 0){
            _btnEdit.enabled = NO;
            if (isEditing) {
                isEditing = NO;
                [self editingStatusChanged];
            }
        }
        else {
            if (isEditing) {
                _btnEdit.enabled = NO;
            }else{
                _btnEdit.enabled = YES;
            }
        }
    }
    if (searchWord.length) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"((first_name CONTAINS[c] %@) OR (last_name CONTAINS[c] %@))", searchWord, searchWord];
        contacts = [contacts filteredArrayUsingPredicate:pred];
        greys = [greys filteredArrayUsingPredicate:pred];
    }
    if (showingContacts) {
        if ([contacts count] == 0){
            _btnEdit.enabled = NO;
            contactsTableView.backgroundView = self.contactsBgView;
            _contactsBgView.hidden = NO;
        }
        else{
            if (isEditing) {
                _btnEdit.enabled = NO;
            }else{
                _btnEdit.enabled = YES;
            }
            contactsTableView.backgroundView = nil;
            _contactsBgView.hidden = YES;
        }
    }else
        if ([greys count] == 0) {
            _btnEdit.enabled = NO;
            greyTableView.backgroundView = self.greyBgView;
            _greyBgView.hidden = NO;
        }else{
            if (isEditing) {
                _btnEdit.enabled = NO;
            }else{
                _btnEdit.enabled = YES;
            }
            greyTableView.backgroundView = nil;
            _greyBgView.hidden = YES;
        }
    [self.contactsTableView reloadData];
    [self.greyTableView reloadData];
}



- (void)getContactDetail : (NSString *)_contactId {
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    [[Communication sharedManager] getContactDetail:[AppDelegate sharedDelegate].sessionId contactId:_contactId contactType:@"1" successed:^(id _responseObject) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            NSDictionary *dict = [_responseObject objectForKey:@"data"];
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
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSDictionary *dictError = [_responseObject objectForKey:@"err"];
            if (dictError) {
                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:[dictError objectForKey:@"errMsg"]];
                if ([[NSString stringWithFormat:@"%@",[dictError objectForKey:@"errCode"]] isEqualToString:@"350"]) {
                     [[AppDelegate sharedDelegate] GetContactList];
                }
            } else {
                [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Failed to connect to server!"];
            }
        }
    } failure:^(NSError *err) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
    }];
}

-(void)CreateMessageBoard:(NSString*)ids dict:(NSDictionary *)contactInfo {
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

- (SearchedContact*)contactFromIndexPath:(NSIndexPath*)iPath ofTableView:(UITableView*)tableView {
    SearchedContact *contact = nil;
    if ([tableView isEqual:self.contactsTableView]) {
        contact = contacts[iPath.row];
    }
    else if ([tableView isEqual:self.greyTableView]) {
        contact = greys[iPath.row];
    }
    return contact;
}

#pragma mark Data attaching to TableView

- (void)initializeSelectedIndexPaths {
    NSMutableSet *ids1 = [NSMutableSet set];
    objc_setAssociatedObject(self.contactsTableView, AssociatingKey, ids1, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSMutableSet *ids2 = [NSMutableSet set];
    objc_setAssociatedObject(self.greyTableView, AssociatingKey, ids2, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)addSelectedIndexPath:(NSIndexPath*)iPath ofTableView:(UITableView*)tableView {
    SearchedContact *contact = [self contactFromIndexPath:iPath ofTableView:tableView];
    NSMutableSet *ids = [objc_getAssociatedObject(tableView, AssociatingKey) mutableCopy];
    [ids addObject:contact.contact_id];
    objc_setAssociatedObject(tableView, AssociatingKey, ids, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)removeDeselectedIndexPath:(NSIndexPath*)iPath ofTableView:(UITableView*)tableView {
    SearchedContact *contact = [self contactFromIndexPath:iPath ofTableView:tableView];
    NSMutableSet *ids = [objc_getAssociatedObject(tableView, AssociatingKey) mutableCopy];
    [ids removeObject:contact.contact_id];
    objc_setAssociatedObject(tableView, AssociatingKey, ids, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isSelectedIndexPath:(NSIndexPath*)iPath inTableView:(UITableView*)tableView {
    SearchedContact *contact = [self contactFromIndexPath:iPath ofTableView:tableView];
    NSMutableSet *ids = [objc_getAssociatedObject(tableView, AssociatingKey) mutableCopy];
    return [ids containsObject:contact.contact_id];
}

#pragma mark -
#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    if ([tableView isEqual:self.contactsTableView]) {
        count = contacts.count;
        self.noContactsLabel.hidden = count;
    }
    else if ([tableView isEqual:self.greyTableView]) {
        count = greys.count;
        self.noGreysLabel.hidden = count;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL toSelect = tableView.isEditing && [self isSelectedIndexPath:indexPath inTableView:tableView];
    if (toSelect) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    if ([tableView isEqual:self.contactsTableView]) {
        SearchedContact *contact = contacts[indexPath.row];
        if (![contact.contact_type isEqualToNumber:@(3)]) {
            ExchangedInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExchangedInfoCell"];
            [cell populateCellWithContact:contact];
            //NSLog(@"cell---%@",contact);
            cell.delegate = self;
            return cell;
        }
    }
    else if ([tableView isEqual:self.greyTableView]) {
        SearchedContact *contact = greys[indexPath.row];
        //NSLog(@"cell--%@",contact);
        if ([contact.contact_type isEqualToNumber:@(3)]) {
            NSDictionary *dict = [contact getDataDictionary];
            EntityCell *cell = [tableView dequeueReusableCellWithIdentifier:EntityCellIdentifier];
            cell.delegate = self;
            cell.curDict = dict;
            cell.isFollowing = NO;
            return cell;
        }
        NotExchangedInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotExchangedInfoCell"];
        [cell populateCellWithContact:contact];
        cell.delegate = self;
        return cell;
    }
    return nil;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.editing) {
        tabController.trashButton.enabled = YES;
        [self addSelectedIndexPath:indexPath ofTableView:tableView];
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SearchedContact *contact = [self contactFromIndexPath:indexPath ofTableView:tableView];
    if ([tableView isEqual:self.contactsTableView]) {
        if ([contact.sharing_status integerValue] == 4) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"GINKO" message:@"Oops! Contact would like to chat only" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alertView show];
            return;
        }
        [self getContactDetail:[contact.contact_id stringValue]];
    }
    else if ([tableView isEqual:self.greyTableView]) {
        NSDictionary *dict = [contact getDataDictionary];
        if ([contact.contact_type isEqualToNumber:@(3)]) {
//            [self getEntityFollowerView:[contact.contact_id stringValue] following:NO notes:[dict objectForKey:@"notes"]];
            BOOL isFollowing = [[dict objectForKey:@"invite_status"] intValue];
            [self getEntityFollowerView:[dict objectForKey:@"entity_id"] following:isFollowing notes:[dict objectForKey:@"notes"]];
        }
        else {
            if ([[dict objectForKey:@"is_pending"] boolValue]) {
                APPDELEGATE.type = 2;
            }else{
                APPDELEGATE.type = 5;
            }
            ProfileViewController * controller = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
            controller.contactInfo = dict;
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self removeDeselectedIndexPath:indexPath ofTableView:tableView];
    NSArray *selectedRows = [tableView indexPathsForSelectedRows];
    tabController.trashButton.enabled = selectedRows.count;
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


#pragma mark -
#pragma mark - ExchangedInfoCell Delegate
- (void)didCallVideo:(NSDictionary *)contactDict{
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
- (void)hideKeyBoard{
    [self.searchBar endEditing:NO];
    [self.searchBar setShowsCancelButton:NO animated:YES];
}
- (void)didChat:(NSDictionary *)contactDict {
    [self CreateMessageBoard:[contactDict objectForKey:@"contact_id"] dict:contactDict];
}
- (void)didPhone:(UIActionSheet *)actionSheet{
    disWithConferenceCallingActionSheet = actionSheet;
}
- (void)closeCurrentActionWhenConferenceView{
    if (disWithConferenceCallingActionSheet) {
        [disWithConferenceCallingActionSheet dismissWithClickedButtonIndex:-1 animated:YES];
    }
}
- (void)didEdit:(NSDictionary *)contactDict {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.type = 4;
    
    if ([contactDict objectForKey:@"detected_location"] && ![[contactDict objectForKey:@"detected_location"] isEqualToString:@""])
    {
        ProfileViewController * controller = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
        controller.contactInfo = contactDict;
        [self.navigationController pushViewController:controller animated:YES];
    }else{
        ProfileRequestController * controller = [[ProfileRequestController alloc] initWithNibName:@"ProfileRequestController" bundle:nil];
        controller.contactInfo = contactDict;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark -
#pragma mark - Action

- (IBAction)onViewSwitched:(UIButton*)but {
    if (isEditing) {
        return;
    }
    showingContacts = [but isEqual:self.contactsButton];
    [self viewSwitched];
}
- (IBAction)btContactsClick:(id)sender {
    showingContacts = YES;
    if (showingContacts) {
        if ([contacts count] == 0 ) _btnEdit.enabled = NO;
        else _btnEdit.enabled = YES;
    }else{
        if ([greys count] == 0) _btnEdit.enabled = NO;
        else _btnEdit.enabled = YES;
    }
    if (isEditing) {
        return;
    }
    if (!contactsTableView.hidden) {
        return;
    }
    if ([contacts count] == 0){
        contactsTableView.backgroundView = self.contactsBgView;
        _contactsBgView.hidden = NO;
    }
    else{
        contactsTableView.backgroundView = nil;
        _contactsBgView.hidden = YES;
    }
    
    
    self.contactsTableView.hidden = NO;
    self.contactsIndicator.hidden = NO;
    self.greyTableView.hidden = YES;
    self.greysIndicator.hidden = YES;
    self.titleLabel.text = @"Contacts around town";
    
    CATransition *animation = [CATransition animation];
    [animation setDelegate:self];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromLeft];
    [animation setDuration:0.50];
    [animation setTimingFunction:
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [contactsTableView.layer addAnimation:animation forKey:kCATransition];
    [greyTableView.layer addAnimation:animation forKey:kCATransition];
    //[_lblNoContact.layer addAnimation:animation forKey:kCATransition];
}

- (IBAction)btGreysClick:(id)sender {
    showingContacts = NO;
    if (showingContacts) {
        if ([contacts count] == 0 ) _btnEdit.enabled = NO;
        else _btnEdit.enabled = YES;
    }else{
        if ([greys count] == 0) _btnEdit.enabled = NO;
        else _btnEdit.enabled = YES;
    }
    if (isEditing) {
        return;
    }
    if (contactsTableView.hidden) {
        return;
    }
    if ([greys count] == 0) {
        greyTableView.backgroundView = self.greyBgView;
        _greyBgView.hidden = NO;
    }else{
        greyTableView.backgroundView = nil;
        _greyBgView.hidden =YES;
    }
    self.contactsTableView.hidden = YES;
    self.contactsIndicator.hidden = YES;
    self.greyTableView.hidden = NO;
    self.greysIndicator.hidden = NO;
    self.titleLabel.text = @"Exchange info with these contacts";
    
    CATransition *animation = [CATransition animation];
    [animation setDelegate:self];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromRight];
    [animation setDuration:0.50];
    [animation setTimingFunction:
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [greyTableView.layer addAnimation:animation forKey:kCATransition];
    [contactsTableView.layer addAnimation:animation forKey:kCATransition];
    //[_lblNoContact.layer addAnimation:animation forKey:kCATransition];
    
}
- (IBAction)onEdit:(id)sender {
    if (showingContacts) {
        if ([contacts count] == 0 ) return;
    }else{
        if ([greys count] == 0) return;
    }
    isEditing = YES;
    [self editingStatusChanged];
    _btnEdit.enabled = NO;
}

- (void)onClose:(id)sender {
    isEditing = NO;
    tabController.trashButton.enabled = NO;
    _btnEdit.enabled = YES;
    [self editingStatusChanged];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView tag] == 1001)
    {
        if (buttonIndex != alertView.cancelButtonIndex) {
            NSArray *selectedRows = [self.contactsTableView indexPathsForSelectedRows];
            
            
            NSString *contactIds = @"";
            NSString *entityIds = @"";
            NSMutableArray *deletedContacts = [NSMutableArray array];
            for (int i = (int)[selectedRows count] - 1 ; i >= 0  ; i--)
            {
                NSIndexPath * selectRow = [selectedRows objectAtIndex:i];
                SearchedContact *contact = [contacts objectAtIndex:selectRow.row];
                [deletedContacts addObject:contact];
                if (![contactIds isEqualToString:@""])
                {
                    contactIds = [NSString stringWithFormat:@"%@,", contactIds];
                }
                contactIds = [NSString stringWithFormat:@"%@%@", contactIds, contact.contact_id];
            }
            
            void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
                [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
                if ([[_responseObject objectForKey:@"success"] boolValue]) {
                    for (SearchedContact *con in deletedContacts) {
                        [MOC deleteObject:con];
                    }
                    [[AppDelegate sharedDelegate] saveContext];
                    [self reloadTables];
                    [self viewSwitched];
                    
                }
            } ;
            
            void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
                [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
            };
            
            if (![contactIds isEqualToString:@""] || ![entityIds isEqualToString:@""]) {
                [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
                [[Communication sharedManager] RemoveContactSelected:[AppDelegate sharedDelegate].sessionId contactIds:contactIds successed:successed failure:failure];
            }

        }
    }
}
- (void)onTrash:(id)sender {
    [self.searchBar  resignFirstResponder];
    if (showingContacts) {
        NSArray *selectedRows = [self.contactsTableView indexPathsForSelectedRows];
        NSString *msg = @"";
        if ([selectedRows count] > 1) {
            msg = @"Do you want to remove contacts?";
        }else{
            msg = @"Do you want to remove a contact?";
        }
        UIAlertView *alertViewforError = [[UIAlertView alloc] initWithTitle:APP_TITLE message:msg delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES",nil];
        alertViewforError.tag = 1001;
        [alertViewforError show];
        
    }else{
        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"Delete Ginko Contact(s)" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Delete contact(s) permanently", @"Delete contact(s) for 24 hours", nil];
        actionSheet.delegate = self;
        [actionSheet showFromTabBar:[[self tabBarController] tabBar]];
    }
}

#pragma mark -
#pragma mark - UISearchBar Delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    isSearchBarSelected = YES;
}
- (void)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:NO animated:YES];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    searchWord = searchText;
    [self reloadTables];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:YES];
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    searchWord = searchBar.text;
    isSearchBarSelected = NO;
    [self reloadTables];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar endEditing:YES];
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    if (!searchBar.text.length) {
        isSearchBarSelected = NO;
        return;
    }
    searchBar.text = @"";
    searchWord = @"";
    isSearchBarSelected = NO;
    [self reloadTables];
}




#pragma mark -
#pragma mark - GinkoMeTabDelegate

- (void)updated:(NSArray *)contacts greys:(NSArray *)greys{
    //if (!isEditing) {
        [self reloadTables];
    //}
}

- (void)updateTableView{
    //if (!isEditing) {
        [self reloadTables];
    //}
}
- (void) malloc{
    
    tabController = nil;
    tabController.cDelegate = nil;
}

#pragma mark -
#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UITableView *tableView = (showingContacts) ? self.contactsTableView : self.greyTableView;
    NSArray *contactArray = (showingContacts) ? contacts : greys;
    NSArray *selectedRows = [tableView indexPathsForSelectedRows];
    
    NSString *remove_type;
    
    if (buttonIndex == 0)
    {
        remove_type = @"1";
    }
    else if (buttonIndex == 1)
    {
        remove_type = @"2";
    }
    else
    {
        return;
    }
    
    NSString *contactIds = @"";
    NSString *entityIds = @"";
    NSMutableArray *deletedContacts = [NSMutableArray array];
    for (int i = (int)[selectedRows count] - 1 ; i >= 0  ; i--)
    {
        NSIndexPath * selectRow = [selectedRows objectAtIndex:i];
        SearchedContact *contact = [contactArray objectAtIndex:selectRow.row];
        [deletedContacts addObject:contact];
        if ([contact.contact_type integerValue] != 3) {
            if (![contactIds isEqualToString:@""])
            {
                contactIds = [NSString stringWithFormat:@"%@,", contactIds];
            }
            contactIds = [NSString stringWithFormat:@"%@%@", contactIds, contact.contact_id];
        } else {
            if (![entityIds isEqualToString:@""])
            {
                entityIds = [NSString stringWithFormat:@"%@,", entityIds];
            }
            entityIds = [NSString stringWithFormat:@"%@%@", entityIds, contact.contact_id];
        }
    }
    
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        if ([[_responseObject objectForKey:@"success"] boolValue]) {
            for (SearchedContact *con in deletedContacts) {
                [MOC deleteObject:con];
            }
            [[AppDelegate sharedDelegate] saveContext];
            [self reloadTables];
            [self viewSwitched];
            
        }
    };
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
    };
    
    if (![contactIds isEqualToString:@""] || ![entityIds isEqualToString:@""]) {
        [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
        [[Communication sharedManager] DeleteDetectedContacts:[AppDelegate sharedDelegate].sessionId userIDs:contactIds entityIDs:entityIds remove_type:remove_type successed:successed failure:failure];
    }
    
    [self onClose:nil];
}
@end
