//
//  PreviewProfileViewController.h
//  ginko
//
//  Created by STAR on 15/12/29.
//  Copyright © 2015年 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreviewProfileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{

    __weak IBOutlet UIView *profileObserveView;
    __weak IBOutlet UIView *borderViewForProfile;
    __weak IBOutlet UIImageView *profileImageViewLarge;

}

@property (weak, nonatomic) IBOutlet UITableView *fieldTable;

// toolbar
@property (weak, nonatomic) IBOutlet UIButton *workButton;
@property (weak, nonatomic) IBOutlet UIButton *homeButton;
- (IBAction)navigateToWork:(id)sender;
- (IBAction)navigateToHome:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *workCapView;
@property (weak, nonatomic) IBOutlet UIView *homeCapView;

// header
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *wallpaperImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *wallpaperLoadingIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *profileImageLoadingIndicator;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *profileImageContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *privilegeImageView;
@property (weak, nonatomic) IBOutlet UIButton *noteDetailsBtn;

// footer
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIImageView *snapshotImageView;


@property (weak, nonatomic) IBOutlet UIButton *btFavorite;
@property (nonatomic, retain) AppDelegate * appDelegate;

- (IBAction)playVideo:(id)sender;
- (IBAction)onProfileFavorite:(id)sender;
- (IBAction)onNoteBtn:(id)sender;

@property (nonatomic, strong) NSString *strNotes;

// set from outside
@property (strong, nonatomic) NSDictionary *userData;

@property (assign, nonatomic) BOOL isWork;

@property (assign, nonatomic) BOOL isSelected;  //0 work 1 home

@property (assign, nonatomic) BOOL isSetup;

@property (assign, nonatomic) BOOL isViewOnly;

@property (assign, nonatomic) BOOL isChat;

@property (assign, nonatomic) BOOL isFromVideoChat;

@property (assign, nonatomic) BOOL directoryUser;
@property (strong, nonatomic) NSDictionary *groupInfo;

- (void)updateNotes;

- (IBAction)onProfileObserve:(id)sender;
- (IBAction)onCloseProfileObserveView:(id)sender;
- (void)movePushNotificationChatViewController:(NSNumber *)boardID isDeletedFriend:(BOOL)isDetetedFriend users:(NSMutableArray *)lstUsers isDirectory:(NSDictionary *)directoryInfo;
- (void)movePushNotificationConferenceViewController:(NSDictionary *)dic;
@end
