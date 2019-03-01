//
//  ProfileViewController.h
//  Ginko
//
//  Created by Mobile on 4/2/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"

@interface ProfileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
{
    IBOutlet UITableView * mainTable;
    IBOutlet UILabel * address;
    IBOutlet UILabel * date;
    IBOutlet UIButton * checkBut;
    IBOutlet UIButton * chatBut;
    
    IBOutlet UIView * navView;
    IBOutlet UILabel * contactName;
    IBOutlet UIButton * approveBut;
    IBOutlet UIView *viewDelete;
    
    NSMutableDictionary * profileDict;
    NSMutableDictionary * homeDict;
    NSMutableDictionary * workDict;
    NSMutableDictionary * homeIdDict;
    NSMutableDictionary * workIdDict;
    
    NSMutableArray * totalArr;
    
    NSString * _sharingInfo;
    NSString * _sharedFieldIds;
    NSString * _shareHomeFieldIds;
    NSString * _shareWorkFieldIds;
    BOOL phoneOnly;
    BOOL emailOnly;
    
    NSMutableArray *lstField;
}
@property (weak, nonatomic) IBOutlet UIButton *btnTrash;
@property (nonatomic, retain) NSDictionary * myInfo;
@property (nonatomic, retain) NSDictionary * contactInfo;
@property (nonatomic, retain) AppDelegate * appDelegate;

- (IBAction)onCheckBut:(id)sender;
- (IBAction)onChatOnlyBut:(id)sender;
- (IBAction)onMapBut:(id)sender;
- (IBAction)onApprove:(id)sender;
- (IBAction)onBackBut:(id)sender;
- (IBAction)onTrashBut:(id)sender;
- (void)movePushNotificationChatViewController:(NSNumber *)boardID isDeletedFriend:(BOOL)isDetetedFriend users:(NSMutableArray *)lstUsers isDirectory:(NSDictionary *)directoryInfo;
- (void)movePushNotificationConferenceViewController:(NSDictionary *)dic;
@end
