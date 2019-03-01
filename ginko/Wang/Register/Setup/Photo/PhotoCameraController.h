//
//  PhotoCameraController.h
//  Xchangewithme
//
//  Created by Xin YingTai on 21/5/14.
//  Copyright (c) 2014 Xin YingTai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoCameraController : UIViewController
{
    IBOutlet UIButton *btnForBack;
    IBOutlet UIView *viewForPhoto;
    IBOutlet UIImageView *imgForGrid;
    IBOutlet UIImageView *imgForFocus;
    IBOutlet UIButton *btnForGrid;
    IBOutlet UIButton *btnForFlip;
    IBOutlet UIButton *btnForFlash;
    IBOutlet UIButton *btnForTake;
}
- (void)movePushNotificationChatViewController:(NSNumber *)boardID isDeletedFriend:(BOOL)isDetetedFriend users:(NSMutableArray *)lstUsers isDirectory:(NSDictionary *)directoryInfo;
- (void)movePushNotificationConferenceViewController:(NSDictionary *)dic;
@end
