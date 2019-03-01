//
//  VideoVoiceConferenceViewController.m
//  ginko
//
//  Created by stepanekdavid on 2/17/17.
//  Copyright © 2017 com.xchangewithme. All rights reserved.
//

#import "VideoVoiceConferenceViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "YYYCommunication.h"
#import "ConferenceInvitationUserCell.h"
#import "UIImageView+AFNetworking.h"
#import "YYYSelectContactController.h"
#import "RemoteViewCell.h"
#import <AudioToolbox/AudioServices.h>

#import <libjingle_peerconnection/RTCPeerConnectionFactory.h>
#import <libjingle_peerconnection/RTCICEServer.h>
#import <libjingle_peerconnection/RTCPeerConnection.h>
#import <libjingle_peerconnection/RTCSessionDescription.h>
#import <libjingle_peerconnection/RTCPeerConnectionInterface.h>
#import <libjingle_peerconnection/RTCMediaStream.h>
#import <libjingle_peerconnection/RTCAudioTrack.h>
#import <libjingle_peerconnection/RTCVideoSource.h>
#import <libjingle_peerconnection/RTCVideoCapturer.h>
#import <libjingle_peerconnection/RTCVideoTrack.h>
#import <libjingle_peerconnection/RTCMediaConstraints.h>
#import <libjingle_peerconnection/RTCPair.h>
#import <libjingle_peerconnection/RTCAVFoundationVideoSource.h>

#import "CallManager.h"
#import <CallKit/CallKit.h>

#import <MobileCoreServices/MobileCoreServices.h>
#import "UIBubbleTableView.h"
#import "UIBubbleTableViewDataSource.h"
#import "NSBubbleData.h"
#import "MBProgressHUD.h"
#import "YYYCommunication.h"
#import "AppDelegate.h"
#import "NSString+Utils.h"
#import "SVGeocoder.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "SVPullToRefresh.h"
#import "Reachability.h"
#import <AddressBook/AddressBook.h>
#import "UIImageView+AFNetworking.h"
#import "PreviewProfileViewController.h"
#import "SelectUserForConferenceViewController.h"

#import "LocalDBManager.h"
#import "RCEasyTipView.h"
#import "VideoEncode.h"

#define BUTTON_FONT_SIZE 32
#define EMOJICOL			7
#define EMOJIROW			3
#define BUTTON_WIDTH 45
#define BUTTON_HEIGHT 37

@interface VideoVoiceConferenceViewController ()<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UIAlertViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CallManagerDelegate, UIActionSheetDelegate, RCEasyTipViewDelegate, RemoteViewCellDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, H264HwEncoderDelegate>
{
    BOOL isHideCamera;
    
    NSMutableArray *lst_user;
    
    NSInteger countForWaiting;
    NSTimer *waitingJoinTimer;
    
    //
    NSMutableArray * arrARDAppClients;
    
    BOOL isDisconnected;
    BOOL isConnectedWithVoice;
    
    NSMutableArray *arrMembersOfConference;
    
    RTCVideoTrack *localVideoTrack;
    RTCPeerConnection *mainPeerConnection;
    RTCPeerConnectionFactory *peerConsfactory;
    NSMutableArray *iceServers;
    
    RTCAudioTrack *defaultAudioTrack;
    RTCVideoTrack *defaultVideoTrack;
    BOOL isSpeakerEnabled;
    
    CXCallController * callkitCallController;
    CXStartCallAction *callActionforanser;
    
    BOOL isRetryCalling;
    BOOL isSetFromMenu;
    BOOL isFinishedInitialing;
    //////ios 4 ~ ios 9
    NSTimer *timerForVibrate;
    BOOL isPlaying;
    AVAudioPlayer *player;
    /////////
    
    
    
    /////////////////////////////////
    ////////chatting spec////////////
    BOOL keyboardShown;
    
    BOOL isLoadingMessages;             // loading previous messages(top)
    BOOL isLoadingNewMessages;          // loading new messages(bottom)
    
    MBProgressHUD *downloadProgressHUD; // Download progress hud for video
    
    NSBubbleContentType longPressedDataType;    // Save the type for long pressed bubble (video, photo, voice)
    NSString *longPressedDataPath;              // Save the data path for long pressed bubble
    
    BOOL isShownBoard; //when show chatboard, this is set once
    BOOL getNewmessage;
    
    NSString *tmpTextMessage;
    
    NSString *videoCallEmoji;
    NSString *voiceCallEmoji;
    
    RCEasyTipView *tipView;
    BOOL isHiddenChatTipView;
    /////////////////////////////////
    
    //h264
    AVCaptureSession *captureSession;
    AVCaptureConnection* connectionVideo;
    AVCaptureDevice *cameraDeviceB;
    AVCaptureDevice *cameraDeviceF;
    
    BOOL cameraDeviceIsF;
    
    VideoEncode *videoEncode;
    NSFileHandle *fileHandle;
    NSString *h264File;
    
    //
    RTCAVFoundationVideoSource *source;
    BOOL sessionRunning;
    dispatch_queue_t sessionQueue;
}


@end

@implementation VideoVoiceConferenceViewController

@synthesize conferenceName, conferenceType;
@synthesize boardId,boardIdNum, infoCalling;

@synthesize emojis;
@synthesize reachability, playerVC;
@synthesize removeInviteNotification;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [RemoteCollectionView registerNib:[UINib nibWithNibName:@"RemoteViewCell" bundle:nil] forCellWithReuseIdentifier:@"RemoteViewItem"];    isRetryCalling = NO;
    isSetFromMenu = NO;
    //init vars
    countForWaiting = 0;
    waitingJoinTimer = [[NSTimer alloc] init];
    timerForVibrate = [[NSTimer alloc] init];
    isDisconnected = NO;
    isConnectedWithVoice = NO;
    isSpeakerEnabled = NO;
    
    sessionQueue = dispatch_queue_create( "session queue", DISPATCH_QUEUE_SERIAL );
    
    isHideCamera = NO;
    imgVoiceMute.hidden = YES;
    imgVideoMute.hidden = YES;
    imgOnlyVoice.hidden = YES;
    
    loadingMaskView.hidden = NO;
    
    removeInviteNotification = YES;
    
    //conferenceToolView.hidden = YES;
    //maskToolView.hidden = YES;
    
    //chatting
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
    
    //h264
    cameraDeviceIsF = YES;
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in videoDevices) {
        if (device.position == AVCaptureDevicePositionFront) {
            cameraDeviceF = device;
        }
        else if(device.position == AVCaptureDevicePositionBack)
        {
            cameraDeviceB = device;
        }
    }
    videoEncode = [[VideoEncode alloc]init];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    h264File = [documentsDirectory stringByAppendingPathComponent:@"myH264.h264"];
    [fileManager removeItemAtPath:h264File error:nil];
    [fileManager createFileAtPath:h264File contents:nil attributes:nil];
    
    fileHandle = [NSFileHandle fileHandleForWritingAtPath:h264File];
    
    [videoEncode initEncode:640 height:480];
    videoEncode.delegate = self;
    
    RCEasyTipPreferences *preferences = [[RCEasyTipPreferences alloc] initWithDefaultPreferences];
    preferences.drawing.backgroundColor = COLOR_PURPLE_THEME;
    
    tipView = [[RCEasyTipView alloc] initWithPreferences:preferences];
    tipView.delegate = self;
    
    isHiddenChatTipView = YES;
    
    senderChatTextImageView.layer.cornerRadius = senderChatTextImageView.frame.size.height / 2.0f;
    senderChatTextImageView.layer.masksToBounds = YES;
    senderChatTextImageView.layer.borderWidth = 1.0f;
    senderChatTextImageView.layer.borderColor = COLOR_PURPLE_THEME.CGColor;
    
    //////****////
    
    lst_user = [[NSMutableArray alloc] init];
    arrARDAppClients = [[NSMutableArray alloc] init];
    arrMembersOfConference = [[NSMutableArray alloc] init];
    iceServers = [[NSMutableArray alloc] init];
    
    localVideoTrack = nil;
    peerConsfactory = [[RTCPeerConnectionFactory alloc] init];
    defaultAudioTrack = nil;
    defaultVideoTrack = nil;
    
    lstUsersForChatting = [[NSMutableArray alloc] init];
    
    //animation for intiataing call....
    isFinishedInitialing = YES;
    
    [speakerBtn setImage:[UIImage imageNamed:@"speak_phone_img"] forState:UIControlStateNormal];
    
    //animation for speaker
    NSArray *animationArrayForSpeaker=[NSArray arrayWithObjects:
                                       [UIImage imageNamed:@"speakerProgress01.png"],
                                       [UIImage imageNamed:@"speakerProgress02.png"],
                                       [UIImage imageNamed:@"speakerProgress03.png"],
                                       [UIImage imageNamed:@"speakerProgress04.png"],
                                       nil];
    speakerProgressImg.animationImages=animationArrayForSpeaker;
    speakerProgressImg.animationDuration=2;
    speakerProgressImg.animationRepeatCount=0;
    [speakerProgressImg startAnimating];
    speakerProgressImg.hidden = YES;
    
    //RTCEAGLVideoViewDelegate provides notifications on video frame dimensions
    [self.localView setDelegate:self];
    [self.soleLocalView setDelegate:self];
    
    localViewMask.hidden = YES;
    if (conferenceType && conferenceType == 2) {
        isHideCamera = YES;
        localViewMask.hidden = NO;
        btnCameraStatus.selected = YES;
        imgVoiceMute.hidden = YES;
        imgVideoMute.hidden = YES;
        imgOnlyVoice.hidden = NO;
    }
    
    isPlaying = NO;
    incomingCallView.hidden = YES;
    
    self.soleLocalView.hidden = YES;
    btnCameraType.enabled = YES;
    btnCameraStatus.enabled = YES;
    btnMicStatus.enabled = YES;
    btnChatText.enabled = YES;
    speakerBtn.enabled = YES;
    
    
    if (!boardId) {
        [lblTitle setText:[self getTitleTextForConference]];
        maskToolView.hidden = YES;
        self.soleLocalView.hidden = NO;
        btnCameraType.enabled = NO;
        btnCameraStatus.enabled = NO;
        btnMicStatus.enabled = NO;
        btnChatText.enabled = NO;
        btnCameraType.enabled = NO;
        speakerBtn.enabled = NO;
        
        RTCMediaStream* lStream =  [peerConsfactory mediaStreamWithLabel:@"GINKOARDAMS"];
        
        RTCVideoTrack *lTrack = [self createLocalVideoTrack];
        if (lTrack) {
            [lStream addVideoTrack:lTrack];
            if (localVideoTrack) {
                [localVideoTrack removeRenderer:self.soleLocalView];
                localVideoTrack = nil;
                [self.soleLocalView renderFrame:nil];
            }
            localVideoTrack = lTrack;
            [localVideoTrack addRenderer:self.soleLocalView];
            self.soleLocalView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        }
        
    }else{
        
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        boardIdNum = [f numberFromString:[NSString stringWithFormat:@"%@", boardId]];
        for (NSDictionary *dc in APPDELEGATE.conferenceMembersForVideoCalling) {
            if ([[dc objectForKey:@"user_id"] integerValue] != [APPDELEGATE.userId integerValue]) {
                NSMutableDictionary *oneMem = [[NSMutableDictionary alloc] init];
                [oneMem setObject:[dc objectForKey:@"user_id"] forKey:@"user_id"];
                [oneMem setObject:[dc objectForKey:@"name"] forKey:@"name"];
                [oneMem setObject:[dc objectForKey:@"photo_url"] forKey:@"photo_url"];
                [oneMem setObject:[dc objectForKey:@"videoStatus"] forKey:@"videoStatus"];
                [oneMem setObject:[dc objectForKey:@"voiceStatus"] forKey:@"voiceStatus"];
                [arrMembersOfConference addObject:oneMem];
            }
        }
        
        [self refreshConstraintOfmembers];
        
        
        if (APPDELEGATE.isOwnerForConference) {
            btCancelButton.hidden = NO;
            isFinishedInitialing = NO;
            [self createConference];
        }else{
            //btCancelButton.hidden = YES;
            [lblTitle setText:[self getTitleTextForConference]];
            if( SYSTEM_VERSION_LESS_THAN(@"10.0") ){
                incomingCallView.hidden = NO;
                lblInitialer.text = conferenceName;
                btCancelButton.hidden = YES;
                
                waitingJoinTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(repeatWaitingJoinOtherUsesr) userInfo:nil repeats:YES];
                [self billPlayingAndStop];
                
            }else{
                [self acceptCallingForUser];
            }
        }
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [UIDevice currentDevice].proximityMonitoringEnabled = YES;
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    [self.navigationController setNavigationBarHidden:YES];
    APPDELEGATE.isConferenceView = YES;
    if (boardId) {
        [lblTitle setText:[self getTitleTextForConference]];
        [RemoteCollectionView reloadData];
        [self refreshConstraintOfmembers];
        
        
        [self performSelector:@selector(checkingExistMembersOfConference) withObject:nil afterDelay:1.0f];
    }else{
        [APPDELEGATE.conferenceMembersForVideoCalling removeAllObjects];
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    
    countForWaiting = 0;
    [waitingJoinTimer invalidate];
    waitingJoinTimer = nil;
    
    if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
        [timerForVibrate invalidate];
        timerForVibrate = nil;
    }
}

- (void)refreshConstraintOfmembers{
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    switch ([arrMembersOfConference count]) {
        case 1:{
            [RemoteCollectionView setFrame:CGRectMake(0, -20, width, height/2+20)];
            [ownerView setFrame:CGRectMake(0, height/2, width, height/2)];
        }
            break;
        case 2:{
            [RemoteCollectionView setFrame:CGRectMake(0, -20, width, height/2+20)];
            [ownerView setFrame:CGRectMake(0, height/2, width, height/2)];
        }
            break;
        case 3:{
            [RemoteCollectionView setFrame:CGRectMake(0, -20, width, height+20)];
            [ownerView setFrame:CGRectMake(width/2, height/2, width/2, height/2)];
        }
            break;
        case 4:{
            [RemoteCollectionView setFrame:CGRectMake(0, -20, width, height*2/3+20)];
            [ownerView setFrame:CGRectMake(0, height*2/3, width, height/3)];
        }
            break;
        case 5:{
            [RemoteCollectionView setFrame:CGRectMake(0, -20, width, height+20)];
            [ownerView setFrame:CGRectMake(width/2, height*2/3, width/2, height/3)];
        }
            break;
        case 6:{
            [RemoteCollectionView setFrame:CGRectMake(0, -20, width, height*3/4+20)];
            [ownerView setFrame:CGRectMake(0, height*3/4, width, height/4)];
        }
            break;
        case 7:{
            [RemoteCollectionView setFrame:CGRectMake(0, -20, width, height+20)];
            [ownerView setFrame:CGRectMake(width/2, height*3/4, width/2, height/4)];
        }
            break;
            
        default:
            break;
    }
    
    [self resizeLocalVideoView:ownerView.bounds.size];
}

- (void)resizeLocalVideoView:(CGSize)size{
    
    CGFloat scale = 640.0f / 480.0f;
    switch ([arrMembersOfConference count]) {
        case 1:{
            [self.localView setFrame:CGRectMake(0.0f, 0.0f, size.width, size.width* scale)];
        }
            break;
        case 2:{
            [self.localView setFrame:CGRectMake(0.0f, 0.0f, size.width, size.width* scale)];
        }
            break;
        case 3:{
            [self.localView setFrame:CGRectMake(0.0f, 0.0f, size.width * scale, size.height)];
        }
            break;
        case 4:{
            [self.localView setFrame:CGRectMake(0.0f, 0.0f, size.width, size.height* scale)];
        }
            break;
        case 5:{
            [self.localView setFrame:CGRectMake(0.0f, 0.0f, size.width * scale, size.height)];
        }
            break;
        case 6:{
            [self.localView setFrame:CGRectMake(0.0f, 0.0f, size.width, size.width* scale)];
        }
            break;
        case 7:{
            [self.localView setFrame:CGRectMake(0.0f, 0.0f, size.width, size.height * scale)];
        }
            break;
            
        default:
            break;
    }
    
}

- (NSString *)getTitleTextForConference{
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
                confName = [NSString stringWithFormat:@"%@ + %d", [dicOfName objectForKey:@"name"], (int)[APPDELEGATE.conferenceMembersForVideoCalling count] - 1];
                break;
            }
        }
    }
    return confName;
}

