//
//  ExchangedInfoCell.m
//  Ginko
//
//  Created by Qi Song on 29/3/14.
//  Copyright (c) 2014 Qi Song. All rights reserved.
//
// --- Headers ---;
#import "ExchangedInfoCell.h"
#import "UIImageView+AFNetworking.h"
#import "LocalDBManager.h"
// --- Defines ---;
// ExchangedInfoCell Class;
@implementation ExchangedInfoCell

@synthesize profileImageView;
@synthesize pingArea;
@synthesize lastDate;
@synthesize sessionId;
@synthesize delegate;
@synthesize contactId;
@synthesize contactInfo;
@synthesize btnPhone;
@synthesize btnContact;
@synthesize arrPhone;

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    profileImageView.layer.cornerRadius = profileImageView.frame.size.height / 2.0f;
    profileImageView.layer.masksToBounds = YES;
    profileImageView.layer.borderColor = [UIColor colorWithRed:128.0/256.0 green:100.0/256.0 blue:162.0/256.0 alpha:1.0f].CGColor;
    profileImageView.layer.borderWidth = 1.0f;
}

- (void)setPhoto:(NSString *)photo
{
    [profileImageView setImageWithURL:[NSURL URLWithString:photo] placeholderImage:nil];
}

- (void)setPingLocation:(CGFloat)pingLatitude pingLongitude:(CGFloat)pingLongitude
{
    CLLocation *someLocation=[[CLLocation alloc] initWithLatitude:pingLatitude longitude:pingLongitude];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:someLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if(placemarks.count){
            CLPlacemark * placemark = [placemarks objectAtIndex:0];
            pingArea.text = @"";
            if (placemark.locality)
            {
                pingArea.text = [NSString stringWithFormat:@"%@", placemark.locality];
            }
            if (placemark.administrativeArea)
            {
                if (![pingArea.text isEqualToString:@""])
                    pingArea.text = [NSString stringWithFormat:@"%@, ", pingArea.text];
                pingArea.text = [NSString stringWithFormat:@"%@%@", pingArea.text, placemark.administrativeArea];
            }
            if (placemark.country)
            {
                if (![pingArea.text isEqualToString:@""])
                    pingArea.text = [NSString stringWithFormat:@"%@, ", pingArea.text];
                pingArea.text = [NSString stringWithFormat:@"%@%@", pingArea.text, placemark.country];
            }
        }
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)populateCellWithContact:(SearchedContact*)contact {
    NSString *contactDic = contact.contact.data;
//    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//    NSDictionary *dict = [appDelegate.exchangedList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(contact_id == %@)", contact.contact_id]].firstObject;
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[contactDic dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    
    NSString * firstName = [dict objectForKey:@"first_name"];
    NSString * lastName = [dict objectForKey:@"last_name"];
    [self setPhoto:[dict objectForKey:@"profile_image"]];
    self.username.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    self.contactId = [dict objectForKey:@"contact_id"];
//    [self setPingLocation:[[dict objectForKey:@"latitude"] floatValue] pingLongitude:[[dict objectForKey:@"longitude"] floatValue]];
    
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setTimeZone:[NSTimeZone localTimeZone]];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate * lastTime = [df dateFromString:[dict objectForKey:@"found_time"]];
    [df setDateFormat:@"MMMM dd, yyyy"];
    NSString * foundTime = [df stringFromDate:lastTime];
    self.lastDate.text = foundTime;
    
//    if (!self.pingArea.text.length) {
        [self setPingLocation:[contact.latitude floatValue] pingLongitude:[contact.longitude floatValue]];
//    }
    /*
    NSDate * lastTime = contact.found_time;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MMMM dd, yyyy"];
    NSString * foundTime = [df stringFromDate:lastTime];
    self.lastDate.text = foundTime;*/
    
    self.contactInfo = dict;
//    self.arrPhone = [self GetPhonesFromPurple:dict];
    self.arrPhone = dict[@"phones"];
    self.sessionId = @"";
    if ([contact.sharing_status integerValue] != 4)
        [self.btnPhone setImage:[UIImage imageNamed:@"BtnPhone.png"] forState:UIControlStateNormal];
    else
        [self.btnPhone setImage:[UIImage imageNamed:@"EditContact.png"] forState:UIControlStateNormal];
    
    
}

