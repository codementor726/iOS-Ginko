//
//  GroupsViewController.m
//  ginko
//
//  Created by stepanekdavid on 3/19/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "GroupsViewController.h"
#import "GroupCollectionViewCell.h"
#import "YYYCommunication.h"
#import "GroupContactsViewController.h"
#import "YYYChatViewController.h"
#import "ProfileRequestController.h"
#import "UIImageView+AFNetworking.h"

@interface GroupsViewController ()<UIAlertViewDelegate>
{
    NSMutableArray *arrGroups;
    NSMutableArray *oldArrGroups;
    NSMutableArray *dictGroups;
    NSMutableArray *sortedArrGroups;
    
    NSString *movedGroupId;
    NSString *movedFromNum;
    NSString *movedToNum;
    NSString *currentGroupId;
    
    BOOL isFinded;
    
    BOOL isEditMode;
    
    UIAlertView *tmpAlertView;
}

@end

@implementation GroupsViewController
@synthesize navView, addGroupsCollectionView, emptyView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationItem setHidesBackButton:YES animated:NO];
    isEditMode = NO;
    arrGroups = [[NSMutableArray alloc] init];
    oldArrGroups = [[NSMutableArray alloc] init];
    dictGroups = [[NSMutableArray alloc] init];
    sortedArrGroups = [[NSMutableArray alloc] init];
    
    [self.addGroupsCollectionView registerNib:[UINib nibWithNibName:@"GroupCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"GroupCell"];
    
    
    addGroupsCollectionView.delegate = self;
    addGroupsCollectionView.dataSource = self;
    
    isFinded = NO;
    
    tmpAlertView = [[UIAlertView alloc] init];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:navView];
    
    _btEdit.selected = NO;
    APPDELEGATE.isGroupScreen = YES;
    if (!isEditMode) {
        [self getGroups];
    }
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [navView removeFromSuperview];
    APPDELEGATE.isGroupScreen = NO;
    //[self savedAllPositionOfGroup];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getGroups) name:CONTACT_SYNC_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getGroups) name:@"GROUPSRELOAD" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeAllPromptWhenAccept) name:NOTIFICATION_GINKO_VIDEO_CONFERENCE object:nil];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CONTACT_SYNC_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GROUPSRELOAD" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_GINKO_VIDEO_CONFERENCE object:nil];
}

- (void)closeAllPromptWhenAccept{
    if (tmpAlertView) {
        [tmpAlertView dismissWithClickedButtonIndex:-1 animated:YES];
        tmpAlertView = nil;
    }
}

#pragma mark : Collection View Datasource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [arrGroups count];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    return CGSizeMake(100, 140);
}
#pragma mark - LXReorderableCollectionViewDataSource methods

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath {
    NSArray *currentGroup = arrGroups[fromIndexPath.item];
    
    movedGroupId = [(NSDictionary *)[arrGroups objectAtIndex:fromIndexPath.row] objectForKey:@"id"];
    [arrGroups removeObjectAtIndex:fromIndexPath.item];
    [arrGroups insertObject:currentGroup atIndex:toIndexPath.item];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
#if LX_LIMITED_MOVEMENT == 1
    PlayingCard *playingCard = self.deck[indexPath.item];
    
    switch (playingCard.suit) {
        case PlayingCardSuitSpade:
        case PlayingCardSuitClub: {
            return YES;
        } break;
        default: {
            return NO;
        } break;
    }
#else
    return YES;
#endif
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath {
#if LX_LIMITED_MOVEMENT == 1
    PlayingCard *fromPlayingCard = self.deck[fromIndexPath.item];
    PlayingCard *toPlayingCard = self.deck[toIndexPath.item];
    
    switch (toPlayingCard.suit) {
        case PlayingCardSuitSpade:
        case PlayingCardSuitClub: {
            return fromPlayingCard.rank == toPlayingCard.rank;
        } break;
        default: {
            return NO;
        } break;
    }
#else
    return YES;
#endif
}

#pragma mark - LXReorderableCollectionViewDelegateFlowLayout methods

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"will begin drag");
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"did begin drag");
    
    movedFromNum = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"will end drag");
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"did end drag");
    movedToNum = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    if (movedGroupId) {
        //[self savedPositionGroup:movedGroupId orderNum:movedToNum oldOrderNum:movedFromNum];
        [self savedAllPositionOfGroup];
    }
    
}
-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentfier = @"GroupCell";
    GroupCollectionViewCell *cell = [addGroupsCollectionView dequeueReusableCellWithReuseIdentifier:CellIdentfier forIndexPath:indexPath];
    
    
    cell.delegate = self;
    NSDictionary *dict  = [arrGroups objectAtIndex:indexPath.row];
    [cell.countOfGroup setText:[NSString stringWithFormat:@"%@",[(NSDictionary *)[arrGroups objectAtIndex:indexPath.row] objectForKey:@"user_count"]]];
    
