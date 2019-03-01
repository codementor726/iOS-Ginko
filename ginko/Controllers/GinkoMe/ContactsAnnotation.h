//
//  ContactsAnnotation.h
//  ginko
//
//  Created by stepanekdavid on 6/9/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface ContactsAnnotation : NSObject<MKAnnotation> {
    CLLocationDegrees _latitude;
    CLLocationDegrees _longitude;
    NSNumber *contactId;
    NSString *profileImg;
    NSArray *contacts;
    NSInteger type;
}
@property  NSInteger type;
@property (nonatomic, retain) NSString *profileImg;
@property (nonatomic, retain) NSNumber *contactId;
@property (nonatomic, retain) NSArray *contacts;

- (id)initWithLatitude:(CLLocationDegrees)latitude
          andLongitude:(CLLocationDegrees)longitude;
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;
- (void)setProfile:(NSString *)imageUrl entityID:(NSNumber *)entity;
@end
