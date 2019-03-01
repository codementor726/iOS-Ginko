//
//  TabBarController.m
//  Ginko
//
//  Created by Qi Song on 29/3/14.
//  Copyright (c) 2014 Qi Song. All rights reserved.
//
// --- Headers ---;
#import "TabRequestController.h"

// --- Defines ---;
// TabBarController Class;

#define TABBARHEIGHT 58.0f

@interface TabRequestController () <UITabBarControllerDelegate,UIGestureRecognizerDelegate>
{
    UIImageView *tabImageView;
}

@end

@implementation TabRequestController

+ (TabRequestController *)sharedController
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"TabRequestController" owner:nil options:nil];
    TabRequestController *sharedController = [array objectAtIndex:0];
    return sharedController;
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
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    self.delegate = self;
    
    self.selectedIndex = 1;
    
    CGRect frame = self.tabBar.bounds;
    
    frame.origin.y = frame.origin.y - 5;
    frame.size.height = 58;
    
    tabImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PendingBar"]];
    tabImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    UIView *bottomView = [[UIView alloc] initWithFrame:frame];
    
    [tabImageView setFrame:frame];
    [bottomView addSubview:tabImageView];
    [bottomView setBackgroundColor:[UIColor clearColor]];
    
    for (int i = 0; i < 2; i ++) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(160 * i, 0, 160, bottomView.frame.size.height);
        button.tag = i;
        [button addTarget:self action:@selector(changeTab:) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:button];
    }
    
    [self.tabBar addSubview:bottomView];
    [self.tabBar bringSubviewToFront:bottomView];
    
    UISwipeGestureRecognizer *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    [leftSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:leftSwipeRecognizer];
    
    UISwipeGestureRecognizer *rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    [rightSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightSwipeRecognizer];
    
    leftSwipeRecognizer.delegate = self;
    rightSwipeRecognizer.delegate = self;

    
}
- (void)swipeLeft:(id)sender
{
    UIButton *button = (UIButton *)[self.view viewWithTag:1];
    [self changeTab:button];
    
}

- (void)swipeRight:(id)sender
{
    UIButton *button = (UIButton *)[self.view viewWithTag:0];
    [self changeTab:button];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [AppDelegate sharedDelegate].isExchageScreen = YES;
    NSLog(@"did exchange appear");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [AppDelegate sharedDelegate].isExchageScreen = NO;
    NSLog(@"will exchange disappear");
}

- (void)changeTab:(UIButton *)sender
{
    if (sender.tag == self.selectedIndex) {
        return;
    }
    // Get the views.
    UIView * fromView = self.selectedViewController.view;
    UIView * toView = [[self.viewControllers objectAtIndex:sender.tag] view];
    
    // Get the size of the view area.
    CGRect viewSize = fromView.frame;
    BOOL scrollRight = sender.tag > self.selectedIndex;
    
    // Add the to view to the tab bar view.
    [fromView.superview addSubview:toView];
    
    // Position it off screen.
    toView.frame = CGRectMake((scrollRight ? 320 : -320), viewSize.origin.y, 320, viewSize.size.height);
    
    [UIView animateWithDuration:0.5
                     animations: ^{
                         
                         // Animate the views on and off the screen. This will appear to slide.
                         fromView.frame =CGRectMake((scrollRight ? -320 : 320), viewSize.origin.y, 320, viewSize.size.height);
                         toView.frame =CGRectMake(0, viewSize.origin.y, 320, viewSize.size.height);
                     }
     
                     completion:^(BOOL finished) {
                         if (finished) {
                             
                             // Remove the old view from the tabbar view.
                             [fromView removeFromSuperview];
                             self.selectedIndex = sender.tag;
                         }
                     }];
    [self setSelectedIndex:sender.tag];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [super setSelectedIndex:selectedIndex];
    
    if (selectedIndex == 0)
        [tabImageView setImage:[UIImage imageNamed:@"RequestBar"]];
    else if (selectedIndex == 1)
        [tabImageView setImage:[UIImage imageNamed:@"PendingBar"]];
}

- (void)showTabbarImage:(BOOL)show
{
    tabImageView.hidden = !show;
}

//- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
//{
//    int index = [self.viewControllers indexOfObject:viewController];
//    _tabSelectedView.frame = CGRectMake(index * 80.0, 0, 80.0, TABBARHEIGHT);
//    
//    return YES;
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
