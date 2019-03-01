//
//  YYYChatViewController.m
//  InstantMessenger
//
//  Created by Wang MeiHua on 2/28/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import "YYYChatViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIBubbleTableView.h"
#import "UIBubbleTableViewDataSource.h"
#import "NSBubbleData.h"
#import "YYYLocationController.h"
#import "MBProgressHUD.h"
#import "YYYCommunication.h"
#import "AppDelegate.h"
#import "NSString+Utils.h"
#import "YYYMapViewController.h"
#import "YYYImageViewController.h"
#import "YYYVideoViewController.h"
#import "SVGeocoder.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "SVPullToRefresh.h"
#import "Reachability.h"
#import <AddressBook/AddressBook.h>
#import "UIImageView+AFNetworking.h"
#import "PreviewProfileViewController.h"
#import "IMPhotoPickerController.h"
#import "IMVideoPickerController.h"

#import "VideoVoiceConferenceViewController.h"

#import "LocalDBManager.h"
#import "SelectUserForConferenceViewController.h"

#define BUTTON_FONT_SIZE 32
#define EMOJICOL			7
#define EMOJIROW			3
#define BUTTON_WIDTH 45
#define BUTTON_HEIGHT 37

@interface YYYChatViewController () <IMPhotoPickerControllerDelegate,IMVideoPickerControllerDelegate, UIActionSheetDelegate>
{
    BOOL keyboardShown;
    
    BOOL isLoadingMessages;             // loading previous messages(top)
    BOOL isLoadingNewMessages;          // loading new messages(bottom)
    
    MBProgressHUD *downloadProgressHUD; // Download progress hud for video
    
    NSBubbleContentType longPressedDataType;    // Save the type for long pressed bubble (video, photo, voice)
    NSString *longPressedDataPath;              // Save the data path for long pressed bubble
    
    BOOL isShownBoard; //when show chatboard, this is set once
    BOOL getNewmessage;
    
    BOOL isRecording;
    
    NSString *tmpTextMessage;
    
    NSString *videoCallEmoji;
    NSString *voiceCallEmoji;
    
    UIView *callingView;
    
    UIActionSheet *tmpAcntionSheet;
    
    NSMutableArray *arrPhone;
}
@end

@implementation YYYChatViewController

@synthesize emojis;
@synthesize boardid;
@synthesize lstUsers, conferencelstUsers;
@synthesize playerVC;
@synthesize reachability;
@synthesize isMemberForDiectory, isDirectory, isFromChatHistory;
@synthesize isPushedFromConference, isAbleVideoConference;
@synthesize availableUsers;
@synthesize fromHistoryGroupDic;

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
    
    
    bFirstLoad = YES;
    lstMsgId = [NSMutableArray new];
    
    bConnection = YES;
    
    isShownBoard = YES;
    getNewmessage = NO;
    
    isRecording = NO;
    
    tmpTextMessage = @"";
    
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    self.navigationController.navigationBar.translucent = NO;
    UIView *viewFortitle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    lblTitle = [[UILabel alloc] initWithFrame:viewFortitle.bounds];
    [viewFortitle addSubview:lblTitle];
    lblTitle.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapTitleView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTitleView)];
    [lblTitle addGestureRecognizer:tapTitleView];
    [self.navigationItem setTitleView:viewFortitle];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.font = [UIFont boldSystemFontOfSize:17.0f];
    lblTitle.textColor = [UIColor colorWithRed:23/255.0f green:64/255.0f blue:38/255.0f alpha:1.0f];
    
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"MyAudioMemo.m4a",
                               nil];
    audioURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:audioURL settings:recordSetting error:NULL];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
    //
    
    UIButton *_btContact = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btContact setFrame:CGRectMake(0, 0, 44, 28)];
    //	[_btContact setImage:[UIImage imageNamed:@"img_groupp"] forState:UIControlStateNormal];
    //	[_btContact addTarget:self action:@selector(btContactClick:) forControlEvents:UIControlEventTouchUpInside];
    btContact = [[UIBarButtonItem alloc] initWithCustomView:_btContact];
    if (_navBarColor) {
        [self.navigationController.navigationBar setBarTintColor:COLOR_GREEN_THEME];
    }
    btBack = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"BackArrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(btBackClick:)];
    
    btClose = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"close"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(btCloseClick:)];
    
    btCloseKeyboard = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"close"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(btCloseChatClick:)];
    
    
    callingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    UIButton *_btVideoCalling = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btVideoCalling setFrame:CGRectMake(0, 10, 25, 25)];
    [_btVideoCalling setImage:[UIImage imageNamed:@"videocalling"] forState:UIControlStateNormal];
    [_btVideoCalling addTarget:self action:@selector(btOpenVideoCallingClick:) forControlEvents:UIControlEventTouchUpInside];
    //[callingView addSubview:_btVideoCalling];
    UIButton *_btVoiceCalling = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btVoiceCalling setFrame:CGRectMake(35, 10, 25, 25)];
    [_btVoiceCalling setImage:[UIImage imageNamed:@"voicecalling"] forState:UIControlStateNormal];
    [_btVoiceCalling addTarget:self action:@selector(btOpenVoiceCallingClick:) forControlEvents:UIControlEventTouchUpInside];
    [callingView addSubview:_btVoiceCalling];
    btVideoCalling = [[UIBarButtonItem alloc] initWithCustomView:callingView];
    
    
    
    
    
    
    //btVideoCalling = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"videocalling"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(btOpenVideoCallingClick:)];
    
    //btVoiceCalling = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"voicecalling"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(btOpenVoiceCallingClick:)];
    
    [self.navigationItem setLeftBarButtonItem:btBack];
    [self.navigationItem setRightBarButtonItem:btVideoCalling];
    
    UIButton *_btCloseEdit = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btCloseEdit setFrame:CGRectMake(0, 0, 14, 14)];
    [_btCloseEdit setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [_btCloseEdit addTarget:self action:@selector(btCloseEditClick:) forControlEvents:UIControlEventTouchUpInside];
    btCloseEdit = [[UIBarButtonItem alloc] initWithCustomView:_btCloseEdit];
    
    btClear = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"Truck"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(btClearClick:)];
    
    bubbleData = [NSMutableArray new];
    bubbleTable.bubbleDataSource = self;
    bubbleTable.snapInterval = 120;
    bubbleTable.showAvatars = YES;
    bubbleTable.bubbledelegate = self;
    
    [vwEmoItem setHidden:YES];
    
    [btSend setHidden:YES];
    btSend.enabled = NO;
    btWrite.enabled = NO;
    //[vwEmoticon setHidden:YES];
    [btRecording setHidden:YES];
    
    vwPhoto = [[UIView alloc] initWithFrame:[AppDelegate sharedDelegate].window.frame];
    imvPhoto = [[UIImageView alloc] initWithFrame:vwPhoto.frame];
    
    [vwPhoto addSubview:imvPhoto];
    [imvPhoto setBackgroundColor:[UIColor blackColor]];
    imvPhoto.contentMode = UIViewContentModeScaleAspectFit;
    
    UIButton *btDone = [UIButton buttonWithType:UIButtonTypeCustom];
    [btDone setTitle:@"Done" forState:UIControlStateNormal];
    [btDone.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [btDone setFrame:CGRectMake(250, 30, 50, 30)];
    [btDone addTarget:self action:@selector(btPhotoDoneClick:) forControlEvents:UIControlEventTouchUpInside];
    [vwPhoto addSubview:btDone];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    [bubbleTable addGestureRecognizer:tapGesture];
    
    //Read Emoji
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"EmojisList"
                                                          ofType:@"plist"];
    emojis = [[NSDictionary dictionaryWithContentsOfFile:plistPath] copy];
    
    voiceCallEmoji = [[emojis objectForKey:@"Objects"] objectAtIndex:32];
    videoCallEmoji = [[emojis objectForKey:@"Objects"] objectAtIndex:23];
    [self makeEmoji:0];
    
    
    btMask.hidden = !self.isDeletedFriend;
    callingView.hidden = self.isDeletedFriend;
    if (isMemberForDiectory || isDirectory) {
        btMask.hidden = YES;
    }
    tapTitleView.enabled = !self.isDeletedFriend;
    
    if ([lstUsers count] == 2) {
        tapTitleView.enabled = NO;
        //display phone numbers when tap phone button.
        for(NSDictionary *dic in lstUsers)
        {
            if ([[dic objectForKey:@"user_id"] intValue] == [[AppDelegate sharedDelegate].userId intValue])
            {
                continue;
            }
            if ([dic objectForKey:@"phones"] != nil)
                arrPhone = [dic objectForKey:@"phones"];
            else{
                if (arrPhone == nil)
                {
                    for(NSDictionary *contactItem in APPDELEGATE.totalList)
                    {
                        if ([dic objectForKey:@"user_id"] == [contactItem objectForKey:@"id"])
                        {
                            arrPhone = [contactItem objectForKey:@"phones"];
                        }
                    }
                }
            }
        }
    }else if (lstUsers.count > 2){
        if (availableUsers == nil)
        {
            availableUsers = [[NSMutableArray alloc] init];
            for(NSDictionary *dic in lstUsers)
            for(NSDictionary *contactItem in APPDELEGATE.totalList)
            {
                if([dic objectForKey:@"user_id"] == APPDELEGATE.userId)
                    continue;
                if ([dic objectForKey:@"user_id"] == [contactItem objectForKey:@"id"] && [[contactItem objectForKey:@"sharing_status"] intValue] != 4)
                {
                    [availableUsers addObject:contactItem];
                }
            }
        }
    }
    
    if (isDirectory) {
        tapTitleView.enabled = YES;
        if (isFromChatHistory)
        {
            [self getVideoCallAvailableUsers];
        }
    }
    __weak YYYChatViewController *weakSelf = self;
    
    // setup pull-to-refresh
    [bubbleTable addPullToRefreshWithActionHandler:^{
        if (!isLoadingMessages)
            [weakSelf GetMessageHistory];
    }];
    
    [self outputSoundSpeaker];
    
    isLoadingMessages = NO;
    if (!isLoadingNewMessages)
        // get messages later than the last recent message
        [self loopLoadNewMessages];
    
    
    //[self GetMessageHistory];
    
    // back button will not have title
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    if (isAbleVideoConference) {
        callingView.hidden = YES;
    }
    if (isPushedFromConference || APPDELEGATE.isConferenceView) {
        callingView.hidden = YES;
    }
}

