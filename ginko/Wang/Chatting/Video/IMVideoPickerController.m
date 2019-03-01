//
//  IMVideoPickerController.m
//  XChangeWithMe
//
//  Created by Xin YingTai on 25/5/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import "IMVideoPickerController.h"
#import "IMVideoViewController.h"

@interface IMVideoPickerController ()

@end

@implementation IMVideoPickerController

- (id)initWithType
{
    self = [super init];
    
    if (self) {

        IMVideoViewController *viewController = [[IMVideoViewController alloc] initWithNibName:@"IMVideoViewController" bundle:nil];
        self.viewControllers = @[viewController];
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationBar setTranslucent:NO];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
