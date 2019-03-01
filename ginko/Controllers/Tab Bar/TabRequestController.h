//
//  TabBarController.h
//  Ginko
//
//  Created by Qi Song on 29/3/14.
//  Copyright (c) 2014 Qi Song. All rights reserved.
//
// --- Headers ---;
#import <UIKit/UIKit.h>

// --- Defines ---;
// TabBarController Class;
@interface TabRequestController : UITabBarController
{
}
// Functions;
+ (TabRequestController *)sharedController;
- (void)showTabbarImage:(BOOL)show;
@end
