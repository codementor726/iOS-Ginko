//
//  YYYActivateViewController.h
//  XChangeWithMe
//
//  Created by Wang MeiHua on 5/21/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYYActivateViewController : UIViewController
{
	IBOutlet UILabel *lblEmail;
}
@property (nonatomic,retain) NSString *email;
-(IBAction)btLoginClick:(id)sender;
-(IBAction)btBackClick:(id)sender;
@end
