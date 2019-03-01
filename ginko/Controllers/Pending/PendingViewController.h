//
//  NotExchangedViewController.h
//  Ginko
//
//  Created by Qi Song on 29/3/14.
//  Copyright (c) 2014 Qi Song. All rights reserved.
//
// --- Headers ---;
#import <UIKit/UIKit.h>
#import "PendingInfoCell.h"

// --- Defines ---;
// NotExchangedViewController Class;
@interface PendingViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, PendingInfoCellDelegate, UIActionSheetDelegate,UIScrollViewDelegate>
{
    IBOutlet UITableView *tblForContact;
    IBOutlet UISearchBar * contactSearch;
    //Custom UINavigationView
    IBOutlet UIView * navView;
    IBOutlet UIButton * backBut;
    IBOutlet UILabel * titleLabel;
    IBOutlet UIButton * gpsBut;
    IBOutlet UIButton * cancelBut;
    IBOutlet UIButton * trashBut;
    
    //Edit
    IBOutlet UIView * tabBar;
    IBOutlet UIButton * closeBut;
    IBOutlet UIButton * clearBut;
    
    __weak IBOutlet UIButton *btEdit;
    BOOL searchFlag;
    BOOL searchStartFlag;
    IBOutlet UILabel * lblNoContact;
    NSMutableArray * contactList;
    NSMutableArray * searchList;
    NSMutableArray * tempRequest;
    NSMutableArray * tempInvite;
    
    NSString * remove_type;
    NSString * contactIds;
    NSString * directoryIds;
}

@property (nonatomic, retain) AppDelegate * appDelegate;

- (IBAction)goBackBut;

- (IBAction)onEdit;
- (IBAction)onTrash;
- (IBAction)onCloseEdit;
- (IBAction)onClearChat;
- (IBAction)onCancelSearch:(id)sender;

- (void)GetSentInvitation;

@end
