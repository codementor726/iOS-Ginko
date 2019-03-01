//
//  GroupsViewController.h
//  ginko
//
//  Created by stepanekdavid on 3/19/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXReorderableCollectionViewFlowLayout.h"
#import "GroupCollectionViewCell.h"
@interface GroupsViewController : UIViewController<LXReorderableCollectionViewDataSource, LXReorderableCollectionViewDelegateFlowLayout,GroupCollectionViewCellDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *addGroupsCollectionView;
@property (nonatomic, retain) IBOutlet UIView *navView;
@property (nonatomic, assign) IBOutlet UIView *emptyView;
@property (weak, nonatomic) IBOutlet UIButton *btEdit;
@property (weak, nonatomic) IBOutlet UIButton *btSort;
@property (weak, nonatomic) IBOutlet UIButton *btAdd;
@property (weak, nonatomic) IBOutlet UIButton *btBack;
@property (weak, nonatomic) IBOutlet UILabel *lblAdd;
@property (weak, nonatomic) IBOutlet UIButton *btCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnJoinDirectory;


- (IBAction)onBack:(id)sender;
- (IBAction)onAddContact:(id)sender;
- (IBAction)onSort:(id)sender;
- (IBAction)onEdit:(id)sender;
- (IBAction)onCancel:(id)sender;

- (IBAction)onJoinDirectory:(id)sender;

@end
