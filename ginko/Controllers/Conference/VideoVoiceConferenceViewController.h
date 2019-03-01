//
//  VideoVoiceConferenceViewController.h
//  ginko
//
//  Created by stepanekdavid on 2/17/17.
//  Copyright © 2017 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <libjingle_peerconnection/RTCEAGLVideoView.h>
#import <libjingle_peerconnection/RTCVideoTrack.h>
#import "ARDAppClient.h"

#import "UIBubbleTableViewDataSource.h"
#import <MapKit/MapKit.h>
#import <AVFoundation/AVFoundation.h>
#import "NSBubbleData.h"
#import "UIBubbleTableView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "Reachability.h"
#import "VideoEncode.h"
@interface VideoVoiceConferenceViewController : UIViewController<ARDAppClientDelegate, RTCEAGLVideoViewDelegate, UIBubbleTableViewDataSource,UITextViewDelegate,UIScrollViewDelegate,UIAlertViewDelegate,NSBubbleDataDelegate,BubbleTableDelegate>{
    
    //video calling tools
    __weak IBOutlet UIButton *btnCameraType;
    __weak IBOutlet UIButton *btnCameraStatus;
    __weak IBOutlet UIButton *btnMicStatus;
    __weak IBOutlet UIButton *btnChatText;
    __weak IBOutlet UIButton *speakerBtn;
    __weak IBOutlet UIImageView *speakerProgressImg;
    
    __weak IBOutlet UIImageView *imgVoiceMute;
    __weak IBOutlet UIImageView *imgVideoMute;
    __weak IBOutlet UIImageView *imgOnlyVoice;
    
    
    __weak IBOutlet UICollectionView *RemoteCollectionView;
    
    __weak IBOutlet UIView *localViewMask;
    __weak IBOutlet UIView *conferenceToolView;
    __weak IBOutlet UIView *maskToolView;
    
    
    __weak IBOutlet UIButton *btCancelButton;
    __weak IBOutlet UILabel *lblTitle;
    
    __weak IBOutlet UIView *loadingMaskView;
    //less ios 10.0
    __weak IBOutlet UIView *incomingCallView;
    __weak IBOutlet UILabel *lblInitialer;
    
    
    __weak IBOutlet UIView *membersCoverView;
    //member view
    IBOutlet UIView *ownerView;
    
    
    
    //chatting
    IBOutlet UIView *textChatView;
    
    IBOutlet UIButton *btEmoji1;
    IBOutlet UIButton *btEmoji2;
    IBOutlet UIButton *btEmoji3;
    IBOutlet UIButton *btEmoji4;
    
    IBOutlet UIView *vwEmoticon;
    
    IBOutlet UIButton			*btEmoticon;
    IBOutlet UIButton			*btSend;
    
    IBOutlet UITextView *txtMessage;
    
    IBOutlet UIScrollView		*scvEmoji;
    IBOutlet UIView				*vwSend;
    IBOutlet UIView				*vwEmoItem;
    
    __weak IBOutlet NSLayoutConstraint *keyboardHeight;
    
    __weak IBOutlet NSLayoutConstraint *messageHeight;
    
    IBOutlet UIBubbleTableView *bubbleTable;
    NSMutableArray *bubbleData;
    
    IBOutlet UIPageControl *pgCtl;
    
    NSMutableArray *lstMsgId;

    BOOL bFirstLoad;
    BOOL bConnection;
    
    NSMutableArray *lstUsersForChatting;
    
    UIView *vwPhoto;
    UIImageView *imvPhoto;
    
    __weak IBOutlet UIImageView *senderChatTextImageView;
}
@property (strong, nonatomic) NSDictionary *infoCalling;

@property (strong, nonatomic) IBOutlet RTCEAGLVideoView *localView;
@property (weak, nonatomic) IBOutlet RTCEAGLVideoView *soleLocalView;

@property (strong, nonatomic) NSString *boardId;
@property (strong, nonatomic) NSNumber *boardIdNum;
@property NSInteger conferenceType;
@property (strong, nonatomic) NSString *conferenceName;
//togle button parameter
@property (assign, nonatomic) BOOL isAudioMute;
@property (assign, nonatomic) BOOL isVideoMute;
@property (assign, nonatomic) BOOL removeInviteNotification;


- (IBAction)onChatText:(id)sender;
- (IBAction)onInviteUser:(id)sender;
- (IBAction)onCameraTypeChange:(id)sender;
- (IBAction)onChangeCamraStatus:(id)sender;
- (IBAction)onChangeMicStatus:(id)sender;
- (IBAction)onChangeSpeakerMode:(UIButton *)sender;

- (IBAction)onCloseConferenceClick:(UIButton *)sender;


- (void)senddingOfferToInvitionMembers;
- (void)openConferenceFromMenu;

- (void)movePushNotificationChatViewController:(NSNumber *)boardID isDeletedFriend:(BOOL)isDetetedFriend users:(NSMutableArray *)lstUsers isDirectory:(NSDictionary *)directoryInfo;

//less ios 10.0
- (IBAction)onAcceptCalling:(id)sender;
- (IBAction)onCancelCalling:(id)sender;

- (void)initConferenceFromMenu;
- (void)closeFromCallScreen;


//chatting

- (IBAction)onCloseChatView:(UIButton *)sender;

-(IBAction)btEmoji1Click:(id)sender;
-(IBAction)btEmoji2Click:(id)sender;
-(IBAction)btEmoji3Click:(id)sender;
-(IBAction)btEmoji4Click:(id)sender;

-(IBAction)btEmoticonClick:(id)sender;
-(IBAction)btSendClick:(id)sender;

@property (nonatomic, retain) NSDictionary *emojis;
@property (nonatomic) Reachability *reachability;
@property (nonatomic, retain) MPMoviePlayerViewController *playerVC;
@end
