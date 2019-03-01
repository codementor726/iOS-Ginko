//
//  SettingViewController.m
//  Ginko
//
//  Created by Mobile on 4/1/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

@synthesize appDelegate;

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
    
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    titleArray = [NSArray arrayWithObjects:@"ON", @"1 mins", @"5 mins", @"15 mins", @"30 mins", @"1 hr", @"6 hrs", @"OFF", nil];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:navView];
    if (appDelegate.locationFlag)
    {
        [mainTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:appDelegate.intervalIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
    }
    else
    {
        [mainTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:7 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [navView removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [titleArray count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    titleArray = [NSArray arrayWithObjects:@"ON", @"1 min", @"5 mins", @"15 mins", @"30 mins", @"1 hr", @"6 hrs", @"OFF", nil];
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingCell"];
    }
    cell.textLabel.text = [titleArray objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor colorWithRed:110.0f/255.0f green:75.0f/255.0f blue:154.0f/255.0f alpha:1.0f];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * turn_on = @"";
    
    BOOL tFlag = NO;
    if (indexPath.row == 7)
    {
        turn_on = @"false";
    }
    else
    {
        tFlag = YES;
        turn_on = @"true";
    }
    
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        NSLog(@"%@",[_responseObject objectForKey:@"data"]);
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            appDelegate.locationFlag = tFlag;
            appDelegate.intervalIndex = indexPath.row;
            if (tFlag)
            {
                appDelegate.didFinishFlag = NO;
                [appDelegate.locationManager startUpdatingLocation];
                [appDelegate refreshLocationUpdating];
            }
            else
            {
                [appDelegate GetContactList];
                [appDelegate.locationManager stopUpdatingLocation];
            }
            [[NSUserDefaults standardUserDefaults] setInteger:indexPath.row forKey:@"INTERVAL_INDEX"];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        NSLog(@"Change GPS Status failed");
    } ;
    
    [[Communication sharedManager] ChangeGPSStatus:[AppDelegate sharedDelegate].sessionId trun_on:turn_on successed:successed failure:failure];
}

@end
