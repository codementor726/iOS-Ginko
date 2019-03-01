//
//  AppDelegate.m
//  Ginko
//
//  Created by Qi Song on 29/3/14.
//  Copyright (c) 2014 Qi Song. All rights reserved.
//
// --- Headers ---;
#import "AppDelegate.h"
#import "ContactViewController.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>

//integration class
#import "CIHomeViewController.h"

//importer class
#import "CIImportViewController.h"

// Wang Class
#import <AVFoundation/AVFoundation.h>

#import "YYYViewController.h"
#import "SetupViewController.h"

#import "YYYCommunication.h"
#import "MBProgressHUD.h"
// Wang Class end

//Wang Class IM
#import <CFNetwork/CFNetwork.h>
#import "OpenUDID.h"
#import "JCNotificationCenter.h"
#import "JCNotificationBannerPresenterIOS7Style.h"
//Wang Class IM end

#import "CBImportItemViewController.h"
#import "CBDetailViewController.h"
#import "CBImportHomeViewController.h"

#import "RequestViewController.h"
#import "TabRequestController.h"
#import "ChatViewController.h"
#import "TabBarController.h"
#import "NotExchangedViewController.h"
#import "ExchangedViewController.h"
#import "ManageProfileViewController.h"
#import "MobileVerificationViewController.h"
#import "YYYChatViewController.h"

#import "PreviewMainEntityViewController.h"
#import "AllEntityPreviewViewController.h"
#import "MainEntityViewController.h"
#import "AllEntityViewController.h"
#import "CreateEntityViewController.h"
#import "PreviewEntityViewController.h"
#import "ManageEntityViewController.h"
#import "GinkoMeTabController.h"
#import "ScanMeViewController.h"

#import "IMVideoCameraController.h"
#import "IMVideoViewController.h"
#import "VideoCameraController.h"
#import "IMVideoEditController.h"
#import "VideoEditController.h"
#import "EntityInviteContactsViewController.h"
#import "QRReaderViewController.h"
#import "ProfileViewController.h"
#import "PreviewProfileViewController.h"
#import "GreyAddNotesController.h"
#import "ContactFilterViewController.h"
#import "IMPhotoEditController.h"
#import "IMPhotoViewController.h"
#import "IMPhotoCameraController.h"
#import "PhotoCameraController.h"
#import "AddSubEntitiesViewController.h"
#import "AddInfoOfSubEntityViewController.h"
#import "GroupsViewController.h"
#import "YYYLocationController.h"
#import "ELCImagePickerController.h"
#import "YYYSelectContactController.h"

#import "DirectoryInviteContactsViewController.h"
#import "CreateDirectoryViewController.h"
#import "ManageDirectoryViewController.h"
#import "PreDirectoryViewController.h"
#import "SelectUserForConferenceViewController.h"
//#import <Fabric/Fabric.h>
//#import <Crashlytics/Crashlytics.h>

#import <PushKit/PushKit.h>

//video/voice conference

#import "RTCPeerConnectionFactory.h"

#import "VideoVoiceConferenceViewController.h"

// --- Defines ---;

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)


// AppDelegate Class;

@implementation AppDelegate

@synthesize currentImagePickerController;

@synthesize didFinishFlag;
@synthesize didTurnOnFlag;

@synthesize allFetchEntityes;
@synthesize timerIfNoOpenApp, timerTillAccept, timerCheckingConferenceView, sheetToConference;
@synthesize countTillAccept;

@synthesize locationFlag;
@synthesize intervalIndex;
@synthesize locationManager;
@synthesize currentLocation;
@synthesize currentLocationforMultiLocations;
@synthesize currentCount;
@synthesize gpsCallTimer;
@synthesize timerFlag;
@synthesize myName;

@synthesize contactList;
@synthesize exchangedList;
@synthesize notExchangedList;
@synthesize totalList;

@synthesize existedContactIDs;

@synthesize enterTime;
@synthesize activeTime;
@synthesize approveFlag;

@synthesize userInfoForPushnotification;

@synthesize isStartedLocationUpdate;

@synthesize isCalledContactsReload;
@synthesize  isCalledSyncContacts;

@synthesize calledloadDetectedContacts;

@synthesize calledGetGroups;

@synthesize callAction;
// -----------------

// importer class
@synthesize importDict;

@synthesize orignialTimeInterval;

// Wang Class
@synthesize strDeviceToken, voIPDeviceToken;
@synthesize dictInfoHome;
@synthesize dictInfoWork;

@synthesize sessionId;
@synthesize firstName;
@synthesize userId;

@synthesize isNewContactFind;

@synthesize homeVideoURL;
@synthesize workVideoURL;
// Wang Class end

//Wang Class IM
@synthesize isChatScreen;
@synthesize isExchageScreen;
@synthesize isRequestScreen;
@synthesize isSproutScreen;
@synthesize isWallScreen;
@synthesize isChatViewScreen;
@synthesize isGroupScreen;
@synthesize bCamera;
@synthesize bFiltered;
@synthesize currentBoardID;

@synthesize boardIdForPushnotification;

@synthesize isShownSpinner;

@synthesize deactiveForAccount;

@synthesize isPlayingAudio;

@synthesize isSleepMode;

@synthesize isCreateEntityViewController;

@synthesize isShownChattingScreenWithMapVideo;
@synthesize isReceivedChattingMessage;

@synthesize isPreviewPhoneVerifyView;

@synthesize isNotificationForChatting;
//Wang Class IM end

@synthesize countGPScontactList;
@synthesize isCalledGetContactList;

@synthesize gpsStatusOfCurrentUser;

@synthesize removedMsgIdsForEntity;
//Wang Class AE
//@synthesize imgEntityBackground;
//@synthesize imgEntityForeground;
//@synthesize strCurrentEntityID;
//@synthesize strEntityBackgroundID;
//@synthesize strEntityForegroundID;
@synthesize newChatNum, xchageReqNum, notExchangeNum, bValid;
//Wang Class AE end

@synthesize strSetupPage;

// Core-data related properties
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize isVideoAndVoiceConferenceScreen;
@synthesize isOwnerForConference;
@synthesize isConferenceView;
@synthesize isReceiverForConferenceSDP, isReceiverForConferenceCandidate;
@synthesize userInfoByPushForConference, userInfoByPushForSDP, userInfoByPushForCandidate;
@synthesize isJoinedOnConference;
@synthesize conferenceMembersForVideoCalling;
@synthesize userIdsForSenddingSDP, userIdsForSendingCandidate;

@synthesize userDicForCalling;

@synthesize isOpenApp;
@synthesize arrhandlePush;

@synthesize endTypeForConference, conferenceStatus;
@synthesize conferenceId;

@synthesize uuidForReceiver,countForActionSheet;

// view type
- (int)viewType {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"viewType"])
        return [[userDefaults objectForKey:@"viewType"] intValue];
    else
        return 1;
}

- (void)setViewType:(int)viewType {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(viewType) forKey:@"viewType"];
    [userDefaults synchronize];
}

// Wang Class
+(AppDelegate*)sharedDelegate
{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}
// Wang Class end

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //    [Fabric with:@[CrashlyticsKit]];
    
    // Wang Class
    
    
    currentImagePickerController = [[UIImagePickerController alloc] init];
    
    isOpenApp = NO;
    arrhandlePush = [[NSMutableArray alloc] init];
    uuidForReceiver = [NSUUID new];
    
    [self voipRegistration];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.viewController = [[YYYViewController alloc] initWithNibName:@"YYYViewController" bundle:nil];
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    self.window.rootViewController = controller;
    [self.window makeKeyAndVisible];

    NSLog(@"iOS Version : %@", [[UIDevice currentDevice] systemVersion]);
    
    if( SYSTEM_VERSION_LESS_THAN( @"10.0" ) )
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound |    UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];

    }
    else
    {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error)
         {
             if( !error )
             {
                 [[UIApplication sharedApplication] registerForRemoteNotifications];  // required to get the app to do anything at all about push notifications
                 NSLog( @"Push registration success." );
             }
             else
             {
                 NSLog( @"Push registration FAILED" );
                 NSLog( @"ERROR: %@ - %@", error.localizedFailureReason, error.localizedDescription );
                 NSLog( @"SUGGESTIONS: %@ - %@", error.localizedRecoveryOptions, error.localizedRecoverySuggestion );  
             }  
         }];  
    }
    isStartedLocationUpdate = NO;
    
    // we have been launched with a URL
    if ( [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey] != nil )
    {
        NSURL *url = (NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
        
        if([url.absoluteString rangeOfString:@"://activate/key:"].location != NSNotFound)
        {
            NSString *key = [url.absoluteString substringFromIndex:[url.absoluteString rangeOfString:@"://activate/key:"].location + 16];
            [self acceptLogin:key];
        }
    }
    
    UINavigationBar* navAppearance = [UINavigationBar appearance];
    UIImage *imgForBack = [ self imageWithColor:[UIColor colorWithRed:196.0f/255.0f green:255.0f/255.0f blue:182.0f/255.0f alpha:1.0f]];
    [navAppearance setBackgroundImage:imgForBack forBarMetrics:UIBarMetricsDefault];
    [navAppearance setTintColor:[UIColor blackColor]];
    [navAppearance setBarTintColor:[UIColor colorWithRed:196.0f/255.0f green:255.0f/255.0f blue:182.0f/255.0f alpha:1.0f]];
    
    if (!dictInfoHome)
    {
        dictInfoHome = [[NSMutableDictionary alloc] init];
        dictInfoWork = [[NSMutableDictionary alloc] init];
        
        [dictInfoHome setObject:@"0" forKey:@"Private"];
        [dictInfoWork setObject:@"0" forKey:@"Private"];
        
        [dictInfoHome setObject:@"0" forKey:@"Abbr"];
        [dictInfoWork setObject:@"0" forKey:@"Abbr"];
    }
    
    isChatScreen = NO;
    isExchageScreen = NO;
    isRequestScreen = NO;
    isSproutScreen = NO;
    isWallScreen = NO;
    isChatViewScreen = NO;
    isGroupScreen = NO;
    
    isPlayingAudio = NO;
    
    deactiveForAccount = NO;
    
    isSleepMode = NO;
    
    isCreateEntityViewController = NO;
    
    isShownSpinner = NO;
    
    isCalledContactsReload = YES;
    isCalledSyncContacts = YES;
    
    calledloadDetectedContacts = NO;
    // Wang Class IM end
    
    countGPScontactList = 0;
    isCalledGetContactList = YES;
    
    isShownChattingScreenWithMapVideo = NO;
    isReceivedChattingMessage = NO;
    
    calledGetGroups = NO;
    
    isPreviewPhoneVerifyView = NO;
    isNotificationForChatting = NO;
    
    removedMsgIdsForEntity = @"";
    
    isVideoAndVoiceConferenceScreen = NO;
    isOwnerForConference = NO;
    isReceiverForConferenceSDP = NO;
    isReceiverForConferenceCandidate = NO;
    isJoinedOnConference = NO;
    isConferenceView = NO;
    conferenceMembersForVideoCalling = [[NSMutableArray alloc] init];
    userIdsForSenddingSDP = [[NSMutableArray alloc] init];
    userIdsForSendingCandidate = [[NSMutableArray alloc] init];
    
    endTypeForConference = 10;  //default
    conferenceStatus = 0;
    conferenceId = @"";
    //Sun class
    [[GlobalData sharedData] loadInitData];
    
    //-------------------
    /* //qi parse
     // ****************************************************************************
     // Uncomment and fill in with your Parse credentials:
     [Parse setApplicationId:@"E1gIiKDC33BGOIfUrQuA6835PGG9HApv9AwiKD6O" clientKey:@"CRTStHEm2N0p0scsvbPgaNl7D13pQNUkI0wkDp8X"];
     // ****************************************************************************
     */
    
    intervalIndex = 0;
    gpsCallTimer = [[NSTimer alloc] init];
    timerIfNoOpenApp = [[NSTimer alloc] init];
    timerTillAccept = [[NSTimer alloc] init];
    timerCheckingConferenceView = [[NSTimer alloc] init];
    countTillAccept = 0;
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"INTERVAL_INDEX"])
    {
        intervalIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"INTERVAL_INDEX"];
    }/*
      if (intervalIndex == 7)
      locationFlag = NO;
      else
      {
      locationFlag = YES;
      [self refreshLocationUpdating];
      }*/
    
    enterTime = 0;
    activeTime = 0;
    
    currentCount = -100;
    //    self.window.rootViewController = self.viewController;  //Wang Class Ignore
    //    [self.window makeKeyAndVisible];  //Wang Class Ignore
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    
    [locationManager startUpdatingLocation];//currentLocationforMultiLocations
    contactList = [[NSMutableArray alloc] init];
    exchangedList = [[NSMutableArray alloc] init];
    notExchangedList = [[NSMutableArray alloc] init];
    totalList = [[NSArray alloc] init];
    
    existedContactIDs = [[NSMutableArray alloc] init];
    
    self.videoID = @"";
    self.videoEntityID = @"";
    
    NSString *file = [NSHomeDirectory() stringByAppendingPathComponent:@"iTunesMetadata.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
        NSLog(@"From App Store!");
    }
    NSLog(@"Route: %@", TEMP_IMAGE_PATH);
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    //video/voice conference
    
    [RTCPeerConnectionFactory initializeSSL];
    return YES;
}

// Register for VoIP notifications
- (void) voipRegistration {
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    // Create a push registry object
    PKPushRegistry * voipRegistry = [[PKPushRegistry alloc] initWithQueue: mainQueue];
    // Set the registry's delegate to self
    voipRegistry.delegate = self;
    // Set the push type to VoIP
    voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
}

// Handle updated push credentials
- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials: (PKPushCredentials *)credentials forType:(NSString *)type {
    // Register VoIP push token (a property of PKPushCredentials) with server
    voIPDeviceToken = [[[[credentials.token description]
                        stringByReplacingOccurrencesOfString: @"<" withString: @""]
                       stringByReplacingOccurrencesOfString: @">" withString: @""]
                      stringByReplacingOccurrencesOfString: @" " withString: @""];
    
}

