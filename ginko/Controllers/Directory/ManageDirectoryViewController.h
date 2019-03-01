//
//  ManageDirectoryViewController.h
//  ginko
//
//  Created by stepanekdavid on 12/26/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ManageDirectoryViewController : UIViewController{

    __weak IBOutlet UILabel *lblDirectoryName;
    
    __weak IBOutlet UIButton *btnPrivate;
    __weak IBOutlet UIButton *btnPublic;
    __weak IBOutlet UIButton *btnAuto;
    __weak IBOutlet UIButton *btnManual;
    
    __weak IBOutlet UIView *viewPrivateOrPublic;
    __weak IBOutlet UIView *domainView;
    
    __weak IBOutlet UITableView *domainTableview;
    __weak IBOutlet UIButton *btnDirectoryLogo;
    __weak IBOutlet UIView *nameView;
    __weak IBOutlet UITextField *txtName;
}
- (IBAction)onPrivate:(id)sender;
- (IBAction)onPublic:(id)sender;
- (IBAction)onAuto:(id)sender;
- (IBAction)onManual:(id)sender;

- (IBAction)onAddDomain:(id)sender;
- (IBAction)onUpdateDirectoryLogo:(id)sender;

@property (nonatomic, retain) NSString *directoryName;
@property (nonatomic, retain) NSMutableDictionary *directoryInfo;
@property BOOL isCreate;
@property BOOL isSetup;
@property BOOL isJoinOwn;
- (void)movePushNotificationViewController;
@end
