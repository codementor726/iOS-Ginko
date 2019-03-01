//
//  ManageEntityViewController.h
//  ginko
//
//  Created by Harry on 1/13/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ManageEntityViewControllerDelegate <NSObject>

- (void)didFinishEdit:(NSMutableDictionary *)entityData;

@end

@interface ManageEntityViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *tables;

@property (weak, nonatomic) IBOutlet UILabel *lockNoticeLabel;

@property (weak, nonatomic) IBOutlet UIButton *lockButton;

@property (weak, nonatomic) IBOutlet UIButton *addFieldButton;

@property (weak, nonatomic) IBOutlet UIButton *subEntityAddButton;

@property (weak, nonatomic) IBOutlet UIButton *addFieldButton2;

@property (weak, nonatomic) IBOutlet UIView *addFieldView;

@property (weak, nonatomic) IBOutlet UITableView *addFieldTable;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpacing;

- (IBAction)addField:(id)sender;

- (IBAction)hideAddFieldView:(id)sender;

- (IBAction)doLockOrUnlock:(id)sender;

- (IBAction)subEntityAdd:(id)sender;

@property (weak, nonatomic) IBOutlet UIScrollView *entityScrollView;



// set from outside
@property (nonatomic, assign) int category;

@property (nonatomic, assign) BOOL isCreate;        // 1 for create new, 0 for edit existing

@property (nonatomic, strong) NSMutableDictionary *entityData;

@property (nonatomic, assign) BOOL isSetup;

@property (nonatomic, assign) BOOL isSubEntity;

@property (nonatomic, assign) int currentIndex;

@property (nonatomic, assign) BOOL isMultiLocation;

@property (weak, nonatomic) id<ManageEntityViewControllerDelegate> delegate;

- (void)movePushNotificationChatViewController:(NSNumber *)boardID isDeletedFriend:(BOOL)isDetetedFriend users:(NSMutableArray *)lstUsers isDirectory:(NSDictionary *)directoryInfo;
- (void)movePushNotificationConferenceViewController:(NSDictionary *)dic;
@end
