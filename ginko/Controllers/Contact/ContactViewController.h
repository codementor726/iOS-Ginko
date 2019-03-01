//
//  ContactViewController.h
//  Ginko
//
//  Created by Qi Song on 29/3/14.
//  Copyright (c) 2014 Qi Song. All rights reserved.
//
// --- Headers ---;

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ContactCell.h"
#import "TileViewCell.h"
#import "TitleEntityCell.h"
#import "ListEntityCellCell.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MessageUI.h>

// --- Defines ---;
// ContactViewController Class;
@interface ContactViewController : UIViewController <ContactCellDelegate, TileViewCellDelegate, TitleEntityCellDelegate, ListEntityCellDelegate, MFMailComposeViewControllerDelegate, NSFetchedResultsControllerDelegate,CLLocationManagerDelegate>
{
    // Created by Zhun L.
    NSMutableDictionary* contactList;
    //NSArray* totalList;
    NSArray* keyList;
    
    IBOutlet UIButton *btnAll;
    IBOutlet UIButton *btnHome;
    IBOutlet UIButton *btnWork;
    IBOutlet UIButton *btnEntity;
    IBOutlet UIButton *btnFavorite;
    //-------------------
    
    IBOutlet UITableView *tblForContact;
    BOOL locationFlag;
    
    IBOutlet UIView * navView;
    IBOutlet UIButton * gpsBut;
    IBOutlet UIButton * closeBut;
    IBOutlet UIImageView *imgViewInvalid;
    
    
    IBOutlet UIView *emptyView;
    
    // Created by Zhun L.
    IBOutlet UIView *blankView;
    IBOutlet UIImageView *backgroundImgView;
    //-------------------
    
    BOOL pushFlag;
    
    NSString *sort;
    int viewType;
    int filterType;
    
    BOOL callFuncForUpdatingUserlocation;

}

@property (nonatomic, retain) AppDelegate * appDelegate;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

- (IBAction)onScan:(id)sender;
- (IBAction)onGinkoMe:(id)sender;
- (IBAction)onContactBuilder;
//- (IBAction)onInviteContacts:(id)sender;
- (IBAction)onImportContact:(id)sender;

- (IBAction)onBtnContacts:(id)sender;
- (IBAction)onBtnRequests:(id)sender;
- (IBAction)onMenu;
- (IBAction)onSearch;
- (IBAction)onClose;
- (IBAction)onInviteContact:(id)sender;
- (IBAction)onAddGroups:(id)sender;




//chatting class
- (IBAction)onChat:(id)sender;

// Created by Zhun L.
- (void)sortContactsByLetters;
//- (void)GetContacts : (NSString *)_sortby
//              search: (NSString *)_search
//            category: (NSString *)_category;
//- (NSMutableArray *)GetPhonesFromPurple : (NSDictionary *)_dict;
//- (NSMutableArray *)GetEmailsFromPurple : (NSDictionary *)_dict;
//- (NSMutableArray *)GetPhonesFromGrey : (NSDictionary *)_dict;
//- (NSMutableArray *)GetEmailsFromGrey : (NSDictionary *)_dict;
- (IBAction)onSortBtn:(id)sender;
- (void)sendMail:(NSString *)_email;
//-------------------

@property (nonatomic, retain) IBOutlet UIView *viewChatBadge;
@property (nonatomic, retain) IBOutlet UILabel *lblChatBadge;
@property (nonatomic, retain) IBOutlet UIView *viewSproutBadge;
@property (nonatomic, retain) IBOutlet UILabel *lblSproutBadge;
@property (nonatomic, retain) IBOutlet UIView *viewExchangeBadge;
@property (nonatomic, retain) IBOutlet UILabel *lblExchangeBadge;

@property (nonatomic, retain) CLLocationManager * locationManagerForThumbPrint;
@property (nonatomic, retain) NSTimer * gpsCallTimerForThumbPrint;
- (void)showCountNum;
//- (void)getFriends;

// Thumb
- (IBAction)touchDownThumb:(id)sender;
- (IBAction)touchUpThumb:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *thumbButton;
- (void)displayGPSButton;

// Check contact id exist
- (NSString *)isContactIdExist:(NSString *)contactId;
- (void)reloadContacts;

@end