- (void)billPlayingAndStop{
    if (!isPlaying) {
        NSString *path;
        NSURL *url;
        
        //where you are about to add sound
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        
        path =[[NSBundle mainBundle] pathForResource:@"ring_conference" ofType:@"mp3"];
        url = [NSURL fileURLWithPath:path];
        
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];
        [player setVolume:1.0];
        [player prepareToPlay];
        player.numberOfLoops = -1;
        [player play];
        isPlaying = YES;
        
        timerForVibrate = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(repeatingVibrate) userInfo:nil repeats:YES];
        
    }
    else {
        [player stop];
        isPlaying = NO;
    }
}
- (void)repeatingVibrate{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

//get local stream
//***********start**********
//- (void)getLocalStream{
//    localStream = [self createLocalMediaStream];
//
//}
- (RTCMediaStream *)createLocalMediaStream {
    RTCMediaStream* lStream =  [peerConsfactory mediaStreamWithLabel:@"GINKOARDAMS"];
    
    RTCVideoTrack *lTrack = [self createLocalVideoTrack];
    if (lTrack) {
        [lStream addVideoTrack:lTrack];
        if (localVideoTrack) {
            [localVideoTrack removeRenderer:self.localView];
            localVideoTrack = nil;
            [self.localView renderFrame:nil];
        }
        localVideoTrack = lTrack;
        if (!isHideCamera) {
            [localVideoTrack addRenderer:self.localView];
        }
        
        self.localView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        
    }
    //[self setAudioOutputSpeaker:[self isHeadsetPluggedIn]];
    [lStream addAudioTrack:[peerConsfactory audioTrackWithID:@"GINKOARDAMSa0"]];
    
    
    return lStream;
}
- (RTCVideoTrack *)createLocalVideoTrack {
    
    RTCVideoTrack *lTrack = nil;
    
    source.useBackCamera = NO;
    
    lTrack = [[RTCVideoTrack alloc] initWithFactory:peerConsfactory
                                             source:source
                                            trackId:@"GINKOARDAMSv0"];
    
    
    //    }
    return lTrack;
}
- (RTCMediaConstraints *)defaultMediaStreamConstraints {
    
    RTCPair *dtlsSrtpKeyAgreement = [[RTCPair alloc] initWithKey:@"DtlsSrtpKeyAgreement"
                                                           value:@"true"];
    NSArray * optionalConstraints = @[dtlsSrtpKeyAgreement];
    NSArray *mandatoryConstraints = [self getMandatoryConstraints];
    RTCMediaConstraints* constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatoryConstraints optionalConstraints:optionalConstraints];
    return constraints;
}

-(NSArray *)getMandatoryConstraints {
    
    RTCPair *localVideoMaxWidth = [[RTCPair alloc] initWithKey:@"maxWidth" value:@"640"];
    RTCPair *localVideoMinWidth = [[RTCPair alloc] initWithKey:@"minWidth" value:@"192"];
    RTCPair *localVideoMaxHeight = [[RTCPair alloc] initWithKey:@"maxHeight" value:@"480"];
    RTCPair *localVideoMinHeight = [[RTCPair alloc] initWithKey:@"minHeight" value:@"144"];
    RTCPair *localVideoMaxFrameRate = [[RTCPair alloc] initWithKey:@"maxFrameRate" value:@"30"];
    RTCPair *localVideoMinFrameRate = [[RTCPair alloc] initWithKey:@"minFrameRate" value:@"5"];
    //    RTCPair *localVideoGoogLeakyBucket = [[RTCPair alloc]
    //                                          initWithKey:@"googLeakyBucket" value:@"false"];
    
    return @[localVideoMaxHeight,
             localVideoMaxWidth,
             localVideoMinHeight,
             localVideoMinWidth,
             localVideoMinFrameRate,
             localVideoMaxFrameRate];
}

//************end**************

- (RTCMediaConstraints *)defaultPeerConnectionConstraints {
    NSArray *optionalConstraints = @[
                                     [[RTCPair alloc] initWithKey:@"DtlsSrtpKeyAgreement" value:@"true"]
                                     ];
    RTCMediaConstraints* constraints =
    [[RTCMediaConstraints alloc]
     initWithMandatoryConstraints:nil
     optionalConstraints:optionalConstraints];
    return constraints;
}
-(void) captureOutput:(AVCaptureOutput*)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection*)connection
{
    [videoEncode encode:sampleBuffer];
}

#pragma mark -  H264HwEncoderDelegate Implement
- (void)gotSpsPps:(NSData*)sps pps:(NSData*)pps
{
    NSLog(@"gotSpsPps %d %d", (int)[sps length], (int)[pps length]);
    
    const char bytes[] = "\x00\x00\x00\x01";
    size_t length = (sizeof bytes) - 1; //string literals have implicit trailing '\0'
    NSData *ByteHeader = [NSData dataWithBytes:bytes length:length];
    
    [fileHandle writeData:ByteHeader];
    [fileHandle writeData:sps];
    [fileHandle writeData:ByteHeader];
    [fileHandle writeData:pps];
    
}
- (void)gotEncodedData:(NSData*)data isKeyFrame:(BOOL)isKeyFrame
{
    NSLog(@"gotEncodedData %d", (int)[data length]);
    
    if (fileHandle != NULL)
    {
        const char bytes[] = "\x00\x00\x00\x01";
        size_t length = (sizeof bytes) - 1; //string literals have implicit trailing '\0'
        NSData *ByteHeader = [NSData dataWithBytes:bytes length:length];
        
        [fileHandle writeData:ByteHeader];
        [fileHandle writeData:data];
    }
}

#pragma CallManagerDelegate
- (void)callDidAnswer{
    NSLog(@"callDidAnswer--------------------");
}
- (void)callDidEnd{
    [self onCloseConferenceClick:nil];
}
- (void)callDidHold:(BOOL)isOnHold{
    NSLog(@"callDidHold--------------------");
}
- (void)callDidFail{
    NSLog(@"callDidFail--------------------");
}
- (void)callDidAnswerConnecting:(CXAnswerCallAction *)_action{
    NSLog(@"callDidAnswerConnecting--------------------");
}
- (void)StartCallAction:(CXStartCallAction *)_action{
    callActionforanser = _action;
    NSLog(@"StartCallAction--------------------");
}
- (void)callConnectingFullfillForOwner{
    NSLog(@"callConnectingFullfillForOwner--------------------");
    if (callActionforanser) {
        [callActionforanser fulfill];
        callActionforanser = nil;
    }
}

- (void)startCallWithPhoneNumber:(NSString*)userName {
    callkitCallController = [[CXCallController alloc] init];
    [CallManager sharedInstance].delegate = self;
    CXHandle *handle = [[CXHandle alloc] initWithType:CXHandleTypePhoneNumber value:userName];
    CXStartCallAction *startCallAction = [[CXStartCallAction alloc] initWithCallUUID:APPDELEGATE.uuidForReceiver handle:handle];
    CXTransaction *transaction = [[CXTransaction alloc] init];
    [transaction addAction:startCallAction];
    [callkitCallController requestTransaction:transaction completion:^(NSError *error) {
        if (error) {
            NSLog(@"StartCallAction transaction request failed: %@", [error localizedDescription]);
        }
        else {
            NSLog(@"StartCallAction transaction request successful");
        }
    }];
}


- (void)sessionRuntimeError:(NSNotification *)notification
{
    NSError *error = notification.userInfo[AVCaptureSessionErrorKey];
    NSLog( @"Capture session runtime error: %@", error );
    
    /*
     Automatically try to restart the session running if media services were
     reset and the last start running succeeded. Otherwise, enable the user
     to try to resume the session running.
     */
    if ( error.code == AVErrorMediaServicesWereReset ) {
        dispatch_async( sessionQueue, ^{
            if (sessionRunning ) {
                [source.captureSession startRunning];
                sessionRunning = source.captureSession.isRunning;
            }
            else {
                dispatch_async( dispatch_get_main_queue(), ^{
                    //self.resumeButton.hidden = NO;
                } );
            }
        } );
    }
    else {
        
    }
}

- (void)sessionWasInterrupted:(NSNotification *)notification
{
    AVCaptureSessionInterruptionReason reason = [notification.userInfo[AVCaptureSessionInterruptionReasonKey] integerValue];
    NSLog( @"Capture session was interrupted with reason %ld", (long)reason );
    
    if ( reason == AVCaptureSessionInterruptionReasonAudioDeviceInUseByAnotherClient ||
        reason == AVCaptureSessionInterruptionReasonVideoDeviceInUseByAnotherClient ) {
        
    }
    else if ( reason == AVCaptureSessionInterruptionReasonVideoDeviceNotAvailableWithMultipleForegroundApps ) {
        // Simply fade-in a label to inform the user that the camera is unavailable.
        
    }
}

- (void)sessionInterruptionEnded:(NSNotification *)notification
{
    NSLog( @"Capture session interruption ended" );
}


- (void)createConference{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        if ([[_responseObject objectForKey:@"success"] boolValue]) {
            APPDELEGATE.conferenceStatus = 1;
            [self startCallWithPhoneNumber:[self getTitleTextForConference]];
            
            waitingJoinTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(repeatWaitingJoinOtherUsesr) userInfo:nil repeats:YES];
            [iceServers removeAllObjects];
            for (NSDictionary *dt in [[_responseObject objectForKey:@"data"] objectForKey:@"iceServers"]) {
                NSString *url = [dt objectForKey:@"url"];
                NSString *credential = [dt objectForKey:@"credential"];
                NSString *username = [dt objectForKey:@"username"];
                credential = credential? credential:@"";
                username = username? username:@"";
                
                RTCICEServer *iceServer = [[RTCICEServer alloc] initWithURI:[NSURL URLWithString:url] username:username password:credential];
                [iceServers addObject:iceServer];
            }
            
            
            RTCMediaConstraints *constraints = [self defaultPeerConnectionConstraints];
            RTCConfiguration *configura = [[RTCConfiguration alloc] init];
            configura.iceServers = [iceServers copy];
            configura.tcpCandidatePolicy = kRTCTcpCandidatePolicyDisabled;
            configura.bundlePolicy = kRTCBundlePolicyMaxBundle;
            configura.rtcpMuxPolicy = kRTCRtcpMuxPolicyRequire;
            mainPeerConnection = [peerConsfactory peerConnectionWithConfiguration:configura constraints:constraints delegate:nil];
            
            RTCMediaConstraints *mediaConstraints = [self defaultMediaStreamConstraints];
            source = [[RTCAVFoundationVideoSource alloc] initWithFactory:peerConsfactory
                                                             constraints:mediaConstraints];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [source.captureSession stopRunning];
                NSError *deviceError;
                AVCaptureDeviceInput *inputCameraDevice = [AVCaptureDeviceInput deviceInputWithDevice:cameraDeviceF error:&deviceError];
                AVCaptureVideoDataOutput *outputVideoDevice = [[AVCaptureVideoDataOutput alloc] init];
                NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
                NSNumber* val = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange];
                NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:val forKey:key];
                outputVideoDevice.videoSettings = videoSettings;
                [outputVideoDevice setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
                
                [source.captureSession beginConfiguration];
                [source.captureSession setSessionPreset:[NSString stringWithString:AVCaptureSessionPreset640x480]];
                connectionVideo = [outputVideoDevice connectionWithMediaType:AVMediaTypeVideo];
                //#if TARGET_OS_IPHONE
                //            [self setRelativeVideoOrientation];
                //
                //            NSNotificationCenter* notify = [NSNotificationCenter defaultCenter];
                //            [notify addObserver:self
                //                       selector:@selector(statusBarOrientationDidChange:)
                //                           name:@"StatusBarOrientationDidChange"
                //                         object:nil];
                //#endif
                [source.captureSession commitConfiguration];
                
                [source.captureSession startRunning];
                
                sessionRunning = source.captureSession.isRunning;
            });
            RTCMediaStream *localStream = [self createLocalMediaStream];
            [mainPeerConnection addStream:localStream];
            
            for (NSDictionary *dict in APPDELEGATE.conferenceMembersForVideoCalling) {
                
                ARDAppClient *client = [[ARDAppClient alloc] initWithDelegate:self boardId:boardId arrIceServers:iceServers memberId:[dict objectForKey:@"user_id"]];
                client.isInitiator = YES;
                client.factory = peerConsfactory;
                [client connectToRoomWithId:localStream];
                [client sendOffer];
                
                NSMutableDictionary *onePeerCons = [[NSMutableDictionary alloc] init];
                [onePeerCons setObject:client forKey:@"peerCons"];
                [onePeerCons setObject:[dict objectForKey:@"user_id"] forKey:@"user_id"];
                [onePeerCons setObject:@"sender" forKey:@"type"];
                
                [arrARDAppClients addObject:onePeerCons];
            }
            
            if (!isHideCamera) {
                [self sendingTurnStatusOfVideo:@"on"];
            }else{
                [self sendingTurnStatusOfVideo:@"off"];
            }
            [self performSelector:@selector(sendingOwnStatus) withObject:nil afterDelay:20.0f];
        }else{
            if (isSetFromMenu) {
                [APPDELEGATE.conferenceMembersForVideoCalling removeAllObjects];
                
                maskToolView.hidden = YES;
                self.soleLocalView.hidden = NO;
                btnCameraType.enabled = NO;
                btnCameraStatus.enabled = NO;
                btnMicStatus.enabled = NO;
                btnChatText.enabled = NO;
                isFinishedInitialing = YES;
                speakerBtn.enabled = NO;
                
                RTCMediaStream* lStream =  [peerConsfactory mediaStreamWithLabel:@"GINKOARDAMS"];
                
                RTCVideoTrack *lTrack = [self createLocalVideoTrack];
                if (lTrack) {
                    [lStream addVideoTrack:lTrack];
                    if (localVideoTrack) {
                        [localVideoTrack removeRenderer:self.soleLocalView];
                        localVideoTrack = nil;
                        [self.soleLocalView renderFrame:nil];
                    }
                    localVideoTrack = lTrack;
                    [localVideoTrack addRenderer:self.soleLocalView];
                    self.soleLocalView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
                }
            }else{
                [CommonMethods showAlertUsingTitle:@"" andMessage:@"Contact is Busy"];
                [self onCloseConferenceClick:nil];
            }
            
        }
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        loadingMaskView.hidden = YES;
        
    };
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        loadingMaskView.hidden = YES;
        [CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Internet Connection Error!"];
        [self onCloseConferenceClick:nil];
    };
    
    [[YYYCommunication sharedManager] OpenVideoConference:APPDELEGATE.sessionId boardId:boardId type:conferenceType successed:successed failure:failure];
    
}

- (void)joinConference{
    if (APPDELEGATE.conferenceStatus == 1) {
        APPDELEGATE.conferenceStatus = 2;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        waitingJoinTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(repeatWaitingJoinOtherUsesr) userInfo:nil repeats:YES];
        [iceServers removeAllObjects];
        for (NSDictionary *dt in [[_responseObject objectForKey:@"data"] objectForKey:@"iceServers"]) {
            NSString *url = [dt objectForKey:@"url"];
            NSString *credential = [dt objectForKey:@"credential"];
            NSString *username = [dt objectForKey:@"username"];
            credential = credential? credential:@"";
            username = username? username:@"";
            
            RTCICEServer *iceServer = [[RTCICEServer alloc] initWithURI:[NSURL URLWithString:url] username:username password:credential];
            [iceServers addObject:iceServer];
        }
        RTCMediaConstraints *constraints = [self defaultPeerConnectionConstraints];
        RTCConfiguration *configura = [[RTCConfiguration alloc] init];
        configura.iceServers = [iceServers copy];
        configura.tcpCandidatePolicy = kRTCTcpCandidatePolicyDisabled;
        configura.bundlePolicy = kRTCBundlePolicyMaxBundle;
        configura.rtcpMuxPolicy = kRTCRtcpMuxPolicyRequire;
        mainPeerConnection = [peerConsfactory peerConnectionWithConfiguration:configura constraints:constraints delegate:nil];
        RTCMediaConstraints *mediaConstraints = [self defaultMediaStreamConstraints];
        source = [[RTCAVFoundationVideoSource alloc] initWithFactory:peerConsfactory
                                                         constraints:mediaConstraints];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [source.captureSession stopRunning];
            NSError *deviceError;
            AVCaptureDeviceInput *inputCameraDevice = [AVCaptureDeviceInput deviceInputWithDevice:cameraDeviceF error:&deviceError];
            AVCaptureVideoDataOutput *outputVideoDevice = [[AVCaptureVideoDataOutput alloc] init];
            NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
            NSNumber* val = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange];
            NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:val forKey:key];
            outputVideoDevice.videoSettings = videoSettings;
            [outputVideoDevice setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
            
            [source.captureSession beginConfiguration];
            [source.captureSession setSessionPreset:[NSString stringWithString:AVCaptureSessionPreset640x480]];
            connectionVideo = [outputVideoDevice connectionWithMediaType:AVMediaTypeVideo];
            //#if TARGET_OS_IPHONE
            //            [self setRelativeVideoOrientation];
            //
            //            NSNotificationCenter* notify = [NSNotificationCenter defaultCenter];
            //            [notify addObserver:self
            //                       selector:@selector(statusBarOrientationDidChange:)
            //                           name:@"StatusBarOrientationDidChange"
            //                         object:nil];
            //#endif
            [source.captureSession commitConfiguration];
            
            [source.captureSession startRunning];
            
            sessionRunning = source.captureSession.isRunning;
        });
        RTCMediaStream *localStream = [self createLocalMediaStream];
        [mainPeerConnection addStream:localStream];
        //        if (conferenceType && conferenceType == 2) {
        //            RTCVideoTrack *trackV = localStream.videoTracks[0];
        //            defaultVideoTrack = localStream.videoTracks[0];
        //            [localStream removeVideoTrack:trackV];
        //        }
        
        
        isHideCamera = YES;
        localViewMask.hidden = NO;
        btnCameraStatus.selected = YES;
        imgVoiceMute.hidden = YES;
        imgVideoMute.hidden = YES;
        imgOnlyVoice.hidden = NO;
        
        for (int i = 0 ; i < [APPDELEGATE.conferenceMembersForVideoCalling count]; i ++) {
            
            NSMutableDictionary *dict = [[APPDELEGATE.conferenceMembersForVideoCalling objectAtIndex:i] mutableCopy];
            
            
            if ([[dict objectForKey:@"user_id"] integerValue] > [APPDELEGATE.userId integerValue] && ![[dict objectForKey:@"isOwner"] boolValue] && [[dict objectForKey:@"isInvited"] boolValue]) {
                
                ARDAppClient *client = [[ARDAppClient alloc] initWithDelegate:self boardId:boardId arrIceServers:iceServers memberId:[dict objectForKey:@"user_id"]];
                
                client.isInitiator = YES;
                client.factory = peerConsfactory;
                [client connectToRoomWithId:localStream];
                [client sendOffer];
                
                NSMutableDictionary *onePeerCons = [[NSMutableDictionary alloc] init];
                [onePeerCons setObject:client forKey:@"peerCons"];
                [onePeerCons setObject:[dict objectForKey:@"user_id"] forKey:@"user_id"];
                [onePeerCons setObject:@"sender" forKey:@"type"];
                
                [arrARDAppClients addObject:onePeerCons];
            }
            else{
                if ([[dict objectForKey:@"user_id"] integerValue] != [APPDELEGATE.userId integerValue]) {
                    ARDAppClient *client = [[ARDAppClient alloc] initWithDelegate:self boardId:boardId arrIceServers:iceServers memberId:[dict objectForKey:@"user_id"]];
                    
                    client.factory = peerConsfactory;
                    client.isInitiator = NO;
                    [client connectToRoomWithId:localStream];
                    
                    //if ([APPDELEGATE.userIdsForSenddingSDP containsObject:[dict objectForKey:@"user_id"]]) {
                    [client getRemoteSDP:[dict objectForKey:@"user_id"]];
                    //  [APPDELEGATE.userIdsForSenddingSDP removeObject:[dict objectForKey:@"user_id"]];
                    //}
                    //if ([APPDELEGATE.userIdsForSendingCandidate containsObject:[dict objectForKey:@"user_id"]]) {
                    [client getRemoteCandidate:[dict objectForKey:@"user_id"]];
                    //    [APPDELEGATE.userIdsForSendingCandidate removeObject:[dict objectForKey:@"user_id"]];
                    //}
                    NSMutableDictionary *onePeerCons = [[NSMutableDictionary alloc] init];
                    [onePeerCons setObject:client forKey:@"peerCons"];
                    [onePeerCons setObject:[dict objectForKey:@"user_id"] forKey:@"user_id"];
                    [onePeerCons setObject:@"answer" forKey:@"type"];
                    
                    [arrARDAppClients addObject:onePeerCons];
                }
            }
            [dict setObject:@(0) forKey:@"isInvited"];
            [APPDELEGATE.conferenceMembersForVideoCalling replaceObjectAtIndex:i withObject:dict];
        }
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        loadingMaskView.hidden = YES;
        if (!isHideCamera) {
            [self sendingTurnStatusOfVideo:@"on"];
        }else{
            [self sendingTurnStatusOfVideo:@"off"];
        }
    };
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        loadingMaskView.hidden = YES;
        [CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Internet Connection Error!"];
    };
    
    [[YYYCommunication sharedManager] AcceptVideoConference:APPDELEGATE.sessionId boardId:boardId successed:successed failure:failure];
}

