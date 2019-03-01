//
//  PhotoPickerController.m
//  XChangeWithMe
//
//  Created by Xin YingTai on 25/5/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import "IMPhotoPickerController.h"
#import "IMPhotoViewController.h"

@interface IMPhotoPickerController ()

@end

@implementation IMPhotoPickerController

- (id)initWithType
{
    self = [super init];
    
    if (self) {
        IMPhotoViewController *viewController = [[IMPhotoViewController alloc] initWithNibName:@"IMPhotoViewController" bundle:nil];
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
