//
//  GroupCollectionViewCell.m
//  ginko
//
//  Created by stepanekdavid on 3/19/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "GroupCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"
@implementation GroupCollectionViewCell

@synthesize btRemoveGroup;
@synthesize delegate;
@synthesize GroupId;
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
    }
    return self;
}
- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _groupImg.contentMode = UIViewContentModeScaleAspectFill;
    _borderView.layer.cornerRadius = CGRectGetWidth(_borderView.bounds) / 2;
    _groupImg.layer.cornerRadius = CGRectGetWidth(_groupImg.bounds) / 2;
    _groupImg.layer.borderWidth = 1;
    _groupImg.layer.borderColor = COLOR_PURPLE_THEME.CGColor;
    [_groupImg setImageWithURL:[NSURL URLWithString:@"http://image.ginko.mobi/Photos/no-face.png"]];
    
    _groupCellsImg.contentMode = UIViewContentModeScaleAspectFill;
    _groupCellsView.layer.cornerRadius = CGRectGetWidth(_groupCellsView.bounds) / 2;
    _groupCellsImg.layer.cornerRadius = CGRectGetWidth(_groupCellsImg.bounds) / 2;
    _groupCellsImg.layer.borderWidth = 1;
    _groupCellsImg.layer.borderColor = COLOR_PURPLE_THEME.CGColor;
    
    btRemoveGroup.contentMode = UIViewContentModeScaleAspectFill;
    _deleteView.layer.cornerRadius = CGRectGetWidth(_deleteView.bounds) / 2;
    btRemoveGroup.layer.cornerRadius = CGRectGetWidth(btRemoveGroup.bounds) / 2;
}
#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        [delegate deleteCurrentGroup:GroupId type:[[_GroupInfo objectForKey:@"type"] integerValue]];
    }
}
-(IBAction)onRemoveGroup:(id)sender{
    if ([[_GroupInfo objectForKey:@"type"] integerValue] !=2) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Do you want to permanently remove this group?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        [alertView show];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Do you want to permanently remove this directory?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        [alertView show];
    }
}
@end