- (void)disconnect {
    if (localVideoTrack){
        [localVideoTrack removeRenderer:self.localView];
    }
    for (NSDictionary *dic in arrARDAppClients) {
        ARDAppClient *oneClient = (ARDAppClient *)[dic objectForKey:@"peerCons"];
        [oneClient disconnect];
    }
    [arrARDAppClients removeAllObjects];
    if (mainPeerConnection) {
        mainPeerConnection = nil;
    }
    localVideoTrack = nil;
    defaultAudioTrack = nil;
    defaultVideoTrack = nil;
    [self.localView renderFrame:nil];
    [APPDELEGATE.conferenceMembersForVideoCalling removeAllObjects];
    isSetFromMenu = NO;
    
    [waitingJoinTimer invalidate];
    waitingJoinTimer = nil;
}

//warting for join other users
- (void) repeatWaitingJoinOtherUsesr{
    if (APPDELEGATE.isOwnerForConference) {
        if (maskToolView.hidden == NO) {
            countForWaiting ++;
            if (countForWaiting == 30) {
                countForWaiting = 0;
                [waitingJoinTimer invalidate];
                waitingJoinTimer = nil;
                
                //[self closeConferenceByOwner];
                
            }
        }else{
            countForWaiting = 0;
            [waitingJoinTimer invalidate];
            waitingJoinTimer = nil;
        }
    }
    //    else {
    if ([APPDELEGATE.conferenceMembersForVideoCalling count] > 0) {
        
        NSMutableArray *tmpConferenceMemberForVideoCalling = [[NSMutableArray alloc] init];
        
        for (NSDictionary *changeUser in APPDELEGATE.conferenceMembersForVideoCalling) {
            
            if ([[changeUser objectForKey:@"conferenceStatus"] integerValue] != 9) {
                
                [tmpConferenceMemberForVideoCalling addObject:[changeUser mutableCopy]];
                
            }else {
                if ([[changeUser objectForKey:@"isInvitedByMe"] boolValue]) {
                    [tmpConferenceMemberForVideoCalling addObject:[changeUser mutableCopy]];
                }else{
                    for (int j = 0; j < [arrMembersOfConference count]; j ++) {
                        NSDictionary *dict = [arrMembersOfConference objectAtIndex:j];
                        if ([[changeUser objectForKey:@"user_id"] integerValue] == [[dict objectForKey:@"user_id"] integerValue]) {
                            [arrMembersOfConference removeObjectAtIndex:j];
                            [arrARDAppClients removeObjectAtIndex:j];
                            
                        }
                    }
                }
                
            }
        }
        BOOL reLoadFlg = NO;
        if ([APPDELEGATE.conferenceMembersForVideoCalling count] != [tmpConferenceMemberForVideoCalling count]) {
            reLoadFlg = YES;
        }
        [APPDELEGATE.conferenceMembersForVideoCalling removeAllObjects];
        APPDELEGATE.conferenceMembersForVideoCalling = tmpConferenceMemberForVideoCalling;
        
        
        if ([arrMembersOfConference count] > 0) {
            [lblTitle setText:[self getTitleTextForConference]];
            if (reLoadFlg) {
                [RemoteCollectionView reloadData];
                [self refreshConstraintOfmembers];
            }
            
        }
        [self performSelector:@selector(checkingUserExistStatusForAnwer) withObject:nil afterDelay:0.5f];
    }
    //    }
}

- (void)checkingUserExistStatusForAnwer{
    
    int initialingCount = 0;
    for (int i = 0 ; i < [APPDELEGATE.conferenceMembersForVideoCalling count]; i ++) {
        NSMutableDictionary *changeUser = [[APPDELEGATE.conferenceMembersForVideoCalling objectAtIndex:i] mutableCopy];
        if ([[changeUser objectForKey:@"conferenceStatus"] integerValue] <= 4 || [[changeUser objectForKey:@"conferenceStatus"] integerValue] == 8 || [[changeUser objectForKey:@"conferenceStatus"] integerValue] == 9) {
            initialingCount ++;
        }
    }
    if (initialingCount == 0) {//exist oneself on conference
        if (APPDELEGATE.conferenceStatus != 0) {
            APPDELEGATE.endTypeForConference = 1;
            APPDELEGATE.conferenceStatus = 0;
            [self onExitConference];
        }
        [APPDELEGATE.conferenceMembersForVideoCalling removeAllObjects];
    }
    
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([alertView tag] == 1001)
    {
        isRetryCalling = NO;
        if (buttonIndex ==1) {
            [self createConference];
        }else{
            [arrMembersOfConference removeAllObjects];
            [self disconnect];
            APPDELEGATE.isConferenceView = NO;
            APPDELEGATE.isReceiverForConferenceSDP = NO;
            APPDELEGATE.isReceiverForConferenceCandidate = NO;
            APPDELEGATE.isJoinedOnConference = NO;
            
            if (APPDELEGATE.isOwnerForConference) {
                CXEndCallAction *endCallAction = [[CXEndCallAction alloc] initWithCallUUID:APPDELEGATE.uuidForReceiver];
                CXTransaction *transaction = [[CXTransaction alloc] initWithAction:endCallAction];
                
                [callkitCallController requestTransaction:transaction completion:^(NSError *error) {
                    if (error) {
                        NSLog(@"EndCallAction transaction request failed: %@", [error localizedDescription]);
                    }
                    else {
                        NSLog(@"EndCallAction transaction request successful");
                    }
                }];
            }else{
                [APPDELEGATE performEndCallActionWithUUID:APPDELEGATE.uuidForReceiver];
            }
            
            APPDELEGATE.isOwnerForConference = NO;
            
            if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
                incomingCallView.hidden = YES;
                isPlaying = YES;
                [self billPlayingAndStop];
                
            }
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else if ([alertView tag] == 1003){
        if (buttonIndex ==1) {
            [arrMembersOfConference removeAllObjects];
            [self disconnect];
            [self reOpenConference];
        }else{
            [arrMembersOfConference removeAllObjects];
            [self disconnect];
            APPDELEGATE.isConferenceView = NO;
            APPDELEGATE.isReceiverForConferenceSDP = NO;
            APPDELEGATE.isReceiverForConferenceCandidate = NO;
            APPDELEGATE.isJoinedOnConference = NO;
            
            if (APPDELEGATE.isOwnerForConference) {
                CXEndCallAction *endCallAction = [[CXEndCallAction alloc] initWithCallUUID:APPDELEGATE.uuidForReceiver];
                CXTransaction *transaction = [[CXTransaction alloc] initWithAction:endCallAction];
                
                [callkitCallController requestTransaction:transaction completion:^(NSError *error) {
                    if (error) {
                        NSLog(@"EndCallAction transaction request failed: %@", [error localizedDescription]);
                    }
                    else {
                        NSLog(@"EndCallAction transaction request successful");
                    }
                }];
            }else{
                [APPDELEGATE performEndCallActionWithUUID:APPDELEGATE.uuidForReceiver];
            }
            
            APPDELEGATE.isOwnerForConference = NO;
            
            if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
                incomingCallView.hidden = YES;
                isPlaying = YES;
                [self billPlayingAndStop];
                
            }
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)reOpenConference{
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        [self startCallWithPhoneNumber:lblTitle.text];
        waitingJoinTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(repeatWaitingJoinOtherUsesr) userInfo:nil repeats:YES];
        [iceServers removeAllObjects];
        for (NSDictionary *dt in [[_responseObject objectForKey:@"data"] objectForKey:@"iceServers"]) {
            NSString *url = [dt objectForKey:@"url"];
            NSString *credential = [dt objectForKey:@"credential"];
            NSString *username = [dt objectForKey:@"username"];
            credential = credential? credential:@"";
            username = username? username:@"";
            
            RTCICEServer *iceServer = [[RTCICEServer alloc] initWithURI:[NSURL URLWithString:url] username:username password:credential];
            [iceServers addObject:iceServer];
        }
        
        
        RTCMediaConstraints *constraints = [self defaultPeerConnectionConstraints];
        RTCConfiguration *configura = [[RTCConfiguration alloc] init];
        configura.iceServers = [iceServers copy];
        configura.tcpCandidatePolicy = kRTCTcpCandidatePolicyDisabled;
        configura.bundlePolicy = kRTCBundlePolicyMaxBundle;
        configura.rtcpMuxPolicy = kRTCRtcpMuxPolicyRequire;
        mainPeerConnection = [peerConsfactory peerConnectionWithConfiguration:configura constraints:constraints delegate:nil];
        RTCMediaConstraints *mediaConstraints = [self defaultMediaStreamConstraints];
        source = [[RTCAVFoundationVideoSource alloc] initWithFactory:peerConsfactory
                                                         constraints:mediaConstraints];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [source.captureSession stopRunning];
            NSError *deviceError;
            AVCaptureDeviceInput *inputCameraDevice = [AVCaptureDeviceInput deviceInputWithDevice:cameraDeviceF error:&deviceError];
            AVCaptureVideoDataOutput *outputVideoDevice = [[AVCaptureVideoDataOutput alloc] init];
            NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
            NSNumber* val = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange];
            NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:val forKey:key];
            outputVideoDevice.videoSettings = videoSettings;
            [outputVideoDevice setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
            
            [source.captureSession beginConfiguration];
            [source.captureSession setSessionPreset:[NSString stringWithString:AVCaptureSessionPreset640x480]];
            connectionVideo = [outputVideoDevice connectionWithMediaType:AVMediaTypeVideo];
            //#if TARGET_OS_IPHONE
            //            [self setRelativeVideoOrientation];
            //
            //            NSNotificationCenter* notify = [NSNotificationCenter defaultCenter];
            //            [notify addObserver:self
            //                       selector:@selector(statusBarOrientationDidChange:)
            //                           name:@"StatusBarOrientationDidChange"
            //                         object:nil];
            //#endif
            [source.captureSession commitConfiguration];
            
            [source.captureSession startRunning];
            
            sessionRunning = source.captureSession.isRunning;
        });
        RTCMediaStream *localStream = [self createLocalMediaStream];
        [mainPeerConnection addStream:localStream];
        
        if ([arrARDAppClients count]>0) {
            for (NSDictionary *dic in arrARDAppClients) {
                ARDAppClient *client = [dic objectForKey:@"peerCons"];
                if ([[dic objectForKey:@"type"] isEqualToString:@"sender"]) {
                    client.isInitiator = YES;
                    [client sendOffer];
                }else{
                    client.isInitiator = NO;
                    //if ([APPDELEGATE.userIdsForSenddingSDP containsObject:[dic objectForKey:@"user_id"]]) {
                    [client getRemoteSDP:[dic objectForKey:@"user_id"]];
                    //   [APPDELEGATE.userIdsForSenddingSDP removeObject:[dic objectForKey:@"user_id"]];
                    //}
                    //if ([APPDELEGATE.userIdsForSendingCandidate containsObject:[dic objectForKey:@"user_id"]]) {
                    [client getRemoteCandidate:[dic objectForKey:@"user_id"]];
                    //    [APPDELEGATE.userIdsForSendingCandidate removeObject:[dic objectForKey:@"user_id"]];
                    //}
                }
            }
        }
    };
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
        //[CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Internet Connection Error!"];
    };
    
    [[YYYCommunication sharedManager] OpenVideoConference:APPDELEGATE.sessionId boardId:boardId type:conferenceType successed:successed failure:failure];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSDPOfOtherUser:) name:NOTIFICATION_GET_SDP_VIDEO_CONFERENCE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getCandidatesOfOtherUser:) name:NOTIFICATION_GET_CANDIDATES_VIDEO_CONFERENCE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendingOwnStatus) name:NOTIFICATION_GINKO_VIDEO_CONFERENCE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hangupConference:) name:NOTIFICATION_HANGUP_VIDEO_CONFERENCE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(senddingOfferToInvitionMembers) name:NOTIFICATION_INVITE_MEMBERS_CONFERENCE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMembersWithStatus) name:NOTIFICATION_MEMEBER_STATUS_CONFERENCE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showChatTextFromPushNotification:) name:NOTIFICATION_MESSAGE_CONFERENCE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSessionRouteChange:) name:AVAudioSessionRouteChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showChatTextFromPushNotificationAndTap) name:NOTIFICATION_MESSAGEBOX_OPEN_CONFERENCE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionRuntimeError:) name:AVCaptureSessionRuntimeErrorNotification object:source.captureSession];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionWasInterrupted:) name:AVCaptureSessionWasInterruptedNotification object:source.captureSession];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionInterruptionEnded:) name:AVCaptureSessionInterruptionEndedNotification object:source.captureSession];
    
    
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [UIDevice currentDevice].proximityMonitoringEnabled = NO;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_GET_SDP_VIDEO_CONFERENCE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_GET_CANDIDATES_VIDEO_CONFERENCE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_GINKO_VIDEO_CONFERENCE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_HANGUP_VIDEO_CONFERENCE object:nil];
    if(removeInviteNotification)
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_INVITE_MEMBERS_CONFERENCE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_MEMEBER_STATUS_CONFERENCE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_MESSAGE_CONFERENCE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_MESSAGEBOX_OPEN_CONFERENCE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionRuntimeErrorNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionWasInterruptedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionInterruptionEndedNotification object:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didSessionRouteChange:(NSNotification *)notification{
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonCategoryChange:
            
            break;
            
        default:
            break;
    }
    
}
- (void)sendingOwnStatus{
    if (!isHideCamera && !btnCameraStatus.selected) {
        [self sendingTurnStatusOfVideo:@"on"];
    }else{
        [self sendingTurnStatusOfVideo:@"off"];
    }
}

- (void)getSDPOfOtherUser:(NSNotification *) notification{
    for (int i = 0; i < [APPDELEGATE.userIdsForSenddingSDP count]; i ++) {
        NSString *uId = [APPDELEGATE.userIdsForSenddingSDP objectAtIndex:i];
        for (NSDictionary *dict in arrARDAppClients) {
            if ([uId integerValue] == [[dict objectForKey:@"user_id"] integerValue]) {
                [(ARDAppClient *)[dict objectForKey:@"peerCons"] getRemoteSDP:uId];
            }
        }
    }
}

- (void)getCandidatesOfOtherUser:(NSNotification *) notification{
    for (int i = 0; i < [APPDELEGATE.userIdsForSendingCandidate count]; i ++) {
        NSString *uId = [APPDELEGATE.userIdsForSendingCandidate objectAtIndex:i];
        for (NSDictionary *dict in arrARDAppClients) {
            if ([uId integerValue] == [[dict objectForKey:@"user_id"] integerValue]) {
                [(ARDAppClient *)[dict objectForKey:@"peerCons"] getRemoteCandidate:uId];
            }
        }
    }
}

