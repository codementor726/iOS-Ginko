//
//  YYYActivateViewController.m
//  XChangeWithMe
//
//  Created by Wang MeiHua on 5/21/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import "YYYActivateViewController.h"
#import "YYYLoginViewController.h"

@interface YYYActivateViewController ()

@end

@implementation YYYActivateViewController

@synthesize email;

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
	
	[lblEmail setText:email];
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES];
}

-(IBAction)btLoginClick:(id)sender
{
	YYYLoginViewController *viewcontroller = [[YYYLoginViewController alloc] initWithNibName:@"YYYLoginViewController" bundle:nil];
	[self.navigationController pushViewController:viewcontroller animated:YES];
}

-(IBAction)btBackClick:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
