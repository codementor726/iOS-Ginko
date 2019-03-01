//
//  CreateDirectoryViewController.m
//  ginko
//
//  Created by stepanekdavid on 12/14/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "CreateDirectoryViewController.h"
#import "ManageDirectoryViewController.h"
#import "YYYCommunication.h"
#import "TabRequestController.h"
#import "VideoVoiceConferenceViewController.h"
@interface CreateDirectoryViewController ()<UITextFieldDelegate, UIGestureRecognizerDelegate>

@end

@implementation CreateDirectoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Create";
    
    // reset global appearance
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBarTintColor:COLOR_PURPLE_THEME];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackArrow"] style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"OK" style:UIBarButtonItemStyleDone target:self action:@selector(onDone:)];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    // tapGestureRecognizer.cancelsTouchesInView = NO;
    tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    lblErrorForDuplicate.hidden = YES;
}
- (void)viewDidAppear:(BOOL)animated {
    [txtDirectoryName becomeFirstResponder];
}
- (void) hideKeyboard{
    [txtDirectoryName resignFirstResponder];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)cancel:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
-(void)showAlert:(NSString*)msg :(NSString*)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}
- (void)onDone:(id)sender {
    if (!txtDirectoryName.text.length)
    {
        [self showAlert:@"Please input Directory name" :@"Input Error"];
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        if ([[_responseObject objectForKey:@"success"] boolValue]) {
            if ([[_responseObject objectForKey:@"data"] integerValue] == 1) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                ManageDirectoryViewController *viewController = [[ManageDirectoryViewController alloc] initWithNibName:@"ManageDirectoryViewController" bundle:nil];
                viewController.directoryName = txtDirectoryName.text;
                viewController.isCreate = YES;
                viewController.isSetup = YES;
                [self.navigationController pushViewController:viewController animated:YES];
                
            }else{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                lblErrorForDuplicate.hidden = NO;
                lblErrorForDuplicate.text = [NSString stringWithFormat:@"Sorry %@ is already taken,\n please enter another name.", txtDirectoryName.text];
                txtDirectoryName.text = @"";
            }
        }else{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    };
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Internet Connection Error!"];
    };
    
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *dirName = [txtDirectoryName.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[YYYCommunication sharedManager] GetDirCheckingAvail:APPDELEGATE.sessionId name:dirName successed:successed failure:failure];

}
#pragma mark UITextfieldViewDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([textField isEqual:txtDirectoryName]) {
        [self onDone:nil];
    }
    return  YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField{
    if ([textField isEqual:txtDirectoryName]) {
        lblErrorForDuplicate.hidden = YES;
    }
    return  YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([textField isEqual:txtDirectoryName]) {
        lblErrorForDuplicate.hidden = YES;
    }
    return  YES;
}
- (void)movePushNotificationViewController{
    TabRequestController *tabRequestController = [TabRequestController sharedController];
    tabRequestController.selectedIndex = 1;
    [self.navigationController pushViewController:tabRequestController animated:YES];
    [self.navigationController.navigationBar setBarTintColor:COLOR_GREEN_THEME];
}
- (void)movePushNotificationConferenceViewController:(NSDictionary *)dic{
    VideoVoiceConferenceViewController *vc = [[VideoVoiceConferenceViewController alloc] initWithNibName:@"VideoVoiceConferenceViewController" bundle:nil];
    vc.infoCalling = dic;
    vc.boardId = [dic objectForKey:@"board_id"];
    if ([[dic objectForKey:@"callType"] integerValue] == 1) {
        vc.conferenceType = 1;
    }else{
        vc.conferenceType = 2;
    }
    vc.conferenceName = [dic objectForKey:@"uname"];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