- (void)initMemberForConference:(NSDictionary *)infoCalling{
    // init memebers
    [APPDELEGATE.conferenceMembersForVideoCalling removeAllObjects];
    
    NSArray *idsOfConference = [[infoCalling objectForKey:@"invited_uids"] componentsSeparatedByString:@","];
    
    for (NSDictionary * memberOfConference in [infoCalling objectForKey:@"userInfo"]) {
        if ([[memberOfConference objectForKey:@"id"] integerValue] != [userId integerValue]) {
            NSMutableDictionary *dictOfUser = [[NSMutableDictionary alloc] init];
            [dictOfUser setObject:[memberOfConference objectForKey:@"id"] forKey:@"user_id"];
            [dictOfUser setObject:[memberOfConference objectForKey:@"name"] forKey:@"name"];
            [dictOfUser setObject:[memberOfConference objectForKey:@"photo_url"] forKey:@"photo_url"];
            
            
            if ([[infoCalling objectForKey:@"callType"] integerValue] == 1) {
                [dictOfUser setObject:@"on" forKey:@"videoStatus"];
            }else{
                [dictOfUser setObject:@"off" forKey:@"videoStatus"];
            }
            [dictOfUser setObject:@"on" forKey:@"voiceStatus"];
            [dictOfUser setObject:@(1) forKey:@"conferenceStatus"];
            if ([[infoCalling objectForKey:@"uid"] integerValue] == [[memberOfConference objectForKey:@"id"] integerValue])
            {
                [dictOfUser setObject:@(1) forKey:@"isOwner"];
            }else{
                [dictOfUser setObject:@(0) forKey:@"isOwner"];
            }
            BOOL isInvitedMember = NO;
            for (int i=0; i < idsOfConference.count; i++) {
                if ([idsOfConference[i] integerValue] == [[memberOfConference objectForKey:@"id"] integerValue]) {
                    isInvitedMember = YES;
                }
            }
            if (isInvitedMember) {
                [dictOfUser setObject:@(1) forKey:@"isInvited"];
            }else{
                [dictOfUser setObject:@(0) forKey:@"isInvited"];
            }
            [dictOfUser setObject:@(0) forKey:@"isInvitedByMe"];
            
            [APPDELEGATE.conferenceMembersForVideoCalling addObject:dictOfUser];
        }
    }
}
// Handle incoming pushes
- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type {
    // Process the received push
    
    NSDictionary *pushInfo = payload.dictionaryPayload;
    
    if ([[pushInfo objectForKey:@"type"] isEqualToString:@"test"]){
        NSString *alert = [[pushInfo objectForKey:@"aps"] objectForKey:@"alert"];
        [[[UIAlertView alloc] initWithTitle:@"VOIP TEST" message:alert delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
    
    if( SYSTEM_VERSION_LESS_THAN( @"10.0" ) )
    {
        if ([[pushInfo objectForKey:@"type"] isEqualToString:@"video_call"] && [pushInfo[@"action"] isEqualToString:@"initial"]) {
            userDicForCalling = payload.dictionaryPayload;
            conferenceStatus = 1;
            [self initMemberForConference:userDicForCalling];
            [self acceptCallingForUser];
            conferenceId = [pushInfo objectForKey:@"board_id"];
        }else if ([[pushInfo objectForKey:@"type"] isEqualToString:@"video_call"] && [pushInfo[@"action"] isEqualToString:@"accept"]){
            if (conferenceStatus == 1) {
                conferenceStatus = 2;
            }
            for (int i = 0 ; i < [conferenceMembersForVideoCalling count]; i ++) {
                NSMutableDictionary *changeUser = [[conferenceMembersForVideoCalling objectAtIndex:i] mutableCopy];
                if ([[changeUser objectForKey:@"user_id"] integerValue] == [pushInfo[@"uid"] integerValue]) {
                    [changeUser setObject:@(2) forKey:@"conferenceStatus"];
                    [conferenceMembersForVideoCalling replaceObjectAtIndex:i withObject:changeUser];
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GINKO_VIDEO_CONFERENCE object:nil userInfo:pushInfo];
        }else if ([[pushInfo objectForKey:@"type"] isEqualToString:@"video_call"] && [pushInfo[@"action"] isEqualToString:@"hangup"]){
            
            for (int i = 0 ; i < [conferenceMembersForVideoCalling count]; i ++) {
                NSMutableDictionary *changeUser = [[conferenceMembersForVideoCalling objectAtIndex:i] mutableCopy];
                if ([[changeUser objectForKey:@"user_id"] integerValue] == [pushInfo[@"uid"] integerValue]) {
                    if ([[changeUser objectForKey:@"conferenceStatus"] integerValue] == 8) {
                        [changeUser setObject:@(12) forKey:@"conferenceStatus"];
                    }else if ([[changeUser objectForKey:@"conferenceStatus"] integerValue] == 2) {
                        [changeUser setObject:@(13) forKey:@"conferenceStatus"];
                    }else if ([[changeUser objectForKey:@"conferenceStatus"] integerValue] == 3) {
                        [changeUser setObject:@(11) forKey:@"conferenceStatus"];
                    }
                    [conferenceMembersForVideoCalling replaceObjectAtIndex:i withObject:changeUser];
                }
            }
            BOOL isCheckForInit = NO;
            for (NSDictionary *dic in conferenceMembersForVideoCalling) {
                if ([[dic objectForKey:@"conferenceStatus"] integerValue] < 10) {
                    isCheckForInit = YES;
                }
            }
            if (!isCheckForInit && !isConferenceView) {
                if (conferenceStatus == 1){
                    conferenceStatus = 0;
                    endTypeForConference = 10;
                    
                    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
                    {
                        if ([[_responseObject objectForKey:@"success"] boolValue]) {
                            
                            [self performEndCallActionWithUUID:self.uuidForReceiver];
                            [conferenceMembersForVideoCalling removeAllObjects];
                        }
                    };
                    
                    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
                    {
                    };
                    [[YYYCommunication sharedManager] HangupVideoConference:APPDELEGATE.sessionId boardId:[pushInfo objectForKey:@"board_id"] endType:4 successed:successed failure:failure];
                }
            }
            if (isConferenceView) {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HANGUP_VIDEO_CONFERENCE object:nil userInfo:pushInfo];
            }
        }else if ([[pushInfo objectForKey:@"type"] isEqualToString:@"video_call"] && [pushInfo[@"action"] isEqualToString:@"sdp_available"]){
            BOOL isCheckingExist = NO;
            for (NSDictionary *oneMember in conferenceMembersForVideoCalling) {
                if ([[oneMember objectForKey:@"user_id"] integerValue] == [pushInfo[@"uid"] integerValue]) {
                    isCheckingExist = YES;
                }
            }
            if (isCheckingExist) {
                [userIdsForSenddingSDP addObject:pushInfo[@"uid"]];
                userInfoByPushForSDP = pushInfo;
                isReceiverForConferenceSDP = YES;
                if(isJoinedOnConference){
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GET_SDP_VIDEO_CONFERENCE object:nil userInfo:pushInfo];
                }
            }
        }else if ([[pushInfo objectForKey:@"type"] isEqualToString:@"video_call"] && [pushInfo[@"action"] isEqualToString:@"candidates_available"]){
            BOOL isCheckingExist = NO;
            for (NSDictionary *oneMember in conferenceMembersForVideoCalling) {
                if ([[oneMember objectForKey:@"user_id"] integerValue] == [pushInfo[@"uid"] integerValue]) {
                    isCheckingExist = YES;
                }
            }
            if (isCheckingExist) {
                [userIdsForSendingCandidate addObject:pushInfo[@"uid"]];
                userInfoByPushForCandidate = pushInfo;
                isReceiverForConferenceCandidate = YES;
                if(isJoinedOnConference){
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GET_CANDIDATES_VIDEO_CONFERENCE object:nil userInfo:pushInfo];
                }
            }
        }else if ([[pushInfo objectForKey:@"type"] isEqualToString:@"video_call"] && [pushInfo[@"action"] isEqualToString:@"inviting"]){

            for (NSDictionary * memberOfConference in [pushInfo objectForKey:@"userInfo"]) {
                if ([[memberOfConference objectForKey:@"id"] integerValue] != [userId integerValue]) {
                    NSMutableDictionary *dictOfUser = [[NSMutableDictionary alloc] init];
                    [dictOfUser setObject:[memberOfConference objectForKey:@"id"] forKey:@"user_id"];
                    [dictOfUser setObject:[memberOfConference objectForKey:@"name"] forKey:@"name"];
                    [dictOfUser setObject:[memberOfConference objectForKey:@"photo_url"] forKey:@"photo_url"];
                    
                    if ([[pushInfo objectForKey:@"callType"] integerValue] == 1) {
                        [dictOfUser setObject:@"on" forKey:@"videoStatus"];
                    }else{
                        [dictOfUser setObject:@"off" forKey:@"videoStatus"];
                    }

                    [dictOfUser setObject:@"on" forKey:@"voiceStatus"];
                    [dictOfUser setObject:@(1) forKey:@"conferenceStatus"];
                    [dictOfUser setObject:@(0) forKey:@"isOwner"];
                    [dictOfUser setObject:@(1) forKey:@"isInvited"];
                    [dictOfUser setObject:@(0) forKey:@"isInvitedByMe"];
                    
                    [APPDELEGATE.conferenceMembersForVideoCalling addObject:dictOfUser];
                }
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_INVITE_MEMBERS_CONFERENCE object:nil userInfo:pushInfo];
        }else if ([[pushInfo objectForKey:@"type"] isEqualToString:@"video_call"] && [pushInfo[@"action"] isEqualToString:@"videooff"]){
            for (NSInteger i=0; i < APPDELEGATE.conferenceMembersForVideoCalling.count; i ++) {
                NSDictionary *dict = [APPDELEGATE.conferenceMembersForVideoCalling objectAtIndex:i];
                if ([[dict objectForKey:@"user_id"] integerValue] == [[pushInfo objectForKey:@"uid"] integerValue]) {
                    NSMutableDictionary *dictOfUser = [dict mutableCopy];
                    [dictOfUser setObject:@"off" forKey:@"videoStatus"];
                    [APPDELEGATE.conferenceMembersForVideoCalling replaceObjectAtIndex:i withObject:dictOfUser];
                    break;
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MEMEBER_STATUS_CONFERENCE object:nil userInfo:pushInfo];
        }else if ([[pushInfo objectForKey:@"type"] isEqualToString:@"video_call"] && [pushInfo[@"action"] isEqualToString:@"videoon"]){
            for (NSInteger i=0; i < APPDELEGATE.conferenceMembersForVideoCalling.count; i ++) {
                NSDictionary *dict = [APPDELEGATE.conferenceMembersForVideoCalling objectAtIndex:i];
                if ([[dict objectForKey:@"user_id"] integerValue] == [[pushInfo objectForKey:@"uid"] integerValue]) {
                    NSMutableDictionary *dictOfUser = [dict mutableCopy];
                    [dictOfUser setObject:@"on" forKey:@"videoStatus"];
                    [APPDELEGATE.conferenceMembersForVideoCalling replaceObjectAtIndex:i withObject:dictOfUser];
                    break;
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MEMEBER_STATUS_CONFERENCE object:nil userInfo:pushInfo];
        }else if ([[pushInfo objectForKey:@"type"] isEqualToString:@"video_call"] && [pushInfo[@"action"] isEqualToString:@"audiooff"]){
            for (NSInteger i=0; i < APPDELEGATE.conferenceMembersForVideoCalling.count; i ++) {
                NSDictionary *dict = [APPDELEGATE.conferenceMembersForVideoCalling objectAtIndex:i];
                if ([[dict objectForKey:@"user_id"] integerValue] == [[pushInfo objectForKey:@"uid"] integerValue]) {
                    NSMutableDictionary *dictOfUser = [dict mutableCopy];
                    [dictOfUser setObject:@"off" forKey:@"voiceStatus"];
                    [APPDELEGATE.conferenceMembersForVideoCalling replaceObjectAtIndex:i withObject:dictOfUser];
                    break;
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MEMEBER_STATUS_CONFERENCE object:nil userInfo:pushInfo];
        }else if ([[pushInfo objectForKey:@"type"] isEqualToString:@"video_call"] && [pushInfo[@"action"] isEqualToString:@"audioon"]){
            for (NSInteger i=0; i < APPDELEGATE.conferenceMembersForVideoCalling.count; i ++) {
                NSDictionary *dict = [APPDELEGATE.conferenceMembersForVideoCalling objectAtIndex:i];
                if ([[dict objectForKey:@"user_id"] integerValue] == [[pushInfo objectForKey:@"uid"] integerValue]) {
                    NSMutableDictionary *dictOfUser = [dict mutableCopy];
                    [dictOfUser setObject:@"on" forKey:@"voiceStatus"];
                    [APPDELEGATE.conferenceMembersForVideoCalling replaceObjectAtIndex:i withObject:dictOfUser];
                    break;
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MEMEBER_STATUS_CONFERENCE object:nil userInfo:pushInfo];
        }
    }else{
        if ([pushInfo objectForKey:@"board_id"]) { //chat
            boardId = [pushInfo[@"board_id"] integerValue];
            boardIdForPushnotification = boardId;
            if ([[pushInfo objectForKey:@"type"] isEqualToString:@"video_call"] && [pushInfo[@"action"] isEqualToString:@"initial"]) {
                userDicForCalling = payload.dictionaryPayload;
                conferenceId = [pushInfo objectForKey:@"board_id"];
                conferenceStatus = 1;
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GINKO_VIDEO_CONFERENCE object:nil userInfo:userDicForCalling];
                if (!isConferenceView) {
                    [self initMemberForConference:userDicForCalling];
                    self.callkitCallController = [[CXCallController alloc] init];
                    uuidForReceiver = [NSUUID new];
                    [CallManager sharedInstance].delegate = self;
                    [[CallManager sharedInstance] reportIncomingCallForUUID:uuidForReceiver phoneNumber:pushInfo[@"uname"]];
                    countTillAccept = 0;
                    timerTillAccept = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(repeatTillAccept) userInfo:nil repeats:YES];
                    
                }else{
                    [self performSelector:@selector(checkingConferenceStatus:) withObject:pushInfo afterDelay:1.0f];
                }
            }else if ([[pushInfo objectForKey:@"type"] isEqualToString:@"video_call"] && [pushInfo[@"action"] isEqualToString:@"accept"]){
                if (conferenceStatus == 1) {
                    conferenceStatus = 2;
                }
                for (int i = 0 ; i < [conferenceMembersForVideoCalling count]; i ++) {
                    NSMutableDictionary *changeUser = [[conferenceMembersForVideoCalling objectAtIndex:i] mutableCopy];
                    if ([[changeUser objectForKey:@"user_id"] integerValue] == [pushInfo[@"uid"] integerValue]) {
                        [changeUser setObject:@(2) forKey:@"conferenceStatus"];
                        [conferenceMembersForVideoCalling replaceObjectAtIndex:i withObject:changeUser];
                    }
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GINKO_VIDEO_CONFERENCE object:nil userInfo:pushInfo];
            }else if ([[pushInfo objectForKey:@"type"] isEqualToString:@"video_call"] && [pushInfo[@"action"] isEqualToString:@"hangup"]){
                BOOL isClosedByOwner = NO;
                for (int i = 0 ; i < [conferenceMembersForVideoCalling count]; i ++) {
                    NSMutableDictionary *changeUser = [[conferenceMembersForVideoCalling objectAtIndex:i] mutableCopy];
                    if ([[changeUser objectForKey:@"user_id"] integerValue] == [pushInfo[@"uid"] integerValue]) {
                        if ([[changeUser objectForKey:@"conferenceStatus"] integerValue] == 8 || [[changeUser objectForKey:@"conferenceStatus"] integerValue] == 1) {
                            [changeUser setObject:@(12) forKey:@"conferenceStatus"];
                        }else if ([[changeUser objectForKey:@"conferenceStatus"] integerValue] == 2) {
                            [changeUser setObject:@(13) forKey:@"conferenceStatus"];
                        }else if ([[changeUser objectForKey:@"conferenceStatus"] integerValue] == 3) {
                            [changeUser setObject:@(11) forKey:@"conferenceStatus"];
                        }
                        [conferenceMembersForVideoCalling replaceObjectAtIndex:i withObject:changeUser];
                        if ([changeUser objectForKey:@"isOwner"]) {
                            isClosedByOwner = YES;
                        }
                    }
                }
                BOOL isCheckForInit = NO;
                for (NSDictionary *dic in conferenceMembersForVideoCalling) {
                    if ([[dic objectForKey:@"conferenceStatus"] integerValue] < 10) {
                        isCheckForInit = YES;
                    }
                }
                if (!isCheckForInit && !isConferenceView) {
                    if (conferenceStatus == 1){
                        conferenceStatus = 0;
                        endTypeForConference = 10;
                        
                        void ( ^successed )( id _responseObject ) = ^( id _responseObject )
                        {
                            if ([[_responseObject objectForKey:@"success"] boolValue]) {
                                
                                [self performEndCallActionWithUUID:self.uuidForReceiver];
                                [conferenceMembersForVideoCalling removeAllObjects];
                            }
                        };
                        
                        void ( ^failure )( NSError* _error ) = ^( NSError* _error )
                        {
                        };
                        [[YYYCommunication sharedManager] HangupVideoConference:APPDELEGATE.sessionId boardId:[pushInfo objectForKey:@"board_id"] endType:4 successed:successed failure:failure];
                    }
                }
                
                if (!isConferenceView && isClosedByOwner  ) {
                    if (conferenceStatus == 1){
                        conferenceStatus = 0;
                        endTypeForConference = 10;
                        
                        void ( ^successed )( id _responseObject ) = ^( id _responseObject )
                        {
                            if ([[_responseObject objectForKey:@"success"] boolValue]) {
                                
                                [self performEndCallActionWithUUID:self.uuidForReceiver];
                                [conferenceMembersForVideoCalling removeAllObjects];
                            }
                        };
                        
                        void ( ^failure )( NSError* _error ) = ^( NSError* _error )
                        {
                        };
                        [[YYYCommunication sharedManager] HangupVideoConference:APPDELEGATE.sessionId boardId:[pushInfo objectForKey:@"board_id"] endType:4 successed:successed failure:failure];
                    }
                }
                
                if (isConferenceView) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HANGUP_VIDEO_CONFERENCE object:nil userInfo:pushInfo];
                }
            }else if ([[pushInfo objectForKey:@"type"] isEqualToString:@"video_call"] && [pushInfo[@"action"] isEqualToString:@"sdp_available"]){
                BOOL isCheckingExist = NO;
                for (NSDictionary *oneMember in conferenceMembersForVideoCalling) {
                    if ([[oneMember objectForKey:@"user_id"] integerValue] == [pushInfo[@"uid"] integerValue]) {
                        isCheckingExist = YES;
                    }
                }
                if (isCheckingExist) {
                    [userIdsForSenddingSDP addObject:pushInfo[@"uid"]];
                    userInfoByPushForSDP = pushInfo;
                    isReceiverForConferenceSDP = YES;
                    if(isJoinedOnConference){
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GET_SDP_VIDEO_CONFERENCE object:nil userInfo:pushInfo];
                    }
                }
            }else if ([[pushInfo objectForKey:@"type"] isEqualToString:@"video_call"] && [pushInfo[@"action"] isEqualToString:@"candidates_available"]){
                BOOL isCheckingExist = NO;
                for (NSDictionary *oneMember in conferenceMembersForVideoCalling) {
                    if ([[oneMember objectForKey:@"user_id"] integerValue] == [pushInfo[@"uid"] integerValue]) {
                        isCheckingExist = YES;
                    }
                }
                if (isCheckingExist) {
                    [userIdsForSendingCandidate addObject:pushInfo[@"uid"]];
                    userInfoByPushForCandidate = pushInfo;
                    isReceiverForConferenceCandidate = YES;
                    if(isJoinedOnConference){
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GET_CANDIDATES_VIDEO_CONFERENCE object:nil userInfo:pushInfo];
                    }
                }
            }else if ([[pushInfo objectForKey:@"type"] isEqualToString:@"video_call"] && [pushInfo[@"action"] isEqualToString:@"inviting"]){
                for (NSDictionary * memberOfConference in [pushInfo objectForKey:@"userInfo"]) {
                    if ([[memberOfConference objectForKey:@"id"] integerValue] != [userId integerValue]) {
                        NSMutableDictionary *dictOfUser = [[NSMutableDictionary alloc] init];
                        [dictOfUser setObject:[memberOfConference objectForKey:@"id"] forKey:@"user_id"];
                        [dictOfUser setObject:[memberOfConference objectForKey:@"name"] forKey:@"name"];
                        [dictOfUser setObject:[memberOfConference objectForKey:@"photo_url"] forKey:@"photo_url"];
                        if ([[pushInfo objectForKey:@"callType"] integerValue] == 1) {
                            [dictOfUser setObject:@"on" forKey:@"videoStatus"];
                        }else{
                            [dictOfUser setObject:@"off" forKey:@"videoStatus"];
                        }

                        [dictOfUser setObject:@"on" forKey:@"voiceStatus"];
                        [dictOfUser setObject:@(1) forKey:@"conferenceStatus"];
                        [dictOfUser setObject:@(0) forKey:@"isOwner"];
                        [dictOfUser setObject:@(1) forKey:@"isInvited"];
                        [dictOfUser setObject:@(0) forKey:@"isInvitedByMe"];
                        
                        [APPDELEGATE.conferenceMembersForVideoCalling addObject:dictOfUser];
                    }
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_INVITE_MEMBERS_CONFERENCE object:nil userInfo:pushInfo];
            }else if ([[pushInfo objectForKey:@"type"] isEqualToString:@"video_call"] && [pushInfo[@"action"] isEqualToString:@"videooff"]){
                for (NSInteger i=0; i < APPDELEGATE.conferenceMembersForVideoCalling.count; i ++) {
                    NSDictionary *dict = [APPDELEGATE.conferenceMembersForVideoCalling objectAtIndex:i];
                    if ([[dict objectForKey:@"user_id"] integerValue] == [[pushInfo objectForKey:@"uid"] integerValue]) {
                        NSMutableDictionary *dictOfUser = [dict mutableCopy];
                        [dictOfUser setObject:@"off" forKey:@"videoStatus"];
                        [APPDELEGATE.conferenceMembersForVideoCalling replaceObjectAtIndex:i withObject:dictOfUser];
                        break;
                    }
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MEMEBER_STATUS_CONFERENCE object:nil userInfo:pushInfo];
            }else if ([[pushInfo objectForKey:@"type"] isEqualToString:@"video_call"] && [pushInfo[@"action"] isEqualToString:@"videoon"]){
                for (NSInteger i=0; i < APPDELEGATE.conferenceMembersForVideoCalling.count; i ++) {
                    NSDictionary *dict = [APPDELEGATE.conferenceMembersForVideoCalling objectAtIndex:i];
                    if ([[dict objectForKey:@"user_id"] integerValue] == [[pushInfo objectForKey:@"uid"] integerValue]) {
                        NSMutableDictionary *dictOfUser = [dict mutableCopy];
                        [dictOfUser setObject:@"on" forKey:@"videoStatus"];
                        [APPDELEGATE.conferenceMembersForVideoCalling replaceObjectAtIndex:i withObject:dictOfUser];
                        break;
                    }
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MEMEBER_STATUS_CONFERENCE object:nil userInfo:pushInfo];
            }else if ([[pushInfo objectForKey:@"type"] isEqualToString:@"video_call"] && [pushInfo[@"action"] isEqualToString:@"audiooff"]){
                for (NSInteger i=0; i < APPDELEGATE.conferenceMembersForVideoCalling.count; i ++) {
                    NSDictionary *dict = [APPDELEGATE.conferenceMembersForVideoCalling objectAtIndex:i];
                    if ([[dict objectForKey:@"user_id"] integerValue] == [[pushInfo objectForKey:@"uid"] integerValue]) {
                        NSMutableDictionary *dictOfUser = [dict mutableCopy];
                        [dictOfUser setObject:@"off" forKey:@"voiceStatus"];
                        [APPDELEGATE.conferenceMembersForVideoCalling replaceObjectAtIndex:i withObject:dictOfUser];
                        break;
                    }
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MEMEBER_STATUS_CONFERENCE object:nil userInfo:pushInfo];
            }else if ([[pushInfo objectForKey:@"type"] isEqualToString:@"video_call"] && [pushInfo[@"action"] isEqualToString:@"audioon"]){
                for (NSInteger i=0; i < APPDELEGATE.conferenceMembersForVideoCalling.count; i ++) {
                    NSDictionary *dict = [APPDELEGATE.conferenceMembersForVideoCalling objectAtIndex:i];
                    if ([[dict objectForKey:@"user_id"] integerValue] == [[pushInfo objectForKey:@"uid"] integerValue]) {
                        NSMutableDictionary *dictOfUser = [dict mutableCopy];
                        [dictOfUser setObject:@"on" forKey:@"voiceStatus"];
                        [APPDELEGATE.conferenceMembersForVideoCalling replaceObjectAtIndex:i withObject:dictOfUser];
                        break;
                    }
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MEMEBER_STATUS_CONFERENCE object:nil userInfo:pushInfo];
            }
        }
    }
}

