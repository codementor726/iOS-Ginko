//
//  LocationOfEntityAnnotoation.m
//  ginko
//
//  Created by stepanekdavid on 6/6/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "LocationOfEntityAnnotoation.h"

@interface LocationOfEntityAnnotoation()
@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;

@end

@implementation LocationOfEntityAnnotoation

@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize entityId = _entiyId;
@synthesize profileImg = _profileImg;
@synthesize locations = _locations;

- (id)initWithLatitude:(CLLocationDegrees)latitude
          andLongitude:(CLLocationDegrees)longitude {
    if (self = [super init]) {
        self.latitude = latitude;
        self.longitude = longitude;
    }
    return self;
}

- (void)setProfile:(NSString *)imageUrl entityID:(NSNumber *)entity{
    self.profileImg = imageUrl;
    self.entityId = entity;
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
