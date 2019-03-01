//
//  NotificationViewController.m
//  GINKO
//
//  Created by Forever on 6/3/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import "NotificationViewController.h"

@interface NotificationViewController ()
{
    BOOL isChanged;
}
@end

@implementation NotificationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar addSubview:navView];
    [self.navigationItem setHidesBackButton:YES animated:NO];
    [self GetNotificationSetting];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [navView removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBack:(id)sender
{
    if (isChanged) {
        [self onBtnSave:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)onValueChanged:(id)sender
{
    isChanged = YES;
}

- (void)onBtnSave:(id)sender
{
    NSString *exchange = @"true";
    NSString *chat = @"true";
    NSString *sprout = @"true";
    NSString *profile = @"true";
    NSString *entity = @"true";
    
    if (!switchExchange.on)
        exchange = @"false";
    
    if (!switchChat.on)
        chat = @"false";
    
    if (!switchSprout.on)
        sprout = @"false";
    
    if (!switchProfileUpdates.on)
        profile = @"false";
    
    if (!switchEntity.on)
        entity = @"false";
    
    BOOL isSaveButton = sender ? YES : NO;
    
    [self SetNotification:exchange chat:chat sprout:sprout profile:profile entity:entity isSaveButton:isSaveButton];
}

- (void)SetNotification : (NSString *)_exchange
                    chat: (NSString *)_chat
                  sprout: (NSString *)_sprout
                 profile: (NSString *)_profile
                  entity: (NSString *)_entity
            isSaveButton: (BOOL)_isSaveButton
{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        if ([[_responseObject objectForKey:@"success"] boolValue])
		{
            [AppDelegate sharedDelegate].isChatNotification = switchChat.on;
            [AppDelegate sharedDelegate].isExchangeNotification = switchExchange.on;
            [AppDelegate sharedDelegate].isSproutNotification = switchSprout.on;
            [AppDelegate sharedDelegate].isProfileNotification = switchProfileUpdates.on;
            [AppDelegate sharedDelegate].isEntityNotification = switchEntity.on;
            
            [[AppDelegate sharedDelegate] saveLoginData];
            
            isChanged = NO;
            if (_isSaveButton) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"Yippee!  You successfully set the push notification." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"Oh no!  Push notification error.  Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        NSLog(@"Connection failed - %@", _error);
    } ;

    NSString *uniqueIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    [[Communication sharedManager] SetNotification:[AppDelegate sharedDelegate].sessionId deviceUID:uniqueIdentifier exchange:_exchange chat:_chat sprout:_sprout profile:_profile entity:_entity successed:successed failure:failure];
}

- (void)GetNotificationSetting
{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        NSDictionary *dict = [_responseObject objectForKey:@"data"];
        
        if ([[dict objectForKey:@"chat_msg_notification"] boolValue])
        {
            [switchChat setOn:YES];
            [AppDelegate sharedDelegate].isChatNotification = YES;
        }
        else
        {
            [switchChat setOn:NO];
            [AppDelegate sharedDelegate].isChatNotification = NO;
        }
        if ([[dict objectForKey:@"exchange_request_notification"] boolValue])
        {
            [switchExchange setOn:YES];
            [AppDelegate sharedDelegate].isExchangeNotification = YES;
        }
        else
        {
            [switchExchange setOn:NO];
            [AppDelegate sharedDelegate].isExchangeNotification = NO;
        }
        if ([[dict objectForKey:@"sprout_notification"] boolValue])
        {
            [switchSprout setOn:YES];
            [AppDelegate sharedDelegate].isSproutNotification = YES;
        }
        else
        {
            [switchSprout setOn:NO];
            [AppDelegate sharedDelegate].isSproutNotification = NO;
        }
        [switchProfileUpdates setOn:[[dict objectForKey:@"profile_change_notification"] boolValue]];
        [AppDelegate sharedDelegate].isProfileNotification = [[dict objectForKey:@"profile_change_notification"] boolValue];
        [switchEntity setOn:[[dict objectForKey:@"entity_notification"] boolValue]];
        [AppDelegate sharedDelegate].isEntityNotification = [[dict objectForKey:@"entity_notification"] boolValue];
        
        [[AppDelegate sharedDelegate] saveLoginData];
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        NSLog(@"Connection failed - %@", _error);
    } ;
    
    [[Communication sharedManager] GetNotificationSetting:[AppDelegate sharedDelegate].sessionId successed:successed failure:failure];
}

@end
