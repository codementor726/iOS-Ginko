//
//  VideoPickerController.m
//  XChangeWithMe
//
//  Created by Xin YingTai on 25/5/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import "VideoPickerController.h"
#import "VideoViewController.h"

@interface VideoPickerController ()

@end

@implementation VideoPickerController

- (id)initWithType:(NSInteger)type entityID:(NSString *)entityID isSetup:(BOOL)isSetup
{
    NSString* nibName = nil;
    switch (type) {
        case 1:
            nibName = @"VideoViewController_Home";
            break;
            
        case 2:
            nibName = @"VideoViewController_Work";
            break;
            
        case 3:
            nibName = @"VideoViewController_Entity";
            break;
            
        default:
            nibName = @"VideoViewController_Home";
            break;
    }
    
    VideoViewController *viewController = [[VideoViewController alloc] initWithNibName:nibName bundle:nil];
    viewController.type = type;
    viewController.isSetup = isSetup;
    if (entityID) {
        viewController.entityID = entityID;
    }
    
    self = [super initWithRootViewController:viewController];
    
    if (self) {
        self.type = type;
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