//    NSData *decodeData = [[NSData alloc] initWithBase64EncodedString:[(NSDictionary *)[arrGroups objectAtIndex:indexPath.row] objectForKey:@"name"] options:0];
//    NSString *decodedString = [[NSString alloc] initWithData:decodeData encoding:NSUTF8StringEncoding];//added by jella
    
    [cell.groupName setText:[(NSDictionary *)[arrGroups objectAtIndex:indexPath.row] objectForKey:@"name"]];
    
    if (isEditMode) {
        cell.deleteView.hidden = NO;
    }else{
        cell.deleteView.hidden = YES;
    }
    switch ([[(NSDictionary *)[arrGroups objectAtIndex:indexPath.row] objectForKey:@"type"] integerValue]) {
        case 0:
            cell.groupImg.layer.borderColor = [UIColor grayColor].CGColor;
            cell.groupImg.layer.borderWidth = 1;
            cell.groupCellsImg.layer.borderColor = [UIColor grayColor].CGColor;
            cell.groupCellsImg.backgroundColor = [UIColor grayColor];
            cell.countOfGroup.textColor = [UIColor whiteColor];
            [cell.groupImg setImageWithURL:[NSURL URLWithString:@"http://image.ginko.mobi/Photos/no-face.png"]];
            break;
        case 1:
            cell.groupImg.layer.borderColor = COLOR_PURPLE_THEME.CGColor;
            cell.groupImg.layer.borderWidth = 1;
            cell.groupCellsImg.layer.borderColor = COLOR_PURPLE_THEME.CGColor;
            cell.groupCellsImg.backgroundColor = COLOR_PURPLE_THEME;
            cell.countOfGroup.textColor = [UIColor whiteColor];
            [cell.groupImg setImageWithURL:[NSURL URLWithString:@"http://image.ginko.mobi/Photos/no-face.png"]];
            break;
        case 2:
            cell.groupImg.layer.borderColor = COLOR_GREEN_THEME.CGColor;
            cell.groupImg.layer.borderWidth = 2;
            cell.groupCellsImg.layer.borderColor = COLOR_GREEN_THEME.CGColor;
            cell.groupCellsImg.backgroundColor = COLOR_GREEN_THEME;
            cell.countOfGroup.textColor = COLOR_PURPLE_THEME;
            if ([dict objectForKey:@"profile_image"] && ![[dict objectForKey:@"profile_image"] isEqualToString:@""] ) {
                [cell.groupImg setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"profile_image"]]];
            }else{
                [cell.groupImg setImageWithURL:[NSURL URLWithString:@"http://image.ginko.mobi/Photos/no-face.png"]];
            }
            break;
        default:
            [cell.groupImg setImageWithURL:[NSURL URLWithString:@"http://image.ginko.mobi/Photos/no-face.png"]];
            break;
    }
    cell.GroupId = [NSString stringWithFormat:@"%@",[(NSDictionary *)[arrGroups objectAtIndex:indexPath.row] objectForKey:@"group_id"]];
    cell.GroupInfo = dict;
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (!_btEdit.selected) {
        GroupContactsViewController *vc = [[GroupContactsViewController alloc] initWithNibName:@"GroupContactsViewController" bundle:nil];
        vc.groupDict = [arrGroups objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
}



#pragma mark - WebApi Integration

- (void)getGroups
{
    if (!APPDELEGATE.calledGetGroups) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        APPDELEGATE.calledGetGroups = YES;
        void ( ^successed )( id _responseObject ) = ^( id _responseObject )
        {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            APPDELEGATE.calledGetGroups = NO;
            [arrGroups removeAllObjects];
            NSDictionary *result = _responseObject;
            if ([[result objectForKey:@"success"] boolValue]) {
                for (NSDictionary *dict in [result objectForKey:@"data"]) {
                    [arrGroups addObject:dict];
                }
                //[self getDirectories];
                if ([arrGroups count]) {
                    addGroupsCollectionView.hidden = NO;
                    emptyView.hidden = YES;
                    _btEdit.enabled = YES;
                    _btSort.enabled = YES;
                } else {
                    addGroupsCollectionView.hidden = YES;
                    emptyView.hidden = NO;
                    _btEdit.enabled = NO;
                    _btSort.enabled = NO;
                    [_btCancel sendActionsForControlEvents:UIControlEventTouchUpInside];
                }
                NSSortDescriptor *sortDescriptor;
                sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order_weight" ascending:YES selector:@selector(compare:)];
                NSMutableArray * sortDescriptors = [NSMutableArray arrayWithObject:sortDescriptor];
                [arrGroups sortUsingDescriptors:sortDescriptors];
                
                oldArrGroups = [arrGroups mutableCopy];
                
                [addGroupsCollectionView reloadData];
            } else {
                NSDictionary *dictError = [result objectForKey:@"err"];
                if (dictError) {
                    [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:[dictError objectForKey:@"errMsg"]];
                } else {
                    [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Failed to connect to server!"];
                }
            }
        };
        
        void ( ^failure )( NSError* _error ) = ^( NSError* _error )
        {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            APPDELEGATE.calledGetGroups = NO;
            [CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Internet Connection Error!"];
        };
        
        
        [[YYYCommunication sharedManager] getGroupList:[AppDelegate sharedDelegate].sessionId successed:successed failure:failure];
    }
    
}
- (void)addGroup:(NSString *)groupName
{
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary *result = _responseObject;
        if ([[result objectForKey:@"success"] boolValue]) {
            [arrGroups addObject:[result objectForKey:@"data"]];
            oldArrGroups = [arrGroups mutableCopy];
            addGroupsCollectionView.hidden = NO;
            emptyView.hidden = YES;
            [addGroupsCollectionView reloadData];
            GroupContactsViewController *vc = [[GroupContactsViewController alloc] initWithNibName:@"GroupContactsViewController" bundle:nil];
            vc.groupDict = [result objectForKey:@"data"];
            [self.navigationController pushViewController:vc animated:YES];
            
        } else {
            NSDictionary *dictError = [result objectForKey:@"err"];
            if (dictError) {
                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:[dictError objectForKey:@"errMsg"]];
            } else {
                [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Failed to connect to server!"];
            }
        }
    };
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Internet Connection Error!"];
    };
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    NSData *plainData = [groupName dataUsingEncoding:NSUTF8StringEncoding];
//    NSString *encodevalue= [plainData base64EncodedStringWithOptions:0];
    
//    NSString *encodeName = [groupName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[YYYCommunication sharedManager] addGroup:[AppDelegate sharedDelegate].sessionId name:groupName successed:successed failure:failure];
}

