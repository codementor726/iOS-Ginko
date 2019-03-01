//
//  MobileVerificationViewController.m
//  ginko
//
//  Created by STAR on 1/1/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "MobileVerificationViewController.h"
#import "CountriesViewController.h"
#import "MobileConfirmViewController.h"
#import "YYYCommunication.h"

@interface MobileVerificationViewController () <CountriesViewControllerDelegate, UIGestureRecognizerDelegate> {
    Country *_country;
}
@end

@implementation MobileVerificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Your phone number";
    
    _country = [Country currentCountry];
    
    UIBarButtonItem *skipButton = [[UIBarButtonItem alloc] initWithTitle:@"Skip" style:UIBarButtonItemStylePlain target:self action:@selector(goSkip:)];
    self.navigationItem.leftBarButtonItem = skipButton;
    
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(goNext:)];
    self.navigationItem.rightBarButtonItem = nextButton;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    _countryCodeLabel.text = [@"+" stringByAppendingString:_country.phoneExtension];
    [_countryButton setTitle:_country.name forState:UIControlStateNormal];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    // tapGestureRecognizer.cancelsTouchesInView = NO;
    tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [_phoneNumberTextField becomeFirstResponder];
}
- (void) hideKeyboard{
    [_phoneNumberTextField resignFirstResponder];
}
- (IBAction)selectCountry:(id)sender {
    CountriesViewController *vc = [[CountriesViewController alloc] initWithNibName:@"CountriesViewController" bundle:nil];

    vc.delegate = self;
    vc.selectedCountry = _country;
    
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:nil];
}

- (void)goSkip:(id)sender {
    if (_isFromContacts)
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    else
        [[AppDelegate sharedDelegate] setWizardPage:@"2"];
}

- (void)goNext:(id)sender {
    if (_phoneNumberTextField.text.length == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Please input phone number." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    if (_phoneNumberTextField.text.length > 14) {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Invalid mobile number." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    if ([_phoneNumberTextField.text rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]].location == NSNotFound) {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Invalid mobile number." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    
    
    NSString *phoneNumber = [_countryCodeLabel.text stringByAppendingString:_phoneNumberTextField.text];
    
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    void(^successed)(id _responseObject) = ^(id _responseObject)
    {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        
        if ([[_responseObject objectForKey:@"success"] boolValue]) {
            MobileConfirmViewController *vc = [[MobileConfirmViewController alloc] initWithNibName:@"MobileConfirmViewController" bundle:nil];
            vc.phoneNumber = phoneNumber;
            vc.isFromContacts = _isFromContacts;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not get verification code." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    };
    
    void(^failure)(NSError* _error) = ^(NSError* _error)
    {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oh no!" message:@"Failed to connect to server." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    };
    
    [[YYYCommunication sharedManager] getVerifyCodeBySMS:[AppDelegate sharedDelegate].sessionId phone_num:phoneNumber successed:successed failure:failure];
}

#pragma mark - CountriesViewControllerDelegate
- (void)countriesViewControllerDidCancel:(CountriesViewController *)countriesViewController {
    
}

- (void)countriesViewController:(CountriesViewController *)countriesViewController didSelectCountry:(Country *)country {
    [countriesViewController.navigationController dismissViewControllerAnimated:YES completion:^{
        _country = country;
        _countryCodeLabel.text = [@"+" stringByAppendingString:_country.phoneExtension];
        [_countryButton setTitle:_country.name forState:UIControlStateNormal];
    }];
}

@end
