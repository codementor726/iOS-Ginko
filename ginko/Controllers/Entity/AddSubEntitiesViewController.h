//
//  AddSubEntitiesViewController.h
//  ginko
//
//  Created by stepanekdavid on 4/17/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AddSubEntitiesViewControllerDelegate <NSObject>

- (void)returnMainEdit:(NSMutableArray *)entityData;

@end
@interface AddSubEntitiesViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *tables;

@property (weak, nonatomic) IBOutlet UILabel *lockNoticeLabel;

@property (weak, nonatomic) IBOutlet UIButton *lockButton;

@property (weak, nonatomic) IBOutlet UIButton *addLocationButton;
@property (weak, nonatomic) IBOutlet UIButton *removeAllLocationButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpacing;

- (IBAction)removeAllLocations:(id)sender;

- (IBAction)doLockOrUnlock:(id)sender;

- (IBAction)addLocationOfEntity:(id)sender;

@property (weak, nonatomic) IBOutlet UIScrollView *entityScrollView;



// set from outside
@property (nonatomic, assign) int category;

@property (nonatomic, assign) BOOL isCreate;        // 1 for create new, 0 for edit existing


@property (nonatomic, strong) NSMutableDictionary *entityData;
@property (nonatomic, weak) NSData *_videoData_sub;

@property (nonatomic, assign) BOOL isSetup;

@property (nonatomic, assign) BOOL isMultiLocation;


@property (weak, nonatomic) id<AddSubEntitiesViewControllerDelegate> delegate;
- (void)movePushNotificationChatViewController:(NSNumber *)boardID isDeletedFriend:(BOOL)isDetetedFriend users:(NSMutableArray *)lstUsers isDirectory:(NSDictionary *)directoryInfo;
- (void)movePushNotificationConferenceViewController:(NSDictionary *)dic;
@end
