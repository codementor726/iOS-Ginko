//
//  YYYLoginViewController.h
//  XChangeWithMe
//
//  Created by Wang MeiHua on 5/21/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYYLoginViewController : UIViewController<UITextFieldDelegate, CLLocationManagerDelegate>
{
	UIButton *btLogin;
	
	IBOutlet UITextField *txtEmail;
	IBOutlet UITextField *txtPassword;
    IBOutlet UIScrollView *scrView;
    BOOL showKeyboard;
}
-(IBAction)btForgotClick:(id)sender;
-(IBAction)btFBLoginClick:(id)sender;
@end
