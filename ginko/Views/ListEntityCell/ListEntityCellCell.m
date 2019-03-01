//
//  ListEntityCellCell.m
//  GINKO
//
//  Created by mobidev on 7/30/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import "ListEntityCellCell.h"
#import "UIImageView+AFNetworking.h"

@implementation ListEntityCellCell
@synthesize imgProfile, lblName;
@synthesize delegate;
@synthesize curDict = _curDict;

+ (ListEntityCellCell *)sharedCell
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"ListEntityCellCell" owner:nil options:nil];
    ListEntityCellCell *cell = [array objectAtIndex:0];
    
    return cell;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [lblName setTextColor:[UIColor colorWithRed:110.0f/255.0f green:75.0f/255.0f blue:154.0f/255.0f alpha:1.0f]];
    
    imgProfile.layer.cornerRadius = imgProfile.frame.size.height / 2.0f;
    imgProfile.layer.masksToBounds = YES;
    imgProfile.layer.borderColor = [UIColor colorWithRed:128.0/256.0 green:100.0/256.0 blue:162.0/256.0 alpha:1.0f].CGColor;
    imgProfile.layer.borderWidth = 1.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCurDict:(NSDictionary *)curDict
{
    _curDict = curDict;
    [imgProfile setImageWithURL:[NSURL URLWithString:[_curDict objectForKey:@"profile_image"]] placeholderImage:[UIImage imageNamed:@"entity-dummy"]];
    lblName.text = [_curDict objectForKey:@"name"];
}

- (NSMutableArray *)getPhonesFromEntity
{
    return _curDict[@"phones"];
}

#pragma - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != (actionSheet.numberOfButtons - 1))
    {
        switch ([actionSheet tag]) {
            case 100:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [CommonMethods removeNanString:[[self getPhonesFromEntity] objectAtIndex:buttonIndex]]]]];
                break;
            default:
                break;
        }
    }
}

#pragma mark - Actions
- (IBAction)onPhone:(id)sender
{
    NSMutableArray *arrPhones = [self getPhonesFromEntity];
    if ([arrPhones count] == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"Oops! No registered phone numbers." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    else if ([arrPhones count] == 1)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [CommonMethods removeNanString:[arrPhones objectAtIndex:0]]]]];
    else
    {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        
        for (int i = 0; i < [arrPhones count]; i++)
            [sheet addButtonWithTitle:[arrPhones objectAtIndex:i]];
        
        [sheet addButtonWithTitle:@"Cancel"];
        sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
        [sheet showInView:self];
        sheet.tag = 100;
    }
    
    [delegate didPhone:_curDict];
}

- (IBAction)onWall:(id)sender
{
    [delegate didWall:_curDict];
}


@end