- (void)checkingConferenceStatus:(NSDictionary *)userInfo{
    
    if (conferenceMembersForVideoCalling.count == 0) {
        self.callkitCallController = [[CXCallController alloc] init];
        [CallManager sharedInstance].delegate = self;
        uuidForReceiver = [NSUUID new];
        [[CallManager sharedInstance] reportIncomingCallForUUID:uuidForReceiver phoneNumber:userInfo[@"uname"]];
        timerTillAccept = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(repeatTillAccept) userInfo:nil repeats:YES];
    }else{
        [self rejectOtherCallingOfConference:userInfo];
    }
}

#pragma mark - CallManagerDelegate

- (void)callDidAnswer {
    [timerTillAccept invalidate];
    timerTillAccept = nil;
    
    if (isOpenApp) {
        [self acceptCallingForUser];
    }else{
        timerIfNoOpenApp = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(repeatCheckingAppOpenStatus) userInfo:nil repeats:YES];
    }
}
- (void)callDidAnswerConnecting:(CXAnswerCallAction *)_action{
    callAction = _action;
    
}

- (void)callConnectingFullfill{
    if (callAction) {
        [callAction fulfill];
        callAction = nil;
    }
}

- (void)repeatCheckingAppOpenStatus{
    if (isOpenApp) {
        [timerIfNoOpenApp invalidate];
        timerIfNoOpenApp = nil;
        [self acceptCallingForUser];
    }
}
- (void)repeatTillAccept{
    countTillAccept ++;
    if (countTillAccept > 30) {
        [timerTillAccept invalidate];
        timerTillAccept = nil;
        countTillAccept = 0;
        
        conferenceStatus = 0;
        
//        void ( ^successed )( id _responseObject ) = ^( id _responseObject )
//        {
//            if ([[_responseObject objectForKey:@"success"] boolValue]) {
        
                [self performEndCallActionWithUUID:self.uuidForReceiver];
//            }
//        };
//        
//        void ( ^failure )( NSError* _error ) = ^( NSError* _error )
//        {
//        };
//        [[YYYCommunication sharedManager] HangupVideoConference:APPDELEGATE.sessionId boardId:conferenceId endType:4 successed:successed failure:failure];
    }
}

- (void)callDidEnd {
    [timerTillAccept invalidate];
    timerTillAccept = nil;
    countTillAccept = 0;
    switch (conferenceStatus) {
        case 1:
        {
            if (isConferenceView) {
                conferenceStatus = 0;
                endTypeForConference = 10;
                void ( ^successed )( id _responseObject ) = ^( id _responseObject )
                {
                    if ([[_responseObject objectForKey:@"success"] boolValue]) {
                        
                        [self performEndCallActionWithUUID:self.uuidForReceiver];
                        if ([self.window.rootViewController isKindOfClass:[UINavigationController class]]) {
                            UIViewController *visibleController = [(UINavigationController *)self.window.rootViewController visibleViewController];
                            if (visibleController) {
                                if ([visibleController isKindOfClass:[VideoVoiceConferenceViewController class]]) {
                                    ((VideoVoiceConferenceViewController*)visibleController).boardId = nil;
                                    [((VideoVoiceConferenceViewController*)visibleController) initConferenceFromMenu];
                                }
                            }
                        }
                    }
                };
                
                void ( ^failure )( NSError* _error ) = ^( NSError* _error )
                {
                };
                [[YYYCommunication sharedManager] HangupVideoConference:APPDELEGATE.sessionId boardId:conferenceId endType:3 successed:successed failure:failure];
                
            }else{
                conferenceStatus = 0;
                endTypeForConference = 10;
                void ( ^successed )( id _responseObject ) = ^( id _responseObject )
                {
                    if ([[_responseObject objectForKey:@"success"] boolValue]) {
                        
                        [self performEndCallActionWithUUID:self.uuidForReceiver];
                    }
                };
                
                void ( ^failure )( NSError* _error ) = ^( NSError* _error )
                {
                };
                [[YYYCommunication sharedManager] HangupVideoConference:APPDELEGATE.sessionId boardId:conferenceId endType:3 successed:successed failure:failure];
            }
        }
            
            break;
        case 2:
        {
            if (isConferenceView) {
                if ([self.window.rootViewController isKindOfClass:[UINavigationController class]]) {
                    UIViewController *visibleController = [(UINavigationController *)self.window.rootViewController visibleViewController];
                    if (visibleController) {
                        if ([visibleController isKindOfClass:[VideoVoiceConferenceViewController class]]) {
                            [((VideoVoiceConferenceViewController*)visibleController) closeFromCallScreen];
                        }
                    }
                }
            }else{
                conferenceStatus = 0;
                endTypeForConference = 10;
                void ( ^successed )( id _responseObject ) = ^( id _responseObject )
                {
                    if ([[_responseObject objectForKey:@"success"] boolValue]) {
                        
                        [self performEndCallActionWithUUID:self.uuidForReceiver];
                    }
                };
                
                void ( ^failure )( NSError* _error ) = ^( NSError* _error )
                {
                };
                [[YYYCommunication sharedManager] HangupVideoConference:APPDELEGATE.sessionId boardId:conferenceId endType:1 successed:successed failure:failure];
            }
        }
            break;
        default:
            break;
    }

}
- (void)callDidHold:(BOOL)isOnHold {


}
- (void)callDidFail {
    [timerTillAccept invalidate];
    timerTillAccept = nil;
    countTillAccept = 0;
    
    switch (conferenceStatus) {
        case 1:
        {
            conferenceStatus = 0;
            endTypeForConference = 10;
            void ( ^successed )( id _responseObject ) = ^( id _responseObject )
            {
                if ([[_responseObject objectForKey:@"success"] boolValue]) {
                    
                    [self performEndCallActionWithUUID:self.uuidForReceiver];
                }
            };
            
            void ( ^failure )( NSError* _error ) = ^( NSError* _error )
            {
            };
            [[YYYCommunication sharedManager] HangupVideoConference:APPDELEGATE.sessionId boardId:conferenceId endType:3 successed:successed failure:failure];
        }
            
            break;
        case 2:
        {
            conferenceStatus = 0;
            endTypeForConference = 10;
            void ( ^successed )( id _responseObject ) = ^( id _responseObject )
            {
                if ([[_responseObject objectForKey:@"success"] boolValue]) {
                    
                    [self performEndCallActionWithUUID:self.uuidForReceiver];
                }
            };
            
            void ( ^failure )( NSError* _error ) = ^( NSError* _error )
            {
            };
            [[YYYCommunication sharedManager] HangupVideoConference:APPDELEGATE.sessionId boardId:conferenceId endType:1 successed:successed failure:failure];
        }
            break;
        default:
            break;
    }
}

- (void)performEndCallActionWithUUID:(NSUUID *)uuid {
    if (uuid == nil) {

        return;
    }

    CXEndCallAction *endCallAction = [[CXEndCallAction alloc] initWithCallUUID:uuid];
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:endCallAction];
    
    [self.callkitCallController requestTransaction:transaction completion:^(NSError *error) {
        if (error) {
            NSLog(@"EndCallAction transaction request failed: %@", [error localizedDescription]);
        }
        else {
            NSLog(@"EndCallAction transaction request successful");
        }
    }];
    
    
}

- (void)acceptCallingForUser{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GINKO_VIDEO_CONFERENCE object:nil userInfo:userDicForCalling];
    if (!isConferenceView) {
        conferenceStatus = 2;
        [self openCallingVideoScreen:userDicForCalling];
        userInfoByPushForConference = userDicForCalling;
    }else{
        if (conferenceMembersForVideoCalling.count == 0) {
            conferenceStatus = 2;
            userInfoByPushForConference = userDicForCalling;
            
            [APPDELEGATE.conferenceMembersForVideoCalling removeAllObjects];
            NSArray *idsOfConference = [[userDicForCalling objectForKey:@"invited_uids"] componentsSeparatedByString:@","];
            
            for (NSDictionary * memberOfConference in [userDicForCalling objectForKey:@"userInfo"]) {
                if ([[memberOfConference objectForKey:@"id"] integerValue] != [userId integerValue]) {
                    NSMutableDictionary *dictOfUser = [[NSMutableDictionary alloc] init];
                    [dictOfUser setObject:[memberOfConference objectForKey:@"id"] forKey:@"user_id"];
                    [dictOfUser setObject:[memberOfConference objectForKey:@"name"] forKey:@"name"];
                    [dictOfUser setObject:[memberOfConference objectForKey:@"photo_url"] forKey:@"photo_url"];
                    if ([[userDicForCalling objectForKey:@"callType"] integerValue] == 1) {
                        [dictOfUser setObject:@"on" forKey:@"videoStatus"];
                    }else{
                        [dictOfUser setObject:@"off" forKey:@"videoStatus"];
                    }

                    [dictOfUser setObject:@"on" forKey:@"voiceStatus"];
                    [dictOfUser setObject:@(1) forKey:@"conferenceStatus"];
                    if ([[userDicForCalling objectForKey:@"uid"] integerValue] == [[memberOfConference objectForKey:@"id"] integerValue])
                    {
                        [dictOfUser setObject:@(1) forKey:@"isOwner"];
                    }else{
                        [dictOfUser setObject:@(0) forKey:@"isOwner"];
                    }
                    
                    if ([idsOfConference containsObject:[memberOfConference objectForKey:@"id"]]) {
                        [dictOfUser setObject:@(1) forKey:@"isInvited"];
                    }else{
                        [dictOfUser setObject:@(0) forKey:@"isInvited"];
                    }
                    
                    [dictOfUser setObject:@(0) forKey:@"isInvitedByMe"];
                    [APPDELEGATE.conferenceMembersForVideoCalling addObject:dictOfUser];
                }
            }
            
            
            NSString *ids = @"";
            for (NSDictionary *dict in APPDELEGATE.conferenceMembersForVideoCalling) {
                if ([ids isEqualToString:@""]) {
                    ids = [dict objectForKey:@"user_id"];
                }else {
                    ids = [NSString stringWithFormat:@"%@,%@", ids, [dict objectForKey:@"user_id"]];
                }
            }
            
            isOwnerForConference = NO;
            
            if ([self.window.rootViewController isKindOfClass:[UINavigationController class]]) {
                UIViewController *visibleController = [(UINavigationController *)self.window.rootViewController visibleViewController];
                if (visibleController) {
                    if ([visibleController isKindOfClass:[VideoVoiceConferenceViewController class]]) {
                        
                        ((VideoVoiceConferenceViewController*)visibleController).boardId = [userDicForCalling objectForKey:@"board_id"];
                        NSString *confName = @"Ginko Call";
                        if ([APPDELEGATE.conferenceMembersForVideoCalling count] == 0) {
                            confName = @"Ginko Call";
                        }else if ([APPDELEGATE.conferenceMembersForVideoCalling count] == 1){
                            confName = [[APPDELEGATE.conferenceMembersForVideoCalling objectAtIndex:0] objectForKey:@"name"];
                        }else {
                            for (NSDictionary *dicOfName in APPDELEGATE.conferenceMembersForVideoCalling) {
                                if (!APPDELEGATE.isOwnerForConference && [[dicOfName objectForKey:@"isOwner"] boolValue]) {
                                    confName = [NSString stringWithFormat:@"%@ + %lu", [dicOfName objectForKey:@"name"], [APPDELEGATE.conferenceMembersForVideoCalling count] - 1];
                                }else if (APPDELEGATE.isOwnerForConference && [[dicOfName objectForKey:@"isOwner"] boolValue]){
                                    
                                }else{
                                    confName = [NSString stringWithFormat:@"%@ + %lu", [dicOfName objectForKey:@"name"], [APPDELEGATE.conferenceMembersForVideoCalling count] - 1];
                                }
                            }
                        }
                        ((VideoVoiceConferenceViewController*)visibleController).conferenceName = confName;
                        if ([[userDicForCalling objectForKey:@"callType"] integerValue] == 1) {
                            ((VideoVoiceConferenceViewController*)visibleController).conferenceType = 1;
                        }else{
                            ((VideoVoiceConferenceViewController*)visibleController).conferenceType = 2;
                        }
                        [((VideoVoiceConferenceViewController*)visibleController) openConferenceFromMenu];
                    }
                }
            }
            
        }else{
            [self rejectOtherCallingOfConference:userDicForCalling];
        }
    }
}