#pragma mark - ARDAppClientDelegate

- (void)appClient:(ARDAppClient *)client didChangeState:(ARDAppClientState)state memberId:(NSString *)_memberId{
    switch (state) {
        case kARDAppClientStateConnected:
            NSLog(@"Client connected.");
            break;
        case kARDAppClientStateConnecting:
            NSLog(@"Client connecting.");
            break;
        case kARDAppClientStateDisconnected:
            NSLog(@"%@ Client disconnected.", _memberId);
            //            if(client.internetConTimer != nil)
            //                [client.internetConTimer invalidate];
            //            [self disconnect];
            break;
    }
}

- (void)appClient:(ARDAppClient *)client didReceiveRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack memberId:(NSString *)_memberId{
    if (!isConnectedWithVoice) {
        if (isFinishedInitialing == NO) {
            [self showingConferenceToolView];
            if (APPDELEGATE.isOwnerForConference) {
                [self callConnectingFullfillForOwner];
            }else{
                [APPDELEGATE callConnectingFullfill];
            }
        }
    }
    for (int i = 0 ; i < [arrMembersOfConference count]; i ++) {
        NSMutableDictionary *oneMemberInfo = [arrMembersOfConference objectAtIndex:i];
        if ([oneMemberInfo objectForKey:@"remoteVideoTrack"]) {
            RTCVideoTrack *videoTrack = [oneMemberInfo objectForKey:@"remoteVideoTrack"];
            [oneMemberInfo setObject:videoTrack forKey:@"remoteVideoTrack"];
            
            [arrMembersOfConference replaceObjectAtIndex:i withObject:oneMemberInfo];
            videoTrack = nil;
        }
    }
    
    for (int i = 0 ; i < [arrMembersOfConference count]; i ++) {
        NSMutableDictionary *oneMemberInfo = [arrMembersOfConference objectAtIndex:i];
        if ([[oneMemberInfo objectForKey:@"user_id"] integerValue] == [_memberId integerValue]) {
            if ([oneMemberInfo objectForKey:@"remoteVideoTrack"]) {
                RTCVideoTrack *videoTrack = [oneMemberInfo objectForKey:@"remoteVideoTrack"];
                videoTrack = nil;
                //                [oneMemberInfo removeObjectForKey:@"remoteVideoTrack"];
            }
            [oneMemberInfo setObject:remoteVideoTrack forKey:@"remoteVideoTrack"];
            
            [arrMembersOfConference replaceObjectAtIndex:i withObject:oneMemberInfo];
            break;
        }
    }
    for (int i = 0 ; i < [APPDELEGATE.conferenceMembersForVideoCalling count]; i ++) {
        NSMutableDictionary *changeUser = [[APPDELEGATE.conferenceMembersForVideoCalling objectAtIndex:i] mutableCopy];
        if ([[changeUser objectForKey:@"user_id"] integerValue] == [_memberId integerValue]) {
            [changeUser setObject:@(3) forKey:@"conferenceStatus"];
            [APPDELEGATE.conferenceMembersForVideoCalling replaceObjectAtIndex:i withObject:changeUser];
        }
    }
    [lblTitle setText:[self getTitleTextForConference]];
    
    [RemoteCollectionView reloadData];
    [self refreshConstraintOfmembers];
    
    
    [self performSelector:@selector(checkingExistMembersOfConference) withObject:nil afterDelay:1.0f];
}
- (void)appClient:(ARDAppClient *)client didConnectedOnConference:(NSString *)_memberId{
    if (!isConnectedWithVoice) {
        isConnectedWithVoice = YES;
        
        if (isFinishedInitialing == NO) {
            isFinishedInitialing = YES;
        }
        if (conferenceType && conferenceType == 2) {
            if (btnCameraStatus.selected) {
                //[self hideCamera];
                [self muteVideoIn];
                if (localVideoTrack) {
                    [localVideoTrack removeRenderer:self.localView];
                    localVideoTrack = nil;
                    [self.localView renderFrame:nil];
                }
            }
        }
    }
    [self reloadSpeakerMode];
}

- (void)appClient:(ARDAppClient *)client disconnectInternet:(NSString *)_memberId
{
    NSString *memName = @"";
    for(NSDictionary * peer in arrMembersOfConference)
    {
        if([peer objectForKey:@"user_id"] == _memberId)
        {
            memName = [peer objectForKey:@"name"];
        }
    }
    if (![memName isEqualToString:@""])
        [CommonMethods showAlertUsingTitle:memName andMessage:@"Internet Connection Error!"];
}
- (void)appClient:(ARDAppClient *)client didError:(NSError *)error memberId:(NSString *)_memberId{
    for (int i = 0 ; i < [APPDELEGATE.conferenceMembersForVideoCalling count]; i ++) {
        NSMutableDictionary *changeUser = [[APPDELEGATE.conferenceMembersForVideoCalling objectAtIndex:i] mutableCopy];
        if ([[changeUser objectForKey:@"user_id"] integerValue] == [client.conferenceId integerValue]) {
            [changeUser setObject:@(13) forKey:@"conferenceStatus"];
            [APPDELEGATE.conferenceMembersForVideoCalling replaceObjectAtIndex:i withObject:changeUser];
        }
    }
    [lblTitle setText:[self getTitleTextForConference]];
    [RemoteCollectionView reloadData];
    [self refreshConstraintOfmembers];
    
    
    [self performSelector:@selector(checkingExistMembersOfConference) withObject:nil afterDelay:1.0f];
}

#pragma mark - RTCEAGLVideoViewDelegate

- (void)videoView:(RTCEAGLVideoView *)videoView didChangeVideoSize:(CGSize)size {
    //    if (videoView !=self.soleLocalView) {
    //        CGFloat scale = size.width / size.height;
    //        CGFloat widthWillChange = videoView.bounds.size.width;
    //        CGFloat heightWillChange = videoView.bounds.size.height;
    //        CGSize defaultAspectRatio = CGSizeMake(4, 3);
    //        CGSize aspectRatio = CGSizeEqualToSize(size, CGSizeZero) ? defaultAspectRatio : size;
    //        CGRect videoRect;
    //
    //        if (widthWillChange > heightWillChange) {
    //            videoRect = CGRectMake(0.0f, 0.0f, widthWillChange, widthWillChange / scale);
    //            if (heightWillChange > widthWillChange / scale) {
    //                CGFloat reScale = heightWillChange * scale /widthWillChange;
    //                videoRect = CGRectMake(0.0f, 0.0f, widthWillChange * reScale, heightWillChange);
    //            }
    //        }else{
    //            videoRect = CGRectMake(0.0f, 0.0f, heightWillChange * scale, heightWillChange);
    //            if (widthWillChange > heightWillChange * scale) {
    //                CGFloat reScale = widthWillChange/(widthWillChange * scale);
    //                videoRect = CGRectMake(0.0f, 0.0f, widthWillChange, heightWillChange * reScale);
    //            }
    //        }
    //
    //        CGRect videoFrame = AVMakeRectWithAspectRatioInsideRect(aspectRatio, videoRect);
    //        [videoView setFrame:videoFrame];
    //    }
    
    
}

- (void)closeConferenceByOwner{
    APPDELEGATE.endTypeForConference = 2;
    
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        if ([[_responseObject objectForKey:@"success"] boolValue]) {
            //waiting for owner's response
            isRetryCalling = YES;
            if (APPDELEGATE.isOwnerForConference) {
                CXEndCallAction *endCallAction = [[CXEndCallAction alloc] initWithCallUUID:APPDELEGATE.uuidForReceiver];
                CXTransaction *transaction = [[CXTransaction alloc] initWithAction:endCallAction];
                
                [callkitCallController requestTransaction:transaction completion:^(NSError *error) {
                    if (error) {
                        NSLog(@"EndCallAction transaction request failed: %@", [error localizedDescription]);
                    }
                    else {
                        NSLog(@"EndCallAction transaction request successful");
                    }
                }];
            }
            
            if (localVideoTrack){
                [localVideoTrack removeRenderer:self.localView];
            }
            for (NSDictionary *dic in arrARDAppClients) {
                ARDAppClient *oneClient = (ARDAppClient *)[dic objectForKey:@"peerCons"];
                [oneClient disconnect];
            }
            [arrARDAppClients removeAllObjects];
            if (mainPeerConnection) {
                mainPeerConnection = nil;
            }
            localVideoTrack = nil;
            defaultAudioTrack = nil;
            defaultVideoTrack = nil;
            [self.localView renderFrame:nil];
            
            UIAlertView *alertViewforError = [[UIAlertView alloc] initWithTitle:@"" message:@"Sorry, No answer." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"Try again",nil];
            alertViewforError.tag = 1001;
            [alertViewforError show];
            
        }else{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    };
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Internet Connection Error!"];
    };
    //[[YYYCommunication sharedManager] CancelVideoConference:APPDELEGATE.sessionId boardId:[infoCalling objectForKey:@"board_id"] successed:successed failure:failure];
    NSString * boardIdForConference = @"";
    if (boardId) {
        boardIdForConference = boardId;
    }else if (APPDELEGATE.userInfoByPushForConference){
        boardIdForConference = [APPDELEGATE.userInfoByPushForConference objectForKey:@"board_id"];
    }else if (infoCalling){
        boardIdForConference = [infoCalling objectForKey:@"board_id"];
    }
    
    APPDELEGATE.conferenceStatus = 0;
    APPDELEGATE.endTypeForConference = 10;
    [[YYYCommunication sharedManager] HangupVideoConference:APPDELEGATE.sessionId boardId:boardIdForConference endType:1 successed:successed failure:failure];
    
}

- (void)popupFromCurrentConferenceBack{
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onExitConference{
    if (boardId) {
        
        if (isRetryCalling) {
            return;
        }
        isDisconnected = YES;
        [RemoteCollectionView reloadData];
        [self refreshConstraintOfmembers];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        void ( ^successed )( id _responseObject ) = ^( id _responseObject )
        {
            if ([[_responseObject objectForKey:@"success"] boolValue]) {
                [arrMembersOfConference removeAllObjects];
                [self disconnect];
                APPDELEGATE.isConferenceView = NO;
                [self.navigationController popViewControllerAnimated:YES];
                APPDELEGATE.isReceiverForConferenceSDP = NO;
                APPDELEGATE.isReceiverForConferenceCandidate = NO;
                APPDELEGATE.isJoinedOnConference = NO;
                
                if (APPDELEGATE.isOwnerForConference) {
                    CXEndCallAction *endCallAction = [[CXEndCallAction alloc] initWithCallUUID:APPDELEGATE.uuidForReceiver];
                    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:endCallAction];
                    
                    [callkitCallController requestTransaction:transaction completion:^(NSError *error) {
                        if (error) {
                            NSLog(@"EndCallAction transaction request failed: %@", [error localizedDescription]);
                        }
                        else {
                            NSLog(@"EndCallAction transaction request successful");
                        }
                    }];
                }else{
                    [APPDELEGATE performEndCallActionWithUUID:APPDELEGATE.uuidForReceiver];
                }
                
                APPDELEGATE.isOwnerForConference = NO;
                
                if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
                    incomingCallView.hidden = YES;
                    isPlaying = YES;
                    [self billPlayingAndStop];
                    
                }
                
                [self performSelector:@selector(popupFromCurrentConferenceBack) withObject:nil afterDelay:0.5f];
            }else{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
        };
        
        void ( ^failure )( NSError* _error ) = ^( NSError* _error )
        {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Internet Connection Error!"];
        };
        //[[YYYCommunication sharedManager] CancelVideoConference:APPDELEGATE.sessionId boardId:[infoCalling objectForKey:@"board_id"] successed:successed failure:failure];
        NSString * boardIdForConference = @"";
        if (boardId) {
            boardIdForConference = boardId;
        }else if (APPDELEGATE.userInfoByPushForConference){
            boardIdForConference = [APPDELEGATE.userInfoByPushForConference objectForKey:@"board_id"];
        }else if (infoCalling){
            boardIdForConference = [infoCalling objectForKey:@"board_id"];
        }
        NSInteger type = APPDELEGATE.endTypeForConference;
        APPDELEGATE.endTypeForConference = 0;
        [[YYYCommunication sharedManager] HangupVideoConference:APPDELEGATE.sessionId boardId:boardIdForConference endType:type successed:successed failure:failure];
    }else{
        if (localVideoTrack){
            [localVideoTrack removeRenderer:self.soleLocalView];
        }
        [arrARDAppClients removeAllObjects];
        if (mainPeerConnection) {
            mainPeerConnection = nil;
        }
        localVideoTrack = nil;
        defaultAudioTrack = nil;
        defaultVideoTrack = nil;
        [self.soleLocalView renderFrame:nil];
        
        [APPDELEGATE.conferenceMembersForVideoCalling removeAllObjects];
        APPDELEGATE.isConferenceView = NO;
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)onCancelCalling:(id)sender {
    if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
        [timerForVibrate invalidate];
        timerForVibrate = nil;
    }
    APPDELEGATE.endTypeForConference = 3;
    APPDELEGATE.conferenceStatus = 0;
    [self onExitConference];
    
}

-(IBAction)onBackClick:(id)sender
{
    if (boardId) {
        APPDELEGATE.endTypeForConference = 1;
        APPDELEGATE.conferenceStatus = 0;
        [self onExitConference];
        
        [timerForVibrate invalidate];
        timerForVibrate = nil;
        
    }else{
        if (localVideoTrack){
            [localVideoTrack removeRenderer:self.soleLocalView];
        }
        [arrARDAppClients removeAllObjects];
        
        if (mainPeerConnection) {
            mainPeerConnection = nil;
        }
        localVideoTrack = nil;
        defaultAudioTrack = nil;
        defaultVideoTrack = nil;
        [self.soleLocalView renderFrame:nil];
        [APPDELEGATE.conferenceMembersForVideoCalling removeAllObjects];
        APPDELEGATE.isConferenceView = NO;
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (IBAction)onAcceptCalling:(id)sender {
    [timerForVibrate invalidate];
    timerForVibrate = nil;
    
    [self billPlayingAndStop];
    
    [lblTitle setText:[self getTitleTextForConference]];
    incomingCallView.hidden = YES;
    
    
    btCancelButton.hidden = NO;
    APPDELEGATE.isOwnerForConference = NO;
    APPDELEGATE.isJoinedOnConference = YES;
    [waitingJoinTimer invalidate];
    waitingJoinTimer = nil;
    isFinishedInitialing = NO;
    
    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted) {
                    [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your Camera or Microphone is disabled.\nPlease go to settings and grant access to it."];
                    APPDELEGATE.endTypeForConference = 3;
                    APPDELEGATE.conferenceStatus = 0;
                    [self onExitConference];
                }
                else {
                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                        if (!granted) {
                            [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your Camera or Microphone is disabled.\nPlease go to settings and grant access to it."];
                            APPDELEGATE.endTypeForConference = 3;
                            APPDELEGATE.conferenceStatus = 0;
                            [self onExitConference];
                        }
                        else {
                            [self joinConference];
                        }
                    }];
                }
            });
        }];
    }
    
}


- (IBAction)onInviteUser:(id)sender {
    SelectUserForConferenceViewController *viewcontroller = [[SelectUserForConferenceViewController alloc] initWithNibName:@"SelectUserForConferenceViewController" bundle:nil];
    viewcontroller.viewcontroller = self;
    if (boardId && APPDELEGATE.conferenceMembersForVideoCalling.count > 0) {
        viewcontroller.boardid = [NSNumber numberWithInteger:[boardId integerValue]];
    }else{
        boardId = nil;
    }
    viewcontroller.isReturnFromConference = YES;
    viewcontroller.conferenceType = conferenceType;
    removeInviteNotification = NO;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:viewcontroller];
    [self presentViewController:nc animated:YES completion:nil];
    
    //    YYYSelectContactController *viewcontroller = [[YYYSelectContactController alloc] initWithNibName:@"YYYSelectContactController" bundle:nil];
    //    viewcontroller.viewcontroller = self;
    //    if (boardId && APPDELEGATE.conferenceMembersForVideoCalling.count > 0) {
    //        viewcontroller.boardid = [NSNumber numberWithInteger:[boardId integerValue]];
    //    }else{
    //        boardId = nil;
    //    }
    //    viewcontroller.isReturnFromConference = YES;
    //    viewcontroller.conferenceType = conferenceType;
    //    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:viewcontroller];
    //    [self presentViewController:nc animated:YES completion:nil];
}

- (void)showingConferenceToolView{
    maskToolView.hidden = YES;
}

