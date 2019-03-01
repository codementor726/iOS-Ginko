//
//  CBMainViewController.h
//  GINKO
//
//  Created by mobidev on 5/17/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CBMainViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>


@property (nonatomic, retain) IBOutlet UIView *navView;
@property (nonatomic, assign) IBOutlet UITableView *tblContacts;
@property (nonatomic, assign) IBOutlet UIImageView *imgNoData;
@property (nonatomic, assign) IBOutlet UIView *blankView;

- (IBAction)onBack:(id)sender;
- (IBAction)onAddNew:(id)sender;
- (IBAction)onExchange:(id)sender;

@end
