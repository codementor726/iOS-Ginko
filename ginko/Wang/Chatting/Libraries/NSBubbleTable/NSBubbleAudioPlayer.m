//
//  NSBubbleAudioPlayer.m
//  InstantMessenger
//
//  Created by Wang MeiHua on 3/1/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import "NSBubbleAudioPlayer.h"
#import "LocalDBManager.h"

@implementation NSBubbleAudioPlayer

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (id)customView
{
    NSBubbleAudioPlayer *customView = [[[NSBundle mainBundle] loadNibNamed:@"NSBubbleAudioPlayer" owner:nil options:nil] lastObject];
    
    // make sure customView is not nil or the wrong class!
    if ([customView isKindOfClass:[NSBubbleAudioPlayer class]]) {
        customView.btPlay.hidden = YES;
        return customView;
    }
    else
        return nil;
}

-(void)initWithUrl:(NSString*)url
{
	audioUrl = url;
//    audioUrl = @"http://www.xchangewith.me/api/v2/im_upload/voice_0.aac";
//    audioUrl = @"http://www.xchangewith.me/api/v2/im_upload/2015-05-22-05-31-13987.aac";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;

        // Check cache first
        NSString *cachedPath = [LocalDBManager checkCachedFileExist:audioUrl];

        NSData *data;
        if (cachedPath) {
            // load from cache
            data = [NSData dataWithContentsOfFile:cachedPath];
        } else {
            // save to temp directory
            data = [NSData dataWithContentsOfURL:[NSURL URLWithString:audioUrl]];
            [data writeToFile:[LocalDBManager getCachedFileNameFromRemotePath:audioUrl] atomically:YES];
        }
        
        self.player = [[AVAudioPlayer alloc] initWithData:data error:&error];
        if(error) {
            NSLog(@"Error: %@", error);
        }
        
        [_player setDelegate:self];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_loadingProgress stopAnimating];
            [_btPlay setHidden:NO];
        });
    });
    
//	self.player = [[AVPlayer alloc] init];
//	AVPlayerItem * currentItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:audioUrl]];
//	AVPlayerItem * currentItem = [AVPlayerItem playerItemWithURL:uurl];
//	[self.player replaceCurrentItemWithPlayerItem:currentItem];
	
//	prgAudio.progress = 0;
	
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachedEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.player currentItem]];

    _prgAudio.progress = 0;
}

//-(void)playerItemDidReachedEnd:(NSNotification*)_notification
//{
//	[btPlay setSelected:NO];
//	prgAudio.progress = 0;
//	[self.player seekToTime:CMTimeMakeWithSeconds(0 , 1)];
//	[self.player pause];
//	[timer invalidate];
//}

#pragma mark - AVAudioPlayer Delegate
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [_btPlay setSelected:NO];
    
    APPDELEGATE.isPlayingAudio = NO;
    _prgAudio.progress = 0;
    [self.player stop];
    [timerForAudio invalidate];
}

-(IBAction)btPlayClick:(id)sender
{
    if (APPDELEGATE.isConferenceView) {
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"You can't play a voice while calling."];
        return;
    }
//	if (btPlay.selected)
    if (APPDELEGATE.isPlayingAudio && !_btPlay.selected) {
        APPDELEGATE.isPlayingAudio = NO;
        [self performSelector:@selector(playOneAudio) withObject:nil afterDelay:0.1];
    }else{
        if (_player.isPlaying)
        {
            [self.player stop];
            [_btPlay setSelected:NO];
            [timerForAudio invalidate];
        }
        else
        {
            APPDELEGATE.isPlayingAudio = YES;
            [self.player prepareToPlay];
            [self.player play];
            [_btPlay setSelected:YES];
            timerForAudio = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(timer:) userInfo:nil repeats:YES];
        }

    }
}
- (void)playOneAudio{
    APPDELEGATE.isPlayingAudio = YES;
    [self.player prepareToPlay];
    [self.player play];
    [_btPlay setSelected:YES];
    timerForAudio = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(timer:) userInfo:nil repeats:YES];
}
-(void)timer:(NSTimer*)timer
{
/*	float total =  CMTimeGetSeconds(self.player.currentItem.asset.duration);
	float current = CMTimeGetSeconds(self.player.currentTime);
 */
    float total =  self.player.duration;
    float current = self.player.currentTime;
    NSLog(@"progress.....");
	_prgAudio.progress = current/total;
    
    if (APPDELEGATE.isPlayingAudio == NO) {
        [self.player stop];
        [_btPlay setSelected:NO];
        [timerForAudio invalidate];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
