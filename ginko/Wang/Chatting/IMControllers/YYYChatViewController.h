//
//  YYYChatViewController.h
//  InstantMessenger
//
//  Created by Wang MeiHua on 2/28/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYYSelectContactController.h"
#import "UIBubbleTableViewDataSource.h"
#import <MapKit/MapKit.h>
#import <AVFoundation/AVFoundation.h>
#import "NSBubbleData.h"
#import "UIBubbleTableView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "Reachability.h"
@interface YYYChatViewController : UIViewController<UIBubbleTableViewDataSource,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIScrollViewDelegate,UIAlertViewDelegate,AVAudioRecorderDelegate,NSBubbleDataDelegate,BubbleTableDelegate>
{
	AVAudioRecorder *recorder;
	
	UIBarButtonItem *btBack;
	UIBarButtonItem *btClose;
    UIBarButtonItem *btCloseKeyboard;
	UIBarButtonItem *btContact;
	UIBarButtonItem *btCloseEdit;
	UIBarButtonItem *btClear;
    
    UIBarButtonItem *btVideoCalling;
    UIBarButtonItem *btVoiceCalling;
	
	IBOutlet UIButton *btEmoji1;
	IBOutlet UIButton *btEmoji2;
	IBOutlet UIButton *btEmoji3;
	IBOutlet UIButton *btEmoji4;
	
	IBOutlet UIView *vwEmoticon;
	
	IBOutlet UIButton			*btMap;
	IBOutlet UIButton			*btVideo;
	IBOutlet UIButton			*btPhoto;
	IBOutlet UIButton			*btEmoticon;
	IBOutlet UIButton			*btWrite;
	IBOutlet UIButton			*btSend;
	IBOutlet UIButton			*btVoice;
    IBOutlet UITextView *txtMessage;
    
	IBOutlet UIButton			*btRecording;
	IBOutlet UIButton			*btMask;
    IBOutlet UIButton           *btDelete;
    
	IBOutlet UIScrollView		*scvEmoji;
	IBOutlet UIView				*vwSend;
	IBOutlet UIView				*vwEmoItem;
	IBOutlet UIView				*vwTrash;
    
    __weak IBOutlet NSLayoutConstraint *keyboardHeight;
    
    __weak IBOutlet NSLayoutConstraint *messageHeight;
	
	IBOutlet UIBubbleTableView *bubbleTable;
	NSMutableArray *bubbleData;
	
	NSTimer *timer;
	int nVoiceSec;
	
	NSURL *audioURL;
	
	BOOL isVideo;
	IBOutlet UIPageControl *pgCtl;
	
	NSMutableArray *lstMsgId;
	
	UILabel *lblTitle;
	NSData *thumbnail;
	
	BOOL bFirstLoad;
	BOOL bConnection;
	
	UIView *vwPhoto;
	UIImageView *imvPhoto;
    
}

-(IBAction)btPhotoDoneClick:(id)sender;
-(void)sendMap:(float)flat :(float)flng;

-(IBAction)btEmoji1Click:(id)sender;
-(IBAction)btEmoji2Click:(id)sender;
-(IBAction)btEmoji3Click:(id)sender;
-(IBAction)btEmoji4Click:(id)sender;

-(IBAction)btMapClick:(id)sender;
-(IBAction)btVideoClick:(id)sender;
-(IBAction)btPhotoClick:(id)sender;
-(IBAction)btEmoticonClick:(id)sender;
-(IBAction)btWriteClick:(id)sender;
-(IBAction)btSendClick:(id)sender;

-(IBAction)btVoiceStart:(id)sender;
-(IBAction)btVoiceSend:(id)sender;
-(IBAction)btVoiceCancel:(id)sender;
- (IBAction)btVoiceTouchCancel:(id)sender;
- (void)setPhoneNumbers:(NSDictionary*)dic;

@property (nonatomic, retain) NSDictionary *emojis;
@property (nonatomic, retain) NSNumber *boardid;

@property (nonatomic, retain) NSDictionary *fromHistoryGroupDic;
@property BOOL isDeletedFriend;

@property BOOL isPushedFromConference;
@property BOOL isAbleVideoConference;

@property (nonatomic, retain) NSMutableArray *lstUsers;
@property (nonatomic, retain) NSMutableArray *conferencelstUsers;
@property (nonatomic, retain) NSString *groupName;
@property (nonatomic, assign) BOOL navBarColor;
@property (nonatomic, assign) BOOL isMemberForDiectory;
@property (nonatomic, assign) BOOL isDirectory;
@property (nonatomic, assign) BOOL isFromChatHistory;

@property (nonatomic, retain) MPMoviePlayerViewController *playerVC;

@property (nonatomic) Reachability *reachability;

@property (nonatomic, retain) NSMutableArray *availableUsers;

- (void)receviedMessage;
- (void)getSelectedItems: (NSString*)itemIds callType:(NSInteger)type;
-(void)makeVideoAndVoiceCall:(NSMutableArray*)usersList callType: (NSInteger)type;
@end
