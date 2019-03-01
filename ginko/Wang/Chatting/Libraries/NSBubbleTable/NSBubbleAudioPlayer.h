//
//  NSBubbleAudioPlayer.h
//  InstantMessenger
//
//  Created by Wang MeiHua on 3/1/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface NSBubbleAudioPlayer : UIView <AVAudioPlayerDelegate>
{
	NSString *audioUrl;
	
	NSTimer *timerForAudio;
}
+ (id)customView;
-(void)initWithUrl:(NSString*)url;

@property (weak, nonatomic) IBOutlet UIButton *btPlay;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingProgress;
@property (nonatomic, weak) IBOutlet UIProgressView *prgAudio;

-(IBAction)btPlayClick:(id)sender;

//@property (nonatomic,retain) AVPlayer *player;
@property (nonatomic,retain) AVAudioPlayer *player;
@end
