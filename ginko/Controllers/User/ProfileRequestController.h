//
//  Ginko
//
//  Created by Mobile on 4/2/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"

@interface ProfileRequestController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
{
    IBOutlet UITableView * mainTable;
    IBOutlet UILabel * address;
    IBOutlet UILabel * date;
    IBOutlet UIButton * checkBut;
    IBOutlet UIButton * chatBut;
    
    __weak IBOutlet UIImageView *leafImageView;
    
    __weak IBOutlet UILabel *shareYourLeafLabel;
    
    __weak IBOutlet UIButton *backButton;
    
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
@property (nonatomic, retain) NSString * directoryId;
@property (nonatomic, retain) NSString * directoryName;

@property (nonatomic, assign) BOOL navBarColor;
@property (nonatomic, assign) BOOL isRequestForDirectoryUser;

- (IBAction)onCheckBut:(id)sender;
- (IBAction)onChatOnlyBut:(id)sender;
- (IBAction)onMapBut:(id)sender;
- (IBAction)onApprove:(id)sender;
- (IBAction)onBackBut:(id)sender;
- (IBAction)onTrashBut:(id)sender;

@end
