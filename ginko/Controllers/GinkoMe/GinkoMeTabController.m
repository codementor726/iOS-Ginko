//
//  GinkoMeTabController.m
//  ginko
//
//  Created by ccom on 1/8/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "GinkoMeTabController.h"
#import "TabRequestController.h"
#import "YYYChatViewController.h"
#import "VideoVoiceConferenceViewController.h"

@interface GinkoMeTabController ()

@end

@implementation GinkoMeTabController {
    NSTimer* timer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gpsChanged) name:NOTIFICATION_GPSSETTING_CHANGED object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDetectedContacts) name:NOTIFICATION_CONTACTGPS_CHANGED object:nil];
    [self.tabBar setHidden:YES];
    
    [self gpsChanged];
    [self performFetch];
    
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.navigationController.delegate = self;
    
    [CommonMethods loadAvaiableEntityNew];//sycn entity
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDetectedContacts) name:NOTIFICATION_CONTACTGPS_CHANGED object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_CONTACTGPS_CHANGED object:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.view addSubview:self.navView];
    [self loadDetectedContacts];
    //timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target: self selector: @selector(loadDetectedContacts) userInfo: nil repeats: YES];
    if ([AppDelegate sharedDelegate].isNewContactFind)
    {
        [_segmentControll setSelectedSegmentIndex:1];
        [_segmentControll sendActionsForControlEvents:UIControlEventValueChanged];
    }
    [self.cDelegate updateTableView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navView removeFromSuperview];
    [timer invalidate];
    [AppDelegate sharedDelegate].isNewContactFind = NO;
}

#pragma mark -
#pragma mark - Function

- (void)loadDetectedContacts {
    if (![AppDelegate sharedDelegate].sessionId) // if not logged in, return
        return;
    
    [CommonMethods loadDetectedContacts];
}

- (void)setEditMode:(BOOL)isEditing {
    self.backButton.hidden = isEditing;
    self.filterButton.hidden = isEditing;
    self.ginkoMeButton.hidden = isEditing;
    if (isEditing) {
        self.on1Label.hidden = isEditing;
    }
    else {
        [self gpsChanged];
        [self loadDetectedContacts];
    }
    
    self.closeButton.hidden = !isEditing;
    self.trashButton.hidden = !isEditing;
}

- (void)gpsChanged {
    if (APPDELEGATE.locationFlag)
    {
        [self.ginkoMeButton setImage:[UIImage imageNamed:@"GPSOn"] forState:UIControlStateNormal];
        if (APPDELEGATE.intervalIndex != 0) {
            self.on1Label.hidden = NO;
        } else self.on1Label.hidden = YES;
    }
    else {
        [self.ginkoMeButton setImage:[UIImage imageNamed:@"GPSOff"] forState:UIControlStateNormal];
        self.on1Label.hidden = YES;
    }
}

#pragma mark -
#pragma mark - IBAction

- (IBAction)onSegChanged:(UISegmentedControl*)segControl {
    NSString *imageName;
    if ([AppDelegate sharedDelegate].isNewContactFind){
        self.selectedIndex = 1;
        imageName = @"BG_Gradient";
        [AppDelegate sharedDelegate].isNewContactFind = NO;
    }else{
        self.selectedIndex = segControl.selectedSegmentIndex;
        //    self.navView.backgroundColor = (segControl.selectedSegmentIndex) ? COLOR_GREEN_THEME : [UIColor clearColor];
        imageName = (segControl.selectedSegmentIndex) ? @"navBar" :@"BG_Gradient";
    }
    
    self.bgImageView.image = [UIImage imageNamed:imageName];
}

- (IBAction)onBack:(id)sender {
    [self.cDelegate malloc];
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)onGinkoMe:(id)sender {
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    if (appDelegate.locationFlag)
    {
        if (appDelegate.intervalIndex == 0) {
            [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeClear];
            [appDelegate changeGPSSetting:2];
        } else if (appDelegate.intervalIndex == 1) {
            [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeClear];
            [appDelegate changeGPSSetting:0];
        }
    }
    else {
        [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeClear];
        [appDelegate changeGPSSetting:1];
    }
}

- (IBAction)onFilter:(id)sender {
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ContactFilterViewController"];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self  presentViewController:nc animated:YES completion:nil];
}


#pragma mark -
#pragma mark - NSFetchedResultsController

- (void)performFetch {
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        return;
        //        exit(-1);  // Fail
    }
    NSArray *results = self.fetchedResultsController.fetchedObjects;
    //NSLog(@"resulet---%@",results);
    if (results.count > 1) {
        for (int i=0; i<results.count-1; i++) {
            for (int j=i+1; j<results.count; j++) {
                SearchedContact *con1 = results[i];
                SearchedContact *con2 = results[j];
                if ([con1.latitude isEqualToNumber:con2.latitude] && [con1.longitude isEqualToNumber:con2.longitude]) {
                    CGFloat latitude = [con2.latitude floatValue];
                    CGFloat longitude =  [con2.longitude floatValue];
                    latitude += ((arc4random() % 10) / 100000.0);
                    longitude += ((arc4random() % 10) / 100000.0);
                    con2.latitude = @(latitude);
                    con2.longitude = @(longitude);
                }
            }
        }
    }
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(exchanged == YES) AND (contact_type == 1)"];
    self.contacts = [results filteredArrayUsingPredicate:pred];
    pred = [NSPredicate predicateWithFormat:@"(exchanged == NO) OR (contact_type == 3)"];
    self.greys = [results filteredArrayUsingPredicate:pred];
    //NSLog(@"entity---%@",self.greys);
    self.greys = [self.greys sortedArrayUsingComparator:^(SearchedContact *obj1,SearchedContact *obj2) {
        return [obj2.found_time compare:obj1.found_time];
    }];
    //NSLog(@"entity---%@",self.greys);
    [self.cDelegate updated:self.contacts greys:self.greys];
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    _fetchedResultsController = [SearchedContact frcForContacts];
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
//    NSLog(@"GinkoMe controllerDidChangeContent");
    [self performFetch];
}


#pragma mark -
#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController isEqual:self]) {
        [navigationController setNavigationBarHidden:YES animated:YES];
    }
    else {
        if (APPDELEGATE.isConferenceView) {
            [navigationController setNavigationBarHidden:YES animated:YES];
        }else{
            [navigationController setNavigationBarHidden:NO animated:YES];
        }
    }
}
- (void)movePushNotificationViewController{
    TabRequestController *tabRequestController = [TabRequestController sharedController];
    tabRequestController.selectedIndex = 1;
    [self.navigationController pushViewController:tabRequestController animated:YES];
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
