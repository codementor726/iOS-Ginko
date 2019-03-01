//
//  PreDirectoryViewController.m
//  ginko
//
//  Created by stepanekdavid on 12/27/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "PreDirectoryViewController.h"
#import "ManageDirectoryViewController.h"
#import "DirectoryInviteContactsViewController.h"
#import "YYYChatViewController.h"
#import "DomainCell.h"
#import "YYYCommunication.h"
#import "UIImageView+AFNetworking.h"

#import "TabRequestController.h"
#import "ProfileRequestController.h"
#import "VideoVoiceConferenceViewController.h"

@interface PreDirectoryViewController ()<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, UIGestureRecognizerDelegate>{
    NSMutableArray *arrDomain;
}

@end

@implementation PreDirectoryViewController
@synthesize directoryInfoForPreview;
@synthesize isJoinOwn;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    UIBarButtonItem *inviteButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Invite"] style:UIBarButtonItemStylePlain target:self action:@selector(goInvite:)];
    UIBarButtonItem *editButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(goEdit:)];
    
    self.title = @"Preview";
    
    if (_isCreate) {
        self.navigationItem.leftBarButtonItems = @[editButtonItem, inviteButtonItem];
        //self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(goDone:)]];
    } else {
        UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackArrow"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
        self.navigationItem.leftBarButtonItems = @[backButtonItem, inviteButtonItem];
        self.navigationItem.rightBarButtonItems = @[editButtonItem];
    }
    arrDomain = [[NSMutableArray alloc] init];
    [self initUI];
    
    profileLogoContainerView.hidden = YES;
    profileLogoImageView.layer.borderWidth = 4.0f;
    profileLogoImageView.layer.borderColor = COLOR_PURPLE_THEME.CGColor;
    profilelogoPreView.hidden = YES;
    UITapGestureRecognizer *tapGestureRecognizerForLogo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideProfileImage)];
    // tapGestureRecognizer.cancelsTouchesInView = NO;
    tapGestureRecognizerForLogo.delegate = self;
    [profilelogoPreView addGestureRecognizer:tapGestureRecognizerForLogo];
    
    
    if (isJoinOwn) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GINKO" message:@"Would you like to join your directory?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alert.tag = 101;
        [alert show];
    }
}
- (void)initUI{
    if (directoryInfoForPreview) {
        lblDirectoryName.text = [directoryInfoForPreview objectForKey:@"name"];
        if (![[directoryInfoForPreview objectForKey:@"privilege"] boolValue]) {
            [imgPrivate setImage:[UIImage imageNamed:@"btn_check_purple"]];
            [imgPublic setImage:[UIImage imageNamed:@"btn_uncheck_purple"]];
            if ([[directoryInfoForPreview objectForKey:@"approve_mode"] boolValue]) {
                [imgAuto setImage:[UIImage imageNamed:@"btn_check_purple"]];
                [imgManual setImage:[UIImage imageNamed:@"btn_uncheck_purple"]];
                NSArray *arr = [[directoryInfoForPreview objectForKey:@"domain"] componentsSeparatedByString:@","];
                arrDomain = [arr mutableCopy];
                [domainTableView reloadData];
            }else{
                [imgAuto setImage:[UIImage imageNamed:@"btn_uncheck_purple"]];
                [imgManual setImage:[UIImage imageNamed:@"btn_check_purple"]];
                domainView.hidden = YES;
            }
        }else{
            [imgPrivate setImage:[UIImage imageNamed:@"btn_uncheck_purple"]];
            [imgPublic setImage:[UIImage imageNamed:@"btn_check_purple"]];
            autoOrManualView.hidden = YES;
            domainView.hidden = YES;
        }
        
        if([directoryInfoForPreview objectForKey:@"profile_image"] && ![[directoryInfoForPreview objectForKey:@"profile_image"] isEqualToString:@""]){
            [directoryLogoImage setImageWithURL:[NSURL URLWithString:[directoryInfoForPreview objectForKey:@"profile_image"]]];
            [profileLogoImageView setImageWithURL:[NSURL URLWithString:[directoryInfoForPreview objectForKey:@"profile_image"]]];
        }else{
            [directoryLogoImage setImage:[UIImage imageNamed:@"directory_bk_image.png"]];
            [profileLogoImageView setImage:[UIImage imageNamed:@"directory_bk_image.png"]];
        }
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goEdit:(id)sender {
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([[_responseObject objectForKey:@"success"] boolValue]) {
            ManageDirectoryViewController *viewController = [[ManageDirectoryViewController alloc] initWithNibName:@"ManageDirectoryViewController" bundle:nil];
            viewController.directoryName = [[_responseObject objectForKey:@"data"] objectForKey:@"name"];
            viewController.directoryInfo = [[_responseObject objectForKey:@"data"] mutableCopy];
            viewController.isCreate = _isCreate;
            viewController.isSetup = NO;
            [self.navigationController pushViewController:viewController animated:YES];
        }
    };
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Internet Connection Error!"];
    };
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[YYYCommunication sharedManager] GetDirectoryDetails:[AppDelegate sharedDelegate].sessionId directoryId:[directoryInfoForPreview objectForKey:@"id"] successed:successed failure:failure];
}
- (void)goInvite:(id)sender {
    DirectoryInviteContactsViewController *vc = [[DirectoryInviteContactsViewController alloc] initWithNibName:@"DirectoryInviteContactsViewController" bundle:nil];
    vc.directoryID = [directoryInfoForPreview objectForKey:@"id"];
    vc.navBarColor = _isCreate;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goDone:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void)goBack:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [arrDomain count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 35.0f;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *simpleTableIdentifier = @"DomainItem";
    DomainCell *cell = (DomainCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [DomainCell sharedCell];
    }
    [cell setCurDomain:[arrDomain objectAtIndex:indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.subDomainName.text = [arrDomain objectAtIndex:indexPath.row];
    cell.btnRemove.hidden = YES;
    return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:NO];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:NO];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        if (alertView.tag == 100) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            void ( ^successed )( id _responseObject ) = ^( id _responseObject )
            {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if ([[_responseObject objectForKey:@"success"] boolValue]) {
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                }
            };
            
            void ( ^failure )( NSError* _error ) = ^( NSError* _error )
            {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Internet Connection Error!"];
            };
            
            [[YYYCommunication sharedManager] DeleteDirectory:APPDELEGATE.sessionId directoryId:[directoryInfoForPreview objectForKey:@"id"] successed:successed failure:failure];
        }else if (alertView.tag == 200){
        
        }else if (alertView.tag == 101){
            APPDELEGATE.type = 9;
            ProfileRequestController * controller = [[ProfileRequestController alloc] initWithNibName:@"ProfileRequestController" bundle:nil];
            controller.directoryId = [directoryInfoForPreview objectForKey:@"id"];
            controller.directoryName = [directoryInfoForPreview objectForKey:@"name"];
            [self.navigationController pushViewController:controller animated:YES];
        }
    }else{
        if (alertView.tag == 101) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    }
}
- (IBAction)onDeleteDirectory:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GINKO" message:@"Are you sure you want to remove this directory?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alert.tag = 100;
    [alert show];
}

