//
//  InvitationQueryViewController.m
//  ginko
//
//  Created by STAR on 1/4/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "InvitationQueryViewController.h"
#import "MobileVerificationViewController.h"
#import "AppDelegate.h"

@interface InvitationQueryViewController ()

@end

@implementation InvitationQueryViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // reset global appearance
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBarTintColor:COLOR_PURPLE_THEME];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    self.title = @"Invite Contacts";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)selectYes:(id)sender {
    MobileVerificationViewController *vc = [[MobileVerificationViewController alloc] initWithNibName:@"MobileVerificationViewController" bundle:nil];
    vc.isFromContacts = _isFromContacts;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)selectNo:(id)sender {
    if (_isFromContacts)
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    else
        [[AppDelegate sharedDelegate] setWizardPage:@"2"];
}
@end