- (void)openConferenceFromMenu{
    isSetFromMenu = YES;
    if (localVideoTrack){
        [localVideoTrack removeRenderer:self.soleLocalView];
    }
    [arrARDAppClients removeAllObjects];
    
    if (mainPeerConnection) {
        mainPeerConnection = nil;
    }
    localVideoTrack = nil;
    defaultAudioTrack = nil;
    defaultVideoTrack = nil;
    [self.soleLocalView renderFrame:nil];
    _soleLocalView.hidden = YES;
    
    maskToolView.hidden = NO;
    speakerProgressImg.hidden = YES;
    [speakerBtn setImage:[UIImage imageNamed:@"speak_phone_img"] forState:UIControlStateNormal];
    btnCameraType.enabled = YES;
    btnCameraStatus.enabled = YES;
    btnMicStatus.enabled = YES;
    btnChatText.enabled = YES;
    speakerBtn.enabled = YES;
    
    if (conferenceType && conferenceType == 2) {
        isHideCamera = YES;
        localViewMask.hidden = NO;
        btnCameraStatus.selected = YES;
        imgVoiceMute.hidden = YES;
        imgVideoMute.hidden = YES;
        imgOnlyVoice.hidden = NO;
    }
    
    [arrMembersOfConference removeAllObjects];
    
    for (NSDictionary *dc in APPDELEGATE.conferenceMembersForVideoCalling) {
        if ([[dc objectForKey:@"user_id"] integerValue] != [APPDELEGATE.userId integerValue]) {
            NSMutableDictionary *oneMem = [[NSMutableDictionary alloc] init];
            [oneMem setObject:[dc objectForKey:@"user_id"] forKey:@"user_id"];
            [oneMem setObject:[dc objectForKey:@"name"] forKey:@"name"];
            [oneMem setObject:[dc objectForKey:@"photo_url"] forKey:@"photo_url"];
            [oneMem setObject:[dc objectForKey:@"videoStatus"] forKey:@"videoStatus"];
            [oneMem setObject:[dc objectForKey:@"voiceStatus"] forKey:@"voiceStatus"];
            [arrMembersOfConference addObject:oneMem];
        }
    }
    [self refreshConstraintOfmembers];
    [lblTitle setText:[self getTitleTextForConference]];
    
    [RemoteCollectionView reloadData];
    [self refreshConstraintOfmembers];
    
    
    [self performSelector:@selector(checkingExistMembersOfConference) withObject:nil afterDelay:1.0f];
    [lblTitle setText:conferenceName];
    btCancelButton.hidden = NO;
    isFinishedInitialing = NO;
    
    if (APPDELEGATE.isOwnerForConference) {
        [self createConference];
    }else{
        [lblTitle setText:conferenceName];
        btCancelButton.hidden = NO;
        APPDELEGATE.isOwnerForConference = NO;
        APPDELEGATE.isJoinedOnConference = YES;
        [waitingJoinTimer invalidate];
        waitingJoinTimer = nil;
        [self joinConference];
    }
}

- (void)senddingOfferToInvitionMembers{
    for (int i = 0 ; i < [APPDELEGATE.conferenceMembersForVideoCalling count]; i ++) {
        
        NSMutableDictionary *inviteMem = [[APPDELEGATE.conferenceMembersForVideoCalling objectAtIndex:i] mutableCopy];
        
        BOOL isJoinedMem = NO;
        for (NSDictionary *isExistMem in arrMembersOfConference) {
            if ([[inviteMem objectForKey:@"user_id"] integerValue] == [[isExistMem objectForKey:@"user_id"] integerValue]) {
                isJoinedMem = YES;
            }
        }
        if (!isJoinedMem && [[inviteMem objectForKey:@"user_id"] integerValue] != [APPDELEGATE.userId integerValue]) {
            //            if (!hasClient) {
            ARDAppClient *clientForEmp = [[ARDAppClient alloc] initWithDelegate:self boardId:boardId arrIceServers:iceServers memberId:[inviteMem objectForKey:@"user_id"]];
            clientForEmp.isInitiator = YES;
            clientForEmp.factory = peerConsfactory;
            RTCMediaStream *localStream = mainPeerConnection.localStreams[0];
            [clientForEmp connectToRoomWithId:localStream];
            [clientForEmp sendOffer];
            
            NSMutableDictionary *onePeerConsForEmp = [[NSMutableDictionary alloc] init];
            [onePeerConsForEmp setObject:clientForEmp forKey:@"peerCons"];
            [onePeerConsForEmp setObject:[inviteMem objectForKey:@"user_id"] forKey:@"user_id"];
            [onePeerConsForEmp setObject:@"sender" forKey:@"type"];
            
            [arrARDAppClients addObject:onePeerConsForEmp];
            //           }
            NSMutableDictionary *oneMem = [[NSMutableDictionary alloc] init];
            [oneMem setObject:[inviteMem objectForKey:@"user_id"] forKey:@"user_id"];
            [oneMem setObject:[inviteMem objectForKey:@"name"] forKey:@"name"];
            [oneMem setObject:[inviteMem objectForKey:@"photo_url"] forKey:@"photo_url"];
            [oneMem setObject:[inviteMem objectForKey:@"videoStatus"] forKey:@"videoStatus"];
            [oneMem setObject:[inviteMem objectForKey:@"voiceStatus"] forKey:@"voiceStatus"];
            [arrMembersOfConference addObject:oneMem];
        }
        [inviteMem setObject:@(0) forKey:@"isInvited"];
        [APPDELEGATE.conferenceMembersForVideoCalling replaceObjectAtIndex:i withObject:inviteMem];
    }
    [self refreshConstraintOfmembers];
    [self checkingExistMembersOfConference];
    if (!isHideCamera) {
        [self sendingTurnStatusOfVideo:@"on"];
    }else{
        [self sendingTurnStatusOfVideo:@"off"];
    }
}
- (void)reloadMembersWithStatus{
    if ([APPDELEGATE.conferenceMembersForVideoCalling count] > 0) {
        for (NSDictionary *changeUser in APPDELEGATE.conferenceMembersForVideoCalling) {
            for (int i = 0; i < [arrMembersOfConference count]; i ++) {
                NSMutableDictionary *dict = [[arrMembersOfConference objectAtIndex:i] mutableCopy];
                if ([[changeUser objectForKey:@"user_id"] integerValue] == [[dict objectForKey:@"user_id"] integerValue]) {
                    [dict setObject:[changeUser objectForKey:@"videoStatus"] forKey:@"videoStatus"];
                    [dict setObject:[changeUser objectForKey:@"voiceStatus"] forKey:@"voiceStatus"];
                    
                    [arrMembersOfConference replaceObjectAtIndex:i withObject:dict];
                }
            }
        }
    }
    
    if ([arrMembersOfConference count] > 0) {
        
        [lblTitle setText:[self getTitleTextForConference]];
        [RemoteCollectionView reloadData];
        [self refreshConstraintOfmembers];
        
        [self performSelector:@selector(checkingExistMembersOfConference) withObject:nil afterDelay:1.0f];
    }
}
- (void)hangupConference:(NSNotification *) notification{
    if (APPDELEGATE.isJoinedOnConference) {
        [lblTitle setText:[self getTitleTextForConference]];
        [RemoteCollectionView reloadData];
        [self refreshConstraintOfmembers];
        
        
        [self performSelector:@selector(checkingExistMembersOfConference) withObject:nil afterDelay:1.0f];
    }else{
        [self onCancelCalling:nil];
    }
}
- (void)closeFromCallScreen{
    APPDELEGATE.endTypeForConference = 1;
    APPDELEGATE.conferenceStatus = 0;
    [self onExitConference];
}

- (void)initConferenceFromMenu{
    [APPDELEGATE.conferenceMembersForVideoCalling removeAllObjects];
    
    maskToolView.hidden = YES;
    self.soleLocalView.hidden = NO;
    btnCameraType.enabled = NO;
    btnCameraStatus.enabled = NO;
    btnMicStatus.enabled = NO;
    btnChatText.enabled = NO;
    isFinishedInitialing = YES;
    speakerBtn.enabled = NO;
    
    RTCMediaStream* lStream =  [peerConsfactory mediaStreamWithLabel:@"GINKOARDAMS"];
    
    RTCVideoTrack *lTrack = [self createLocalVideoTrack];
    if (lTrack) {
        [lStream addVideoTrack:lTrack];
        if (localVideoTrack) {
            [localVideoTrack removeRenderer:self.soleLocalView];
            localVideoTrack = nil;
            [self.soleLocalView renderFrame:nil];
        }
        localVideoTrack = lTrack;
        [localVideoTrack addRenderer:self.soleLocalView];
        self.soleLocalView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    }
}

- (void)sendingTurnStatusOfVideo:(NSString *)status{
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        if ([[_responseObject objectForKey:@"success"] boolValue]) {
            NSLog(@"sent a status successfully!");
        }
    };
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
        [CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Internet Connection Error!"];
    };
    [[YYYCommunication sharedManager] TurnStatusOfVideoConference:APPDELEGATE.sessionId boardId:boardId status:status successed:successed failure:failure];
}
- (void)sendingTurnStatusOfAudio:(NSString *)status{
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        if ([[_responseObject objectForKey:@"success"] boolValue]) {
            NSLog(@"sent a status successfully!");
        }
    };
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
        [CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Internet Connection Error!"];
    };
    [[YYYCommunication sharedManager] TurnStatusOfAudioConference:APPDELEGATE.sessionId boardId:boardId status:status successed:successed failure:failure];
}
- (IBAction)onCameraTypeChange:(id)sender {
    if (isHideCamera) {
        return;
    }
    btnCameraType.selected = !btnCameraType.selected;
    if (!btnCameraType.selected) {
        [self swapCameraToFront];
        self.isVideoMute = NO;
    } else {
        [self swapCameraToBack];
        self.isVideoMute = YES;
    }
}

- (IBAction)onChangeCamraStatus:(id)sender {
    localViewMask.hidden = YES;
    btnCameraStatus.selected = !btnCameraStatus.selected;
    if (!btnCameraStatus.selected) {
        isHideCamera = NO;
        [self sendingTurnStatusOfVideo:@"on"];
        [self unmuteVideoIn];
        if (btnCameraType.selected) {
            [self swapCameraToBack];
        }else{
            [self swapCameraToFront];
        }
        
        if (btnMicStatus.selected) {
            imgVoiceMute.hidden = NO;
            imgVideoMute.hidden = YES;
            imgOnlyVoice.hidden = YES;
        }else{
            imgVoiceMute.hidden = YES;
            imgVideoMute.hidden = YES;
            imgOnlyVoice.hidden = YES;
        }
    }else{
        //[self hideCamera];
        [self muteVideoIn];
        [self sendingTurnStatusOfVideo:@"off"];
        if (localVideoTrack) {
            [localVideoTrack removeRenderer:self.localView];
            localVideoTrack = nil;
            [self.localView renderFrame:nil];
        }
        isHideCamera = YES;
        if (btnMicStatus.selected) {
            imgVoiceMute.hidden = NO;
            imgVideoMute.hidden = NO;
            imgOnlyVoice.hidden = YES;
        }else{
            imgVoiceMute.hidden = YES;
            imgVideoMute.hidden = YES;
            imgOnlyVoice.hidden = NO;
        }
    }
}

- (IBAction)onChangeMicStatus:(id)sender {
    btnMicStatus.selected = !btnMicStatus.selected;
    if (!btnMicStatus.selected) {
        [self unmuteAudioIn];
        [self sendingTurnStatusOfAudio:@"on"];
        self.isAudioMute = NO;
        if (btnCameraStatus.selected) {
            imgVoiceMute.hidden = YES;
            imgVideoMute.hidden = YES;
            imgOnlyVoice.hidden = NO;
        }else{
            imgVoiceMute.hidden = YES;
            imgVideoMute.hidden = YES;
            imgOnlyVoice.hidden = YES;
        }
    } else {
        [self muteAudioIn];
        [self sendingTurnStatusOfAudio:@"off"];
        self.isAudioMute = YES;
        if (btnCameraStatus.selected) {
            imgVoiceMute.hidden = NO;
            imgVideoMute.hidden = NO;
            imgOnlyVoice.hidden = YES;
        }else{
            imgVoiceMute.hidden = NO;
            imgVideoMute.hidden = YES;
            imgOnlyVoice.hidden = YES;
        }
    }
}
- (void)reloadSpeakerMode{
    AVAudioSession* session = [AVAudioSession sharedInstance];
    NSError* error;
    if (!isSpeakerEnabled) {
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
        
        AudioSessionSetProperty (
                                 kAudioSessionProperty_OverrideAudioRoute,
                                 sizeof (audioRouteOverride),
                                 &audioRouteOverride
                                 );
    }else{
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        [session setMode:AVAudioSessionModeVoiceChat error:&error];
        
        [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    }
    
    [session setActive:YES error:&error];
}
- (IBAction)onChangeSpeakerMode:(UIButton *)sender {
    if ([self isHeadsetPluggedIn]) {
        
        if (isSpeakerEnabled) {
            isSpeakerEnabled = NO;
            speakerProgressImg.hidden = YES;
            [speakerBtn setImage:[UIImage imageNamed:@"speak_phone_img"] forState:UIControlStateNormal];
            
        }else{
            isSpeakerEnabled = YES;
            speakerProgressImg.hidden = NO;
            [speakerBtn setImage:nil forState:UIControlStateNormal];
            
        }
        
        [self reloadSpeakerMode];
    }else{
        if (isSpeakerEnabled) {
            isSpeakerEnabled = NO;
            speakerProgressImg.hidden = YES;
            [speakerBtn setImage:[UIImage imageNamed:@"speak_phone_img"] forState:UIControlStateNormal];
        }else{
            isSpeakerEnabled = YES;
            speakerProgressImg.hidden = NO;
            [speakerBtn setImage:nil forState:UIControlStateNormal];
        }
    }
    
}

- (IBAction)onCloseConferenceClick:(UIButton *)sender {
    if (boardId) {
        APPDELEGATE.endTypeForConference = 1;
        APPDELEGATE.conferenceStatus = 0;
        [self onExitConference];
        
        [timerForVibrate invalidate];
        timerForVibrate = nil;
        
    }else{
        if (localVideoTrack){
            [localVideoTrack removeRenderer:self.soleLocalView];
        }
        [arrARDAppClients removeAllObjects];
        
        if (mainPeerConnection) {
            mainPeerConnection = nil;
        }
        localVideoTrack = nil;
        defaultAudioTrack = nil;
        defaultVideoTrack = nil;
        [self.soleLocalView renderFrame:nil];
        [APPDELEGATE.conferenceMembersForVideoCalling removeAllObjects];
        APPDELEGATE.isConferenceView = NO;
        [self.navigationController popViewControllerAnimated:YES];
    }
}


-(void)showAlert:(NSString*)_message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:_message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}


#pragma mark UICollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [arrMembersOfConference count];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellWidth;
    CGFloat cellHeight;
    
    switch ([arrMembersOfConference count]) {
        case 1:
            cellWidth =  [RemoteCollectionView bounds].size.width;
            cellHeight =  [RemoteCollectionView bounds].size.height-20;
            return CGSizeMake(cellWidth, cellHeight);
            break;
        case 2:
            cellWidth =  [RemoteCollectionView bounds].size.width/2;
            cellHeight =  [RemoteCollectionView bounds].size.height-20;
            return CGSizeMake(cellWidth, cellHeight);
            break;
        case 3:
            cellWidth =  [RemoteCollectionView bounds].size.width/2;
            cellHeight =  ([RemoteCollectionView bounds].size.height-20)/2;
            return CGSizeMake(cellWidth, cellHeight);
            break;
        case 4:
            cellWidth =  [RemoteCollectionView bounds].size.width/2;
            cellHeight =  ([RemoteCollectionView bounds].size.height-20)/2;
            return CGSizeMake(cellWidth, cellHeight);
            break;
        case 5:
            cellWidth =  [RemoteCollectionView bounds].size.width/2;
            cellHeight =  ([RemoteCollectionView bounds].size.height-20)/3;
            return CGSizeMake(cellWidth, cellHeight);
            break;
        case 6:
            cellWidth =  [RemoteCollectionView bounds].size.width/2;
            cellHeight =  ([RemoteCollectionView bounds].size.height-20)/3;
            return CGSizeMake(cellWidth, cellHeight);
            break;
        case 7:
            cellWidth =  [RemoteCollectionView bounds].size.width/2;
            cellHeight =  ([RemoteCollectionView bounds].size.height-20)/4;
            return CGSizeMake(cellWidth, cellHeight);
            break;
            
        default:
            break;
    }
    cellWidth =  [RemoteCollectionView bounds].size.width;
    cellHeight = [RemoteCollectionView bounds].size.height-20;
    return CGSizeMake(cellWidth, cellHeight);
}

