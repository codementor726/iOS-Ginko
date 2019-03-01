//
//  CallManager.h
//  CallKit
//
//  Created by Dobrinka Tabakova on 11/13/16.
//  Copyright © 2016 Dobrinka Tabakova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CallKit/CallKit.h>
#import <CallKit/CXError.h>

@protocol CallManagerDelegate <NSObject>

- (void)callDidAnswer;
- (void)callDidEnd;
- (void)callDidHold:(BOOL)isOnHold;
- (void)callDidFail;
- (void)callDidAnswerConnecting:(CXAnswerCallAction *)_action;
- (void)StartCallAction:(CXStartCallAction *)_action;

@end

@interface CallManager : NSObject

+ (CallManager*)sharedInstance;
- (void)reportIncomingCallForUUID:(NSUUID*)uuid phoneNumber:(NSString*)phoneNumber;
- (void)reportOutgoingcallForUUID:(NSUUID *)uuid;
- (void)startCallWithPhoneNumber:(NSString*)phoneNumber;
- (void)endCall;
- (void)holdCall:(BOOL)hold;

@property (nonatomic, weak) id<CallManagerDelegate> delegate;

@end
