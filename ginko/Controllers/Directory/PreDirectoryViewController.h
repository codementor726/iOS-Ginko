//
//  PreDirectoryViewController.h
//  ginko
//
//  Created by stepanekdavid on 12/27/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreDirectoryViewController : UIViewController{

    __weak IBOutlet UILabel *lblDirectoryName;
    __weak IBOutlet UIImageView *imgPrivate;
    __weak IBOutlet UIImageView *imgPublic;
    __weak IBOutlet UIView *autoOrManualView;
    __weak IBOutlet UIImageView *imgAuto;
    __weak IBOutlet UIImageView *imgManual;
    __weak IBOutlet UIView *domainView;
    __weak IBOutlet UITableView *domainTableView;
    __weak IBOutlet UIImageView *directoryLogoImage;
    
    __weak IBOutlet UIView *profilelogoPreView;
    __weak IBOutlet UIImageView *profileLogoImageView;
    __weak IBOutlet UIView *profileLogoContainerView;
}
@property BOOL isJoinOwn;
@property BOOL isCreate;
@property (nonatomic, retain) NSMutableDictionary *directoryInfoForPreview;
- (IBAction)onDeleteDirectory:(id)sender;
- (IBAction)onCloseProfilePreView:(id)sender;
- (IBAction)onOpenProfilePreView:(id)sender;

- (void)movingInviteViewFromNotification:(NSString *)directoryId;
- (void)movePushNotificationViewController;
- (void)movePushNotificationConferenceViewController:(NSDictionary *)dic;
@end