- (void)getVideoCallAvailableUsers
{
    if (fromHistoryGroupDic == nil)
        return;
    //    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        //        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            if(availableUsers == nil)
                availableUsers = [[NSMutableArray alloc] init];
            else
                [availableUsers removeAllObjects];
            
            
            for (NSDictionary *dict in [[_responseObject objectForKey:@"data"] objectForKey:@"data"]) {
                if ([[fromHistoryGroupDic objectForKey:@"group_type"] integerValue] == 2) {
                    if ([[dict objectForKey:@"user_id"] integerValue] != [[AppDelegate sharedDelegate].userId integerValue] && [[dict objectForKey:@"sharing_status"] integerValue] != 4) {
                        [availableUsers addObject:dict];
                    }
                }else{
                    if ([[dict objectForKey:@"contact_type"] integerValue] == 1 && [[dict objectForKey:@"sharing_status"] integerValue] != 4) {
                        [availableUsers addObject:dict];
                    }
                }
            }
            if (availableUsers.count > 0)
            {
                callingView.hidden = NO;
            }
        }else{
            if (availableUsers.count > 0)
            {
                callingView.hidden = NO;
            }else{
                callingView.hidden = YES;
            }
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Internet Connection Error!"];
    } ;
    if ([[fromHistoryGroupDic objectForKey:@"group_type"] integerValue] != 2) {
        if ([fromHistoryGroupDic objectForKey:@"group_id"] ) {
            [[YYYCommunication sharedManager] getUsersForGroup:[AppDelegate sharedDelegate].sessionId groupID:[fromHistoryGroupDic objectForKey:@"group_id"] successed:successed failure:failure];
        }else{
            [[YYYCommunication sharedManager] getUsersForGroup:[AppDelegate sharedDelegate].sessionId groupID:[fromHistoryGroupDic objectForKey:@"id"] successed:successed failure:failure];
        }
    }else {
        [[YYYCommunication sharedManager] GetMembersDirectory:APPDELEGATE.sessionId directoryId:[fromHistoryGroupDic objectForKey:@"group_id"] pageNum:@"1" countPerPage:@"40" successed:successed failure:failure];
    }
}
- (void)btOpenVideoCallingClick:(id)sender {
    [self OpenConference:1];
}
- (void)btOpenVoiceCallingClick:(id)sender {
    // [self OpenConference:2];
    BOOL isCheckOwn = NO;
    for (NSDictionary *dict in lstUsers) {
        if ([[dict objectForKey:@"user_id"] integerValue] != [[AppDelegate sharedDelegate].userId integerValue]) {
            isCheckOwn = YES;
        }
    }
    if (isCheckOwn) {
        if ([lstUsers count] >8 ) {
            SelectUserForConferenceViewController *viewcontroller = [[SelectUserForConferenceViewController alloc] initWithNibName:@"SelectUserForConferenceViewController" bundle:nil];
            viewcontroller.viewcontroller = self;
            
            viewcontroller.isDirectory = isDirectory;
            viewcontroller.isReturnFromGroupChat = YES;
            viewcontroller.conferenceType = 1;
            viewcontroller.arrayUsers = availableUsers;
            viewcontroller.viewcontroller = self;
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:viewcontroller];
            [self presentViewController:nc animated:YES completion:nil];
            return;
        }
    }else{
        if ([lstUsers count]>7) {
            NSMutableArray *listUser = [availableUsers mutableCopy];
            for(int i = 0; i<availableUsers.count; i++)
            {
                if ([availableUsers[i] objectForKey:@"user_id"] == [AppDelegate sharedDelegate].userId)
                {
                    [listUser removeObjectAtIndex:i];
                    break;
                }
            }
            SelectUserForConferenceViewController *viewcontroller = [[SelectUserForConferenceViewController alloc] initWithNibName:@"SelectUserForConferenceViewController" bundle:nil];
            viewcontroller.viewcontroller = self;
            viewcontroller.conferenceType = 1;
            viewcontroller.isDirectory = isDirectory;
            viewcontroller.isReturnFromGroupChat = YES;
            viewcontroller.arrayUsers = listUser;
            viewcontroller.viewcontroller = self;
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:viewcontroller];
            [self presentViewController:nc animated:YES completion:nil];
            return;
        }
    }
    if((isDirectory || lstUsers.count > 1) && isFromChatHistory)
    {
        if (isDirectory)
            self.lstUsers = [availableUsers mutableCopy];
        NSMutableArray *listUser = [availableUsers mutableCopy];
        for(int i = 0; i<availableUsers.count; i++)
        {
            if ([availableUsers[i] objectForKey:@"user_id"] == [AppDelegate sharedDelegate].userId)
            {
                [listUser removeObjectAtIndex:i];
                break;
            }
        }
        SelectUserForConferenceViewController *viewcontroller = [[SelectUserForConferenceViewController alloc] initWithNibName:@"SelectUserForConferenceViewController" bundle:nil];
        viewcontroller.viewcontroller = self;
        viewcontroller.conferenceType = 1;
        viewcontroller.isDirectory = isDirectory;
        viewcontroller.isReturnFromGroupChat = YES;
        viewcontroller.arrayUsers = availableUsers;
        viewcontroller.viewcontroller = self;
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:viewcontroller];
        [self presentViewController:nc animated:YES completion:nil];
        return;
        
    }
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    [sheet setTag:100];
    [sheet addButtonWithTitle:@"Ginko Video Call"];
    [sheet addButtonWithTitle:@"Ginko Voice Call"];
    if(arrPhone != nil)
    {
        for (int i = 0; i < [arrPhone count]; i++)
            [sheet addButtonWithTitle:[arrPhone objectAtIndex:i]];
    }
    [sheet addButtonWithTitle:@"Cancel"];
    sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
    [sheet showInView:self.view];
    tmpAcntionSheet = sheet;
}
//delegate
- (void)getSelectedItems: (NSString*)itemIds callType:(NSInteger)type
{
    if([itemIds  isEqual: @""])
    {
        return;
    }
    NSMutableArray* userList = [[NSMutableArray alloc]init];
    for(int i = 0; i< lstUsers.count; i++)
    {
        NSString* strID = [NSString stringWithFormat:@"%@", [lstUsers[i] objectForKey:@"user_id"]];
        if ([itemIds containsString:strID])
            [userList addObject:lstUsers[i]];
    }
    conferencelstUsers = userList;
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    [sheet setTag:100];
    [sheet addButtonWithTitle:@"Ginko Video Call"];
    [sheet addButtonWithTitle:@"Ginko Voice Call"];
    [sheet addButtonWithTitle:@"Cancel"];
    sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
    [sheet showInView:self.view];
    tmpAcntionSheet = sheet;
}
- (void)OpenConference:(NSInteger)type{
    //    BOOL isCheckOwn = NO;
    //    for (NSDictionary *dict in lstUsers) {
    //        if ([[dict objectForKey:@"user_id"] integerValue] != [[AppDelegate sharedDelegate].userId integerValue]) {
    //            isCheckOwn = YES;
    //        }
    //    }
    //    if (isCheckOwn) {
    //        if ([lstUsers count] >8 ) {
    //            SelectUserForConferenceViewController *viewcontroller = [[SelectUserForConferenceViewController alloc] initWithNibName:@"SelectUserForConferenceViewController" bundle:nil];
    //            viewcontroller.viewcontroller = self;
    //
    //            viewcontroller.isDirectory = isDirectory;
    //            viewcontroller.isReturnFromGroupChat = YES;
    //            viewcontroller.conferenceType = type;
    //            viewcontroller.arrayUsers = availableUsers;
    //            viewcontroller.viewcontroller = self;
    //            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:viewcontroller];
    //            [self presentViewController:nc animated:YES completion:nil];
    //            return;
    //        }
    //    }else{
    //        if ([lstUsers count]>7) {
    //            NSMutableArray *listUser = [availableUsers mutableCopy];
    //            for(int i = 0; i<availableUsers.count; i++)
    //            {
    //                if ([availableUsers[i] objectForKey:@"user_id"] == [AppDelegate sharedDelegate].userId)
    //                {
    //                    [listUser removeObjectAtIndex:i];
    //                    break;
    //                }
    //            }
    //            SelectUserForConferenceViewController *viewcontroller = [[SelectUserForConferenceViewController alloc] initWithNibName:@"SelectUserForConferenceViewController" bundle:nil];
    //            viewcontroller.viewcontroller = self;
    //            viewcontroller.conferenceType = type;
    //            viewcontroller.isDirectory = isDirectory;
    //            viewcontroller.isReturnFromGroupChat = YES;
    //            viewcontroller.arrayUsers = listUser;
    //            viewcontroller.viewcontroller = self;
    //            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:viewcontroller];
    //            [self presentViewController:nc animated:YES completion:nil];
    //            return;
    //        }
    //    }
    if (conferencelstUsers != nil && conferencelstUsers.count != 0)
    {
        [self makeVideoAndVoiceCall:conferencelstUsers callType:type];
        conferencelstUsers = nil;
    }
    else
        [self makeVideoAndVoiceCall:lstUsers callType:type];
}

-(void)makeVideoAndVoiceCall:(NSMutableArray*)usersList callType: (NSInteger)type
{
    NSString *ids = @"";
    NSString *availableIds = @"";
    if (availableUsers != nil)
    {
        for(NSDictionary *dic in availableUsers)
        {
            if ([availableIds isEqualToString:@""]) {
                if([dic objectForKey:@"user_id"] == nil)
                    availableIds = [NSString stringWithFormat:@"%@", [dic objectForKey:@"id"]];
                else
                    availableIds = [NSString stringWithFormat:@"%@", [dic objectForKey:@"user_id"]];
            }else{
                if([dic objectForKey:@"user_id"] == nil)
                    availableIds = [NSString stringWithFormat:@"%@,%@", availableIds, [dic objectForKey:@"id"]];
                else
                    availableIds = [NSString stringWithFormat:@"%@,%@", availableIds, [dic objectForKey:@"user_id"]];
            }
        }
    }
    [APPDELEGATE.conferenceMembersForVideoCalling removeAllObjects];
    
    for (NSDictionary *oneUser in usersList) {
        if ([[oneUser objectForKey:@"user_id"] integerValue] != [[AppDelegate sharedDelegate].userId integerValue]) {
            if(!isDirectory){
                if (![availableIds isEqualToString:@""])
                {
                    NSString *currentId = [[NSString alloc] initWithFormat:@"%ld", [[oneUser objectForKey:@"user_id"] integerValue]];
                    if (![availableIds containsString:currentId])
                        continue;
                }
                NSMutableDictionary *dictOfUser = [[NSMutableDictionary alloc] init];
                [dictOfUser setObject:[oneUser objectForKey:@"user_id"] forKey:@"user_id"];
                [dictOfUser setObject:[NSString stringWithFormat:@"%@ %@", [oneUser objectForKey:@"fname"], [oneUser objectForKey:@"lname"]] forKey:@"name"];
                if([oneUser objectForKey:@"photo_url"] != nil)
                    [dictOfUser setObject:[oneUser objectForKey:@"photo_url"] forKey:@"photo_url"];
                else if ([oneUser objectForKey:@"profile_image"] != nil)
                    [dictOfUser setObject:[oneUser objectForKey:@"profile_image"] forKey:@"photo_url"];
                
                if (type == 1) {
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
            }else{
                if (![availableIds isEqualToString:@""])
                {
                    NSString *currentId = [[NSString alloc] initWithFormat:@"%ld", [[oneUser objectForKey:@"user_id"] integerValue]];
                    if (![availableIds containsString:currentId])
                        continue;
                }
                NSMutableDictionary *dictOfUser = [[NSMutableDictionary alloc] init];
                [dictOfUser setObject:[oneUser objectForKey:@"user_id"] forKey:@"user_id"];
                [dictOfUser setObject:[NSString stringWithFormat:@"%@ %@", [oneUser objectForKey:@"fname"], [oneUser objectForKey:@"lname"]] forKey:@"name"];
                if([oneUser objectForKey:@"photo_url"] != nil)
                    [dictOfUser setObject:[oneUser objectForKey:@"photo_url"] forKey:@"photo_url"];
                else if ([oneUser objectForKey:@"profile_image"] != nil)
                    [dictOfUser setObject:[oneUser objectForKey:@"profile_image"] forKey:@"photo_url"];
                
                
                if (type == 1) {
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
                
            }
            
            if ([ids isEqualToString:@""]) {
                ids = [NSString stringWithFormat:@"%@", [oneUser objectForKey:@"user_id"]];
            }else{
                ids = [NSString stringWithFormat:@"%@,%@", ids, [oneUser objectForKey:@"user_id"]];
            }
        }
    }
    
    if (isDirectory || (lstUsers.count != APPDELEGATE.conferenceMembersForVideoCalling.count && isFromChatHistory)) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            if ([[_responseObject objectForKey:@"success"] boolValue])
            {
                VideoVoiceConferenceViewController *viewcontroller = [[VideoVoiceConferenceViewController alloc] initWithNibName:@"VideoVoiceConferenceViewController" bundle:nil];
                APPDELEGATE.isOwnerForConference = YES;
                APPDELEGATE.isJoinedOnConference = YES;
                APPDELEGATE.conferenceId = [[_responseObject objectForKey:@"data"] objectForKey:@"board_id"];
                viewcontroller.boardId = [[_responseObject objectForKey:@"data"] objectForKey:@"board_id"];
                viewcontroller.conferenceType = type;
                viewcontroller.conferenceName =self.navigationController.title;
                [self.navigationController pushViewController:viewcontroller animated:YES];
                
            }else{
                [CommonMethods showAlertUsingTitle:@"Error!" andMessage:[[_responseObject objectForKey:@"err"] objectForKey:@"errMsg"]];
            }
        };
        
        void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
            
            [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
            [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Internet Connection Error!"];
            
        } ;
        
        [[YYYCommunication sharedManager] CreateChatBoard:[AppDelegate sharedDelegate].sessionId userids:ids successed:successed failure:failure];
    }else{
        VideoVoiceConferenceViewController *viewcontroller = [[VideoVoiceConferenceViewController alloc] initWithNibName:@"VideoVoiceConferenceViewController" bundle:nil];
        APPDELEGATE.isOwnerForConference = YES;
        APPDELEGATE.isJoinedOnConference = YES;
        APPDELEGATE.conferenceId = [NSString stringWithFormat:@"%@", boardid];
        viewcontroller.boardId = [NSString stringWithFormat:@"%@", boardid];
        viewcontroller.conferenceType = type;
        viewcontroller.conferenceName =self.navigationController.title;
        [self.navigationController pushViewController:viewcontroller animated:YES];
    }
}

-(void)outputSoundSpeaker
{
    AVAudioSession* audioSession = [AVAudioSession sharedInstance];
    
    UInt32 doChangeDefaultRoute = 1;
    NSError* error4 = nil;
    
    OSStatus status = AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof (doChangeDefaultRoute), &doChangeDefaultRoute);
    if (status != kAudioSessionNoError) {
        NSLog(@"AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers) failed: %d", (int)status);
    }
    
    // Activate the audio session
    error4 = nil;
    if (![audioSession setActive:YES error:&error4]) {
        NSLog(@"AVAudioSession setActive:YES failed: %@", [error4 localizedDescription]);
    }
}

- (void) reachabilityChanged:(NSNotification *)note
{
    /*
     Reachability* curReach = [note object];
     NetworkStatus status = [curReach currentReachabilityStatus];
     
     if(status == NotReachable)
     {
     //No internet
     bConnection = NO;
     }
     else if (status == ReachableViaWiFi)
     {
     //WiFi
     if (!bConnection)
     {
     if (![bubbleData count])
     {
     [self GetMessageHistory];
     }
     else{
     [bubbleTable reloadData];
     }
     
     bConnection = YES;
     }
     }
     else if (status == ReachableViaWWAN)
     {
     //3G
     if (!bConnection)
     {
     
     if (![bubbleData count])
     {
     [self GetMessageHistory];
     }
     else{
     [bubbleTable reloadData];
     }
     
     bConnection = YES;
     }
     }
     */
}

-(void)tapTitleView
{
    if (!isRecording) {
        APPDELEGATE.isShownChattingScreenWithMapVideo = YES;
        YYYSelectContactController *viewcontroller = [[YYYSelectContactController alloc] initWithNibName:@"YYYSelectContactController" bundle:nil];
        viewcontroller.boardid = boardid;
        viewcontroller.viewcontroller = self;
        
        NSMutableArray *lstTempIds = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in lstUsers)
        {
            [lstTempIds addObject:[dict objectForKey:@"user_id"]];
        }
        
        viewcontroller.lstCurrentUserIds = lstTempIds;
        viewcontroller.bContact = YES;
        [self.navigationController presentViewController:viewcontroller animated:YES completion:nil];
    }
}

-(void)showAlert:(NSString*)_message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:_message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

-(void)sendMap:(float)flat :(float)flng
{
    [self sendMessage:nil image:nil voice:nil video:nil map:[NSString stringWithFormat:@"%f,%f",flat,flng]];
}

