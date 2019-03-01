//
//  SettingViewController.h
//  Ginko
//
//  Created by Mobile on 4/1/14.
//  Copyright (c) 2014 Xin ZhangZhe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface SettingViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    //Custom UINavigationView
    IBOutlet UIView * navView;
    IBOutlet UITableView * mainTable;
    NSArray * titleArray;
}

@property (nonatomic, retain) AppDelegate * appDelegate;

- (IBAction)onBack:(id)sender;
@end
