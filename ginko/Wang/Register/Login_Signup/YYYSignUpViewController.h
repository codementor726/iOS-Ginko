//
//  YYYSignUpViewController.h
//  XChangeWithMe
//
//  Created by Wang MeiHua on 5/21/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@interface YYYSignUpViewController : UIViewController<UIAlertViewDelegate,UITextFieldDelegate>
{
	IBOutlet UITextField *txtName;
	IBOutlet UITextField *txtEmail;
	IBOutlet UITextField *txtPassword;
    IBOutlet UIScrollView *scrView;
    BOOL showKeyboard;
}

@property (weak, nonatomic) IBOutlet TTTAttributedLabel *descLabel;

-(IBAction)btAgreeClick:(id)sender;
-(IBAction)btFBLoginClick:(id)sender;
-(IBAction)btBackClick:(id)sender;
@end