- (void)saveLoginData {
    isOpenApp = YES;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[AppDelegate sharedDelegate].sessionId forKey:@"sessionId"];
    [userDefaults setObject:[AppDelegate sharedDelegate].userId forKey:@"user_id"];
    [userDefaults setObject:[AppDelegate sharedDelegate].firstName forKey:@"first_name"];
    [userDefaults setObject:[AppDelegate sharedDelegate].lastName forKey:@"last_name"];
    [userDefaults setObject:[AppDelegate sharedDelegate].userName forKey:@"user_name"];
    [userDefaults setObject:[AppDelegate sharedDelegate].photoUrl forKey:@"photo_url"];
    [userDefaults setObject:[AppDelegate sharedDelegate].qrCode forKey:@"qrcode"];
    [userDefaults setObject:@([AppDelegate sharedDelegate].gpsFilterType) forKey:@"gpsFilterType"];
    [userDefaults setObject:@([AppDelegate sharedDelegate].phoneVerified) forKey:@"phone_verified"];
    [userDefaults setObject:@([AppDelegate sharedDelegate].isChatNotification) forKey:@"chat_msg_notification"];
    [userDefaults setObject:@([AppDelegate sharedDelegate].isExchangeNotification) forKey:@"exchange_request_notification"];
    [userDefaults setObject:@([AppDelegate sharedDelegate].isSproutNotification) forKey:@"sprout_notification"];
    [userDefaults synchronize];
}

- (BOOL)loadLoginData {
    isOpenApp = YES;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"sessionId"]) {
        [AppDelegate sharedDelegate].sessionId = [userDefaults objectForKey:@"sessionId"];
        [AppDelegate sharedDelegate].userId = [userDefaults objectForKey:@"user_id"];
        [AppDelegate sharedDelegate].firstName = [userDefaults objectForKey:@"first_name"];
        [AppDelegate sharedDelegate].lastName = [userDefaults objectForKey:@"last_name"];
        [AppDelegate sharedDelegate].userName = [userDefaults objectForKey:@"user_name"];
        [AppDelegate sharedDelegate].photoUrl = [userDefaults objectForKey:@"photo_url"];
        [AppDelegate sharedDelegate].qrCode = [userDefaults objectForKey:@"qrcode"];
        [AppDelegate sharedDelegate].gpsFilterType = [[userDefaults objectForKey:@"gpsFilterType"] integerValue];
        [AppDelegate sharedDelegate].myName = [NSString stringWithFormat:@"%@ %@", [userDefaults objectForKey:@"first_name"], [userDefaults objectForKey:@"last_name"]];
        [AppDelegate sharedDelegate].phoneVerified = [[userDefaults objectForKey:@"phone_verified"] boolValue];
        [AppDelegate sharedDelegate].isChatNotification = [[userDefaults objectForKey:@"chat_msg_notification"] boolValue];
        [AppDelegate sharedDelegate].isExchangeNotification = [[userDefaults objectForKey:@"exchange_request_notification"] boolValue];
        [AppDelegate sharedDelegate].isSproutNotification = [[userDefaults objectForKey:@"sprout_notification"] boolValue];

        return YES;
    }
    return NO;
}

- (void)deleteLoginData {
    isOpenApp = NO;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"sessionId"];
    [userDefaults removeObjectForKey:@"user_id"];
    [userDefaults removeObjectForKey:@"first_name"];
    [userDefaults removeObjectForKey:@"last_name"];
    [userDefaults removeObjectForKey:@"photo_url"];
    [userDefaults removeObjectForKey:@"qrcode"];
    [userDefaults synchronize];
    [self turnOffGPS];
}

// Wang Class
- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
- (void)validateEmail:(NSString *)key{
    //[MBProgressHUD showHUDAddedTo:self.window animated:YES];
    
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        [MBProgressHUD hideAllHUDsForView:self.window animated:YES];
        
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Congratulations!" message:@"You joined the Ginko directory. A directory icon will appear in Groups" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
            [alertView show];
            if (!isGroupScreen) {
                GroupsViewController *vc = [[GroupsViewController alloc] initWithNibName:@"GroupsViewController" bundle:nil];
                if ([self.window.rootViewController isKindOfClass:[UINavigationController class]]) {
                    UIViewController *topVC = ((UINavigationController *)self.window.rootViewController).topViewController;
                    if (topVC.isViewLoaded && topVC.view.window) {
                        [((UINavigationController *)self.window.rootViewController) pushViewController:vc animated:YES];
                    }
                }
            }else{                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GROUPSRELOAD" object:nil];
            }
        }
        else
        {
            if ([[[_responseObject objectForKey:@"err"] objectForKey:@"errCode"] intValue] == 110)
            {
                [self showAlert:@"The key is incorrect." :@"Oops!"];
            }
            else if ([[[_responseObject objectForKey:@"err"] objectForKey:@"errCode"] intValue] == 902)
            {
                [self showAlert:@"Validate Code is expired!" :@"Oops!"];
            }else
            {
                [ self  showAlert: @"An unknown error occurred" :@"Oops!"] ;
            }
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
        
        [ MBProgressHUD hideHUDForView : self.window animated : YES ] ;
        [ self  showAlert: @"An unknown error occurred" :@"Oops!"] ;
        
    } ;
    
    [[YYYCommunication sharedManager] ValidateEmail:APPDELEGATE.sessionId key:key
                                        successed:successed
                                          failure:failure];
}
-(void)acceptLogin:(NSString*)key
{
    [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        [MBProgressHUD hideAllHUDsForView:self.window animated:YES];
        
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            [AppDelegate sharedDelegate].sessionId	= [[_responseObject objectForKey:@"data"] objectForKey:@"sessionId"];
            [AppDelegate sharedDelegate].userId		= [[_responseObject objectForKey:@"data"] objectForKey:@"user_id"];
            [AppDelegate sharedDelegate].firstName	= [NSString stringWithFormat:@"%@ %@",[[_responseObject objectForKey:@"data"] objectForKey:@"first_name"],[[_responseObject objectForKey:@"data"] objectForKey:@"last_name"]];
            
            //			[self goToSetup];
            //wang class interrupt
            [self configAfterSignIn:_responseObject];
            //wang class interrupt end
        }
        else
        {
            if ([[[_responseObject objectForKey:@"err"] objectForKey:@"errCode"] intValue] == 110)
            {
                [self showAlert:@"The activate key is incorrect." :@"Oops!"];
            }
            else
            {
                [ self  showAlert: @"An unknown error occurred" :@"Oops!"] ;
            }
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
        
        [ MBProgressHUD hideHUDForView : self.window animated : YES ] ;
        [ self  showAlert: @"An unknown error occurred" :@"Oops!"] ;
        
    } ;
    
    [[YYYCommunication sharedManager] AcceptLogin:key
                                        voipToken:APPDELEGATE.voIPDeviceToken
                                        successed:successed
                                          failure:failure];
}
//----------SetupLocation-------------
int repeatCount;
BOOL locFlag;
BOOL configFlag;
CLLocationCoordinate2D curLoc;
- (void)configAfterSignIn:(NSDictionary *)_responseObject
{
    NSDictionary * myInfo = [_responseObject objectForKey:@"data"];
    self.myName = [NSString stringWithFormat:@"%@ %@", [myInfo objectForKey:@"first_name"], [myInfo objectForKey:@"last_name"]];
    
    //Sun Class
    [AppDelegate sharedDelegate].sessionId = [myInfo objectForKey:@"sessionId"];
    NSLog(@"session id = %@", [AppDelegate sharedDelegate].sessionId);
    
    [AppDelegate sharedDelegate].strSetupPage = [myInfo objectForKey:@"setup_page"];
    
    [AppDelegate sharedDelegate].isChatNotification = [[myInfo objectForKey:@"chat_msg_notification"] boolValue];
    [AppDelegate sharedDelegate].isExchangeNotification = [[myInfo objectForKey:@"exchange_request_notification"] boolValue];
    [AppDelegate sharedDelegate].isSproutNotification = [[myInfo objectForKey:@"sprout_notification"] boolValue];
    
    currentLocation.latitude = 0;
    currentLocation.longitude = 0;
    
    self.locationFlag = [[myInfo objectForKey:@"location_on"] boolValue];
    if (self.locationFlag) {
        [self refreshLocationUpdating];
    }
    [self setupNext];
}

- (void)setupNext
{
    if ([self.strSetupPage intValue]) {
        [dictInfoWork removeAllObjects];
        [dictInfoWork setObject:@"0" forKey:@"Private"];
        [dictInfoWork setObject:@"0" forKey:@"Abbr"];
    }
    
    if ([[AppDelegate sharedDelegate].strSetupPage isEqualToString:@"2"]) {
        [AppDelegate sharedDelegate].isShowTutorial = YES;
        [[AppDelegate sharedDelegate] goToMainContact];//signup complete, cb skip
    } else if ([[AppDelegate sharedDelegate].strSetupPage isEqualToString:@"1"]) {
        [[AppDelegate sharedDelegate] goToSetupCB];
    }/* else if ([[AppDelegate sharedDelegate].strSetupPage isEqualToString:@"1"]) {
      [[AppDelegate sharedDelegate] goToContactImporter];
      } */else if ([[AppDelegate sharedDelegate].strSetupPage isEqualToString:@""]) {
          [[AppDelegate sharedDelegate] goToSetup];
      } else {
          [[AppDelegate sharedDelegate] goToMainContact];
      }
}

//----------SetupLocation End-------------

- (void)addFavoriteContact:(NSString *)contactID contactType:(NSString *)type{
    [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    
    void (^successed)(id _responseObject) = ^(id _responseObject){
        [MBProgressHUD hideAllHUDsForView:self.window animated:YES];
        
        if ([[_responseObject objectForKey:@"success"] boolValue]) {
            NSLog(@"Message-%@",[_responseObject objectForKey:@"message"]);
        }
    };
    
    void (^failure)(NSError* _error) = ^(NSError* _error)
    {
        [MBProgressHUD hideHUDForView:self.window animated:YES];
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to load user info." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    };
    
    [[YYYCommunication sharedManager] AddFavoriteContact:[AppDelegate sharedDelegate].sessionId contactID:contactID contactType:type successed:successed failure:failure];
    
}
- (void)removeFavoriteContact:(NSString *)contactID contactType:(NSString *)type{
    [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    void (^successed)(id _responseObject) = ^(id _responseObject){
        [MBProgressHUD hideAllHUDsForView:self.window animated:YES];
        
        if ([[_responseObject objectForKey:@"success"] boolValue]) {
            NSLog(@"Message-%@",[_responseObject objectForKey:@"message"]);
        }
    };
    
    void (^failure)(NSError* _error) = ^(NSError* _error)
    {
        [MBProgressHUD hideHUDForView:self.window animated:YES];
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to load user info." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    };
    
    [[YYYCommunication sharedManager] RemoveFavoriteContact:[AppDelegate sharedDelegate].sessionId contactID:contactID contactType:type successed:successed failure:failure];
}
-(void)goToSetup
{
    // for MBProgressHUD, process in async
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showHUDAddedTo:self.window animated:YES];
        
        void (^successed)(id _responseObject) = ^(id _responseObject){
            [MBProgressHUD hideAllHUDsForView:self.window animated:YES];
            
            if ([[_responseObject objectForKey:@"success"] boolValue]) {
                NSDictionary *userData = _responseObject[@"data"];
                
                ProfileMode mode;
                BOOL isWork;
                if ([userData[@"home"][@"fields"] count] > 0)
                {
                    if ([userData[@"work"][@"fields"] count] > 0) {
                        mode = ProfileModeBoth;
                        isWork = YES;
                    } else {
                        mode = ProfileModePersonal;
                        isWork = NO;
                    }
                } else if ([userData[@"work"][@"fields"] count] > 0) {
                    mode = ProfileModeWork;
                    isWork = YES;
                } else {    // really new and show profile selection screen
                    SetupViewController *viewcontroller = [[SetupViewController alloc] initWithNibName:@"SetupViewController" bundle:nil];
                    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:viewcontroller];
                    [controller.navigationBar setTranslucent:NO];
                    self.window.rootViewController = controller;
                    return;
                }
                
                ManageProfileViewController *vc = [[ManageProfileViewController alloc] initWithNibName:@"ManageProfileViewController" bundle:nil];
                vc.userData = userData;
                vc.isCreate = YES;
                vc.isWork = isWork;
                vc.isSecond = NO;
                vc.mode = mode;
                vc.isSetup = YES;
                
                UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
                navVC.navigationBar.translucent = NO;
                // reset global appearance
                [navVC.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
                [navVC.navigationBar setTintColor:[UIColor whiteColor]];
                [navVC.navigationBar setBarTintColor:COLOR_PURPLE_THEME];
                [navVC.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
                
                self.window.rootViewController = navVC;
            }
        };
        
        void (^failure)(NSError* _error) = ^(NSError* _error)
        {
            [MBProgressHUD hideHUDForView:self.window animated:YES];
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to load user info." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        };
        
        [[YYYCommunication sharedManager] GetInfo:[AppDelegate sharedDelegate].sessionId successed:successed failure:failure];
    });
    
    //	YYYPreviewProfileViewController *viewcontroller = [[YYYPreviewProfileViewController alloc] initWithNibName:@"YYYPreviewProfileViewController" bundle:nil];
    //	UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:viewcontroller];
    //	[controller.navigationBar setTranslucent:NO];
    //	self.window.rootViewController = controller;
}

- (void)goToMainContact
{
    [[AppDelegate sharedDelegate] saveLoginData];
    
    ContactViewController * viewcontroller = [[ContactViewController alloc] initWithNibName:@"ContactViewController" bundle:nil];
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:viewcontroller];
    [controller.navigationBar setTranslucent:NO];
    self.window.rootViewController = controller;
}

- (void)goToSplash
{
    YYYViewController *viewcontroller = [[YYYViewController alloc] initWithNibName:@"YYYViewController" bundle:nil];
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:viewcontroller];
    [controller.navigationBar setTranslucent:NO];
    self.window.rootViewController = controller;
}

- (void)goToSetupCB
{
    _globalData.cbIsFromMenu = NO;
    CBImportHomeViewController *viewcontroller = [[CBImportHomeViewController alloc] initWithNibName:@"CBImportHomeViewController" bundle:nil];
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:viewcontroller];
    [controller.navigationBar setTranslucent:NO];
    self.window.rootViewController = controller;
}

//- (void)goToContactImporter
//{
//    _globalData.isFromMenu = NO;
//    CIHomeViewController *viewcontroller = [[CIHomeViewController alloc] initWithNibName:@"CIHomeViewController" bundle:nil];
//    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:viewcontroller];
//    [controller.navigationBar setTranslucent:NO];
//    self.window.rootViewController = controller;
//}

-(void)showAlert:(NSString*)msg :(NSString*)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}
// Wang Class end

