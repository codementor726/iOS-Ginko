//
//  NotExchangedViewController.h
//  Ginko
//
//  Created by Qi Song on 29/3/14.
//  Copyright (c) 2014 Qi Song. All rights reserved.
//
// --- Headers ---;
#import <UIKit/UIKit.h>
#import "RequestInfoCell.h"

// --- Defines ---;
// NotExchangedViewController Class;
@interface RequestViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, RequestInfoCellDelegate, UIActionSheetDelegate, UIScrollViewDelegate>
{
    IBOutlet UITableView *tblForContact;
    IBOutlet UISearchBar * contactSearch;
    //Custom UINavigationView
    IBOutlet UIView * navView;
    IBOutlet UIButton * backBut;
    IBOutlet UILabel * titleLabel;
    IBOutlet UIButton * cancelBut;
    IBOutlet UIButton * trashBut;
    
    //Edit
    IBOutlet UIView * tabBar;
    IBOutlet UIButton * closeBut;
    IBOutlet UIButton * realCloseBut;
    IBOutlet UIButton * clearBut;
    
    IBOutlet UILabel * lblNoContact;
    BOOL searchFlag;
    BOOL searchStartFlag;
    
    __weak IBOutlet UIButton *btEdit;
    
    NSMutableArray * contactList;
    NSMutableArray * searchList;
    NSMutableArray * tempInvite;
    NSMutableArray * tempSent;
    
    NSString * remove_type;
    NSString * contactIds;
    NSString * entityIds;
    NSString * directoryIds;
}

@property (nonatomic, retain) AppDelegate * appDelegate;

- (IBAction)goBackBut;
- (IBAction)onEdit;
- (IBAction)onTrash;
- (IBAction)onCloseEdit;
- (IBAction)onCancelSearch:(id)sender;

- (void)GetRequests;
- (void)GetSentInvitation;
- (void)reloadContacts;
@end
