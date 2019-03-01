//
//  QRReaderViewController.h
//  Dictate
//
//  Created by Harry on 3/4/14.
//  Copyright (c) 2014 gomilab. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QRReaderViewDelegate <NSObject>

- (void)didReadQRCode:(NSString *)userId;

@end

@interface QRReaderViewController : UIViewController
@property (nonatomic, assign) id<QRReaderViewDelegate> delegate;


- (void)movePushNotificationChatViewController:(NSNumber *)boardID isDeletedFriend:(BOOL)isDetetedFriend users:(NSMutableArray *)lstUsers isDirectory:(NSDictionary *)directoryInfo;
- (void)movePushNotificationConferenceViewController:(NSDictionary *)dic;

@end
