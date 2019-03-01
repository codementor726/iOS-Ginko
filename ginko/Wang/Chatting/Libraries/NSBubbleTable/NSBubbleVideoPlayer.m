//
//  NSBubbleVideoPlayer.m
//  InstantMessenger
//
//  Created by Wang MeiHua on 3/1/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import "NSBubbleVideoPlayer.h"
#import "UIImageView+AFNetworking.h"
#import "LocalDBManager.h"

@implementation NSBubbleVideoPlayer

@synthesize player;
@synthesize layer;
@synthesize delegate;

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
    NSBubbleVideoPlayer *customView = [[[NSBundle mainBundle] loadNibNamed:@"NSBubbleVideoPlayer" owner:nil options:nil] lastObject];
    
    // make sure customView is not nil or the wrong class!
    if ([customView isKindOfClass:[NSBubbleVideoPlayer class]])
        return customView;
    else
        return nil;
}

-(void)initWithUrl:(NSString*)url thumb:(NSString*)thumburl
{
//	videoUrl = url;
//	prgVideo.progress = 0;url	__NSCFString *	
//	
//	if (self.player)
//    {
//        [layer removeFromSuperlayer];
//        layer = nil;
//    }
//    
//    self.player = [AVPlayer playerWithURL:[NSURL URLWithString:videoUrl]];
//    layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
//    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
//    layer.frame = CGRectMake(0, 0, 230, 230);
//    [vwPlay.layer addSublayer: layer];
//	
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachedEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.player currentItem]];
//
	imvThumb.userInteractionEnabled = YES;
    
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
	[imvThumb addGestureRecognizer:tapGesture];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [imvThumb addGestureRecognizer:longPress];
//
//	[btPlay setHidden:YES];
	
	videoUrl = url;
    if (!thumburl || [thumburl isEqualToString:@""]) {
        
    } else {
        // Check cache first
        NSString *cachedPath = [LocalDBManager checkCachedFileExist:thumburl];
        
        if (cachedPath) {
            // load from cache
            UIImage *img = [UIImage imageWithContentsOfFile:cachedPath];
            [imvThumb setImage:img];
        } else {
            // save to temp directory
            __weak UIImageView *weakImageView = imvThumb;
            [imvThumb setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:thumburl]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                weakImageView.image = image;
                [UIImageJPEGRepresentation(image, 1.0) writeToFile:[LocalDBManager getCachedFileNameFromRemotePath:thumburl] atomically:YES];
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                
            }];
        }
    }

//	imvThumb.transform = CGAffineTransformMakeRotation(3.14/2);
}

- (void)setImageFrame:(CGRect)frame
{
    imvThumb.frame = frame;
}

-(void)handleTap
{
	[delegate videoTouched:videoUrl];
}

- (void)longPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan)
        [delegate videoLongPressed:videoUrl];
}

-(void)playerItemDidReachedEnd:(NSNotification*)_notification
{
	prgVideo.progress = 0;
//	[btPlay setHidden:NO];
//	[btStop setHidden:YES];
	
	[self.player seekToTime:CMTimeMakeWithSeconds(0 , 1)];
//	[self.player pause];
//	[timer invalidate];
}

-(IBAction)btPlayClick:(id)sender
{
	[self.player play];
    [btPlay setHidden:YES];
	[btStop setHidden:NO];
	
	timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timer:) userInfo:nil repeats:YES];
}

-(IBAction)btStopClick:(id)sender
{
	[self.player pause];
	[btStop setHidden:YES];
	[btPlay setHidden:NO];
}

-(void)timer:(NSTimer*)timer
{
	float total =  CMTimeGetSeconds(self.player.currentItem.asset.duration);
	float current = CMTimeGetSeconds(self.player.currentTime);
	
	prgVideo.progress = current/total;
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