- (void)getUsersForGroup:(NSString *)groupID
{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            NSMutableArray *arrContacts = [[_responseObject objectForKey:@"data"] objectForKey:@"data"];
            NSString *strIds = @"";
            
            for (NSDictionary *dict in arrContacts) {
                if ([[dict objectForKey:@"contact_type"] intValue] == 1) {
                    strIds = [NSString stringWithFormat:@"%@,%@", strIds, [dict objectForKey:@"contact_id"]];
                }
            }
            
            if ([strIds length]) {
                strIds = [strIds substringFromIndex:1];
            }
            if (![strIds length]) {
                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Oops, no purple contacts."];
                return;
            }
            [dictGroups addObject:arrContacts];
            //[self CreateMessageBoard:strIds :arrContacts];
        }
    };
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Internet Connection Error!"];
    } ;
    
    [[YYYCommunication sharedManager] getUsersForGroup:[AppDelegate sharedDelegate].sessionId groupID:groupID successed:successed failure:failure];
}
-(void)savedPositionGroup:(NSString *)groupID orderNum:(NSString *)movedNum oldOrderNum:(NSString *)movedOldNum
{
    
    //NSLog(@"position---%@----%@",movedNum,movedOldNum);
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            NSLog(@"%@",[_responseObject objectForKey:@"message"]);
            [self getGroups];
        }
    };
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        
        NSLog(@"Failed to save information. Please try again.");
    } ;
    
    [[YYYCommunication sharedManager] SavePositionGroup:[AppDelegate sharedDelegate].sessionId groupID:groupID orderNum:movedNum oldOrderNum:movedOldNum successed:successed failure:failure];
}
- (void)savedAllPositionOfGroup{
    NSMutableArray *positionOfGroup = [NSMutableArray new];
    
    for (int i = 0; i < [oldArrGroups count]; i++) {
        for (int j = 0; j < [arrGroups count]; j++) {
            if ([[[oldArrGroups objectAtIndex:i] objectForKey:@"id"] integerValue] == [[[arrGroups objectAtIndex:j] objectForKey:@"id"] integerValue] && i != j ) {
                [positionOfGroup addObject:@{@"id":[(NSDictionary *)[oldArrGroups objectAtIndex:i] objectForKey:@"id"],@"order_num":@(j),@"old_order_num":@(i)}];
            }
        }
    }
    NSLog(@"position---%@",positionOfGroup);
    if ([positionOfGroup count] == 0) {
        return;
    }

    //[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    void(^successed)(id _responseObject) = ^(id _responseObject)
    {
        //[MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            NSLog(@"%@",[_responseObject objectForKey:@"message"]);
            [self getGroups];
            //oldArrGroups = [arrGroups mutableCopy];
        }
        
    };
    
    void(^failure)(NSError* _error) = ^(NSError* _error)
    {
        //[MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oh no!" message:@"Failed to save information. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    };
    
    [[YYYCommunication sharedManager] SaveAllPositionOfGroups:[AppDelegate sharedDelegate].sessionId fields:positionOfGroup successed:successed failure:failure];
}
#pragma mark -
- (void)deleteCurrentGroup:(NSString *)_groupId type:(NSInteger)_type
{
    //NSLog(@"groupId---%@",_groupId);
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary *result = _responseObject;
        if ([[result objectForKey:@"success"] boolValue]) {
            [self getGroups];
        } else {
            NSDictionary *dictError = [result objectForKey:@"err"];
            if (dictError) {
                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:[dictError objectForKey:@"errMsg"]];
            } else {
                [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Failed to connect to server!"];
            }
        }
    };
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Internet Connection Error!"];
    };
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (_type != 2) {
        [[YYYCommunication sharedManager] deleteGroup:[AppDelegate sharedDelegate].sessionId groupID:_groupId successed:successed failure:failure];
    }else{
        [[YYYCommunication sharedManager] QuitMemberDirectory:[AppDelegate sharedDelegate].sessionId directoryId:_groupId successed:successed failure:failure];
    }
}
//-(void)CreateMessageBoard:(NSString*)ids :(NSArray *)arrContacts
//{
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    
//    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
//        
//        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//        
//        if ([[_responseObject objectForKey:@"success"] boolValue])
//        {
//            NSMutableArray *lstTemp = [[NSMutableArray alloc] init];
//            
//            
//            for (NSDictionary *dict in arrContacts)
//            {
//                if ([[dict objectForKey:@"contact_type"] intValue] == 1)
//                {
//                    NSMutableDictionary *dictTemp = [[NSMutableDictionary alloc] init];
//                    
//                    [dictTemp setObject:[dict objectForKey:@"first_name"] forKey:@"fname"];
//                    [dictTemp setObject:[dict objectForKey:@"last_name"] forKey:@"lname"];
//                    [dictTemp setObject:[dict objectForKey:@"photo_url"] forKey:@"photo_url"];
//                    [dictTemp setObject:[dict objectForKey:@"contact_id"] forKey:@"user_id"];
//                    
//                    [lstTemp addObject:dictTemp];
//                }
//            }
//            
//            NSMutableDictionary *dictTemp1 = [[NSMutableDictionary alloc] init];
//            
//            [dictTemp1 setObject:[AppDelegate sharedDelegate].firstName forKey:@"fname"];
//            [dictTemp1 setObject:[AppDelegate sharedDelegate].lastName forKey:@"lname"];
//            [dictTemp1 setObject:[AppDelegate sharedDelegate].photoUrl forKey:@"photo_url"];
//            [dictTemp1 setObject:[AppDelegate sharedDelegate].userId forKey:@"user_id"];
//            
//            [lstTemp addObject:dictTemp1];
//            
//            YYYChatViewController *viewcontroller = [[YYYChatViewController alloc] initWithNibName:@"YYYChatViewController" bundle:nil];
//            viewcontroller.boardid = [[_responseObject objectForKey:@"data"] objectForKey:@"board_id"];
//            viewcontroller.lstUsers = [[NSMutableArray alloc] initWithArray:lstTemp];;
//            [self.navigationController pushViewController:viewcontroller animated:YES];
//            
//        }else{
//            [CommonMethods showAlertUsingTitle:@"Error!" andMessage:[[_responseObject objectForKey:@"err"] objectForKey:@"errMsg"]];
//        }
//    } ;
//    
//    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
//        
//        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
//        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Internet Connection Error!"];
//        
//    } ;
//    
//    [[YYYCommunication sharedManager] CreateChatBoard:[AppDelegate sharedDelegate].sessionId userids:ids successed:successed failure:failure];
//}
#pragma mark - Actions
- (IBAction)onBack:(id)sender
{
    //[self.navigationController popViewControllerAnimated:YES];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)onAddContact:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Create a new Group" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = 101;
    [[alertView textFieldAtIndex:0] setTextAlignment:NSTextAlignmentLeft];
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.placeholder = @"Enter Group Name";
    tmpAlertView = alertView;
    [alertView show];
}

