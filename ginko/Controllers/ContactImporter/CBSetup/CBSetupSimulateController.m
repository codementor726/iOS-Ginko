//
//  CBSetupSimulateController.m
//  ContactImporter
//
//  Created by mobidev on 6/21/14.
//  Copyright (c) 2014 Ron. All rights reserved.
//

#import "CBSetupSimulateController.h"

@interface CBSetupSimulateController ()

@end

@implementation CBSetupSimulateController
@synthesize segControl, txtEmail, txtPass;
@synthesize parentController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)isValidFields
{
    [self.view findAndResignFirstResponder];
    
    if (![CommonMethods checkBlankField:[NSArray arrayWithObjects:txtEmail, txtPass, nil] titles:[NSArray arrayWithObjects:@"Email Adress", @"Password Field",  nil]]) {
        return NO;
    }
    if (![CommonMethods checkEmail:txtEmail]) {
        return NO;
    }
    return YES;
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == txtEmail) {
        [txtPass becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - Actions
- (IBAction)onDone:(id)sender
{
    if (![self isValidFields]) {
        return;
    }
    parentController.validType = segControl.selectedSegmentIndex ? 3 : 1;
    parentController.strEmail = txtEmail.text;
    parentController.strPass = txtPass.text;
    [self dismissViewControllerAnimated:YES  completion:^{
        [parentController configureUI];
    }];
}

@end
