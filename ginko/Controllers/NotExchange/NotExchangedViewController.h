//
//  NotExchangedViewController.h
//  Ginko
//
//  Created by Qi Song on 29/3/14.
//  Copyright (c) 2014 Qi Song. All rights reserved.
//
// --- Headers ---;
#import <UIKit/UIKit.h>
#import "NotExchangedInfoCell.h"
#import "EntityCell.h"

// --- Defines ---;
// NotExchangedViewController Class;
@interface NotExchangedViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, NotExchangedInfoCellDelegate, EntityCellDelegate, UIActionSheetDelegate, UIAlertViewDelegate>
{
//    IBOutlet UITableView *tblForContact;
    IBOutlet UISearchBar * contactSearch;
    //Custom UINavigationView
    IBOutlet UIView * navView;
    IBOutlet UIButton * backBut;
    IBOutlet UILabel * titleLabel;
    IBOutlet UIButton * gpsBut;
    IBOutlet UIButton * trashBut;
    
    //Edit
    IBOutlet UIButton * closeBut;
    
    IBOutlet UILabel *lblOn1;
    
    IBOutlet UIButton *btnThumb;
    __weak IBOutlet UILabel *lblSorry;
    
    BOOL searchFlag;
    BOOL searchStartFlag;
    
    NSMutableArray * contactList;
    NSMutableArray * searchList;
    
    NSString * contactIds;
    NSString * entityIds;
    
}

@property (nonatomic, retain) AppDelegate * appDelegate;
@property (nonatomic, retain) IBOutlet UITableView *tblForContact;

- (void)touchDown;
- (void)touchUp;

- (IBAction)goBackBut;
- (IBAction)onGPSBut;

- (IBAction)onEdit;
- (IBAction)onTrash;
- (IBAction)onCloseEdit;

- (IBAction)touchDownThumb:(id)sender;
- (IBAction)touchUpInside:(id)sender;

- (void)displayGPSButton;

@end
