//
//  AppDelegate.h
//  Ginko
//
//  Created by Qi Song on 29/3/14.
//  Copyright (c) 2014 Qi Song. All rights reserved.
//
// --- Headers ---;

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

//Wang Class IM
#import <CoreData/CoreData.h>
//Wang Class IM end

#import <PushKit/PushKit.h>
#import <Pushkit/PKPushRegistry.h>

#import <UserNotifications/UserNotifications.h>

#import "CallManager.h"
#import <CallKit/CallKit.h>
#import <PhotosUI/PhotosUI.h>
// --- Classes ---;
@class NavigationController;

// Wang Class
@class YYYViewController;
// Wang Class end

// --- Defines ---;
// AppDelegate Class;
@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate,CLLocationManagerDelegate,UNUserNotificationCenterDelegate, PKPushRegistryDelegate, CallManagerDelegate>
{
    NSInteger boardId;  // board id from notification
    NSString *directoryIdForPushNotification; // directory id from notification
}
// Properties;

//@property (nonatomic, retain) UIWindow *window; //Wang class ingnore
//@property (nonatomic, retain) NavigationController *viewController; //Wang class ingnore

@property (nonatomic, retain) UIImagePickerController *currentImagePickerController;

@property (nonatomic, retain) CLLocationManager * locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;
@property (nonatomic, assign) CLLocationCoordinate2D currentLocationforMultiLocations;
@property (nonatomic, assign) NSInteger intervalIndex;
@property (nonatomic, assign) NSInteger currentCount;
@property (nonatomic, retain) NSTimer * gpsCallTimer;
@property (nonatomic, assign) BOOL timerFlag;
@property (nonatomic, retain) NSString * myName;

@property (nonatomic, retain) NSMutableArray * contactList;
@property (nonatomic, retain) NSMutableArray * exchangedList;
@property (nonatomic, retain) NSMutableArray * notExchangedList;
@property (nonatomic, retain) NSArray * totalList;

@property (nonatomic, retain) NSMutableArray * existedContactIDs;

//added by liu
@property (nonatomic, retain) NSDictionary *allFetchEntityes;


@property (nonatomic, assign) long enterTime;
@property (nonatomic, assign) long activeTime;
@property (nonatomic, assign) BOOL approveFlag;


@property (nonatomic, strong) NSDictionary *userDicForCalling;
@property (nonatomic, strong) NSUUID *uuidForReceiver;
@property (nonatomic, strong) CXCallController * callkitCallController;

// Created by Zhun L.
/**
 0: Request, 1: Invite, 2: Pending, 4: Contact 5:serched contact 6:directory 7:joined directory 8:directory request 9:directory owner
 */

@property (nonatomic, nonatomic) int type;

@property (nonatomic, nonatomic) int viewType;

// -----------------

// importer class
@property (nonatomic, retain) NSMutableDictionary *importDict;

@property (nonatomic, retain)NSDictionary *userInfoForPushnotification;

- (void) refreshLocationUpdating;
- (void) repeatUpdating;
- (void)GetContactList;

- (void)goToMainContact;
- (void)goToSplash;
- (void)goToSetupCB;
//- (void)goToContactImporter;

// Wang Class

+(AppDelegate*)sharedDelegate;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) YYYViewController *viewController;
@property (nonatomic,retain) NSString *strDeviceToken;
@property (nonatomic, retain) NSString *voIPDeviceToken;

@property (nonatomic,retain) NSMutableDictionary *dictInfoHome;
@property (nonatomic,retain) NSMutableDictionary *dictInfoWork;

//UserInformation
@property (nonatomic,retain) NSString *sessionId;
@property (nonatomic,retain) NSNumber *userId;
@property (nonatomic,retain) NSString *firstName;
@property (nonatomic,retain) NSString *lastName;
@property (nonatomic, strong) NSString *userName;   // unique user name for ginko connect invite
@property (nonatomic, strong) NSString *photoUrl;
@property (nonatomic, strong) NSNumber *syncTimeStamp;
@property (nonatomic, strong) NSString *qrCode;
@property (nonatomic) NSInteger gpsFilterType;
@property (nonatomic) CGFloat latitude;//User's last location from login
@property (nonatomic) CGFloat longitude;
@property (nonatomic, assign) BOOL phoneVerified;

@property (nonatomic, assign) BOOL isNewContactFind;


@property (nonatomic, assign) BOOL isOpenApp;
@property (nonatomic, strong) NSMutableArray *arrhandlePush;
@property (nonatomic, retain) NSTimer * timerIfNoOpenApp;
@property (nonatomic, retain) NSTimer * timerTillAccept;
@property NSInteger countTillAccept;
@property (nonatomic, strong) CXAnswerCallAction *callAction;

//Assist Sign UP
@property (nonatomic,retain) NSString *homeVideoURL;

@property (nonatomic,retain) NSString *workVideoURL;

-(void)goToSetup;
- (void)setupNext;
// Wang Class end

//Wang Class IM
@property BOOL isChatScreen;
@property BOOL isExchageScreen;
@property BOOL isRequestScreen;
@property BOOL isSproutScreen;
@property BOOL isWallScreen;
@property BOOL isChatViewScreen;
@property BOOL isGroupScreen;
@property BOOL bCamera;
@property BOOL bFiltered;

