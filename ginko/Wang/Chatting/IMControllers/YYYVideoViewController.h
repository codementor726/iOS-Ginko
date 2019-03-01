//
//  YYYVideoViewController.h
//  InstantMessenger
//
//  Created by Wang MeiHua on 4/7/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

@interface YYYVideoViewController : UIViewController

@property (nonatomic,retain) NSString *strUrl;
@property (nonatomic,retain) MPMoviePlayerController *player;
@end
