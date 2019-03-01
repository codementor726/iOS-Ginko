//
//  PreviewMainEntityViewController.h
//  ginko
//
//  Created by stepanekdavid on 4/18/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface PreviewMainEntityViewController : UIViewController<CLLocationManagerDelegate>{
    
    __weak IBOutlet UIView *selfMainEntityObserveView;
    __weak IBOutlet UIView *selfMainEntityProfileContainerView;
    __weak IBOutlet UIImageView *selfMainEntityProfileImageLarge;
}

@property (weak, nonatomic) IBOutlet UIScrollView *entityScrollView;

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *wallpaperImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *wallpaperLoadingIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *profileImageLoadingIndicator;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *privilegeImageView;

@property (weak, nonatomic) IBOutlet UIButton *btnEntityFavorite;

- (IBAction)deleteEntity:(id)sender;
- (IBAction)onFavority:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deleteButtonHeight;

// set from outside
@property (nonatomic, assign) BOOL isCreate;
@property (nonatomic, assign) BOOL isMultiLocation;
@property (nonatomic, strong) NSString *entityId;

@property (nonatomic, retain) CLLocationManager * locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D currentLocationforMultiLocations;
@property (nonatomic, assign) CLLocationCoordinate2D newLocationOfUser;

@property (nonatomic, retain) NSTimer * getCurrentGPSCallTimer;

-(void)repeatLocationUpdating;

- (void)movePushNotificationViewController;
- (void)movePushNotificationChatViewController:(NSNumber *)boardID isDeletedFriend:(BOOL)isDetetedFriend users:(NSMutableArray *)lstUsers isDirectory:(NSDictionary *)directoryInfo;
- (void)movePushNotificationConferenceViewController:(NSDictionary *)dic;


- (IBAction)onSelfMainEntityObserveView:(id)sender;
- (IBAction)onSelfMainEntityObserveClose:(id)sender;

@end
