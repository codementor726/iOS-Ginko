//
//  ContactCell.m
//  Ginko
//
//  Created by Qi Song on 29/3/14.
//  Copyright (c) 2014 Qi Song. All rights reserved.
//
// --- Headers ---;
#import "TileViewCell.h"
#import "UIImageView+AFNetworking.h"

// --- Defines ---;
// ContactCell Class;
@implementation TileViewCell

@synthesize profileImageView;
@synthesize firstName;
@synthesize lastName;
@synthesize contactBut;
@synthesize phoneBut;

// Created by Zhun L.
@synthesize statusImageView;
@synthesize backgroundView;
@synthesize imgViewNew;
@synthesize imgViewBg;
@synthesize type;
@synthesize arrPhone;
@synthesize arrEmail;
//------------------

@synthesize delegate;
@synthesize sessionId;
@synthesize contactId;
@synthesize curContact;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
}

- (void)setBorder
{
    if (type == 1)
    {
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height / 2.0f;
        profileImageView.layer.masksToBounds = YES;
        profileImageView.layer.borderColor = [UIColor colorWithRed:128.0/256.0 green:100.0/256.0 blue:162.0/256.0 alpha:1.0f].CGColor;
        profileImageView.layer.borderWidth = 1.2f;
        
        [imgViewBg setBackgroundColor:[UIColor colorWithRed:128.0/256.0 green:100.0/256.0 blue:162.0/256.0 alpha:1.0f]];
    }
    else if (type == 2)
    {
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height / 2.0f;
        profileImageView.layer.masksToBounds = YES;
        profileImageView.layer.borderColor = [UIColor grayColor].CGColor;
        profileImageView.layer.borderWidth = 1.2f;
        
        [imgViewBg setBackgroundColor:[UIColor grayColor]];
    }
}

- (void)setPhoto:(NSString *)photo
{
    [profileImageView setImageWithURL:[NSURL URLWithString:photo] placeholderImage:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

//- (void)onChat:(id)sender
//{
//    [delegate viewChat:sessionId contactId:contactId];
//}

#pragma - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != (actionSheet.numberOfButtons - 1))
    {
        switch ([actionSheet tag]) {
            case 100:
                if ([[arrPhone objectAtIndex:buttonIndex] rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]].location == NSNotFound) {
                    [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Invalid mobile number." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    return;
                }
                if (buttonIndex == 0) {
                    [delegate didCallVideo:curContact];
                }else if(buttonIndex == 1){
                    [delegate didCallVoice:curContact];
                }else{
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [CommonMethods removeNanString:[arrPhone objectAtIndex:buttonIndex-2]]]]];
                }
                break;
            case 102:
                if ([[arrPhone objectAtIndex:0] rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]].location == NSNotFound) {
                    [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Invalid mobile number." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    return;
                }
                
                if (buttonIndex == 0) {
                    [delegate didCallVideo:curContact];
                }else if(buttonIndex == 1){
                    [delegate didCallVoice:curContact];
                }else{
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [CommonMethods removeNanString:[arrPhone objectAtIndex:0]]]]];
                }
                break;
            case 103:
                if (buttonIndex == 0) {
                    [delegate didCallVideo:curContact];
                }else if(buttonIndex == 1){
                    [delegate didCallVoice:curContact];
                }
                break;
            case 101:
                [delegate sendMail: [arrEmail objectAtIndex:0]];
            default:
                break;
        }
    }
}

- (IBAction)onPhone:(id)sender
{
    [self.superview.superview.superview endEditing:YES];
    int sharingStatus = 0;
    
    if (type == 1)
        sharingStatus = [[curContact objectForKey:@"sharing_status"] intValue];
    
    if (sharingStatus != 4)
    {
        if ([arrPhone count] == 0)
        {
            if (type ==1) {
                UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
                
                [sheet setTag:103];
                [sheet addButtonWithTitle:@"Ginko Video Call"];
                [sheet addButtonWithTitle:@"Ginko Voice Call"];
                [sheet addButtonWithTitle:@"Cancel"];
                sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
                [sheet showInView:self];
                [APPDELEGATE dismissActionSheetWithConference:sheet];
                
            }else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"Oops! No registered phone numbers." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
        }
        else if ([arrPhone count] == 1){
            if (type == 1) {
                UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
                
                [sheet setTag:102];
                [sheet addButtonWithTitle:@"Ginko Video Call"];
                [sheet addButtonWithTitle:@"Ginko Voice Call"];
                [sheet addButtonWithTitle:[arrPhone objectAtIndex:0]];
                [sheet addButtonWithTitle:@"Cancel"];
                sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
                [sheet showInView:self];
                [APPDELEGATE dismissActionSheetWithConference:sheet];
            }else{
                if ([[arrPhone objectAtIndex:0] rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]].location == NSNotFound) {
                    [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Invalid mobile number." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    return;
                }
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [CommonMethods removeNanString:[arrPhone objectAtIndex:0]]]]];
            }
            
        }
        else
        {
            if (type == 1) {
                UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
                
                [sheet setTag:100];
                [sheet addButtonWithTitle:@"Ginko Video Call"];
                [sheet addButtonWithTitle:@"Ginko Voice Call"];
                for (int i = 0; i < [arrPhone count]; i++)
                    [sheet addButtonWithTitle:[arrPhone objectAtIndex:i]];
                
                [sheet addButtonWithTitle:@"Cancel"];
                sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
                [sheet showInView:self];
                [APPDELEGATE dismissActionSheetWithConference:sheet];
            }else{
                UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
                
                [sheet setTag:100];
                for (int i = 0; i < [arrPhone count]; i++)
                    [sheet addButtonWithTitle:[arrPhone objectAtIndex:i]];
                
                [sheet addButtonWithTitle:@"Cancel"];
                sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
                [sheet showInView:self];
                [APPDELEGATE dismissActionSheetWithConference:sheet];
            }
        }
    }
    else
        [delegate didEdit:curContact];
}

- (IBAction)onContact:(id)sender
{
    switch (type) {
        case 2:
            if ([arrEmail count] == 0)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"Oops! No registered emails." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
            else if ([arrEmail count] == 1)
            {
                [delegate sendMail:[arrEmail objectAtIndex:0]];
            }
            else
            {
                UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
                
                [sheet setTag:100];
                
                for (int i = 0; i < [arrEmail count]; i++)
                    [sheet addButtonWithTitle:[arrEmail objectAtIndex:i]];
                
                [sheet addButtonWithTitle:@"Cancel"];
                sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
                [sheet showInView:self];
            }
            break;
        case 1:
            [delegate didChat:curContact];
            break;
        default:
            break;
    }
}

@end