-(void)makeEmoji:(int)nIndex
{
    [btEmoji1 setSelected:NO];
    [btEmoji2 setSelected:NO];
    [btEmoji3 setSelected:NO];
    [btEmoji4 setSelected:NO];
    
    if (nIndex == 0) {
        [btEmoji1 setSelected:YES];
    }else if (nIndex == 1){
        [btEmoji2 setSelected:YES];
    }else if (nIndex == 2){
        [btEmoji3 setSelected:YES];
    }else if (nIndex == 3){
        [btEmoji4 setSelected:YES];
    }
    
    for (UIView *view in scvEmoji.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
        }
    }
    
    NSArray *lstArray = [NSArray arrayWithObjects:@"People",@"Nature",@"Places",@"Objects", nil];
    NSArray *lstEmojis = [emojis objectForKey:[lstArray objectAtIndex:nIndex]];
    
    
    
    for (int i = 0; i < [lstEmojis count]; i++) {
        UIButton *btEmoji = [UIButton buttonWithType:UIButtonTypeCustom];
        [btEmoji setTitle:[lstEmojis objectAtIndex:i] forState:UIControlStateNormal];
        btEmoji.titleLabel.font = [UIFont fontWithName:@"Apple color emoji" size:BUTTON_FONT_SIZE];
        btEmoji.frame = CGRectIntegral(CGRectMake([self XMarginForButtonInColumn:i/3],
                                                  [self YMarginForButtonInRow:i%3] + 10,
                                                  BUTTON_WIDTH,
                                                  BUTTON_HEIGHT));
        [btEmoji addTarget:self action:@selector(btEmojiItemClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [scvEmoji addSubview:btEmoji];
    }
    
    int nPageCount = (int)[lstEmojis count] / (EMOJIROW*EMOJICOL);
    if ([lstEmojis count] % (EMOJIROW*EMOJICOL) != 0) {
        nPageCount = nPageCount + 1;
    }
    
    scvEmoji.delegate = self;
    
    [pgCtl setNumberOfPages:nPageCount];
    
    [scvEmoji setContentSize:CGSizeMake(320 * nPageCount, scvEmoji.frame.size.height)];
}

-(IBAction)btEmojiItemClick:(id)sender
{
    [txtMessage setText:[NSString stringWithFormat:@"%@%@",txtMessage.text,[(UIButton*)sender currentTitle]]];
    [self textViewDidChange:txtMessage];
    tmpTextMessage = txtMessage.text;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [pgCtl setCurrentPage:scrollView.contentOffset.x / 320];
}

- (CGFloat)XMarginForButtonInColumn:(NSInteger)column {
    CGFloat padding = ((CGRectGetWidth(scvEmoji.bounds) - EMOJICOL * BUTTON_WIDTH) / EMOJICOL);
    return (padding / 2 + column * (padding + BUTTON_WIDTH));
}

- (CGFloat)YMarginForButtonInRow:(NSInteger)rowNumber {
    CGFloat padding = ((CGRectGetHeight(scvEmoji.bounds) - 30 - EMOJIROW * BUTTON_WIDTH) / EMOJIROW);
    return (padding / 2 + rowNumber * (padding + BUTTON_WIDTH));
}

-(void)handleTap
{
    if (btWrite.selected) // no action if editing
        return;
    
    [self.view endEditing:YES];
    [self.navigationItem setRightBarButtonItem:btVideoCalling];
    
    if (!vwEmoItem.hidden)
    {
        [vwEmoItem setHidden:YES];
        //[vwEmoticon setHidden:YES];
        
        [btMap setEnabled:YES];
        [btVideo setEnabled:YES];
        [btPhoto setEnabled:YES];
        
        [btSend setHidden:YES];
        [btVoice setHidden:NO];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationCurve:7];
        
        keyboardHeight.constant = 0;
        [self.view layoutIfNeeded];
        
        [UIView commitAnimations];
        //		CGRect frame = vwSend.frame;
        //		frame.origin.y += 216;
        //		vwSend.frame = frame;
        //
        //		frame = bubbleTable.frame;
        //		frame.size.height += 216;
        //		bubbleTable.frame = frame;
        
        [self.navigationItem setRightBarButtonItem:btVideoCalling];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        btSend.enabled = NO;
        tmpTextMessage = @"";
    }else{
        btSend.enabled = YES;
    }
    [self.navigationItem setRightBarButtonItem:btCloseKeyboard];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@""] && [txtMessage.text isEqualToString:@""]) {
        btSend.enabled = NO;
        tmpTextMessage = @"";
    }else{
        btSend.enabled = YES;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    [textView layoutIfNeeded];
    if ([textView.text isEqualToString:@""]) {
        btSend.enabled = NO;
        tmpTextMessage = @"";
    }else{
        btSend.enabled = YES;
    }
    CGFloat height = MIN(MAX(33, ceil(textView.contentSize.height)), 60); // ceil to avoid decimal
    
    if (height != messageHeight.constant) { // set when height changed
        messageHeight.constant = height;
        [txtMessage setContentOffset:CGPointZero animated:NO]; // scroll to top to avoid "wrong contentOffset" artefact when line count changes
        [self.view layoutIfNeeded];
    }
}

-(void)enterBackground
{
    if (!isLoadingNewMessages)
        // get messages later than the last recent message
        [self loopLoadNewMessages];
}

- (void)viewWillAppear:(BOOL)animated
{
    // refresh title
    if (!isDirectory && [lstUsers count] > 0) {
        NSDictionary *dictMe = nil;
        for (int i = 0; i < [lstUsers count]; i++)
        {
            NSDictionary *dict = [lstUsers objectAtIndex:i];
            if ([[dict objectForKey:@"user_id"] intValue] == [[AppDelegate sharedDelegate].userId intValue]) {
                dictMe = dict;
                break;
            }
        }
        
        if (dictMe) {
            [lstUsers removeObject:dictMe];
        }
        
        [lblTitle setText:_groupName];
        if (!_groupName) {
            if ([lstUsers count] == 1)
            {
                [lblTitle setText:[NSString stringWithFormat:@"%@ %@",[[lstUsers objectAtIndex:0] objectForKey:@"fname"],[[lstUsers objectAtIndex:0] objectForKey:@"lname"]]];
            }
            else
            {
                //            [lblTitle setText:[NSString stringWithFormat:@"%@ %@+%d",[[lstUsers objectAtIndex:0] objectForKey:@"fname"],[[lstUsers objectAtIndex:0] objectForKey:@"lname"],(int)[lstUsers count] - 1]];
                [lblTitle setText:[NSString stringWithFormat:@"%@+%d",[[lstUsers objectAtIndex:[lstUsers count] - 1] objectForKey:@"fname"],(int)[lstUsers count] - 1]];
            }
        }
    }else{
        if (isMemberForDiectory && isDirectory) {
            [lblTitle setText:_groupName];
        }
    }
    
    if (APPDELEGATE.isShownChattingScreenWithMapVideo) {
        APPDELEGATE.isShownChattingScreenWithMapVideo = NO;
        [self loopLoadNewMessages];
    }
    [self reloadChatViewOnly];
    
    [AppDelegate sharedDelegate].currentBoardID = boardid;
    
}
- (void)reloadChatViewOnly{
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        
        NSDictionary *result = _responseObject;
        if ([[result objectForKey:@"success"] boolValue]) {
            NSArray *members = [[result objectForKey:@"data"] objectForKey:@"members"];
            BOOL isFriendByPush = YES;
            for (NSDictionary *memberDic in members) {
                //if ([memberDic[@"is_friend"] boolValue] && [[AppDelegate sharedDelegate].existedContactIDs containsObject:[memberDic[@"memberinfo"] objectForKey:@"user_id"]]) {
                if ([memberDic[@"is_friend"] boolValue]) {
                    isFriendByPush = NO;
                }
            }
            if (isFriendByPush) {
                [self.view endEditing:YES];
            }
            btMask.hidden = !isFriendByPush;
            callingView.hidden = isFriendByPush;
            if (isMemberForDiectory || isDirectory) {
                btMask.hidden = YES;
                if (availableUsers.count > 0)
                {
                    callingView.hidden = NO;
                }
            }
            if (isAbleVideoConference || APPDELEGATE.isConferenceView) {
                callingView.hidden = YES;
            }
            self.isDeletedFriend = isFriendByPush;
        }
        
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
    } ;
    
    [[Communication sharedManager] GetBoardInformation:APPDELEGATE.sessionId boardid:[NSString stringWithFormat:@"%@",boardid] successed:successed failure:failure];
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [AppDelegate sharedDelegate].isChatScreen = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessage:) name:@"NEWMESSAGE" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground) name:@"ENTERFROMBACKGROUND" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadChatView) name:CONTACT_SYNC_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeAllPromptWhenAccept) name:CLOSE_ALERT_WHEN_CONFERENCEVIEW_NOTIFICATION object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [AppDelegate sharedDelegate].isChatScreen = NO;
    APPDELEGATE.isPlayingAudio = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NEWMESSAGE" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ENTERFROMBACKGROUND" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CONTACT_SYNC_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CLOSE_ALERT_WHEN_CONFERENCEVIEW_NOTIFICATION object:nil];
    [AppDelegate sharedDelegate].currentBoardID = nil;
}
- (void)closeAllPromptWhenAccept{
    if (tmpAcntionSheet) {
        [tmpAcntionSheet dismissWithClickedButtonIndex:-1 animated:YES];
        tmpAcntionSheet = nil;
    }
}
- (void)reloadChatView{
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        
        NSDictionary *result = _responseObject;
        if ([[result objectForKey:@"success"] boolValue]) {
            NSArray *members = [[result objectForKey:@"data"] objectForKey:@"members"];
            BOOL isFriendByPush = YES;
            for (NSDictionary *memberDic in members) {
                //if ([memberDic[@"is_friend"] boolValue] && [[AppDelegate sharedDelegate].existedContactIDs containsObject:[memberDic[@"memberinfo"] objectForKey:@"user_id"]]) {
                if ([memberDic[@"is_friend"] boolValue]) {
                    isFriendByPush = NO;
                }
                for (int i = 0 ; i < [bubbleData count] ; i ++) {
                    NSBubbleData *oneData = [bubbleData objectAtIndex:i];
                    if ([[[memberDic objectForKey:@"memberinfo"] objectForKey:@"user_id"] integerValue] == [oneData.msg_userid integerValue])
                    {
                        oneData.avatar_url =[NSURL URLWithString:[[memberDic objectForKey:@"memberinfo"] objectForKey:@"photo_url"]];
                        [bubbleData replaceObjectAtIndex:i withObject:oneData];
                    }
                }
            }
            if (isFriendByPush) {
                [self.view endEditing:YES];
            }
            btMask.hidden = !isFriendByPush;
            callingView.hidden = isFriendByPush;
            if (isMemberForDiectory || isDirectory) {
                btMask.hidden = YES;
            }
            if (isAbleVideoConference|| APPDELEGATE.isConferenceView) {
                callingView.hidden = YES;
            }
            self.isDeletedFriend = isFriendByPush;
            
            [bubbleTable reloadData];
        }
        
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
    } ;
    
    [[Communication sharedManager] GetBoardInformation:APPDELEGATE.sessionId boardid:[NSString stringWithFormat:@"%@",boardid] successed:successed failure:failure];
}
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    [self performSelector:@selector(btCloseClick:) withObject:btClose];
    
    [btSend setHidden:NO];
    if ([txtMessage.text isEqualToString:@""]) {
        btSend.enabled = NO;
        tmpTextMessage = @"";
    }else{
        btSend.enabled = YES;
    }
    [btVoice setHidden:YES];
    
    NSDictionary* userInfo = [aNotification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    if(!keyboardShown)
    {
        CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:duration];
        [UIView setAnimationCurve:[userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    }
    
    keyboardHeight.constant = kbSize.height;
    [self.view layoutIfNeeded];
    
    if(!keyboardShown)
        [UIView commitAnimations];
    
    keyboardShown = YES;
    
    //	CGRect frame = self.view.bounds;
    //    frame.size.height -= CGRectGetHeight(vwSend.frame);
    //	frame.size.height -= kbSize.height;
    //	bubbleTable.frame = frame;
    //
    //    frame = vwSend.frame;
    //    frame.origin.y = CGRectGetMaxY(bubbleTable.frame);
    //    vwSend.frame = frame;
    
    [self scrollToBottom : FALSE];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [self.navigationItem setRightBarButtonItem:btVideoCalling];
    keyboardShown = NO;
    [btSend setHidden:YES];
    [btVoice setHidden:NO];
    
    NSDictionary *userInfo = [aNotification userInfo];
    CGFloat duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:[userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    keyboardHeight.constant = 0;
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

-(void)scrollToBottom : (BOOL)_animated
{
    CGFloat yoffset = 0;
    if (bubbleTable.contentSize.height > bubbleTable.bounds.size.height) {
        yoffset = bubbleTable.contentSize.height - bubbleTable.bounds.size.height;
    }
    
    [bubbleTable setContentOffset:CGPointMake(0, yoffset) animated:_animated];
}

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [bubbleData count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [bubbleData objectAtIndex:row];
}


-(void)IMphotoPickerController:(IMPhotoPickerController *)pickerController didSelectBackground:(UIImage *)background avatar:(UIImage *)avatar
{
    [pickerController dismissViewControllerAnimated:NO completion:^{
        [self sendMessage:nil image:UIImageJPEGRepresentation(background,0.2f) voice:nil video:nil map:nil];
    }];
}

-(void)IMphotoPickerControllerDidCancel:(IMPhotoPickerController *)pickerController
{
    [pickerController dismissViewControllerAnimated:NO completion:^{
        
    }];
}

- (void)videoPickerController:(IMVideoPickerController *)pickerController didSelectVideo:(NSURL *)videoURL
{
    [pickerController dismissViewControllerAnimated:NO completion:^{
        NSArray *pathComponents = [NSArray arrayWithObjects:
                                   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                   @"ZipedVideo.mp4",
                                   nil];
        NSURL *outputURL = [NSURL fileURLWithPathComponents:pathComponents];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[AppDelegate sharedDelegate].window animated:YES];
        [hud setLabelText:@"Sending..."];
        
        [self convertVideoToLowQuailtyWithInputURL:videoURL outputURL:outputURL handler:^(AVAssetExportSession *exportSession)
         {
             if (exportSession.status == AVAssetExportSessionStatusCompleted)
             {
                 printf("completed\n");
                 NSData *videoData = [NSData dataWithContentsOfURL:outputURL];
                 thumbnail = UIImageJPEGRepresentation([self generateThumbImage:outputURL], 0.3);
                 [self sendMessage:nil image:nil voice:nil video:videoData map:nil];
             }
             else
             {
                 [MBProgressHUD hideAllHUDsForView:[AppDelegate sharedDelegate].window animated:YES];
                 printf("error\n");
                 [self showAlert:@"Oops! Error occurred while compressing video file."];
             }
         }];
    }];
}

- (void)videoPickerControllerDidCancel:(IMVideoPickerController *)pickerController
{
    [pickerController dismissViewControllerAnimated:NO completion:^{
        
    }];
}


- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (isVideo)
    {
        [viewController.navigationItem setTitle:@"Videos"];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    if (isVideo)
    {
        //		NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        //		NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
        
        isVideo = FALSE;
        
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        NSArray *pathComponents = [NSArray arrayWithObjects:
                                   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                   @"ZipedVideo.mp4",
                                   nil];
        NSURL *outputURL = [NSURL fileURLWithPathComponents:pathComponents];
        
        [self convertVideoToLowQuailtyWithInputURL:videoURL outputURL:outputURL handler:^(AVAssetExportSession *exportSession)
         {
             if (exportSession.status == AVAssetExportSessionStatusCompleted)
             {
                 printf("completed\n");
                 NSData *videoData = [NSData dataWithContentsOfURL:outputURL];
                 thumbnail = UIImageJPEGRepresentation([self generateThumbImage:outputURL], 0.3);
                 [self sendMessage:nil image:nil voice:nil video:videoData map:nil];
             }
             else
             {
                 printf("error\n");
                 [self showAlert:@"Oops! Error occurred while compressing video file."];
             }
         }];
        
    }
    else
    {
        [self sendMessage:nil image:UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerEditedImage],1.0f) voice:nil video:nil map:nil];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL
                                   outputURL:(NSURL*)outputURL
                                     handler:(void (^)(AVAssetExportSession*))handler
{
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    //    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.outputURL = outputURL;
    //    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
         handler(exportSession);
     }];
}