//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
//
//    return 1;
//}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [RemoteCollectionView performBatchUpdates:nil completion:nil];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *strIdentifier = @"RemoteViewItem";
    RemoteViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:strIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [RemoteViewCell sharedCell];
    }
    cell.delegate = self;
    CGFloat scale = 640.0f / 480.0f;
    switch ([arrMembersOfConference count]) {
        case 1:
            cell.remoteCellWidthCons.constant =  [RemoteCollectionView bounds].size.width;
            cell.remoteCellHeightCons.constant =  [RemoteCollectionView bounds].size.height-20;
            cell.remoteViewWidthCons.constant = [cell bounds].size.width;
            cell.remoteViewHeightCons.constant = [cell bounds].size.height * scale;
            break;
        case 2:
            cell.remoteCellWidthCons.constant =  [RemoteCollectionView bounds].size.width/2;
            cell.remoteCellHeightCons.constant =  [RemoteCollectionView bounds].size.height-20;
            cell.remoteViewWidthCons.constant = [cell bounds].size.width * scale;
            cell.remoteViewHeightCons.constant = [cell bounds].size.height;
            break;
        case 3:
            cell.remoteCellWidthCons.constant =  [RemoteCollectionView bounds].size.width/2;
            cell.remoteCellHeightCons.constant =  ([RemoteCollectionView bounds].size.height-20)/2;
            cell.remoteViewWidthCons.constant = [cell bounds].size.width * scale;
            cell.remoteViewHeightCons.constant = [cell bounds].size.height;
            break;
        case 4:
            cell.remoteCellWidthCons.constant =  [RemoteCollectionView bounds].size.width/2;
            cell.remoteCellHeightCons.constant =  ([RemoteCollectionView bounds].size.height-20)/2;
            //cell.remoteViewWidthCons.constant = [cell bounds].size.width;
            //cell.remoteViewHeightCons.constant = [cell bounds].size.height * scale;
            //[cell.remoteViewOne setFrame:CGRectMake(0.0f, 0.0f, ([RemoteCollectionView bounds].size.width/2) * scale, ([RemoteCollectionView bounds].size.height-20)/2)];
            break;
        case 5:
            cell.remoteCellWidthCons.constant =  [RemoteCollectionView bounds].size.width/2;
            cell.remoteCellHeightCons.constant =  ([RemoteCollectionView bounds].size.height-20)/3;
            //cell.remoteViewWidthCons.constant = [cell bounds].size.width;
            //cell.remoteViewHeightCons.constant = [cell bounds].size.height * scale;
            //[cell.remoteViewOne setFrame:CGRectMake(0.0f, 0.0f, ([RemoteCollectionView bounds].size.width/2) * scale, ([RemoteCollectionView bounds].size.height-20)/3)];
            break;
        case 6:
            cell.remoteCellWidthCons.constant =  [RemoteCollectionView bounds].size.width/2;
            cell.remoteCellHeightCons.constant =  ([RemoteCollectionView bounds].size.height-20)/3;
            cell.remoteViewWidthCons.constant = [cell bounds].size.width;
            cell.remoteViewHeightCons.constant = [cell bounds].size.height * scale;
            break;
        case 7:
            cell.remoteCellWidthCons.constant =  [RemoteCollectionView bounds].size.width/2;
            cell.remoteCellHeightCons.constant =  ([RemoteCollectionView bounds].size.height-20)/4;
            cell.remoteViewWidthCons.constant = [cell bounds].size.width;
            cell.remoteViewHeightCons.constant = [cell bounds].size.height * scale;
            break;
            
        default:
            break;
    }
    
    
    NSDictionary *aMember = [arrMembersOfConference objectAtIndex:indexPath.row];
    
    if (cell.remoteCellWidthCons.constant > cell.remoteCellHeightCons.constant) {
        cell.profileImageWidth.constant = cell.remoteCellHeightCons.constant-40;
        cell.profileImageHeight.constant = cell.remoteCellHeightCons.constant-40;
        
        cell.alertWidth.constant = cell.remoteCellHeightCons.constant-50;
        cell.alertheight.constant = cell.alertWidth.constant * 0.55f;
        cell.btnNoWidth.constant = cell.alertWidth.constant/2;
        cell.btnYesWidth.constant = cell.alertWidth.constant/2;
    }else{
        cell.profileImageWidth.constant = cell.remoteCellWidthCons.constant-40;
        cell.profileImageHeight.constant = cell.remoteCellWidthCons.constant-40;
        
        cell.alertWidth.constant = cell.remoteCellWidthCons.constant-50;
        cell.alertheight.constant = cell.alertWidth.constant * 0.55f;
        cell.btnNoWidth.constant = cell.alertWidth.constant/2;
        cell.btnYesWidth.constant = cell.alertWidth.constant/2;
    }
    
    
    NSArray *animationArray=[NSArray arrayWithObjects:
                             [UIImage imageNamed:@"SproutProgressforConference01.png"],
                             [UIImage imageNamed:@"SproutProgressforConference02.png"],
                             [UIImage imageNamed:@"SproutProgressforConference03.png"],
                             [UIImage imageNamed:@"SproutProgressforConference04.png"],
                             [UIImage imageNamed:@"SproutProgressforConference05.png"],
                             [UIImage imageNamed:@"SproutProgressforConference06.png"],
                             nil];
    cell.imgIntiatingCall.animationImages=animationArray;
    cell.imgIntiatingCall.animationDuration=3;
    cell.imgIntiatingCall.animationRepeatCount=0;
    [cell.imgIntiatingCall startAnimating];
    
    cell.maskView.hidden = NO;
    
    
    [cell setPhoto:[aMember objectForKey:@"photo_url"]];
    [cell setCurrentMemberId:[NSString stringWithFormat:@"%@", [aMember objectForKey:@"user_id"]]];
    
    
    cell.alertCoverView.hidden = YES;
    
    if (isDisconnected) {
        [cell.lblStatus setTextColor:[UIColor redColor]];
        cell.lblStatus.text = [NSString stringWithFormat:@"Disconnected!"];
        cell.isRendering = NO;
        cell.maskView.hidden = NO;
        cell.imgIntiatingCall.hidden = YES;
        cell.alertCoverView.hidden = YES;
        if ([aMember objectForKey:@"remoteVideoTrack"]) {
            if(cell.remoteViewOne != nil)
            {
                RTCVideoTrack *videoTrack = [aMember objectForKey:@"remoteVideoTrack"];
                [videoTrack removeRenderer:cell.remoteViewOne];
                [cell.remoteViewOne renderFrame:nil];
                videoTrack = nil;
            }
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:[aMember objectForKey:@"user_id"] forKey:@"user_id"];
            [dic setObject:[aMember objectForKey:@"name"] forKey:@"name"];
            [dic setObject:[aMember objectForKey:@"photo_url"] forKey:@"photo_url"];
            [dic setObject:[aMember objectForKey:@"videoStatus"] forKey:@"videoStatus"];
            [dic setObject:[aMember objectForKey:@"voiceStatus"] forKey:@"voiceStatus"];
            
            [arrMembersOfConference replaceObjectAtIndex:indexPath.row withObject:dic];
        }
    }else{
        NSDictionary *dicOfConferenceStatus;
        for (NSDictionary *oneInfo in APPDELEGATE.conferenceMembersForVideoCalling) {
            if ([[oneInfo objectForKey:@"user_id"] integerValue] == [[aMember objectForKey:@"user_id"] integerValue]) {
                dicOfConferenceStatus = [oneInfo copy];
            }
        }
        if ([dicOfConferenceStatus objectForKey:@"conferenceStatus"]) {
            switch ([[dicOfConferenceStatus objectForKey:@"conferenceStatus"] integerValue]) {
                case 1:{//initial
                    cell.lblStatus.hidden = NO;
                    [cell.lblStatus setTextColor:COLOR_GREEN_THEME];
                    cell.lblStatus.text = @"";
                    //cell.lblStatus.text = [NSString stringWithFormat:@"%@ is initaling...",[aMember objectForKey:@"name"]];
                    cell.imgIntiatingCall.hidden = NO;
                    
                    if (arrARDAppClients.count == arrMembersOfConference.count) {
                        NSDictionary *oneARDAppClent =  [arrARDAppClients objectAtIndex:indexPath.row];
                        if ([[oneARDAppClent objectForKey:@"type"] isEqualToString:@"sender"]) {
                            [cell startAcceptTimerCount];
                            
                            for (int i = 0 ; i < [APPDELEGATE.conferenceMembersForVideoCalling count]; i ++) {
                                NSMutableDictionary *changeUser = [[APPDELEGATE.conferenceMembersForVideoCalling objectAtIndex:i] mutableCopy];
                                if ([[changeUser objectForKey:@"user_id"] integerValue] == [[aMember objectForKey:@"user_id"] integerValue]) {
                                    [changeUser setObject:@(8) forKey:@"conferenceStatus"];
                                    [APPDELEGATE.conferenceMembersForVideoCalling replaceObjectAtIndex:i withObject:changeUser];
                                }
                            }
                        }
                    }
                    
                    break;
                }
                case 2:{//accept
                    cell.lblStatus.hidden = NO;
                    [cell.lblStatus setTextColor:COLOR_GREEN_THEME];
                    cell.lblStatus.text = @"";
                    //cell.lblStatus.text = [NSString stringWithFormat:@"%@ accepted",[aMember objectForKey:@"name"]];
                    cell.imgIntiatingCall.hidden = YES;
                    
                    
                    [cell hideAlertOnCell];
                    break;
                }
                case 3:{//join
                    cell.lblStatus.hidden = NO;
                    [cell.lblStatus setTextColor:[UIColor whiteColor]];
                    cell.lblStatus.text = [NSString stringWithFormat:@"%@",[aMember objectForKey:@"name"]];
                    RTCEAGLVideoView *remoteView = [[RTCEAGLVideoView alloc]init];
                    cell.imgIntiatingCall.hidden = YES;
                    if ([aMember objectForKey:@"remoteVideoTrack"]) {
                        RTCVideoTrack *videoTrack = [aMember objectForKey:@"remoteVideoTrack"];
                        [videoTrack addRenderer:remoteView];
                        [remoteView setDelegate:self];
                        //                        [cell.remoteViewOne setDelegate:self];
                        //                        if (!cell.isRendering) {
                        //                            [videoTrack addRenderer:cell.remoteViewOne];
                        //                            cell.isRendering = YES;
                        //                        }
                        if(cell.remoteViewOne != nil)
                        {
                            
                        }
                        [cell setVideoView:nil];
                        [cell setVideoView:remoteView];
                        //                        else{
                        //                            if (videoTrack) {
                        //
                        //                                [videoTrack removeRenderer:cell.remoteViewOne];
                        //                                [cell.remoteViewOne renderFrame:nil];
                        //                            }
                        //                            [videoTrack addRenderer:cell.remoteViewOne];
                        //                        }
                        //                        [videoTrack addRenderer:cell.remoteViewOne];
                        remoteView = nil;
                        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                        [dic setObject:[aMember objectForKey:@"user_id"] forKey:@"user_id"];
                        [dic setObject:[aMember objectForKey:@"name"] forKey:@"name"];
                        [dic setObject:[aMember objectForKey:@"photo_url"] forKey:@"photo_url"];
                        if (videoTrack)
                            [dic setObject:videoTrack forKey:@"remoteVideoTrack"];
                        [dic setObject:[aMember objectForKey:@"videoStatus"] forKey:@"videoStatus"];
                        [dic setObject:[aMember objectForKey:@"voiceStatus"] forKey:@"voiceStatus"];
                        
                        [arrMembersOfConference replaceObjectAtIndex:indexPath.row withObject:dic];
                        if (cell.remoteViewOne != nil)
                            cell.remoteViewOne.transform = CGAffineTransformMakeScale(-1.0, 1.0);
                        [cell.lblStatus setTextColor:[UIColor whiteColor]];
                        cell.lblStatus.text = [NSString stringWithFormat:@"%@",[aMember objectForKey:@"name"]];
                        videoTrack = nil;
                        
                        if ([[aMember objectForKey:@"videoStatus"] isEqualToString:@"on"] && [[aMember objectForKey:@"voiceStatus"] isEqualToString:@"on"]) {
                            cell.maskView.hidden = YES;
                        }else if ([[aMember objectForKey:@"videoStatus"] isEqualToString:@"on"] && [[aMember objectForKey:@"voiceStatus"] isEqualToString:@"off"]) {
                            cell.maskView.hidden = YES;
                        }else if ([[aMember objectForKey:@"videoStatus"] isEqualToString:@"off"] && [[aMember objectForKey:@"voiceStatus"] isEqualToString:@"on"]) {
                            cell.maskView.hidden = NO;
                        }else if ([[aMember objectForKey:@"videoStatus"] isEqualToString:@"off"] && [[aMember objectForKey:@"voiceStatus"] isEqualToString:@"off"]) {
                            cell.maskView.hidden = NO;
                        }
                        
                    }
                    [cell hideAlertOnCell];
                    break;
                }
                case 4:{//already started
                    cell.lblStatus.hidden = NO;
                    [cell.lblStatus setTextColor:[UIColor whiteColor]];
                    cell.lblStatus.text = [NSString stringWithFormat:@"%@",[aMember objectForKey:@"name"]];
                    
                    cell.imgIntiatingCall.hidden = YES;
                    cell.maskView.hidden = YES;
                    if ([aMember objectForKey:@"remoteVideoTrack"]) {
                        
                        [cell.lblStatus setTextColor:[UIColor whiteColor]];
                        cell.lblStatus.text = [NSString stringWithFormat:@"%@",[aMember objectForKey:@"name"]];
                        
                        if ([[aMember objectForKey:@"videoStatus"] isEqualToString:@"on"] && [[aMember objectForKey:@"voiceStatus"] isEqualToString:@"on"]) {
                            cell.maskView.hidden = YES;
                        }else if ([[aMember objectForKey:@"videoStatus"] isEqualToString:@"on"] && [[aMember objectForKey:@"voiceStatus"] isEqualToString:@"off"]) {
                            cell.maskView.hidden = YES;
                        }else if ([[aMember objectForKey:@"videoStatus"] isEqualToString:@"off"] && [[aMember objectForKey:@"voiceStatus"] isEqualToString:@"on"]) {
                            cell.maskView.hidden = NO;
                        }else if ([[aMember objectForKey:@"videoStatus"] isEqualToString:@"off"] && [[aMember objectForKey:@"voiceStatus"] isEqualToString:@"off"]) {
                            cell.maskView.hidden = NO;
                        }
                    }
                    
                    [cell hideAlertOnCell];
                    break;
                }
                case 8:{//started timer
                    cell.lblStatus.hidden = YES;
                    cell.imgIntiatingCall.hidden = NO;
                    cell.maskView.hidden = NO;
                    cell.alertCoverView.hidden = YES;
                    break;
                }
                case 9:{//no answer
                    cell.lblStatus.hidden = YES;
                    cell.imgIntiatingCall.hidden = YES;
                    cell.maskView.hidden = NO;
                    
                    [cell showAlertOnCell];
                    break;
                }
                case 11:{//left
                    cell.lblStatus.hidden = NO;
                    [cell.lblStatus setTextColor:[UIColor redColor]];
                    cell.lblStatus.text = [NSString stringWithFormat:@"%@ left",[aMember objectForKey:@"name"]];
                    cell.imgIntiatingCall.hidden = YES;
                    cell.maskView.hidden = NO;
                    if ([aMember objectForKey:@"remoteVideoTrack"]) {
                        RTCVideoTrack *videoTrack = [aMember objectForKey:@"remoteVideoTrack"];
                        if(cell.remoteViewOne != nil)
                        {
                            [videoTrack removeRenderer:cell.remoteViewOne];
                            [cell setVideoView:nil];
                            [cell.remoteViewOne renderFrame:nil];
                        }
                        videoTrack = nil;
                        
                        cell.maskView.hidden = NO;
                        cell.isRendering = NO;
                    }
                    
                    [cell hideAlertOnCell];
                    break;
                }
                case 12:{//busy
                    cell.lblStatus.hidden = NO;
                    [cell.lblStatus setTextColor:[UIColor redColor]];
                    cell.lblStatus.text = [NSString stringWithFormat:@"%@ is busy",[aMember objectForKey:@"name"]];
                    cell.imgIntiatingCall.hidden = YES;
                    cell.maskView.hidden = NO;
                    if ([aMember objectForKey:@"remoteVideoTrack"]) {
                        RTCVideoTrack *videoTrack = [aMember objectForKey:@"remoteVideoTrack"];
                        if(cell.remoteViewOne != nil)
                        {
                            [videoTrack removeRenderer:cell.remoteViewOne];
                            [cell setVideoView:nil];
                            [cell.remoteViewOne renderFrame:nil];
                        }
                        videoTrack = nil;
                        
                        cell.maskView.hidden = NO;
                        cell.isRendering = NO;
                    }
                    
                    [cell hideAlertOnCell];
                    break;
                }
                case 13:{//failed
                    cell.lblStatus.hidden = NO;
                    [cell.lblStatus setTextColor:[UIColor redColor]];
                    cell.lblStatus.text = [NSString stringWithFormat:@"%@ failed",[aMember objectForKey:@"name"]];
                    cell.imgIntiatingCall.hidden = YES;
                    cell.maskView.hidden = NO;
                    if ([aMember objectForKey:@"remoteVideoTrack"]) {
                        RTCVideoTrack *videoTrack = [aMember objectForKey:@"remoteVideoTrack"];
                        if(cell.remoteViewOne != nil)
                        {
                            [videoTrack removeRenderer:cell.remoteViewOne];
                            [cell setVideoView:nil];
                            [cell.remoteViewOne renderFrame:nil];
                        }
                        videoTrack = nil;
                        cell.maskView.hidden = NO;
                        cell.isRendering = NO;
                    }
                    
                    [cell hideAlertOnCell];
                    break;
                }
                default:
                    break;
            }
        }
    }
    
    
    //[cell setBorder];
    cell.profileImageMember.layer.cornerRadius = cell.profileImageWidth.constant / 2.0f;
    cell.profileImageMember.layer.masksToBounds = YES;
    cell.profileImageMember.layer.borderWidth = 1.0f;
    cell.profileImageMember.layer.borderColor = COLOR_PURPLE_THEME.CGColor;
    return cell;
}

//#pragma mark ConferenceInviationUserCellDelegate
//- (void)conferenceGinkoUserCellInvite:(ConferenceInvitationUserCell *)cell{
//    NSIndexPath *indexPath = [contactInvitationTablebiew indexPathForCell:cell];
//    if (indexPath) {
//        NSDictionary *contact = [lst_user objectAtIndex:indexPath.row];
//    }
//}

