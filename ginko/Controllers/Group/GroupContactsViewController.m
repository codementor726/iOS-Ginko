//
//  GroupContactsViewController.m
//  GINKO
//
//  Created by Xian on 7/22/14.
//  Copyright (c) 2014 Xian. All rights reserved.
//

#import "GroupContactsViewController.h"
#import "YYYCommunication.h"
#import "GroupAddContactsViewController.h"
#import "YYYChatViewController.h"
#import "ProfileRequestController.h"
#import "GreyDetailController.h"
#import "YYYCommunication.h"
#import "GroupAddContactsViewController.h"
#import "PreviewProfileViewController.h"
#import "ProfileViewController.h"
#import "VideoVoiceConferenceViewController.h"
#import "SelectUserForConferenceViewController.h"

@interface GroupContactsViewController ()<UIActionSheetDelegate>
{
    NSMutableArray *arrContacts;
    NSMutableArray *arrFilteredList;
    NSMutableArray *keyList;
    NSMutableArray *contactList;
    
    NSMutableArray *arrSelectedContacts;
    NSString *sort;
    CGFloat rowHeight;
    NSString *cellIdentifier;
    
    UIActionSheet *currentActionSheet;
}
@end

@implementation GroupContactsViewController
@synthesize navView, emptyView, viewBottom;
@synthesize tblContacts, searchBarForList;
@synthesize btnAddContact, btnChat, btnBack, btnBackFunction, btnCar, btnClose, btnEdit, lblGroupName, btnGroupVideoChat;
@synthesize groupDict;

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
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    arrContacts = [[NSMutableArray alloc] init];
    arrFilteredList = [[NSMutableArray alloc] init];
    contactList = [[NSMutableArray alloc] init];
    keyList = [[NSMutableArray alloc] init];
    arrSelectedContacts = [[NSMutableArray alloc] init];
    
    sort = [[NSUserDefaults standardUserDefaults] objectForKey:@"GINKOSORTBY"];
    availableIdsWithConfere = @"";
    availContactsWithConfere = [[NSMutableArray alloc] init];
    if (sort == nil)
        sort = @"first_name";
    
    if ([[groupDict objectForKey:@"type"] integerValue] ==2) {
        sort = @"fname";
    }
    
    lblGroupName.text = [groupDict objectForKey:@"name"];
    
    // back button will not have title
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    
    searchBarForList.text = @"";
    
    if ([AppDelegate sharedDelegate].viewType == 0)
    {
        rowHeight = 405.0f;
        cellIdentifier = @"TileViewCell";
    }
    else if ([AppDelegate sharedDelegate].viewType == 1)
    {
        rowHeight = 72.0f;
        cellIdentifier = @"ContactCell";
    }
    
    [tblContacts registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
    
    btnEdit.selected = NO;
    //    [self getOnlyContacts];
    
    if ([[groupDict objectForKey:@"type"] integerValue] == 2) {
        _btnEditPermission.hidden = NO;
        viewBottom.hidden = YES;
        btnEdit.hidden = YES;
        _addView.hidden = YES;
        [searchBarForList setFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
        [tblContacts setFrame:CGRectMake(tblContacts.frame.origin.x, tblContacts.frame.origin.y, tblContacts.frame.size.width, tblContacts.frame.size.height + 48)];
    }else{
        _btnEditPermission.hidden = YES;
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getUsersForGroup];
    
    [tblContacts deselectRowAtIndexPath:[tblContacts indexPathForSelectedRow] animated:animated];
    
    [self.navigationController.navigationBar addSubview:navView];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [navView removeFromSuperview];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeCurrentActionWhenConferenceView) name:CLOSE_ALERT_WHEN_CONFERENCEVIEW_NOTIFICATION object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CLOSE_ALERT_WHEN_CONFERENCEVIEW_NOTIFICATION object:nil];
}
#pragma mark - Methods
- (void)sortContactsByLetters
{
    NSString *key = @"";
    
    [keyList removeAllObjects];
    [contactList removeAllObjects];
    
    NSMutableArray *arrTemp = [[NSMutableArray alloc] init];
    NSArray *arrList = [arrFilteredList copy];
    arrList = [arrList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *name1, *name2;
        if ([sort isEqualToString:@"first_name"] || [sort isEqualToString:@"fname"]){
            name1 = [NSString stringWithFormat:@"%@%@%@", obj1[@"first_name"], obj1[@"middle_name"], obj1[@"last_name"]];
            name2 = [NSString stringWithFormat:@"%@%@%@", obj2[@"first_name"], obj2[@"middle_name"], obj2[@"last_name"]];
            if ([[groupDict objectForKey:@"type"] integerValue] ==2) {
                name1 = [NSString stringWithFormat:@"%@%@%@", obj1[@"fname"], obj1[@"mname"], obj1[@"lname"]];
                name2 = [NSString stringWithFormat:@"%@%@%@", obj2[@"fname"], obj2[@"mname"], obj2[@"lname"]];
            }
        }
        else{
            name1 = [NSString stringWithFormat:@"%@%@%@", obj1[@"last_name"], obj1[@"middle_name"], obj1[@"first_name"]];
            name2 = [NSString stringWithFormat:@"%@%@%@", obj2[@"last_name"], obj2[@"middle_name"], obj2[@"first_name"]];
            if ([[groupDict objectForKey:@"type"] integerValue] ==2) {
                name1 = [NSString stringWithFormat:@"%@%@%@", obj1[@"lname"], obj1[@"mname"], obj1[@"fname"]];
                name2 = [NSString stringWithFormat:@"%@%@%@", obj2[@"lname"], obj2[@"mname"], obj2[@"fname"]];
            }
        }
        return [name1.lowercaseString compare:name2.lowercaseString options:NSNumericSearch];
    }];
    [arrFilteredList removeAllObjects];
    arrFilteredList = [arrList mutableCopy];
    for (int i = 0; i < [arrFilteredList count]; i++)
    {
        NSDictionary *dict = [arrFilteredList objectAtIndex:i];
        
        NSString *tempStr = @"";
        
        if ([sort isEqualToString:@"first_name"] || [sort isEqualToString:@"fname"])
        {
            if (![[dict objectForKey:@"first_name"] isEqualToString:@""])
                tempStr = [[[dict objectForKey:@"first_name"] uppercaseString] substringToIndex:1];
            else if (![[dict objectForKey:@"middle_name"] isEqualToString:@""])
                tempStr = [[[dict objectForKey:@"middle_name"] uppercaseString] substringToIndex:1];
            else if (![[dict objectForKey:@"last_name"] isEqualToString:@""])
                tempStr = [[[dict objectForKey:@"last_name"] uppercaseString] substringToIndex:1];
            
            if ([[groupDict objectForKey:@"type"] integerValue] ==2) {
                if (![[dict objectForKey:@"fname"] isEqualToString:@""])
                    tempStr = [[[dict objectForKey:@"fname"] uppercaseString] substringToIndex:1];
                else if (![[dict objectForKey:@"mname"] isEqualToString:@""])
                    tempStr = [[[dict objectForKey:@"mname"] uppercaseString] substringToIndex:1];
                else if (![[dict objectForKey:@"lname"] isEqualToString:@""])
                    tempStr = [[[dict objectForKey:@"lname"] uppercaseString] substringToIndex:1];
            }
        }
        else
        {
            if (![[dict objectForKey:@"last_name"] isEqualToString:@""])
                tempStr = [[[dict objectForKey:@"last_name"] uppercaseString] substringToIndex:1];
            else if (![[dict objectForKey:@"first_name"] isEqualToString:@""])
                tempStr = [[[dict objectForKey:@"first_name"] uppercaseString] substringToIndex:1];
            else
                tempStr = [[[dict objectForKey:@"middle_name"] uppercaseString] substringToIndex:1];
            
            if ([[groupDict objectForKey:@"type"] integerValue] ==2) {
                if (![[dict objectForKey:@"lname"] isEqualToString:@""])
                    tempStr = [[[dict objectForKey:@"lname"] uppercaseString] substringToIndex:1];
                else if (![[dict objectForKey:@"fname"] isEqualToString:@""])
                    tempStr = [[[dict objectForKey:@"fname"] uppercaseString] substringToIndex:1];
                else
                    tempStr = [[[dict objectForKey:@"mname"] uppercaseString] substringToIndex:1];
            }
        }
        
        if (![tempStr isEqualToString:[key uppercaseString]])
        {
            if ([arrTemp count] > 0)
                [contactList addObject:arrTemp];
            
            arrTemp = [[NSMutableArray alloc] init];
            [arrTemp addObject:dict];
            
            [keyList addObject:tempStr];
            key = tempStr;
        }
        else
            [arrTemp addObject:dict];
    }
    
    if ([arrTemp count] > 0)
        [contactList addObject:arrTemp];
    
    if ([contactList count]) {
        tblContacts.hidden = NO;
        emptyView.hidden = YES;
        btnEdit.enabled = YES;
    } else {
        tblContacts.hidden = YES;
        emptyView.hidden = NO;
        btnEdit.enabled = NO;
    }
    [tblContacts reloadData];
}