#pragma mark - IBAction

-(IBAction)btEmoji1Click:(id)sender
{
    [self makeEmoji:0];
}

-(IBAction)btEmoji2Click:(id)sender
{
    [self makeEmoji:1];
}

-(IBAction)btEmoji3Click:(id)sender
{
    [self makeEmoji:2];
}

-(IBAction)btEmoji4Click:(id)sender
{
    [self makeEmoji:3];
}

-(IBAction)btBackClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    APPDELEGATE.isPlayingAudio = NO;
    if ([AppDelegate sharedDelegate].isCreateEntityViewController) {
        [self.navigationController.navigationBar setBarTintColor:COLOR_PURPLE_THEME];
    }
    [AppDelegate sharedDelegate].isCreateEntityViewController = NO;
}

- (void)btCloseChatClick:(id)sender {
    [txtMessage resignFirstResponder];
}

-(IBAction)btCloseClick:(id)sender
{
    if (vwEmoItem.hidden) {
        return;
    }
    
    [vwEmoItem setHidden:YES];
    //[vwEmoticon setHidden:YES];
    
    [btMap setEnabled:YES];
    [btVideo setEnabled:YES];
    [btPhoto setEnabled:YES];
    
    [btSend setHidden:YES];
    [btVoice setHidden:NO];
    
    //	CGRect frame = vwSend.frame;
    //	frame.origin.y += 216;
    //	vwSend.frame = frame;
    //
    //	frame = bubbleTable.frame;
    //	frame.size.height += 216;
    //	bubbleTable.frame = frame;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationCurve:7];
    
    keyboardHeight.constant = 0;
    [self.view layoutIfNeeded];
    
    [UIView commitAnimations];
    
    [self.navigationItem setRightBarButtonItem:btVideoCalling];
}

-(IBAction)btMapClick:(id)sender
{
    APPDELEGATE.isShownChattingScreenWithMapVideo = YES;
    YYYLocationController *viewcontroller = [[YYYLocationController alloc] initWithNibName:@"YYYLocationController" bundle:nil];
    
    viewcontroller.chatviewcontroller = self;
    viewcontroller.navBarColor = _navBarColor;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:viewcontroller];
    nc.navigationBar.translucent = NO;
    [self presentViewController:nc animated:YES completion:nil];
}

-(IBAction)btVideoClick:(id)sender
{
    APPDELEGATE.isShownChattingScreenWithMapVideo = YES;
    //	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    //	picker.delegate = self;
    //	picker.allowsEditing = YES;
    //	picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //	picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    //	picker.videoMaximumDuration = 30.0f;
    //	isVideo = YES;
    //	[self presentViewController:picker animated:YES completion:NULL];
    
    [self.view endEditing:YES];
    
    IMVideoPickerController *viewController = [[IMVideoPickerController alloc] initWithType];
    viewController.pickerDelegate = self;
    [self presentViewController:viewController animated:NO completion:nil];
}

-(IBAction)btPhotoClick:(id)sender
{
    APPDELEGATE.isShownChattingScreenWithMapVideo = YES;
    [self.view endEditing:YES];
    
    IMPhotoPickerController *viewController = [[IMPhotoPickerController alloc] initWithType];
    viewController.pickerDelegate = self;
    [self presentViewController:viewController animated:NO completion:nil];
}

-(IBAction)btEmoticonClick:(id)sender
{
    if (!vwEmoItem.hidden) {
        return;
    }
    
    [txtMessage resignFirstResponder];
    
    // [vwEmoticon setHidden:NO];
    [vwEmoItem setHidden:NO];
    
    [btMap setEnabled:NO];
    [btVideo setEnabled:NO];
    [btPhoto setEnabled:NO];
    
    [btSend setHidden:NO];
    [btVoice setHidden:YES];
    
    //	CGRect frame = vwSend.frame;
    //	frame.origin.y -= 216;
    //	vwSend.frame = frame;
    //
    //	frame = bubbleTable.frame;
    //	frame.size.height -= 216;
    //	bubbleTable.frame = frame;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationCurve:7];
    
    keyboardHeight.constant = 216;
    [self.view layoutIfNeeded];
    
    [self scrollToBottom : NO];
    
    [UIView commitAnimations];
    
    [self.navigationItem setRightBarButtonItem:btClose];
}

-(IBAction)btWriteClick:(id)sender
{
    //Edit
    [self btCloseClick:self];  // Close Emoticon view if shown
    
    [self btCloseChatClick:self]; // Close keyboard if shown
    
    if (btWrite.selected)
    {
        [btWrite setSelected:NO];
        bubbleTable.bEdit = NO;
        [bubbleTable.lstSelected removeAllObjects];
        [vwTrash setHidden:YES];
        [vwSend setHidden:NO];
        
        [self.navigationItem setLeftBarButtonItem:btBack];
        [self.navigationItem setRightBarButtonItem:btVideoCalling];
    }
    else
    {
        //[txtMessage setText:@""];
        //[self textViewDidChange:txtMessage];
        APPDELEGATE.isPlayingAudio = NO;
        [btWrite setSelected:YES];
        [btWrite setHidden:YES];
        bubbleTable.bEdit = YES;
        [vwTrash setHidden:NO];
        [vwSend setHidden:YES];
        
        btDelete.enabled = bubbleTable.lstSelected.count;
        
        [self.navigationItem setLeftBarButtonItem:btClear];
        [self.navigationItem setRightBarButtonItem:btCloseEdit];
    }
    
    [bubbleTable reloadData];
}

-(IBAction)btCloseEditClick:(id)sender
{
    [btWrite setSelected:NO];
    [btWrite setHidden:NO];
    bubbleTable.bEdit = NO;
    [bubbleTable.lstSelected removeAllObjects];
    [bubbleTable reloadData];
    [vwTrash setHidden:YES];
    [vwSend setHidden:NO];
    
    if ([bubbleData count] == 0) {
        btWrite.enabled = NO;
    }else{
        btWrite.enabled = YES;
    }
    btDelete.enabled = bubbleTable.lstSelected.count;
    
    [self.navigationItem setLeftBarButtonItem:btBack];
    [self.navigationItem setRightBarButtonItem:btVideoCalling];
}

-(IBAction)btClearClick:(id)sender
{
    
    APPDELEGATE.isPlayingAudio = NO;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Do you want to delete all the messages?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    alert.tag = 1000;
    [alert show];
}

-(IBAction)btDeleteClick:(id)sender
{
    if ([bubbleTable.lstSelected count] == 0) {
        return;
    }
    NSString * messageAlert = @"";
    if ([bubbleTable.lstSelected count] == 1) {
        messageAlert = @"Do you want to delete the selected message?";
    }else{
        messageAlert = @"Do you want to delete the selected messages?";
    }
    
    APPDELEGATE.isPlayingAudio = NO;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:messageAlert delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    alert.tag = 1001;
    [alert show];
}

#pragma mark - Voice

-(IBAction)btVoiceStart:(id)sender
{
    tmpTextMessage = txtMessage.text;
    [self setEnabledOfSubviewsOfvwSend:NO];
    APPDELEGATE.isPlayingAudio = NO;
    bubbleTable.userInteractionEnabled = NO;
    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            if (!granted) {
                [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your microphone is disabled.\nPlease go to settings and grant access to microphone."];
                [self setEnabledOfSubviewsOfvwSend:YES];
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    AVAudioSession *session = [AVAudioSession sharedInstance];
                    [session setActive:YES error:nil];
                    
                    // Start recording
                    [recorder record];
                    isRecording = YES;
                    [self timer];
                    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timer) userInfo:nil repeats:YES];
                    [btWrite setHidden:YES];
                    [btRecording setHidden:NO];
                });
            }
        }];
    }
}

-(IBAction)btVoiceSend:(id)sender
{
    [self setEnabledOfSubviewsOfvwSend:YES];
    bubbleTable.userInteractionEnabled = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        isRecording = NO;
        [recorder stop];
        [timer invalidate];
        timer = nil;
        
        if(nVoiceSec < 2)
        {
            nVoiceSec = 0;
            [btWrite setHidden:NO];
            [btRecording setHidden:YES];
            if ([tmpTextMessage isEqualToString:@""]) {
                [txtMessage setText:@""];
            }else{
                [txtMessage setText:tmpTextMessage];
            }
            [self textViewDidChange:txtMessage];
            return;
        }
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Do you want to send your voice message?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        [alert show];
    });
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1000)
    {
        if (buttonIndex == alertView.cancelButtonIndex)
        {
            void ( ^successed )( id _responseObject ) = ^( id _responseObject )
            {
                
                if ([[_responseObject objectForKey:@"success"] boolValue])
                {
                    @synchronized(bubbleData) {
                        [bubbleData removeAllObjects];
                    }
                    [[LocalDBManager sharedManager] deleteAllMessagesForBoard:boardid];
                    
                    [btWrite setSelected:NO];
                    [btWrite setHidden:NO];
                    bubbleTable.bEdit = NO;
                    [bubbleTable.lstSelected removeAllObjects];
                    [bubbleTable reloadData];
                    [vwTrash setHidden:YES];
                    [vwSend setHidden:NO];
                    
                    btDelete.enabled = NO;
                    btWrite.enabled = NO;
                    [self.navigationItem setLeftBarButtonItem:btBack];
                    [self.navigationItem setRightBarButtonItem:btVideoCalling];
                }
            } ;
            
            void ( ^failure )( NSError* _error ) = ^( NSError* _error )
            {
                
            } ;
            
            [[YYYCommunication sharedManager] ClearMessage:[AppDelegate sharedDelegate].sessionId
                                                   boardid:boardid
                                                 successed:successed
                                                   failure:failure];
        }
    }
    else if(alertView.tag == 1001) {
        if(buttonIndex == alertView.cancelButtonIndex) {
            NSString *msgIds = [bubbleTable.lstSelected componentsJoinedByString:@","];
            
            //	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
                
                //		[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                
                if ([[_responseObject objectForKey:@"success"] boolValue])
                {
                    NSMutableArray *newBubbleData = [[NSMutableArray alloc] init];
                    
                    @synchronized(bubbleData) {
                        for (NSBubbleData *data in bubbleData)
                        {
                            if (![bubbleTable.lstSelected containsObject:data.msg_id])
                            {
                                [newBubbleData addObject:data];
                            }
                        }
                        
                        bubbleData = [[NSMutableArray alloc] initWithArray:newBubbleData];
                    }
                    
                    if (bubbleData.count == 0) {
                        [btWrite setSelected:NO];
                        [btWrite setHidden:NO];
                        bubbleTable.bEdit = NO;
                        [bubbleTable.lstSelected removeAllObjects];
                        [bubbleTable reloadData];
                        [vwTrash setHidden:YES];
                        [vwSend setHidden:NO];
                        
                        btDelete.enabled = NO;
                        btWrite.enabled = NO;
                        [self.navigationItem setLeftBarButtonItem:btBack];
                        [self.navigationItem setRightBarButtonItem:btVideoCalling];
                    }
                    
                    [bubbleTable reloadData];
                    
                    btDelete.enabled = NO;
                    
                    [[LocalDBManager sharedManager] deleteSelectedMessages:bubbleTable.lstSelected];
                    [bubbleTable.lstSelected removeAllObjects];
                }
            } ;
            
            void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
                
                //        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
                
            } ;
            
            [[YYYCommunication sharedManager] DeleteMessages:[AppDelegate sharedDelegate].sessionId
                                                     boardid:boardid
                                                  messageids:msgIds
                                                   successed:successed
                                                     failure:failure];
        }
    }
    else
    {
        nVoiceSec = 0;
        [timer invalidate];
        [btWrite setHidden:NO];
        [btRecording setHidden:YES];
        if ([tmpTextMessage isEqualToString:@""]) {
            [txtMessage setText:@""];
        }else{
            [txtMessage setText:tmpTextMessage];
        }
        [self textViewDidChange:txtMessage];
        
        if (buttonIndex == 0)
        {
            [self sendMessage:nil image:nil voice:[NSData dataWithContentsOfURL:audioURL] video:nil map:nil];
        }
    }
}

