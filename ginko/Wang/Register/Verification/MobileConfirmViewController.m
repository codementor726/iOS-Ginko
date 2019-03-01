//
//  MobileConfirmViewController.m
//  ginko
//
//  Created by STAR on 1/1/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "MobileConfirmViewController.h"
#import "YYYCommunication.h"
#import "GinkoConnectViewController.h"

@interface MobileConfirmViewController ()

@end

@implementation MobileConfirmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Confirm your number";
    
    [_hiddenTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)resend:(id)sender {    
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    void(^successed)(id _responseObject) = ^(id _responseObject)
    {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        
        if ([[_responseObject objectForKey:@"success"] boolValue]) {
            [[[UIAlertView alloc] initWithTitle:@"GINKO" message:@"Verification code sent." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            _hiddenTextField.text = _label1.text = _label2.text = _label3.text = _label4.text = _label5.text = _label6.text = @"";
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not get verification code." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    };
    
    void(^failure)(NSError* _error) = ^(NSError* _error)
    {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oh no!" message:@"Failed to conenct to server." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    };
    
    [[YYYCommunication sharedManager] getVerifyCodeBySMS:[AppDelegate sharedDelegate].sessionId phone_num:_phoneNumber successed:successed failure:failure];
}

- (IBAction)becomeFirst:(id)sender {
    if (![_hiddenTextField isFirstResponder])
        [_hiddenTextField becomeFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (text.length > 6)
        return NO;
    
    if (text.length > 0)
        _label1.text = [text substringWithRange:NSMakeRange(0, 1)];
    else
        _label1.text = @"";
    if (text.length > 1)
        _label2.text = [text substringWithRange:NSMakeRange(1, 1)];
    else
        _label2.text = @"";
    if (text.length > 2)
        _label3.text = [text substringWithRange:NSMakeRange(2, 1)];
    else
        _label3.text = @"";
    if (text.length > 3)
        _label4.text = [text substringWithRange:NSMakeRange(3, 1)];
    else
        _label4.text = @"";
    if (text.length > 4)
        _label5.text = [text substringWithRange:NSMakeRange(4, 1)];
    else
        _label5.text = @"";
    if (text.length > 5)
        _label6.text = [text substringWithRange:NSMakeRange(5, 1)];
    else
        _label6.text = @"";
    
    if (text.length == 6) {
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        
        void(^successed)(id _responseObject) = ^(id _responseObject)
        {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            
            if ([_responseObject[@"success"] intValue] == 0) {
                [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"The verification code is invalid." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                textField.text = @"";
                _label1.text = _label2.text = _label3.text = _label4.text = _label5.text = _label6.text = @"";
                return;
            }
            
            [AppDelegate sharedDelegate].phoneVerified = YES;
            [AppDelegate sharedDelegate].isPreviewPhoneVerifyView = YES;
            [[AppDelegate sharedDelegate] saveLoginData];

            GinkoConnectViewController *vc = [[GinkoConnectViewController alloc] initWithNibName:@"GinkoConnectViewController" bundle:nil];
            UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
            navVC.navigationBar.translucent = NO;
            vc.isFromContacts = _isFromContacts;
            
            if (_isFromContacts)
                [self.navigationController pushViewController:vc animated:YES];
            else
                [[AppDelegate sharedDelegate].window.rootViewController presentViewController:navVC animated:YES completion:nil];
        };
        
        void(^failure)(NSError* _error) = ^(NSError* _error)
        {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oh no!" message:@"Failed to verify code. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            textField.text = @"";
            _label1.text = _label2.text = _label3.text = _label4.text = _label5.text = _label6.text = @"";
            return;
        };
        
        [[YYYCommunication sharedManager] verifySMSCode:[AppDelegate sharedDelegate].sessionId phoneNum:_phoneNumber verifyCode:text successed:successed failure:failure];
    }
    
    return YES;
}

@end
