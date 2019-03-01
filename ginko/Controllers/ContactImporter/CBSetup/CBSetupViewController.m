//
//  CBSetupViewController.m
//  ContactImporter
//
//  Created by mobidev on 6/12/14.
//  Copyright (c) 2014 Ron. All rights reserved.
//

#import "CBSetupViewController.h"
#import "ContactBuilderClient.h"
#import "ProfileCell.h"
#import "ContactViewController.h"

@interface CBSetupViewController ()
{
    BOOL isOn;
    NSDictionary *myInfo;
    NSMutableDictionary *profileDict;
    NSMutableDictionary *homeDict;
    NSMutableDictionary *workDict;
    NSString * _sharingInfo;
    NSString * _sharedHomeFields;
    NSString * _sharedWorkFields;
    UITapGestureRecognizer *tapRecognizer;
    int share_status;
}
@end

@implementation CBSetupViewController
@synthesize validType;
@synthesize strEmail, strPass;
@synthesize tblInfo, navView, viewTap, btnNext, btnSkip;
@synthesize viewOff, viewOn, btnOff, btnOn, txtEmail, txtPass, btnChatOnly, btnCheck;
@synthesize lblBottomLine, lblMiddleLine, lblTopLine, imgAm;

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
    share_status = 4;
    
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
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    tapRecognizer.delegate = self;
    [viewTap addGestureRecognizer:tapRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    CBSetupSimulateController *vc = [[CBSetupSimulateController alloc] initWithNibName:@"CBSetupSimulateController" bundle:nil];
//    [vc setParentController:self];
//    [self presentViewController:vc animated:YES completion:nil];
    
    [self configureUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [navView removeFromSuperview];
}

#pragma mark - configure UI
- (void)configureUI
{
//    parentController.validType = segControl.selectedSegmentIndex ? 2 : 0;
//    parentController.strEmail = txtEmail.text;
//    parentController.strPass = txtPass.text;
    validType = _globalData.scbValidType;
//    strEmail = @"testcftfone@gmail.com";
//    strPass = @"Test@123!@#";
    strEmail = _globalData.scbEmail;
    strPass = _globalData.scbPassword;
    
    // Zhun's
    totalArr = [[NSMutableArray alloc] init];
    lstField = [[NSMutableArray alloc] initWithObjects:@"Mobile",@"Mobile#2",@"Phone",@"Phone#2",@"Phone#3",@"Fax",@"Email",@"Email#2",@"Address",@"Address#2",@"Birthday",@"Facebook",@"Twitter",@"Website",@"Custom",@"Custom#2",@"Custom#3", nil];
    
    [self.navigationController.navigationBar addSubview:navView];
    [self getInfo];
    
    [self layoutSubViews];
    [self layoutOnOffViews];
}

- (void)layoutSubViews
{
    txtEmail.text = strEmail;
    txtPass.text = strPass;
    if (validType == 0) {
        txtPass.hidden = YES;
        txtEmail.borderStyle = UITextBorderStyleNone;
        txtEmail.enabled = NO;
        CGRect frame = txtEmail.frame;
        frame.origin.y+=18;
        txtEmail.frame = frame;
        
        imgAm.hidden = YES;
        
//        btnSkip.hidden = YES;
        CGRect frmButton = btnNext.frame;
        frmButton.origin.x = 138;
        btnNext.frame = frmButton;
    }
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
    [btnOn setImage:isOn ? [UIImage imageNamed:@"btn_on"] : [UIImage imageNamed:@"btn_off"] forState:UIControlStateNormal];
    [btnOff setImage:isOn ? [UIImage imageNamed:@"btn_off"] : [UIImage imageNamed:@"btn_on"] forState:UIControlStateNormal];
    if (isOn) {
        viewOn.hidden = NO;
        viewOff.hidden = YES;
    } else {
        viewOff.hidden = NO;
        viewOn.hidden = YES;
    }
}

#pragma mark - custom methods
- (BOOL)getShareInfoFromTable
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
        _sharingInfo = @"3";
    else if (homeCount > 0)
        _sharingInfo = @"1";
    else if (workCount > 0)
        _sharingInfo = @"2";
    
    return YES;
}

