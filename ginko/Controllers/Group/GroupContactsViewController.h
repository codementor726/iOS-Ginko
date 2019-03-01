//
//  GroupContactsViewController.h
//  GINKO
//
//  Created by Xian on 7/22/14.
//  Copyright (c) 2014 Xian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactCell.h"
#import "TileViewCell.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MessageUI.h>
#import <MapKit/MapKit.h>

@interface GroupContactsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIScrollViewDelegate, UISearchBarDelegate, ContactCellDelegate, TileViewCellDelegate, MFMailComposeViewControllerDelegate>
{
    NSString *availableIdsWithConfere;
    NSMutableArray *availContactsWithConfere;
}

@property (nonatomic, assign) IBOutlet UITableView *tblContacts;
@property (nonatomic, retain) IBOutlet UIView *navView;
@property (nonatomic, assign) IBOutlet UIView *emptyView;
@property (nonatomic, assign) IBOutlet UIView *viewBottom;
@property (nonatomic, assign) IBOutlet UISearchBar *searchBarForList;
@property (nonatomic, assign) IBOutlet UILabel *lblGroupName;
@property (nonatomic, assign) IBOutlet UIButton *btnBack;
@property (nonatomic, assign) IBOutlet UIButton *btnBackFunction;
@property (nonatomic, assign) IBOutlet UIButton *btnAddContact;
@property (nonatomic, assign) IBOutlet UIButton *btnChat;
@property (nonatomic, assign) IBOutlet UIButton *btnCar;
@property (nonatomic, assign) IBOutlet UIButton *btnClose;
@property (nonatomic, assign) IBOutlet UIButton *btnEdit;
@property (weak, nonatomic) IBOutlet UIButton *btnEditPermission;
@property (weak, nonatomic) IBOutlet UIView *addView;
@property (weak, nonatomic) IBOutlet UIButton *btnGroupVideoChat;

@property (nonatomic, retain) NSDictionary *groupDict;

- (IBAction)onBack:(id)sender;
- (IBAction)onAddContact:(id)sender;
- (IBAction)onChat:(id)sender;
- (IBAction)onCar:(id)sender;
- (IBAction)onClose:(id)sender;
- (IBAction)onEdit:(id)sender;
- (IBAction)onRemove:(id)sender;
- (IBAction)onSearchCancel:(id)sender;
- (IBAction)onGroupVideoChat:(id)sender;

- (IBAction)onPermissionEdit:(id)sender;

- (void)startVideoCallingWithSelectedContact:(NSString *)ids availContacts:(NSMutableArray *)users;
@end
