//
//  CBImportHomeViewController.m
//  GINKO
//
//  Created by mobidev on 8/7/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import "CBImportHomeViewController.h"
#import "CBImportItemViewController.h"
#import "CBImportOtherViewController.h"

@interface CBImportHomeViewController ()

@end

@implementation CBImportHomeViewController
@synthesize navView;
@synthesize btnBack, btnSkip, viewBottom, viewDescription;

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
    
    if (_globalData.cbIsFromMenu) {
        [self layoutMenuLink];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar addSubview:navView];
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

- (void)layoutMenuLink
{
    btnBack.hidden = NO;
    viewBottom.hidden = YES;
    CGRect frame = viewDescription.frame;
    frame.origin.y += 48;
    [viewDescription setFrame:frame];
}

#pragma mark - Actions
- (IBAction)onImportItem:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    CBImportItemViewController *vc = [[CBImportItemViewController alloc] initWithNibName:@"CBImportItemViewController" bundle:nil];
    [vc setType:(int)btn.tag];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onOther:(id)sender
{
    CBImportOtherViewController *vc = [[CBImportOtherViewController alloc] initWithNibName:@"CBImportOtherViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onSkip:(id)sender
{
    [[AppDelegate sharedDelegate] setWizardPage:@"2"];
}

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
