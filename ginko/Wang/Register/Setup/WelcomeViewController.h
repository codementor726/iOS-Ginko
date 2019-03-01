//
//  WelcomeViewController.h
//  ginko
//
//  Created by STAR on 15/12/23.
//  Copyright © 2015年 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WelcomeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
- (IBAction)start:(id)sender;

- (void)presentWindow;

@end
