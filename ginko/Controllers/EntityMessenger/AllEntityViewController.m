//
//  AllEntityViewController.m
//  ginko
//
//  Created by stepanekdavid on 4/19/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "AllEntityViewController.h"
#import "LocalDBManager.h"
#import "UIImageView+AFNetworking.h"
#import "SubEntityPreviewCell.h"
#import "EntityViewController.h"
#import <CCBottomRefreshControl/UIScrollView+BottomRefreshControl.h>
#import "YYYCommunication.h"

@interface AllEntityViewController ()<EntityViewControllerDelegate>{

    NSMutableArray *allLocations;

    UIImageView *profileImg;
    AppDelegate *appDelegate;
    UIRefreshControl *refreshControl;
    
    NSInteger currentLocationCount;
    NSMutableDictionary *loadedEntitydata;
}
@end

@implementation AllEntityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackArrow"] style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    currentLocationCount = 21;
    _getCurrentGPSCallTimer = [[NSTimer alloc] init];
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_locationManager requestWhenInUseAuthorization];
    }
    appDelegate = [AppDelegate sharedDelegate];
    _currentLocationforMultiLocations = appDelegate.currentLocationforMultiLocations;
    
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusDenied) {
        NSString *title;
        title = (status == kCLAuthorizationStatusDenied)?@"Location services are off" : @"Background location is not enabled";
        NSString *message = @"To use background location you must turn on 'Always' or 'While Using the App' in the Location Services Settings";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
        [alert show];
    }
    
    allLocations = [NSMutableArray new];
    self.title = @"Preview";
    [_tableView registerNib:[UINib nibWithNibName:@"SubEntityPreviewCell" bundle:nil] forCellReuseIdentifier:@"SubEntityPreviewCell"];
    
    loadedEntitydata = [[NSMutableDictionary alloc] init];
    loadedEntitydata = [_entityData mutableCopy];
    
    [self reloadEntity];
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.triggerVerticalOffset = 100.;
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];    
    self.tableView.bottomRefreshControl = refreshControl;

}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [_locationManager startUpdatingLocation];
    
    _getCurrentGPSCallTimer = [NSTimer scheduledTimerWithTimeInterval:(3.0) target:self selector:@selector(repeatLocationUpdating) userInfo:nil repeats:YES];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_locationManager stopUpdatingLocation];
    [_getCurrentGPSCallTimer invalidate];
    _getCurrentGPSCallTimer = nil;
    
    appDelegate.currentLocationforMultiLocations = _currentLocationforMultiLocations;
}
- (void)repeatLocationUpdating{
    [_locationManager startUpdatingLocation];
}
- (void)reloadEntity {
    [allLocations removeAllObjects];
    NSMutableArray * sortedMtArray = [NSMutableArray new];
    sortedMtArray = loadedEntitydata[@"infos"];
    
    //sort by gps location
    NSArray *orderedUsers = [sortedMtArray sortedArrayUsingComparator:^(id a,id b) {
        NSArray *userA = (NSArray *)a;
        NSArray *userB = (NSArray *)b;
        
        if ([[userA valueForKey:@"latitude"] isKindOfClass:[NSNull class]] && ![[userB valueForKey:@"latitude"] isKindOfClass:[NSNull class]]) {
            return NSOrderedDescending;
        }else if (![[userA valueForKey:@"latitude"] isKindOfClass:[NSNull class]] && [[userB valueForKey:@"latitude"] isKindOfClass:[NSNull class]]){
            return NSOrderedAscending;
        }else if ([[userA valueForKey:@"latitude"] isKindOfClass:[NSNull class]] && [[userB valueForKey:@"latitude"] isKindOfClass:[NSNull class]]){
            return NSOrderedSame;
        }else {
            CGFloat aLatitude = [[userA valueForKey:@"latitude"] floatValue];
            CGFloat aLongitude = [[userA valueForKey:@"longitude"] floatValue];
            CLLocation *participantALocation = [[CLLocation alloc] initWithLatitude:aLatitude longitude:aLongitude];
            
            CGFloat bLatitude = [[userB valueForKey:@"latitude"] floatValue];
            CGFloat bLongitude = [[userB valueForKey:@"longitude"] floatValue];
            CLLocation *participantBLocation = [[CLLocation alloc] initWithLatitude:bLatitude longitude:bLongitude];
            
            CLLocation *myLocation = [[CLLocation alloc] initWithLatitude:_currentLocationforMultiLocations.latitude longitude:_currentLocationforMultiLocations.longitude];
            
            CLLocationDistance distanceA = [participantALocation distanceFromLocation:myLocation];
            CLLocationDistance distanceB = [participantBLocation distanceFromLocation:myLocation];
            if (distanceA < distanceB) {
                return NSOrderedAscending;
            } else if (distanceA > distanceB) {
                return NSOrderedDescending;
            } else {
                return NSOrderedSame;
            }

        }
    }];
    
    //update EntityData by Sorted Data
    for (int i = 0; i < orderedUsers.count; i ++) {
        [allLocations addObject:orderedUsers[i]];
    }
    
    profileImg = [[UIImageView alloc] init];
    // parse profile image
    NSString *profileImageUrl = loadedEntitydata[@"profile_image"];
    
    if (profileImageUrl && ![profileImageUrl isEqualToString:@""]) {
        NSString *localFilePath = [LocalDBManager checkCachedFileExist:profileImageUrl];
        if (localFilePath) {
            // load from local
            profileImg.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:localFilePath]];
        } else {
            [profileImg cancelImageRequestOperation];
            [profileImg setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:profileImageUrl]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                [profileImg setImage:image];
                [LocalDBManager saveImage:image forRemotePath:profileImageUrl];
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to load wallpaper image." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }];
        }
    } else {
        profileImg.image = [UIImage imageNamed:@"entity-dummy"];
    }
    
    [_tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)cancel:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(returnAllEntityIsFollowing: isFavorite:)])
        [_delegate returnAllEntityIsFollowing:_isFollowing isFavorite:_isFavorite];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [allLocations count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SubEntityPreviewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SubEntityPreviewCell"];
    
    cell.subEntityImg.image =  profileImg.image;
    
    NSMutableDictionary *dict = [allLocations objectAtIndex:indexPath.row][@"fields"];
    
    
    cell.lblLocation.text = @"Can't Location field!";
    cell.lblLocation.textColor=[UIColor lightGrayColor];
    
    for (NSDictionary *fieldDic in dict) {
        NSString *fieldName = fieldDic[@"field_name"];
        if ([fieldName  isEqual: @"Address"]) {
            cell.lblLocation.text = fieldDic[@"field_value"];
            cell.lblLocation.textColor=[UIColor blackColor];
        }
    }
    if([[allLocations objectAtIndex:indexPath.row][@"address_confirmed"] intValue] == 0){
        cell.lblDistance.text = @"No address!";
        cell.lblDistance.textColor = [UIColor lightGrayColor];
    }else
    {
        //calculate distance
        CGFloat aLatitude = [[allLocations objectAtIndex:indexPath.row][@"latitude"] floatValue];
        CGFloat aLongitude = [[allLocations objectAtIndex:indexPath.row][@"longitude"] floatValue];
        CLLocation *participantALocation = [[CLLocation alloc] initWithLatitude:aLatitude longitude:aLongitude];
        CLLocation *myLocation = [[CLLocation alloc] initWithLatitude:_currentLocationforMultiLocations.latitude longitude:_currentLocationforMultiLocations.longitude];
        
        CLLocationDistance distanceA = [participantALocation distanceFromLocation:myLocation];
        
        cell.lblDistance.text = [NSString stringWithFormat:@"%0.2f mi", ((int)((distanceA / 1609.344)*100))/100.f];
        cell.lblDistance.textColor = [UIColor blackColor];
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    EntityViewController *vc = [[EntityViewController alloc] initWithNibName:@"EntityViewController" bundle:nil];
    vc.entityData = loadedEntitydata;
    vc.infoId = (int)[[[allLocations objectAtIndex:indexPath.row] valueForKey:@"info_id"] integerValue] ;
    vc.isFollowing = _isFollowing;
    vc.isFavorite = _isFavorite;
    vc.isMultiLocations = true;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation * location = locations.lastObject;
    
    CLLocation *oldLocation = [[CLLocation alloc] initWithLatitude:_currentLocationforMultiLocations.latitude longitude:_currentLocationforMultiLocations.longitude];
    
    CLLocationDistance distance = [oldLocation distanceFromLocation:location];
    
    if (distance > 50.0) {
        _currentLocationforMultiLocations = location.coordinate;
        [allLocations removeAllObjects];
        NSMutableArray * sortedMtArray = [NSMutableArray new];
        sortedMtArray = loadedEntitydata[@"infos"];
        
        //sort by gps location
        NSArray *orderedUsers = [sortedMtArray sortedArrayUsingComparator:^(id a,id b) {
            NSArray *userA = (NSArray *)a;
            NSArray *userB = (NSArray *)b;
            if ([[userA valueForKey:@"latitude"] isKindOfClass:[NSNull class]] && ![[userB valueForKey:@"latitude"] isKindOfClass:[NSNull class]]) {
                return NSOrderedDescending;
            }else if (![[userA valueForKey:@"latitude"] isKindOfClass:[NSNull class]] && [[userB valueForKey:@"latitude"] isKindOfClass:[NSNull class]]){
                return NSOrderedAscending;
            }else if ([[userA valueForKey:@"latitude"] isKindOfClass:[NSNull class]] && [[userB valueForKey:@"latitude"] isKindOfClass:[NSNull class]]){
                return NSOrderedSame;
            }else {
                CGFloat aLatitude = [[userA valueForKey:@"latitude"] floatValue];
                CGFloat aLongitude = [[userA valueForKey:@"longitude"] floatValue];
                CLLocation *participantALocation = [[CLLocation alloc] initWithLatitude:aLatitude longitude:aLongitude];
                
                CGFloat bLatitude = [[userB valueForKey:@"latitude"] floatValue];
                CGFloat bLongitude = [[userB valueForKey:@"longitude"] floatValue];
                CLLocation *participantBLocation = [[CLLocation alloc] initWithLatitude:bLatitude longitude:bLongitude];
                
                CLLocation *myLocation = [[CLLocation alloc] initWithLatitude:_currentLocationforMultiLocations.latitude longitude:_currentLocationforMultiLocations.longitude];
                
                CLLocationDistance distanceA = [participantALocation distanceFromLocation:myLocation];
                CLLocationDistance distanceB = [participantBLocation distanceFromLocation:myLocation];
                if (distanceA < distanceB) {
                    return NSOrderedAscending;
                } else if (distanceA > distanceB) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedSame;
                }
            }
        }];
        
        //update EntityData by Sorted Data
        for (int i = 0; i < orderedUsers.count; i ++) {
            [allLocations addObject:orderedUsers[i]];
        }

        [_tableView reloadData];
    }
    [_locationManager stopUpdatingLocation];
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}
#pragma mark - EntityViewControllerDelegate
- (void)returnIsFollowing:(BOOL)isFollowing{
    _isFollowing = isFollowing;
}
- (void)returnIsFavorite:(BOOL)isFavorite{
    _isFavorite = isFavorite;
}
-(void)getEntityFollowerView
{
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        NSDictionary *result = _responseObject;
        if ([[result objectForKey:@"success"] boolValue]) {
            
            if ([_responseObject[@"data"][@"infos"] count] > 1){
                [refreshControl endRefreshing];
                currentLocationCount = currentLocationCount + 20;
                NSLog(@"%ld", (long)currentLocationCount);
                NSMutableArray *loadedEntity = [[NSMutableArray alloc] init];
                loadedEntity = [loadedEntitydata[@"infos"] mutableCopy];
                for (NSDictionary *dict in _responseObject[@"data"][@"infos"]) {
                    [loadedEntity addObject:dict];
                }
                [loadedEntitydata setObject:loadedEntity forKey:@"infos"];
                [self reloadEntity];
            }else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"GINKO" message:@"Oops! Current Entity hasn't informations!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                
                [alertView show];
            }
        } else {
            NSDictionary *dictError = [result objectForKey:@"err"];
            if (dictError) {
                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:[dictError objectForKey:@"errMsg"]];
                if ([[NSString stringWithFormat:@"%@",[dictError objectForKey:@"errCode"]] isEqualToString:@"700"]) {
                    [CommonMethods loadFetchAllEntityNew];
                    [[NSNotificationCenter defaultCenter] postNotificationName:CONTACT_SYNC_NOTIFICATION object:nil];
                }
            } else {
                [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Failed to connect to server!"];
            }
        }
    };
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
        [CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Internet Connection Error!"];
    };
    
    [[YYYCommunication sharedManager] GetEntityByFollowrNew:[AppDelegate sharedDelegate].sessionId entityid:[_entityData objectForKey:@"entity_id"] infoFrom:[NSString stringWithFormat:@"%ld", (long)currentLocationCount] infoCount:@"20" latitude:[AppDelegate sharedDelegate].currentLocationforMultiLocations.latitude longitude:[AppDelegate sharedDelegate].currentLocationforMultiLocations.longitude successed:successed failure:failure];
}
- (void)refresh:(UIRefreshControl *)refreshControl {
    NSLog(@"refesh contact list");
    if (currentLocationCount < _locationsTotal) {
        [self getEntityFollowerView];
    }else{
        [refreshControl endRefreshing];
    }
}
@end
