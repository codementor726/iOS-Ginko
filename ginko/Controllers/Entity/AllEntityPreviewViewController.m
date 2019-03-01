//
//  AllEntityPreviewViewController.m
//  ginko
//
//  Created by stepanekdavid on 4/19/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "AllEntityPreviewViewController.h"
#import "LocalDBManager.h"
#import "UIImageView+AFNetworking.h"
#import "SubEntityPreviewCell.h"
#import "PreviewEntityViewController.h"
#import "YYYCommunication.h"
@interface AllEntityPreviewViewController ()<UIAlertViewDelegate>{
    
    NSMutableArray *allLocations;
    
    UIImageView *profileImg;
    
    NSMutableDictionary *_entityData;
    
    AppDelegate *appDelegate;
    
}
@end

@implementation AllEntityPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackArrow"] style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    
    allLocations = [NSMutableArray new];
    
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
        alert.tag = 1001;
        [alert show];
    }
    
    self.title = @"Preview";
    [_tableView registerNib:[UINib nibWithNibName:@"SubEntityPreviewCell" bundle:nil] forCellReuseIdentifier:@"SubEntityPreviewCell"];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [_locationManager startUpdatingLocation];
    _getCurrentGPSCallTimer = [NSTimer scheduledTimerWithTimeInterval:(3.0) target:self selector:@selector(repeatLocationUpdating) userInfo:nil repeats:YES];
    
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        if ([_responseObject[@"success"] intValue] == 1) {
            _entityData = _responseObject[@"data"];
            [allLocations removeAllObjects];
            [self reloadEntity];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to get entity info, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    };
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to get entity info, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    };
    
    [[YYYCommunication sharedManager] GetEntityDetail:[AppDelegate sharedDelegate].sessionId
                                             entityid:_entityId
                                            successed:successed
                                              failure:failure];
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
    sortedMtArray = _entityData[@"infos"];
    //    for (NSArray *tmp in arrLocationsOfSubEntity){
    //        CGFloat aLatitude = [[tmp valueForKey:@"latitude"] floatValue];
    //        CGFloat aLongitude = [[tmp valueForKey:@"longitude"] floatValue];
    //        CLLocation *participantALocation = [[CLLocation alloc] initWithLatitude:aLatitude longitude:aLongitude];
    //        CLLocation *myLocation = [[CLLocation alloc] initWithLatitude:[AppDelegate sharedDelegate].currentLocation.latitude longitude:[AppDelegate sharedDelegate].currentLocation.longitude];
    //
    //        CLLocationDistance distanceA = [participantALocation distanceFromLocation:myLocation];
    //        NSLog(@"distance----%f",distanceA);
    //    }
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
    NSString *profileImageUrl = _entityData[@"profile_image"];
    
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
    if (_delegate && [_delegate respondsToSelector:@selector(didFinishAllEntity:)])
        [_delegate didFinishAllEntity:_entityData];
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
    PreviewEntityViewController *vc = [[PreviewEntityViewController alloc] initWithNibName:@"PreviewEntityViewController" bundle:nil];
    vc.isCreate = _isCreate;
    vc.infoId = (int)[[[allLocations objectAtIndex:indexPath.row] valueForKey:@"info_id"] integerValue] ;
    vc.entityId = [_entityData objectForKey:@"entity_id"];
    vc.isMultiLocation = YES;
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
        sortedMtArray = _entityData[@"infos"];
        //    for (NSArray *tmp in arrLocationsOfSubEntity){
        //        CGFloat aLatitude = [[tmp valueForKey:@"latitude"] floatValue];
        //        CGFloat aLongitude = [[tmp valueForKey:@"longitude"] floatValue];
        //        CLLocation *participantALocation = [[CLLocation alloc] initWithLatitude:aLatitude longitude:aLongitude];
        //        CLLocation *myLocation = [[CLLocation alloc] initWithLatitude:[AppDelegate sharedDelegate].currentLocation.latitude longitude:[AppDelegate sharedDelegate].currentLocation.longitude];
        //
        //        CLLocationDistance distanceA = [participantALocation distanceFromLocation:myLocation];
        //        NSLog(@"distance----%f",distanceA);
        //    }
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
@end