#pragma mark - webAPI integration
- (void)addCBEmail
{
    void (^successed)(id responseObject) = ^(id responseObject) {
        NSDictionary *result = responseObject;
        
        NSLog(@"add result = %@", result);
        
        if ([[result objectForKey:@"success"] boolValue]) {
            
            [SVProgressHUD dismiss];
//            NSArray *arrControllers = self.navigationController.viewControllers;
//            ContactViewController *vc = [arrControllers objectAtIndex:1];
//            [self.navigationController popToViewController:vc animated:YES];
//            [[AppDelegate sharedDelegate] GetContactList];
            [[AppDelegate sharedDelegate] setWizardPage:@"2"];
            
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
    [[ContactBuilderClient sharedClient] addOrUpdateCBEmail:[AppDelegate sharedDelegate].sessionId cbID:nil email:txtEmail.text password:txtPass.text sharing:share_status sharedHomeFieldIds:_sharedHomeFields sharedWorkFieldIds:_sharedWorkFields active:NO authType:nil provider:nil oauthToken:nil username:nil inserver:nil inserverType:nil inserverPort:nil successed:successed failure:failure];
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
                
                for (int i = 0; i < [keyArr count]; i++)
                {
                    NSMutableDictionary * tempDict = [[NSMutableDictionary alloc] init];
                    
                    [tempDict setObject:@"Home" forKey:@"type"];
                    [tempDict setObject:[keyArr objectAtIndex:i] forKey:@"field_name"];
                    [tempDict setObject:[homeDict objectForKey:[keyArr objectAtIndex:i]] forKey:@"field_value"];
                    [tempDict setObject:[homeIdDict objectForKey:[keyArr objectAtIndex:i]] forKey:@"field_id"];
                    
                    [totalArr addObject:tempDict];
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
                
                for (int i = 0; i < [keyArr count]; i++)
                {
                    NSMutableDictionary * tempDict = [[NSMutableDictionary alloc] init];
                    
                    [tempDict setObject:@"Work" forKey:@"type"];
                    [tempDict setObject:[keyArr objectAtIndex:i] forKey:@"field_name"];
                    [tempDict setObject:[workDict objectForKey:[keyArr objectAtIndex:i]] forKey:@"field_value"];
                    [tempDict setObject:[workIdDict objectForKey:[keyArr objectAtIndex:i]] forKey:@"field_id"];
                    
                    [totalArr addObject:tempDict];
                }
                
            }
            
            [SVProgressHUD dismiss];
            [tblInfo reloadData];
            
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

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == txtEmail) {
        [txtPass becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - UITableView Datasource, Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProfileCell * cell;
    cell = (ProfileCell *)[[[NSBundle mainBundle] loadNibNamed:@"ProfileCell" owner:nil options:nil] objectAtIndex:0];
 
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
    btnChatOnly.selected = NO;
    
    NSDictionary *dict = [totalArr objectAtIndex:indexPath.row];
    
    // Select Header
    if ([[dict objectForKey:@"field_name"] isEqualToString:@"header"])
    {
        if ([[dict objectForKey:@"type"] isEqualToString:@"Home"]) // Select Home
        {
            [tblInfo selectRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            
            for (long i = indexPath.row + 1; i < [totalArr count] ; i++)
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
            for (long i = indexPath.row; i < [totalArr count] ; i++)
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
}

#pragma mark - resign textfield
- (void)tapView:(UITapGestureRecognizer *)gestureRecognizer
{
    UIView *hitView = [gestureRecognizer.view hitTest:[gestureRecognizer locationInView:gestureRecognizer.view] withEvent:nil];
    if (hitView == viewTap) {
        [self.view findAndResignFirstResponder];
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
    [self layoutOnOffViews];
}

- (IBAction)onChatOnly:(id)sender
{
    share_status = 4;
    [self.view findAndResignFirstResponder];
    btnChatOnly.selected = !btnChatOnly.selected;
    btnCheck.selected = NO;
    if (!btnChatOnly.selected)
    {
        return;
    }
    for (int i = 0 ; i < 8 ; i++)
    {
        [tblInfo deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO];
    }
}

- (IBAction)onCheck:(id)sender
{
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

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onNext:(id)sender
{
    if (validType != 0) {
        if (![CommonMethods checkBlankField:[NSArray arrayWithObjects:txtEmail, txtPass, nil] titles:[NSArray arrayWithObjects:@"Email field", @"Password field", nil]]) {
            return;
        }
    }
    
    if (![CommonMethods checkEmail:txtEmail]) {
        return;
    }
    
    if (isOn && ![self getShareInfoFromTable]) {
        [CommonMethods showAlertUsingTitle:@"" andMessage:@"Oops!  Please select contact info to share."];
        return;
    }
    
    [self.view findAndResignFirstResponder];
    
    [self addCBEmail];
}

- (IBAction)onSkip:(id)sender
{
//    NSArray *arrControllers = self.navigationController.viewControllers;
//    ContactViewController *vc = [arrControllers objectAtIndex:1];
//    [self.navigationController popToViewController:vc animated:YES];
//    [[AppDelegate sharedDelegate] GetContactList];
    [[AppDelegate sharedDelegate] setWizardPage:@"2"];
}

@end