- (NSMutableArray *)GetPhonesFromPurple : (NSDictionary *)_dict
{
    NSArray * homeArray = [[_dict objectForKey:@"home"] objectForKey:@"fields"];
    NSArray * workArray = [[_dict objectForKey:@"work"] objectForKey:@"fields"];
    
    NSMutableArray *arrPhone = [[NSMutableArray alloc] init];
    
    for (int i = 0 ; i < [homeArray count] ; i++)
    {
        NSDictionary * dict = [homeArray objectAtIndex:i];
        if ([[dict objectForKey:@"field_type"] isEqualToString:@"phone"] || [[dict objectForKey:@"field_name"] isEqualToString:@"Mobile"] || [[dict objectForKey:@"field_name"] isEqualToString:@"Mobile#2"] || [[dict objectForKey:@"field_name"] isEqualToString:@"Phone#2"] || [[dict objectForKey:@"field_name"] isEqualToString:@"Phone#3"])
            [arrPhone addObject:[dict objectForKey:@"field_value"]];
    }
    
    for (int i = 0 ; i < [workArray count] ; i++)
    {
        NSDictionary * dict = [workArray objectAtIndex:i];
        if ([[dict objectForKey:@"field_type"] isEqualToString:@"phone"] || [[dict objectForKey:@"field_name"] isEqualToString:@"Mobile"] || [[dict objectForKey:@"field_name"] isEqualToString:@"Mobile#2"] || [[dict objectForKey:@"field_name"] isEqualToString:@"Phone#2"] || [[dict objectForKey:@"field_name"] isEqualToString:@"Phone#3"])
            [arrPhone addObject:[dict objectForKey:@"field_value"]];
    }
    if ([[groupDict objectForKey:@"type"] integerValue] == 2) {
        for (NSString *phone in [_dict objectForKey:@"phones"]) {
            [arrPhone addObject:phone];
        }
    }
    return arrPhone;
}

- (NSMutableArray *)GetEmailsFromPurple : (NSDictionary *)_dict
{
    NSArray * homeArray = [[_dict objectForKey:@"home"] objectForKey:@"fields"];
    NSArray * workArray = [[_dict objectForKey:@"work"] objectForKey:@"fields"];
    
    NSMutableArray *arrEmail = [[NSMutableArray alloc] init];
    
    for (int i = 0 ; i < [homeArray count] ; i++)
    {
        NSDictionary * dict = [homeArray objectAtIndex:i];
        if ([[dict objectForKey:@"field_type"] isEqualToString:@"email"])
            [arrEmail addObject:[dict objectForKey:@"field_value"]];
    }
    
    for (int i = 0 ; i < [workArray count] ; i++)
    {
        NSDictionary * dict = [workArray objectAtIndex:i];
        if ([[dict objectForKey:@"field_type"] isEqualToString:@"email"])
            [arrEmail addObject:[dict objectForKey:@"field_value"]];
    }
    
    return arrEmail;
}

- (NSMutableArray *)GetPhonesFromGrey : (NSDictionary *)_dict
{
    NSArray * fieldsArray = [_dict objectForKey:@"fields"];
    
    NSMutableArray *arrPhone = [[NSMutableArray alloc] init];
    
    for (int i = 0 ; i < [fieldsArray count] ; i++)
    {
        NSDictionary * dict = [fieldsArray objectAtIndex:i];
        if ([[dict objectForKey:@"field_type"] isEqualToString:@"phone"])
            [arrPhone addObject:[dict objectForKey:@"field_value"]];
    }
    
    return arrPhone;
}

- (NSMutableArray *)GetEmailsFromGrey : (NSDictionary *)_dict
{
    NSArray * fieldsArray = [_dict objectForKey:@"fields"];
    
    NSMutableArray *arrEmail = [[NSMutableArray alloc] init];
    
    for (int i = 0 ; i < [fieldsArray count] ; i++)
    {
        NSDictionary * dict = [fieldsArray objectAtIndex:i];
        if ([[dict objectForKey:@"field_type"] isEqualToString:@"email"])
            [arrEmail addObject:[dict objectForKey:@"field_value"]];
    }
    
    return arrEmail;
}


- (void)changeEditingStatus:(BOOL)status
{
    [tblContacts setEditing:status animated:YES];
    btnChat.hidden = status;
    btnClose.hidden = !status;
    btnBack.hidden = status;
    btnBackFunction.hidden = status;
    btnCar.hidden = !status;
    [self showHideBottomView];
    
    NSInteger countExistVideoMember = 0;
//    if (status) {
//        for (int i = 0; i < [arrContacts count]; i ++) {
//            NSDictionary *dict = [arrContacts objectAtIndex:i];
//            if ([[dict objectForKey:@"contact_type"] intValue] == 1 && [arrSelectedContacts containsObject:[dict valueForKey:@"contact_id"]]) {
//                countExistVideoMember = countExistVideoMember + 1;
//            }
//        }
//        if (countExistVideoMember > 0) {
//            btnGroupVideoChat.enabled = YES;
//        }else{
//            btnGroupVideoChat.enabled = NO;
//        }
//    }else{
        for (NSDictionary *dict in arrContacts) {
            if ([[groupDict objectForKey:@"type"] integerValue] != 2) {
                if ([[dict objectForKey:@"contact_type"] intValue] == 1 && [[dict objectForKey:@"sharing_status"] integerValue] != 4) {
                    countExistVideoMember = countExistVideoMember + 1;
                }
            }else{
                if ([[dict objectForKey:@"user_id"] integerValue] != [[AppDelegate sharedDelegate].userId integerValue] && [[dict objectForKey:@"sharing_status"] integerValue] != 4) {
                    countExistVideoMember = countExistVideoMember + 1;
                }
            }
        }
        if (countExistVideoMember > 0) {
            btnGroupVideoChat.enabled = YES;
        }else{
            btnGroupVideoChat.enabled = NO;
        }
//    }
}

- (BOOL)showHideBottomView
{
    NSArray * selectedRows = [tblContacts indexPathsForSelectedRows];
    NSInteger countExistVideoMember = 0;
    if (btnEdit.selected) {
        for (NSIndexPath *indexPath in selectedRows) {
            NSDictionary *dict = [[contactList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            if ([[groupDict objectForKey:@"type"] integerValue] != 2) {
                if ([[dict objectForKey:@"contact_type"] intValue] == 1 && [[dict objectForKey:@"sharing_status"] integerValue] != 4) {
                    countExistVideoMember = countExistVideoMember + 1;
                }
            }else{
                if ([[dict objectForKey:@"user_id"] integerValue] != [[AppDelegate sharedDelegate].userId integerValue] && [[dict objectForKey:@"sharing_status"] integerValue] != 4) {
                    countExistVideoMember = countExistVideoMember + 1;
                }
            }
        }
        if (countExistVideoMember > 0) {
            btnGroupVideoChat.enabled = YES;
        }else{
            btnGroupVideoChat.enabled = NO;
        }
    }
    if ([selectedRows count]) {
        viewBottom.hidden = NO;
        btnAddContact.hidden = YES;
        return YES;
    }
    viewBottom.hidden = YES;
    btnAddContact.hidden = NO;
    return NO;
}

#pragma mark - Scroll View Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [searchBarForList resignFirstResponder];
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        if (alertView.tag == 1) {
            [self deleteGroup];
        } else if (alertView.tag == 2) {
            [self removeUser];
        }
    }
}

#pragma mark - UITableView DataSource, Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [keyList count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [keyList objectAtIndex:section];
}

//- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    
//    UIView *headerView = [[UIView alloc] init];
//    [headerView setBackgroundColor:[UIColor lightGrayColor]];
//    return headerView;
//}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    int keyIndex = -1;
    
    for (int i = 0; i < [keyList count]; i++)
        if ([[keyList objectAtIndex:i] isEqualToString:title])
        {
            keyIndex = i;
            break;
        }
    
    return keyIndex;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[contactList objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return rowHeight;
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    UITableViewHeaderFooterView *v = (UITableViewHeaderFooterView *)view;
    //v.backgroundView.backgroundColor = [UIColor lightGrayColor];
    v.backgroundView.backgroundColor = [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0f];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([AppDelegate sharedDelegate].viewType == 0)
    {
        NSDictionary * dict = [[contactList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

        
        TileViewCell *cell = [tblContacts dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        // Set;
        if (cell == nil)
        {
            cell = [[TileViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        //cell.profileImageView.frame = CGRectMake(30, 21, 260, 260);
        
        NSString * firstName = [dict objectForKey:@"first_name"];
        NSString * middleName = [dict objectForKey:@"middle_name"];
        NSString * lastName = [dict objectForKey:@"last_name"];
        if ([[groupDict objectForKey:@"type"] integerValue] !=2) {
            if ([[dict objectForKey:@"is_read"] boolValue])
                [cell.imgViewNew setHidden:YES];
            else
                [cell.imgViewNew setHidden:NO];
            
            //        NSURL * imageURL = [NSURL URLWithString:[dict objectForKey:@"photo_url"]];
            //        NSData *data = [NSData dataWithContentsOfURL:imageURL];
            //        UIImage *profileImage = [[UIImage alloc] initWithData:data];
            //        [cell.profileImageView setImage:profileImage];
            if ([[dict objectForKey:@"contact_type"] integerValue] == 1) {
                [cell setPhoto:[dict objectForKey:@"profile_image"]];
            } else if ([[dict objectForKey:@"contact_type"] integerValue] == 2) {
                [cell setPhoto:[dict objectForKey:@"photo_url"]];
            }
            
            cell.firstName.text = [NSString stringWithFormat:@"%@ %@", firstName, middleName];
            cell.lastName.text = lastName;
            cell.delegate = self;
            cell.sessionId = @"";
            cell.contactId = [dict objectForKey:@"contact_id"];
            cell.curContact = dict;
            
            if ([[dict objectForKey:@"contact_type"] integerValue] == 1)
            {
                [cell.contactBut setImage:[UIImage imageNamed:@"BtnChat.png"] forState:UIControlStateNormal];
                
                CGPoint centerPt = cell.contactBut.center;
                
                [cell.contactBut setFrame:CGRectMake(0, 0, 32, 32)];
                [cell.contactBut setCenter:centerPt];
                [cell.statusImageView setHidden:NO];
                
                if ([dict objectForKey:@"online"])
                    [cell.statusImageView setImage:[UIImage imageNamed:@"online"]];
                else
                    [cell.statusImageView setImage:[UIImage imageNamed:@"offline"]];
                
                // Phone Button
                centerPt = cell.phoneBut.center;
                
                [cell.phoneBut setFrame:CGRectMake(0, 0, 32, 32)];
                [cell.phoneBut setCenter:centerPt];
                
                if ([[dict objectForKey:@"sharing_status"] integerValue] != 4)
                    [cell.phoneBut setImage:[UIImage imageNamed:@"BtnPhone.png"] forState:UIControlStateNormal];
                else
                    [cell.phoneBut setImage:[UIImage imageNamed:@"EditContact.png"] forState:UIControlStateNormal];
                // End
                
                cell.type = 1;
                cell.arrPhone = [dict objectForKey:@"phones"];//[self GetPhonesFromPurple:dict];
                cell.arrEmail = [self GetEmailsFromPurple:dict];
                
                [cell.firstName setTextColor:[UIColor colorWithRed:110.0f/255.0f green:75.0f/255.0f blue:154.0f/255.0f alpha:1.0f]];
                [cell.lastName setTextColor:[UIColor colorWithRed:110.0f/255.0f green:75.0f/255.0f blue:154.0f/255.0f alpha:1.0f]];
            }
            else if ([[dict objectForKey:@"contact_type"] integerValue] == 2)
            {
                [cell.contactBut setImage:[UIImage imageNamed:@"BtnMailGrey"] forState:UIControlStateNormal];
                
                CGPoint centerPt = cell.contactBut.center;
                
                [cell.contactBut setFrame:CGRectMake(0, 0, 32, 20)];
                [cell.contactBut setCenter:centerPt];
                [cell.statusImageView setHidden:YES];
                
                // Phone Button
                centerPt = cell.phoneBut.center;
                
                [cell.phoneBut setFrame:CGRectMake(0, 0, 32, 32)];
                [cell.phoneBut setCenter:centerPt];
                [cell.phoneBut setImage:[UIImage imageNamed:@"BtnPhoneGrey.png"] forState:UIControlStateNormal];
                // End
                
                cell.type = 2;
                cell.arrPhone = [dict objectForKey:@"phones"];//[self GetPhonesFromGrey:dict];
                cell.arrEmail = [self GetEmailsFromGrey:dict];
                
                [cell.firstName setTextColor:[UIColor colorWithRed:86.0f/255.0f green:86.0f/255.0f blue:86.0f/255.0f alpha:1.0f]];
                [cell.lastName setTextColor:[UIColor colorWithRed:86.0f/255.0f green:86.0f/255.0f blue:86.0f/255.0f alpha:1.0f]];
            }
            
            if (btnEdit.selected) {
                [cell.contactBut setFrame:CGRectMake(245, 344, 32, 32)];
                [cell.phoneBut setFrame:CGRectMake(188, 343, 32, 33 )];
            }else{
                [cell.contactBut setFrame:CGRectMake(264, 344, 32, 32)];
                [cell.phoneBut setFrame:CGRectMake(207, 343, 32, 33 )];
            }
            
            [cell setBorder];

        }else{
            firstName = [dict objectForKey:@"fname"];
            middleName = [dict objectForKey:@"mname"];
            lastName = [dict objectForKey:@"lname"];
            
            [cell.imgViewNew setHidden:YES];
            
            [cell setPhoto:[dict objectForKey:@"profile_image"]];
            
            cell.firstName.text = [NSString stringWithFormat:@"%@ %@", firstName, middleName];
            cell.lastName.text = lastName;
            cell.delegate = self;
            cell.sessionId = @"";
            cell.contactId = [dict objectForKey:@"user_id"];
            cell.curContact = dict;
            
//            if ([[dict objectForKey:@"contact_type"] integerValue] == 1)
//            {
            if ([[dict objectForKey:@"user_id"] integerValue] == [APPDELEGATE.userId integerValue]) {
                cell.contactBut.hidden = YES;
                cell.phoneBut.hidden = YES;
            }else{
                cell.contactBut.hidden = NO;
                cell.phoneBut.hidden = NO;
            }
                [cell.contactBut setImage:[UIImage imageNamed:@"BtnChat.png"] forState:UIControlStateNormal];
                
                CGPoint centerPt = cell.contactBut.center;
                
                [cell.contactBut setFrame:CGRectMake(0, 0, 32, 32)];
                [cell.contactBut setCenter:centerPt];
                [cell.statusImageView setHidden:NO];
                
                if ([dict objectForKey:@"online"])
                    [cell.statusImageView setImage:[UIImage imageNamed:@"online"]];
                else
                    [cell.statusImageView setImage:[UIImage imageNamed:@"offline"]];
                
                // Phone Button
                centerPt = cell.phoneBut.center;
                
                [cell.phoneBut setFrame:CGRectMake(0, 0, 32, 32)];
                [cell.phoneBut setCenter:centerPt];
                
                if ([[dict objectForKey:@"sharing_status"] integerValue] != 4)
                    [cell.phoneBut setImage:[UIImage imageNamed:@"BtnPhone.png"] forState:UIControlStateNormal];
                else
                    [cell.phoneBut setImage:[UIImage imageNamed:@"EditContact.png"] forState:UIControlStateNormal];
                // End
                
                cell.type = 1;
                cell.arrPhone = [self GetPhonesFromPurple:dict];
                cell.arrEmail = [self GetEmailsFromPurple:dict];
                
                [cell.firstName setTextColor:[UIColor colorWithRed:110.0f/255.0f green:75.0f/255.0f blue:154.0f/255.0f alpha:1.0f]];
                [cell.lastName setTextColor:[UIColor colorWithRed:110.0f/255.0f green:75.0f/255.0f blue:154.0f/255.0f alpha:1.0f]];
            //}
            
            if (btnEdit.selected) {
                [cell.contactBut setFrame:CGRectMake(245, 344, 32, 32)];
                [cell.phoneBut setFrame:CGRectMake(188, 343, 32, 33 )];
            }else{
                [cell.contactBut setFrame:CGRectMake(264, 344, 32, 32)];
                [cell.phoneBut setFrame:CGRectMake(207, 343, 32, 33 )];
            }
            
            [cell setBorder];

        }
        
        return cell;
    }
    else if ([AppDelegate sharedDelegate].viewType == 1)
    {
        NSDictionary * dict = [[contactList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        ContactCell *cell = [tblContacts dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        // Set;
        if (cell == nil)
        {
            cell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        cell.backgroundView.frame = CGRectMake(0, 3, 290, 66);
        
        NSString * firstName = [dict objectForKey:@"first_name"];
        NSString * middleName = [dict objectForKey:@"middle_name"];
        NSString * lastName = [dict objectForKey:@"last_name"];
        if ([[groupDict objectForKey:@"type"] integerValue] !=2) {
            if ([[dict objectForKey:@"is_read"] boolValue])
                [cell.imgViewNew setHidden:YES];
            else
                [cell.imgViewNew setHidden:NO];
            
            //        NSURL * imageURL = [NSURL URLWithString:[dict objectForKey:@"photo_url"]];
            //        NSData *data = [NSData dataWithContentsOfURL:imageURL];
            //        UIImage *profileImage = [[UIImage alloc] initWithData:data];
            //        [cell.profileImageView setImage:profileImage];
            if ([[dict objectForKey:@"contact_type"] integerValue] == 1) {
                [cell setPhoto:[dict objectForKey:@"profile_image"]];
            } else if ([[dict objectForKey:@"contact_type"] integerValue] == 2) {
                [cell setPhoto:[dict objectForKey:@"photo_url"]];
            }
            cell.firstName.text = [NSString stringWithFormat:@"%@ %@", firstName, middleName];
            cell.lastName.text = lastName;
            cell.delegate = self;
            cell.sessionId = @"";
            cell.contactId = [dict objectForKey:@"contact_id"];
            cell.curContact = dict;
            
            if ([[dict objectForKey:@"contact_type"] integerValue] == 1)
            {
                [cell.contactBut setImage:[UIImage imageNamed:@"BtnChat.png"] forState:UIControlStateNormal];
                
                CGPoint centerPt = cell.contactBut.center;
                
                [cell.contactBut setFrame:CGRectMake(0, 0, 32, 32)];
                [cell.contactBut setCenter:centerPt];
                [cell.statusImageView setHidden:NO];
                
                if ([dict objectForKey:@"online"])
                    [cell.statusImageView setImage:[UIImage imageNamed:@"online"]];
                else
                    [cell.statusImageView setImage:[UIImage imageNamed:@"offline"]];
                
                // Phone Button
                centerPt = cell.phoneBut.center;
                
                [cell.phoneBut setFrame:CGRectMake(0, 0, 32, 32)];
                [cell.phoneBut setCenter:centerPt];
                
                if ([[dict objectForKey:@"sharing_status"] integerValue] != 4)
                    [cell.phoneBut setImage:[UIImage imageNamed:@"BtnPhone.png"] forState:UIControlStateNormal];
                else
                    [cell.phoneBut setImage:[UIImage imageNamed:@"EditContact.png"] forState:UIControlStateNormal];
                //End
                
                cell.type = 1;
                cell.arrPhone = [dict objectForKey:@"phones"];;//[self GetPhonesFromPurple:dict];
                cell.arrEmail = [self GetEmailsFromPurple:dict];
                
                [cell.firstName setTextColor:[UIColor colorWithRed:110.0f/255.0f green:75.0f/255.0f blue:154.0f/255.0f alpha:1.0f]];
                [cell.lastName setTextColor:[UIColor colorWithRed:110.0f/255.0f green:75.0f/255.0f blue:154.0f/255.0f alpha:1.0f]];
            }
            else if ([[dict objectForKey:@"contact_type"] integerValue] == 2)
            {
                [cell.contactBut setImage:[UIImage imageNamed:@"BtnMailGrey.png"] forState:UIControlStateNormal];
                
                CGPoint centerPt = cell.contactBut.center;
                
                [cell.contactBut setFrame:CGRectMake(0, 0, 32, 20)];
                [cell.contactBut setCenter:centerPt];
                [cell.statusImageView setHidden:YES];
                
                // Phone Button
                centerPt = cell.phoneBut.center;
                
                [cell.phoneBut setFrame:CGRectMake(0, 0, 32, 32)];
                [cell.phoneBut setCenter:centerPt];
                [cell.phoneBut setImage:[UIImage imageNamed:@"BtnPhoneGrey.png"] forState:UIControlStateNormal];
                // End
                
                cell.type = 2;
                cell.arrPhone = [dict objectForKey:@"phones"];;//[self GetPhonesFromGrey:dict];
                cell.arrEmail = [self GetEmailsFromGrey:dict];
                
                [cell.firstName setTextColor:[UIColor colorWithRed:86.0f/255.0f green:86.0f/255.0f blue:86.0f/255.0f alpha:1.0f]];
                [cell.lastName setTextColor:[UIColor colorWithRed:86.0f/255.0f green:86.0f/255.0f blue:86.0f/255.0f alpha:1.0f]];
            }
            
            [cell setBorder];
            
            if (btnEdit.selected) {
                [cell.contactBut setFrame:CGRectMake(222, 26, 32, 32)];
                [cell.phoneBut setFrame:CGRectMake(180, 25, 32, 32 )];
                [cell.imgViewNew setFrame:CGRectMake(229, 10, 40, 40)];
                [cell.imgSeperator setFrame:CGRectMake(-28, 70, 300, 1)];
            }else{
                [cell.contactBut setFrame:CGRectMake(260, 26, 32, 32)];
                [cell.phoneBut setFrame:CGRectMake(218, 25, 32, 32 )];
                [cell.imgViewNew setFrame:CGRectMake(267, 10, 40, 40)];
                [cell.imgSeperator setFrame:CGRectMake(10, 70, 300, 1)];
            }
            if (tableView.editing) {
                if ([arrSelectedContacts containsObject:[dict objectForKey:@"contact_id"]])
                {
                    //                cell.selected = YES;
                    [tableView selectRowAtIndexPath:indexPath
                                           animated:NO
                                     scrollPosition:UITableViewScrollPositionNone];
                }
            }

        }else{
            firstName = [dict objectForKey:@"fname"];
            middleName = [dict objectForKey:@"mname"];
            lastName = [dict objectForKey:@"lname"];
//            if ([[dict objectForKey:@"is_read"] boolValue])
                [cell.imgViewNew setHidden:YES];
//            else
//                [cell.imgViewNew setHidden:NO];
            
            //        NSURL * imageURL = [NSURL URLWithString:[dict objectForKey:@"photo_url"]];
            //        NSData *data = [NSData dataWithContentsOfURL:imageURL];
            //        UIImage *profileImage = [[UIImage alloc] initWithData:data];
            //        [cell.profileImageView setImage:profileImage];
            [cell setPhoto:[dict objectForKey:@"profile_image"]];
            
            cell.firstName.text = [NSString stringWithFormat:@"%@ %@", firstName, middleName];
            cell.lastName.text = lastName;
            cell.delegate = self;
            cell.sessionId = @"";
            cell.contactId = [dict objectForKey:@"user_id"];
            cell.curContact = dict;
            
//            if ([[dict objectForKey:@"contact_type"] integerValue] == 1)
//            {
            if ([[dict objectForKey:@"user_id"] integerValue] == [APPDELEGATE.userId integerValue]) {
                cell.contactBut.hidden = YES;
                cell.phoneBut.hidden = YES;
            }else{
                cell.contactBut.hidden = NO;
                cell.phoneBut.hidden = NO;
            }
            
                [cell.contactBut setImage:[UIImage imageNamed:@"BtnChat.png"] forState:UIControlStateNormal];
                
                CGPoint centerPt = cell.contactBut.center;
                
                [cell.contactBut setFrame:CGRectMake(0, 0, 32, 32)];
                [cell.contactBut setCenter:centerPt];
                [cell.statusImageView setHidden:NO];
                
//                if ([dict objectForKey:@"online"])
                    [cell.statusImageView setImage:[UIImage imageNamed:@"online"]];
//                else
//                    [cell.statusImageView setImage:[UIImage imageNamed:@"offline"]];
            
                // Phone Button
                centerPt = cell.phoneBut.center;
                
                [cell.phoneBut setFrame:CGRectMake(0, 0, 32, 32)];
                [cell.phoneBut setCenter:centerPt];
                
                if ([[dict objectForKey:@"sharing_status"] integerValue] != 4)
                    [cell.phoneBut setImage:[UIImage imageNamed:@"BtnPhone.png"] forState:UIControlStateNormal];
                else
                    [cell.phoneBut setImage:[UIImage imageNamed:@"EditContact.png"] forState:UIControlStateNormal];
                //End
                
                cell.type = 1;
                cell.arrPhone = [self GetPhonesFromPurple:dict];
                cell.arrEmail = [self GetEmailsFromPurple:dict];
                
                [cell.firstName setTextColor:[UIColor colorWithRed:110.0f/255.0f green:75.0f/255.0f blue:154.0f/255.0f alpha:1.0f]];
                [cell.lastName setTextColor:[UIColor colorWithRed:110.0f/255.0f green:75.0f/255.0f blue:154.0f/255.0f alpha:1.0f]];
            
            
            [cell setBorder];
            
            if (btnEdit.selected) {
                [cell.contactBut setFrame:CGRectMake(222, 26, 32, 32)];
                [cell.phoneBut setFrame:CGRectMake(180, 25, 32, 32 )];
                [cell.imgViewNew setFrame:CGRectMake(229, 10, 40, 40)];
                [cell.imgSeperator setFrame:CGRectMake(-28, 70, 300, 1)];
            }else{
                [cell.contactBut setFrame:CGRectMake(260, 26, 32, 32)];
                [cell.phoneBut setFrame:CGRectMake(218, 25, 32, 32 )];
                [cell.imgViewNew setFrame:CGRectMake(267, 10, 40, 40)];
                [cell.imgSeperator setFrame:CGRectMake(10, 70, 300, 1)];
            }
            if (tableView.editing) {
                if ([arrSelectedContacts containsObject:[dict objectForKey:@"contact_id"]])
                {
                    //                cell.selected = YES;
                    [tableView selectRowAtIndexPath:indexPath
                                           animated:NO
                                     scrollPosition:UITableViewScrollPositionNone];
                }
            }

        }
        
        return cell;
    }
    
    return nil;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dict = [[contactList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if (tableView.editing) {
        [self showHideBottomView];
        if ([[groupDict objectForKey:@"type"] integerValue] !=2) {
            [arrSelectedContacts addObject:[dict objectForKey:@"contact_id"]];
        }else{
            [arrSelectedContacts addObject:[dict objectForKey:@"user_id"]];
        }
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([[groupDict objectForKey:@"type"] integerValue] !=2) {
        [self updateIsRead:[dict objectForKey:@"contact_id"] contactType:[[dict objectForKey:@"contact_type"] stringValue]];
        
        if ([[dict objectForKey:@"contact_type"] integerValue] == 1)
        {
            if ([[dict objectForKey:@"sharing_status"] integerValue] == 0)
                return;
            else if ([[dict objectForKey:@"sharing_status"] integerValue] == 4)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"GINKO" message:@"Oops! Contact would like to chat only" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                
                [alertView show];
            }
            else
            {
                PreviewProfileViewController *vc = [[PreviewProfileViewController alloc] initWithNibName:@"PreviewProfileViewController" bundle:nil];
                vc.userData = dict;
                
                BOOL isWork;
                if ([dict[@"work"][@"fields"] count] > 0) {
                    isWork = YES;
                } else {    // really new and show profile selection screen
                    isWork = NO;
                }
                vc.isWork = isWork;
                vc.isViewOnly = YES;
                vc.isChat = NO;
                
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
        else if ([[dict objectForKey:@"contact_type"] integerValue] == 2)
        {
            GreyDetailController *vc = [[GreyDetailController alloc] initWithNibName:@"GreyDetailController" bundle:nil];
            vc.curContactDict = dict;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else{
        if ([APPDELEGATE.userId longValue] == [[dict objectForKey:@"user_id"] longValue]){
            //[self GetUserInformation];
            [self onPermissionEdit:nil];
        }else{
            if ([[dict objectForKey:@"sharing_status"] integerValue] == 0)
                return;
            else if ([[dict objectForKey:@"sharing_status"] integerValue] == 4)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"GINKO" message:@"Oops! Contact would like to chat only" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                
                [alertView show];
            }
            else
            {
                [self getMemberInfoForDirectory:[dict objectForKey:@"user_id"]];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dict = [[contactList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (tableView.editing) {
        [self showHideBottomView];
        if ([[groupDict objectForKey:@"type"] integerValue] !=2) {
            [arrSelectedContacts removeObject:[dict objectForKey:@"contact_id"]];
        }else{
            [arrSelectedContacts removeObject:[dict objectForKey:@"user_id"]];
        }
    }
}
- (void)GetUserInformation
{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        
        
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            NSDictionary *arrMyInfo = [_responseObject objectForKey:@"data"];
            
            APPDELEGATE.isProfileEdit = YES;
            
            PreviewProfileViewController *vc = [[PreviewProfileViewController alloc] initWithNibName:@"PreviewProfileViewController" bundle:nil];
            vc.userData = arrMyInfo;
            
            BOOL isWork;
            if ([arrMyInfo[@"work"][@"fields"] count] > 0) {
                isWork = YES;
            } else {    // really new and show profile selection screen
                isWork = NO;
            }
            vc.isWork = isWork;
            vc.isSetup = NO;
            
            [self.navigationController pushViewController:vc animated:YES];
            
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        NSLog(@"Connection failed - %@", [[_error userInfo] objectForKey:@"NSLocalizedDescription"]);
        [CommonMethods showAlertUsingTitle:@"Error" andMessage:[[_error userInfo] objectForKey:@"NSLocalizedDescription"]];
    } ;
    
    [[Communication sharedManager] GetMyInfo:[AppDelegate sharedDelegate].sessionId contact_uid:nil successed:successed failure:failure];
}
- (void)getMemberInfoForDirectory:(NSString *)userId{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            NSDictionary *dict = [_responseObject objectForKey:@"data"];
            PreviewProfileViewController *vc = [[PreviewProfileViewController alloc] initWithNibName:@"PreviewProfileViewController" bundle:nil];
            vc.userData = dict;
            
            BOOL isWork;
            if ([dict[@"work"][@"fields"] count] > 0) {
                isWork = YES;
            } else {    // really new and show profile selection screen
                isWork = NO;
            }
            vc.isWork = isWork;
            vc.isViewOnly = YES;
            vc.isChat = NO;
            vc.directoryUser = YES;
            vc.groupInfo = groupDict;
            [self.navigationController pushViewController:vc animated:YES];
            
        }else{
            [CommonMethods showAlertUsingTitle:@"Error!" andMessage:[[_responseObject objectForKey:@"err"] objectForKey:@"errMsg"]];
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Internet Connection Error!"];
        
    } ;
    
    [[YYYCommunication sharedManager] GetMemberInfo:APPDELEGATE.sessionId directoryId:[groupDict objectForKey:@"group_id"] userId:userId successed:successed failure:failure];
}

#pragma mark - ContactCell, TileCell Delegate
- (void)didCallVideo:(NSDictionary *)contactDict{
    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted) {
                    [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your Camera or Microphone is disabled.\nPlease go to settings and grant access to it."];
                }
                else {
                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                        if (!granted) {
                            [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your Camera or Microphone is disabled.\nPlease go to settings and grant access to it."];
                        }
                        else {
                            if ([[groupDict objectForKey:@"type"] integerValue] != 2) {
                                [self CreateVideoAndVoiceConferenceOneToOneBoard:[contactDict objectForKey:@"contact_id"] dict:contactDict type:1];
                            }else{
                                [self CreateVideoAndVoiceConferenceOneToOneBoard:[contactDict objectForKey:@"user_id"] dict:contactDict type:1];
                            }
                        }
                    }];
                }
            });
        }];
    }
}
- (void)didCallVoice:(NSDictionary *)contactDict{
    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted) {
                    [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your Camera or Microphone is disabled.\nPlease go to settings and grant access to it."];
                }
                else {
                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                        if (!granted) {
                            [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your Camera or Microphone is disabled.\nPlease go to settings and grant access to it."];
                        }
                        else {
                            if ([[groupDict objectForKey:@"type"] integerValue] != 2) {
                                [self CreateVideoAndVoiceConferenceOneToOneBoard:[contactDict objectForKey:@"contact_id"] dict:contactDict type:2];
                            }else{
                                [self CreateVideoAndVoiceConferenceOneToOneBoard:[contactDict objectForKey:@"user_id"] dict:contactDict type:2];
                            }
                        }
                    }];
                }
            });
        }];
    }
}
- (void)sendMail:(NSString *)_email
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    
    if ([mailClass canSendMail])
        [self displayComposerSheet: _email];
}

- (void)didChat:(NSDictionary *)contactDict
{
    if ([[groupDict objectForKey:@"type"] integerValue] != 2) {
        [self CreateMessageBoard:[contactDict objectForKey:@"contact_id"] dict:contactDict];
    }else{
        [self CreateMessageBoard:[contactDict objectForKey:@"user_id"] dict:contactDict];
    }
}

- (void)didEdit:(NSDictionary *)contactDict
{
    [AppDelegate sharedDelegate].type = 4;
    
    if ([contactDict objectForKey:@"detected_location"] && ![[contactDict objectForKey:@"detected_location"] isEqualToString:@""])
    {
        ProfileViewController * controller = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
        controller.contactInfo = contactDict;
        [self.navigationController pushViewController:controller animated:YES];
    }else{
        ProfileRequestController * controller = [[ProfileRequestController alloc] initWithNibName:@"ProfileRequestController" bundle:nil];
        controller.contactInfo = contactDict;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

-(void)CreateVideoAndVoiceConferenceOneToOneBoard:(NSString*)ids dict:(NSDictionary *)contactInfo type:(NSInteger)_type
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            
            [APPDELEGATE.conferenceMembersForVideoCalling removeAllObjects];
            NSMutableDictionary *dictOfUser = [[NSMutableDictionary alloc] init];
            
            if ([[groupDict objectForKey:@"type"] integerValue] != 2) {
                [dictOfUser setObject:[contactInfo valueForKey:@"contact_id"] forKey:@"user_id"];
                [dictOfUser setObject:[NSString stringWithFormat:@"%@ %@", [contactInfo objectForKey:@"first_name"], [contactInfo objectForKey:@"last_name"]] forKey:@"name"];
                [dictOfUser setObject:[contactInfo objectForKey:@"profile_image"] forKey:@"photo_url"];
            }else{
                [dictOfUser setObject:[contactInfo valueForKey:@"user_id"] forKey:@"user_id"];
                [dictOfUser setObject:[NSString stringWithFormat:@"%@ %@", [contactInfo objectForKey:@"fname"], [contactInfo objectForKey:@"lname"]] forKey:@"name"];
                [dictOfUser setObject:[contactInfo objectForKey:@"profile_image"] forKey:@"photo_url"];
            }
            if (_type == 1) {
                [dictOfUser setObject:@"on" forKey:@"videoStatus"];
            }else{
                [dictOfUser setObject:@"off" forKey:@"videoStatus"];
            }
            [dictOfUser setObject:@"on" forKey:@"voiceStatus"];
            [dictOfUser setObject:@(1) forKey:@"conferenceStatus"];
            [dictOfUser setObject:@(0) forKey:@"isOwner"];
            [dictOfUser setObject:@(0) forKey:@"isInvited"];
            [dictOfUser setObject:@(1) forKey:@"isInvitedByMe"];
            
            [APPDELEGATE.conferenceMembersForVideoCalling addObject:dictOfUser];
            
            VideoVoiceConferenceViewController *viewcontroller = [[VideoVoiceConferenceViewController alloc] initWithNibName:@"VideoVoiceConferenceViewController" bundle:nil];
            APPDELEGATE.isOwnerForConference = YES;
            APPDELEGATE.isJoinedOnConference = YES;
            APPDELEGATE.conferenceId = [[_responseObject objectForKey:@"data"] objectForKey:@"board_id"];
            viewcontroller.boardId = [[_responseObject objectForKey:@"data"] objectForKey:@"board_id"];
            viewcontroller.conferenceType = _type;
            if ([[groupDict objectForKey:@"type"] integerValue] != 2) {
                viewcontroller.conferenceName =[NSString stringWithFormat:@"%@ %@", [contactInfo objectForKey:@"first_name"], [contactInfo objectForKey:@"last_name"]];
            }else{
                viewcontroller.conferenceName =[NSString stringWithFormat:@"%@ %@", [contactInfo objectForKey:@"fname"], [contactInfo objectForKey:@"lname"]];
            }
            [self.navigationController pushViewController:viewcontroller animated:YES];
            
            
        }else{
            [CommonMethods showAlertUsingTitle:@"Error!" andMessage:[[_responseObject objectForKey:@"err"] objectForKey:@"errMsg"]];
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Internet Connection Error!"];
        
    } ;
    
    [[YYYCommunication sharedManager] CreateChatBoard:[AppDelegate sharedDelegate].sessionId userids:ids successed:successed failure:failure];
}
#pragma mark - MFMailComposer
-(void)displayComposerSheet : (NSString *)email
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:@""];
	
    
	// Set up recipients
	NSArray *toRecipients = [NSArray arrayWithObjects:email, nil];
	NSArray *ccRecipients = [NSArray arrayWithObject:@""];
	NSArray *bccRecipients = [NSArray arrayWithObject:@""];
	
	[picker setToRecipients:toRecipients];
	[picker setCcRecipients:ccRecipients];
	[picker setBccRecipients:bccRecipients];
    
	[picker setMessageBody:@"" isHTML:YES];
	
	[self presentViewController:picker animated:YES completion:nil];
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    NSString * messageResult ;
	switch (result)
	{
		case MFMailComposeResultCancelled:
			messageResult = @"Mail cancelled.";
			break;
		case MFMailComposeResultSaved:
			messageResult = @"Mail saved.";
			break;
		case MFMailComposeResultSent:
            messageResult = @"Mail successfully sent";
            [[[UIAlertView alloc] initWithTitle: nil message:messageResult delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
			break;
		case MFMailComposeResultFailed:
			messageResult = @"Mail failed.";
			break;
		default:
			messageResult = @"Mail don't send.";
			break;
	}
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Go To Chat
-(void)CreateMessageBoard:(NSString*)ids dict:(NSDictionary *)contactInfo
{
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
	
	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        
		[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
		
		if ([[_responseObject objectForKey:@"success"] boolValue])
		{
			NSMutableArray *lstTemp = [[NSMutableArray alloc] init];
            
            if (contactInfo) {
                NSMutableDictionary *dictTemp = [[NSMutableDictionary alloc] init];
                if ([[groupDict objectForKey:@"type"] integerValue] != 2) {
                    [dictTemp setObject:[contactInfo objectForKey:@"first_name"] forKey:@"fname"];
                    [dictTemp setObject:[contactInfo objectForKey:@"last_name"] forKey:@"lname"];
                    [dictTemp setObject:[contactInfo objectForKey:@"photo_url"] forKey:@"photo_url"];
                    [dictTemp setObject:[contactInfo objectForKey:@"contact_id"] forKey:@"user_id"];
                }else{
                    [dictTemp setObject:[contactInfo objectForKey:@"fname"] forKey:@"fname"];
                    [dictTemp setObject:[contactInfo objectForKey:@"lname"] forKey:@"lname"];
                    [dictTemp setObject:[contactInfo objectForKey:@"profile_image"] forKey:@"photo_url"];
                    [dictTemp setObject:[contactInfo objectForKey:@"user_id"] forKey:@"user_id"];
                }
                
                [lstTemp addObject:dictTemp];
            } else {
                for (NSDictionary *dict in arrContacts)
                {
                    if ([[dict objectForKey:@"contact_type"] intValue] == 1)
                    {
                        NSMutableDictionary *dictTemp = [[NSMutableDictionary alloc] init];
                        
                            [dictTemp setObject:[dict objectForKey:@"first_name"] forKey:@"fname"];
                            [dictTemp setObject:[dict objectForKey:@"last_name"] forKey:@"lname"];
                            [dictTemp setObject:[dict objectForKey:@"photo_url"] forKey:@"photo_url"];
                            [dictTemp setObject:[dict objectForKey:@"contact_id"] forKey:@"user_id"];
                        
                        [lstTemp addObject:dictTemp];
                    }
                }
            }
			
			NSMutableDictionary *dictTemp1 = [[NSMutableDictionary alloc] init];
			
			[dictTemp1 setObject:[AppDelegate sharedDelegate].firstName forKey:@"fname"];
			[dictTemp1 setObject:[AppDelegate sharedDelegate].lastName forKey:@"lname"];
			[dictTemp1 setObject:[AppDelegate sharedDelegate].photoUrl forKey:@"photo_url"];
			[dictTemp1 setObject:[AppDelegate sharedDelegate].userId forKey:@"user_id"];
			
			[lstTemp addObject:dictTemp1];
            
            YYYChatViewController *viewcontroller = [[YYYChatViewController alloc] initWithNibName:@"YYYChatViewController" bundle:nil];
            viewcontroller.boardid = [[_responseObject objectForKey:@"data"] objectForKey:@"board_id"];
            viewcontroller.lstUsers = [[NSMutableArray alloc] initWithArray:lstTemp];
            NSMutableArray *availableUsers = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in arrContacts) {
                
                if ([[groupDict objectForKey:@"type"] integerValue] != 2) {
                    if ([[dict objectForKey:@"contact_type"] intValue] == 1 && [[dict objectForKey:@"sharing_status"] integerValue] != 4) {
                        [availableUsers addObject:dict];
                    }
                }else{
                    if ([[dict objectForKey:@"user_id"] integerValue] != [[AppDelegate sharedDelegate].userId integerValue] && [[dict objectForKey:@"sharing_status"] integerValue] != 4) {
                        [availableUsers addObject:dict];
                    }
                }
            }

            if (contactInfo) {
                viewcontroller.groupName = nil;
            }else{
                viewcontroller.groupName = [groupDict objectForKey:@"name"];
            }
            viewcontroller.isDeletedFriend = NO;
            if ([[groupDict objectForKey:@"type"] integerValue] != 2) {
                viewcontroller.isDeletedFriend = NO;
            }else{
                viewcontroller.isMemberForDiectory = YES;
            }
            if ([[contactInfo objectForKey:@"sharing_status"] integerValue] == 4) {
                viewcontroller.isAbleVideoConference = YES;
            }
            viewcontroller.availableUsers = availableUsers;
            [self.navigationController pushViewController:viewcontroller animated:YES];
            
		}else{
            [CommonMethods showAlertUsingTitle:@"Error!" andMessage:[[_responseObject objectForKey:@"err"] objectForKey:@"errMsg"]];
		}
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
		
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Internet Connection Error!"];
		
    } ;
    
	[[YYYCommunication sharedManager] CreateChatBoard:[AppDelegate sharedDelegate].sessionId userids:ids successed:successed failure:failure];
}
-(void)CreateMessageBoardForDirectory
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            NSMutableArray *lstTemp = [[NSMutableArray alloc] init];
            
                for (NSDictionary *dict in arrContacts)
                {
                    NSMutableDictionary *dictTemp = [[NSMutableDictionary alloc] init];
                    [dictTemp setObject:[dict objectForKey:@"fname"] forKey:@"fname"];
                    [dictTemp setObject:[dict objectForKey:@"lname"] forKey:@"lname"];
                    [dictTemp setObject:[dict objectForKey:@"profile_image"] forKey:@"photo_url"];
                    [dictTemp setObject:[dict objectForKey:@"user_id"] forKey:@"user_id"];
                    
                    [lstTemp addObject:dictTemp];
                }
            
            YYYChatViewController *viewcontroller = [[YYYChatViewController alloc] initWithNibName:@"YYYChatViewController" bundle:nil];
            viewcontroller.boardid = [[_responseObject objectForKey:@"data"] objectForKey:@"board_id"];
            viewcontroller.lstUsers = [[NSMutableArray alloc] initWithArray:lstTemp];
            viewcontroller.groupName = [groupDict objectForKey:@"name"];
            viewcontroller.isMemberForDiectory = YES;
            viewcontroller.isDirectory = YES;
            NSMutableArray *availableUsers = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in arrContacts) {
                
                if ([[groupDict objectForKey:@"type"] integerValue] != 2) {
                    if ([[dict objectForKey:@"contact_type"] intValue] == 1 && [[dict objectForKey:@"sharing_status"] integerValue] != 4) {
                        [availableUsers addObject:dict];
                    }
                }else{
                    if ([[dict objectForKey:@"user_id"] integerValue] != [[AppDelegate sharedDelegate].userId integerValue] && [[dict objectForKey:@"sharing_status"] integerValue] != 4) {
                        [availableUsers addObject:dict];
                    }
                }
            }
            viewcontroller.availableUsers = availableUsers;
            
            [self.navigationController pushViewController:viewcontroller animated:YES];
            
        }else{
            [CommonMethods showAlertUsingTitle:@"Error!" andMessage:[[_responseObject objectForKey:@"err"] objectForKey:@"errMsg"]];
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Internet Connection Error!"];
        
    } ;
    
    [[YYYCommunication sharedManager] CreateBoardDirectory:APPDELEGATE.sessionId directoryId:[groupDict objectForKey:@"group_id"] successed:successed failure:failure];
}
#pragma mark - SearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    //    searchStartFlag = YES;
    //    [self showCancelBut:YES];
    [searchBar setShowsCancelButton:YES animated:YES];
    UIView *view = [searchBar.subviews objectAtIndex:0];
    for (UIView *subView in view.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *cancelButton = (UIButton *)subView;
            [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        }
    }
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    
    [searchBar setShowsCancelButton:NO animated:YES];
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self onSearchCancel:searchBar];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBarForList resignFirstResponder];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText isEqualToString:@""]) {
        [self onSearchCancel:nil];
        return;
    }
    
    NSDictionary *dict;
    NSString *firstName, *middleName, *lastName;
    
    [arrFilteredList removeAllObjects];
    
    for (int i = 0; i < [arrContacts count]; i++)
    {
        dict = [arrContacts objectAtIndex:i];
        
        firstName = [[dict objectForKey:@"first_name"] uppercaseString];
        middleName = [[dict objectForKey:@"middle_name"] uppercaseString];
        lastName = [[dict objectForKey:@"last_name"] uppercaseString];
        if ([[groupDict objectForKey:@"type"] integerValue]== 2) {
            firstName = [[dict objectForKey:@"fname"] uppercaseString];
            middleName = [[dict objectForKey:@"mname"] uppercaseString];
            lastName = [[dict objectForKey:@"lname"] uppercaseString];
        }
        if ([firstName rangeOfString:[searchText uppercaseString]].location == NSNotFound) {
            if ([middleName rangeOfString:[searchText uppercaseString]].location == NSNotFound) {
                if ([lastName rangeOfString:[searchText uppercaseString]].location == NSNotFound) {
                }
                else
                    [arrFilteredList addObject:dict];
            }
            else
                [arrFilteredList addObject:dict];
        }
        else
            [arrFilteredList addObject:dict];
    }
    
    [self sortContactsByLetters];
}

