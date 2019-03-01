//
//  YYYMapViewController.h
//  InstantMessenger
//
//  Created by Wang MeiHua on 4/7/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface YYYMapViewController : UIViewController
{
	IBOutlet MKMapView *mapView;
}

@property float flat;
@property float flng;
-(IBAction)btBackClick:(id)sender;
@end
