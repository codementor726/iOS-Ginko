//
//  DomainCell.h
//  ginko
//
//  Created by stepanekdavid on 12/26/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DomainCell;
@protocol DomainCellDelegate

@optional;
- (void)onRemoveDomain:(DomainCell *)cell curDomain:(NSDictionary *)domain;
@end

@interface DomainCell : UITableViewCell
@property (nonatomic, retain) NSDictionary *curDict;

+ (DomainCell *)sharedCell;

@property (nonatomic, strong) id<DomainCellDelegate> delegate;

- (void)setCurDomain:(NSString *)domainItem;

- (IBAction)onRemove:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnRemove;
@property (weak, nonatomic) IBOutlet UILabel *subDomainName;
@end
