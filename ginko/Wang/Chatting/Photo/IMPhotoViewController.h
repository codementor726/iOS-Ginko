//
//  PhotoViewController.h
//  Xchangewithme
//
//  Created by Xin YingTai on 20/5/14.
//  Copyright (c) 2014 Xin YingTai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMPhotoViewController : UIViewController
{
    IBOutlet UIButton *btnForBack;
    IBOutlet UIButton *btnForEdit;
    IBOutlet UIButton *btnForClose;    
    IBOutlet UIBarButtonItem *itemForSkip;
	
	IBOutlet UILabel *lblForHidden;
	IBOutlet UIImageView *imgForHidden;
}
- (void)movePushNotificationChatViewController:(NSNumber *)boardID isDeletedFriend:(BOOL)isDetetedFriend users:(NSMutableArray *)lstUsers isDirectory:(NSDictionary *)directoryInfo;
- (void)movePushNotificationConferenceViewController:(NSDictionary *)dic;
@end
