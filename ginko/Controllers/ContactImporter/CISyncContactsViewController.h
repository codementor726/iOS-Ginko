//
//  CISyncContactsViewController.h
//  ContactImporter
//
//  Created by mobidev on 6/13/14.
//  Copyright (c) 2014 Ron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CISyncCell.h"

@interface CISyncContactsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, SyncCellDelegate, UIAlertViewDelegate, UISearchBarDelegate>

@property (nonatomic, retain) IBOutlet UIView *navView;
@property (nonatomic, assign) IBOutlet UITableView *tblSyncContacts;
@property (nonatomic, assign) IBOutlet UIButton *btnEntity;
@property (nonatomic, assign) IBOutlet UIButton *btnHome;
@property (nonatomic, assign) IBOutlet UIButton *btnWork;
@property (nonatomic, assign) IBOutlet UISearchBar *contactSearch;
@property (nonatomic, assign) IBOutlet UIView *viewTap;

@property (nonatomic, assign) IBOutlet UIButton *btnClose;
@property (nonatomic, assign) IBOutlet UIButton *btnRemove;
@property (nonatomic, assign) IBOutlet UIButton *btnSkip;
@property (nonatomic, assign) IBOutlet UIButton *btnNext;
@property (nonatomic, assign) IBOutlet UIButton *btnImport;
@property (nonatomic, assign) IBOutlet UIButton *btnEdit;

@property (nonatomic, assign) IBOutlet UILabel *lblTitle;
@property (nonatomic) BOOL isHistory;

@property (nonatomic, assign) IBOutlet UIButton *btnBack;
@property (nonatomic, assign) IBOutlet UIButton *btnDone;
@property (weak, nonatomic) IBOutlet UIButton *btnRealDone;

- (IBAction)onType:(id)sender;
- (IBAction)onSkip:(id)sender;
- (IBAction)onNext:(id)sender;
- (IBAction)onImport:(id)sender;
- (IBAction)onClose:(id)sender;
- (IBAction)onRemove:(id)sender;

- (IBAction)onBack:(id)sender;
- (IBAction)onDone:(id)sender;

@end
