//
//  SproutProgressViewController.m
//  ginko
//
//  Created by STAR on 8/25/15.
//  Copyright (c) 2015 com.xchangewithme. All rights reserved.
//

#import "SproutProgressViewController.h"

@interface SproutProgressViewController ()
{
    UIWindow *parentWindow;
}
@end

@implementation SproutProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
    
    NSArray *animationArray=[NSArray arrayWithObjects:
                             [UIImage imageNamed:@"SproutProgress01"],
                             [UIImage imageNamed:@"SproutProgress02"],
                             [UIImage imageNamed:@"SproutProgress03"],
                             [UIImage imageNamed:@"SproutProgress04"],
                             [UIImage imageNamed:@"SproutProgress05"],
                             [UIImage imageNamed:@"SproutProgress06"],
                             nil];
    _progressImageView.animationImages=animationArray;
    _progressImageView.animationDuration=3;
    _progressImageView.animationRepeatCount=0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showAnimation
{
    CGPoint ptCenter = CGPointMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0);
    _progressImageView.alpha = 0.0;
    _progressImageView.center = ptCenter;
    _progressImageView.transform = CGAffineTransformMakeScale(0.05, 0.05);
    double dDuration = 0.2;
    
    [UIView animateWithDuration:dDuration animations:^(void) {
        
        self.view.alpha = 1.0;
        _progressImageView.alpha = 1.0;
        _progressImageView.transform = CGAffineTransformMakeScale(1.05, 1.05);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^(void) {
            _progressImageView.alpha = 1.0;
            _progressImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL finished) {
            [_progressImageView startAnimating];
        }];
    }];
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

- (void)hideWindow
{
    double dDuration = 0.1;
    [UIView animateWithDuration:dDuration animations:^(void) {
        _progressImageView.transform = CGAffineTransformMakeScale(1.05, 1.05);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^(void) {
            [UIView setAnimationDelay:0.05];
            self.view.alpha = 0.0;
            _progressImageView.transform = CGAffineTransformMakeScale(0.05, 0.05);
            _progressImageView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self hideAlertView];
        }];
    }];
}

- (void)hideAlertView
{
    [_progressImageView stopAnimating];
    [parentWindow removeFromSuperview];
    parentWindow = nil;
}

@end
