//
//  SetupLocationer.m
//  GINKO
//
//  Created by mobidev on 7/2/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import "SetupLocationer.h"
#import "YYYCommunication.h"
#import "MobileVerificationViewController.h"

@implementation SetupLocationer

#pragma mark - Shared Functions
+ (SetupLocationer *)sharedLocationer
{
    static SetupLocationer *_sharedLocationer;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedLocationer = [[SetupLocationer alloc] init];
    });
    
    return _sharedLocationer;
}

- (id)init
{
    self = [super init];
    
    if (self) {

    }
    
    return self;
}

- (void)configAfterSignIn:(NSDictionary *)_responseObject
{
    NSDictionary * myInfo = [_responseObject objectForKey:@"data"];
    [AppDelegate sharedDelegate].myName = [NSString stringWithFormat:@"%@ %@", [myInfo objectForKey:@"first_name"], [myInfo objectForKey:@"last_name"]];
    
    //Sun Class
    [AppDelegate sharedDelegate].sessionId = [myInfo objectForKey:@"sessionId"];
    NSLog(@"session id = %@", [AppDelegate sharedDelegate].sessionId);
        
    [AppDelegate sharedDelegate].strSetupPage = [myInfo objectForKey:@"setup_page"];
    
    [AppDelegate sharedDelegate].currentLocation = CLLocationCoordinate2DMake(0, 0);
    
    [AppDelegate sharedDelegate].locationFlag = [[myInfo objectForKey:@"location_on"] boolValue];
    if ([AppDelegate sharedDelegate].locationFlag) {
        [[AppDelegate sharedDelegate] refreshLocationUpdating];
    }
    
    [AppDelegate sharedDelegate].isChatNotification = [[myInfo objectForKey:@"chat_msg_notification"] boolValue];
    [AppDelegate sharedDelegate].isExchangeNotification = [[myInfo objectForKey:@"exchange_request_notification"] boolValue];
    [AppDelegate sharedDelegate].isSproutNotification = [[myInfo objectForKey:@"sprout_notification"] boolValue];

    [self setupNext];
}

- (void)setupNext
{
    if ([[AppDelegate sharedDelegate].strSetupPage intValue]) {
        [[AppDelegate sharedDelegate].dictInfoWork removeAllObjects];
        [[AppDelegate sharedDelegate].dictInfoWork setObject:@"0" forKey:@"Private"];
		[[AppDelegate sharedDelegate].dictInfoWork setObject:@"0" forKey:@"Abbr"];
    }
    
    if ([[AppDelegate sharedDelegate].strSetupPage isEqualToString:@"2"]) {
        [[AppDelegate sharedDelegate] goToMainContact];
    } else if ([[AppDelegate sharedDelegate].strSetupPage isEqualToString:@"1"]) {
        [[AppDelegate sharedDelegate] goToSetupCB];
    }/* else if ([[AppDelegate sharedDelegate].strSetupPage isEqualToString:@"1"]) {
        [[AppDelegate sharedDelegate] goToContactImporter];
    }*/  else if ([[AppDelegate sharedDelegate].strSetupPage isEqualToString:@""] || ![AppDelegate sharedDelegate].strSetupPage) {
        [[AppDelegate sharedDelegate] goToSetup];//signup process
    } else {
        [[AppDelegate sharedDelegate] goToMainContact];
    }
}

@end
