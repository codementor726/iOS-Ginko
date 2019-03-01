//
//  ScanMeViewController.m
//  ginko
//
//  Created by STAR on 9/22/15.
//  Copyright © 2015 com.xchangewithme. All rights reserved.
//

#import "ScanMeViewController.h"
#import "UIImageView+AFNetworking.h"
#import "QRReaderViewController.h"
#import "BBBadgeBarButtonItem.h"
#import "UIImage+Tint.h"
#import "TabRequestController.h"
#import "ProfileRequestController.h"
#import "LocalDBManager.h"

#import <AVFoundation/AVFoundation.h>

@interface ScanMeViewController () <QRReaderViewDelegate, UIAlertViewDelegate>
{
    NSString *scanUserId;
}
@property (nonatomic, strong) BBBadgeBarButtonItem *exchangeButton;
@end

@implementation ScanMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"";
//    _borderHeight.constant = 1 / [UIScreen mainScreen].scale;
//    _borderView.backgroundColor = [UIColor colorWithRed:126.f/255 green:87.f/255 blue:133.f/255 alpha:1];
    
    NSString *cachedPath = [LocalDBManager checkCachedFileExist:[AppDelegate sharedDelegate].qrCode];
    
    if (cachedPath) {
        // load from cache
        [_qrImageView setImage:[UIImage imageWithContentsOfFile:cachedPath]];
    } else {
        // save to temp directory
        __weak UIImageView *weakImageView = _qrImageView;
        [_qrImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[AppDelegate sharedDelegate].qrCode]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            weakImageView.image = image;
            [UIImageJPEGRepresentation(image, 1.0) writeToFile:[LocalDBManager getCachedFileNameFromRemotePath:[AppDelegate sharedDelegate].qrCode] atomically:YES];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            
        }];
    }
    
    [_qrImageView setImageWithURL:[NSURL URLWithString:[AppDelegate sharedDelegate].qrCode]];
    
    // If you want your BarButtonItem to handle touch event and click, use a UIButton as customView
    UIButton *customButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    // Add your action to your button
    [customButton addTarget:self action:@selector(onExchange:) forControlEvents:UIControlEventTouchUpInside];
    // Customize your button as you want, with an image if you have a pictogram to display for example
    [customButton setImage:[[UIImage imageNamed:@"Exchange"] tintImageWithColor:[UIColor colorWithRed:126.f/255 green:87.f/255 blue:133.f/255 alpha:1]] forState:UIControlStateNormal];
    
    // Then create and add our custom BBBadgeBarButtonItem
    BBBadgeBarButtonItem *barButton = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:customButton];
    // Set a value for the badge
    barButton.badgeValue = [NSString stringWithFormat:@"%d", [AppDelegate sharedDelegate].xchageReqNum];
    barButton.badgeBGColor      = [UIColor whiteColor];
    barButton.badgeTextColor    = [UIColor blackColor];
    barButton.badgeOriginX = 13;
    barButton.badgeOriginY = -9;
    
    self.navigationItem.rightBarButtonItem = barButton;
    
    self.navigationItem.hidesBackButton =  YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:_navView];
    [APPDELEGATE GetSummaryFromPush];
}

- (void)viewDidAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNumber) name:UPDATE_XCHG_NOTIFICATION object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_navView removeFromSuperview];
}

- (void)viewDidDisappear:(BOOL)animated {
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateNumber {
    ((BBBadgeBarButtonItem *)self.navigationItem.rightBarButtonItem).badgeValue = [NSString stringWithFormat:@"%d", [AppDelegate sharedDelegate].xchageReqNum];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onCamera:(id)sender {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if(status == AVAuthorizationStatusAuthorized) { // authorized
        [self moveToCameraView];
    }
    else if(status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted){ // denied or restricted
        [self showCameraNotAuthorizedAlert];
    }
    else if(status == AVAuthorizationStatusNotDetermined){ // not determined
        
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted){ // Access has been granted ..do something
                [self moveToCameraView];
            } else { // Access denied ..do something
                [self showCameraNotAuthorizedAlert];
            }
        }];
    }
}

- (void)moveToCameraView {
    QRReaderViewController *qrvc = [[QRReaderViewController alloc] initWithNibName:nil bundle:nil];
    qrvc.delegate = self;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:qrvc] animated:YES completion:nil];
}

- (void)showCameraNotAuthorizedAlert
{
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Cannot access Camera. Please open Settings and allow ginko to access Camera" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)onExchange:(id)sender {
//    self.navigationItem.title = @"";
    TabRequestController *tabRequestController = [TabRequestController sharedController];
    tabRequestController.selectedIndex = 2;
    // Push;
    [self.navigationController pushViewController:tabRequestController animated:YES];

}

#pragma mark - QRReaderViewDelegate
- (void)didReadQRCode:(NSString *)userId {
    if ([[AppDelegate sharedDelegate].userId integerValue] == [userId integerValue])
    {
        [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"This is your own QR code." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    NSString *contactName = [_parentVC isContactIdExist:userId];
    if (contactName != nil)
    {
        contactName = [contactName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [[[UIAlertView alloc] initWithTitle:@"Oops" message:[NSString stringWithFormat:@"%@ is already a contact.", contactName] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES];
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            if (_responseObject[@"data"][@"share"]) {
                if ([_responseObject[@"data"][@"share"][@"is_pending"] boolValue] == YES) {
                    scanUserId = userId;
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GINKO" message:@"This is a pending contact.  Do you want to view permission screen?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
                    [alert show];
                } else {
                    NSString *contactName = @"";
                    NSDictionary *contactInfo = _responseObject[@"data"][@"contact_info"];
                    
                    if (![[contactInfo objectForKey:@"first_name"] isKindOfClass:[NSNull class]])
                        contactName = [contactInfo objectForKey:@"first_name"];
                    if (![[contactInfo objectForKey:@"last_name"] isKindOfClass:[NSNull class]])
                        contactName = [NSString stringWithFormat:@"%@ %@", contactName, [contactInfo objectForKey:@"last_name"]];
                    contactName = [contactName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    if ([contactName isEqualToString:@""])
                        contactName = [contactInfo objectForKey:@"email"];
                    
                    contactName = [contactName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    [[[UIAlertView alloc] initWithTitle:@"Oops" message:[NSString stringWithFormat:@"%@ is already a contact.", contactName] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }
            } else {
                ProfileRequestController *controller = [[ProfileRequestController alloc] initWithNibName:@"ProfileRequestController" bundle:nil];
                controller.contactInfo = @{@"contact_id": userId};
                [AppDelegate sharedDelegate].type = 1;
                [self.navigationController pushViewController:controller animated:YES];
            }
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"Connection Error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    } ;
    
    [[Communication sharedManager] GetMyInfo:[AppDelegate sharedDelegate].sessionId contact_uid:userId successed:successed failure:failure];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        ProfileRequestController * controller = [[ProfileRequestController alloc] initWithNibName:@"ProfileRequestController" bundle:nil];
        controller.contactInfo = @{@"contact_id": scanUserId};
        [AppDelegate sharedDelegate].type = 2;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
