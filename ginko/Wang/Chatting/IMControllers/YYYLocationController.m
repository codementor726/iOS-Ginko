//
//  YYYLocationController.m
//  InstantMessenger
//
//  Created by Wang MeiHua on 2/28/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import "YYYLocationController.h"
#import "AppDelegate.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Place.h"
#import "PlaceMark.h"
#import "MBProgressHUD.h"

#import "VideoVoiceConferenceViewController.h"

@interface YYYLocationController ()<UIAlertViewDelegate>

@end

@implementation YYYLocationController

@synthesize chatviewcontroller, entityChatController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	lstLocations = [[NSMutableArray alloc] init];
	
	locationmanager = [[CLLocationManager alloc] init];
    locationmanager.delegate = self;
    locationmanager.desiredAccuracy = kCLLocationAccuracyBest;
    locationmanager.distanceFilter = kCLDistanceFilterNone;
    
    if ([locationmanager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationmanager requestWhenInUseAuthorization];
    }
    
    NSLog(@"UpdateLocation");
    [locationmanager startUpdatingLocation];
	
	// Do any additional setup after loading the view.
    self.title = @"Location";
    btDone = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Checkmark"] style:UIBarButtonItemStylePlain target:self action:@selector(btAcceptClick:)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackArrow"] style:UIBarButtonItemStylePlain target:self action:@selector(btBackClick:)];
    self.navigationItem.rightBarButtonItem = btDone;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    if (_navBarColor) {
        [self.navigationController.navigationBar setBarTintColor:COLOR_PURPLE_THEME];
    }else{
        [self.navigationController.navigationBar setBarTintColor:COLOR_GREEN_THEME];
    }
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
		fLat = currentLocation.coordinate.latitude;
		fLng = currentLocation.coordinate.longitude;
		
		[locationmanager stopUpdatingLocation];
		[self getCurrentAddress];
	}
}
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusDenied) {
        NSString *title;
        title = (status == kCLAuthorizationStatusDenied)?@"Location services are off" : @"Background location is not enabled";
        NSString *message = @"To use background location you must turn on 'Always' or 'While Using the App' in the Location Services Settings";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
        [alert show];
    }
    
}
-(void)getCurrentAddress
{
	[lstLocations removeAllObjects];
	
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
	
	CLGeocoder *geocoder = [[CLGeocoder alloc] init];
	CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:fLat longitude:fLng];
	[geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
		
		[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
		
        if (error == nil && [placemarks count] > 0) {
            if ([placemarks count] == 0) {
                [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Internet Connection Error!"];
				return;
			}
			
			for (CLPlacemark *placemark in placemarks)
			{
				[lstLocations addObject:placemark];
				
				Place *pt = [[Place alloc] init];
				pt.latitude		= placemark.location.coordinate.latitude;
				pt.longitude	= placemark.location.coordinate.longitude;
				pt.name = placemark.name;
				
				[mapView addAnnotation:[[PlaceMark alloc] initWithPlace:pt]];
			}
			
			CLPlacemark *pmark = [placemarks objectAtIndex:0];
			
			CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(pmark.location.coordinate.latitude, pmark.location.coordinate.longitude);
			MKCoordinateSpan span = MKCoordinateSpanMake(1, 1);
			MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
			
			[mapView setRegion:region animated:TRUE];
            
			[tblLocations reloadData];
            
            [tblLocations selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
            
            btDone.enabled = YES;
		}
    }];
}

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
	searchBar.showsCancelButton = YES;
	return YES;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	[self.view endEditing:YES];
	searchBar.showsCancelButton = NO;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[self.view endEditing:YES];
	searchBar.showsCancelButton = NO;
	[self searchLocation:searchBar.text];
}

-(void)addPin:(float)latitude :(float)longtitude
{
	CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longtitude);
    MKCoordinateSpan span = MKCoordinateSpanMake(1, 1);
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
	
    [mapView setRegion:region animated:TRUE];
	
	Place *pt = [[Place alloc] init];
	pt.latitude		= latitude;
	pt.longitude	= longtitude;
	
	PlaceMark *placemark = [[PlaceMark alloc] initWithPlace:pt];
	[mapView removeAnnotations:mapView.annotations];
	
	[mapView addAnnotation:placemark];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [lstLocations count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *strIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strIdentifier];
	if (!cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strIdentifier];
	}
	
	CLPlacemark *placemark = [lstLocations objectAtIndex:indexPath.row];
