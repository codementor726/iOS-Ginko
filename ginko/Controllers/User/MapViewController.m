//
//  MapViewController.m
//  Ginko
//
//  Created by Mobile on 4/8/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController

@synthesize appDelegate;
@synthesize pingLocation;
@synthesize pingLocationName;
@synthesize locationName;

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
       
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:MKCoordinateRegionMakeWithDistance(pingLocation, 100, 100)];
    [mapView setRegion:adjustedRegion animated:YES];
    
    MKPlacemark *mPlacemark = [[MKPlacemark alloc] initWithCoordinate:pingLocation addressDictionary:nil];
    [mapView addAnnotation:mPlacemark];
//    
//    mapView.showsUserLocation = YES;
//    
    pingLocationName.text = locationName;
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:navView];
    [self.navigationItem setHidesBackButton:YES animated:NO];
//    [self.navigationController.navigationItem setHidesBackButton:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [navView removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
