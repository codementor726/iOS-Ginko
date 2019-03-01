//
//  ContactFilterViewController.m
//  ginko
//
//  Created by ccom on 1/21/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "ContactFilterViewController.h"
#import "YYYChatViewController.h"
#import "VideoVoiceConferenceViewController.h"
@interface ContactFilterViewController ()

@end

@implementation ContactFilterViewController {
    NSArray *contacts;
    NSArray *purpleContacts;
    NSMutableArray *selectedContacts;
    NSArray *typeNames;
    NSArray *typeImages;
    NSArray *typeSelImages;
    NSArray *selectedTypes;
    NSString *searchWord;
    NSInteger filterType;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    purpleContacts = [Contact getPurpleContacts];
    purpleContacts = [purpleContacts sortedArrayUsingComparator:^(Contact *obj1,Contact *obj2) {
        NSString *num1 =[obj1 getContactName];
        NSString *num2 =[obj2 getContactName];
        return [num1 compare:num2 options:NSNumericSearch];
        //return (NSComparisonResult) [num1 caseInsensitiveCompare:num2];
    }];
    contacts = purpleContacts;
    selectedContacts = [NSMutableArray array];
//    [self.contactTable reloadData];
    typeNames = @[@"Select All", @"Personal", @"Work", @"I’m shy, I don’t want to show my location."];
    typeImages = @[@"AllFilter", @"HomeFilter", @"WorkFilter", @""];//ContactFilter
    typeSelImages = @[@"AllFilter_Sel", @"HomeFilter_Sel", @"WorkFilter_Sel", @""];
    
    filterType = -1;
    if (APPDELEGATE.gpsFilterType == 3) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[Communication sharedManager] getFilteredContacts:APPDELEGATE.sessionId successed:^(NSDictionary *resObj) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            selectedContacts = [NSMutableArray arrayWithArray:resObj[@"data"][@"user_ids"]];
            filterType = [resObj[@"data"][@"type"] integerValue];
            [self.contactTable reloadData];
            [self.typeTable reloadData];
        } failure:^(NSError *err) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    }
    else {
        filterType = APPDELEGATE.gpsFilterType;
        [self.typeTable reloadData];
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];
    [super viewWillDisappear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadContactTable {
    contacts = purpleContacts;
    if (searchWord.length) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(getContactName CONTAINS[c] %@)", searchWord];
        contacts = [purpleContacts filteredArrayUsingPredicate:pred];
    }
    [self.contactTable reloadData];
}

#pragma mark - IBAction

- (IBAction)onDone:(id)sender {
    NSString *ids = @"";
    if (filterType == 3) {
        for (id con in selectedContacts) {
            if ([ids isEqualToString:@""]) {
                ids = [NSString stringWithFormat:@"%@", con];
                continue;
            }
            ids = [NSString stringWithFormat:@"%@,%@", ids, con];
        }
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[Communication sharedManager] setFilter:APPDELEGATE.sessionId type:filterType user_ids:ids remove_existed:YES successed:^(NSDictionary *res) {
        APPDELEGATE.gpsFilterType = filterType;
        [APPDELEGATE saveLoginData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(NSError *err) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
}

- (IBAction)onClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:self.typeTable]) {
//        if (!filterType) {//If select all
//            [tableView setSeparatorColor:[UIColor whiteColor]];
//        }
//        else {
//            [tableView setSeparatorColor:RGBA(134, 134, 139, 1)];
//        }
        return 4;
    }
    return contacts.count;
}
 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.typeTable]) {
        UITableViewCell *cell = [self.typeTable dequeueReusableCellWithIdentifier:@"FilterTypeCell"];
        UIImageView *icon = [cell viewWithTag:500];
        UILabel *label = [cell viewWithTag:600];
        label.text = typeNames[indexPath.row];
        [icon setImage:[UIImage imageNamed:typeImages[indexPath.row]]];
        
        label.textColor = RGBA(134, 134, 139, 1);
        cell.backgroundColor = [UIColor whiteColor];
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = [UIColor clearColor];
        cell.selectedBackgroundView = view;
        if (indexPath.row == 3 && selectedContacts.count > 0) {
            return cell;
        }
        if (indexPath.row == filterType) {
            cell.backgroundColor = COLOR_PURPLE_THEME;
            label.textColor = [UIColor whiteColor];
            [icon setImage:[UIImage imageNamed:typeSelImages[indexPath.row]]];
        }
        if (filterType == 0 && indexPath.row < 3) {
            cell.backgroundColor = COLOR_PURPLE_THEME;
            label.textColor = [UIColor whiteColor];
            [icon setImage:[UIImage imageNamed:typeSelImages[indexPath.row]]];
        }
        return cell;
    }
    Contact *contact = contacts[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
    [cell.textLabel setText:[contact getContactName]];
    if ([selectedContacts containsObject:@([contact.contact_id integerValue])]) {
        cell.backgroundColor = COLOR_PURPLE_THEME;
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    else {
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.textColor = [UIColor blackColor];
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = view;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ([tableView isEqual:self.typeTable]) {
        filterType = indexPath.row;
        selectedContacts = [NSMutableArray array];
    }
    else {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        Contact *contact = contacts[indexPath.row];
        if (![selectedContacts containsObject:@([contact.contact_id integerValue])]) {
            [selectedContacts addObject:@([contact.contact_id integerValue])];
        }
        else {
            [selectedContacts removeObject:@([contact.contact_id integerValue])];
        }
        filterType = 3;
    }
    [self.typeTable reloadData];
    [self.contactTable reloadData];
}


#pragma mark -
#pragma mark - UISearchBar Delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    searchWord = searchText;
    [self reloadContactTable];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    searchWord = searchBar.text;
    [self reloadContactTable];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    searchWord = @"";
    [self reloadContactTable];
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
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
    [self.navigationController  pushViewController:viewcontroller animated:YES];
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