//	
//	if ([lstSelected containsObject:placemark])
//	{
//		[cell setBackgroundColor:[UIColor colorWithRed:235/255.0f green:235/255.0f blue:235/255.0f alpha:1.0f]];
//	}
//	else
//	{
//		[cell setBackgroundColor:[UIColor whiteColor]];
//	}

	NSString *strAddress = @"";
	
	NSString *str = placemark.country;
	if (![str isEqual:[NSNull null]] && str)
	{
		strAddress = [NSString stringWithFormat:@"%@ %@",strAddress,str];
	}
	
	str = placemark.administrativeArea;
	if (![str isEqual:[NSNull null]] && str)
	{
		strAddress = [NSString stringWithFormat:@"%@ %@",strAddress,str];
	}
		
	str = placemark.subAdministrativeArea;
	if (![str isEqual:[NSNull null]] && str)
	{
		strAddress = [NSString stringWithFormat:@"%@ %@",strAddress,str];
	}
		
	str = placemark.locality;
	if (![str isEqual:[NSNull null]] && str)
	{
		strAddress = [NSString stringWithFormat:@"%@ %@",strAddress,str];
	}
	
	str = placemark.subLocality;
	if (![str isEqual:[NSNull null]] && str)
	{
		strAddress = [NSString stringWithFormat:@"%@ %@",strAddress,str];
	}
	
	str = placemark.thoroughfare;
	if (![str isEqual:[NSNull null]] && str)
	{
		strAddress = [NSString stringWithFormat:@"%@ %@",strAddress,str];
	}
	
	str = placemark.subThoroughfare;
	if (![str isEqual:[NSNull null]] && str)
	{
		strAddress = [NSString stringWithFormat:@"%@ %@",strAddress,str];
	}
	
	cell.textLabel.font = [UIFont systemFontOfSize:13.0f];
	cell.textLabel.numberOfLines = 0;
		
	
	NSArray *lines = placemark.addressDictionary[ @"FormattedAddressLines"];
	NSString *addressString = [lines componentsJoinedByString:@", "];
//	[addressString stringByReplacingOccurrencesOfString:@"\n" withString:@", "];
	
	[cell.textLabel setText:addressString];
	
	
	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	CLPlacemark *pmark = [lstLocations objectAtIndex:indexPath.row];
		
	CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(pmark.location.coordinate.latitude, pmark.location.coordinate.longitude);
	MKCoordinateSpan span = MKCoordinateSpanMake(1, 1);
	MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
	
	[mapView setRegion:region animated:TRUE];
}

-(void)searchLocation:(NSString*)address
{
	[lstLocations removeAllObjects];
	[mapView removeAnnotations:mapView.annotations];
	
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
	
	CLGeocoder *geocoder = [[CLGeocoder alloc] init];
	
	[geocoder geocodeAddressString:address
				 completionHandler:^(NSArray* placemarks, NSError* error){
				 
					 [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
					 
					 if ([placemarks count] == 0) {
                         [tblLocations reloadData];
                         btDone.enabled = NO;
                         [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not find address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
						 return;
					 }
					 
					 for (CLPlacemark *placemark in placemarks) {
						 [lstLocations addObject:placemark];
						 
						 Place *pt = [[Place alloc] init];
						 pt.latitude		= placemark.location.coordinate.latitude;
						 pt.longitude	= placemark.location.coordinate.longitude;
						 pt.name = placemark.name;
						 
						 [mapView addAnnotation:[[PlaceMark alloc] initWithPlace:pt]];
					 }
					 
					 CLPlacemark *pmark = [placemarks objectAtIndex:0];
					 
					 CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(pmark.location.coordinate.latitude, pmark.location.coordinate.longitude);
					 MKCoordinateSpan span = MKCoordinateSpanMake(1, 1);
					 MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
					 
					 [mapView setRegion:region animated:TRUE];
					 					 
					 [tblLocations reloadData];
                     
                     [tblLocations selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
                     
                     btDone.enabled = YES;
	}];
}

-(UIImage*)imageCapture:(CGRect)_frame
{
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGRect rect= _frame;
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([viewImage CGImage], rect);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    
    return image;
}

-(IBAction)btBackClick:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)btAcceptClick:(id)sender
{
    if (chatviewcontroller) {
        [chatviewcontroller sendMap:[(CLPlacemark*)[lstLocations objectAtIndex:0] location].coordinate.latitude :[(CLPlacemark*)[lstLocations objectAtIndex:0] location].coordinate.longitude];
    } else if (entityChatController) {
        [entityChatController sendMap:[(CLPlacemark*)[lstLocations objectAtIndex:0] location].coordinate.latitude :[(CLPlacemark*)[lstLocations objectAtIndex:0] location].coordinate.longitude];
    }
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

- (void)movePushNotificationConferenceViewController:(NSDictionary *)dic{
    VideoVoiceConferenceViewController *vc = [[VideoVoiceConferenceViewController alloc] initWithNibName:@"VideoVoiceConferenceViewController" bundle:nil];
    vc.infoCalling = dic;
    vc.boardId = [dic objectForKey:@"board_id"];
    if ([[dic objectForKey:@"callType"] integerValue] == 1) {
        vc.conferenceType = 1;
    }else{
        vc.conferenceType = 2;
    }
    vc.conferenceName = [dic objectForKey:@"uname"];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