-(IBAction)btVoiceCancel:(id)sender
{
    [self setEnabledOfSubviewsOfvwSend:YES];
    [recorder stop];
    isRecording  = NO;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    
    [timer invalidate];
    [btWrite setHidden:NO];
    [btRecording setHidden:YES];
    if ([tmpTextMessage isEqualToString:@""]) {
        [txtMessage setText:@""];
    }else{
        [txtMessage setText:tmpTextMessage];
    }
    [self textViewDidChange:txtMessage];
    nVoiceSec = 0;
}

- (IBAction)btVoiceTouchCancel:(id)sender {
    [self setEnabledOfSubviewsOfvwSend:YES];
    [recorder stop];
    isRecording = NO;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    
    [timer invalidate];
    [btWrite setHidden:NO];
    [btRecording setHidden:YES];
    if ([tmpTextMessage isEqualToString:@""]) {
        [txtMessage setText:@""];
    }else{
        [txtMessage setText:tmpTextMessage];
    }
    [self textViewDidChange:txtMessage];
    nVoiceSec = 0;
}


#pragma mark -

-(void)timer
{
    [txtMessage setText:[NSString stringWithFormat:@"%.2d:%.2d          Slide to Cancel <",nVoiceSec/60,nVoiceSec%60]];
    [self textViewDidChange:txtMessage];
    nVoiceSec++;
    //	[self performSelector:@selector(timer) withObject:nil afterDelay:1];
}

-(IBAction)btSendClick:(id)sender
{
    if (!txtMessage.text.length) {
        return;
    }
    
    [self sendMessage:txtMessage.text image:nil voice:nil video:nil map:nil];
}

- (void)addMessagesToDataSource:(NSArray *)messageDics atFirst:(BOOL)bFirst {
    NSMutableArray *tempMsgIds = [NSMutableArray new];
    NSMutableArray *tempBubbleData = [NSMutableArray new];
    
    for (NSDictionary *dict in messageDics)
    {
        NSString *messageId = [[dict objectForKey:@"msg_id"] stringValue];
        if ([bubbleData filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSBubbleData * _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            return [evaluatedObject.msg_id isEqualToString:messageId];
        }]].count > 0) {
            continue;
        }
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [formatter setTimeZone :[NSTimeZone timeZoneForSecondsFromGMT: 0]];
        NSDate *utcdate = [formatter dateFromString:[NSString stringWithFormat:@"%@",[dict objectForKey:@"send_time"]]];
        
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
        NSDate *localdate = [formatter dateFromString:[formatter stringFromDate:utcdate]];
        
        [tempMsgIds addObject:messageId];
        
        //				if ([[NSString stringWithFormat:@"%@",[dict objectForKey:@"send_from"]] isEqualToString:[[YYYCommunication sharedManager].me objectForKey:@"user_id"]])
        if ([[dict objectForKey:@"send_from"] intValue] == [[AppDelegate sharedDelegate].userId intValue])
        {
            if ([[dict objectForKey:@"msgType"] intValue] == 1)
            {
                if ([[dict objectForKey:@"content"] rangeOfString:MAPBOUND].location == 0) {
                    
                    NSBubbleData *sayBubble = [NSBubbleData dataWithMap:[[dict objectForKey:@"content"] substringFromIndex:MAPBOUND.length] date:localdate type:BubbleTypeMine];
                    sayBubble.delegate = self;
                    sayBubble.msg_id = [NSString stringWithFormat:@"%@",[dict objectForKey:@"msg_id"]];
                    sayBubble.msg_userid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"send_from"]];
                    sayBubble.msg_userfname = [AppDelegate sharedDelegate].firstName;
                    sayBubble.msg_userlname = [AppDelegate sharedDelegate].lastName;
                    [tempBubbleData addObject:sayBubble];
                }else if ([dict objectForKey:@"content"] && [[dict objectForKey:@"content"] rangeOfString:@"{\"msgType\":\""].location == 0){
                    id jsonData = [[dict objectForKey:@"content"] dataUsingEncoding:NSUTF8StringEncoding]; //if input is NSString
                    id content = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
                    NSString *emoT = videoCallEmoji;
                    if ([[content objectForKey:@"msgType"] isEqualToString:@"audioCall"]) {
                        emoT = voiceCallEmoji;
                    }
                    NSString *strContent = @"";
                    switch ([[content objectForKey:@"endType"] integerValue]) {
                        case 1:
                            strContent = [NSString stringWithFormat:@"%@ Call ended", emoT];
                            break;
                        case 2:
                            strContent = [NSString stringWithFormat:@"%@ no answer", emoT];
                            break;
                        case 3:
                            strContent = [NSString stringWithFormat:@"%@ is busy", emoT];
                            break;
                        case 4:
                            strContent = [NSString stringWithFormat:@"%@ Missing a call", emoT];
                            break;
                            
                        default:
                            break;
                    }
                    
                    NSBubbleData *sayBubble = [NSBubbleData dataWithText:strContent date:localdate type:BubbleTypeMine];
                    sayBubble.msg_id = [NSString stringWithFormat:@"%@",[dict objectForKey:@"msg_id"]];
                    sayBubble.msg_userid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"send_from"]];
                    sayBubble.msg_userfname = [AppDelegate sharedDelegate].firstName;
                    sayBubble.msg_userlname = [AppDelegate sharedDelegate].lastName;
                    [tempBubbleData addObject:sayBubble];
                }
                else
                {
                    NSBubbleData *sayBubble = [NSBubbleData dataWithText:[dict objectForKey:@"content"] date:localdate type:BubbleTypeMine];
                    sayBubble.msg_id = [NSString stringWithFormat:@"%@",[dict objectForKey:@"msg_id"]];
                    sayBubble.msg_userid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"send_from"]];
                    sayBubble.msg_userfname = [AppDelegate sharedDelegate].firstName;
                    sayBubble.msg_userlname = [AppDelegate sharedDelegate].lastName;
                    [tempBubbleData addObject:sayBubble];
                }
            }
            else
            {
                NSString *content = [dict objectForKey:@"content"];
                id jsonData = [content dataUsingEncoding:NSUTF8StringEncoding]; //if input is NSString
                id dictMsg = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
                
                if([[dictMsg objectForKey:@"file_type"] isEqualToString:@"photo"])
                {
                    NSBubbleData *sayBubble = [NSBubbleData dataWithImage:[dictMsg objectForKey:@"url"] date:localdate type:BubbleTypeMine];
                    sayBubble.msg_id = [NSString stringWithFormat:@"%@",[dict objectForKey:@"msg_id"]];
                    sayBubble.msg_userid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"send_from"]];
                    sayBubble.msg_userfname = [AppDelegate sharedDelegate].firstName;
                    sayBubble.msg_userlname = [AppDelegate sharedDelegate].lastName;
                    sayBubble.delegate = self;
                    [tempBubbleData addObject:sayBubble];
                }
                else if ([[dictMsg objectForKey:@"file_type"] isEqualToString:@"voice"])
                {
                    NSBubbleData *sayBubble = [NSBubbleData dataWithAudio:[dictMsg objectForKey:@"url"] date:localdate type:BubbleTypeMine];
                    sayBubble.msg_id = [NSString stringWithFormat:@"%@",[dict objectForKey:@"msg_id"]];
                    sayBubble.msg_userid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"send_from"]];
                    sayBubble.msg_userfname = [AppDelegate sharedDelegate].firstName;
                    sayBubble.msg_userlname = [AppDelegate sharedDelegate].lastName;
                    sayBubble.delegate = self;
                    [tempBubbleData addObject:sayBubble];
                }
                else if ([[dictMsg objectForKey:@"file_type"] isEqualToString:@"video"])
                {
                    NSBubbleData *sayBubble = [NSBubbleData dataWithVideo:[dictMsg objectForKey:@"url"] thumb:[dictMsg objectForKey:@"thumnail_url"] date:localdate type:BubbleTypeMine];
                    sayBubble.msg_id = [NSString stringWithFormat:@"%@",[dict objectForKey:@"msg_id"]];
                    sayBubble.msg_userid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"send_from"]];
                    sayBubble.msg_userfname = [AppDelegate sharedDelegate].firstName;
                    sayBubble.msg_userlname = [AppDelegate sharedDelegate].lastName;
                    sayBubble.delegate = self;
                    [tempBubbleData addObject:sayBubble];
                }
                /*
                 {
                 content = "{\"file_type\":\"video\",\"url\":\"http:\\/\\/www.xchangewith.me\\/api\\/v2\\/im_upload\\/2015-02-06-11-09-24859.mov\",\"thumnail_url\":\"http:\\/\\/www.xchangewith.me\\/api\\/v2\\/im_upload\\/142319219655806V33A13C8.jpg\"}";
                 "is_new" = 0;
                 "is_read" = 1;
                 msgType = 2;
                 "msg_id" = 2661;
                 "send_from" = 859;
                 "send_time" = "2015-02-06 03:09:56";
                 }
                 */
            }
        }
        else
        {
            NSString *photoURL = @"";
            NSString *fname = @"";
            NSString *lname = @"";
            
            for (NSDictionary *user in lstUsers)
            {
                if ([[user objectForKey:@"user_id"] intValue] == [[dict objectForKey:@"send_from"] intValue]) {
                    photoURL	= [user objectForKey:@"photo_url"];
                    fname		= [user objectForKey:@"fname"];
                    lname		= [user objectForKey:@"lname"];
                    break;
                }
            }
            
            if ([[dict objectForKey:@"msgType"] intValue] == 1)
            {
                if ([[dict objectForKey:@"content"] rangeOfString:MAPBOUND].location == 0) {
                    NSBubbleData *sayBubble = [NSBubbleData dataWithMap:[[dict objectForKey:@"content"] substringFromIndex:MAPBOUND.length] date:localdate type:BubbleTypeSomeoneElse];
                    sayBubble.msg_id = [NSString stringWithFormat:@"%@",[dict objectForKey:@"msg_id"]];
                    sayBubble.msg_userid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"send_from"]];
                    sayBubble.msg_userfname = fname;
                    sayBubble.msg_userlname = lname;
                    sayBubble.delegate = self;
                    sayBubble.avatar_url = [NSURL URLWithString:photoURL];
                    [tempBubbleData addObject:sayBubble];
                }else if ([dict objectForKey:@"content"] && [[dict objectForKey:@"content"] rangeOfString:@"{\"msgType\":\""].location == 0){
                    id jsonData = [[dict objectForKey:@"content"] dataUsingEncoding:NSUTF8StringEncoding]; //if input is NSString
                    id content = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
                    NSString *emoT = videoCallEmoji;
                    if ([[content objectForKey:@"msgType"] isEqualToString:@"audioCall"]) {
                        emoT = voiceCallEmoji;
                    }
                    NSString *strContent = @"";
                    switch ([[content objectForKey:@"endType"] integerValue]) {
                        case 1:
                            strContent = [NSString stringWithFormat:@"%@ Call ended", emoT];
                            break;
                        case 2:
                            strContent = [NSString stringWithFormat:@"%@ no answer", emoT];
                            break;
                        case 3:
                            strContent = [NSString stringWithFormat:@"%@ is busy", emoT];
                            break;
                        case 4:
                            strContent = [NSString stringWithFormat:@"%@ Missing a call", emoT];
                            break;
                            
                        default:
                            break;
                    }
                    
                    NSBubbleData *sayBubble = [NSBubbleData dataWithText:strContent date:localdate type:BubbleTypeSomeoneElse];
                    sayBubble.avatar_url = [NSURL URLWithString:photoURL];
                    sayBubble.msg_id = [NSString stringWithFormat:@"%@",[dict objectForKey:@"msg_id"]];
                    sayBubble.msg_userid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"send_from"]];
                    sayBubble.msg_userfname = fname;
                    sayBubble.msg_userlname = lname;
                    [tempBubbleData addObject:sayBubble];
                }
                else
                {
                    NSBubbleData *sayBubble = [NSBubbleData dataWithText:[dict objectForKey:@"content"] date:localdate type:BubbleTypeSomeoneElse];
                    sayBubble.avatar_url = [NSURL URLWithString:photoURL];
                    sayBubble.msg_id = [NSString stringWithFormat:@"%@",[dict objectForKey:@"msg_id"]];
                    sayBubble.msg_userid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"send_from"]];
                    sayBubble.msg_userfname = fname;
                    sayBubble.msg_userlname = lname;
                    [tempBubbleData addObject:sayBubble];
                }
            }
            else
            {
                NSString *content = [dict objectForKey:@"content"];
                id jsonData = [content dataUsingEncoding:NSUTF8StringEncoding]; //if input is NSString
                id dictMsg = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
                
                if([[dictMsg objectForKey:@"file_type"] isEqualToString:@"photo"])
                {
                    NSBubbleData *sayBubble = [NSBubbleData dataWithImage:[dictMsg objectForKey:@"url"] date:localdate type:BubbleTypeSomeoneElse];
                    sayBubble.delegate = self;
                    sayBubble.avatar_url = [NSURL URLWithString:photoURL];
                    sayBubble.msg_userid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"send_from"]];
                    sayBubble.msg_userfname = fname;
                    sayBubble.msg_userlname = lname;
                    sayBubble.msg_id = [NSString stringWithFormat:@"%@",[dict objectForKey:@"msg_id"]];
                    [tempBubbleData addObject:sayBubble];
                }
                else if ([[dictMsg objectForKey:@"file_type"] isEqualToString:@"voice"])
                {
                    NSBubbleData *sayBubble = [NSBubbleData dataWithAudio:[dictMsg objectForKey:@"url"] date:localdate type:BubbleTypeSomeoneElse];
                    sayBubble.avatar_url = [NSURL URLWithString:photoURL];
                    sayBubble.msg_userid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"send_from"]];
                    sayBubble.msg_userfname = fname;
                    sayBubble.msg_userlname = lname;
                    sayBubble.msg_id = [NSString stringWithFormat:@"%@",[dict objectForKey:@"msg_id"]];
                    sayBubble.delegate = self;
                    [tempBubbleData addObject:sayBubble];
                }
                else if ([[dictMsg objectForKey:@"file_type"] isEqualToString:@"video"])
                {
                    NSBubbleData *sayBubble = [NSBubbleData dataWithVideo:[dictMsg objectForKey:@"url"] thumb:[dictMsg objectForKey:@"thumnail_url"] date:localdate type:BubbleTypeSomeoneElse];
                    sayBubble.delegate = self;
                    sayBubble.avatar_url = [NSURL URLWithString:photoURL];
                    sayBubble.msg_userid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"send_from"]];
                    sayBubble.msg_userfname = fname;
                    sayBubble.msg_userlname = lname;
                    sayBubble.msg_id = [NSString stringWithFormat:@"%@",[dict objectForKey:@"msg_id"]];
                    [tempBubbleData addObject:sayBubble];
                }
            }
        }
    }
    
    if (bFirst) {
        [bubbleData insertObjects:tempBubbleData atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [tempBubbleData count])]];
        [lstMsgId insertObjects:tempMsgIds atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [tempMsgIds count])]];
    } else {
        [bubbleData insertObjects:tempBubbleData atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange([bubbleData count], [tempBubbleData count])]];
        [lstMsgId insertObjects:tempMsgIds atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange([lstMsgId count], [tempMsgIds count])]];
    }
}

