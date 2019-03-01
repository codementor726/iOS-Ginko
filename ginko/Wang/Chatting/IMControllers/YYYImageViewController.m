//
//  YYYImageViewController.m
//  InstantMessenger
//
//  Created by Wang MeiHua on 4/7/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import "YYYImageViewController.h"
#import "UIImageView+AFNetworking.h"

@interface YYYImageViewController ()

@end

@implementation YYYImageViewController

@synthesize strUrl;

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
	
	[imvPhoto setImageWithURL:[NSURL URLWithString:strUrl]];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self.navigationController setNavigationBarHidden:NO];
}

-(IBAction)btBackClick:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
