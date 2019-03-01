//
//  DeactivateCell.m
//  ginko
//
//  Created by Lion on 6/8/15.
//  Copyright (c) 2015 com.xchangewithme. All rights reserved.
//

#import "DeactivateCell.h"

@implementation DeactivateCell
@synthesize lblReason, btnReason, dictReason = _dictReason, curIndex = _curIndex, isReasonSelected = _isReasonSelected;
@synthesize delegate;

+ (DeactivateCell *)sharedCell
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"DeactivateCell" owner:nil options:nil];
    DeactivateCell *cell = [array objectAtIndex:0];
    
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

- (void)setDictReason:(NSDictionary *)dictReason
{
    _dictReason = dictReason;
    if (_dictReason) {
        [lblReason setText:[dictReason objectForKey:@"description"]];
    } else {
        [lblReason setText:@"Other"];
    }
}

- (void)setCurIndex:(NSInteger)curIndex
{
    _curIndex = curIndex;
}

- (void)setIsReasonSelected:(BOOL)isReasonSelected
{
    _isReasonSelected = isReasonSelected;
    if (isReasonSelected) {
        [btnReason setImage:[UIImage imageNamed:@"SmallOn.png"] forState:UIControlStateNormal];
    } else {
        [btnReason setImage:[UIImage imageNamed:@"SmallOff.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)onReason:(id)sender {
    [delegate selectReason:_dictReason index:_curIndex];
}

@end
