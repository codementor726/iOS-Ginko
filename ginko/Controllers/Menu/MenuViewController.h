//
//  MenuViewController.h
//  GINKO
//
//  Created by Forever on 6/3/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuCell.h"

#import "AddressBook/AddressBook.h"
#import <AddressBookUI/AddressBookUI.h>

@interface MenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MenuCellDelegate, UIAlertViewDelegate>
{
    IBOutlet UIView * navView;
    IBOutlet UITableView *tblForMenu;
    IBOutlet UILabel *lblFirstName;
    IBOutlet UILabel *lblLastName;
    IBOutlet UIImageView *imgViewPhoto;
    
    IBOutlet UIButton *btnTile;
    IBOutlet UIButton *btnList;
    IBOutlet UIButton *btnChat;
    
    __weak IBOutlet UIButton *btnProfilePreView;
    NSArray *arrSections;
    NSMutableArray *arrMenuCaptions;
    NSMutableArray *arrMenuImages;
    
    NSDictionary *arrMyInfo;
    NSMutableArray* totalList;
    
    NSMutableArray *arrEntities; //Sun class
    NSMutableArray *arrDirectories;
    
    ABRecordID groupId;
}

@property (nonatomic, retain) IBOutlet UIView *viewChatBadge;
@property (nonatomic, retain) IBOutlet UILabel *lblChatBadge;

@property (nonatomic, retain) AppDelegate * appDelegate;

- (IBAction)onBack:(id)sender;
- (IBAction)onBtnViewType:(id)sender;

//chatting class
- (IBAction)onChat:(id)sender;

//PE class
- (IBAction)onProfileEdit:(id)sender;

//EE class
- (IBAction)onEditEntity:(id)sender;

- (void)startVideoCallingWithSelectedContact:(NSString *)conferecenBoardId type:(NSInteger)_type;

@end
