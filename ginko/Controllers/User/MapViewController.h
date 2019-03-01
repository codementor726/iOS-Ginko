//
//  MapViewController.h
//  Ginko
//
//  Created by Mobile on 4/8/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController
{
    IBOutlet MKMapView * mapView;
    IBOutlet UIView * navView;
}

@property (nonatomic, retain) IBOutlet UILabel * pingLocationName;
@property (nonatomic, assign) CLLocationCoordinate2D pingLocation;
@property (nonatomic, retain) AppDelegate * appDelegate;
@property (nonatomic, retain) NSString * locationName;
- (IBAction)onBack;

@end