- (IBAction)onCloseProfilePreView:(id)sender {
    CATransition *transition = [CATransition animation];
    transition.duration = 2.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [profileLogoContainerView.layer addAnimation:transition forKey:nil];
    profilelogoPreView.hidden = YES;
    profileLogoContainerView.hidden = YES;
}

- (IBAction)onOpenProfilePreView:(id)sender {
    profilelogoPreView.hidden = NO;
    CATransition *transition = [CATransition animation];
    transition.duration = 1.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionReveal;
    [profileLogoContainerView.layer addAnimation:transition forKey:nil];
    profileLogoContainerView.hidden = NO;
}
- (void)hideProfileImage{
    CATransition *transition = [CATransition animation];
    transition.duration = 2.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [profileLogoContainerView.layer addAnimation:transition forKey:nil];
    profilelogoPreView.hidden = YES;
    profileLogoContainerView.hidden = YES;
}
- (void)movingInviteViewFromNotification:(NSString *)directoryId{
    DirectoryInviteContactsViewController *vc = [[DirectoryInviteContactsViewController alloc] initWithNibName:@"DirectoryInviteContactsViewController" bundle:nil];
    vc.directoryID = directoryId;
    vc.navBarColor = _isCreate;
    vc.statusFromNavi = 4;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)movePushNotificationViewController{
    TabRequestController *tabRequestController = [TabRequestController sharedController];
    tabRequestController.selectedIndex = 1;
    [self.navigationController pushViewController:tabRequestController animated:YES];
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