// importer class!
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    NSLog(@"redirect!!");
    if ([[url scheme] isEqualToString:@"com.ginko.app"]) {
        if([url.absoluteString rangeOfString:@"://email/activate?key="].location != NSNotFound)
        {
            NSString *key = [url.absoluteString substringFromIndex:[url.absoluteString rangeOfString:@"://email/activate?key="].location + 22];
            [self acceptLogin:key];
            //Wang class interrupt
            return YES;
        }
        // Wang Class
        if([url.absoluteString rangeOfString:@"://activate/key:"].location != NSNotFound)
        {
            NSString *key = [url.absoluteString substringFromIndex:[url.absoluteString rangeOfString:@"://activate/key:"].location + 16];
            [self acceptLogin:key];
            //Wang class interrupt
            return YES;
        }
        if([url.absoluteString rangeOfString:@"://directory/validateEmail?key="].location != NSNotFound)
        {
            
            NSString *key = [url.absoluteString substringFromIndex:[url.absoluteString rangeOfString:@"://directory/validateEmail?key="].location + 31];
            [self validateEmail:key];
            //Wang class interrupt
            return YES;
        }
        
        // Wang Class End
        NSLog(@"URL is %@",url.absoluteString); //com.ginko.app://sync/redirect?code=4/vpJp3Z1fG3smuhR_UlXzYRNm9SJH.4k4V5EbDBR8bgrKXntQAax10HsdXjwI
        //com.ginko.app://cb/redirect?code=4/RNBgR7vYwBKsU4CjL43TzmaBHRHB.kvWuTh16ROcWgrKXntQAax36cmFYjwI
        UIViewController *lastViewController = [[(UINavigationController *)self.window.rootViewController viewControllers] lastObject];
        
        if([url.absoluteString rangeOfString:@"com.ginko.app://cb"].location != NSNotFound)
        {
            if ([lastViewController isKindOfClass:[CBImportItemViewController class]]) {
                [(CBImportItemViewController *)lastViewController goToCBDetail:url.absoluteString];
            } else if ([lastViewController isKindOfClass:[CBDetailViewController class]]) {
                [(CBDetailViewController *)lastViewController modifyCBEmail:url.absoluteString];
            }
            return YES;
        }
        
        if ([lastViewController isKindOfClass:[CIImportViewController class]]) {
            [(CIImportViewController *)lastViewController syncContactByOauth:url.absoluteString];
        }else {
            [self showAlert:@"Please try from Menu -> Backup Contacts, again" :@"Oops!"];
        }
        
        return YES;
    }else{
        BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                      openURL:url
                                                            sourceApplication:sourceApplication
                                                                   annotation:annotation
                        ];
        // Add any custom logic here.
        return handled;
    }
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if ([AppDelegate sharedDelegate].sessionId) {
        CLLocation * location = locations.lastObject;
        currentLocationforMultiLocations = location.coordinate;
        [locationManager stopUpdatingLocation];
        if (!_thumbDown)
        {
            //[locationManager stopUpdatingLocation];
            isStartedLocationUpdate = NO;
            if (didFinishFlag) {
                return;
            }
            didFinishFlag = YES;
        }
        
        double dMeters = [location distanceFromLocation:[[CLLocation alloc] initWithLatitude:currentLocation.latitude longitude:currentLocation.longitude]];
        
        if (dMeters > 50) {
            isStartedLocationUpdate = NO;
        }
        
        if (!isStartedLocationUpdate) {
            if (dMeters > 50 || didTurnOnFlag) {
                NSLog(@"Upload location: %@", location);
                currentLocation = location.coordinate;
                void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
                    //NSLog(@"%@",[_responseObject objectForKey:@"data"]);
                    if ([[_responseObject objectForKey:@"success"] boolValue])
                    {
                        didTurnOnFlag = NO;
                        [self GetContactList];
                        NSLog(@"call didupadted locatino");
                    }
                };
                
                void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
                    NSLog(@"Connection Error - %@", _error);
                } ;
                
                if (myName && ![myName isEqualToString:@""])
                {
                    [[Communication sharedManager] SetUpdateLocation:[AppDelegate sharedDelegate].sessionId
                                                           longitude:[NSString stringWithFormat:@"%f", currentLocation.longitude]
                                                            latitude:[NSString stringWithFormat:@"%f", currentLocation.latitude]
                                                           successed:successed
                                                             failure:failure];
                }
            }
            isStartedLocationUpdate = YES;
        }
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSString *message = @"";
    NSString *title;
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (locationFlag)
    {
        if ([error domain] == kCLErrorDomain) {
            
            switch ([error code]) {
                case kCLErrorDenied:{
                    title = (status == kCLAuthorizationStatusDenied)?@"Location services are off" : @"Background location is not enabled";
                    message = @"To use background location you must turn on 'Always' or 'While Using the App' in the Location Services Settings";
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
                    [alert show];}
                    break;
                case kCLErrorLocationUnknown:
                    message = @"Please check your network connection or that you are not in airplane mode.";
                    [self showAlert:message :@"Oops!"];
                    break;
                default:
                    break;
            }
        } else {
            message = @"Location Service Error!";
            [self showAlert:message :@"Oops!"];
            [locationManager stopUpdatingLocation];
            isStartedLocationUpdate = NO;
        }
    }
    else
    {
        title = (status == kCLAuthorizationStatusDenied)?@"Location services are off" : @"Background location is not enabled";
        message = @"To use background location you must turn on 'Always' or 'While Using the App' in the Location Services Settings";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
        [alert show];
        [locationManager stopUpdatingLocation];
        isStartedLocationUpdate = NO;
    }
    
    NSLog(@"GPS Connection Failed %@", error);
    
    // Should dismiss loading screen, applicationWillResignActive may be not inappropriate for this, but this should be enough
    [[NSNotificationCenter defaultCenter] postNotificationName:ApplicationWillResignActive object:nil];
}

- (void)refreshLocationUpdating
{
    if (intervalIndex == 7) // off
    {
        locationFlag = NO;
    }
    else
    {
        float interval = 10;
        switch (intervalIndex) {
            case 0: // on
                currentCount = 0;
                break;
            case 1: // off after one hr
            {
                interval = 10;
                currentCount = 240;
                break;
            }
            default:
                currentCount = 0;
                break;
        }
        if (timerFlag == YES && gpsCallTimer != nil)
        {
            NSLog(@"stopped timer");
            [gpsCallTimer invalidate];
        }
        NSLog(@"UpdateLocation");
        didFinishFlag = NO;
        [locationManager startUpdatingLocation];
        [gpsCallTimer invalidate];
        gpsCallTimer = nil;
        gpsCallTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(repeatUpdating) userInfo:nil repeats:YES];
        timerFlag = YES;
    }
}

- (void)repeatUpdating
{
    if (locationFlag)
    {
        if (intervalIndex == 0) // if turned on, we upload every 15 seconds
        {
            NSLog(@"UpdateLocation");
            didFinishFlag = NO;
            [locationManager startUpdatingLocation];
            
            self.didTurnOnFlag = YES;
        }
        else // if off after one hr, we decrease the count until it reaches 1 hr
        {
            currentCount -- ;
            if (currentCount > 0)
            {
                NSLog(@"UpdateLocation");
                didFinishFlag = NO;
                [locationManager startUpdatingLocation];
            }
            else
            {
                
                NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
                locationFlag = NO;
                [dict setValue:@"NO" forKey:@"LOCATION_FLAG"];
                [[NSNotificationCenter defaultCenter] postNotificationName:LOCATION_CHANGE_NOTIFICATION object:nil userInfo:dict];
                
                if (timerFlag == YES)
                {
                    [gpsCallTimer invalidate];
                    timerFlag = NO;
                }
                if ([AppDelegate sharedDelegate].sessionId) {
                    [self turnOffGPS];
                }
            }
        }
        NSLog(@"Timer Interval = %ld currentCount = %ld", (long)intervalIndex, (long)currentCount);
    }
    else
    {
        if (timerFlag == YES)
        {
            [gpsCallTimer invalidate];
            timerFlag = NO;
        }
    }
}

// type: 0-turn off, 1-turn on, 2-turn off after one hr
- (void)changeGPSSetting:(int)type
{
    NSLog(@"Change gps setting:%d", type);
    NSString * turn_on = @"";
    
    BOOL turnOn = NO;
    if (type)
    {
        turnOn = YES;
        turn_on = @"true";
    }
    else
    {
        turn_on = @"false";
    }
    
    //    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        //        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        self.locationFlag = turnOn;
        
        if(!self.thumbDown)
            [SVProgressHUD dismiss];
        
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            switch (type) {
                case 0:
                    self.intervalIndex = 7;
                    break;
                case 1:
                    self.intervalIndex = 0;
                    break;
                case 2:
                    self.intervalIndex = 1;
                    break;
                default:
                    break;
            }
            
            if (turnOn)
            {
                self.didFinishFlag = NO;
                [locationManager startUpdatingLocation];
                self.didTurnOnFlag = YES;
                [self refreshLocationUpdating];
            }
            else
            {
                //                [self GetContactList];
                [self.locationManager stopUpdatingLocation];
                isStartedLocationUpdate = NO;
            }
            [[NSUserDefaults standardUserDefaults] setInteger:type forKey:@"INTERVAL_INDEX"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GPSSETTING_CHANGED object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CONTACTGPS_CHANGED object:nil];
            // update ui for gps button
            UIViewController *visibleController = [(UINavigationController *)self.window.rootViewController visibleViewController];
            if (visibleController) {
                if ([visibleController isKindOfClass:[ContactViewController class]]) {
                    [(ContactViewController *)visibleController displayGPSButton];
                } else if ([visibleController isKindOfClass:[TabBarController class]]) {
                    UIViewController *selectedViewController = [(TabBarController *)visibleController selectedViewController];
                    if ([selectedViewController isKindOfClass:[NotExchangedViewController class]]) {
                        [(NotExchangedViewController *)selectedViewController displayGPSButton];
                    } else if([selectedViewController isKindOfClass:[ExchangedViewController class]]) {
                        [(ExchangedViewController *)selectedViewController displayGPSButton];
                    }
                }
            }
            
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        //        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        //self.locationFlag = turnOn;
        [SVProgressHUD dismiss];
        //        switch (type) {
        //            case 0:
        //                self.intervalIndex = 7;
        //                break;
        //            case 1:
        //                self.intervalIndex = 0;
        //                break;
        //            case 2:
        //                self.intervalIndex = 1;
        //                break;
        //            default:
        //                break;
        //        }
        //
        //        if (turnOn)
        //        {
        //            self.didFinishFlag = NO;
        //            [locationManager startUpdatingLocation];
        //            self.didTurnOnFlag = YES;
        //            [self refreshLocationUpdating];
        //        }
        //        else
        //        {
        //            //                [self GetContactList];
        //            [self.locationManager stopUpdatingLocation];
        //            isStartedLocationUpdate = NO;
        //        }
        //        [[NSUserDefaults standardUserDefaults] setInteger:type forKey:@"INTERVAL_INDEX"];
        //
        //        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GPSSETTING_CHANGED object:nil];
        //
        //        // update ui for gps button
        //        UIViewController *visibleController = [(UINavigationController *)self.window.rootViewController visibleViewController];
        //        if (visibleController) {
        //            if ([visibleController isKindOfClass:[ContactViewController class]]) {
        //                [(ContactViewController *)visibleController displayGPSButton];
        //            } else if ([visibleController isKindOfClass:[TabBarController class]]) {
        //                UIViewController *selectedViewController = [(TabBarController *)visibleController selectedViewController];
        //                if ([selectedViewController isKindOfClass:[NotExchangedViewController class]]) {
        //                    [(NotExchangedViewController *)selectedViewController displayGPSButton];
        //                } else if([selectedViewController isKindOfClass:[ExchangedViewController class]]) {
        //                    [(ExchangedViewController *)selectedViewController displayGPSButton];
        //                }
        //            }
        //        }
        NSLog(@"Change GPS Status failed");
    } ;
    
    [[Communication sharedManager] ChangeGPSStatus:[AppDelegate sharedDelegate].sessionId trun_on:turn_on successed:successed failure:failure];
}

- (void)touchThumb
{
    NSLog(@"do Action!");
    self.isGPSOn = YES; // we need to set the flag so that we know need to disable gps setting later
    self.notCallFlag = NO;
    [self changeGPSSetting:1];
    
    //    notCallFlag = NO; //??
}



