//
//  IMVideoViewController.h
//  Xchangewithme
//
//  Created by Xin YingTai on 21/5/14.
//  Copyright (c) 2014 Xin YingTai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMVideoViewController : UIViewController
{
    IBOutlet UIButton *btnForBack;
    IBOutlet UIButton *btnForClose;
    IBOutlet UIBarButtonItem *itemForSkip;
}

@property (nonatomic, assign) BOOL navBarColor;
- (void)movePushNotificationChatViewController:(NSNumber *)boardID isDeletedFriend:(BOOL)isDetetedFriend users:(NSMutableArray *)lstUsers isDirectory:(NSDictionary *)directoryInfo;
- (void)movePushNotificationConferenceViewController:(NSDictionary *)dic;

@end
