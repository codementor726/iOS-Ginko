//
//  DirectoryInviteContactsViewController.h
//  ginko
//
//  Created by stepanekdavid on 12/27/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DirectoryInviteContactsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UISearchBarDelegate, UIAlertViewDelegate>
@property (nonatomic, retain) IBOutlet UIView *navView;
@property (nonatomic, assign) IBOutlet UIButton *btnDone;

@property (nonatomic, assign) IBOutlet UIButton *btnSelectAll;
@property (nonatomic, assign) IBOutlet UISearchBar *searchBarForList;
@property (nonatomic, assign) IBOutlet UITableView *tblForContact;
@property (nonatomic, assign) IBOutlet UIView *viewBottom;

@property (weak, nonatomic) IBOutlet UIButton *btnDirectoryUser;
@property (nonatomic, assign) IBOutlet UIButton *btnInvited;
@property (nonatomic, assign) IBOutlet UIButton *btnAccepted;
@property (nonatomic, assign) IBOutlet UIButton *btnAllContacts;
@property (weak, nonatomic) IBOutlet UIButton *trashButton;

@property (nonatomic, assign) IBOutlet UIView *viewDelete;

@property (nonatomic, assign) BOOL navBarColor;
@property (nonatomic, assign) IBOutlet UIButton *backButton;

@property (nonatomic, retain) NSString *directoryID;
@property (weak, nonatomic) IBOutlet UILabel *navigationTextLabel;


@property (nonatomic, assign) NSInteger statusFromNavi;
- (IBAction)onBack:(id)sender;
- (IBAction)onDone:(id)sender;

- (IBAction)onSelectAll:(id)sender;

- (IBAction)onDirectoryUser:(id)sender;
- (IBAction)onInvitedContacts:(id)sender;
- (IBAction)onAllContacts:(id)sender;
- (IBAction)onAcceptContacts:(id)sender;

- (IBAction)onDelete:(id)sender;
- (void)movePushNotificationViewController;
@end