-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    NSLog(@"here");
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    //Wang class
    strDeviceToken = [[[[deviceToken description]
                        stringByReplacingOccurrencesOfString: @"<" withString: @""]
                       stringByReplacingOccurrencesOfString: @">" withString: @""]
                      stringByReplacingOccurrencesOfString: @" " withString: @""];
    //Wang class end
    
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"sessionId"]) {
//        if (strDeviceToken)
//        {
//            strDeviceToken = @"11111111111111";
//        }
//        [[YYYCommunication sharedManager] checkSession:[[NSUserDefaults standardUserDefaults] objectForKey:@"sessionId"] udid:[OpenUDID value]  token:strDeviceToken successed:^(id _responseObject) {
//            if ([_responseObject[@"success"] integerValue] == 1) {
//                
//            } else {
//                
//            }
//        } failure:^(NSError *_error) {
//            
//        }];
//    } else {
//        
//    }
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        // show some alert or otherwise handle the failure to register.
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

- (void)showNotification:(NSString *)msg keyIndex:(NSInteger)_keyIndex{
    
    if (msg && ![msg isEqualToString:@""]) {
        [JCNotificationCenter sharedCenter].presenter = [JCNotificationBannerPresenterIOS7Style new];
        
        [JCNotificationCenter
         enqueueNotificationWithTitle:@""
         message:msg
         tapHandler:^{
             switch (_keyIndex) {
                 case 1://chat
                     [self openChatForBoard];
                     break;
                 case 2://request
                     [self openRequestScreen];
                     break;
                 case 3://entitychat
                     [self openWallScreen];
                     break;
                 case 4://directory
                     [self openDirectoryInviteContactview];
                     break;
                 case 5://group
                     [self openGroupScreen];
                     break;
                 default:
                     break;
             }
         }];
    }
}
- (void)HandlePushNotification:(NSDictionary *)userInfo{
    
    isNotificationForChatting = NO;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    if ([AppDelegate sharedDelegate].sessionId == nil || deactiveForAccount) { // User not logged in
        return;
    }
    
    NSString *msg = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    NSString *type = [userInfo objectForKey:@"type"];
    
    [self GetSummaryFromPush];
    
    if ([userInfo objectForKey:@"total"]) { //sprout
        [self GetContactList];
    } else if ([userInfo objectForKey:@"board_id"]) { //chat
        BOOL openChat = ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive || [UIApplication sharedApplication].applicationState == UIApplicationStateBackground);
        boardId = [userInfo[@"board_id"] integerValue];
        boardIdForPushnotification = boardId;
        if ([type isEqualToString:@"video_call"] && [userInfo[@"action"] isEqualToString:@"initial"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GINKO_VIDEO_CONFERENCE object:nil userInfo:userInfo];
            if (!isConferenceView) {
                [self initMemberForConference:userInfo];
                [self openCallingVideoScreen:userInfo];
                userInfoByPushForConference = userInfo;
            }else{
                [self performSelector:@selector(checkingConferenceStatus:) withObject:userInfo afterDelay:1.0f];
            }
        }else if ([type isEqualToString:@"video_call"] && [userInfo[@"action"] isEqualToString:@"accept"]){
            if (conferenceStatus == 1) {
                conferenceStatus = 2;
            }
            for (int i = 0 ; i < [conferenceMembersForVideoCalling count]; i ++) {
                NSMutableDictionary *changeUser = [[conferenceMembersForVideoCalling objectAtIndex:i] mutableCopy];
                if ([[changeUser objectForKey:@"user_id"] integerValue] == [userInfo[@"uid"] integerValue]) {
                    [changeUser setObject:@(2) forKey:@"conferenceStatus"];
                    [conferenceMembersForVideoCalling replaceObjectAtIndex:i withObject:changeUser];
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GINKO_VIDEO_CONFERENCE object:nil userInfo:userInfo];
        }else if ([type isEqualToString:@"video_call"] && [userInfo[@"action"] isEqualToString:@"hangup"]){
            BOOL isClosedByOwner = NO;
            for (int i = 0 ; i < [conferenceMembersForVideoCalling count]; i ++) {
                NSMutableDictionary *changeUser = [[conferenceMembersForVideoCalling objectAtIndex:i] mutableCopy];
                if ([[changeUser objectForKey:@"user_id"] integerValue] == [userInfo[@"uid"] integerValue]) {
                    if ([[changeUser objectForKey:@"conferenceStatus"] integerValue] == 8 || [[changeUser objectForKey:@"conferenceStatus"] integerValue] == 1) {
                        [changeUser setObject:@(12) forKey:@"conferenceStatus"];
                    }else if ([[changeUser objectForKey:@"conferenceStatus"] integerValue] == 2) {
                        [changeUser setObject:@(13) forKey:@"conferenceStatus"];
                    }else if ([[changeUser objectForKey:@"conferenceStatus"] integerValue] == 3) {
                        [changeUser setObject:@(11) forKey:@"conferenceStatus"];
                    }
                    [conferenceMembersForVideoCalling replaceObjectAtIndex:i withObject:changeUser];
                    if ([changeUser objectForKey:@"isOwner"]) {
                        isClosedByOwner = YES;
                    }
                }
            }
            BOOL isCheckForInit = NO;
            for (NSDictionary *dic in conferenceMembersForVideoCalling) {
                if ([[dic objectForKey:@"conferenceStatus"] integerValue] < 10) {
                    isCheckForInit = YES;
                }
            }
            if (!isCheckForInit && !isConferenceView) {
                if (conferenceStatus == 1){
                    conferenceStatus = 0;
                    endTypeForConference = 10;
                    
                    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
                    {
                        if ([[_responseObject objectForKey:@"success"] boolValue]) {
                            
                            [self performEndCallActionWithUUID:self.uuidForReceiver];
                            [conferenceMembersForVideoCalling removeAllObjects];
                        }
                    };
                    
                    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
                    {
                    };
                    [[YYYCommunication sharedManager] HangupVideoConference:APPDELEGATE.sessionId boardId:[userInfo objectForKey:@"board_id"] endType:4 successed:successed failure:failure];
                }
            }
            
            if (!isConferenceView && isClosedByOwner  ) {
                if (conferenceStatus == 1){
                    conferenceStatus = 0;
                    endTypeForConference = 10;
                    
                    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
                    {
                        if ([[_responseObject objectForKey:@"success"] boolValue]) {
                            
                            [self performEndCallActionWithUUID:self.uuidForReceiver];
                            [conferenceMembersForVideoCalling removeAllObjects];
                        }
                    };
                    
                    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
                    {
                    };
                    [[YYYCommunication sharedManager] HangupVideoConference:APPDELEGATE.sessionId boardId:[userInfo objectForKey:@"board_id"] endType:4 successed:successed failure:failure];
                }
            }
            
            if (isConferenceView) {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HANGUP_VIDEO_CONFERENCE object:nil userInfo:userInfo];
            }
        }else if ([type isEqualToString:@"video_call"] && [userInfo[@"action"] isEqualToString:@"sdp_available"]){
            BOOL isCheckingExist = NO;
            for (NSDictionary *oneMember in conferenceMembersForVideoCalling) {
                if ([[oneMember objectForKey:@"user_id"] integerValue] == [userInfo[@"uid"] integerValue]) {
                    isCheckingExist = YES;
                }
            }
            if (isCheckingExist) {
                [userIdsForSenddingSDP addObject:userInfo[@"uid"]];
                userInfoByPushForSDP = userInfo;
                isReceiverForConferenceSDP = YES;
                if(isJoinedOnConference){
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GET_SDP_VIDEO_CONFERENCE object:nil userInfo:userInfo];
                }
            }
        }else if ([type isEqualToString:@"video_call"] && [userInfo[@"action"] isEqualToString:@"candidates_available"]){
            BOOL isCheckingExist = NO;
            for (NSDictionary *oneMember in conferenceMembersForVideoCalling) {
                if ([[oneMember objectForKey:@"user_id"] integerValue] == [userInfo[@"uid"] integerValue]) {
                    isCheckingExist = YES;
                }
            }
            if (isCheckingExist) {
                [userIdsForSendingCandidate addObject:userInfo[@"uid"]];
                userInfoByPushForCandidate = userInfo;
                isReceiverForConferenceCandidate = YES;
                if(isJoinedOnConference){
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GET_CANDIDATES_VIDEO_CONFERENCE object:nil userInfo:userInfo];
                }
            }
        }else if ([type isEqualToString:@"video_call"] && [userInfo[@"action"] isEqualToString:@"inviting"]){
            for (NSDictionary * memberOfConference in [userInfo objectForKey:@"userInfo"]) {
                if ([[memberOfConference objectForKey:@"id"] integerValue] != [userId integerValue]) {
                    NSMutableDictionary *dictOfUser = [[NSMutableDictionary alloc] init];
                    [dictOfUser setObject:[memberOfConference objectForKey:@"id"] forKey:@"user_id"];
                    [dictOfUser setObject:[memberOfConference objectForKey:@"name"] forKey:@"name"];
                    [dictOfUser setObject:[memberOfConference objectForKey:@"photo_url"] forKey:@"photo_url"];
                    if ([[userInfo objectForKey:@"callType"] integerValue] == 1) {
                        [dictOfUser setObject:@"on" forKey:@"videoStatus"];
                    }else{
                        [dictOfUser setObject:@"off" forKey:@"videoStatus"];
                    }

                    [dictOfUser setObject:@"on" forKey:@"voiceStatus"];
                    [dictOfUser setObject:@(1) forKey:@"conferenceStatus"];
                    [dictOfUser setObject:@(0) forKey:@"isOwner"];
                    [dictOfUser setObject:@(1) forKey:@"isInvited"];
                    [dictOfUser setObject:@(0) forKey:@"isInvitedByMe"];
                    
                    [APPDELEGATE.conferenceMembersForVideoCalling addObject:dictOfUser];
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_INVITE_MEMBERS_CONFERENCE object:nil userInfo:userInfo];
        }else if ([type isEqualToString:@"video_call"] && [userInfo[@"action"] isEqualToString:@"videooff"]){
            for (NSInteger i=0; i < APPDELEGATE.conferenceMembersForVideoCalling.count; i ++) {
                NSDictionary *dict = [APPDELEGATE.conferenceMembersForVideoCalling objectAtIndex:i];
                if ([[dict objectForKey:@"user_id"] integerValue] == [[userInfo objectForKey:@"uid"] integerValue]) {
                    NSMutableDictionary *dictOfUser = [dict mutableCopy];
                    [dictOfUser setObject:@"off" forKey:@"videoStatus"];
                    [APPDELEGATE.conferenceMembersForVideoCalling replaceObjectAtIndex:i withObject:dictOfUser];
                    break;
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MEMEBER_STATUS_CONFERENCE object:nil userInfo:userInfo];
        }else if ([type isEqualToString:@"video_call"] && [userInfo[@"action"] isEqualToString:@"videoon"]){
            for (NSInteger i=0; i < APPDELEGATE.conferenceMembersForVideoCalling.count; i ++) {
                NSDictionary *dict = [APPDELEGATE.conferenceMembersForVideoCalling objectAtIndex:i];
                if ([[dict objectForKey:@"user_id"] integerValue] == [[userInfo objectForKey:@"uid"] integerValue]) {
                    NSMutableDictionary *dictOfUser = [dict mutableCopy];
                    [dictOfUser setObject:@"on" forKey:@"videoStatus"];
                    [APPDELEGATE.conferenceMembersForVideoCalling replaceObjectAtIndex:i withObject:dictOfUser];
                    break;
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MEMEBER_STATUS_CONFERENCE object:nil userInfo:userInfo];
        }else if ([type isEqualToString:@"video_call"] && [userInfo[@"action"] isEqualToString:@"audiooff"]){
            for (NSInteger i=0; i < APPDELEGATE.conferenceMembersForVideoCalling.count; i ++) {
                NSDictionary *dict = [APPDELEGATE.conferenceMembersForVideoCalling objectAtIndex:i];
                if ([[dict objectForKey:@"user_id"] integerValue] == [[userInfo objectForKey:@"uid"] integerValue]) {
                    NSMutableDictionary *dictOfUser = [dict mutableCopy];
                    [dictOfUser setObject:@"off" forKey:@"voiceStatus"];
                    [APPDELEGATE.conferenceMembersForVideoCalling replaceObjectAtIndex:i withObject:dictOfUser];
                    break;
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MEMEBER_STATUS_CONFERENCE object:nil userInfo:userInfo];
        }else if ([type isEqualToString:@"video_call"] && [userInfo[@"action"] isEqualToString:@"audioon"]){
            for (NSInteger i=0; i < APPDELEGATE.conferenceMembersForVideoCalling.count; i ++) {
                NSDictionary *dict = [APPDELEGATE.conferenceMembersForVideoCalling objectAtIndex:i];
                if ([[dict objectForKey:@"user_id"] integerValue] == [[userInfo objectForKey:@"uid"] integerValue]) {
                    NSMutableDictionary *dictOfUser = [dict mutableCopy];
                    [dictOfUser setObject:@"on" forKey:@"voiceStatus"];
                    [APPDELEGATE.conferenceMembersForVideoCalling replaceObjectAtIndex:i withObject:dictOfUser];
                    break;
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MEMEBER_STATUS_CONFERENCE object:nil userInfo:userInfo];
        }else{
            isNotificationForChatting = YES;
            [self checkNewMessage:openChat];
        }
    } else if ([userInfo objectForKey:@"request_id"]) { //exchange
        BOOL openRequestScreen = ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive || [UIApplication sharedApplication].applicationState == UIApplicationStateBackground);
        if (!openRequestScreen) {
            [self GetContactList];
        }else{
            [self openRequestScreen];
        }
    } else if ([userInfo objectForKey:@"contact_uid"]) { //profile change?
        [self GetContactList];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CONTACTGPS_CHANGED object:nil];
    } else if ([userInfo objectForKey:@"entity_id"]){
        BOOL openWallScreen = ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive || [UIApplication sharedApplication].applicationState == UIApplicationStateBackground);
        if (openWallScreen) {
            if ([userInfo objectForKey:@"other_user_id"]) {
                [self openRequestScreen];
            }else if ([userInfo objectForKey:@"type"] && [[userInfo objectForKey:@"type"] isEqualToString:@"entity_msg"])
                [self openWallScreen];
            else{
                [self GetContactList];
            }
        }else if ([type isEqualToString:@"entity_msg"]) {
            if ([userInfo objectForKey:@"removed_msg_ids"]) {
                removedMsgIdsForEntity = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"removed_msg_ids"]];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:ENTITY_MESSAGE_NOTIFICATION object:nil];
        }else{
            [self GetContactList];
        }
    }else if ([userInfo objectForKey:@"id"] && [type isEqualToString:@"directory"]){
        BOOL openDirectoryRequest = ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive || [UIApplication sharedApplication].applicationState == UIApplicationStateBackground);
        if (openDirectoryRequest) {
            if ([msg rangeOfString:@"invited you to join the directory"].location != NSNotFound) {
                [self openRequestScreen];
            }else{
                directoryIdForPushNotification = [userInfo objectForKey:@"id"];
                [self openDirectoryInviteContactview];
            }
        }
    } else if (type) {
        //contact_changed
        if ([type isEqualToString:@"entity_msg"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ENTITY_MESSAGE_NOTIFICATION object:nil];
        }
        else if ([type isEqualToString:@"gps_contact"]) {//Contact gps setting changed
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CONTACTGPS_CHANGED object:nil];
            
        }
        else if ([type isEqualToString:@"directory"]){
            
        }else if (msg || [type isEqualToString:@"contact_changed"]){
            if (!isRequestScreen){
                [self GetContactList];
            }
            //[[NSNotificationCenter defaultCenter] postNotificationName:CONTACT_SYNC_NOTIFICATION object:nil];
        }
    }
    
    if (!isChatScreen && [userInfo objectForKey:@"board_id"])
    {
        
        if ([type isEqualToString:@"video_call"] && userInfo[@"action"]) {
                [self showNotification:msg keyIndex:0];
        }else if (self.isChatNotification && msg && !([UIApplication sharedApplication].applicationState == UIApplicationStateInactive || [UIApplication sharedApplication].applicationState == UIApplicationStateBackground)) {
            if (!isConferenceView) {
                [self showNotification:msg keyIndex:1];
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MESSAGE_CONFERENCE object:nil userInfo:userInfo];
            }
        }
    }else if (isChatScreen && [userInfo objectForKey:@"board_id"]){
        NSString *receivedMSGID =[userInfo objectForKey:@"board_id"];
        if (self.isChatNotification && msg && !([UIApplication sharedApplication].applicationState == UIApplicationStateInactive || [UIApplication sharedApplication].applicationState == UIApplicationStateBackground) && ![[currentBoardID stringValue] isEqual:receivedMSGID]) {
            [self showNotification:msg keyIndex:1];
        }
    } else if (!isExchageScreen && [userInfo objectForKey:@"request_id"])
    {
        if (self.isExchangeNotification && msg && !([UIApplication sharedApplication].applicationState == UIApplicationStateInactive || [UIApplication sharedApplication].applicationState == UIApplicationStateBackground)) {
            [self showNotification:msg keyIndex:2];
        }
    } else if (!isSproutScreen && [userInfo objectForKey:@"total"])
    {
        if (self.isSproutNotification && msg) {
            [self showNotification:msg keyIndex:0];
        }
    } else if (!isRequestScreen && [userInfo objectForKey:@"entity_id"]) //entity invite
    {
        if (self.isExchangeNotification && msg && !isWallScreen && !([UIApplication sharedApplication].applicationState == UIApplicationStateInactive || [UIApplication sharedApplication].applicationState == UIApplicationStateBackground)) {//new entity msg
            if ([userInfo objectForKey:@"msg_id"] && !isWallScreen) {
                [self showNotification:msg keyIndex:3];
            }else
                [self showNotification:msg keyIndex:2];
        }
    } else if (isRequestScreen && !isWallScreen && ![type isEqualToString:@"contact_changed"] && ![type isEqualToString:@"directory"]) {
        if ([userInfo objectForKey:@"msg_id"]) {
            [self showNotification:msg keyIndex:3];
        }else if (![type isEqualToString:@"contact_changed"]){
            UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
            if ([navController.topViewController isKindOfClass:[TabRequestController class]]) {
                TabRequestController *tabController = (TabRequestController *)navController.topViewController;
                if ([tabController.selectedViewController isKindOfClass:[RequestViewController class]]) {
                    [(RequestViewController *)tabController.selectedViewController GetSentInvitation];
                }
            }
        }
    }else if ([userInfo objectForKey:@"type"])
    {
        if (msg && ![userInfo objectForKey:@"board_id"] && ![userInfo objectForKey:@"entity_id"] && [msg rangeOfString:@"removed"].location == NSNotFound && !([UIApplication sharedApplication].applicationState == UIApplicationStateInactive || [UIApplication sharedApplication].applicationState == UIApplicationStateBackground)) {
            if ([type isEqualToString:@"directory"]) {
                if ([msg rangeOfString:@"invited you to join the directory"].location != NSNotFound) {
                    if (isRequestScreen) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:CONTACT_SYNC_NOTIFICATION object:nil];
                    }else{
                        [self showNotification:msg keyIndex:2];
                    }
                }else if ([msg rangeOfString:@"Admin grants you the permission to access directory"].location != NSNotFound) {
                    if (isGroupScreen) {
                        [self showNotification:msg keyIndex:0];
                        [[NSNotificationCenter defaultCenter] postNotificationName:CONTACT_SYNC_NOTIFICATION object:nil];
                    }else{
                        [self showNotification:msg keyIndex:5];
                    }
                }else{
                    directoryIdForPushNotification = [userInfo objectForKey:@"id"];
                    [self showNotification:msg keyIndex:4];
                }
            }else{
                [self showNotification:msg keyIndex:0];
            }
        }
    }
}
//-(void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
//{
//    // iOS 10 will handle notifications through other methods
//    
////    if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO( @"10.0" ) )
////    {
////        NSLog( @"iOS version >= 10. Let NotificationCenter handle this one." );
////        // set a member variable to tell the new delegate that this is background
////        return;
////    }
//    NSLog( @"HANDLE PUSH, didReceiveRemoteNotification: %@", userInfo );
//    
//    // custom code to handle notification content
//    
//    if( [UIApplication sharedApplication].applicationState == UIApplicationStateInactive )
//    {
//        NSLog( @"INACTIVE" );
//        completionHandler( UIBackgroundFetchResultNewData );
//    }
//    else if( [UIApplication sharedApplication].applicationState == UIApplicationStateBackground )
//    {  
//        NSLog( @"BACKGROUND" );  
//        completionHandler( UIBackgroundFetchResultNewData );  
//    }  
//    else  
//    {  
//        NSLog( @"FOREGROUND" );  
//        completionHandler( UIBackgroundFetchResultNewData );  
//    }
//    
//    [self HandlePushNotification:userInfo];
//}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //[self application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:^(UIBackgroundFetchResult result) {
    
        // iOS 10 will handle notifications through other methods
    
        if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO( @"10.0" ) )
        {
            NSLog( @"iOS version >= 10. Let NotificationCenter handle this one." );
            // set a member variable to tell the new delegate that this is background
            //return;
        }
        NSLog(@"userinfo----%@",userInfo);
        [self HandlePushNotification:userInfo];
    
    //}];
}
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
    NSLog( @"Handle push from foreground" );
    // custom code to handle push while app is in the foreground
    NSLog(@"userinfo----%@",notification.request.content.userInfo);
    
    [self HandlePushNotification:notification.request.content.userInfo];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)())completionHandler
{
    NSLog( @"Handle push from background or closed" );
    // if you set a member variable in didReceiveRemoteNotification, you  will know if this is from closed or background
    NSLog(@"%@", response.notification.request.content.userInfo);
    
    if (isOpenApp) {
        [self HandlePushNotification:response.notification.request.content.userInfo];
    }else {
        [arrhandlePush addObject:response.notification.request.content.userInfo];
    }
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    
    NSLog(@"applicationWillResignActive");
    isSleepMode = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:ApplicationWillResignActive object:nil];
    UIViewController *visibleController = [(UINavigationController *)self.window.rootViewController visibleViewController];
    if (visibleController) {
        if ([visibleController isKindOfClass:[IMVideoCameraController class]]) {
            [(IMVideoCameraController *)visibleController pauseVideoWhenSleepMode];
        }else if ([visibleController isKindOfClass:[VideoCameraController class]]) {
            [(VideoCameraController *)visibleController pauseVideoWhenSleepMode];
        }else if ([visibleController isKindOfClass:[IMVideoEditController class]]) {
            [(IMVideoEditController *)visibleController pauseVideoWhenSleepMode];
        }else if ([visibleController isKindOfClass:[VideoEditController class]]) {
            [(VideoEditController *)visibleController pauseVideoWhenSleepMode];
        }
    }
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    isNotificationForChatting = NO;
    NSLog(@"applicationDidEnterBackground");
    enterTime = [[NSDate date] timeIntervalSince1970];
    if (locationFlag) {
        orignialTimeInterval = intervalIndex;
        [self turnOffGPS];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"applicationWillEnterForeground");
    
    [self currentLocationsUpdate];
    
    //Wang Class IM
    [ [ NSNotificationCenter defaultCenter ] postNotificationName : @"ENTERFROMBACKGROUND" object : nil userInfo : nil ] ;
    isSleepMode = NO;
    //Wang Class IM end
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CONTACT_SYNC_NOTIFICATION object:nil];
}
- (void) turnOnGPS{
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            NSLog(@"GPS status is back");
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        NSLog(@"Change GPS Status failed");
    } ;
    if (APPDELEGATE.sessionId) {
        [[Communication sharedManager] ChangeGPSStatus:[AppDelegate sharedDelegate].sessionId trun_on:@"true" successed:successed failure:failure];
    }
}
- (void)turnOffGPS
{
    if ([AppDelegate sharedDelegate].sessionId) {
        void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
            [ MBProgressHUD hideHUDForView : self.window animated : YES ] ;
            NSLog(@"%@",[_responseObject objectForKey:@"data"]);
            if ([[_responseObject objectForKey:@"success"] boolValue])
            {
                self.intervalIndex = 7;
                [locationManager stopUpdatingLocation];
                isStartedLocationUpdate = NO;
                gpsStatusOfCurrentUser = NO;
            }
        } ;
        
        void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
            [ MBProgressHUD hideHUDForView : self.window animated : YES ] ;
            NSLog(@"Change GPS Status failed");
        } ;
        if (APPDELEGATE.sessionId) {
            [[Communication sharedManager] ChangeGPSStatus:[AppDelegate sharedDelegate].sessionId trun_on:@"false" successed:successed failure:failure];
        }
    }
    
}
- (void)applicationDidBecomeActive:(UIApplication *)applicatiron
{
    NSLog(@"applicationDidBecomeActive");
    
    if ([AppDelegate sharedDelegate].sessionId) {        
        [self GetSummaryFromPush];
        
        if ([APPDELEGATE.arrhandlePush count] > 0) {
            for (int i = 1 ; i <= [APPDELEGATE.arrhandlePush count]; i ++) {
                NSDictionary *onePush = [APPDELEGATE.arrhandlePush objectAtIndex:[APPDELEGATE.arrhandlePush count] - i];
                [APPDELEGATE HandlePushNotification:onePush];
                
                if ([onePush objectForKey:@"board_id"] || [onePush objectForKey:@"request_id"] || [onePush objectForKey:@"entity_id"] || ([onePush objectForKey:@"id"] && [[onePush objectForKey:@"type"] isEqualToString:@"directory"])) {
                }else {
                }
            }
            [APPDELEGATE.arrhandlePush removeAllObjects];
        }
    }
    [FBSDKAppEvents activateApp];
    if (locationFlag) {
        intervalIndex = orignialTimeInterval;
        [self turnOnGPS];
    }
    activeTime = [[NSDate date] timeIntervalSince1970];
    if (intervalIndex != 0 && enterTime != 0 && locationFlag && [AppDelegate sharedDelegate].sessionId)
    {
        float interval = 15;
        float differentTime = activeTime - enterTime;
        int count = differentTime / interval;
        currentCount = currentCount - count;
        if (currentCount < 0)
        {
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
            locationFlag = NO;
            [dict setValue:@"NO" forKey:@"LOCATION_FLAG"];
            [[NSNotificationCenter defaultCenter] postNotificationName:LOCATION_CHANGE_NOTIFICATION object:nil userInfo:dict];
            
            if (timerFlag == YES)
            {
                [gpsCallTimer invalidate];
                timerFlag = NO;
            }
            
            [self turnOffGPS];
        }
    }
    
    UIViewController *visibleController = [(UINavigationController *)self.window.rootViewController visibleViewController];
    if (visibleController && !isNotificationForChatting) {
        if ([visibleController isKindOfClass:[YYYChatViewController class]]) {
            void(^successed)(id _responseObject) = ^(id _responseObject) {
                if ([AppDelegate sharedDelegate].sessionId)
                {
                    //if ([[_responseObject objectForKey:@"data"] count])
                    //{
                        [(YYYChatViewController *)visibleController receviedMessage];
                    //}
                }
            };
            
            [[YYYCommunication sharedManager] CheckNewMessage:[AppDelegate sharedDelegate].sessionId successed:successed failure:nil];
        }
    }
}

