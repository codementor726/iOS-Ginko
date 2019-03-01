//
//  GroupAddContactsViewController.h
//  GINKO
//
//  Created by Xian on 7/22/14.
//  Copyright (c) 2014 Xian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupAddContactsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UISearchBarDelegate>

@property (nonatomic, retain) IBOutlet UIView *navView;
@property (nonatomic, assign) IBOutlet UIButton *btnDone;

@property (nonatomic, assign) IBOutlet UIButton *btnSelectAll;
@property (nonatomic, assign) IBOutlet UISearchBar *searchBarForList;
@property (nonatomic, assign) IBOutlet UITableView *tblForContact;

@property (nonatomic, retain) NSString *groupID;

- (IBAction)onBack:(id)sender;
- (IBAction)onDone:(id)sender;
- (IBAction)onSelectAll:(id)sender;
- (IBAction)onSearchCancel:(id)sender;

@end
