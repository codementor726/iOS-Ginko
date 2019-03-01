//
//  PhotoBackgroundViewController.h
//  GINKO
//
//  Created by MobiDev on 12/20/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoViewController.h"

@interface PhotoBackgroundViewController : UIViewController
{
    IBOutlet UIScrollView *scvMain;
}

@property (nonatomic, retain) PhotoViewController *parentController;

@end