- (void) currentLocationsUpdate{
    UIViewController *visibleController = [(UINavigationController *)self.window.rootViewController visibleViewController];
    if (visibleController) {
        if ([visibleController isKindOfClass:[PreviewMainEntityViewController class]]) {
            [(PreviewMainEntityViewController *)visibleController repeatLocationUpdating];
        }else if ([visibleController isKindOfClass:[AllEntityPreviewViewController class]]) {
            [(AllEntityPreviewViewController *)visibleController repeatLocationUpdating];
        }else if ([visibleController isKindOfClass:[MainEntityViewController class]]) {
            [(MainEntityViewController *)visibleController repeatLocationUpdating];
        }else if ([visibleController isKindOfClass:[AllEntityViewController class]]) {
            [(AllEntityViewController *)visibleController repeatLocationUpdating];
        }
    }
}
- (void)applicationWillTerminate:(UIApplication *)application
{
    [locationManager stopUpdatingLocation];
    isStartedLocationUpdate = NO;
    [self GetContactList];
    
    //video/voice conference
    [RTCPeerConnectionFactory deinitializeSSL];
    
    if (isConferenceView && ![[NSString stringWithFormat:@"%@", conferenceId] isEqualToString:@""]) {
        void ( ^successed )( id _responseObject ) = ^( id _responseObject )
        {
            if ([[_responseObject objectForKey:@"success"] boolValue]) {
                
                NSLog(@"closed conference");
            }
        };
        
        void ( ^failure )( NSError* _error ) = ^( NSError* _error )
        {
        };
        [[YYYCommunication sharedManager] HangupVideoConference:APPDELEGATE.sessionId boardId:conferenceId endType:1 successed:successed failure:failure];
    }
}

- (void)rejectOtherCallingOfConference:(NSDictionary *)userInfo{
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        if ([[_responseObject objectForKey:@"success"] boolValue]) {
            
           // [self performEndCallActionWithUUID:self.uuid];
        }
    };
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
    };
    [[YYYCommunication sharedManager] HangupVideoConference:APPDELEGATE.sessionId boardId:[userInfo objectForKey:@"board_id"] endType:3 successed:successed failure:failure];
}

- (void)openCallingVideoScreen:(NSDictionary *)infoCalling{
    if ([AppDelegate sharedDelegate].sessionId)
    {
        // Push;
        if ([self.window.rootViewController isKindOfClass:[UINavigationController class]]) {
                
            
            NSString *ids = @"";
            for (NSDictionary *dict in APPDELEGATE.conferenceMembersForVideoCalling) {
                if ([ids isEqualToString:@""]) {
                    ids = [NSString stringWithFormat:@"%@", [dict objectForKey:@"user_id"]];
                }else {
                    ids = [NSString stringWithFormat:@"%@,%@", ids, [dict objectForKey:@"user_id"]];
                }
            }
            
                [self CreateMessageBoard:ids infoCalling:infoCalling];

        }
    }
}
-(void)CreateMessageBoard:(NSString*)ids infoCalling:(NSDictionary *)_infoCalling
{
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        NSDictionary *result = _responseObject;
        if ([[result objectForKey:@"success"] boolValue]) {
            
            //close current alertview when conference view
            [[NSNotificationCenter defaultCenter] postNotificationName:CLOSE_ALERT_WHEN_CONFERENCEVIEW_NOTIFICATION object:nil userInfo:nil];
            
            isOwnerForConference = NO;
            VideoVoiceConferenceViewController *vc = [[VideoVoiceConferenceViewController alloc] initWithNibName:@"VideoVoiceConferenceViewController" bundle:nil];
            vc.infoCalling = _infoCalling;
            APPDELEGATE.conferenceId = [_infoCalling objectForKey:@"board_id"];
            vc.boardId = [_infoCalling objectForKey:@"board_id"];
            if ([[_infoCalling objectForKey:@"callType"] integerValue] == 1) {
                vc.conferenceType = 1;
            }else{
                vc.conferenceType = 2;
            }
            NSMutableArray *lstTemp = [[NSMutableArray alloc] init];
            for (NSDictionary *dictMember in [[result objectForKey:@"data"] objectForKey:@"members"]) {
                [lstTemp addObject:[dictMember objectForKey:@"memberinfo"]];
            }
            vc.conferenceName = [_infoCalling objectForKey:@"uname"];
            isOwnerForConference = NO;
            
            //[((UINavigationController *)self.window.rootViewController) pushViewController:vc animated:YES];
            if ([self.window.rootViewController isKindOfClass:[UINavigationController class]]) {
                UIViewController *topVC = ((UINavigationController *)self.window.rootViewController).topViewController;
                if (topVC.isViewLoaded && topVC.view.window) {
                    [((UINavigationController *)self.window.rootViewController) pushViewController:vc animated:YES];
                }else{
                    UIViewController *visibleController = [(UINavigationController *)self.window.rootViewController visibleViewController];
                    if (visibleController) {
                        if ([visibleController isKindOfClass:[PreviewMainEntityViewController class]]) {
                            [(PreviewMainEntityViewController *)visibleController movePushNotificationConferenceViewController:_infoCalling];
                        } else if ([visibleController isKindOfClass:[PreviewEntityViewController class]]) {
                            [(PreviewEntityViewController *)visibleController movePushNotificationConferenceViewController:_infoCalling];
                        }else if ([visibleController isKindOfClass:[CreateEntityViewController class]]) {
                            [(CreateEntityViewController *)visibleController movePushNotificationConferenceViewController:_infoCalling];
                        }else if ([visibleController isKindOfClass:[ManageEntityViewController class]]) {
                            [(ManageEntityViewController *)visibleController movePushNotificationConferenceViewController:_infoCalling];
                        }else if([visibleController isKindOfClass:[EntityInviteContactsViewController class]]){
                            [(EntityInviteContactsViewController *)visibleController movePushNotificationConferenceViewController:_infoCalling];
                        }else if([visibleController isKindOfClass:[QRReaderViewController class]]){
                            [(QRReaderViewController *)visibleController movePushNotificationConferenceViewController:_infoCalling];
                        }else if([visibleController isKindOfClass:[GinkoMeTabController class]]){
                            [(GinkoMeTabController *)visibleController movePushNotificationConferenceViewController:_infoCalling];
                        }else if([visibleController isKindOfClass:[ProfileViewController class]]){
                            [(ProfileViewController *)visibleController movePushNotificationConferenceViewController:_infoCalling];
                        }else if([visibleController isKindOfClass:[PreviewProfileViewController class]]){
                            [(PreviewProfileViewController *)visibleController movePushNotificationConferenceViewController:_infoCalling];
                        }else if([visibleController isKindOfClass:[ContactFilterViewController class]]){
                            [(ContactFilterViewController *)visibleController movePushNotificationConferenceViewController:_infoCalling];
                        }else if([visibleController isKindOfClass:[IMPhotoEditController class]]){
                            [(IMPhotoEditController *)visibleController movePushNotificationConferenceViewController:_infoCalling];
                        }else if([visibleController isKindOfClass:[IMPhotoViewController class]]){
                            [(IMPhotoViewController *)visibleController movePushNotificationConferenceViewController:_infoCalling];
                        }else if([visibleController isKindOfClass:[IMPhotoCameraController class]]){
                            [(IMPhotoCameraController *)visibleController movePushNotificationConferenceViewController:_infoCalling];
                        }else if([visibleController isKindOfClass:[PhotoCameraController class]]){
                            [(PhotoCameraController *)visibleController movePushNotificationConferenceViewController:_infoCalling];
                        }else if([visibleController isKindOfClass:[AddSubEntitiesViewController class]]){
                            [(AddSubEntitiesViewController *)visibleController movePushNotificationConferenceViewController:_infoCalling];
                        }else if([visibleController isKindOfClass:[AddInfoOfSubEntityViewController class]]){
                            [(AddInfoOfSubEntityViewController *)visibleController movePushNotificationConferenceViewController:_infoCalling];
                        }else if([visibleController isKindOfClass:[YYYLocationController class]]){
                            [(YYYLocationController *)visibleController movePushNotificationConferenceViewController:_infoCalling];
                        }else if([visibleController isKindOfClass:[CreateDirectoryViewController class]]){
                            [(CreateDirectoryViewController *)visibleController movePushNotificationConferenceViewController:_infoCalling];
                        }else if([visibleController isKindOfClass:[IMVideoEditController class]]){
                            [(IMVideoEditController *)visibleController movePushNotificationConferenceViewController:_infoCalling];
                        }else if([visibleController isKindOfClass:[IMVideoViewController class]]){
                            [(IMVideoViewController *)visibleController movePushNotificationConferenceViewController:_infoCalling];
                        }else if([visibleController isKindOfClass:[IMVideoCameraController class]]){
                            [(IMVideoCameraController *)visibleController movePushNotificationConferenceViewController:_infoCalling];
                        }else if([visibleController.parentViewController isKindOfClass:[ELCImagePickerController class]]){
                            [(ELCImagePickerController *)visibleController.parentViewController movePushNotificationConferenceViewController:_infoCalling];
                        }else if([visibleController.parentViewController isKindOfClass:[UIImagePickerController class]]){
                            [self moveConferenceViewController:_infoCalling];
                        }else if([visibleController isKindOfClass:[PreDirectoryViewController class]]){
                            [(PreDirectoryViewController *)visibleController movePushNotificationConferenceViewController:_infoCalling];
                        }else if([visibleController isKindOfClass:[YYYSelectContactController class]]){
                            [(YYYSelectContactController *)visibleController movePushNotificationConferenceViewController:_infoCalling];
                        }else if([visibleController isKindOfClass:[SelectUserForConferenceViewController class]]){
                            [(SelectUserForConferenceViewController *)visibleController movePushNotificationConferenceViewController:_infoCalling];
                        }
                    }
                }
            }
        }
        
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
        //[CommonMethods showAlertUsingTitle:@"Error!" andMessage:[[_responseObject objectForKey:@"err"] objectForKey:@"errMsg"]];
    } ;
    
    [[Communication sharedManager] GetBoardInformation:APPDELEGATE.sessionId boardid:[NSString stringWithFormat:@"%@",[_infoCalling objectForKey:@"board_id"]] successed:successed failure:failure];
    
}
- (void)moveConferenceViewController:(NSDictionary *)dic{
    VideoVoiceConferenceViewController *vc = [[VideoVoiceConferenceViewController alloc] initWithNibName:@"VideoVoiceConferenceViewController" bundle:nil];
    vc.infoCalling = dic;
    vc.boardId = [dic objectForKey:@"board_id"];
    if ([[dic objectForKey:@"callType"] integerValue] == 1) {
        vc.conferenceType = 1;
    }else{
        vc.conferenceType = 2;
    }
    vc.conferenceName = [dic objectForKey:@"uname"];
    [currentImagePickerController pushViewController:vc animated:YES];
}
- (void)openRequestScreen{
    if ([AppDelegate sharedDelegate].sessionId)
    {
        
        // Push;
        if ([self.window.rootViewController isKindOfClass:[UINavigationController class]]) {
            UIViewController *topVC = ((UINavigationController *)self.window.rootViewController).topViewController;
            if (topVC.isViewLoaded && topVC.view.window) {
                TabRequestController *tabRequestController = [TabRequestController sharedController];
                tabRequestController.selectedIndex = 1;
                [((UINavigationController *)self.window.rootViewController) pushViewController:tabRequestController animated:YES];
            }else{
                
                UIViewController *visibleController = [(UINavigationController *)self.window.rootViewController visibleViewController];
                if (visibleController) {
                    if ([visibleController isKindOfClass:[PreviewMainEntityViewController class]]) {
                        [(PreviewMainEntityViewController *)visibleController movePushNotificationViewController];
                    } else if ([visibleController isKindOfClass:[PreviewEntityViewController class]]) {
                        [(PreviewEntityViewController *)visibleController movePushNotificationViewController];
                    }else if ([visibleController isKindOfClass:[CreateEntityViewController class]]) {
                        isCreateEntityViewController = YES;
                        [(CreateEntityViewController *)visibleController movePushNotificationViewController];
                    } else if ([visibleController isKindOfClass:[GinkoMeTabController class]]) {
                        [(GinkoMeTabController *)visibleController movePushNotificationViewController];
                    }else if ([visibleController isKindOfClass:[DirectoryInviteContactsViewController class]]) {
                        [(DirectoryInviteContactsViewController *)visibleController movePushNotificationViewController];
                    }else if ([visibleController isKindOfClass:[CreateDirectoryViewController class]]) {
                        isCreateEntityViewController = YES;
                        [(CreateDirectoryViewController *)visibleController movePushNotificationViewController];
                    }else if ([visibleController isKindOfClass:[ManageDirectoryViewController class]]) {
                        [(ManageDirectoryViewController *)visibleController movePushNotificationViewController];
                    }else if ([visibleController isKindOfClass:[PreDirectoryViewController class]]) {
                        [(PreDirectoryViewController *)visibleController movePushNotificationViewController];
                    }
                }
            }
        }
    }
}
- (void)openGroupScreen{
    if ([AppDelegate sharedDelegate].sessionId)
    {
        if ([self.window.rootViewController isKindOfClass:[UINavigationController class]]) {
            UIViewController *topVC = ((UINavigationController *)self.window.rootViewController).topViewController;
            if (topVC.isViewLoaded && topVC.view.window) {
                GroupsViewController *vc = [[GroupsViewController alloc] initWithNibName:@"GroupsViewController" bundle:nil];
                [((UINavigationController *)self.window.rootViewController) pushViewController:vc animated:YES];
            }else{
                UIViewController *visibleController = [(UINavigationController *)self.window.rootViewController visibleViewController];
                if (visibleController) {
                    if ([visibleController isKindOfClass:[PreDirectoryViewController class]]) {
                        
                    }
                }
            }
        }
    }

}
- (void)openDirectoryInviteContactview{
    if ([AppDelegate sharedDelegate].sessionId)
    {
        if ([self.window.rootViewController isKindOfClass:[UINavigationController class]]) {
            UIViewController *topVC = ((UINavigationController *)self.window.rootViewController).topViewController;
            if (topVC.isViewLoaded && topVC.view.window) {
                DirectoryInviteContactsViewController *vc = [[DirectoryInviteContactsViewController alloc] initWithNibName:@"DirectoryInviteContactsViewController" bundle:nil];
                vc.directoryID = directoryIdForPushNotification;
                vc.navBarColor = NO;
                vc.statusFromNavi = 4;
                [((UINavigationController *)self.window.rootViewController) pushViewController:vc animated:YES];
            }else{
                UIViewController *visibleController = [(UINavigationController *)self.window.rootViewController visibleViewController];
                if (visibleController) {
                    if ([visibleController isKindOfClass:[PreDirectoryViewController class]]) {
                        [(PreDirectoryViewController *)visibleController movingInviteViewFromNotification:directoryIdForPushNotification];
                    }
                }
            }
        }
    }
}
- (void)openWallScreen{
    if ([AppDelegate sharedDelegate].sessionId)
    {
        if (isChatViewScreen) {
            UIViewController *visibleController = [(UINavigationController *)self.window.rootViewController visibleViewController];
            if (visibleController) {
                if ([visibleController isKindOfClass:[ChatViewController class]]) {
                    [(ChatViewController *)visibleController moveWallHistory];
                }
            }
        }else {
            ChatViewController * controller = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
            controller.isWall = YES;
            if ([self.window.rootViewController isKindOfClass:[UINavigationController class]]) {
                UIViewController *topVC = ((UINavigationController *)self.window.rootViewController).topViewController;
                if (topVC.isViewLoaded && topVC.view.window) {
                    [((UINavigationController *)self.window.rootViewController) pushViewController:controller animated:YES];
                }
            }
        }
    }
}
- (void)openChatForBoard {
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            for (NSDictionary *dict in [_responseObject objectForKey:@"data"])
            {
                //if ([[dict objectForKey:@"members"] count] > 1 && [dict[@"board_id"] integerValue] == boardId && boardId != [currentBoardID integerValue]) {
                if ([dict[@"board_id"] integerValue] == boardId && boardId != [currentBoardID integerValue]) {
                    
                    NSMutableArray *lstTemp = [[NSMutableArray alloc] init];
                    BOOL isFriend = YES;
                    BOOL isMembersSameDirectory = NO;
                    YYYChatViewController *viewcontroller = [[YYYChatViewController alloc] initWithNibName:@"YYYChatViewController" bundle:nil];
                    
                    if ([[dict objectForKey:@"is_group"] boolValue]) {//directory chat for members
                        viewcontroller.isDeletedFriend = NO;
                        viewcontroller.groupName = [dict objectForKey:@"board_name"];
                        viewcontroller.isMemberForDiectory = YES;
                        viewcontroller.isDirectory = YES;
                    }else{
                        NSDictionary * newMessageOwner;
                        for (NSDictionary *dictMember in dict[@"members"]) {
                            if ([[[dictMember objectForKey:@"memberinfo"] objectForKey:@"user_id"] integerValue] == [[[dict objectForKey:@"recent_messages"][0] objectForKey:@"send_from"] integerValue]) {
                                newMessageOwner = [dictMember objectForKey:@"memberinfo"];
                            }else{
                                [lstTemp addObject:[dictMember objectForKey:@"memberinfo"]];
                            }
                        }
                        viewcontroller.isDeletedFriend = YES;
                        for (NSDictionary *memberDic in dict[@"members"]) {
                            if ([memberDic[@"is_friend"] boolValue]) {
                                viewcontroller.isDeletedFriend = NO;
                                isFriend = NO;
                            }                            
                            if ([memberDic[@"in_same_directory"] boolValue]) {
                                isMembersSameDirectory = YES;
                            }
                        }
                        if (isMembersSameDirectory) {
                            viewcontroller.isDeletedFriend = NO;
                            viewcontroller.groupName = [dict objectForKey:@"board_name"];
                            viewcontroller.isMemberForDiectory = YES;
                            viewcontroller.isDirectory = NO;
                        }
                        if (newMessageOwner) {
                            [lstTemp addObject:newMessageOwner];
                        }
                        viewcontroller.lstUsers = lstTemp;
                    }
                    
                    viewcontroller.boardid = @(boardId);
                    
                    if ([self.window.rootViewController isKindOfClass:[UINavigationController class]]) {
                        UIViewController *topVC = ((UINavigationController *)self.window.rootViewController).topViewController;
                        if (topVC.isViewLoaded && topVC.view.window) {
                            [((UINavigationController *)self.window.rootViewController) pushViewController:viewcontroller animated:YES];
                        }else{
                            UIViewController *visibleController = [(UINavigationController *)self.window.rootViewController visibleViewController];
                            if (visibleController) {
                                if ([visibleController isKindOfClass:[PreviewMainEntityViewController class]]) {
                                    isCreateEntityViewController = YES;
                                    [(PreviewMainEntityViewController *)visibleController movePushNotificationChatViewController:@(boardId) isDeletedFriend:isFriend users:lstTemp isDirectory:dict];
                                } else if ([visibleController isKindOfClass:[PreviewEntityViewController class]]) {
                                    isCreateEntityViewController = YES;
                                    [(PreviewEntityViewController *)visibleController movePushNotificationChatViewController:@(boardId) isDeletedFriend:isFriend users:lstTemp isDirectory:dict];
                                }else if ([visibleController isKindOfClass:[CreateEntityViewController class]]) {
                                    isCreateEntityViewController = YES;
                                    [(CreateEntityViewController *)visibleController movePushNotificationChatViewController:@(boardId) isDeletedFriend:isFriend users:lstTemp isDirectory:dict];
                                }else if ([visibleController isKindOfClass:[ManageEntityViewController class]]) {
                                    isCreateEntityViewController = YES;
                                    [(ManageEntityViewController *)visibleController movePushNotificationChatViewController:@(boardId) isDeletedFriend:isFriend users:lstTemp isDirectory:dict];
                                }else if([visibleController isKindOfClass:[EntityInviteContactsViewController class]]){
                                    [(EntityInviteContactsViewController *)visibleController movePushNotificationChatViewController:@(boardId) isDeletedFriend:isFriend users:lstTemp isDirectory:dict];
                                
                                }else if([visibleController isKindOfClass:[QRReaderViewController class]]){
                                    [(QRReaderViewController *)visibleController movePushNotificationChatViewController:@(boardId) isDeletedFriend:isFriend users:lstTemp isDirectory:dict];
                                    
                                }else if([visibleController isKindOfClass:[GinkoMeTabController class]]){
                                    [(GinkoMeTabController *)visibleController movePushNotificationChatViewController:@(boardId) isDeletedFriend:isFriend users:lstTemp isDirectory:dict];
                                    
                                }else if([visibleController isKindOfClass:[ProfileViewController class]]){
                                    [(ProfileViewController *)visibleController movePushNotificationChatViewController:@(boardId) isDeletedFriend:isFriend users:lstTemp isDirectory:dict];
                                    
                                }else if([visibleController isKindOfClass:[PreviewProfileViewController class]]){
                                    [(PreviewProfileViewController *)visibleController movePushNotificationChatViewController:@(boardId) isDeletedFriend:isFriend users:lstTemp isDirectory:dict];
                                    
                                }else if([visibleController isKindOfClass:[ContactFilterViewController class]]){
                                    [(ContactFilterViewController *)visibleController movePushNotificationChatViewController:@(boardId) isDeletedFriend:isFriend users:lstTemp isDirectory:dict];
                                    
                                }else if([visibleController isKindOfClass:[IMPhotoEditController class]]){
                                    [(IMPhotoEditController *)visibleController movePushNotificationChatViewController:@(boardId) isDeletedFriend:isFriend users:lstTemp isDirectory:dict];
                                    
                                }else if([visibleController isKindOfClass:[IMPhotoViewController class]]){
                                    [(IMPhotoViewController *)visibleController movePushNotificationChatViewController:@(boardId) isDeletedFriend:isFriend users:lstTemp isDirectory:dict];
                                    
                                }else if([visibleController isKindOfClass:[IMPhotoCameraController class]]){
                                    [(IMPhotoCameraController *)visibleController movePushNotificationChatViewController:@(boardId) isDeletedFriend:isFriend users:lstTemp isDirectory:dict];
                                    
                                }else if([visibleController isKindOfClass:[PhotoCameraController class]]){
                                    [(PhotoCameraController *)visibleController movePushNotificationChatViewController:@(boardId) isDeletedFriend:isFriend users:lstTemp isDirectory:dict];
                                }else if([visibleController isKindOfClass:[AddSubEntitiesViewController class]]){
                                    isCreateEntityViewController = YES;
                                    [(AddSubEntitiesViewController *)visibleController movePushNotificationChatViewController:@(boardId) isDeletedFriend:isFriend users:lstTemp isDirectory:dict];
                                }else if([visibleController isKindOfClass:[AddInfoOfSubEntityViewController class]]){
                                    isCreateEntityViewController = YES;
                                    [(AddInfoOfSubEntityViewController *)visibleController movePushNotificationChatViewController:@(boardId) isDeletedFriend:isFriend users:lstTemp isDirectory:dict];
                                }else if([visibleController isKindOfClass:[VideoVoiceConferenceViewController class]]){
                                    [(VideoVoiceConferenceViewController *)visibleController movePushNotificationChatViewController:@(boardId) isDeletedFriend:isFriend users:lstTemp isDirectory:dict];
                                }
                            }
                        }
                    }
                    
                    break;
                }else if ([dict[@"board_id"] integerValue] == boardId && boardId == [currentBoardID integerValue]){
                    UIViewController *visibleController = [(UINavigationController *)self.window.rootViewController visibleViewController];
                    if (visibleController) {
                        if ([visibleController isKindOfClass:[YYYChatViewController class]]) {
                            [(YYYChatViewController *)visibleController receviedMessage];
                        }
                    }
                }
            }
        }
    };
    [[YYYCommunication sharedManager] GetChatBoards:[AppDelegate sharedDelegate].sessionId successed:successed failure:nil];
}
-(void)checkNewMessage:(BOOL)openChat
{
    if ([AppDelegate sharedDelegate].sessionId)
    {
        if (openChat) {
            if (isConferenceView && boardId == [conferenceId integerValue]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MESSAGEBOX_OPEN_CONFERENCE object:nil userInfo:nil];
            }else{
                [self openChatForBoard];
            }
        } else {
//            UIViewController *visibleController = [(UINavigationController *)self.window.rootViewController visibleViewController];
//            if (visibleController && !isNotificationForChatting) {
//                if ([visibleController isKindOfClass:[YYYChatViewController class]]) {
//                    void(^successed)(id _responseObject) = ^(id _responseObject) {
//                        if ([AppDelegate sharedDelegate].sessionId)
//                        {
//                            //if ([[_responseObject objectForKey:@"data"] count])
//                            //{
//                            [(YYYChatViewController *)visibleController receviedMessage];
//                            //}
//                        }
//                    };
//                    
//                    [[YYYCommunication sharedManager] CheckNewMessage:[AppDelegate sharedDelegate].sessionId successed:successed failure:nil];
//                }
//            }
            
            void(^successed)(id _responseObject) = ^(id _responseObject) {
                if ([AppDelegate sharedDelegate].sessionId)
                {
                    if ([[_responseObject objectForKey:@"data"] count])
                    {
                        APPDELEGATE.isReceivedChattingMessage = YES;
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"NEWMESSAGE" object:nil userInfo:(NSDictionary*)_responseObject];
                    }
                }
            };
            
            [[YYYCommunication sharedManager] CheckNewMessage:[AppDelegate sharedDelegate].sessionId successed:successed failure:nil];
            
        }
    }
}

