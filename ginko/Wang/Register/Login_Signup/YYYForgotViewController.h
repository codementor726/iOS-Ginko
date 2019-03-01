//
//  YYYForgotViewController.h
//  XChangeWithMe
//
//  Created by Wang MeiHua on 5/21/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYYForgotViewController : UIViewController<UIAlertViewDelegate>
{
	IBOutlet UITextField *txtEmail;
}
-(IBAction)btSubmitClick:(id)sender;
@end
