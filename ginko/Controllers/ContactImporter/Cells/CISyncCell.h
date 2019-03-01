//
//  CISyncCell.h
//  ContactImporter
//
//  Created by mobidev on 6/13/14.
//  Copyright (c) 2014 Ron. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SyncCellDelegate

@optional;
- (void)didType:(NSDictionary *)dict tag:(int)tag;
- (void)didName:(NSDictionary *)dict;

@end

@interface CISyncCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *nameButton;
@property (nonatomic, assign) IBOutlet UILabel *lblFirstMiddleName;
@property (nonatomic, assign) IBOutlet UILabel *lblLastName;
@property (nonatomic, assign) IBOutlet UIButton *btnEntity;
@property (nonatomic, assign) IBOutlet UIButton *btnHome;
@property (nonatomic, assign) IBOutlet UIButton *btnWork;

@property (nonatomic) int curIndex;
@property (nonatomic, strong) NSMutableDictionary *curDict;
@property (nonatomic, assign) id<SyncCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *maskViewForSel;

+ (CISyncCell *)sharedCell;
- (IBAction)onType:(id)sender;
- (IBAction)onName:(id)sender;

@end
