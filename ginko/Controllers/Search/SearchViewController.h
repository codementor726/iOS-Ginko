//
//  SearchViewController.h
//  GINKO
//
//  Created by Zhun L. on 6/2/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchCell.h"
#import "EntityCell.h"

@interface SearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, SearchCellDelegate, EntityCellDelegate, UISearchBarDelegate, UIScrollViewDelegate>
{
    IBOutlet UIView * navView;
    IBOutlet UITableView *tblForContact;
    IBOutlet UISearchBar *searchBarForList;
    
    NSMutableArray* totalList;
    
    NSMutableArray* orgTotalList;
}

@property (nonatomic, retain) AppDelegate * appDelegate;
@property NSArray *contactList;
@property (nonatomic, assign) BOOL isMenu;

- (IBAction)onCloseBtn:(id)sender;

@end
