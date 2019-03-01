//
//  GreyInfoController.h
//  GINKO
//
//  Created by mobidev on 5/20/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CISyncDetailController.h" //importer class
#import "GreyDetailController.h"

@interface GreyInfoController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UIView *navView;
@property (nonatomic, assign) IBOutlet UITableView *tblInfoItems;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;

@property (nonatomic, strong) UIViewController *parentController; //importer class

- (IBAction)onCancel:(id)sender;
- (IBAction)onDone:(id)sender;

@end
