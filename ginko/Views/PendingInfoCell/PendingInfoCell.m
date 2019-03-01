//
//  NotExchangedInfoCell.m
//  Ginko
//
//  Created by Qi Song on 29/3/14.
//  Copyright (c) 2014 Qi Song. All rights reserved.
//
// --- Headers ---;
#import "PendingInfoCell.h"
#import "UIImageView+AFNetworking.h"

// --- Defines ---;
// NotExchangedInfoCell Class;
@implementation PendingInfoCell

@synthesize profileImageView;
@synthesize username;
@synthesize lastDate;
@synthesize delegate;
@synthesize contactInfo;
@synthesize pingArea;

- (void)awakeFromNib
{
    [super awakeFromNib];
    profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2.0f;
    profileImageView.layer.masksToBounds = YES;
    profileImageView.layer.borderColor = [UIColor colorWithRed:128.0/256.0 green:100.0/256.0 blue:162.0/256.0 alpha:1.0f].CGColor;
    profileImageView.layer.borderWidth = 1.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)onShareInfo:(id)sender
{
    [delegate shareInfo:contactInfo];
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

@end
