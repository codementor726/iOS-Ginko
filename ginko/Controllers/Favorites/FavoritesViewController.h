//
//  FavoritesViewController.h
//  ginko
//
//  Created by stepanekdavid on 3/25/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavoritesViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIScrollViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UIButton *btnEdit;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBarForList;
@property (weak, nonatomic) IBOutlet UITableView *tblContact;
@property (weak, nonatomic) IBOutlet UIView *emptyView;

- (IBAction)onEdit:(id)sender;
- (IBAction)onBack:(id)sender;
- (IBAction)onAdd:(id)sender;

@end
