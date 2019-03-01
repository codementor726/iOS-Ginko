//
//  VideoEditController.h
//  Xchangewithme
//
//  Created by Xin YingTai on 21/5/14.
//  Copyright (c) 2014 Xin YingTai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoEditController : UIViewController
{
    IBOutlet UIButton *btnForDelete;
    IBOutlet UIButton *btnForApply;
    
    IBOutlet UIView *viewForVideo;
    IBOutlet UIView *viewForRange;
    IBOutlet UIImageView *imgForTick;
    IBOutlet UIView *viewForFilter;
    IBOutlet UIButton *btnForPlay;
}

@property (nonatomic, strong) NSURL *videoURL;
- (void)pauseVideoWhenSleepMode;
@end