- (void)checkingExistMembersOfConference{
    if ([APPDELEGATE.conferenceMembersForVideoCalling count] > 0) {
        for (int i = 0 ; i < [APPDELEGATE.conferenceMembersForVideoCalling count]; i ++) {
            NSDictionary *changeUser = [APPDELEGATE.conferenceMembersForVideoCalling objectAtIndex:i];
            if ([[changeUser objectForKey:@"conferenceStatus"] integerValue] > 10) {
                [APPDELEGATE.conferenceMembersForVideoCalling removeObjectAtIndex:i];
                
                for (int j = 0; j < [arrMembersOfConference count]; j ++) {
                    NSDictionary *dict = [arrMembersOfConference objectAtIndex:j];
                    if ([[changeUser objectForKey:@"user_id"] integerValue] == [[dict objectForKey:@"user_id"] integerValue]) {
                        [arrMembersOfConference removeObjectAtIndex:j];
                        
                    }
                }
            }
        }
        
        if ([arrMembersOfConference count] > 0) {
            [lblTitle setText:[self getTitleTextForConference]];
            [RemoteCollectionView reloadData];
            [self refreshConstraintOfmembers];
            
        }
        
        [self performSelector:@selector(checkingUserExistStatus) withObject:nil afterDelay:0.5f];
    }
}

- (void)checkingUserExistStatus{
    int initialingCount = 0;
    for (int i = 0 ; i < [APPDELEGATE.conferenceMembersForVideoCalling count]; i ++) {
        NSMutableDictionary *changeUser = [[APPDELEGATE.conferenceMembersForVideoCalling objectAtIndex:i] mutableCopy];
        if ([[changeUser objectForKey:@"conferenceStatus"] integerValue] < 10) {
            initialingCount ++;
        }
    }
    if (initialingCount == 0) {//exist oneself on conference
        if (APPDELEGATE.conferenceStatus != 0) {
            APPDELEGATE.endTypeForConference = 1;
            APPDELEGATE.conferenceStatus = 0;
            [self onExitConference];
        }
        [APPDELEGATE.conferenceMembersForVideoCalling removeAllObjects];
    }
}

#pragma mark RmoteViewCellDelegate

-(void)didYesTryCalling:(NSString *)userId{
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            for (int i = 0 ; i < [APPDELEGATE.conferenceMembersForVideoCalling count]; i ++) {
                NSMutableDictionary *changeUser = [[APPDELEGATE.conferenceMembersForVideoCalling objectAtIndex:i] mutableCopy];
                if ([[changeUser objectForKey:@"user_id"] integerValue] == [userId integerValue]) {
                    [changeUser setObject:@(1) forKey:@"conferenceStatus"];
                    [APPDELEGATE.conferenceMembersForVideoCalling replaceObjectAtIndex:i withObject:changeUser];
                }
            }
            ARDAppClient *clientForEmp = [[ARDAppClient alloc] initWithDelegate:self boardId:boardId arrIceServers:iceServers memberId:userId];
            clientForEmp.isInitiator = YES;
            clientForEmp.factory = peerConsfactory;
            RTCMediaStream *localStream = mainPeerConnection.localStreams[0];
            [clientForEmp connectToRoomWithId:localStream];
            [clientForEmp sendOffer];
            
            for (int i = 0; i < [arrARDAppClients count]; i ++) {
                NSMutableDictionary *onePeerConsForEmp = [[arrARDAppClients objectAtIndex:i] mutableCopy];
                if ([[onePeerConsForEmp objectForKey:@"user_id"] integerValue] == [userId integerValue]) {
                    [onePeerConsForEmp setObject:clientForEmp forKey:@"peerCons"];
                    [arrARDAppClients replaceObjectAtIndex:i withObject:onePeerConsForEmp];
                }
            }
            
            [self refreshConstraintOfmembers];
            [self checkingExistMembersOfConference];
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
    [[YYYCommunication sharedManager] InviteNewMembersOnConference:APPDELEGATE.sessionId boardId:[NSString stringWithFormat:@"%@", boardId] userIds:userId successed:successed failure:failure];
    
    
}

-(void)didNoTryCalling:(NSString *)userId{
    for (int i = 0 ; i < [APPDELEGATE.conferenceMembersForVideoCalling count]; i ++) {
        NSMutableDictionary *changeUser = [[APPDELEGATE.conferenceMembersForVideoCalling objectAtIndex:i] mutableCopy];
        if ([[changeUser objectForKey:@"user_id"] integerValue] == [userId integerValue]) {
            [changeUser setObject:@(13) forKey:@"conferenceStatus"];
            [APPDELEGATE.conferenceMembersForVideoCalling replaceObjectAtIndex:i withObject:changeUser];
        }
    }
    
    [lblTitle setText:[self getTitleTextForConference]];
    [RemoteCollectionView reloadData];
    [self refreshConstraintOfmembers];
    
    
    [self performSelector:@selector(checkingExistMembersOfConference) withObject:nil afterDelay:1.0f];
}
-(void)noAnsweringNotification:(NSString *)userId{
    if ([APPDELEGATE.conferenceMembersForVideoCalling count] > 0) {
        
        NSMutableArray *tmpConferenceMemberForVideoCalling = [[NSMutableArray alloc] init];
        
        for (NSDictionary *changeUser in APPDELEGATE.conferenceMembersForVideoCalling) {
            
            if ([[changeUser objectForKey:@"conferenceStatus"] integerValue] != 9) {
                
                [tmpConferenceMemberForVideoCalling addObject:[changeUser mutableCopy]];
                
            }else {
                if ([[changeUser objectForKey:@"isInvitedByMe"] boolValue]) {
                    [tmpConferenceMemberForVideoCalling addObject:[changeUser mutableCopy]];
                }else{
                    for (int j = 0; j < [arrMembersOfConference count]; j ++) {
                        NSDictionary *dict = [arrMembersOfConference objectAtIndex:j];
                        if ([[changeUser objectForKey:@"user_id"] integerValue] == [[dict objectForKey:@"user_id"] integerValue]) {
                            [arrMembersOfConference removeObjectAtIndex:j];
                            [arrARDAppClients removeObjectAtIndex:j];
                            
                        }
                    }
                }
                
            }
        }
        //        BOOL reLoadFlg = NO;
        //        if ([APPDELEGATE.conferenceMembersForVideoCalling count] != [tmpConferenceMemberForVideoCalling count]) {
        //            reLoadFlg = YES;
        //        }
        
        BOOL reLoadFlg = YES;
        [APPDELEGATE.conferenceMembersForVideoCalling removeAllObjects];
        APPDELEGATE.conferenceMembersForVideoCalling = tmpConferenceMemberForVideoCalling;
        
        
        if ([arrMembersOfConference count] > 0) {
            [lblTitle setText:[self getTitleTextForConference]];
            if (reLoadFlg) {
                [RemoteCollectionView reloadData];
            }
            [self refreshConstraintOfmembers];
            
        }
        [self performSelector:@selector(checkingUserExistStatusForAnwer) withObject:nil afterDelay:0.5f];
    }
}


#pragma mark Setting Local View

#pragma mark - Audio mute/unmute
- (void)muteAudioIn {
    NSLog(@"audio muted");
    RTCMediaStream *localStream = mainPeerConnection.localStreams[0];
    defaultAudioTrack = localStream.audioTracks[0];
    [localStream removeAudioTrack:localStream.audioTracks[0]];
    
    for (NSDictionary *dict in arrARDAppClients) {
        [(ARDAppClient *)[dict objectForKey:@"peerCons"] setStreamPeerConnection:localStream];
    }
}
- (void)unmuteAudioIn {
    NSLog(@"audio unmuted");
    RTCMediaStream* localStream = mainPeerConnection.localStreams[0];
    [localStream addAudioTrack:defaultAudioTrack];
    for (NSDictionary *dict in arrARDAppClients) {
        [(ARDAppClient *)[dict objectForKey:@"peerCons"] setStreamPeerConnection:localStream];
    }
}

#pragma mark - Video mute/unmute
- (void)muteVideoIn {
    NSLog(@"video muted");
    RTCMediaStream *localStream = mainPeerConnection.localStreams[0];
    defaultVideoTrack = localStream.videoTracks[0];
    [localStream removeVideoTrack:localStream.videoTracks[0]];
    
    for (NSDictionary *dict in arrARDAppClients) {
        [(ARDAppClient *)[dict objectForKey:@"peerCons"] setStreamPeerConnection:localStream];
    }
}
- (void)unmuteVideoIn {
    NSLog(@"video unmuted");
    
    RTCMediaStream* localStream = mainPeerConnection.localStreams[0];
    if (defaultVideoTrack) {
        [localStream addVideoTrack:defaultVideoTrack];
    }else{
        defaultVideoTrack = localStream.videoTracks[0];
        [localStream addVideoTrack:defaultVideoTrack];
    }
    for (NSDictionary *dict in arrARDAppClients) {
        [(ARDAppClient *)[dict objectForKey:@"peerCons"] setStreamPeerConnection:localStream];
    }
}

#pragma mark - swap camera
- (RTCVideoTrack *)createLocalVideoTrackBackCamera {
    RTCVideoTrack *lTrack = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // [source.captureSession stopRunning];
        //        AVCaptureDeviceInput *inputCameraDevice = [AVCaptureDeviceInput deviceInputWithDevice:cameraDeviceB error:&deviceError];
        AVCaptureVideoDataOutput *outputVideoDevice = [[AVCaptureVideoDataOutput alloc] init];
        NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
        NSNumber* val = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange];
        NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:val forKey:key];
        outputVideoDevice.videoSettings = videoSettings;
        [outputVideoDevice setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
        source.useBackCamera = YES;
        //        [source.captureSession beginConfiguration];
        //        [source.captureSession setSessionPreset:[NSString stringWithString:AVCaptureSessionPreset640x480]];
        connectionVideo = [outputVideoDevice connectionWithMediaType:AVMediaTypeVideo];
        //#if TARGET_OS_IPHONE
        //        [self setRelativeVideoOrientation];
        //
        //        NSNotificationCenter* notify = [NSNotificationCenter defaultCenter];
        //        [notify addObserver:self
        //                   selector:@selector(statusBarOrientationDidChange:)
        //                       name:@"StatusBarOrientationDidChange"
        //                     object:nil];
        //#endif
        //[source.captureSession commitConfiguration];
        //[source.captureSession startRunning];
        sessionRunning = source.captureSession.isRunning;
    });
    
    lTrack = [[RTCVideoTrack alloc] initWithFactory:peerConsfactory
                                             source:source
                                            trackId:@"GINKOARDAMSv0"];
    return lTrack;
}
#pragma mark -  方向设置

#if TARGET_OS_IPHONE
- (void)statusBarOrientationDidChange:(NSNotification*)notification {
    [self setRelativeVideoOrientation];
}

- (void)setRelativeVideoOrientation {
    switch ([[UIDevice currentDevice] orientation]) {
        case UIInterfaceOrientationPortrait:
#if defined(__IPHONE_8_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
        case UIInterfaceOrientationUnknown:
#endif
            connectionVideo.videoOrientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            connectionVideo.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            connectionVideo.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIInterfaceOrientationLandscapeRight:
            connectionVideo.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        default:
            break;
    }
}
#endif
- (void)swapCameraToFront{
    RTCMediaStream *localStream = mainPeerConnection.localStreams[0];
    if (localStream) {
        [localStream removeVideoTrack:localStream.videoTracks[0]];
    }
    RTCVideoTrack *lTrack = [self createLocalVideoTrack];
    if (lTrack) {
        [localStream addVideoTrack:lTrack];
        if (localVideoTrack) {
            [localVideoTrack removeRenderer:self.localView];
            localVideoTrack = nil;
            [self.localView renderFrame:nil];
        }
        localVideoTrack = lTrack;
        if (!isHideCamera) {
            [localVideoTrack addRenderer:self.localView];
        }
        self.localView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        
    }
    for (NSDictionary *dict in arrARDAppClients) {
        [(ARDAppClient *)[dict objectForKey:@"peerCons"] setStreamPeerConnection:localStream];
    }
    
}
- (void)swapCameraToBack{
    
    RTCMediaStream *localStream = mainPeerConnection.localStreams[0];
    if (localStream) {
        [localStream removeVideoTrack:localStream.videoTracks[0]];
    }
    
    RTCVideoTrack *lTrack = [self createLocalVideoTrackBackCamera];
    if (lTrack) {
        [localStream addVideoTrack:lTrack];
        if (localVideoTrack) {
            [localVideoTrack removeRenderer:self.localView];
            localVideoTrack = nil;
            [self.localView renderFrame:nil];
        }
        localVideoTrack = lTrack;
        if (!isHideCamera) {
            [localVideoTrack addRenderer:self.localView];
        }
        self.localView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }
    for (NSDictionary *dict in arrARDAppClients) {
        [(ARDAppClient *)[dict objectForKey:@"peerCons"] setStreamPeerConnection:localStream];
    }
}
- (void)hideCamera{
    
    RTCMediaStream *localStream = mainPeerConnection.localStreams[0];
    [localStream removeVideoTrack:localStream.videoTracks[0]];
    
    RTCVideoTrack *lTrack = [self createLocalVideoTrackBackCamera];
    [localVideoTrack setEnabled:NO];
    if (lTrack) {
        [localStream addVideoTrack:lTrack];
        if (localVideoTrack) {
            [localVideoTrack removeRenderer:self.localView];
            localVideoTrack = nil;
            [self.localView renderFrame:nil];
        }
        localVideoTrack = lTrack;
        if (!isHideCamera) {
            [localVideoTrack addRenderer:self.localView];
        }
        self.localView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    }
    for (NSDictionary *dict in arrARDAppClients) {
        [(ARDAppClient *)[dict objectForKey:@"peerCons"] setStreamPeerConnection:localStream];
    }
}
#pragma mark - enable/disable speaker
- (void)setAudioOutputSpeaker:(BOOL)enabled
{
    AVAudioSession* session = [AVAudioSession sharedInstance];
    
    NSError* error;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    [session setMode:AVAudioSessionModeVoiceChat error:&error];
    if (enabled) // Enable speaker
    {
        [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
        isSpeakerEnabled = YES;
    }
    else // Disable speaker
    {
        [session overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
        isSpeakerEnabled = NO;
    }
    [session setActive:YES error:&error];
}

- (void)enableSpeaker {
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    isSpeakerEnabled = YES;
}

- (void)disableSpeaker {
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    isSpeakerEnabled = NO;
}

- (BOOL)isHeadsetPluggedIn {
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        NSLog(@"Porttype : %@", [desc portType]);
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return NO;
    }
    return YES;
}
- (void)acceptCallingForUser{
    [lblTitle setText:conferenceName];
    btCancelButton.hidden = NO;
    APPDELEGATE.isOwnerForConference = NO;
    APPDELEGATE.isJoinedOnConference = YES;
    [waitingJoinTimer invalidate];
    waitingJoinTimer = nil;
    isFinishedInitialing = NO;
    
    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted) {
                    [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your Camera or Microphone is disabled.\nPlease go to settings and grant access to it."];
                    APPDELEGATE.endTypeForConference = 3;
                    APPDELEGATE.conferenceStatus = 0;
                    [self onExitConference];
                }
                else {
                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                        if (!granted) {
                            [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your Camera or Microphone is disabled.\nPlease go to settings and grant access to it."];
                            APPDELEGATE.endTypeForConference = 3;
                            APPDELEGATE.conferenceStatus = 0;
                            [self onExitConference];
                        }
                        else {
                            [self joinConference];
                        }
                    }];
                }
            });
        }];
    }
}

