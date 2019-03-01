//
//  AddInfoOfSubEntityViewController.h
//  ginko
//
//  Created by stepanekdavid on 4/17/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddInfoOfSubEntityViewControllerDelegate <NSObject>

- (void)didFinishAddSubEntity:(NSMutableDictionary *)infoSubEntity;
- (void)deletedLocationOfEntity:(int)index;

@end

@interface AddInfoOfSubEntityViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *tables;

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (weak, nonatomic) IBOutlet UIButton *addFieldButton;

@property (weak, nonatomic) IBOutlet UIButton *addFieldButton2;

@property (weak, nonatomic) IBOutlet UIView *addFieldView;

@property (weak, nonatomic) IBOutlet UITableView *addFieldTable;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpacing;

- (IBAction)addField:(id)sender;

- (IBAction)hideAddFieldView:(id)sender;

- (IBAction)deleteLocation:(id)sender;

@property (weak, nonatomic) IBOutlet UIScrollView *entityScrollView;



// set from outside
@property (nonatomic, assign) int category;

@property (nonatomic, assign) BOOL isCreate;        // 1 for create new, 0 for edit existing

@property (nonatomic, strong) NSMutableDictionary *entityData;

@property (nonatomic, assign) BOOL isSetup;

@property (nonatomic, assign) int indexOfSubEntity;

@property (weak, nonatomic) id<AddInfoOfSubEntityViewControllerDelegate> delegate;
- (void)movePushNotificationChatViewController:(NSNumber *)boardID isDeletedFriend:(BOOL)isDetetedFriend users:(NSMutableArray *)lstUsers isDirectory:(NSDictionary *)directoryInfo;
- (void)moveRedirectCISyncContactsViewController:(NSString *)redirectURL;
- (void)movePushNotificationConferenceViewController:(NSDictionary *)dic;
@end