- (NSMutableArray *)GetPhonesFromPurple : (NSDictionary *)_dict
{
    NSArray * homeArray = [[_dict objectForKey:@"home"] objectForKey:@"fields"];
    NSArray * workArray = [[_dict objectForKey:@"work"] objectForKey:@"fields"];
    
    NSMutableArray *phoneArray = [[NSMutableArray alloc] init];
    
    for (int i = 0 ; i < [homeArray count] ; i++)
    {
        NSDictionary * dict = [homeArray objectAtIndex:i];
        if ([[dict objectForKey:@"field_type"] isEqualToString:@"phone"] || [[dict objectForKey:@"field_name"] isEqualToString:@"Mobile"] || [[dict objectForKey:@"field_name"] isEqualToString:@"Mobile#2"] || [[dict objectForKey:@"field_name"] isEqualToString:@"Phone#2"] || [[dict objectForKey:@"field_name"] isEqualToString:@"Phone#3"])
            [phoneArray addObject:[dict objectForKey:@"field_value"]];
    }
    
    for (int i = 0 ; i < [workArray count] ; i++)
    {
        NSDictionary * dict = [workArray objectAtIndex:i];
        if ([[dict objectForKey:@"field_type"] isEqualToString:@"phone"] || [[dict objectForKey:@"field_name"] isEqualToString:@"Mobile"] || [[dict objectForKey:@"field_name"] isEqualToString:@"Mobile#2"] || [[dict objectForKey:@"field_name"] isEqualToString:@"Phone#2"] || [[dict objectForKey:@"field_name"] isEqualToString:@"Phone#3"])
            [phoneArray addObject:[dict objectForKey:@"field_value"]];
    }
    
    return phoneArray;
}



#pragma mark - ActionSheet Delegate

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
                    [delegate didCallVideo:contactInfo];
                }else if(buttonIndex == 1){
                    [delegate didCallVoice:contactInfo];
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
                    [delegate didCallVideo:contactInfo];
                }else if(buttonIndex == 1){
                    [delegate didCallVoice:contactInfo];
                }else{
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [CommonMethods removeNanString:[arrPhone objectAtIndex:0]]]]];
                }
                break;
            case 103:
                if (buttonIndex == 0) {
                    [delegate didCallVideo:contactInfo];
                }else if(buttonIndex == 1){
                    [delegate didCallVoice:contactInfo];
                }
                break;
            default:
                break;
        }
    }
}

- (IBAction)onPhone:(id)sender
{
    [delegate hideKeyBoard];
    int sharingStatus = [[contactInfo objectForKey:@"sharing_status"] intValue];
    
    if (sharingStatus != 4)
    {
        if ([arrPhone count] == 0)
        {
            //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"Oops! No registered phone numbers." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            //[alertView show];
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            
            [sheet setTag:103];
            [sheet addButtonWithTitle:@"Ginko Video Call"];
            [sheet addButtonWithTitle:@"Ginko Voice Call"];
            [sheet addButtonWithTitle:@"Cancel"];
            sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
            [sheet showInView:self];
            [delegate didPhone:sheet];
        }
        else if ([arrPhone count] == 1){
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [CommonMethods removeNanString:[arrPhone objectAtIndex:0]]]]];
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            
            [sheet setTag:102];
            [sheet addButtonWithTitle:@"Ginko Video Call"];
            [sheet addButtonWithTitle:@"Ginko Voice Call"];
            [sheet addButtonWithTitle:[arrPhone objectAtIndex:0]];
            [sheet addButtonWithTitle:@"Cancel"];
            sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
            [sheet showInView:self];
            [delegate didPhone:sheet];
        }
        else
        {
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            
            [sheet setTag:100];
            [sheet addButtonWithTitle:@"Ginko Video Call"];
            [sheet addButtonWithTitle:@"Ginko Voice Call"];
            
            for (int i = 0; i < [arrPhone count]; i++)
                [sheet addButtonWithTitle:[arrPhone objectAtIndex:i]];
            
            [sheet addButtonWithTitle:@"Cancel"];
            sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
            [sheet showInView:self];
            [delegate didPhone:sheet];
        }
    }
    else
        [delegate didEdit:contactInfo];
}

- (IBAction)onContact:(id)sender
{
    [delegate didChat:contactInfo];
}

@end
