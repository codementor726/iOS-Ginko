//
//  TitleEntityCell.m
//  GINKO
//
//  Created by mobidev on 7/25/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import "TitleEntityCell.h"
#import "UIImageView+AFNetworking.h"

@implementation TitleEntityCell
@synthesize imgProfile, lblName;
@synthesize delegate;
@synthesize curDict = _curDict;

+ (TitleEntityCell *)sharedCell
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"TitleEntityCell" owner:nil options:nil];
    TitleEntityCell *cell = [array objectAtIndex:0];
    
    return cell;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [lblName setTextColor:[UIColor colorWithRed:110.0f/255.0f green:75.0f/255.0f blue:154.0f/255.0f alpha:1.0f]];
    
    imgProfile.layer.cornerRadius = imgProfile.frame.size.height / 2.0f;
    imgProfile.layer.masksToBounds = YES;
    imgProfile.layer.borderColor = [UIColor colorWithRed:128.0/256.0 green:100.0/256.0 blue:162.0/256.0 alpha:1.0f].CGColor;
    imgProfile.layer.borderWidth = 1.2f;
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

#pragma mark - Actions
- (IBAction)onPhone:(id)sender
{
    NSMutableArray *arrPhones = [_curDict objectForKey:@"phones"];
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
    }
    
    [delegate didPhone:_curDict];
}

- (IBAction)onWall:(id)sender
{
    [delegate didWall:_curDict];
}

@end
