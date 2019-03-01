//
//  NSBubbleVideoPlayer.h
//  InstantMessenger
//
//  Created by Wang MeiHua on 3/1/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol NSBubbleVideoDelegate <NSObject>

- (void)videoTouched:(NSString*)videoPath;
- (void)videoLongPressed:(NSString *)videoPath;

@end

@interface NSBubbleVideoPlayer : UIView
{
	IBOutlet UIImageView *imvThumb;
	NSString *videoUrl;
	IBOutlet UIButton *btPlay;
	IBOutlet UIView *vwPlay;
	IBOutlet UIProgressView *prgVideo;
	IBOutlet UIButton *btStop;
	NSTimer *timer;
}
+ (id)customView;
-(void)initWithUrl:(NSString*)url thumb:(NSString*)thumburl;
- (void)setImageFrame:(CGRect)frame;

-(IBAction)btPlayClick:(id)sender;
-(IBAction)btStopClick:(id)sender;

@property (nonatomic,retain) id<NSBubbleVideoDelegate> delegate;
@property (nonatomic) AVPlayer *player;
@property (nonatomic) AVPlayerLayer *layer;
@end
