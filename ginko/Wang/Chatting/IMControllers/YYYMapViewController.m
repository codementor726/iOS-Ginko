//
//  YYYMapViewController.m
//  InstantMessenger
//
//  Created by Wang MeiHua on 4/7/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import "YYYMapViewController.h"

#import "Place.h"
#import "PlaceMark.h"

@interface YYYMapViewController ()

@end

@implementation YYYMapViewController

@synthesize flat;
@synthesize flng;

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
	
	[self addPin:flat :flng];
	
    // Do any additional setup after loading the view.
}

-(IBAction)btBackClick:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
