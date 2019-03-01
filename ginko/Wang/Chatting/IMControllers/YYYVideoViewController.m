//
//  YYYVideoViewController.m
//  InstantMessenger
//
//  Created by Wang MeiHua on 4/7/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import "YYYVideoViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface YYYVideoViewController ()

@end

@implementation YYYVideoViewController

@synthesize strUrl;
@synthesize player;

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
	
	UIButton *_btBack = [UIButton buttonWithType:UIButtonTypeCustom];
	[_btBack setFrame:CGRectMake(0, 0, 17, 28)];
	[_btBack setImage:[UIImage imageNamed:@"img_back"] forState:UIControlStateNormal];
	[_btBack addTarget:self action:@selector(btBackClick:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem * btBack = [[UIBarButtonItem alloc] initWithCustomView:_btBack];
	[self.navigationItem setLeftBarButtonItem:btBack];
	[self.navigationItem setTitle:@"Video"];
	
	player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:strUrl]];
	[[player view] setFrame:[self.view bounds]]; // Frame must match parent view
	[self.view addSubview:[player view]];
	
    // Do any additional setup after loading the view.
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
