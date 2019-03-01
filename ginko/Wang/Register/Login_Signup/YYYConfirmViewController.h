//
//  YYYConfirmViewController.h
//  XChangeWithMe
//
//  Created by Wang MeiHua on 5/21/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SetupLocationer.h"

@interface YYYConfirmViewController : UIViewController<UIAlertViewDelegate>
{
	IBOutlet UITextField *txtEmail;
	IBOutlet UITextField *txtPassword;
	IBOutlet UITextField *txtNewEmail;
	
	IBOutlet UIScrollView *scvContent;
}
-(IBAction)btAgreeClick:(id)sender;
-(IBAction)btBackClick:(id)sender;
-(IBAction)btSendLinkClick:(id)sender;

@property (nonatomic,retain) NSString *email;
@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *lname;

@end
