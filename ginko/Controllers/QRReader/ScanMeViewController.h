//
//  ScanMeViewController.h
//  ginko
//
//  Created by STAR on 9/22/15.
//  Copyright © 2015 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactViewController.h"

@interface ScanMeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *qrImageView;
- (IBAction)onCamera:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *borderHeight;
@property (weak, nonatomic) IBOutlet UIView *borderView;
@property (weak) ContactViewController *parentVC;
- (IBAction)onBack:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *navView;

- (void)updateNumber;
@end
