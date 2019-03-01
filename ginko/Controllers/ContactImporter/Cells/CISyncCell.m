//
//  CISyncCell.m
//  ContactImporter
//
//  Created by mobidev on 6/13/14.
//  Copyright (c) 2014 Ron. All rights reserved.
//

#import "CISyncCell.h"

@implementation CISyncCell
@synthesize lblFirstMiddleName, lblLastName, btnEntity, btnHome, btnWork;
@synthesize curIndex = _curIndex;
@synthesize curDict = _curDict;
@synthesize delegate;

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

+ (CISyncCell *)sharedCell
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"CISyncCell" owner:nil options:nil];
    CISyncCell *cell = [array objectAtIndex:0];
    
    return cell;
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    [super setSelected:selected animated:animated];
//}

- (void)setCurIndex:(int)curIndex
{
    _curIndex = curIndex;
}

- (void)setCurDict:(NSMutableDictionary *)curDict
{
    _curDict = curDict;
    lblFirstMiddleName.text = [NSString stringWithFormat:@"%@ %@", [curDict objectForKey:@"first_name"], [curDict objectForKey:@"middle_name"]];
    lblLastName.text = [curDict objectForKey:@"last_name"];
    [self colorTypeButtons];
}

- (void)colorTypeButtons
{
    [btnEntity setSelected:NO];
    [btnWork setSelected:NO];
    [btnHome setSelected:NO];
    
    switch ([[_curDict objectForKey:@"type"] intValue]) {
        case 0:
            [btnEntity setSelected:YES];
            break;
        case 2:
            [btnWork setSelected:YES];
            break;
        case 1:
            [btnHome setSelected:YES];
            break;
        default:
            break;
    }
}

#pragma mark - Actions
- (IBAction)onType:(id)sender
{
    if([btnEntity isEqual:sender]) {
        btnEntity.selected = !btnEntity.selected;
        btnWork.selected = btnHome.selected = NO;
    }
    else if([btnWork isEqual:sender]) {
        btnWork.selected = !btnWork.selected;
        btnEntity.selected = btnHome.selected = NO;
    }
    else if([btnHome isEqual:sender]) {
        btnHome.selected = !btnHome.selected;
        btnEntity.selected = btnWork.selected = NO;
    }
    if ([(id)delegate respondsToSelector:@selector(didType:tag:)]) {
        [delegate didType:_curDict tag:((UIButton *)sender).tag];
    }
}

- (IBAction)onName:(id)sender
{
    if ([(id)delegate respondsToSelector:@selector(didName:)]) {
        [delegate didName:_curDict];
    }
}

@end
