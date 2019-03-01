//
//  AllEntityPreviewViewController.h
//  ginko
//
//  Created by stepanekdavid on 4/19/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>

@protocol AllEntityPreviewViewControllerDelegate <NSObject>

- (void)didFinishAllEntity:(NSMutableDictionary *)entityDataChanged;

@end

@interface AllEntityPreviewViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// set from outside
@property (nonatomic, assign) BOOL isCreate;
@property (nonatomic, strong) NSString *entityId;

@property (weak, nonatomic) id<AllEntityPreviewViewControllerDelegate> delegate;

@property (nonatomic, retain) CLLocationManager * locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D currentLocationforMultiLocations;
@property (nonatomic, retain) NSTimer * getCurrentGPSCallTimer;
-(void)repeatLocationUpdating;
@end
