//
//  GroupListViewController.h
//  GINKO
//
//  Created by Xian on 7/22/14.
//  Copyright (c) 2014 Xian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, assign) IBOutlet UITableView *tblGroups;
@property (nonatomic, retain) IBOutlet UIView *navView;
@property (nonatomic, assign) IBOutlet UIView *emptyView;

- (IBAction)onBack:(id)sender;
- (IBAction)onAddContact:(id)sender;

@end