#pragma mark - WebApi Integration
- (void)getOnlyContacts
{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        NSLog(@"%@",_responseObject);
        [arrContacts removeAllObjects];
        [arrFilteredList removeAllObjects];
        if ([[_responseObject objectForKey:@"success"] boolValue])
		{
            for (NSDictionary *dict in [_responseObject objectForKey:@"data"]) {
                if (![dict objectForKey:@"entity_id"]) {
                    [arrContacts addObject:dict];
                }
            }
            
            arrFilteredList = [[NSMutableArray alloc] initWithArray:arrContacts];
            
            if ([arrFilteredList count]) {
                tblContacts.hidden = NO;
                emptyView.hidden = YES;
            } else {
                tblContacts.hidden = YES;
                emptyView.hidden = NO;
            }
            
            [self sortContactsByLetters];
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Internet Connection Error!"];
    } ;
    
    [[Communication sharedManager] GetContacts:[AppDelegate sharedDelegate].sessionId sortby:nil search:nil category:nil contactType:nil successed:successed failure:failure];
}

- (void)getUsersForGroup
{
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        if ([[_responseObject objectForKey:@"success"] boolValue])
		{
            [arrContacts removeAllObjects];
            [arrFilteredList removeAllObjects];
            
            int coundPurpleContacts = 0;
            for (NSDictionary *dict in [[_responseObject objectForKey:@"data"] objectForKey:@"data"]) {
                [arrContacts addObject:dict];
                if ([[groupDict objectForKey:@"type"] integerValue] == 2) {
                    if ([[dict objectForKey:@"user_id"] integerValue] != [[AppDelegate sharedDelegate].userId integerValue] && [[dict objectForKey:@"sharing_status"] integerValue] != 4) {
                        coundPurpleContacts = coundPurpleContacts + 1;
                    }
                }else{
                    if ([[dict objectForKey:@"contact_type"] integerValue] == 1 && [[dict objectForKey:@"sharing_status"] integerValue] != 4) {
                        coundPurpleContacts = coundPurpleContacts + 1;
                    }
                }
            }
            
            arrFilteredList = [[NSMutableArray alloc] initWithArray:arrContacts];
            
            if ([arrFilteredList count]) {
                tblContacts.hidden = NO;
                emptyView.hidden = YES;
                btnEdit.enabled = YES;
            } else {
                tblContacts.hidden = YES;
                emptyView.hidden = NO;
                btnEdit.enabled = NO;
            }
            
            [self sortContactsByLetters];
            
            //[self changeEditingStatus:NO];
            //btnEdit.selected = NO;
            if ([arrFilteredList count]){
                if (coundPurpleContacts > 0) {
                    btnGroupVideoChat.enabled = YES;
                }else{
                    btnGroupVideoChat.enabled = NO;
                }
            }else{
                btnGroupVideoChat.enabled = NO;
            }
            if (searchBarForList.text && ![searchBarForList.text  isEqual: @""]) {
                [self searchBar:searchBarForList textDidChange:searchBarForList.text];
            }
            
            NSInteger countExistVideoMember = 0;
                for (NSDictionary *dict in arrContacts) {
                    if ([[groupDict objectForKey:@"type"] integerValue] != 2) {
                        if ([[dict objectForKey:@"contact_type"] intValue] == 1 && [[dict objectForKey:@"sharing_status"] integerValue] != 4) {
                            countExistVideoMember = countExistVideoMember + 1;
                        }
                    }else{
                        if ([[dict objectForKey:@"user_id"] integerValue] != [[AppDelegate sharedDelegate].userId integerValue] && [[dict objectForKey:@"sharing_status"] integerValue] != 4) {
                            countExistVideoMember = countExistVideoMember + 1;
                        }
                    }
                }
                if (countExistVideoMember > 0) {
                    btnGroupVideoChat.enabled = YES;
                }else{
                    btnGroupVideoChat.enabled = NO;
                }
        }else{
            btnEdit.enabled = NO;
            btnGroupVideoChat.enabled = NO;
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Internet Connection Error!"];
    } ;
    if ([[groupDict objectForKey:@"type"] integerValue] != 2) {
        if ([groupDict objectForKey:@"group_id"] ) {
            [[YYYCommunication sharedManager] getUsersForGroup:[AppDelegate sharedDelegate].sessionId groupID:[groupDict objectForKey:@"group_id"] successed:successed failure:failure];
        }else{
            [[YYYCommunication sharedManager] getUsersForGroup:[AppDelegate sharedDelegate].sessionId groupID:[groupDict objectForKey:@"id"] successed:successed failure:failure];
        }
    }else{
        [[YYYCommunication sharedManager] GetMembersDirectory:APPDELEGATE.sessionId directoryId:[groupDict objectForKey:@"group_id"] pageNum:@"1" countPerPage:@"40" successed:successed failure:failure];
    }
}

