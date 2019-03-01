//
//  CBSetupSimulateController.h
//  ContactImporter
//
//  Created by mobidev on 6/21/14.
//  Copyright (c) 2014 Ron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBSetupViewController.h"

@interface CBSetupSimulateController : UIViewController <UITextFieldDelegate>

@property (nonatomic, assign) IBOutlet UISegmentedControl *segControl;
@property (nonatomic, assign) IBOutlet UITextField *txtEmail;
@property (nonatomic, assign) IBOutlet UITextField *txtPass;

@property (nonatomic, retain) CBSetupViewController *parentController;

- (IBAction)onDone:(id)sender;

@end