- (void)GetContactList
{
    //NSLog(@"Call GetContactList of AppDelegate");
    if (![AppDelegate sharedDelegate].sessionId) // if not logged in, return
        return;
//    if(isCalledGetContactList){
//        isCalledGetContactList = NO;
        void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
            
//            isCalledGetContactList = YES;
            //NSLog(@"%@",_responseObject);
            NSDictionary * contacts = [_responseObject objectForKey:@"data"];
            NSArray * friends = [contacts objectForKey:@"friends"];
            NSMutableDictionary * temp = [[NSMutableDictionary alloc] init];
            
            NSInteger oldNotExchangedCount = notExchangedList.count;
            
            countGPScontactList = [[contacts objectForKey:@"total"] intValue];
            
//            if (countGPScontactList <= [contactList count]){
                
                [contactList removeAllObjects];
                [exchangedList removeAllObjects];
                [notExchangedList removeAllObjects];
//            }
            
            for (int i = 0 ; i < [friends count] ; i++)
            {
                NSDictionary * dict = [friends objectAtIndex:i];
                if (![dict objectForKey:@"entity_id"]) {
                    NSString * userID = [dict objectForKey:@"contact_id"];
                    BOOL exchangedFlag = [[dict objectForKey:@"exchanged"] boolValue];
                    if ([temp objectForKey:userID] == nil || [[temp objectForKey:userID] isEqualToString:@""])
                    {
                        [temp setObject:@"YES" forKey:userID];
                        [contactList addObject:dict];
                        if (exchangedFlag)
                        {
                            [exchangedList addObject:dict];
                        }
                        else
                        {
                            [notExchangedList addObject:dict];
                        }
                    }
                } else {
                    [contactList addObject:dict];
                    [notExchangedList addObject:dict];
                }
                
            }
            
//            if (countGPScontactList > [contactList count]) {
//                [self GetContactList];
//            }else{
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                //        [dict setObject:contactList forKey:@"BothList"];
                [dict setObject:exchangedList forKey:@"ExchangedList"];
                [dict setObject:notExchangedList forKey:@"NotExchangedList"];
                NSLog(@"old = %ld   new = %lu", (long)oldNotExchangedCount, (unsigned long)notExchangedList.count);
                if (notExchangedList.count > oldNotExchangedCount)
                    [dict setObject:@YES forKey:@"FoundNew"];
                [[NSNotificationCenter defaultCenter] postNotificationName:CONTACT_SYNC_NOTIFICATION object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:GET_CONTACTLIST_NOTIFICATION object:nil userInfo:dict];
                [[NSNotificationCenter defaultCenter] postNotificationName:ENTITY_MESSAGE_NOTIFICATION object:nil];
//            }
        } ;
        
        void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
            NSLog(@"Connection failed - %@", _error);
//            isCalledGetContactList = YES;
        } ;
        
        [[Communication sharedManager] GetFriendsFound:[AppDelegate sharedDelegate].sessionId type:@"3" pageNum:@"1" countPerPage:@"50" successed:successed failure:failure];
//    }
    
    
}

- (void)GetSummaryFromPush
{
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        bValid = [[[_responseObject objectForKey:@"data"] objectForKey:@"all_cb_valid"] boolValue];
        newChatNum = [[[_responseObject objectForKey:@"data"] objectForKey:@"new_chat_msg_num"] intValue];
        notExchangeNum = [[[_responseObject objectForKey:@"data"] objectForKey:@"not_xcg_sprout_num"] intValue];
        if (xchageReqNum != [[[_responseObject objectForKey:@"data"] objectForKey:@"xcg_req_num"] intValue])
        {
            xchageReqNum = [[[_responseObject objectForKey:@"data"] objectForKey:@"xcg_req_num"] intValue];
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_XCHG_NOTIFICATION object:nil];
        }
        [self showCountNum];
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        NSLog(@"Connection failed - %@", _error);
    } ;
    
    [[Communication sharedManager] GetCBEmailValid:[AppDelegate sharedDelegate].sessionId successed:successed failure:failure];
}

- (void)showCountNum
{
    if ([self.window.rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
        if ([[navController.viewControllers objectAtIndex:0] isKindOfClass:[ContactViewController class]]) {
            [(ContactViewController *)[navController.viewControllers objectAtIndex:0] showCountNum];
        }else if ([[navController.viewControllers objectAtIndex:0] isKindOfClass:[ScanMeViewController class]]) {
            [(ScanMeViewController *)[navController.viewControllers objectAtIndex:0] updateNumber];
        }
    }
}

- (void)setWizardPage:(NSString *)wizardValue
{
    [MBProgressHUD showHUDAddedTo:[AppDelegate sharedDelegate].window animated:YES];
    
    void (^successed)(id responseObject) = ^(id responseObject) {
        [MBProgressHUD hideHUDForView:[AppDelegate sharedDelegate].window animated:YES];
        NSDictionary *result = responseObject;
        
        if ([[result objectForKey:@"success"] boolValue]) {
            [AppDelegate sharedDelegate].strSetupPage = wizardValue;
            [self setupNext];
            
        } else {
            NSDictionary *dictError = [result objectForKey:@"err"];
            if (dictError) {
                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:[dictError objectForKey:@"errMsg"]];
            } else {
                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Failed to connect to server!"];
            }
        }
    };
    
    void (^failure)(NSError* error) = ^(NSError* error) {
        [MBProgressHUD hideHUDForView:[AppDelegate sharedDelegate].window animated:YES];
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Failed to connect to server!"];
    };
    
    [[YYYCommunication sharedManager] setWizardPage:[AppDelegate sharedDelegate].sessionId setupPage:wizardValue successed:successed failure:failure];
}

#pragma mark - Core data methods
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"internal.sqlite"];
    
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
                              NSInferMappingModelAutomaticallyOption: @YES};
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


//dismissing ActionSheet with conference
- (void)dismissActionSheetWithConference:(UIActionSheet *)_sheet{
    sheetToConference = _sheet;
    countForActionSheet = 0;
    timerCheckingConferenceView = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(checkingConferenceViewStatus) userInfo:nil repeats:YES];
}
- (void)stopTimerForDismissingActionSheet{    
    [timerCheckingConferenceView invalidate];
    timerCheckingConferenceView = nil;
}

- (void)checkingConferenceViewStatus{
    countForActionSheet = countForActionSheet +1;
    if (countForActionSheet == 20) {
        [timerCheckingConferenceView invalidate];
        timerCheckingConferenceView = nil;
    }
    if (isConferenceView) {
        [timerCheckingConferenceView invalidate];
        timerCheckingConferenceView = nil;
        [sheetToConference dismissWithClickedButtonIndex:-1 animated:YES];
    }
}

@end
