//
//  PreviewEntityViewController.h
//  ginko
//
//  Created by Harry on 1/15/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreviewEntityViewController : UIViewController{

    __weak IBOutlet UIView *selfEntityProfileObserveView;
    __weak IBOutlet UIView *selfEntityProfileContainerView;
    __weak IBOutlet UIImageView *selfEntityProfileImageLarge;
    
}

@property (weak, nonatomic) IBOutlet UIScrollView *entityScrollView;

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *wallpaperImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *wallpaperLoadingIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *profileImageLoadingIndicator;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *privilegeImageView;
@property (strong, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UIImageView *snapshotImageView;

@property (weak, nonatomic) IBOutlet UIButton *btnEntityFavorite;

@property (weak, nonatomic) IBOutlet UIButton *btnRemoveLocation;
- (IBAction)playVideo:(id)sender;
- (IBAction)deleteEntity:(id)sender;
- (IBAction)onFavority:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deleteButtonHeight;

// set from outside
@property (nonatomic, assign) BOOL isCreate;
@property (nonatomic, assign) BOOL isMultiLocation;
@property (nonatomic, assign) int infoId;
@property (nonatomic, strong) NSString *entityId;

- (void)movePushNotificationViewController;
- (void)movePushNotificationChatViewController:(NSNumber *)boardID isDeletedFriend:(BOOL)isDetetedFriend users:(NSMutableArray *)lstUsers isDirectory:(NSDictionary *)directoryInfo;

- (void)movePushNotificationConferenceViewController:(NSDictionary *)dic;

- (IBAction)onSelfEntityObserveView:(id)sender;
- (IBAction)onSelfEntityObserveViewClose:(id)sender;

@end
