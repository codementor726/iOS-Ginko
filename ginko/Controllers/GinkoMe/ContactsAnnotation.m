//
//  ContactsAnnotation.m
//  ginko
//
//  Created by stepanekdavid on 6/9/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "ContactsAnnotation.h"

@interface ContactsAnnotation()
@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;

@end

@implementation ContactsAnnotation

@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize contactId = _contactId;
@synthesize profileImg = _profileImg;
@synthesize contacts = _contacts;
@synthesize type = _type;

- (id)initWithLatitude:(CLLocationDegrees)latitude
          andLongitude:(CLLocationDegrees)longitude {
    if (self = [super init]) {
        self.latitude = latitude;
        self.longitude = longitude;
    }
    return self;
}

- (void)setProfile:(NSString *)imageUrl contactID:(NSNumber *)contact{
    self.profileImg = imageUrl;
    self.contactId = contact;
}
- (CLLocationCoordinate2D)coordinate {
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = self.latitude;
    coordinate.longitude = self.longitude;
    return coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    self.latitude = newCoordinate.latitude;
    self.longitude = newCoordinate.longitude;
}
@end