//
//  FavoritesViewController.m
//  ginko
//
//  Created by stepanekdavid on 3/25/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "FavoritesViewController.h"

@interface FavoritesViewController ()
{
    NSMutableArray *arrFavorites;
}

@end

@implementation FavoritesViewController

@synthesize navView,tblContact,emptyView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:navView];
    
    arrFavorites = [[NSMutableArray alloc] init];
    
    [self getFavorites];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [navView removeFromSuperview];
}

#pragma  mark - WebApi Intergration
- (void)getFavorites{
    if ([arrFavorites count]) {
        tblContact.hidden = NO;
        emptyView.hidden = YES;
    } else {
        tblContact.hidden = YES;
        emptyView.hidden = NO;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onEdit:(id)sender {
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onAdd:(id)sender {
}
@end
