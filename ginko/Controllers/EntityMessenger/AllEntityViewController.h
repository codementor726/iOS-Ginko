//
//  AllEntityViewController.h
//  ginko
//
//  Created by stepanekdavid on 4/19/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>
@protocol AllEntityViewControllerDelegate <NSObject>

- (void)returnAllEntityIsFollowing:(BOOL)isFollowing isFavorite:(BOOL)isFavorite;

@end
@interface AllEntityViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// set from outside
@property (nonatomic, assign) BOOL isCreate;
@property (nonatomic, strong) NSDictionary *entityData;


@property (nonatomic, retain) CLLocationManager * locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D currentLocationforMultiLocations;
@property (nonatomic, retain) NSTimer * getCurrentGPSCallTimer;

@property (nonatomic, assign) BOOL isFollowing;
@property (nonatomic, assign) BOOL isFavorite;
@property (nonatomic, assign) NSInteger locationsTotal;

-(void)repeatLocationUpdating;

@property (weak, nonatomic) id<AllEntityViewControllerDelegate> delegate;
@end
