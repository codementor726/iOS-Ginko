//
//  MobileConfirmViewController.h
//  ginko
//
//  Created by STAR on 1/1/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MobileConfirmViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UILabel *label4;
@property (weak, nonatomic) IBOutlet UILabel *label5;
@property (weak, nonatomic) IBOutlet UILabel *label6;
- (IBAction)resend:(id)sender;
- (IBAction)becomeFirst:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *hiddenTextField;

@property (nonatomic, strong) NSString *phoneNumber;

@property (nonatomic, assign) BOOL isFromContacts;
@end