- (void)updateIsRead: (NSString *)_contactID
        contactType : (NSString *)_contactType
{
	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        NSLog(@"%@",_responseObject);
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        NSLog(@"Connection failed - %@", _error);
    } ;
    
    [[Communication sharedManager] UpdateIsRead:[AppDelegate sharedDelegate].sessionId contactIds:_contactID contactType:_contactType isRead:@"true" successed:successed failure:failure];
}

- (void)deleteGroup
{
//    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
//	{
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//        NSDictionary *result = _responseObject;
//        if ([[result objectForKey:@"success"] boolValue]) {
//            [self.navigationController popViewControllerAnimated:YES];
//        } else {
//            NSDictionary *dictError = [result objectForKey:@"err"];
//            if (dictError) {
//                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:[dictError objectForKey:@"errMsg"]];
//            } else {
//                [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Failed to connect to server!"];
//            }
//        }
//	};
//	
//	void ( ^failure )( NSError* _error ) = ^( NSError* _error )
//	{
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//		[CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Internet Connection Error!"];
//	};
//	
//	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    
//    [[YYYCommunication sharedManager] deleteGroup:[AppDelegate sharedDelegate].sessionId groupID:[groupDict objectForKey:@"group_id"] successed:successed failure:failure];
    
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary *result = _responseObject;
        if ([[result objectForKey:@"success"] boolValue]) {
            //            [self getOnlyContacts];
            [self getUsersForGroup];
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
    NSString *strKeys = @"";
    for (int i = 0; i < [arrContacts count]; i ++) {
        NSDictionary *dict = [arrContacts objectAtIndex:i];
        //if ([arrSelectedContacts containsObject:[dict valueForKey:@"contact_id"]]) {
            strKeys = [NSString stringWithFormat:@"%@%@_%@,", strKeys, [dict objectForKey:@"contact_id"], [dict objectForKey:@"contact_type"]];
       // }
    }
    if ([strKeys length]) {
        strKeys = [strKeys substringToIndex:[strKeys length] - 1];
    }
    if ([groupDict objectForKey:@"group_id"]) {
        [[YYYCommunication sharedManager] removeUserFromGroup:[AppDelegate sharedDelegate].sessionId groupID:[groupDict objectForKey:@"group_id"] contactKeys:strKeys successed:successed failure:failure];
    }else{
        [[YYYCommunication sharedManager] removeUserFromGroup:[AppDelegate sharedDelegate].sessionId groupID:[groupDict objectForKey:@"id"] contactKeys:strKeys successed:successed failure:failure];
    }
}

- (void)removeUser
{
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
	{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary *result = _responseObject;
        if ([[result objectForKey:@"success"] boolValue]) {
//            [self getOnlyContacts];
            [arrSelectedContacts removeAllObjects];
            viewBottom.hidden = YES;
            btnAddContact.hidden = NO;
            [self getUsersForGroup];
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
    NSString *strKeys = @"";
    for (int i = 0; i < [arrContacts count]; i ++) {
        NSDictionary *dict = [arrContacts objectAtIndex:i];
        if ([arrSelectedContacts containsObject:[dict valueForKey:@"contact_id"]]) {
            strKeys = [NSString stringWithFormat:@"%@%@_%@,", strKeys, [dict objectForKey:@"contact_id"], [dict objectForKey:@"contact_type"]];
        }
    }
    
//    NSArray * selectedRows = [tblContacts indexPathsForSelectedRows];
//    NSString *strKeys = @"";
//    for (int i = 0 ; i < [selectedRows count] ; i++)
//    {
//        NSIndexPath * indexPath = [selectedRows objectAtIndex:i];
//        NSDictionary * dict = [[contactList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//        strKeys = [NSString stringWithFormat:@"%@%@_%@,", strKeys, [dict objectForKey:@"contact_id"], [dict objectForKey:@"contact_type"]];
//    }
    if ([strKeys length]) {
        strKeys = [strKeys substringToIndex:[strKeys length] - 1];
    }
    if ([groupDict objectForKey:@"group_id"]) {
        [[YYYCommunication sharedManager] removeUserFromGroup:[AppDelegate sharedDelegate].sessionId groupID:[groupDict objectForKey:@"group_id"] contactKeys:strKeys successed:successed failure:failure];
    }else{
        [[YYYCommunication sharedManager] removeUserFromGroup:[AppDelegate sharedDelegate].sessionId groupID:[groupDict objectForKey:@"id"] contactKeys:strKeys successed:successed failure:failure];
    }
}

#pragma mark - Actions
- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onChat:(id)sender
{
    if ([[groupDict objectForKey:@"type"] integerValue] != 2) {
        NSString *strIds = @"";
        
        for (NSDictionary *dict in arrContacts) {
            
            if ([[groupDict objectForKey:@"type"] integerValue] != 2) {
                if ([[dict objectForKey:@"contact_type"] intValue] == 1) {
                    strIds = [NSString stringWithFormat:@"%@,%@", strIds, [dict objectForKey:@"contact_id"]];
                }
            }else{
                strIds = [NSString stringWithFormat:@"%@,%@", strIds, [dict objectForKey:@"user_id"]];
            }
        }
        
        if ([strIds length]) {
            strIds = [strIds substringFromIndex:1];
        }
        if (![strIds length]) {
            [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Oops, no purple contacts."];
            return;
        }
        [self CreateMessageBoard:strIds dict:nil];
    }else if ([[groupDict objectForKey:@"type"] integerValue] == 2){
        [self CreateMessageBoardForDirectory];
    }
}

- (IBAction)onAddContact:(id)sender
{
    GroupAddContactsViewController *vc = [[GroupAddContactsViewController alloc] initWithNibName:@"GroupAddContactsViewController" bundle:nil];
    if ([groupDict objectForKey:@"group_id"] ) {
        vc.groupID = [groupDict objectForKey:@"group_id"];
    }else{
        vc.groupID = [groupDict objectForKey:@"id"];
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onCar:(id)sender
{
    //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Do you want to remove this group permanently?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Do you want to remove all contacts from this group?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    alertView.tag = 1;
    [alertView show];
}

- (IBAction)onClose:(id)sender
{
    if (btnEdit.selected) {
        btnEdit.selected = !btnEdit.selected;
    }
    [self changeEditingStatus:NO];
    [tblContacts reloadData];
}

- (IBAction)onEdit:(id)sender
{
    btnEdit.selected = !btnEdit.selected;
    [self changeEditingStatus:btnEdit.selected];
    [arrSelectedContacts removeAllObjects];
    [tblContacts reloadData];
}

- (IBAction)onRemove:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Do you want to remove the contact(s) from this group?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    alertView.tag = 2;
    [alertView show];
}

- (IBAction)onSearchCancel:(id)sender
{
    searchBarForList.text = @"";
    arrFilteredList = [[NSMutableArray alloc] initWithArray:arrContacts];
    [self sortContactsByLetters];
    if (sender) {
        [searchBarForList setShowsCancelButton:NO animated:YES];
        [searchBarForList resignFirstResponder];
    }
}

- (IBAction)onGroupVideoChat:(id)sender {
//    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
//    [sheet setTag:100];
//    [sheet addButtonWithTitle:@"Ginko Video Call"];
//    [sheet addButtonWithTitle:@"Ginko Voice Call"];
//    [sheet addButtonWithTitle:@"Cancel"];
//    sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
//    [sheet showInView:self.view];
//    currentActionSheet = sheet;
    
    SelectUserForConferenceViewController *viewcontroller = [[SelectUserForConferenceViewController alloc] initWithNibName:@"SelectUserForConferenceViewController" bundle:nil];
    viewcontroller.viewcontroller = self;
    
    NSMutableArray *availableUsers = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in arrContacts) {
        
        if ([[groupDict objectForKey:@"type"] integerValue] != 2) {
            if ([[dict objectForKey:@"contact_type"] intValue] == 1 && [[dict objectForKey:@"sharing_status"] integerValue] != 4) {
                [availableUsers addObject:dict];
            }
        }else{
            if ([[dict objectForKey:@"user_id"] integerValue] != [[AppDelegate sharedDelegate].userId integerValue] && [[dict objectForKey:@"sharing_status"] integerValue] != 4) {
                [availableUsers addObject:dict];
            }
        }
    }
    if ([[groupDict objectForKey:@"type"] integerValue] != 2) {
        viewcontroller.isDirectory = NO;
    }else{
        viewcontroller.isDirectory = YES;
    }
    viewcontroller.isReturnFromGruopView = YES;
    viewcontroller.arrayUsers = availableUsers;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:viewcontroller];
    [self presentViewController:nc animated:YES completion:nil];
}

- (void)closeCurrentActionWhenConferenceView{
    if (currentActionSheet) {
        [currentActionSheet dismissWithClickedButtonIndex:-1 animated:YES];
    }
}
- (void)startVideoCallingWithSelectedContact:(NSString *)ids availContacts:(NSMutableArray *)users{
    availableIdsWithConfere = ids;
    availContactsWithConfere = users;
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    [sheet setTag:100];
    [sheet addButtonWithTitle:@"Ginko Video Call"];
    [sheet addButtonWithTitle:@"Ginko Voice Call"];
    [sheet addButtonWithTitle:@"Cancel"];
    sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
    [sheet showInView:self.view];
    currentActionSheet = sheet;
}
#pragma - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != (actionSheet.numberOfButtons - 1))
    {
        switch ([actionSheet tag]) {
            case 100:
            {

                if (buttonIndex == 0) {
                    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
                        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (!granted) {
                                    [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your Camera or Microphone is disabled.\nPlease go to settings and grant access to it."];
                                }
                                else {
                                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                                        if (!granted) {
                                            [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your Camera or Microphone is disabled.\nPlease go to settings and grant access to it."];
                                        }
                                        else {
                                            [self CreateVideoAndVoiceConferenceBoard:availableIdsWithConfere dict:nil type:1];
                                        }
                                    }];
                                }
                            });
                        }];
                    }
                }else if(buttonIndex == 1){
                    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
                        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (!granted) {
                                    [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your Camera or Microphone is disabled.\nPlease go to settings and grant access to it."];
                                }
                                else {
                                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                                        if (!granted) {
                                            [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your Camera or Microphone is disabled.\nPlease go to settings and grant access to it."];
                                        }
                                        else {
                                            [self CreateVideoAndVoiceConferenceBoard:availableIdsWithConfere dict:nil type:2];
                                        }
                                    }];
                                }
                            });
                        }];
                    }
                }
                break;
            }
            default:
                break;
        }
    }
}
-(void)CreateVideoAndVoiceConferenceBoard:(NSString*)ids dict:(NSDictionary *)contactInfo type:(NSInteger)_type
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            [APPDELEGATE.conferenceMembersForVideoCalling removeAllObjects];
            
            for (NSDictionary *dict in availContactsWithConfere)
            {
                
                NSMutableDictionary *dictOfUser = [[NSMutableDictionary alloc] init];
                if ([[groupDict objectForKey:@"type"] integerValue] != 2) {
                    [dictOfUser setObject:[dict valueForKey:@"contact_id"] forKey:@"user_id"];
                    [dictOfUser setObject:[NSString stringWithFormat:@"%@ %@", [dict objectForKey:@"first_name"], [dict objectForKey:@"last_name"]] forKey:@"name"];
                    [dictOfUser setObject:[dict objectForKey:@"photo_url"] forKey:@"photo_url"];
                }else{
                    
                    [dictOfUser setObject:[dict valueForKey:@"user_id"] forKey:@"user_id"];
                    [dictOfUser setObject:[NSString stringWithFormat:@"%@ %@", [dict objectForKey:@"fname"], [dict objectForKey:@"lname"]] forKey:@"name"];
                    [dictOfUser setObject:[dict objectForKey:@"profile_image"] forKey:@"photo_url"];
                }
                
                if (_type == 1) {
                    [dictOfUser setObject:@"on" forKey:@"videoStatus"];
                }else{
                    [dictOfUser setObject:@"off" forKey:@"videoStatus"];
                }
                [dictOfUser setObject:@"on" forKey:@"voiceStatus"];
                [dictOfUser setObject:@(1) forKey:@"conferenceStatus"];
                [dictOfUser setObject:@(0) forKey:@"isOwner"];
                [dictOfUser setObject:@(0) forKey:@"isInvited"];
                [dictOfUser setObject:@(1) forKey:@"isInvitedByMe"];
                
                [APPDELEGATE.conferenceMembersForVideoCalling addObject:dictOfUser];
            }
            
            VideoVoiceConferenceViewController *viewcontroller = [[VideoVoiceConferenceViewController alloc] initWithNibName:@"VideoVoiceConferenceViewController" bundle:nil];
            APPDELEGATE.isOwnerForConference = YES;
            APPDELEGATE.isJoinedOnConference = YES;
            APPDELEGATE.conferenceId = [[_responseObject objectForKey:@"data"] objectForKey:@"board_id"];
            viewcontroller.boardId = [[_responseObject objectForKey:@"data"] objectForKey:@"board_id"];
            viewcontroller.conferenceType = _type;
            viewcontroller.conferenceName =[groupDict objectForKey:@"name"];
            [self.navigationController pushViewController:viewcontroller animated:YES];
            
            
        }else{
            [CommonMethods showAlertUsingTitle:@"Error!" andMessage:[[_responseObject objectForKey:@"err"] objectForKey:@"errMsg"]];
        }
    };
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Internet Connection Error!"];
        
    } ;
    
    [[YYYCommunication sharedManager] CreateChatBoard:[AppDelegate sharedDelegate].sessionId userids:ids successed:successed failure:failure];
}

- (IBAction)onPermissionEdit:(id)sender {
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            
            APPDELEGATE.type = 7;
            ProfileRequestController * controller = [[ProfileRequestController alloc] initWithNibName:@"ProfileRequestController" bundle:nil];
            //controller.contactInfo = contactDict;
            controller.directoryId = [groupDict objectForKey:@"group_id"];
            controller.directoryName = [groupDict objectForKey:@"name"];
            controller.contactInfo = [_responseObject objectForKey:@"data"];
            [self.navigationController pushViewController:controller animated:YES];
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Internet Connection Error!"];
    } ;
    
    [[YYYCommunication sharedManager] GetPermissionMemberDirectory:APPDELEGATE.sessionId directoryId:[groupDict objectForKey:@"group_id"]  successed:successed failure:failure];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