// check if the messages loaded from db exist in bubble data
- (BOOL)allMessagesExistInBubbleData:(NSArray *)messages {
    for (Message *message in messages) {
        if ([bubbleData filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSBubbleData * _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            return [evaluatedObject.msg_id isEqualToString:[message.messageId stringValue]];
        }]].count == 0) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)allMessageDicsExistInBubbleData:(NSArray *)messageDics {
    for (NSDictionary *messageDic in messageDics) {
        if ([bubbleData filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSBubbleData * _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            return [evaluatedObject.msg_id isEqualToString:[messageDic[@"msg_id"] stringValue]];
        }]].count == 0) {
            return NO;
        }
    }
    
    return YES;
}

-(void)GetMessageHistory
{
    //    if (!bubbleTable.pullToRefreshView.state)
    //        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDate *oldestDate = nil;
    NSBubbleData *lastObject = nil;
    
    if (isShownBoard == YES) {
        [bubbleData removeAllObjects];
        isShownBoard = NO;
    }
    if (bubbleData && bubbleData.count > 0) {
        lastObject = bubbleData.lastObject;
        oldestDate = lastObject.date;
    }
    
    NSArray *messages = [[LocalDBManager sharedManager] getMessagesEarlierThan:oldestDate boardId:boardid count:10];
    // the operator is less than or equal, so we need to handle equal case
    if (messages.count == 0 || messages.count < 10 || [self allMessagesExistInBubbleData:messages]) { // no local messages, need to load from api
        
        isLoadingMessages = YES;
        
        void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
            [bubbleTable.pullToRefreshView stopAnimating];
            
            if ([[_responseObject objectForKey:@"success"] boolValue])
            {
                [[LocalDBManager sharedManager] saveMessagesToLocalDB:_responseObject[@"data"] boardId:[NSNumber numberWithInteger:[boardid integerValue]]];
                
                @synchronized(bubbleData) {
                    [self addMessagesToDataSource:_responseObject[@"data"] atFirst:NO];
                }
                
                //Read Message
                NSString *strMsgIds = [lstMsgId componentsJoinedByString:@","];
                
                if ([lstMsgId count]) {
                    [[YYYCommunication sharedManager] ReadMessage:[AppDelegate sharedDelegate].sessionId board_id:boardid msg_ids:strMsgIds successed:nil failure:nil];
                }
                //
                [bubbleTable reloadData];
                if ([bubbleData count] == 0) {
                    btWrite.enabled = NO;
                }else{
                    btWrite.enabled = YES;
                }
                if (bFirstLoad) {
                    [self scrollToBottom : YES];
                    bFirstLoad = NO;
                }
            }
            
            isLoadingMessages = NO;
        };
        
        void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
            [bubbleTable.pullToRefreshView stopAnimating];
            
            [CommonMethods showAlertUsingTitle:@"Oops!" andMessage:@"Bad connection!"];
            
            isLoadingMessages = NO;
        };
        
        if (oldestDate)
            // load 40 messages earlier than the first date loaded
            [[YYYCommunication sharedManager] GetMessageHistory:[AppDelegate sharedDelegate].sessionId boardid:boardid number:@"10" lastdays:@"0" earlierThan:oldestDate laterThan:nil successed:successed failure:failure];
        else
            // load last 40 messages
            [[YYYCommunication sharedManager] GetMessageHistory:[AppDelegate sharedDelegate].sessionId boardid:boardid number:@"10" lastdays:@"0" earlierThan:nil laterThan:nil successed:successed failure:failure];
        
    } else {
        // local messages exist, so load and show
        NSMutableArray *messageDics = [NSMutableArray new];
        
        for (Message *message in messages) {
            [messageDics addObject:[NSJSONSerialization JSONObjectWithData:[message.content dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil]];
        }
        
        @synchronized(bubbleData) {
            [self addMessagesToDataSource:[messageDics copy] atFirst:NO];
        }
        
        [bubbleTable.pullToRefreshView stopAnimating];
        if ([bubbleData count] == 0) {
            btWrite.enabled = NO;
        }else{
            btWrite.enabled = YES;
        }
        [bubbleTable reloadData];
        
        if (bFirstLoad) {
            [self scrollToBottom : YES];
            bFirstLoad = NO;
        }
        
        //        if (!isLoadingNewMessages)
        //            // get messages later than the last recent message
        //            [self loopLoadNewMessages];
    }
}
- (void)realodUserInfos:(id)responseBody{
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            NSMutableArray *arrUsers = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in [_responseObject objectForKey:@"data"]) {
                NSMutableDictionary *dictTemp = [[NSMutableDictionary alloc] init];
                [dictTemp setObject:[dict objectForKey:@"name"] forKey:@"fname"];
                [dictTemp setObject:@"" forKey:@"lname"];
                [dictTemp setObject:[dict objectForKey:@"profile_image"] forKey:@"photo_url"];
                [dictTemp setObject:[dict objectForKey:@"id"] forKey:@"user_id"];
                if (!lstUsers) {
                    lstUsers = [[NSMutableArray alloc] init];
                    [lstUsers addObject:dictTemp];
                }
                if (![lstUsers containsObject:dictTemp]) {
                    [lstUsers addObject:dictTemp];
                }
            }
            if(ABS(bubbleTable.contentOffset.y - (bubbleTable.contentSize.height - bubbleTable.frame.size.height)) < 2) {
                //user has scrolled to the bottom
                if (getNewmessage)
                    [bubbleTable reloadData];
                
                [self scrollToBottom:YES];
            } else {
                if (getNewmessage)
                    [bubbleTable reloadData];
                [self scrollToBottom:YES];
            }
            
            
            //[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if ([responseBody[@"data"] count] == 0 || [self allMessageDicsExistInBubbleData:responseBody[@"data"]]) {
                if (isShownBoard == YES) {
                    [SVProgressHUD dismiss];
                    [SVProgressHUD showSuccessWithStatus:@"Loaded"];
                }
                isLoadingNewMessages = NO;
                if (!getNewmessage) {
                    [self GetMessageHistory];
                    
                    [self scrollToBottom : YES];
                }
                return;
            }
            
            [[LocalDBManager sharedManager] saveMessagesToLocalDB:responseBody[@"data"] boardId:[NSNumber numberWithInteger:[boardid integerValue]]];
            
            @synchronized(bubbleData) {
                [self addMessagesToDataSource:responseBody[@"data"] atFirst:YES];
            }
            
            //Read Message
            NSString *strMsgIds = [lstMsgId componentsJoinedByString:@","];
            
            if ([lstMsgId count]) {
                [[YYYCommunication sharedManager] ReadMessage:[AppDelegate sharedDelegate].sessionId board_id:boardid msg_ids:strMsgIds successed:nil failure:nil];
            }
            //
            
            
            
            // continue loading messages
            [self loopLoadNewMessages];
        }else{
            if (isShownBoard == YES) {
                [SVProgressHUD dismiss];
                [SVProgressHUD showSuccessWithStatus:@"Loaded"];
            }
        }
    };
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        if (isShownBoard == YES) {
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:@"Loaded"];
        }
        [CommonMethods showAlertUsingTitle:@"Oops!" andMessage:@"Bad connection!"];
        isLoadingNewMessages = NO;
    };
    
    
    NSMutableArray *idsSentMessage = [[NSMutableArray alloc] init];
    NSString *idsSent = @"";
    for (NSDictionary *dc in [responseBody objectForKey:@"data"]) {
        NSString *idSentOne = [NSString stringWithFormat:@"%@", [dc objectForKey:@"send_from"]];
        if (![idsSentMessage containsObject:idSentOne]) {
            [idsSentMessage addObject:idSentOne];
            if ([idsSent isEqualToString:@""]) {
                idsSent = idSentOne;
            }else{
                idsSent = [NSString stringWithFormat:@"%@,%@", idsSent, idSentOne];
            }
        }
    }
    
    [[YYYCommunication sharedManager] GetMemberInfosForChat:[AppDelegate sharedDelegate].sessionId boardId:boardid userids:idsSent successed:successed failure:failure];
}
- (void)loopLoadNewMessages {
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (isShownBoard == YES) {
        [SVProgressHUD showWithStatus:@"" maskType:SVProgressHUDMaskTypeClear];
    }
    isLoadingNewMessages = YES;
    if ([bubbleData count] == 0) {
        btWrite.enabled = NO;
    }else{
        btWrite.enabled = YES;
    }
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            if (isDirectory) {
                [self realodUserInfos:_responseObject];
            }else{
                if(ABS(bubbleTable.contentOffset.y - (bubbleTable.contentSize.height - bubbleTable.frame.size.height)) < 2) {
                    //user has scrolled to the bottom
                    if (getNewmessage)
                        [bubbleTable reloadData];
                    
                    [self scrollToBottom:YES];
                } else {
                    if (getNewmessage)
                        [bubbleTable reloadData];
                    [self scrollToBottom:YES];
                }
                
                
                //[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                if ([_responseObject[@"data"] count] == 0 || [self allMessageDicsExistInBubbleData:_responseObject[@"data"]]) {
                    if (isShownBoard == YES) {
                        [SVProgressHUD dismiss];
                        [SVProgressHUD showSuccessWithStatus:@"Loaded"];
                    }
                    isLoadingNewMessages = NO;
                    if (!getNewmessage) {
                        [self GetMessageHistory];
                        
                        [self scrollToBottom : YES];
                    }
                    return;
                }
                
                [[LocalDBManager sharedManager] saveMessagesToLocalDB:_responseObject[@"data"] boardId:[NSNumber numberWithInteger:[boardid integerValue]]];
                
                @synchronized(bubbleData) {
                    [self addMessagesToDataSource:_responseObject[@"data"] atFirst:YES];
                }
                
                //Read Message
                NSString *strMsgIds = [lstMsgId componentsJoinedByString:@","];
                
                if ([lstMsgId count]) {
                    [[YYYCommunication sharedManager] ReadMessage:[AppDelegate sharedDelegate].sessionId board_id:boardid msg_ids:strMsgIds successed:nil failure:nil];
                }
                //
                
                
                
                // continue loading messages
                [self loopLoadNewMessages];
            }
        }
    };
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        //[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (isShownBoard == YES) {
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:@"Loaded"];
        }
        [CommonMethods showAlertUsingTitle:@"Oops!" andMessage:@"Bad connection!"];
        isLoadingNewMessages = NO;
    };
    
    NSDate *newestDate = nil;
    
    if (bubbleData && bubbleData.count > 0)
        newestDate = ((NSBubbleData *)bubbleData.firstObject).date;
    
    if (newestDate)
        // load 40 messages next to the most recent date
        [[YYYCommunication sharedManager] GetMessageHistory:[AppDelegate sharedDelegate].sessionId boardid:boardid number:@"40" lastdays:@"0" earlierThan:nil laterThan:newestDate successed:successed failure:failure];
    else
        // load
        [[YYYCommunication sharedManager] GetMessageHistory:[AppDelegate sharedDelegate].sessionId boardid:boardid number:@"40" lastdays:@"0" earlierThan:nil laterThan:nil successed:successed failure:failure];
}

-(void)checkAction:(NSString *)msgid :(int)status
{
    btDelete.enabled = bubbleTable.lstSelected.count;
}

