//
//  PasswordViewController.h
//  GINKO
//
//  Created by Forever on 6/3/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PasswordViewController : UIViewController <UITextFieldDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate>
{
    IBOutlet UIView *navView;
    IBOutlet UIScrollView *scrView;
    IBOutlet UITextField *txtFieldCurPass;
    IBOutlet UITextField *txtFieldNewPass;
    IBOutlet UITextField *txtFieldConfirmPass;
    
    int originalHeight;
}

- (IBAction)onBack:(id)sender;
- (IBAction)onChange:(id)sender;

@end