@property BOOL calledloadDetectedContacts;

@property BOOL isPlayingAudio;

@property BOOL deactiveForAccount;

@property BOOL isSleepMode;

@property NSNumber *currentBoardID;

@property BOOL bLibrary;  //select video

@property BOOL gpsStatusOfCurrentUser;

@property BOOL calledGetGroups;

@property BOOL isShownChattingScreenWithMapVideo;
@property BOOL isReceivedChattingMessage;

@property BOOL isPreviewPhoneVerifyView;

@property BOOL isNotificationForChatting;
@property NSInteger boardIdForPushnotification;

@property BOOL isVideoAndVoiceConferenceScreen;
@property BOOL isOwnerForConference;
@property BOOL isReceiverForConferenceSDP;
@property BOOL isReceiverForConferenceCandidate;
@property BOOL isJoinedOnConference;
@property BOOL isConferenceView;
@property NSInteger conferenceStatus; // 1: starting, 2: has conference 3: ending
@property (nonatomic, retain) NSString *conferenceId;

@property (nonatomic,retain) NSDictionary *userInfoByPushForConference;
@property (nonatomic,retain) NSDictionary *userInfoByPushForSDP;
@property (nonatomic,retain) NSDictionary *userInfoByPushForCandidate;
@property (nonatomic, retain) NSMutableArray *conferenceMembersForVideoCalling;

@property (nonatomic, retain) NSMutableArray *userIdsForSenddingSDP;
@property (nonatomic, retain) NSMutableArray *userIdsForSendingCandidate;

@property (nonatomic, assign) NSInteger endTypeForConference;
//-(void)timer;
//Wang Class IM end

//Wang Class AE
//@property (nonatomic,retain) UIImage *imgEntityForeground;
//@property (nonatomic,retain) UIImage *imgEntityBackground;
//@property (nonatomic,retain) NSString *strEntityForegroundID;
//@property (nonatomic,retain) NSString *strEntityBackgroundID;
@property (nonatomic) CGRect workInfoForegroundFrame;
//@property (nonatomic,retain) NSString *strCurrentEntityID;
//Wang Class AE end

@property BOOL didFinishFlag;
@property BOOL didTurnOnFlag;

@property (nonatomic, readwrite) int newChatNum;
@property (nonatomic, readwrite) int notExchangeNum;
@property (nonatomic, readwrite) int xchageReqNum;
@property (nonatomic, readwrite) BOOL bValid;

@property (nonatomic, readwrite) int countGPScontactList;
@property BOOL isCalledGetContactList;


@property (nonatomic, retain) NSString *facebookAccessToke;

@property (nonatomic, retain) NSString *strSetupPage;

@property (nonatomic, retain) NSString *removedMsgIdsForEntity;

@property NSInteger orignialTimeInterval;

@property BOOL isChatNotification;
@property BOOL isExchangeNotification;
@property BOOL isSproutNotification;
@property BOOL isProfileNotification;
@property BOOL isEntityNotification;

@property BOOL isShownSpinner;

@property BOOL isStartedLocationUpdate;

@property BOOL isCreateEntityViewController;


@property BOOL isCalledContactsReload;
@property BOOL isCalledSyncContacts;

- (void)setWizardPage:(NSString *)wizardValue;

@property BOOL isProfileEdit;
@property BOOL isEditEntity;
@property BOOL isShowTutorial;//flag for tutorial on signup

@property (nonatomic, strong) NSString *videoID;
@property (nonatomic, strong) NSString *videoEntityID;


// Sprout
// type: 0-turn off, 1-turn on, 2-turn off after one hr
- (void)changeGPSSetting:(int)type;
- (void)touchThumb;

- (void)turnOffGPS;
- (void)turnOnGPS;

// flag that if we can cancel the scheduled selectorfor changing gps setting
@property (nonatomic, assign) BOOL notCallFlag;

// we call gps status api after 0.5s when touching down the thumb button and set this flag to YES, and when the user just tap the button by mistake this property won't be set to YES and we don't need to call gps status api
@property (nonatomic, assign) BOOL isGPSOn;

// if holding thumb button, YES, otherwise NO
@property (nonatomic, assign) BOOL thumbDown;

// Reflects if the gps setting is currently on or off
@property (nonatomic, assign) BOOL locationFlag;

// Core-data related
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

// Save and Load Login data
- (void)saveLoginData;
- (BOOL)loadLoginData;
- (void)deleteLoginData;

- (void)addFavoriteContact:(NSString *)contactID contactType:(NSString *)type;
- (void)removeFavoriteContact:(NSString *)contactID contactType:(NSString *)type;

- (void)GetSummaryFromPush;
- (void)performEndCallActionWithUUID:(NSUUID *)uuid;

- (void)HandlePushNotification:(NSDictionary *)userInfo;

- (void)callConnectingFullfill;


//UIActionsheet dismissing with conference view
@property (nonatomic, retain) NSTimer * timerCheckingConferenceView;
@property (nonatomic, retain) UIActionSheet *sheetToConference;
@property NSInteger countForActionSheet;
- (void)dismissActionSheetWithConference:(UIActionSheet *)_sheet;
- (void)stopTimerForDismissingActionSheet;

@end