-(void)newMessage : (NSNotification*) _notification
{
    NSArray *lstMessage = [_notification.userInfo objectForKey:@"data"];
    for (NSDictionary *dict in lstMessage)
    {
        if ([[NSString stringWithFormat:@"%@",[dict objectForKey:@"board_id"]] isEqualToString:[NSString stringWithFormat:@"%@",boardid]])
        {
            if ([bubbleData count] == 0) {
                isLoadingNewMessages = NO;
                isShownBoard = NO;
            }
            if (!isLoadingNewMessages){
                // get messages later than the last recent message
                getNewmessage = YES;
                [self loopLoadNewMessages];
            }
            /*
             for (NSDictionary *msg in [dict objectForKey:@"messages"])
             {
             NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
             [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
             [formatter setTimeZone :[NSTimeZone timeZoneForSecondsFromGMT: 0]];
             NSDate *utcdate = [formatter dateFromString:[NSString stringWithFormat:@"%@",[msg objectForKey:@"send_time"]]];
             
             [formatter setTimeZone:[NSTimeZone localTimeZone]];
             NSDate *localdate = [formatter dateFromString:[formatter stringFromDate:utcdate]];
             
             //Read Message
             [[YYYCommunication sharedManager] ReadMessage:[AppDelegate sharedDelegate].sessionId board_id:boardid msg_ids:[msg objectForKey:@"msg_id"]  successed:nil failure:nil];
             //
             
             if (![[NSString stringWithFormat:@"%@",[msg objectForKey:@"send_from"]] isEqualToString:[AppDelegate sharedDelegate].userId])
             {
             if ([lstMsgId containsObject:[msg objectForKey:@"msg_id"]]) {
             continue;
             }
             
             [lstMsgId addObject:[msg objectForKey:@"msg_id"]];
             
             NSString *photoURL = @"";
             NSString *fname = @"";
             NSString *lname = @"";
             
             for (NSDictionary *user in lstUsers)
             {
             if ([[user objectForKey:@"user_id"] intValue] == [[msg objectForKey:@"send_from"] intValue]) {
             photoURL	= [user objectForKey:@"photo_url"];
             fname		= [user objectForKey:@"fname"];
             lname		= [user objectForKey:@"lname"];
             break;
             }
             }
             
             if ([[msg objectForKey:@"msgType"] intValue] == 1)
             {
             if ([[msg objectForKey:@"content"] rangeOfString:MAPBOUND].location == 0)
             {
             NSBubbleData *sayBubble = [NSBubbleData dataWithMap:[[msg objectForKey:@"content"] substringFromIndex:MAPBOUND.length] date:localdate type:BubbleTypeSomeoneElse];
             sayBubble.msg_id = [NSString stringWithFormat:@"%@",[msg objectForKey:@"msg_id"]];
             sayBubble.delegate = self;
             sayBubble.msg_userid = [NSString stringWithFormat:@"%@",[msg objectForKey:@"send_from"]];
             sayBubble.msg_userfname = fname;
             sayBubble.msg_userlname = lname;
             sayBubble.avatar_url = [NSURL URLWithString:photoURL];
             [bubbleData addObject:sayBubble];
             }
             else
             {
             NSBubbleData *sayBubble = [NSBubbleData dataWithText:[msg objectForKey:@"content"] date:localdate type:BubbleTypeSomeoneElse];
             sayBubble.avatar_url = [NSURL URLWithString:photoURL];
             sayBubble.msg_id = [NSString stringWithFormat:@"%@",[msg objectForKey:@"msg_id"]];
             sayBubble.msg_userid = [NSString stringWithFormat:@"%@",[msg objectForKey:@"send_from"]];
             sayBubble.msg_userfname = fname;
             sayBubble.msg_userlname = lname;
             [bubbleData addObject:sayBubble];
             }
             }
             else
             {
             NSString *content = [msg objectForKey:@"content"];
             id jsonData = [content dataUsingEncoding:NSUTF8StringEncoding]; //if input is NSString
             id dictMsg = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
             
             if([[dictMsg objectForKey:@"file_type"] isEqualToString:@"photo"])
             {
             NSBubbleData *sayBubble = [NSBubbleData dataWithImage:[dictMsg objectForKey:@"url"] date:localdate type:BubbleTypeSomeoneElse];
             sayBubble.delegate = self;
             sayBubble.msg_id = [NSString stringWithFormat:@"%@",[msg objectForKey:@"msg_id"]];
             sayBubble.avatar_url = [NSURL URLWithString:photoURL];
             sayBubble.msg_userid = [NSString stringWithFormat:@"%@",[msg objectForKey:@"send_from"]];
             sayBubble.msg_userfname = fname;
             sayBubble.msg_userlname = lname;
             [bubbleData addObject:sayBubble];
             }
             else if ([[dictMsg objectForKey:@"file_type"] isEqualToString:@"voice"])
             {
             NSBubbleData *sayBubble = [NSBubbleData dataWithAudio:[dictMsg objectForKey:@"url"] date:localdate type:BubbleTypeSomeoneElse];
             sayBubble.msg_id = [NSString stringWithFormat:@"%@",[msg objectForKey:@"msg_id"]];
             sayBubble.avatar_url = [NSURL URLWithString:photoURL];
             sayBubble.msg_userid = [NSString stringWithFormat:@"%@",[msg objectForKey:@"send_from"]];
             sayBubble.msg_userfname = fname;
             sayBubble.msg_userlname = lname;
             [bubbleData addObject:sayBubble];
             }
             else if ([[dictMsg objectForKey:@"file_type"] isEqualToString:@"video"])
             {
             NSBubbleData *sayBubble = [NSBubbleData dataWithVideo:[dictMsg objectForKey:@"url"] thumb:[dictMsg objectForKey:@"thumnail_url"] date:localdate type:BubbleTypeSomeoneElse];
             sayBubble.msg_id = [NSString stringWithFormat:@"%@",[msg objectForKey:@"msg_id"]];
             sayBubble.delegate = self;
             sayBubble.avatar_url = [NSURL URLWithString:photoURL];
             sayBubble.msg_userid = [NSString stringWithFormat:@"%@",[msg objectForKey:@"send_from"]];
             sayBubble.msg_userfname = fname;
             sayBubble.msg_userlname = lname;
             [bubbleData addObject:sayBubble];
             }
             }
             }
             }
             
             [bubbleTable reloadData];
             [self scrollToBottom:YES];
             */
        }
    }
}

-(void)sendMessage:(NSString*)text image:(NSData*)image voice:(NSData*)voice video:(NSData*)video map:(NSString*)map
{
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        
        [btSend setUserInteractionEnabled:YES];
        
        [ MBProgressHUD hideHUDForView : [AppDelegate sharedDelegate].window animated : YES ] ;
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            btWrite.enabled = YES;
            
            
            NSDictionary *dict = [_responseObject objectForKey:@"data"];
            if ([dict objectForKey:@"msg_id"])
            {
                [lstMsgId addObject:[dict objectForKey:@"msg_id"]];
            }
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            [formatter setTimeZone :[NSTimeZone timeZoneForSecondsFromGMT: 0]];
            NSDate *utcdate = [formatter dateFromString:[NSString stringWithFormat:@"%@",[dict objectForKey:@"send_time"]]];
            
            [formatter setTimeZone:[NSTimeZone localTimeZone]];
            NSDate *localdate1 = [formatter dateFromString:[formatter stringFromDate:utcdate]];
            
            if([[dict objectForKey:@"file_type"] isEqualToString:@"photo"])
            {
                NSBubbleData *sayBubble = [NSBubbleData dataWithImage:[dict objectForKey:@"url"] date:localdate1 type:BubbleTypeMine];
                sayBubble.delegate = self;
                sayBubble.msg_id = [NSString stringWithFormat:@"%@",[dict objectForKey:@"msg_id"]];
                sayBubble.msg_userid = [NSString stringWithFormat:@"%@",[AppDelegate sharedDelegate].userId];
                sayBubble.msg_userfname = [AppDelegate sharedDelegate].firstName;
                sayBubble.msg_userlname = [AppDelegate sharedDelegate].lastName;
                
                @synchronized(bubbleData) {
                    [bubbleData addObject:sayBubble];
                }
                
                [[LocalDBManager sharedManager] addBubbleData:sayBubble boardId:boardid];
            }
            else if([[dict objectForKey:@"file_type"] isEqualToString:@"voice"])
            {
                NSBubbleData *sayBubble = [NSBubbleData dataWithAudio:[dict objectForKey:@"url"] date:localdate1 type:BubbleTypeMine];
                sayBubble.msg_id = [NSString stringWithFormat:@"%@",[dict objectForKey:@"msg_id"]];
                sayBubble.msg_userid = [NSString stringWithFormat:@"%@",[AppDelegate sharedDelegate].userId];
                sayBubble.msg_userfname = [AppDelegate sharedDelegate].firstName;
                sayBubble.msg_userlname = [AppDelegate sharedDelegate].lastName;
                sayBubble.delegate = self;
                @synchronized(bubbleData) {
                    [bubbleData addObject:sayBubble];
                }
                
                [[LocalDBManager sharedManager] addBubbleData:sayBubble boardId:boardid];
            }
            else if([[dict objectForKey:@"file_type"] isEqualToString:@"video"])
            {
                NSLog(@"VIDEO__%@",[_responseObject objectForKey:@"data"]);
                NSBubbleData *sayBubble = [NSBubbleData dataWithVideo:[dict objectForKey:@"url"] thumb:[dict objectForKey:@"thumnail_url"] date:localdate1 type:BubbleTypeMine];
                sayBubble.delegate = self;
                sayBubble.msg_id = [NSString stringWithFormat:@"%@",[dict objectForKey:@"msg_id"]];
                sayBubble.msg_userid = [NSString stringWithFormat:@"%@", [AppDelegate sharedDelegate].userId];
                sayBubble.msg_userfname = [AppDelegate sharedDelegate].firstName;
                sayBubble.msg_userlname = [AppDelegate sharedDelegate].lastName;
                
                @synchronized(bubbleData) {
                    [bubbleData addObject:sayBubble];
                }
                
                [[LocalDBManager sharedManager] addBubbleData:sayBubble boardId:boardid];
            }
            else
            {
                if (text)
                {
                    [txtMessage setText:@""];
                    [self textViewDidChange:txtMessage];
                    tmpTextMessage = @"";
                    NSBubbleData *sayBubble = [NSBubbleData dataWithText:text date:localdate1 type:BubbleTypeMine];
                    sayBubble.msg_id = [NSString stringWithFormat:@"%@",[dict objectForKey:@"msg_id"]];
                    sayBubble.msg_userid = [NSString stringWithFormat:@"%@", [AppDelegate sharedDelegate].userId];
                    sayBubble.msg_userfname = [AppDelegate sharedDelegate].firstName;
                    sayBubble.msg_userlname = [AppDelegate sharedDelegate].lastName;
                    
                    @synchronized(bubbleData) {
                        [bubbleData addObject:sayBubble];
                    }
                    
                    [[LocalDBManager sharedManager] addBubbleData:sayBubble boardId:boardid];
                }
                else
                {
                    NSBubbleData *sayBubble = [NSBubbleData dataWithMap:map date:localdate1 type:BubbleTypeMine];
                    sayBubble.msg_id = [NSString stringWithFormat:@"%@",[dict objectForKey:@"msg_id"]];
                    sayBubble.msg_userid = [NSString stringWithFormat:@"%@", [AppDelegate sharedDelegate].userId];
                    sayBubble.delegate = self;
                    sayBubble.msg_userfname = [AppDelegate sharedDelegate].firstName;
                    sayBubble.msg_userlname = [AppDelegate sharedDelegate].lastName;
                    
                    @synchronized(bubbleData) {
                        [bubbleData addObject:sayBubble];
                    }
                    
                    [[LocalDBManager sharedManager] addBubbleData:sayBubble boardId:boardid];
                }
            }
            
            if ([bubbleData count] == 0) {
                btWrite.enabled = NO;
            }else{
                btWrite.enabled = YES;
            }
            [bubbleTable reloadData];
            [self scrollToBottom:YES];
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
        
        [btSend setUserInteractionEnabled:YES];
        [txtMessage setText:@""];
        tmpTextMessage = @"";
        [self textViewDidChange:txtMessage];
        [ MBProgressHUD hideHUDForView : [AppDelegate sharedDelegate].window animated : YES ] ;
        
        [ self  showAlert: @"Internet Connection Error!" ] ;
        
    } ;
    
    //082e5f286fb2
    
    if (text)
    {
        [btSend setUserInteractionEnabled:NO];
        [[YYYCommunication sharedManager] SendMessage:[AppDelegate sharedDelegate].sessionId board_id:boardid message:text successed:successed failure:failure];
    }
    else if (map)
    {
        [[YYYCommunication sharedManager] SendMessage:[AppDelegate sharedDelegate].sessionId board_id:boardid message:[NSString stringWithFormat:@"%@%@",MAPBOUND,map] successed:successed failure:nil];
    }
    else if(image)
    {
        [[YYYCommunication sharedManager] SendFile:[AppDelegate sharedDelegate].sessionId data:image thumbnail:nil name:@"file" mimetype:@"image/jpeg" boardid:boardid successed:successed failure:nil];
    }
    else if(voice)
    {
        [MBProgressHUD showHUDAddedTo:[AppDelegate sharedDelegate].window animated:YES];
        [[YYYCommunication sharedManager] SendFile:[AppDelegate sharedDelegate].sessionId data:voice thumbnail:nil name:@"file" mimetype:@"audio/aac" boardid:boardid successed:successed failure:nil];
    }
    else if(video)
    {
        [[YYYCommunication sharedManager] SendFile:[AppDelegate sharedDelegate].sessionId data:video thumbnail:thumbnail name:@"file" mimetype:@"video/quicktime" boardid:boardid successed:successed failure:nil];
    }
}

