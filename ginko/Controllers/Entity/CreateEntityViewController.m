//
//  CreateEntityViewController.m
//  ginko
//
//  Created by Harry on 1/13/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "CreateEntityViewController.h"
#import "ManageEntityViewController.h"
#import "TabRequestController.h"
#import "YYYChatViewController.h"
#import "VideoVoiceConferenceViewController.h"

@interface CreateEntityViewController ()

@end

@implementation CreateEntityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Choose Entity Category";
    
    // reset global appearance
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBarTintColor:COLOR_PURPLE_THEME];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    // customize button
    [self makeImageTopTextBottomButton:_localBusinessButton];
    [self makeImageTopTextBottomButton:_companyButton];
    [self makeImageTopTextBottomButton:_brandButton];
    [self makeImageTopTextBottomButton:_entertainmentButton];
    [self makeImageTopTextBottomButton:_artistButton];
    [self makeImageTopTextBottomButton:_communityButton];
    
    _localBusinessButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _companyButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _brandButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _entertainmentButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _artistButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _communityButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    // set highlighted color
    _localBusinessButton.bgColor = _companyButton.bgColor = _brandButton.bgColor = _entertainmentButton.bgColor = _artistButton.bgColor = _communityButton.bgColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackArrow"] style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)createLocalBusiness:(id)sender {
    [self navigateToEntityCreationWithCategory:0];
}

- (IBAction)createCompany:(id)sender {
    [self navigateToEntityCreationWithCategory:1];
}

- (IBAction)createBrand:(id)sender {
    [self navigateToEntityCreationWithCategory:2];
}

- (IBAction)createEntertainment:(id)sender {
    [self navigateToEntityCreationWithCategory:3];
}

- (IBAction)createArtist:(id)sender {
    [self navigateToEntityCreationWithCategory:4];
}

- (IBAction)createCommunity:(id)sender {
    [self navigateToEntityCreationWithCategory:5];
}

- (void)navigateToEntityCreationWithCategory:(int)category {
    ManageEntityViewController *vc = [[ManageEntityViewController alloc] initWithNibName:@"ManageEntityViewController" bundle:nil];
    vc.category = category;
    vc.isCreate = YES;
    vc.entityData = nil;
    vc.isSetup = YES;
    vc.currentIndex = 0;
    vc.isSubEntity = NO;
    vc.isMultiLocation = NO;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)cancel:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Make UIButton top image and bottom text
- (void)makeImageTopTextBottomButton:(UIButton *)button {
    // the space between the image and text
    CGFloat spacing = 6.0;
    
    // raise the image and push it right so it appears centered
    //  above the text
    CGRect rt = [button.titleLabel.text boundingRectWithSize:CGSizeMake(160 - 10 * 2, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: button.titleLabel.font} context:nil];
    CGSize imageSize = button.imageView.image.size;
    button.titleEdgeInsets = UIEdgeInsetsMake(0.0, -imageSize.width, -(rt.size.height + spacing), 0.0);
    button.imageEdgeInsets = UIEdgeInsetsMake(-60, (CGRectGetWidth(button.frame) - 10 * 2 - imageSize.width) / 2, 0.0, 0);
}
- (void)movePushNotificationViewController{
    TabRequestController *tabRequestController = [TabRequestController sharedController];
    tabRequestController.selectedIndex = 1;
    [self.navigationController pushViewController:tabRequestController animated:YES];
    [self.navigationController.navigationBar setBarTintColor:COLOR_GREEN_THEME];
}
- (void)movePushNotificationChatViewController:(NSNumber *)boardID isDeletedFriend:(BOOL)isDetetedFriend users:(NSMutableArray *)lstUsers isDirectory:(NSDictionary *)directoryInfo{
    YYYChatViewController *viewcontroller = [[YYYChatViewController alloc] initWithNibName:@"YYYChatViewController" bundle:nil];
    viewcontroller.isDeletedFriend = isDetetedFriend;
    viewcontroller.boardid = boardID;
    viewcontroller.lstUsers = lstUsers;
    BOOL isMembersSameDirectory = NO;
    if ([[directoryInfo objectForKey:@"is_group"] boolValue]) {//directory chat for members
        viewcontroller.isDeletedFriend = NO;
        viewcontroller.groupName = [directoryInfo objectForKey:@"board_name"];
        viewcontroller.isMemberForDiectory = YES;
        viewcontroller.isDirectory = YES;
    }else{
        viewcontroller.lstUsers = lstUsers;
        
        viewcontroller.isDeletedFriend = YES;
        for (NSDictionary *memberDic in directoryInfo[@"members"]) {
            if ([memberDic[@"in_same_directory"] boolValue]) {
                isMembersSameDirectory = YES;
            }
        }
        if (isMembersSameDirectory) {
            viewcontroller.isDeletedFriend = NO;
            viewcontroller.groupName = [directoryInfo objectForKey:@"board_name"];
            viewcontroller.isMemberForDiectory = YES;
            viewcontroller.isDirectory = NO;
        }
    }
    [self.navigationController pushViewController:viewcontroller animated:YES];
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
