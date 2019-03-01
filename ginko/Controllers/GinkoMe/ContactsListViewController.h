//
//  ContactsListViewController.h
//  ginko
//
//  Created by ccom on 1/8/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GinkoMeTabController.h"
#import "ExchangedInfoCell.h"
#import "NotExchangedInfoCell.h"
#import "EntityCell.h"


@interface ContactsListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIActionSheetDelegate, GinkoMeTabDelegate, ExchangedInfoCellDelegate, NotExchangedInfoCellDelegate, EntityCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *contactsTableView;
@property (strong, nonatomic) IBOutlet UIView *contactsBgView;
@property (weak, nonatomic) IBOutlet UILabel *noContactsLabel;
@property (weak, nonatomic) IBOutlet UITableView *greyTableView;
@property (strong, nonatomic) IBOutlet UIView *greyBgView;
@property (weak, nonatomic) IBOutlet UILabel *noGreysLabel;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UIButton *contactsButton;
@property (weak, nonatomic) IBOutlet UIButton *greysButton;
@property (weak, nonatomic) IBOutlet UIImageView *contactsIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *greysIndicator;

@property (weak, nonatomic) IBOutlet UILabel *lblNoContact;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIButton *btnEdit;

- (IBAction)btContactsClick:(id)sender;
- (IBAction)btGreysClick:(id)sender;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@end