- (IBAction)onSort:(id)sender {
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSMutableArray * sortDescriptors = [NSMutableArray arrayWithObject:sortDescriptor];
    [arrGroups sortUsingDescriptors:sortDescriptors];
    [self savedAllPositionOfGroup];
    [addGroupsCollectionView reloadData];
}

- (IBAction)onEdit:(id)sender {
    _btEdit.selected = !_btEdit.selected;
    
    if (_btEdit.selected) {
        isEditMode = YES;
        _btEdit.hidden = YES;
        _btSort.hidden = YES;
        _btAdd.hidden = YES;
        _lblAdd.hidden = YES;
        _btBack.hidden = YES;
        _btCancel.hidden = NO;
        _btnJoinDirectory.hidden = YES;
        
    }
    
    
    [addGroupsCollectionView reloadData];
}

- (IBAction)onCancel:(id)sender {
    isEditMode = NO;
    _btEdit.hidden = NO;
    _btSort.hidden = NO;
    _btAdd.hidden = NO;
    _lblAdd.hidden = NO;
    _btBack.hidden = NO;
    _btCancel.hidden = YES;
    _btEdit.selected = NO;
    _btnJoinDirectory.hidden = NO;
    [addGroupsCollectionView reloadData];
}

- (IBAction)onJoinDirectory:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Join a Directory."
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[alertView textFieldAtIndex:0] setTextAlignment:NSTextAlignmentLeft];
    [alertView setTag:100];
    UITextField *textField = [alertView textFieldAtIndex:0];
    [textField setKeyboardType:UIKeyboardTypeEmailAddress];
    textField.placeholder = @"Enter Directory Name";
    tmpAlertView = alertView;
    [alertView show];
}