-(UIImage *)generateThumbImage : (NSURL *)url
{
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime time = [asset duration];
    time.value = 0;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *_thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
    
    //	if ([AppDelegate sharedDelegate].bCamera)
    //	{
    //        _thumbnail = [UIImage imageWithCGImage:_thumbnail.CGImage scale:_thumbnail.scale orientation:UIImageOrientationLeft];
    //    } else {
    //        if ([AppDelegate sharedDelegate].bFiltered) {
    //            _thumbnail = [UIImage imageWithCGImage:_thumbnail.CGImage scale:_thumbnail.scale orientation:UIImageOrientationLeft];
    //        }
    //    }
    
    return _thumbnail;
}

-(void)profileAction:(NSString *)userid
{
    //	YYYUserProfileViewController *viewcontroller = [[YYYUserProfileViewController alloc] initWithNibName:@"YYYUserProfileViewController" bundle:nil];
    //	viewcontroller.userid = userid;
    //	[self.navigationController presentViewController:viewcontroller animated:YES completion:nil];
    if (!isMemberForDiectory) {
        if (self.isDeletedFriend) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"GINKO" message:@"Sorry, the selection is no longer a contact." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alertView show];
            return;
        }
        [self.view endEditing:YES];
        //    [self.navigationItem setRightBarButtonItem:btContact];
        [self getContactDetail:userid];
    }
}

- (void)getContactDetail : (NSString *)_contactId
{
    APPDELEGATE.isPlayingAudio = NO;
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES];
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        NSLog(@"%@",_responseObject);
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            NSDictionary *dict = [_responseObject objectForKey:@"data"];
            
            if ([[dict objectForKey:@"sharing_status"] integerValue] == 4)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"GINKO" message:@"Oops! Contact would like to chat only" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                
                [alertView show];
                return;
            }
            
            APPDELEGATE.isShownChattingScreenWithMapVideo = YES;
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
            vc.isChat = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }else {
            NSDictionary *dictError = [_responseObject objectForKey:@"err"];
            if (dictError) {
                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Sorry, the selection is no longer a contact."];
                if ([[NSString stringWithFormat:@"%@",[dictError objectForKey:@"errCode"]] isEqualToString:@"350"]) {
                    [[AppDelegate sharedDelegate] GetContactList];
                }
            } else {
                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Failed to connect to server!"];
            }
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        NSLog(@"Connection failed - %@", _error);
    } ;
    
    [[Communication sharedManager] getContactDetail:[AppDelegate sharedDelegate].sessionId contactId:_contactId contactType:@"1" successed:successed failure:failure];
}

-(void)videoTouched:(NSString *)videoPath {
    
    APPDELEGATE.isShownChattingScreenWithMapVideo = YES;
    // Check cache first
    NSString *cachedPath = [LocalDBManager checkCachedFileExist:videoPath];
    
    if (cachedPath) {
        // load from cache
        [self playVideoAtLocalPath:cachedPath];
    } else {
        // save to temp directory
        NSURL *url = [NSURL URLWithString:videoPath];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
        NSProgress *progress;
        
        downloadProgressHUD = [MBProgressHUD showHUDAddedTo:[AppDelegate sharedDelegate].window animated:YES];
        downloadProgressHUD.mode = MBProgressHUDModeDeterminate;
        
        NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            return [NSURL fileURLWithPath:[LocalDBManager getCachedFileNameFromRemotePath:videoPath]];
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            [progress removeObserver:self forKeyPath:@"fractionCompleted" context:NULL];
            
            [downloadProgressHUD hide:YES];
            if (!error) {
                [self playVideoAtLocalPath:[LocalDBManager getCachedFileNameFromRemotePath:videoPath]];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not download video, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }];
        
        [downloadTask resume];
        [progress addObserver:self
                   forKeyPath:@"fractionCompleted"
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
        
        //        data = [NSData dataWithContentsOfURL:[NSURL URLWithString:audioUrl]];
        //        [data writeToFile:[LocalDBManager getCachedFileNameFromRemotePath:audioUrl] atomically:YES];
    }
}

- (void)playVideoAtLocalPath:(NSString *)videoPath {
    playerVC = [[MPMoviePlayerViewController alloc] init];
    
    playerVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    playerVC.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
    playerVC.moviePlayer.contentURL = [NSURL fileURLWithPath:videoPath];
    
    [self presentMoviePlayerViewControllerAnimated:playerVC];
}

- (void)shareWithPath:(NSString *)videoPath {
    NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
    NSArray* dataToShare = @[SHARE_MAIL_TEXT, videoURL];
    UIActivityViewController* activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:dataToShare
                                      applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:nil];
}


- (void)setPhoneNumbers:(NSDictionary*)dic
{
    if([dic objectForKey:@"phones"] != nil)
    {
        arrPhone = [dic objectForKey:@"phones"];
    }
}
//-(void)movieFinishedCallback:(NSNotification*)aNotification
//{
//	// Obtain the reason why the movie playback finished
//    NSNumber *finishReason = [[aNotification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
//
//    // Dismiss the view controller ONLY when the reason is not "playback ended"
//    if ([finishReason intValue] != MPMovieFinishReasonPlaybackEnded)
//    {
//        MPMoviePlayerController *moviePlayer = [aNotification object];
//
//        // Remove this class from the observers
//        [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                        name:MPMoviePlayerPlaybackDidFinishNotification
//                                                      object:moviePlayer];
////		[moviePlayer.view removeFromSuperview];
//	}
//}

-(IBAction)btPhotoDoneClick:(id)sender
{
    [imvPhoto setImage:nil];
    [vwPhoto removeFromSuperview];
}

-(IBAction)btContactClick:(id)sender
{
    YYYSelectContactController *viewcontroller = [[YYYSelectContactController alloc] initWithNibName:@"YYYSelectContactController" bundle:nil];
    viewcontroller.boardid = boardid;
    viewcontroller.viewcontroller = self;
    
    NSMutableArray *lstTempIds = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in lstUsers)
    {
        [lstTempIds addObject:[dict objectForKey:@"user_id"]];
    }
    
    viewcontroller.lstCurrentUserIds = lstTempIds;
    [self.navigationController presentViewController:viewcontroller animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NSBubbleDataDelegate
-(void)mapTouched:(float)latitude :(float)longitude
{
    
    APPDELEGATE.isShownChattingScreenWithMapVideo = YES;
    APPDELEGATE.isPlayingAudio = NO;
    if (!bConnection) {
        [self showAlert:@"Oops! Internet Connection Error"];
        return;
    }
    
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    CLLocation *newLocation = [[CLLocation alloc]initWithLatitude:latitude
                                                        longitude:longitude];
    
    [geocoder reverseGeocodeLocation:newLocation
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       
                       if (error) {
                           [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Internet Connection Error!"];
                           return;
                       }
                       
                       if (placemarks && placemarks.count > 0)
                       {
                           CLPlacemark *placemark = placemarks[0];
                           
                           NSDictionary *addressDictionary =
                           placemark.addressDictionary;
                           
                           NSString *address = [addressDictionary
                                                objectForKey:(NSString *)kABPersonAddressStreetKey];
                           NSString *city = [addressDictionary
                                             objectForKey:(NSString *)kABPersonAddressCityKey];
                           NSString *state = [addressDictionary
                                              objectForKey:(NSString *)kABPersonAddressStateKey];
                           NSString *zip = [addressDictionary
                                            objectForKey:(NSString *)kABPersonAddressZIPKey];
                           
                           if (!address) address = @"";
                           if (!city) city = @"";
                           if (!state) state = @"";
                           if (!zip) zip = @"";
                           
                           MKPlacemark *place = [[MKPlacemark alloc]
                                                 initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude)
                                                 addressDictionary:nil];
                           
                           MKMapItem *mapItem = [[MKMapItem alloc]initWithPlacemark:place];
                           [mapItem setName: [NSString stringWithFormat:@"%@ %@ %@ %@", address,city, state, zip]];
                           [mapItem openInMapsWithLaunchOptions:nil];
                       }
                       
                   }];
    
    
    
    
    //	[SVGeocoder reverseGeocode:CLLocationCoordinate2DMake(latitude, longitude)
    //                    completion:^(NSArray *placemarks, NSHTTPURLResponse *urlResponse, NSError *error)
    //	 {
    //		 if (!error)
    //		 {
    //			 MKPlacemark *place = [[MKPlacemark alloc]
    //								   initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude)
    //								   addressDictionary:nil];
    //
    //			 MKMapItem *mapItem = [[MKMapItem alloc]initWithPlacemark:place];
    //			 [mapItem setName:[NSString stringWithFormat:@"%@",[(SVPlacemark*)[placemarks objectAtIndex:0] formattedAddress]]];
    //			 [mapItem openInMapsWithLaunchOptions:nil];
    //		 }
    //		 else
    //		 {
    //			 NSLog(@"%@",[error description]);
    //		 }
    //	 }];
}

- (void)videoLongPressed:(NSString *)videoPath {
    
    APPDELEGATE.isPlayingAudio = NO;
    longPressedDataType = NSBubbleContentTypeVideo;
    longPressedDataPath = videoPath;
    [self.view endEditing:YES];
    [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share", nil] showInView:self.navigationController.view];
}

- (void)voiceLongPressed:(NSString *)audioPath {
    
    APPDELEGATE.isPlayingAudio = NO;
    longPressedDataType = NSBubbleContentTypeVoice;
    longPressedDataPath = audioPath;
    [self.view endEditing:YES];
    [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share", nil] showInView:self.navigationController.view];
}

-(void)imageTouched:(NSString *)imageurl
{
    [self.view endEditing:YES];
    //    [self.navigationItem setRightBarButtonItem:btContact];
    APPDELEGATE.isPlayingAudio = NO;
    [imvPhoto setImageWithURL:[NSURL URLWithString:imageurl]];
    [[AppDelegate sharedDelegate].window addSubview:vwPhoto];
}

- (void)photoLongPressed:(NSString *)photoPath {
    
    APPDELEGATE.isPlayingAudio = NO;
    longPressedDataType = NSBubbleContentTypePhoto;
    longPressedDataPath = photoPath;
    [self.view endEditing:YES];
    [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share", nil] showInView:self.navigationController.view];
}

#pragma mark - Function

- (void)setEnabledOfSubviewsOfvwSend:(BOOL)enabled {
    for (UIView *view in vwSend.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            ((UIButton*)view).enabled = enabled;
        }
    }
    if ([bubbleData count] == 0) {
        btWrite.enabled = NO;
    }else{
        btWrite.enabled = YES;
    }
    txtMessage.userInteractionEnabled = enabled;
}

#pragma mark - Download progress

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"fractionCompleted"]) {
        NSProgress *progress = (NSProgress *)object;
        NSLog(@"Progress… %f", progress.fractionCompleted);
        downloadProgressHUD.progress = progress.fractionCompleted;
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != (actionSheet.numberOfButtons - 1))
    {
        switch ([actionSheet tag]) {
            case 100:
            {
                if (buttonIndex == 0) {
                    [self OpenConference:1];
                }else if(buttonIndex == 1){
                    [self OpenConference:2];
                }else{
                    if ([[arrPhone objectAtIndex:buttonIndex-2] rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]].location == NSNotFound) {
                        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Invalid mobile number." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                        return;
                    }
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [CommonMethods removeNanString:[arrPhone objectAtIndex:buttonIndex-2]]]]];
                }
                break;
            }
            default:
                break;
        }
    }
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        switch (longPressedDataType) {
            case NSBubbleContentTypeVideo:
            {
                // Check cache first
                NSString *cachedPath = [LocalDBManager checkCachedFileExist:longPressedDataPath];
                
                if (cachedPath) {
                    // load from cache
                    [self shareWithPath:cachedPath];
                } else {
                    // save to temp directory
                    NSURL *url = [NSURL URLWithString:longPressedDataPath];
                    NSURLRequest *request = [NSURLRequest requestWithURL:url];
                    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
                    NSProgress *progress;
                    
                    downloadProgressHUD = [MBProgressHUD showHUDAddedTo:[AppDelegate sharedDelegate].window animated:YES];
                    downloadProgressHUD.mode = MBProgressHUDModeDeterminate;
                    
                    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                        return [NSURL fileURLWithPath:[LocalDBManager getCachedFileNameFromRemotePath:longPressedDataPath]];
                    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                        [progress removeObserver:self forKeyPath:@"fractionCompleted" context:NULL];
                        [downloadProgressHUD hide:YES];
                        if (!error) {
                            [self shareWithPath:[LocalDBManager getCachedFileNameFromRemotePath:longPressedDataPath]];
                        } else {
                            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not download video, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                        }
                    }];
                    
                    [downloadTask resume];
                    [progress addObserver:self
                               forKeyPath:@"fractionCompleted"
                                  options:NSKeyValueObservingOptionNew
                                  context:NULL];
                    
                    //        data = [NSData dataWithContentsOfURL:[NSURL URLWithString:audioUrl]];
                    //        [data writeToFile:[LocalDBManager getCachedFileNameFromRemotePath:audioUrl] atomically:YES];
                }
            }
                break;
                
            case NSBubbleContentTypeVoice:
            {
                NSString *cachedPath = [LocalDBManager checkCachedFileExist:longPressedDataPath];
                
                if (cachedPath) {
                    // load from cache
                    [self shareWithPath:cachedPath];
                }
            }
                break;
                
            case NSBubbleContentTypePhoto:
            {
                NSString *cachedPath = [LocalDBManager checkCachedFileExist:longPressedDataPath];
                
                if (cachedPath) {
                    // load from cache
                    [self shareWithPath:cachedPath];
                }
            }
                break;
                
            default:
                break;
        }
    }
}
- (void)receviedMessage{
    //if (APPDELEGATE.isReceivedChattingMessage) {
    APPDELEGATE.isReceivedChattingMessage = NO;
    getNewmessage = YES;
    [self loopLoadNewMessages];
    //}
}
@end
