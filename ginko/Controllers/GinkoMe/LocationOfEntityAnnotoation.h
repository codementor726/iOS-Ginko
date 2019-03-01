//
//  LocationOfEntityAnnotoation.h
//  ginko
//
//  Created by stepanekdavid on 6/6/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface LocationOfEntityAnnotoation : NSObject<MKAnnotation> {
    CLLocationDegrees _latitude;
    CLLocationDegrees _longitude;
    NSNumber *entityId;
    NSString *profileImg;
    NSArray *locations;
}

@property (nonatomic, retain) NSString *profileImg;
@property (nonatomic, retain) NSNumber *entityId;
@property (nonatomic, retain) NSArray *locations;

- (id)initWithLatitude:(CLLocationDegrees)latitude
          andLongitude:(CLLocationDegrees)longitude;
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;
- (void)setProfile:(NSString *)imageUrl entityID:(NSNumber *)entity;
@end
