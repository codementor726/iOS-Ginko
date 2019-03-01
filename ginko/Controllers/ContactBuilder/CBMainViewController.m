//
//  CBMainViewController.m
//  GINKO
//
//  Created by mobidev on 5/17/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import "CBMainViewController.h"
#import "CBDetailViewController.h"
#import "ContactBuilderClient.h"
#import "CBEmail.h"
#import "CBCell.h"
#import "TabRequestController.h"

#import "CBImportHomeViewController.h"

@interface CBMainViewController ()
{
    NSMutableArray *arrCBEmails;
}
@end

@implementation CBMainViewController
@synthesize tblContacts, imgNoData, navView, blankView;

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
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    // self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:230.0/256.0 green:1.0f blue:190.0/256.0 alpha:1.0f];
    
    arrCBEmails = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [tblContacts deselectRowAtIndexPath:[tblContacts indexPathForSelectedRow] animated:animated];
    [self.navigationController.navigationBar addSubview:navView];
    
    [self getCBEmails];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [navView removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Get CBEmails from webservice
- (void)getCBEmails
{
    void (^successed)(id responseObject) = ^(id responseObject) {
        NSDictionary *result = responseObject;
        
        if ([[result objectForKey:@"success"] boolValue]) {
            [arrCBEmails removeAllObjects];
            NSArray *cbArray = [result objectForKey:@"data"];
            int invalidCount = 0;
            for (NSDictionary *cbDict in cbArray) {
                CBEmail *cbEmail = [[CBEmail alloc] initWithDict:cbDict];
                [arrCBEmails addObject:cbEmail];
                if (!cbEmail.valid) {
                    invalidCount++;
                }
            }
            if (invalidCount) {
                _globalData.isCBValid = NO;
            } else _globalData.isCBValid = YES;
            
            [SVProgressHUD dismiss];
            [self layoutViews];
            
        } else {
            [SVProgressHUD showErrorWithStatus:@"Failed to connect to server!"];
        }
    };
    
    void (^failure)(NSError* error) = ^(NSError* error) {
        [SVProgressHUD showErrorWithStatus:@"Failed to connect to server!"];
    };
    
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeClear];
    [[ContactBuilderClient sharedClient] getAllCBEmails:[AppDelegate sharedDelegate].sessionId successed:successed failure:failure];
}

- (void)getCBEmailByCBEmailID:(CBEmail *)curCBEmail
{
    void (^successed)(id responseObject) = ^(id responseObject) {
        NSDictionary *result = responseObject;
        
        if ([[result objectForKey:@"success"] boolValue]) {
            NSDictionary *cbDict = [result objectForKey:@"data"];
            curCBEmail.active = [[cbDict objectForKey:@"active"] isEqualToString:@"yes"] ? YES : NO;
            curCBEmail.sharing_status = [[cbDict objectForKey:@"sharing_status"] intValue];
            curCBEmail.shareHomeFields = ([cbDict objectForKey:@"shared_home_fids"] == [NSNull null]) ? @"" : [cbDict objectForKey:@"shared_home_fids"];
            curCBEmail.shareWorkFields = ([cbDict objectForKey:@"shared_work_fids"] == [NSNull null]) ? @"" : [cbDict objectForKey:@"shared_work_fids"];
            
            [SVProgressHUD dismiss];
            
            CBDetailViewController *vc = [[CBDetailViewController alloc] initWithNibName:@"CBDetailViewController" bundle:nil];
            [vc setCurCBEmail:curCBEmail];
            [self.navigationController pushViewController:vc animated:YES];
            
        } else {
            [SVProgressHUD showErrorWithStatus:@"Failed to connect to server!"];
        }
    };
    
    void (^failure)(NSError* error) = ^(NSError* error) {
        [SVProgressHUD showErrorWithStatus:@"Failed to connect to server!"];
    };
    
    [SVProgressHUD showWithStatus:@"LoadingInfo..." maskType:SVProgressHUDMaskTypeClear];
    [[ContactBuilderClient sharedClient] getCBEmailByEmailID:[AppDelegate sharedDelegate].sessionId emailID:curCBEmail.cbID successed:successed failure:failure];
}

#pragma mark - Custom Methods
- (void)layoutViews
{
    if ([arrCBEmails count] > 0) {
        [tblContacts reloadData];
        tblContacts.hidden = NO;
        blankView.hidden = YES;
        return;
    }
    else
        blankView.hidden = NO;
    
    tblContacts.hidden = YES;
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrCBEmails count];
}

- (CGFloat)tableView:( UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBCell *cell = [tblContacts dequeueReusableCellWithIdentifier:@"CBCell"];
    
    if(cell == nil)
    {
        cell = [CBCell sharedCell];
    }
    
    [cell setDelegate:self] ;
    
    [cell setCurCBEmail:[arrCBEmails objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self getCBEmailByCBEmailID:[arrCBEmails objectAtIndex:indexPath.row]];
}

#pragma mark - Actions
- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onAddNew:(id)sender
{
    CBImportHomeViewController *vc = [[CBImportHomeViewController alloc] initWithNibName:@"CBImportHomeViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onExchange:(id)sender
{
    self.navigationItem.title = @"";
    TabRequestController *tabRequestController = [TabRequestController sharedController];
    tabRequestController.selectedIndex = 2;
    // Push;
    [self.navigationController pushViewController:tabRequestController animated:YES];
}

@end
