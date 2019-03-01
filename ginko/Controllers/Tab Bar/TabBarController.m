//
//  TabBarController.m
//  Ginko
//
//  Created by Qi Song on 29/3/14.
//  Copyright (c) 2014 Qi Song. All rights reserved.
//
// --- Headers ---;
#import "TabBarController.h"
#import "ExchangedViewController.h"
#import "NotExchangedViewController.h"
#import "SproutProgressViewController.h"
#import "M13BadgeView.h"


// --- Defines ---;
// TabBarController Class;
#define TABBARHEIGHT 58.0f

@interface TabBarController () <UITabBarControllerDelegate>
{
    UIButton *tabImageView;
    UIButton *btnThumb;
    NSMutableArray *tabBarButtons;
    SproutProgressViewController *progressVC;
    M13BadgeView *badge1;
    M13BadgeView *badge2;
}

@end

@implementation TabBarController
@synthesize delegate;

+ (TabBarController *)sharedController
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"TabBarController" owner:nil options:nil];
    TabBarController *sharedController = [array objectAtIndex:0];
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
    self.selectedIndex = 1;
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    CGRect frame = self.tabBar.bounds;
     
    frame.origin.y = frame.origin.y - 4.5;
    frame.size.height = 58;
    
    tabImageView = [UIButton buttonWithType:UIButtonTypeCustom];
    [tabImageView setImage:[UIImage imageNamed:@"NotExchangeBar"] forState:UIControlStateNormal];
    [tabImageView setImage:[UIImage imageNamed:@"NotExchangeBar_Disabled"] forState:UIControlStateDisabled];
    
    tabImageView.userInteractionEnabled = NO;
    
    UIView *bottomView = [[UIView alloc] initWithFrame:frame];
    
    [tabImageView setFrame:frame];
    [bottomView addSubview:tabImageView];
    [bottomView setBackgroundColor:[UIColor clearColor]];
    
    tabBarButtons = [NSMutableArray new];
    for (int i = 0; i < 2; i ++) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(214 * i, 16, 107, bottomView.frame.size.height);
        button.tag = i;
        [button addTarget:self action:@selector(changeTab:) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:button];
        [tabBarButtons addObject:button];
    }
    
    UIView *viewDummy = [[UIView alloc] initWithFrame:CGRectMake(135, 0, 50, 49)];
    viewDummy.backgroundColor = [UIColor colorWithRed:126.0f/255.0f green:87.0f/255.0f blue:133.0f/255.0f alpha:1.0];
    [bottomView addSubview:viewDummy];
    
    btnThumb = [UIButton buttonWithType:UIButtonTypeCustom];
    btnThumb.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    btnThumb.frame = CGRectMake(135, -24, 50, 78);
    NSLog(@"Look here! %@, %@", NSStringFromCGRect(self.tabBar.bounds), NSStringFromCGRect(bottomView.frame));
    [btnThumb setImage:[UIImage imageNamed:@"fingerprint"] forState:UIControlStateNormal];
    [btnThumb addTarget:self action:@selector(touchDownThumb:) forControlEvents:UIControlEventTouchDown];
    [btnThumb addTarget:self action:@selector(touchUpThumb:) forControlEvents:UIControlEventTouchUpInside];
    [btnThumb addTarget:self action:@selector(touchUpThumb:) forControlEvents:UIControlEventTouchUpOutside];
    [bottomView addSubview:btnThumb];
    
    [self.tabBar addSubview:bottomView];
    [self.tabBar bringSubviewToFront:bottomView];
    
    progressVC = [[SproutProgressViewController alloc] initWithNibName:@"SproutProgressViewController" bundle:nil];
    
    
}

- (void)enableButtons:(BOOL)enable
{
    btnThumb.enabled = enable;
    for(UIButton *button in tabBarButtons)
        button.enabled = enable;
    tabImageView.enabled = enable;
}

- (void)changeThumbEnabled:(BOOL)flag
{
    btnThumb.enabled = flag;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self setItemImageInsets];
    [AppDelegate sharedDelegate].isSproutScreen = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:ApplicationWillResignActive object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [AppDelegate sharedDelegate].isSproutScreen = YES;
}

- (void)changeTab:(UIButton *)sender
{
    [self setSelectedIndex:sender.tag];
}

- (void)applicationWillResignActive
{
    if ([AppDelegate sharedDelegate].thumbDown)
        [self touchUpThumb:btnThumb];
}

- (void)touchDownThumb:(UIButton *)sender
{
    [progressVC presentWindow];
    if (self.selectedIndex) {
        [(NotExchangedViewController *)self.selectedViewController touchDown];
    } else {
        [(ExchangedViewController *)self.selectedViewController touchDown];
    }
}

- (void)touchUpThumb:(UIButton *)sender
{
    [progressVC hideWindow];
    if (self.selectedIndex) {
        [(NotExchangedViewController *)self.selectedViewController touchUp];
    } else {
        [(ExchangedViewController *)self.selectedViewController touchUp];
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [super setSelectedIndex:selectedIndex];
//    [self setSelectedIndex:selectedIndex];
    if (selectedIndex == 0) {
        [tabImageView setImage:[UIImage imageNamed:@"ExchangeBar"] forState:UIControlStateNormal];
        [tabImageView setImage:[UIImage imageNamed:@"ExchangeBar_Disabled"] forState:UIControlStateDisabled];
    }
    else if (selectedIndex == 1) {
        [tabImageView setImage:[UIImage imageNamed:@"NotExchangeBar"] forState:UIControlStateNormal];
        [tabImageView setImage:[UIImage imageNamed:@"NotExchangeBar_Disabled"] forState:UIControlStateDisabled];
    }
//    [self setItemImageInsets];
//    else
//        [tabImageView setImage:[UIImage imageNamed:@"NotExchangeBar"]];
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

//- (void)setItemImageInsets {
//    UITabBarItem *item = self.tabBar.items[0];
//    UIEdgeInsets insets = UIEdgeInsetsMake(0, 50, 0, 0);
//    [item setImageInsets:insets];
//    item = self.tabBar.items[1];
//    [item setImageInsets:insets];
//}

- (void)setBadgeOnItem:(NSInteger)index value:(NSString*)value {
    if (!index) {
        if (!badge1) {
            badge1 = [[M13BadgeView alloc] initWithFrame:CGRectMake(0, 0, 17, 17)];
            badge1.horizontalAlignment = M13BadgeViewHorizontalAlignmentCenter;
            badge1.verticalAlignment = M13BadgeViewVerticalAlignmentTop;
            badge1.hidesWhenZero = YES;
            badge1.text = nil;
            UIButton *button = tabBarButtons[0];
            [button addSubview:badge1];
        }
        badge1.text = value;
    }
    else {
        if (!badge2) {
            badge2 = [[M13BadgeView alloc] initWithFrame:CGRectMake(0, 0, 17, 17)];
            badge2.horizontalAlignment = M13BadgeViewHorizontalAlignmentCenter;
            badge2.verticalAlignment = M13BadgeViewVerticalAlignmentTop;
            badge2.hidesWhenZero = YES;
            badge2.text = nil;
            UIButton *button = tabBarButtons[1];
            [button addSubview:badge2];
        }
        badge2.text = value;
    }
}
@end
