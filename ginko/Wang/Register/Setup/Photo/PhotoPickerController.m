//
//  PhotoPickerController.m
//  XChangeWithMe
//
//  Created by Xin YingTai on 25/5/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import "PhotoPickerController.h"
#import "PhotoViewController.h"

@interface PhotoPickerController ()

@end

@implementation PhotoPickerController

- (id)initWithType:(NSInteger)type entityID:(NSString *)entityID
{
    self = [super init];
    BOOL createFlag = NO;
    if (self) {
        self.type = type;
        
        NSString* nibName = nil;
        
        switch (self.type) {
            case 1:
                nibName = @"PhotoViewController_Home";
                break;
            case 2:
                nibName = @"PhotoViewController_Work";
                break;
			
			case 3:
				nibName = @"PhotoViewController_Entity";
				break;
            case 4:
                nibName = @"PhotoViewController_Home";
                createFlag = YES;//create your home profile
                break;
            default:
                nibName = @"PhotoViewController";
                break;
        }
        
        PhotoViewController *viewController = [[PhotoViewController alloc] initWithNibName:nibName bundle:nil];
        viewController.type = self.type;
        viewController.isCreate = createFlag;//create flag for signup
        if (entityID) {
            viewController.entityID = entityID;
        }
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