- (void)movePushNotificationChatViewController:(NSNumber *)boardID isDeletedFriend:(BOOL)isDetetedFriend users:(NSMutableArray *)_lstUsers isDirectory:(NSDictionary *)directoryInfo{
    YYYChatViewController *viewcontroller = [[YYYChatViewController alloc] initWithNibName:@"YYYChatViewController" bundle:nil];
    viewcontroller.isDeletedFriend = isDetetedFriend;
    viewcontroller.boardid = boardID;
    viewcontroller.lstUsers = _lstUsers;
    BOOL isMembersSameDirectory = NO;
    if ([[directoryInfo objectForKey:@"is_group"] boolValue]) {//directory chat for members
        viewcontroller.isDeletedFriend = NO;
        viewcontroller.groupName = [directoryInfo objectForKey:@"board_name"];
        viewcontroller.isMemberForDiectory = YES;
        viewcontroller.isDirectory = YES;
    }else{
        viewcontroller.lstUsers = _lstUsers;
        
        viewcontroller.isDeletedFriend = YES;
        for (NSDictionary *memberDic in directoryInfo[@"members"]) {
            if ([memberDic[@"in_same_directory"] boolValue]) {
                isMembersSameDirectory = YES;
            }
        }
        if (isMembersSameDirectory) {
            viewcontroller.isDeletedFriend = NO;
            viewcontroller.groupName = [directoryInfo objectForKey:@"board_name"];
            viewcontroller.isMemberForDiectory = YES;
            viewcontroller.isDirectory = NO;
        }
    }
    [self.navigationController pushViewController:viewcontroller animated:YES];
}
- (IBAction)onChatText:(id)sender {
    if (boardId && [APPDELEGATE.conferenceMembersForVideoCalling count] > 0) {
        NSString *strIds = @"";
        
        for (NSDictionary *dict in arrMembersOfConference) {
            
            strIds = [NSString stringWithFormat:@"%@,%@",strIds,[dict objectForKey:@"user_id"]];
        }
        
        strIds = [strIds substringFromIndex:1];
        
        [self CreateMessageBoard:strIds];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"You should invite Users." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}
- (void)showChatTextFromPushNotificationAndTap{
    if (boardId && [APPDELEGATE.conferenceMembersForVideoCalling count] > 0) {
        NSString *strIds = @"";
        
        for (NSDictionary *dict in arrMembersOfConference) {
            
            strIds = [NSString stringWithFormat:@"%@,%@",strIds,[dict objectForKey:@"user_id"]];
        }
        
        strIds = [strIds substringFromIndex:1];
        
        [self CreateMessageBoard:strIds];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"You should invite Users." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)showChatTextFromPushNotification:(NSNotification *) notification{
    if (tipView) {
        [self hideChatTipView];
    }
    NSDictionary *userinfo = notification.userInfo;
    
    if ([userinfo objectForKey:@"uid"]) {
        for (NSDictionary *member in APPDELEGATE.conferenceMembersForVideoCalling) {
            if ([[userinfo objectForKey:@"uid"] integerValue] == [[member objectForKey:@"user_id"] integerValue]) {
                if ([member objectForKey:@"photo_url"] && ![[NSString stringWithFormat:@"%@", [member objectForKey:@"photo_url"]] isEqualToString:@""]) {
                    senderChatTextImageView.hidden = NO;
                    [senderChatTextImageView setImageWithURL:[NSURL URLWithString:[member objectForKey:@"photo_url"]]];
                }
            }
        }
    }
    
    RCEasyTipPreferences *preferences = [[RCEasyTipPreferences alloc] initWithDefaultPreferences];
    preferences.drawing.backgroundColor = COLOR_PURPLE_THEME;
    tipView = [[RCEasyTipView alloc] initWithPreferences:preferences];
    tipView.delegate = self;
    NSString *chatText = [[userinfo objectForKey:@"aps"] objectForKey:@"alert"];
    NSArray *arrLineText = [chatText componentsSeparatedByString:@"\n"];
    NSString *lineText = @"";
    if ([arrLineText count] > 20) {
        for (int i = 0; i < 20; i ++) {
            if ([lineText isEqualToString:@""]) {
                lineText = arrLineText[i];
            }else{
                lineText = [NSString stringWithFormat:@"%@\n%@", lineText, arrLineText[i]];
            }
        }
        lineText = [NSString stringWithFormat:@"%@\n...", lineText];
        
        tipView.text = lineText;
    }else{
        tipView.text = chatText;
    }
    [tipView showAnimated:YES forView:btnChatText withinSuperView:nil];
    if (isHiddenChatTipView == YES) {
        isHiddenChatTipView = NO;
        [self performSelector:@selector(hideChatTipView) withObject:nil afterDelay:2];
    }
}
- (void)hideChatTipView{
    isHiddenChatTipView = YES;
    [tipView hideAnimated];
    senderChatTextImageView.hidden = YES;
    tipView = nil;
}

#pragma mark RCEasyTipViewDelegate

- (void)willShowTip:(RCEasyTipView *)tipView{
    
}
- (void)didShowTip:(RCEasyTipView *)tipView{
    
}

- (void)willDismissTip:(RCEasyTipView *)tipView{
    
}
- (void)didDismissTip:(RCEasyTipView *)tipView{
    
}

- (IBAction)onCloseChatView:(UIButton *)sender {
    [textChatView setFrame:CGRectMake(0, 20, 320, 548)];
    [UIView animateWithDuration:0.5
                     animations: ^{
                         // Animate the views on and off the screen. This will appear to slide.
                         textChatView.frame =CGRectMake(0, 568, 320, 548);
                     }
     
                     completion:^(BOOL finished) {
                         if (finished) {
                             [textChatView removeFromSuperview];
                             btCancelButton.hidden = NO;
                             [AppDelegate sharedDelegate].isChatScreen = NO;
                             APPDELEGATE.isPlayingAudio = NO;
                             [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
                             [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
                             [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NEWMESSAGE" object:nil];
                             [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ENTERFROMBACKGROUND" object:nil];
                             [AppDelegate sharedDelegate].currentBoardID = nil;
                         }
                     }];
}

//////////////////////////////////////////////////////////////////////////////
////////////////////// / //// //// /////// /////// / / / / ///////////////////
//////////////////// //////// //// ////// // ///////// ///////////////////////
//////////////////// //////// //// ////// /// //////// ///////////////////////
//////////////////// //////// //// ///// //// //////// ///////////////////////
//////////////////// //////// / // ///// / / / /////// ///////////////////////
//////////////////// //////// //// //// ////// /////// ///////////////////////
//////////////////// //////// //// //// /////// ////// ///////////////////////
///////////////////// /////// //// /// //////// ////// ///////////////////////
////////////////////// / //// //// /// //////// ////// ///////////////////////
//////////////////////////////////////////////////////////////////////////////

-(void)CreateMessageBoard:(NSString*)ids
{
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            NSMutableArray *lstTemp = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in arrMembersOfConference)
            {
                NSMutableDictionary *dictTemp = [[NSMutableDictionary alloc] init];
                
                [dictTemp setObject:[dict objectForKey:@"name"] forKey:@"fname"];
                [dictTemp setObject:@"" forKey:@"lname"];
                [dictTemp setObject:[dict objectForKey:@"photo_url"] forKey:@"photo_url"];
                [dictTemp setObject:[dict objectForKey:@"user_id"] forKey:@"user_id"];
                
                [lstTemp addObject:dictTemp];
            }
            
            //            NSMutableDictionary *dictTemp = [[NSMutableDictionary alloc] init];
            //
            //            [dictTemp setObject:[AppDelegate sharedDelegate].firstName forKey:@"fname"];
            //            [dictTemp setObject:[AppDelegate sharedDelegate].lastName forKey:@"lname"];
            //            [dictTemp setObject:[AppDelegate sharedDelegate].photoUrl forKey:@"photo_url"];
            //            [dictTemp setObject:[AppDelegate sharedDelegate].userId forKey:@"user_id"];
            //
            //            [lstTemp addObject:dictTemp];
            
            [lstUsersForChatting removeAllObjects];
            lstUsersForChatting = lstTemp;
            
            [textChatView setFrame:CGRectMake(0, 568, 320, 548)];
            [self.view addSubview:textChatView];
            
            [self initForChattingOnConference];
            
            [UIView animateWithDuration:0.5
                             animations: ^{
                                 // Animate the views on and off the screen. This will appear to slide.
                                 textChatView.frame =CGRectMake(0, 20, 320, 548);
                             }
             
                             completion:^(BOOL finished) {
                                 if (finished) {
                                     btCancelButton.hidden = YES;
                                     [AppDelegate sharedDelegate].isChatScreen = YES;
                                     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
                                     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
                                     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessage:) name:@"NEWMESSAGE" object:nil];
                                     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground) name:@"ENTERFROMBACKGROUND" object:nil];
                                 }
                             }];
            
        }else{
            [self showAlert:[[_responseObject objectForKey:@"err"] objectForKey:@"errMsg"]];
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ self  showAlert: @"Internet Connection Error!" ] ;
    } ;
    [[YYYCommunication sharedManager] CreateChatBoard:[AppDelegate sharedDelegate].sessionId userids:ids successed:successed failure:failure];
}


- (void)initForChattingOnConference{
    bFirstLoad = YES;
    lstMsgId = [NSMutableArray new];
    isShownBoard = YES;
    getNewmessage = NO;
    tmpTextMessage = @"";
    
    bubbleData = [NSMutableArray new];
    bubbleTable.bubbleDataSource = self;
    bubbleTable.snapInterval = 120;
    bubbleTable.showAvatars = YES;
    bubbleTable.bubbledelegate = self;
    
    [vwEmoItem setHidden:YES];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    [bubbleTable addGestureRecognizer:tapGesture];
    
    //Read Emoji
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"EmojisList"
                                                          ofType:@"plist"];
    emojis = [[NSDictionary dictionaryWithContentsOfFile:plistPath] copy];
    voiceCallEmoji = [[emojis objectForKey:@"Objects"] objectAtIndex:32];
    videoCallEmoji = [[emojis objectForKey:@"Objects"] objectAtIndex:23];
    [self makeEmoji:0];
    
    __weak VideoVoiceConferenceViewController *weakSelf = self;
    
    // setup pull-to-refresh
    [bubbleTable addPullToRefreshWithActionHandler:^{
        if (!isLoadingMessages)
            [weakSelf GetMessageHistory];
    }];
    
    isLoadingMessages = NO;
    if (!isLoadingNewMessages)
        // get messages later than the last recent message
        [self loopLoadNewMessages];
    
    [AppDelegate sharedDelegate].currentBoardID = boardIdNum;
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
    
    [scvEmoji setContentSize:CGSizeMake(320 * nPageCount, scvEmoji.frame.size.height-45)];
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
    [self.view endEditing:YES];
    
    if (!vwEmoItem.hidden)
    {
        [vwEmoItem setHidden:YES];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationCurve:7];
        
        keyboardHeight.constant = -45;
        [self.view layoutIfNeeded];
        
        [UIView commitAnimations];
    }
}
- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        btSend.enabled = NO;
        tmpTextMessage = @"";
    }else{
        btSend.enabled = YES;
    }
    [vwEmoItem setHidden:YES];
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

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    if ([txtMessage.text isEqualToString:@""]) {
        btSend.enabled = NO;
        tmpTextMessage = @"";
    }else{
        btSend.enabled = YES;
    }
    NSDictionary* userInfo = [aNotification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    if(!keyboardShown)
    {
        CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:duration];
        [UIView setAnimationCurve:[userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    }
    
    keyboardHeight.constant = kbSize.height-45;
    [self.view layoutIfNeeded];
    
    if(!keyboardShown)
        [UIView commitAnimations];
    
    keyboardShown = YES;
    
    [self scrollToBottom : FALSE];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    keyboardShown = NO;
    NSDictionary *userInfo = [aNotification userInfo];
    CGFloat duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:[userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    keyboardHeight.constant = -45;
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
-(IBAction)btEmoticonClick:(id)sender
{
    if (!vwEmoItem.hidden) {
        return;
    }
    
    [txtMessage resignFirstResponder];
    
    [vwEmoItem setHidden:NO];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationCurve:7];
    
    keyboardHeight.constant = 216-45;
    [self.view layoutIfNeeded];
    
    [self scrollToBottom : NO];
    
    [UIView commitAnimations];
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
            
            for (NSDictionary *user in lstUsersForChatting)
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
    
    NSArray *messages = [[LocalDBManager sharedManager] getMessagesEarlierThan:oldestDate boardId:boardIdNum count:10];
    // the operator is less than or equal, so we need to handle equal case
    if (messages.count == 0 || messages.count < 10 || [self allMessagesExistInBubbleData:messages]) { // no local messages, need to load from api
        
        isLoadingMessages = YES;
        
        void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
            [bubbleTable.pullToRefreshView stopAnimating];
            
            if ([[_responseObject objectForKey:@"success"] boolValue])
            {
                [[LocalDBManager sharedManager] saveMessagesToLocalDB:_responseObject[@"data"] boardId:[NSNumber numberWithInteger:[boardId integerValue]]];
                
                @synchronized(bubbleData) {
                    [self addMessagesToDataSource:_responseObject[@"data"] atFirst:NO];
                }
                
                //Read Message
                NSString *strMsgIds = [lstMsgId componentsJoinedByString:@","];
                
                if ([lstMsgId count]) {
                    [[YYYCommunication sharedManager] ReadMessage:[AppDelegate sharedDelegate].sessionId board_id:boardIdNum msg_ids:strMsgIds successed:nil failure:nil];
                }
                //
                [bubbleTable reloadData];
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
            [[YYYCommunication sharedManager] GetMessageHistory:[AppDelegate sharedDelegate].sessionId boardid:boardIdNum number:@"10" lastdays:@"0" earlierThan:oldestDate laterThan:nil successed:successed failure:failure];
        else
            // load last 40 messages
            [[YYYCommunication sharedManager] GetMessageHistory:[AppDelegate sharedDelegate].sessionId boardid:boardIdNum number:@"10" lastdays:@"0" earlierThan:nil laterThan:nil successed:successed failure:failure];
        
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

- (void)loopLoadNewMessages {
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (isShownBoard == YES) {
        [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeClear];
    }
    isLoadingNewMessages = YES;
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            
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
            
            [[LocalDBManager sharedManager] saveMessagesToLocalDB:_responseObject[@"data"] boardId:[NSNumber numberWithInteger:[boardId integerValue]]];
            
            @synchronized(bubbleData) {
                [self addMessagesToDataSource:_responseObject[@"data"] atFirst:YES];
            }
            
            //Read Message
            NSString *strMsgIds = [lstMsgId componentsJoinedByString:@","];
            
            if ([lstMsgId count]) {
                [[YYYCommunication sharedManager] ReadMessage:[AppDelegate sharedDelegate].sessionId board_id:boardIdNum msg_ids:strMsgIds successed:nil failure:nil];
            }
            //
            
            
            
            // continue loading messages
            [self loopLoadNewMessages];
            
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
        [[YYYCommunication sharedManager] GetMessageHistory:[AppDelegate sharedDelegate].sessionId boardid:boardIdNum number:@"40" lastdays:@"0" earlierThan:nil laterThan:newestDate successed:successed failure:failure];
    else
        // load
        [[YYYCommunication sharedManager] GetMessageHistory:[AppDelegate sharedDelegate].sessionId boardid:boardIdNum number:@"40" lastdays:@"0" earlierThan:nil laterThan:nil successed:successed failure:failure];
}

-(void)newMessage : (NSNotification*) _notification
{
    NSArray *lstMessage = [_notification.userInfo objectForKey:@"data"];
    for (NSDictionary *dict in lstMessage)
    {
        if ([[NSString stringWithFormat:@"%@",[dict objectForKey:@"board_id"]] isEqualToString:[NSString stringWithFormat:@"%@",boardId]])
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
                
                [[LocalDBManager sharedManager] addBubbleData:sayBubble boardId:boardIdNum];
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
                
                [[LocalDBManager sharedManager] addBubbleData:sayBubble boardId:boardIdNum];
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
    
    
    [btSend setUserInteractionEnabled:NO];
    [[YYYCommunication sharedManager] SendMessage:[AppDelegate sharedDelegate].sessionId board_id:boardIdNum message:text successed:successed failure:failure];
    
}
#pragma mark - NSBubbleDataDelegate
-(void)mapTouched:(float)latitude :(float)longitude
{
    
    APPDELEGATE.isShownChattingScreenWithMapVideo = YES;
    APPDELEGATE.isPlayingAudio = NO;
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
-(void)videoTouched:(NSString *)videoPath {
    
    [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"You can't play a video while calling."];
    return;
    
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
-(void)profileAction:(NSString *)userid
{
    //        if (self.isDeletedFriend) {
    //            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"GINKO" message:@"Sorry, the selection is no longer a contact." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    //            [alertView show];
    //            return;
    //        }
    //        [self.view endEditing:YES];
    //    [self.navigationItem setRightBarButtonItem:btContact];
    [self getContactDetail:userid];
}
- (void)playVideoAtLocalPath:(NSString *)videoPath {
    playerVC = [[MPMoviePlayerViewController alloc] init];
    
    playerVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    playerVC.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
    playerVC.moviePlayer.contentURL = [NSURL fileURLWithPath:videoPath];
    
    [self presentMoviePlayerViewControllerAnimated:playerVC];
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
            vc.isFromVideoChat = YES;
            
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
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        switch (longPressedDataType) {
            case NSBubbleContentTypeVideo:
            {
                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"You can't play a video while calling."];
                
                // Check cache first
                //                NSString *cachedPath = [LocalDBManager checkCachedFileExist:longPressedDataPath];
                //
                //                if (cachedPath) {
                //                    // load from cache
                //                    [self shareWithPath:cachedPath];
                //                } else {
                //                    // save to temp directory
                //                    NSURL *url = [NSURL URLWithString:longPressedDataPath];
                //                    NSURLRequest *request = [NSURLRequest requestWithURL:url];
                //                    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
                //                    NSProgress *progress;
                //
                //                    downloadProgressHUD = [MBProgressHUD showHUDAddedTo:[AppDelegate sharedDelegate].window animated:YES];
                //                    downloadProgressHUD.mode = MBProgressHUDModeDeterminate;
                //
                //                    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                //                        return [NSURL fileURLWithPath:[LocalDBManager getCachedFileNameFromRemotePath:longPressedDataPath]];
                //                    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                //                        [progress removeObserver:self forKeyPath:@"fractionCompleted" context:NULL];
                //                        [downloadProgressHUD hide:YES];
                //                        if (!error) {
                //                            [self shareWithPath:[LocalDBManager getCachedFileNameFromRemotePath:longPressedDataPath]];
                //                        } else {
                //                            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not download video, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                //                        }
                //                    }];
                //
                //                    [downloadTask resume];
                //                    [progress addObserver:self
                //                               forKeyPath:@"fractionCompleted"
                //                                  options:NSKeyValueObservingOptionNew
                //                                  context:NULL];
                //
                //                    //        data = [NSData dataWithContentsOfURL:[NSURL URLWithString:audioUrl]];
                //                    //        [data writeToFile:[LocalDBManager getCachedFileNameFromRemotePath:audioUrl] atomically:YES];
                //                }
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
- (void)shareWithPath:(NSString *)videoPath {
    NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
    NSArray* dataToShare = @[SHARE_MAIL_TEXT, videoURL];
    UIActivityViewController* activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:dataToShare
                                      applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:nil];
}
-(IBAction)btPhotoDoneClick:(id)sender
{
    [imvPhoto setImage:nil];
    [vwPhoto removeFromSuperview];
}
@end
