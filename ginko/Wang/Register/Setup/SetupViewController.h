//
//  SetupViewController.h
//  Xchangewithme
//
//  Created by Xin YingTai on 20/5/14.
//  Copyright (c) 2014 Xin YingTai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ToggleButton.h"

@interface SetupViewController : UIViewController

@property (weak, nonatomic) IBOutlet ToggleButton *homeButton;
@property (weak, nonatomic) IBOutlet ToggleButton *workButton;
@property (weak, nonatomic) IBOutlet ToggleButton *bothButton;
- (IBAction)createPersonal:(id)sender;
- (IBAction)createWork:(id)sender;
- (IBAction)createBoth:(id)sender;
@end
