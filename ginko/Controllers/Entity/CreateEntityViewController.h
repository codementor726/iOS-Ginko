//
//  CreateEntityViewController.h
//  ginko
//
//  Created by Harry on 1/13/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ToggleButton.h"

@interface CreateEntityViewController : UIViewController
@property (weak, nonatomic) IBOutlet ToggleButton *localBusinessButton;
@property (weak, nonatomic) IBOutlet ToggleButton *companyButton;
@property (weak, nonatomic) IBOutlet ToggleButton *brandButton;
@property (weak, nonatomic) IBOutlet ToggleButton *entertainmentButton;
@property (weak, nonatomic) IBOutlet ToggleButton *artistButton;
@property (weak, nonatomic) IBOutlet ToggleButton *communityButton;

- (IBAction)createLocalBusiness:(id)sender;
- (IBAction)createCompany:(id)sender;
- (IBAction)createBrand:(id)sender;
- (IBAction)createEntertainment:(id)sender;
- (IBAction)createArtist:(id)sender;
- (IBAction)createCommunity:(id)sender;

- (void)movePushNotificationViewController;
- (void)movePushNotificationChatViewController:(NSNumber *)boardID isDeletedFriend:(BOOL)isDetetedFriend users:(NSMutableArray *)lstUsers isDirectory:(NSDictionary *)directoryInfo;
- (void)movePushNotificationConferenceViewController:(NSDictionary *)dic;
@end
