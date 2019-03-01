//
//  CBDetailViewController.m
//  GINKO
//
//  Created by mobidev on 5/17/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import "CBDetailViewController.h"
#import "ContactBuilderClient.h"
#import "ProfileCell.h"
#import "CBMainViewController.h"
#import "CBImportOtherViewController.h"
#import "CBImportItemViewController.h"
#import "ContactImporterClient.h"

#import "UIImage+Tint.h"

//static NSString * const ProfileCellIdentifier = @"ProfileCell";

@interface CBDetailViewController ()
{
    BOOL isOn;
    NSDictionary *myInfo;
    NSMutableDictionary *profileDict;
    NSMutableDictionary *homeDict;
    NSMutableDictionary *workDict;
    NSString * _sharingInfo;
    NSString * _sharedHomeFields;
    NSString * _sharedWorkFields;
}
@end

@implementation CBDetailViewController
@synthesize tblInfo, navView, btnDone, btnDoneFake, viewTap;
@synthesize imgValid, viewDel, viewOff, viewOn, btnOff, btnOn, btnChatOnly, btnCheck;
@synthesize lblBottomLine, lblMiddleLine, lblTopLine;
@synthesize lblEmail, lblOther, lblRevalidateOther, viewRevalidate, imgProvider, imgRevalidate, viewBottom;
@synthesize curCBEmail, oauth_token;

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
    
    isOn = YES;
    
    _sharingInfo = [[NSString alloc] init];
    _sharedHomeFields = [[NSString alloc] init];
    _sharedHomeFields = @"";
    _sharedWorkFields = [[NSString alloc] init];
    _sharedWorkFields = @"";
    
    myInfo = [NSDictionary dictionary];
    profileDict = [[NSMutableDictionary alloc] init];
    homeDict = [[NSMutableDictionary alloc] init];
    workDict = [[NSMutableDictionary alloc] init];
    homeIdDict = [[NSMutableDictionary alloc] init];
    workIdDict = [[NSMutableDictionary alloc] init];
    
    // Zhun's
    totalArr = [[NSMutableArray alloc] init];
    lstField = [[NSMutableArray alloc] initWithObjects:@"Mobile",@"Mobile#2",@"Phone",@"Phone#2",@"Phone#3",@"Fax",@"Email",@"Email#2",@"Address",@"Address#2",@"Birthday",@"Facebook",@"Twitter",@"Website",@"Custom",@"Custom#2",@"Custom#3", nil];
    
    [self getInfo];
    
    [_trashBut setImage:[[UIImage imageNamed:@"TrashIcon"] tintImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    
    if ([curCBEmail.provider isEqualToString:@"google"]) {
        imgProvider.image = [UIImage imageNamed:@"ImportMail"];
        imgRevalidate.image = [UIImage imageNamed:@"ImportMail"];
    } else if ([curCBEmail.provider isEqualToString:@"yahoo"]) {
        imgProvider.image = [UIImage imageNamed:@"ImportYahoo"];
        imgRevalidate.image = [UIImage imageNamed:@"ImportYahoo"];
    } else if ([curCBEmail.provider isEqualToString:@"hotmail"]) {
        imgProvider.image = [UIImage imageNamed:@"ImportMsn"];
        imgRevalidate.image = [UIImage imageNamed:@"ImportMsn"];
    } else if ([curCBEmail.provider isEqualToString:@"msn"]) {
        imgProvider.image = [UIImage imageNamed:@"ImportMsn"];
        imgRevalidate.image = [UIImage imageNamed:@"ImportMsn"];
    } else if ([curCBEmail.provider isEqualToString:@"live"]) {
        imgProvider.image = [UIImage imageNamed:@"ImportMsn"];
        imgRevalidate.image = [UIImage imageNamed:@"ImportMsn"];
    } else if ([curCBEmail.provider isEqualToString:@"facebook"]) {
        imgProvider.image = [UIImage imageNamed:@"btn_facebook"];
        imgRevalidate.image = [UIImage imageNamed:@"btn_facebook"];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar addSubview:navView];

    [self layoutViews];
    [self layoutOnOffViews];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [navView removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Methods
- (void)layoutViews
{
    if (oauth_token) {
        if (!_globalData.cbIsFromMenu) {
            viewBottom.hidden = NO;
        } else {
            viewDel.hidden = YES;
            CGRect onFrame = viewOn.frame;
            onFrame.size.height += 48;
            [viewOn setFrame:onFrame];
        }
        if ([curCBEmail.authType isEqualToString:@"password"]) {
            lblOther.hidden = NO;
        } else {
            imgProvider.hidden = NO;
        }
    } else {
        isOn = curCBEmail.active;
        imgValid.hidden = curCBEmail.valid;
        if ([curCBEmail.authType isEqualToString:@"password"]) {
            if (curCBEmail.valid) {
                lblOther.hidden = NO;
            } else {
                viewRevalidate.hidden = NO;
                lblRevalidateOther.hidden = NO;
            }
        } else {
            if (curCBEmail.valid) {
                imgProvider.hidden = NO;
            } else {
                viewRevalidate.hidden = NO;
                imgRevalidate.hidden = NO;
            }
        }
    }
    lblEmail.text = curCBEmail.email;
}

- (void)layoutOnOffViews
{
    if (isOn) {
        [lblBottomLine setHidden:YES];
        [lblTopLine setText:@"Automatically send exchange requests to"];
        [lblMiddleLine setText:@"new email contacts."];
    } else {
        [lblBottomLine setHidden:NO];
        [lblTopLine setText:@"Manually send exchange requests to"];
        [lblMiddleLine setText:@"new email contacts. New email contacts"];
    }
    [btnOn setImage:isOn ? [UIImage imageNamed:@"SmallOn"] : [UIImage imageNamed:@"SmallOff"] forState:UIControlStateNormal];
    [btnOff setImage:isOn ? [UIImage imageNamed:@"SmallOff"] : [UIImage imageNamed:@"SmallOn"] forState:UIControlStateNormal];
    if (isOn) {
        viewOn.hidden = NO;
        viewOff.hidden = YES;
    } else {
        viewOff.hidden = NO;
        viewOn.hidden = YES;
    }
}

- (void)displayeShare
{
    NSInteger share_status1 = curCBEmail.sharing_status;
    NSString * share_home_field = curCBEmail.shareHomeFields;
    NSString * share_work_field = curCBEmail.shareWorkFields;
    
    if (share_status1 == 3 && [share_home_field isEqualToString:@""] && [share_work_field isEqualToString:@""])  // select all
    {
        btnCheck.selected = YES;
        
        for (int i = 0; i < [totalArr count]; i++)
            [tblInfo selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        return;
    }
    else if (share_status1 == 4) // chat only
    {
        btnChatOnly.selected = YES;
        return;
    }
//    else if ([share_home_field isEqualToString:@""] && [share_work_field isEqualToString:@""])
//        return;
    
    if ([share_home_field isEqualToString:@""] && (share_status1 == 1 || share_status1 == 3)) {
        for (int j = 0; j < [totalArr count]; j++)
        {
            NSDictionary *tempDict = [totalArr objectAtIndex:j];
            if ([[tempDict objectForKey:@"type"] isEqualToString:@"Home"])
                [tblInfo selectRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    } else if ([share_work_field isEqualToString:@""] && (share_status1 == 2 || share_status1 == 3)) {
        for (int j = 0; j < [totalArr count]; j++)
        {
            NSDictionary *tempDict = [totalArr objectAtIndex:j];
            if ([[tempDict objectForKey:@"type"] isEqualToString:@"Work"])
                [tblInfo selectRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    
    NSArray * h_split_items = [share_home_field componentsSeparatedByString:@","];
    NSArray * w_split_items = [share_work_field componentsSeparatedByString:@","];
    
    for (int i = 0 ; i < [h_split_items count] ; i++)
    {
        for (int j = 0; j < [totalArr count]; j++)
        {
            NSDictionary *tempDict = [totalArr objectAtIndex:j];
            
            if ([[tempDict objectForKey:@"field_id"] intValue] == [h_split_items[i] intValue] && ![[tempDict objectForKey:@"field_name"] isEqualToString:@"header"])
                [tblInfo selectRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    
    for (int i = 0 ; i < [w_split_items count] ; i++)
    {
        for (int j = 0; j < [totalArr count]; j++)
        {
            NSDictionary *tempDict = [totalArr objectAtIndex:j];
            
            if ([[tempDict objectForKey:@"field_id"] intValue] == [w_split_items[i] intValue] && ![[tempDict objectForKey:@"field_name"] isEqualToString:@"header"])
                [tblInfo selectRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    
    // check cells and select header
    int homeCount = 0;
    int workCount = 0;
    
    NSArray * selectedRows = [tblInfo indexPathsForSelectedRows];
    for (int i = 0 ; i < [selectedRows count] ; i++)
    {
        NSIndexPath * selectRow = [selectedRows objectAtIndex:i];
        NSDictionary *tempDict = [totalArr objectAtIndex:selectRow.row];
        
        if ([[tempDict objectForKey:@"type"] isEqualToString:@"Home"])
            homeCount++;
        else
            workCount++;
    }
    if (homeCount >= [homeDict count] && homeCount > 0)
        [tblInfo selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    if (workCount >= [workDict count] && workCount > 0)
    {
        if ([homeDict count] == 0)
            [tblInfo selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        else
            [tblInfo selectRowAtIndexPath:[NSIndexPath indexPathForRow:([homeDict count] + 1) inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        
    }
}

- (void)addCBEmail
{
    void (^successed)(id responseObject) = ^(id responseObject) {
        NSDictionary *result = responseObject;
        
        NSLog(@"add result = %@", result);
        
        if ([[result objectForKey:@"success"] boolValue]) {

            [SVProgressHUD dismiss];
            if (!_globalData.cbIsFromMenu) {
                [[AppDelegate sharedDelegate] setWizardPage:@"2"];
            } else {
                NSArray *arrControllers = self.navigationController.viewControllers;
                for (UIViewController *vc in arrControllers) {
                    if ([vc isKindOfClass:[CBMainViewController class]]) {
                        [self.navigationController popToViewController:vc animated:YES];
                        return;
                    }
                }
            }
            
        } else {
            NSDictionary *dictError = [result objectForKey:@"err"];
            if (dictError) {
                [SVProgressHUD showErrorWithStatus:[dictError objectForKey:@"errMsg"]];
            } else {
                [SVProgressHUD showErrorWithStatus:@"Failed to connect to server!"];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    };
    
    void (^failure)(NSError* error) = ^(NSError* error) {
        [SVProgressHUD showErrorWithStatus:@"Failed to connect to server!"];
    };
    
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeClear];
    if ([oauth_token isEqualToString:@"other"]) {
        [[ContactBuilderClient sharedClient] addOrUpdateCBEmail:[AppDelegate sharedDelegate].sessionId cbID:nil email:lblEmail.text password:curCBEmail.password sharing:[_sharingInfo intValue] sharedHomeFieldIds:_sharedHomeFields sharedWorkFieldIds:_sharedWorkFields active:isOn authType:curCBEmail.authType provider:nil oauthToken:nil username:curCBEmail.username inserver:curCBEmail.inserver inserverType:curCBEmail.inservertype inserverPort:curCBEmail.inserverport successed:successed failure:failure];
    } else {
        [[ContactBuilderClient sharedClient] addOrUpdateCBEmail:[AppDelegate sharedDelegate].sessionId cbID:nil email:lblEmail.text password:nil sharing:[_sharingInfo intValue] sharedHomeFieldIds:_sharedHomeFields sharedWorkFieldIds:_sharedWorkFields active:isOn authType:curCBEmail.authType provider:curCBEmail.provider oauthToken:oauth_token username:nil inserver:nil inserverType:nil inserverPort:nil successed:successed failure:failure];
    }
}

- (void)modifyCBEmail:(NSString *)redirectURL
{
    void (^successed)(id responseObject) = ^(id responseObject) {
        NSDictionary *result = responseObject;
        
        NSLog(@"modify result = %@", result);
        
        if ([[result objectForKey:@"success"] boolValue]) {
            
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:@"Succeeded"];
            [self.navigationController popViewControllerAnimated:YES];
            
        } else {
            NSDictionary *dictError = [result objectForKey:@"err"];
            if (dictError) {
                [SVProgressHUD showErrorWithStatus:[dictError objectForKey:@"errMsg"]];
                if ([[dictError objectForKey:@"errCode"] intValue] == 126) {
                    [imgValid setImage:[UIImage imageNamed:@"IconWarning"]];
                }
            } else {
                [SVProgressHUD showErrorWithStatus:@"Failed to connect to server!"];
            }
        }
    };
    
    void (^failure)(NSError* error) = ^(NSError* error) {
        [SVProgressHUD showErrorWithStatus:@"Failed to connect to server!"];
    };
    
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeClear];
    
    if (redirectURL) {
        NSRange range;
        range = [redirectURL rangeOfString:@"redirect?"];
        
        NSString *code = @"";
        
        if (!(range.location == NSNotFound)) {
            code = [redirectURL substringFromIndex:range.location + range.length];
            NSLog(@"code = %@", code);
        }
        
        self.oauth_token = code;
        _sharingInfo = [NSString stringWithFormat:@"%d", curCBEmail.sharing_status];
        _sharedHomeFields = curCBEmail.shareHomeFields;
        _sharedWorkFields = curCBEmail.shareWorkFields;
    } else {
        
    }
    
    [[ContactBuilderClient sharedClient] addOrUpdateCBEmail:[AppDelegate sharedDelegate].sessionId cbID:curCBEmail.cbID email:curCBEmail.email password:nil sharing:[_sharingInfo intValue] sharedHomeFieldIds:_sharedHomeFields sharedWorkFieldIds:_sharedWorkFields active:isOn authType:curCBEmail.authType provider:curCBEmail.provider oauthToken:self.oauth_token username:curCBEmail.username inserver:nil inserverType:nil inserverPort:nil successed:successed failure:failure];
}

- (void)getInfo
{
    void (^successed)(id responseObject) = ^(id responseObject) {
        NSDictionary *result = responseObject;
        
        NSLog(@"get info result = %@", result);
        
        if ([[result objectForKey:@"success"] boolValue]) {
            
            myInfo = [responseObject objectForKey:@"data"];
            
            NSArray * profileArray = [[myInfo objectForKey:@"profile"] objectForKey:@"fields"];
            NSArray * homeArray = [[myInfo objectForKey:@"home"] objectForKey:@"fields"];
            NSArray * workArray = [[myInfo objectForKey:@"work"] objectForKey:@"fields"];
            
            // Set Profile and Set Name on Nav Bar
            [profileDict setObject:@"" forKey:@"firstname"];
            [profileDict setObject:@"" forKey:@"lastname"];
            [profileDict setObject:@"" forKey:@"Birthday"];
            
            for (int i = 0 ; i < [profileArray count] ; i++)
            {
                NSDictionary * dict = [profileArray objectAtIndex:i];
                if ([[dict objectForKey:@"field_name"] isEqualToString:@"First Name"])
                {
                    [profileDict setObject:[dict objectForKey:@"field_value"] forKey:@"firstname"];
                }
                else if ([[dict objectForKey:@"field_name"] isEqualToString:@"Middle Name"])
                {
                    [profileDict setObject:[dict objectForKey:@"field_value"] forKey:@"middlename"];
                }
                else if ([[dict objectForKey:@"field_name"] isEqualToString:@"Last Name"])
                {
                    [profileDict setObject:[dict objectForKey:@"field_value"] forKey:@"lastname"];
                }
                else if ([[dict objectForKey:@"field_name"] isEqualToString:@"Birthday"])
                {
                    [profileDict setObject:[dict objectForKey:@"field_value"] forKey:@"Birthday"];
                }
            }
            
            // Set Home Info
            
            for (int i = 0 ; i < [homeArray count] ; i++)
            {
                NSDictionary * dict = [homeArray objectAtIndex:i];
                
                if ([lstField containsObject:[dict objectForKey:@"field_name"]])
                {
                    [homeDict setObject:[dict objectForKey:@"field_value"] forKey:[dict objectForKey:@"field_name"]];
                    [homeIdDict setObject:[dict objectForKey:@"field_id"] forKey:[dict objectForKey:@"field_name"]];
                }
            }
            
            // Set Work Info
            for (int i = 0 ; i < [workArray count] ; i++)
            {
                NSDictionary * dict = [workArray objectAtIndex:i];
                
                if ([lstField containsObject:[dict objectForKey:@"field_name"]])
                {
                    [workDict setObject:[dict objectForKey:@"field_value"] forKey:[dict objectForKey:@"field_name"]];
                    [workIdDict setObject:[dict objectForKey:@"field_id"] forKey:[dict objectForKey:@"field_name"]];
                }
            }
            
            // Set Total Array
            if ([homeDict count] > 0)
            {
                NSMutableDictionary * tempDict = [[NSMutableDictionary alloc] init];
                
                [tempDict setObject:@"Home" forKey:@"type"];
                [tempDict setObject:@"header" forKey:@"field_name"];
                [tempDict setObject:@"" forKey:@"field_value"];
                [tempDict setObject:@"" forKey:@"field_id"];
                
                [totalArr addObject:tempDict];
                
                NSArray *keyArr = [homeDict allKeys];
                
                for (NSString *keyValue in lstField)
                {
                    for (int i = 0; i < [keyArr count]; i++)
                    {
                        if ([keyValue isEqualToString:[keyArr objectAtIndex:i]]) {
                            NSMutableDictionary * tempDict = [[NSMutableDictionary alloc] init];
                            
                            [tempDict setObject:@"Home" forKey:@"type"];
                            [tempDict setObject:[keyArr objectAtIndex:i] forKey:@"field_name"];
                            [tempDict setObject:[homeDict objectForKey:[keyArr objectAtIndex:i]] forKey:@"field_value"];
                            [tempDict setObject:[homeIdDict objectForKey:[keyArr objectAtIndex:i]] forKey:@"field_id"];
                            
                            [totalArr addObject:tempDict];
                            break;
                        }
                    }
                }
            }
            
            if ([workDict count] > 0)
            {
                NSMutableDictionary * tempDict = [[NSMutableDictionary alloc] init];
                
                [tempDict setObject:@"Work" forKey:@"type"];
                [tempDict setObject:@"header" forKey:@"field_name"];
                [tempDict setObject:@"" forKey:@"field_value"];
                [tempDict setObject:@"" forKey:@"field_id"];
                
                [totalArr addObject:tempDict];
                
                NSArray *keyArr = [workDict allKeys];
                
                for (NSString *keyValue in lstField)
                {
                    for (int i = 0; i < [keyArr count]; i++)
                    {
                        if ([keyValue isEqualToString:[keyArr objectAtIndex:i]]) {
                            NSMutableDictionary * tempDict = [[NSMutableDictionary alloc] init];
                            
                            [tempDict setObject:@"Work" forKey:@"type"];
                            [tempDict setObject:[keyArr objectAtIndex:i] forKey:@"field_name"];
                            [tempDict setObject:[workDict objectForKey:[keyArr objectAtIndex:i]] forKey:@"field_value"];
                            [tempDict setObject:[workIdDict objectForKey:[keyArr objectAtIndex:i]] forKey:@"field_id"];
                            
                            [totalArr addObject:tempDict];
                            break;
                        }
                    }
                }
                
            }
            
            [SVProgressHUD dismiss];
            [tblInfo reloadData];
            if (curCBEmail) {
                [self displayeShare];
            }
            
        } else {
            NSDictionary *dictError = [result objectForKey:@"err"];
            if (dictError) {
                [SVProgressHUD showErrorWithStatus:[dictError objectForKey:@"errMsg"]];
            } else {
                [SVProgressHUD showErrorWithStatus:@"Failed to connect to server!"];
            }
        }
    };
    
    void (^failure)(NSError* error) = ^(NSError* error) {
        [SVProgressHUD showErrorWithStatus:@"Failed to connect to server!"];
    };
    
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeClear];
    [[ContactBuilderClient sharedClient] getInfo:[AppDelegate sharedDelegate].sessionId successed:successed failure:failure];
}

- (BOOL)GetInfo
{
    NSArray * selectedRows = [tblInfo indexPathsForSelectedRows];
    
    _sharingInfo = @"1";
    _sharedHomeFields = @"";
    _sharedWorkFields = @"";
    
    if ([selectedRows count] == [totalArr count])
    {
        _sharingInfo = @"3";
        
        return YES;
    }
    else if (btnChatOnly.selected)
    {
        _sharingInfo = @"4";
        
        return YES;
    }
    else if ([selectedRows count] == 0 && !btnChatOnly.selected)
        return NO;
    
    int homeCount, workCount;
    
    homeCount = workCount = 0;
    
    for (int i = 0 ; i < [selectedRows count] ; i++)
    {
        NSIndexPath * indexPath = [selectedRows objectAtIndex:i];
        NSDictionary *dict = [totalArr objectAtIndex:indexPath.row];
        if (![[dict objectForKey:@"field_name"] isEqualToString:@"header"])
        {
            if ([[dict objectForKey:@"type"] isEqualToString:@"Home"])
            {
                homeCount++;
                if ([_sharedHomeFields isEqualToString:@""])
                    _sharedHomeFields = [NSString stringWithFormat:@"%@", [dict objectForKey:@"field_id"]];
                else
                    _sharedHomeFields = [NSString stringWithFormat:@"%@,%@",_sharedHomeFields, [dict objectForKey:@"field_id"]];
            }
            if ([[dict objectForKey:@"type"] isEqualToString:@"Work"])
            {
                workCount++;
                if ([_sharedWorkFields isEqualToString:@""])
                    _sharedWorkFields = [NSString stringWithFormat:@"%@", [dict objectForKey:@"field_id"]];
                else
                    _sharedWorkFields = [NSString stringWithFormat:@"%@,%@",_sharedWorkFields, [dict objectForKey:@"field_id"]];
            }
        }
    }
    
    if (homeCount > 0 && workCount > 0)
    {
        _sharingInfo = @"3";
        if (homeCount == [[homeDict allKeys] count]) {
            _sharedHomeFields = @"";
        }
        if (workCount == [[workDict allKeys] count]) {
            _sharedWorkFields = @"";
        }
    }
    else if (homeCount > 0)
    {
        _sharingInfo = @"1";
        if (homeCount == [[homeDict allKeys] count]) {
            _sharedHomeFields = @"";
        }
    }
    else if (workCount > 0)
    {
        _sharingInfo = @"2";
        if (workCount == [[workDict allKeys] count]) {
            _sharedWorkFields = @"";
        }
    }
    
    return YES;
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [totalArr count] ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProfileCell * cell;// = [tblInfo dequeueReusableCellWithIdentifier:ProfileCellIdentifier forIndexPath:indexPath];//[tblInfo dequeueReusableCellWithIdentifier:ProfileCellIdentifier];
//    if (cell == nil)
//    {
        cell = (ProfileCell *)[[[NSBundle mainBundle] loadNibNamed:@"ProfileCell" owner:nil options:nil] objectAtIndex:0];
        //cell = [[ProfileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ProfileCellIdentifier];
//    }
    
    NSDictionary *dict = [totalArr objectAtIndex:indexPath.row];
    
    if ([[dict objectForKey:@"field_name"] isEqualToString:@"header"])
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        UILabel *lblCaption = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, 320, 50)];
        
        [lblCaption setBackgroundColor:[UIColor clearColor]];
        [lblCaption setTextColor:[UIColor colorWithRed:130.0f/255.0f green:87.0f/255.0f blue:131.0f/255.0f alpha:1.0f]];
        [lblCaption setFont:[UIFont boldSystemFontOfSize:14.0f]];
        lblCaption.text = [dict objectForKey:@"type"];
        
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Seperator"]];
        [imgView setFrame:CGRectMake(75, 25, 210, 1)];
        
        [view addSubview:lblCaption];
        [view addSubview:imgView];
        
        [view setBackgroundColor:[UIColor clearColor]];
        
        [cell addSubview:view];
    }
    else
    {
        cell.typeLabel.text = [NSString stringWithFormat:@"%@.", [dict objectForKey:@"field_name"]];
        cell.nameLabel.text = [dict objectForKey:@"field_value"];
    }
    
    // this is where you set your color view
    UIView *customColorView = [[UIView alloc] init];
    customColorView.backgroundColor = [UIColor colorWithRed:180/255.0
                                                      green:138/255.0
                                                       blue:171/255.0
                                                      alpha:0.3];
    cell.selectedBackgroundView =  customColorView;
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    btnDone.hidden = NO;
    btnDoneFake.hidden = NO;
    btnChatOnly.selected = NO;
    
    NSDictionary *dict = [totalArr objectAtIndex:indexPath.row];
    
    // Select Header
    if ([[dict objectForKey:@"field_name"] isEqualToString:@"header"])
    {
        if ([[dict objectForKey:@"type"] isEqualToString:@"Home"]) // Select Home
        {
            [tblInfo selectRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            
            for (int i = indexPath.row + 1; i < [totalArr count] ; i++)
            {
                NSDictionary *tempDict = [totalArr objectAtIndex:i];
                
                if ([[tempDict objectForKey:@"field_name"] isEqualToString:@"header"])
                    break;
                else
                    [tblInfo selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
        else if ([[dict objectForKey:@"type"] isEqualToString:@"Work"]) // Select Work
        {
            for (int i = indexPath.row; i < [totalArr count] ; i++)
                [tblInfo selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    else    // check the cells and select header
    {
        int homeCount = 0;
        int workCount = 0;
        
        NSArray * selectedRows = [tableView indexPathsForSelectedRows];
        for (int i = 0 ; i < [selectedRows count] ; i++)
        {
            NSIndexPath * selectRow = [selectedRows objectAtIndex:i];
            NSDictionary *tempDict = [totalArr objectAtIndex:selectRow.row];
            
            if ([[tempDict objectForKey:@"type"] isEqualToString:@"Home"])
                homeCount++;
            else
                workCount++;
        }
        if (homeCount >= [homeDict count] && homeCount > 0)
            [tblInfo selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        if (workCount >= [workDict count] && workCount > 0)
        {
            if ([homeDict count] == 0)
                [tblInfo selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            else
                [tblInfo selectRowAtIndexPath:[NSIndexPath indexPathForRow:([homeDict count] + 1) inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        
    }
    
    // if all things is checked
    NSArray * selectedRows = [tableView indexPathsForSelectedRows];
    
    if ([selectedRows count] == [totalArr count])
        btnCheck.selected = YES;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    btnDone.hidden = NO;
    btnDoneFake.hidden = NO;
    btnCheck.selected = NO;
    
    NSDictionary *dict = [totalArr objectAtIndex:indexPath.row];
    
    // Select Header
    if ([[dict objectForKey:@"field_name"] isEqualToString:@"header"])
    {
        if ([[dict objectForKey:@"type"] isEqualToString:@"Home"]) // Select Home
        {
            [tblInfo deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO];
            
            for (int i = indexPath.row + 1; i < [totalArr count] ; i++)
            {
                NSDictionary *tempDict = [totalArr objectAtIndex:i];
                
                if ([[tempDict objectForKey:@"field_name"] isEqualToString:@"header"])
                    break;
                else
                    [tblInfo deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO];
            }
        }
        else if ([[dict objectForKey:@"type"] isEqualToString:@"Work"]) // Select Work
        {
            for (int i = indexPath.row; i < [totalArr count] ; i++)
                [tblInfo deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO];
        }
    }
    else    // check the cells and deSelect header
    {
        if ([[dict objectForKey:@"type"] isEqualToString:@"Home"])
            [tblInfo deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO];
        else
        {
            for (int i = indexPath.row; i >= 0; i--)
            {
                NSDictionary *tempDict = [totalArr objectAtIndex:i];
                
                if ([[tempDict objectForKey:@"field_name"] isEqualToString:@"header"])
                {
                    [tblInfo deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO];
                    break;
                }
            }
        }
    }
    
    NSArray *selectedRows = [tableView indexPathsForSelectedRows];
    
    if ([selectedRows count] == 0)
    {
        btnDone.hidden = NO;
        btnDoneFake.hidden = YES;        
        btnChatOnly.selected = YES;
    }
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        if (curCBEmail) {
            void (^successed)(id responseObject) = ^(id responseObject) {
                NSDictionary *result = responseObject;
                
                NSLog(@"delete result = %@", result);
                
                if ([[result objectForKey:@"success"] boolValue]) {
                    
                    [SVProgressHUD showSuccessWithStatus:@"Account Deleted"];
                    [self.navigationController popViewControllerAnimated:YES];
                    
                } else {
                    NSDictionary *dictError = [result objectForKey:@"err"];
                    if (dictError) {
                        [SVProgressHUD showErrorWithStatus:[dictError objectForKey:@"errMsg"]];
                    } else {
                        [SVProgressHUD showErrorWithStatus:@"Failed to connect to server!"];
                    }
                }
            };
            
            void (^failure)(NSError* error) = ^(NSError* error) {
                [SVProgressHUD showErrorWithStatus:@"Failed to connect to server!"];
            };
            
            [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeClear];
            
            [[ContactBuilderClient sharedClient] deleteCBEmail:[AppDelegate sharedDelegate].sessionId cbID:curCBEmail.cbID successed:successed failure:failure];
        }
    }
}

#pragma mark - Actions
- (IBAction)onOff:(id)sender
{
    [self.view findAndResignFirstResponder];
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == 100) {
        if (isOn) {
            return;
        }
    } else {
        if (!isOn) {
            return;
        }
    }
    
    isOn = !isOn;
    btnDone.hidden = NO;
    btnDoneFake.hidden = NO;
    [self layoutOnOffViews];
}

- (IBAction)onChatOnly:(id)sender
{
    btnDone.hidden = NO;
    btnDoneFake.hidden = NO;
    [self.view findAndResignFirstResponder];
    btnChatOnly.selected = !btnChatOnly.selected;
    btnCheck.selected = NO;
    if (!btnChatOnly.selected)
    {
        btnDone.hidden = YES;
        return;
    }
    for (int i = 0 ; i < 8 ; i++)
    {
        [tblInfo deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO];
    }
}

- (IBAction)onCheck:(id)sender
{
    btnDone.hidden = NO;
    btnDoneFake.hidden = NO;
    btnChatOnly.selected = NO;
    
    if (btnCheck.selected)
    {
        btnCheck.selected = NO;
        
        for (int i = 0 ; i < [totalArr count] ; i++)
            [tblInfo deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO];
    }
    else
    {
        btnCheck.selected = YES;
        
        for (int i = 0 ; i < [totalArr count] ; i++)
            [tblInfo selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
}

- (IBAction)onDone:(id)sender
{
    if (isOn && ![self GetInfo]) {
        [CommonMethods showAlertUsingTitle:@"" andMessage:@"Oops!  Please select contact info to share."];
        return;
    }
    
    [self.view findAndResignFirstResponder];
    
    if (!oauth_token) {
        [self modifyCBEmail:nil];
    } else {
        [self addCBEmail];
    }
}

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onDelete:(id)sender
{
    [self.view findAndResignFirstResponder];
    UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"Do you want to delete this Builder account?" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
    [deleteAlert show];
}

- (IBAction)onRevalidate:(id)sender
{
//    if (curCBEmail.valid) {
//        return;
//    }
    if (!curCBEmail.cbID) {
        return;
    }
    if ([curCBEmail.authType isEqualToString:@"password"]) {
        CBImportOtherViewController *vc = [[CBImportOtherViewController alloc] initWithNibName:@"CBImportOtherViewController" bundle:nil];
        vc.curCBEmail = curCBEmail;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [self getCBOAuthURL];
    }
}

- (IBAction)onSkip:(id)sender
{
    [[AppDelegate sharedDelegate] setWizardPage:@"2"];
}

- (IBAction)onNext:(id)sender
{
    [self onDone:nil];
}

#pragma mark - WebAPI Integration - Revalidate
- (void)getCBOAuthURL
{
    void (^successed)(id responseObject) = ^(id responseObject) {
        NSDictionary *result = responseObject;
        
        NSLog(@"oauth url result = %@", result);
        
        if ([[result objectForKey:@"success"] boolValue]) {
            
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:@"Successed"];
            
            NSString *oAuthURL = [(NSDictionary *)[result objectForKey:@"data"] objectForKey:@"requestUrl"];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:oAuthURL]];
            
        } else {
            NSDictionary *dictError = [result objectForKey:@"err"];
            if (dictError) {
                [SVProgressHUD showErrorWithStatus:[dictError objectForKey:@"errMsg"]];
            } else {
                [SVProgressHUD showErrorWithStatus:@"Failed to connect to server!"];
            }
        }
    };
    
    void (^failure)(NSError* error) = ^(NSError* error) {
        [SVProgressHUD showErrorWithStatus:@"Failed to connect to server!"];
    };
    
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeClear];
    [[ContactImporterClient sharedClient] getCBOAuthURL:[AppDelegate sharedDelegate].sessionId email:curCBEmail.email provider:curCBEmail.provider successed:successed failure:failure];
}

@end
