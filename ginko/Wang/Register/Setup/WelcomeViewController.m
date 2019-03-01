//
//  WelcomeViewController.m
//  ginko
//
//  Created by STAR on 15/12/23.
//  Copyright © 2015年 com.xchangewithme. All rights reserved.
//

#import "WelcomeViewController.h"
#import <UIView+Borders.h>

@interface WelcomeViewController () {
    UIWindow *parentWindow;
}
@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // the bottom view is partially visible
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    
    [_startButton addTopBorderWithHeight:0.5f andColor:[UIColor colorWithWhite:229.f/255 alpha:1]];
    
    _contentView.layer.cornerRadius = 3;
    _contentView.clipsToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)start:(id)sender {
    [self hideWindow];
}

- (void)presentWindow
{
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    window.opaque = NO;
    window.windowLevel = UIWindowLevelAlert;
    window.rootViewController = self;
    
    parentWindow = window;
    [parentWindow makeKeyAndVisible];
    
    [self showAnimation];
}

- (void)showAnimation
{
    CGPoint ptCenter = CGPointMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0);
    _contentView.alpha = 0.0;
    _contentView.center = ptCenter;
    _contentView.transform = CGAffineTransformMakeScale(0.05, 0.05);
    double dDuration = 0.2;
    
    [UIView animateWithDuration:dDuration animations:^(void) {
        
        self.view.alpha = 1.0;
        _contentView.alpha = 1.0;
        _contentView.transform = CGAffineTransformMakeScale(1.05, 1.05);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^(void) {
            _contentView.alpha = 1.0;
            _contentView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }];
    }];
}

- (void)hideWindow
{
    double dDuration = 0.1;
    [UIView animateWithDuration:dDuration animations:^(void) {
        _contentView.transform = CGAffineTransformMakeScale(1.05, 1.05);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^(void) {
            [UIView setAnimationDelay:0.05];
            self.view.alpha = 0.0;
            _contentView.transform = CGAffineTransformMakeScale(0.05, 0.05);
            _contentView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self hideAlertView];
        }];
    }];
}

- (void)hideAlertView
{
    [parentWindow removeFromSuperview];
    parentWindow = nil;
}

@end