#pragma mark - UIAlertView Delegate
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (buttonIndex) {
//        [self addGroup:[[alertView textFieldAtIndex:0] text]];
//    }
//}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([alertView tag] == 100 && buttonIndex == 1)
    {
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSString *text = textField.text;
        if (text.length == 0) {
            UIAlertView *alertViewforError = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"The input field is empty." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
            [alertViewforError show];
            return;
        }
        BOOL isCheckInOwn = NO;
        NSDictionary *checkedDirInfo = [NSDictionary new];
        for (NSDictionary *dic in arrGroups) {
            if ([[dic objectForKey:@"type"] integerValue] == 2) {
                if ([[dic objectForKey:@"name"] isEqualToString:text]) {
                    isCheckInOwn = YES;
                    checkedDirInfo = dic;
                }
            }
        }
        if (isCheckInOwn) {
            GroupContactsViewController *vc = [[GroupContactsViewController alloc] initWithNibName:@"GroupContactsViewController" bundle:nil];
            vc.groupDict = checkedDirInfo;
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            [self jobDiectory:text];
        }
        
    }else if ([alertView tag] == 101 && buttonIndex == 1){
        [self addGroup:[[alertView textFieldAtIndex:0] text]];
    }
}

- (void)jobDiectory:(NSString *)diectoryName{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        if ([[_responseObject objectForKey:@"success"] boolValue]) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if ([[_responseObject objectForKey:@"data"] objectForKey:@"id"]) {
                APPDELEGATE.type = 6;
                ProfileRequestController * controller = [[ProfileRequestController alloc] initWithNibName:@"ProfileRequestController" bundle:nil];
                //controller.contactInfo = contactDict;
                controller.directoryId = [[_responseObject objectForKey:@"data"] objectForKey:@"id"];
                controller.directoryName = diectoryName;
                [self.navigationController pushViewController:controller animated:YES];
            }else{
//                lblErrorForDuplicate.hidden = NO;
//                lblErrorForDuplicate.text = [NSString stringWithFormat:@"Sorry %@ is already taken,\n please enter another name.", txtDirectoryName.text];
//                txtDirectoryName.text = @"";
            }
        }else{
            UIAlertView *alertViewforError = [[UIAlertView alloc] initWithTitle:@"Oops!" message:[[_responseObject objectForKey:@"err"] objectForKey:@"errMsg"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
            [alertViewforError show];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    };
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Internet Connection Error!"];
    };
    
    NSString *dirName = [diectoryName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[YYYCommunication sharedManager] CheckExisedDirectory:APPDELEGATE.sessionId name:dirName successed:successed failure:failure];
}
@end
