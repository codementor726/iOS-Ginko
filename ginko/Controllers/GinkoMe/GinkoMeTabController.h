//
//  GinkoMeTabController.h
//  ginko
//
//  Created by ccom on 1/8/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GinkoMeTabDelegate

-(void)updated:(NSArray*)contacts greys:(NSArray*)greys;
-(void)updateTableView;
- (void)malloc;
@end

@interface GinkoMeTabController : UITabBarController<NSFetchedResultsControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property NSArray *contacts;
@property NSArray *greys;

@property (nonatomic, strong) id<GinkoMeTabDelegate> cDelegate;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControll;




@property (strong, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *filterButton;
@property (weak, nonatomic) IBOutlet UIButton *trashButton;
@property (weak, nonatomic) IBOutlet UIButton *ginkoMeButton;
@property (weak, nonatomic) IBOutlet UILabel *on1Label;





- (void)setEditMode:(BOOL)isEditing;
- (void)movePushNotificationViewController;

- (void)movePushNotificationChatViewController:(NSNumber *)boardID isDeletedFriend:(BOOL)isDetetedFriend users:(NSMutableArray *)lstUsers isDirectory:(NSDictionary *)directoryInfo;
- (void)movePushNotificationConferenceViewController:(NSDictionary *)dic;
@end
