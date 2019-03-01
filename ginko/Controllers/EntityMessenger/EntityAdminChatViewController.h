//
//  EntityAdminChatViewController.h
//  GINKO
//
//  Created by mobidev on 7/24/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
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

@interface EntityAdminChatViewController : UIViewController<UIBubbleTableViewDataSource, UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIScrollViewDelegate,UIAlertViewDelegate,AVAudioRecorderDelegate,NSBubbleDataDelegate,BubbleTableDelegate>
{
	AVAudioRecorder *recorder;
	
	UIBarButtonItem *btBack;
	UIBarButtonItem *btClose;
    UIBarButtonItem *btCloseKeyboard;
	UIBarButtonItem *btContact;
	UIBarButtonItem *btCloseEdit;
	UIBarButtonItem *btClear;
	
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

    __weak IBOutlet UITextView *txtMessage;
    __weak IBOutlet NSLayoutConstraint *keyboardHeight;
    __weak IBOutlet NSLayoutConstraint *messageHeight;
    
	IBOutlet UIButton			*btRecording;
	
	IBOutlet UIScrollView		*scvEmoji;
	IBOutlet UIView				*vwSend;
	IBOutlet UIView				*vwEmoItem;
	IBOutlet UIView				*vwTrash;
	
	IBOutlet UIBubbleTableView *bubbleTable;
	NSMutableArray *bubbleData;
	
	NSTimer *timer;
	int nVoiceSec;
	
	NSURL *audioURL;
	
	BOOL isVideo;
	IBOutlet UIPageControl *pgCtl;
	
	NSMutableArray *lstMsgId;
	
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

@property (nonatomic, retain) NSDictionary *emojis;
@property (nonatomic, retain) NSString *boardid;

@property (nonatomic, retain) MPMoviePlayerViewController *playerVC;

@property (nonatomic) Reachability *reachability;
@property (nonatomic, assign) BOOL navBarColor;
@property (nonatomic, retain) NSString *entityID;
@property (nonatomic, retain) NSString *entityName;
@end
