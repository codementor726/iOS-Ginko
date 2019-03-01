//
//  ExchangedViewController.h
//  Ginko
//
//  Created by Qi Song on 29/3/14.
//  Copyright (c) 2014 Qi Song. All rights reserved.
//
// --- Headers ---;
#import <UIKit/UIKit.h>
#import "ExchangedInfoCell.h"

// --- Defines ---;
// ExchangedViewController Class;
@interface ExchangedViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, ExchangedInfoCellDelegate, UIActionSheetDelegate, UIAlertViewDelegate>
{
    IBOutlet UITableView *tblForContact;
    IBOutlet UISearchBar * contactSearch;
    
    //Custom UINavigationView
    IBOutlet UIView * navView;
    IBOutlet UIButton * backBut;
    IBOutlet UIButton * gpsBut;
    NSMutableArray * contactList;
    NSMutableArray * searchList;
    IBOutlet UIButton * trashBut;
    
    //Edit
    IBOutlet UIButton * closeBut;
    
    IBOutlet UILabel *lblOn1;
    IBOutlet UILabel *lblSorry;
    
    BOOL searchFlag;
    BOOL searchStartFlag;
    
    NSString * contactIds;
    NSString * entityIds;
}

@property (nonatomic, retain) AppDelegate * appDelegate;

- (IBAction)goBackBut;
- (IBAction)onGPSBut;

- (IBAction)onEdit;
- (IBAction)onTrash;
- (IBAction)onCloseEdit;

- (void)touchDown;
- (void)touchUp;

- (void)displayGPSButton;

@end
