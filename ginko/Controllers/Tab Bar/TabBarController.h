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

@interface TabBarController : UITabBarController
{
    
}

// Functions;
+ (TabBarController *)sharedController;
- (void)changeThumbEnabled:(BOOL)flag;
- (void)enableButtons:(BOOL)enable;
- (void)setBadgeOnItem:(NSInteger)index value:(NSString*)value;

@end
