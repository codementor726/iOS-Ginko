//
//  IMVideoEditController.h
//  Xchangewithme
//
//  Created by Xin YingTai on 21/5/14.
//  Copyright (c) 2014 Xin YingTai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMVideoEditController : UIViewController
{
    IBOutlet UIButton *btnForDelete;
    IBOutlet UIButton *btnForApply;
    
    IBOutlet UIView *viewForVideo;
    IBOutlet UIView *viewForRange;
    IBOutlet UIImageView *imgForTick;
    IBOutlet UIView *viewForFilter;
    IBOutlet UIButton *btnForPlay;
    __weak IBOutlet UIView *filterCoverView;
}

@property (nonatomic, strong) NSURL *videoURL;
- (void)pauseVideoWhenSleepMode;

- (void)movePushNotificationChatViewController:(NSNumber *)boardID isDeletedFriend:(BOOL)isDetetedFriend users:(NSMutableArray *)lstUsers isDirectory:(NSDictionary *)directoryInfo;
- (void)movePushNotificationConferenceViewController:(NSDictionary *)dic;

@end
