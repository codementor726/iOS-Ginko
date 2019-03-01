//
//  IMVideoCameraController.h
//  Xchangewithme
//
//  Created by Xin YingTai on 21/5/14.
//  Copyright (c) 2014 Xin YingTai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>


#import "FilterView.h"
#import "GPUImage.h"
#import "EZAudioFile.h"
#import "EZAudioPlot.h"

#import "MBProgressHUD.h"

@class RecordingProgressBarView;
@class EZAudioPlot;

@interface IMVideoCameraController : UIViewController
{
    IBOutlet UIButton *btnForApply;
    
    IBOutlet UIView *viewForVideo;
    IBOutlet UIImageView *imgForGhost;
    IBOutlet UIImageView *imgForGrid;    
    IBOutlet UIImageView *imgForFocus;
    
    IBOutlet RecordingProgressBarView *viewForProgress;
    IBOutlet UIButton *btnForCut;
    
    IBOutlet UIView *viewForAudio;
    IBOutlet UIScrollView *viewForScroll;
    IBOutlet EZAudioPlot *viewForWave;
    IBOutlet UIImageView *imgForTicker;
    
    IBOutlet UIView *viewForTool;
    IBOutlet UIButton *btnForGrid;
    IBOutlet UIButton *btnForFlip;
    IBOutlet UIButton *btnForFlash;
    IBOutlet UIButton *btnForMicrophone;
    IBOutlet UIButton *btnForFocus;
    IBOutlet UIButton *btnForGhost;
    
    IBOutlet UIView *viewForMusic;
    IBOutlet UIButton *btnForMusic;
    
    __weak IBOutlet UILabel *lblWayForRecording;
    IBOutlet UIView *viewForFilter;
}

- (void)pauseVideoWhenSleepMode;
- (void)movePushNotificationChatViewController:(NSNumber *)boardID isDeletedFriend:(BOOL)isDetetedFriend users:(NSMutableArray *)lstUsers isDirectory:(NSDictionary *)directoryInfo;
- (void)movePushNotificationConferenceViewController:(NSDictionary *)dic;

@property (strong, nonatomic) GPUImageView *imageView;

@end
