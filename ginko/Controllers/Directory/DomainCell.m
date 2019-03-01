//
//  DomainCell.m
//  ginko
//
//  Created by stepanekdavid on 12/26/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "DomainCell.h"

@implementation DomainCell
+ (DomainCell *)sharedCell
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"DomainCell" owner:nil options:nil];
    DomainCell *cell = [array objectAtIndex:0];
    return cell;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setCurDomain:(NSString *)domainItem
{
    _curDict = domainItem;
}

- (IBAction)onRemove:(id)sender {
    [_delegate onRemoveDomain:self curDomain:_curDict];
}
@end
