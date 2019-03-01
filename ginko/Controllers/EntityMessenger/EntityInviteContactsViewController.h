//
//  EntityInviteContactsViewController.h
//  GINKO
//
//  Created by mobidev on 7/24/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EntityInviteContactsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UISearchBarDelegate, UIAlertViewDelegate>

@property (nonatomic, retain) IBOutlet UIView *navView;
@property (nonatomic, assign) IBOutlet UIButton *btnDone;

@property (nonatomic, assign) IBOutlet UIButton *btnSelectAll;
@property (nonatomic, assign) IBOutlet UISearchBar *searchBarForList;
@property (nonatomic, assign) IBOutlet UITableView *tblForContact;
@property (nonatomic, assign) IBOutlet UIView *viewBottom;

@property (nonatomic, assign) IBOutlet UIButton *btnInvited;
@property (nonatomic, assign) IBOutlet UIButton *btnAccepted;
@property (nonatomic, assign) IBOutlet UIButton *btnAllContacts;
@property (weak, nonatomic) IBOutlet UIButton *trashButton;

@property (nonatomic, assign) IBOutlet UIView *viewDelete;

@property (nonatomic, assign) BOOL navBarColor;
@property (nonatomic, assign) IBOutlet UIButton *backButton;

@property (nonatomic, retain) NSString *entityID;
@property (weak, nonatomic) IBOutlet UILabel *navigationTextLabel;

- (IBAction)onBack:(id)sender;
- (IBAction)onDone:(id)sender;
- (IBAction)onSelectAll:(id)sender;
- (IBAction)onInvitedContacts:(id)sender;
- (IBAction)onAllContacts:(id)sender;
- (IBAction)onDelete:(id)sender;

- (void)movePushNotificationChatViewController:(NSNumber *)boardID isDeletedFriend:(BOOL)isDetetedFriend users:(NSMutableArray *)lstUsers isDirectory:(NSDictionary *)directoryInfo;
- (void)movePushNotificationConferenceViewController:(NSDictionary *)dic;
@end
