//
//  YYYLocationController.h
//  InstantMessenger
//
//  Created by Wang MeiHua on 2/28/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "YYYChatViewController.h"
#import "EntityAdminChatViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface YYYLocationController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,CLLocationManagerDelegate>
{
	IBOutlet MKMapView		*mapView;
	IBOutlet UITableView	*tblLocations;
	
	NSMutableArray *lstLocations;
	
	IBOutlet UISearchBar	*srbLocation;
	
	CLLocation *location;
    CLLocationManager *locationmanager;
	
	float fLat;
	float fLng;
    UIBarButtonItem *btDone;
}

@property (nonatomic, assign) BOOL navBarColor;
@property (nonatomic,retain) YYYChatViewController *chatviewcontroller;
@property (nonatomic,retain) EntityAdminChatViewController *entityChatController;

- (void)movePushNotificationConferenceViewController:(NSDictionary *)dic;
@end
