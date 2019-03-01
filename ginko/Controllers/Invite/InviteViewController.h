//
//  NotExchangedViewController.h
//  Ginko
//
//  Created by Qi Song on 29/3/14.
//  Copyright (c) 2014 Qi Song. All rights reserved.
//
// --- Headers ---;
#import <UIKit/UIKit.h>
#import "InviteInfoCell.h"

// --- Defines ---;
// NotExchangedViewController Class;
@interface InviteViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, InviteInfoCellDelegate, UIActionSheetDelegate>
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
    IBOutlet UIButton * clearBut;
    IBOutlet UIButton * addBut;
    
    BOOL searchFlag;
    BOOL searchStartFlag;
    
    NSMutableArray * contactList;
    NSMutableArray * searchList;
    NSMutableArray * tempRequest;
    NSMutableArray * tempSent;
    
    NSString * remove_type;
    NSString * contactIds;
}

@property (nonatomic, retain) AppDelegate * appDelegate;

- (IBAction)onAddInvitation;
- (IBAction)goBackBut;
- (IBAction)onEdit;
- (IBAction)onTrash;
- (IBAction)onCloseEdit;
- (IBAction)onClearChat;
- (IBAction)onCancelSearch:(id)sender;

- (void)AddInvitation : (NSString*)email;
- (void)GetInvitation;

@end
