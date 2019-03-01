//
//  CISyncContactsViewController.m
//  ContactImporter
//
//  Created by mobidev on 6/13/14.
//  Copyright (c) 2014 Ron. All rights reserved.
//

#import "CISyncContactsViewController.h"
#import "CIHomeViewController.h"
#import "CISyncDetailController.h"
#import "ContactImporterClient.h"

#import "ContactViewController.h"
#import "AppDelegate.h"

#import "UIImage+Tint.h"

#import "GreyDetailController.h"

@interface CISyncContactsViewController ()<UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    int contact_type;
    NSMutableArray *searchList;
    UITapGestureRecognizer * gesture;
    BOOL searchStartFlag;
    
    BOOL isChanged;
    
    NSMutableArray *arrSelectedContacts;
}
@end

@implementation CISyncContactsViewController
@synthesize navView;
@synthesize tblSyncContacts;
@synthesize btnEntity, btnHome, btnWork;
@synthesize contactSearch, viewTap;
@synthesize btnClose, btnRemove, btnSkip, btnNext, btnImport, btnEdit;
@synthesize lblTitle, isHistory;
@synthesize btnBack, btnDone;

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
    
    [btnRemove setImage:[[UIImage imageNamed:@"TrashIcon"] tintImageWithColor:[UIColor blackColor]] forState:UIControlStateNormal];
    
//    [contactSearch setSearchFieldBackgroundImage:[CommonMethods imageWithColor:[UIColor blueColor] andSize:contactSearch.frame.size] forState:UIControlStateNormal];
    
    contact_type = -1;
    
    isChanged = YES;
    
    [self colorTypeButtons];
    searchList = [[NSMutableArray alloc] init];
    
    arrSelectedContacts = [[NSMutableArray alloc] init];
    
    gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(TapView)];
    
    if (isHistory) {
        lblTitle.text = @"Backup Contacts";
    }
    
//    if (_globalData.isFromMenu) {
        [self layoutMainLink];
//    }
    [self showHideDoneButton];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    // tapGestureRecognizer.cancelsTouchesInView = NO;
    tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar addSubview:navView];
    
    contactSearch.text = @"";
    searchList = [_globalData.arrSyncContacts mutableCopy];
    [tblSyncContacts reloadData];
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

- (void)layoutMainLink
{
    btnBack.hidden = NO;
    btnSkip.hidden = YES;
    btnNext.hidden = YES;
    btnImport.hidden = YES;
}

#pragma mark - Custom Methods
- (void)colorTypeButtons
{
    [btnEntity setSelected:NO];
    [btnWork setSelected:NO];
    [btnHome setSelected:NO];
    
    switch (contact_type) {
        case 0:
            [btnEntity setSelected:YES];
            break;
        case 2:
            [btnWork setSelected:YES];
            break;
        case 1:
            [btnHome setSelected:YES];
            break;
        default:
            break;
    }
}

- (void)TapView
{
    if (searchStartFlag)
    {
        [contactSearch resignFirstResponder];
        searchStartFlag = NO;
        [viewTap removeGestureRecognizer:gesture];
    }
}

- (void)showEditPane:(BOOL)flag
{
    [tblSyncContacts setEditing:flag animated:YES];

    btnBack.hidden = flag;
    
    btnClose.hidden = !flag;
    //btnRemove.hidden = !flag;
    
//    if (!_globalData.isFromMenu) {
//        btnSkip.hidden = flag;
//        btnNext.hidden = flag;
//    }
//    btnImport.hidden = flag;
    btnEdit.hidden = flag;
    
    [self showHideDoneButton];
}

- (BOOL)isAllType:(int)type
{
    for (NSDictionary *dict in _globalData.arrSyncContacts) {
        if ([[dict objectForKey:@"type"] intValue] != type) {
            return NO;
        }
    }
    return YES;
}

- (void)showHideDoneButton
{
//    if (_globalData.isFromMenu) {
        if ([self isAllType:-1] || tblSyncContacts.editing) {
            btnDone.hidden = YES;
            _btnRealDone.hidden = YES;
        } else {
            btnDone.hidden = NO;
            _btnRealDone.hidden = NO;
        }
//    }
}

- (BOOL)isBlankContact:(NSDictionary*)dic {
    NSString *name = [NSString stringWithFormat:@"%@%@%@", dic[@"first_name"], dic[@"middle_name"], dic[@"last_name"]];
    name = [name stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    return (!name.length);
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [contactSearch resignFirstResponder];
}
#pragma mark - WebAPI integration
- (void)importContacts:(NSArray *)arrData import:(NSMutableArray *)arrImport
{
    void (^successed)(id responseObject) = ^(id responseObject) {
        NSDictionary *result = responseObject;
        if ([[result objectForKey:@"success"] boolValue]) {
            
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:@"Successed"];
            
            for (NSDictionary *dict in arrImport) {
                [_globalData.arrSyncContacts removeObject:dict];
            }
//            if (_globalData.isFromMenu) {
                //ml class
                NSArray *arrControllers = self.navigationController.viewControllers;
                ContactViewController *vc = [arrControllers objectAtIndex:1];
                [self.navigationController popToViewController:vc animated:YES];
//            } else {
//                [[AppDelegate sharedDelegate] setWizardPage:@"2"];
//            }
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

    [SVProgressHUD showWithStatus:@"Importing..." maskType:SVProgressHUDMaskTypeClear];
    [[ContactImporterClient sharedClient] addUpdateSyncContact:[AppDelegate sharedDelegate].sessionId fields:arrData successed:successed failure:failure];
}

- (void)removeContact:(NSString *)syncContactIDs remove:(NSMutableArray *)arrRemove
{
    void (^successed)(id responseObject) = ^(id responseObject) {
        NSDictionary *result = responseObject;
        
        NSLog(@"remove contact result = %@", result);
        
        if ([[result objectForKey:@"success"] boolValue]) {
            
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:@"Removed"];
            for (NSDictionary *dict in arrRemove) {
                [_globalData.arrSyncContacts removeObject:dict];
            }
            searchList = [_globalData.arrSyncContacts mutableCopy];
            contactSearch.text = @"";
            [self showEditPane:NO];
            btnRemove.hidden = YES;
            [tblSyncContacts reloadData];
            
            if ([self isAllType:0]) {
                contact_type = 0;
            } else if ([self isAllType:1]) {
                contact_type = 1;
            } else if ([self isAllType:2]) {
                contact_type = 2;
            } else {
                contact_type = -1;
            }
            [self colorTypeButtons];
            [self showHideDoneButton];
            
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
    
    [SVProgressHUD showWithStatus:@"Removing..." maskType:SVProgressHUDMaskTypeClear];
    [[ContactImporterClient sharedClient] removeSyncContact:[AppDelegate sharedDelegate].sessionId syncContacts:syncContactIDs successed:successed failure:failure];
}

#pragma mark - UISearchBar Delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    [viewTap addGestureRecognizer:gesture];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:NO animated:YES];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
//    searchFlag = YES;
    if ([searchText isEqualToString:@""])
    {
        [searchList removeAllObjects];
        searchList = [_globalData.arrSyncContacts mutableCopy];
//        searchFlag = NO;
        [tblSyncContacts reloadData];
    }
    else
    {
        [searchList removeAllObjects];
        for (int i = 0 ; i < [_globalData.arrSyncContacts count] ; i++)
        {
            NSDictionary * dict = [_globalData.arrSyncContacts objectAtIndex:i];
            NSString * firstName = [dict objectForKey:@"first_name"];
            NSString * lastName = [dict objectForKey:@"last_name"];
            NSString * middleName = [dict objectForKey:@"middle_name"];
            NSRange range = [[[NSString stringWithFormat:@"%@ %@%@", firstName, middleName, lastName] uppercaseString] rangeOfString:[searchText uppercaseString]];
            if (range.location != NSNotFound)
                [searchList addObject:dict];
        }
        if ([searchList count] == 0) {
            btnEdit.enabled = NO;
        }else{
            btnEdit.enabled = YES;
        }
        [tblSyncContacts reloadData];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    searchStartFlag = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    searchList = [_globalData.arrSyncContacts mutableCopy];
//    searchFlag = NO;
    [tblSyncContacts reloadData];
}

#pragma mark - UITableView DataSource, Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [searchList count];
}

- (CGFloat)tableView:( UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CISyncCell *cell = [tblSyncContacts dequeueReusableCellWithIdentifier:@"CISyncCell"];
    NSDictionary * dict = [searchList objectAtIndex:indexPath.row];
    if(cell == nil)
    {
        cell = [CISyncCell sharedCell];
    }
    
    [cell setDelegate:self];
    cell.curIndex = (int)indexPath.row;
    cell.curDict = [searchList objectAtIndex:indexPath.row];
    [cell.contentView setBackgroundColor:[UIColor clearColor]];
    cell.maskViewForSel.hidden = YES;
    if (tblSyncContacts.editing) {
        cell.maskViewForSel.hidden = NO;
        if ([arrSelectedContacts containsObject:[dict objectForKey:@"contact_id"]]) {
            [tableView selectRowAtIndexPath:indexPath
                                   animated:NO
                             scrollPosition:UITableViewScrollPositionNone];
        }
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!tblSyncContacts.editing) {
//        if (!_globalData.isFromMenu) {
//            return NO;
//        }
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dict = [searchList objectAtIndex:indexPath.row];
    if (tblSyncContacts.editing) {
        [arrSelectedContacts addObject:[dict objectForKey:@"contact_id"]];
        if ([arrSelectedContacts count] > 0) {
            btnRemove.hidden = NO;
        }else{
            btnRemove.hidden = YES;
        }
        return;
    }
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dict = [searchList objectAtIndex:indexPath.row];
    if (tblSyncContacts.editing) {
        [arrSelectedContacts removeObject:[dict objectForKey:@"contact_id"]];
        if ([arrSelectedContacts count] > 0) {
            btnRemove.hidden = NO;
        }else{
            btnRemove.hidden = YES;
        }
        return;
    }
}
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dict = [searchList objectAtIndex:indexPath.row];
    if (tblSyncContacts.editing) {
        [arrSelectedContacts removeObject:[dict objectForKey:@"contact_id"]];
        return;
    }
}

#pragma mark - SyncCellDelegate
- (void)didType:(NSMutableDictionary *)dict tag:(int)tag
{
    [self.view findAndResignFirstResponder];
    
    if ([[dict objectForKey:@"type"] intValue] == tag - 100) {
        [dict setObject:@"-1" forKey:@"type"];
        searchList = [_globalData.arrSyncContacts mutableCopy];
        contactSearch.text = @"";
//        [tblSyncContacts reloadData];
    } else {
        [dict setObject:[NSString stringWithFormat:@"%d", tag - 100] forKey:@"type"];
        searchList = [_globalData.arrSyncContacts mutableCopy];
        contactSearch.text = @"";
//        [tblSyncContacts reloadData];
    }
    if ([self isAllType:tag - 100]) {
        contact_type = tag - 100;
    } else {
        contact_type = -1;
    }
    [self colorTypeButtons];
    [self showHideDoneButton];
}

- (void)didName:(NSMutableDictionary *)dict
{
    
    [self.view findAndResignFirstResponder];
//    
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    
//    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
//    {
//        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//        
//        NSDictionary *result = _responseObject;
//        if ([[result objectForKey:@"success"] boolValue]) {
//            NSDictionary *dic = [_responseObject objectForKey:@"data"];
            GreyDetailController *vc = [[GreyDetailController alloc] initWithNibName:@"GreyDetailController" bundle:nil];
            vc.curContactDict = dict;
            vc.isContactFromBackup = YES;
            [self.navigationController pushViewController:vc animated:YES];
//        } else {
//            NSDictionary *dictError = [result objectForKey:@"err"];
//            if (dictError) {
//                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:[dictError objectForKey:@"errMsg"]];
//                if ([[NSString stringWithFormat:@"%@",[dictError objectForKey:@"errCode"]] isEqualToString:@"350"]) {
//                    [[AppDelegate sharedDelegate] GetContactList];
//                }            } else {
//                    [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Failed to connect to server!"];
//                }
//        }
//        
//    } ;
//    
//    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
//    {
//        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Failed to connect to server!"];
//    } ;
//    
//    [[Communication sharedManager] getContactDetail:[AppDelegate sharedDelegate].sessionId contactId:[dict objectForKey:@"contact_id"] contactType:[dict objectForKey:@"contact_type"] successed:successed failure:failure];
    
    
//    CISyncDetailController *vc = [[CISyncDetailController alloc] initWithNibName:@"CISyncDetailController" bundle:nil];
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    appDelegate.importDict = dict;
////    [vc setCurContactDict:dict];
//    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    isChanged = NO;
    if (buttonIndex == 0) {
        if (alertView.tag == 1) {
            for (NSMutableDictionary *dict in _globalData.arrSyncContacts) {
                [dict setObject:[NSString stringWithFormat:@"%d", contact_type] forKey:@"type"];
            }
            [self colorTypeButtons];
            searchList = [_globalData.arrSyncContacts mutableCopy];
            contactSearch.text = @"";
            [tblSyncContacts reloadData];
            [self showHideDoneButton];
            isChanged = YES;
        } else if (alertView.tag == 2) {
            NSArray * selectedRows = [tblSyncContacts indexPathsForSelectedRows];
            NSString *syncContactIDs = @"";
            NSMutableArray *arrRemoveContacts = [[NSMutableArray alloc] init];
            for (int i=0; i<[selectedRows count]; i++) {
                NSIndexPath * selectRow = [selectedRows objectAtIndex:i];
                NSMutableDictionary *dict = [searchList objectAtIndex:selectRow.row];
                [arrRemoveContacts addObject:dict];
                syncContactIDs = [NSString stringWithFormat:@"%@,%@", syncContactIDs, [dict objectForKey:@"contact_id"]];
            }
            if ([selectedRows count] == 1) {
                NSString *lastString = [syncContactIDs substringFromIndex:syncContactIDs.length - 1];
                if ([lastString isEqualToString:@","]) {
                    syncContactIDs = [syncContactIDs substringToIndex:syncContactIDs.length - 1];
                }
            }
            [self removeContact:syncContactIDs remove:arrRemoveContacts];
            
            /*
            NSMutableArray *arrRemoveContacts = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in searchList) {
                syncContactIDs = [NSString stringWithFormat:@"%@,%@", syncContactIDs, [dict objectForKey:@"contact_id"]];
            }

            NSString *lastString = [syncContactIDs substringFromIndex:syncContactIDs.length - 1];
            if ([lastString isEqualToString:@","]) {
                syncContactIDs = [syncContactIDs substringToIndex:syncContactIDs.length - 1];
            }
            [self removeContact:syncContactIDs remove:arrRemoveContacts];*/
        }
    }
}

#pragma mark - Actions
- (IBAction)onType:(id)sender
{
    [self.view findAndResignFirstResponder];
    if (![searchList count]) {
        return;
    }
    UIButton *btn = (UIButton *)sender;
    if (btn.tag - 100 == contact_type && isChanged) {
        contact_type = -1;
        for (NSMutableDictionary *dict in _globalData.arrSyncContacts) {
            [dict setObject:[NSString stringWithFormat:@"%d", contact_type] forKey:@"type"];
        }
        [self colorTypeButtons];
        searchList = [_globalData.arrSyncContacts mutableCopy];
        contactSearch.text = @"";
        [tblSyncContacts reloadData];
        [self showHideDoneButton];
        return;
    }
    NSString *strType = @"";
    switch (btn.tag) {
        case 100:
            strType = @"entity";
            break;
        case 101:
            strType = @"Personal";
            break;
        case 102:
            strType = @"work";
            break;
        default:
            break;
    }
    contact_type = (int)btn.tag - 100;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GINKO" message:[NSString stringWithFormat:@"Do you want to set type '%@' for all contacts?", strType] delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
    alert.tag = 1;
    [alert show];
}

- (IBAction)onEdit:(id)sender
{
    [self showEditPane:YES];
    [tblSyncContacts reloadData];
}

- (IBAction)onSkip:(id)sender
{
//    [[AppDelegate sharedDelegate] setWizardPage:@"2"];
}

- (IBAction)onNext:(id)sender
{
    NSMutableArray *arrParam = [[NSMutableArray alloc] init];
    NSMutableArray *arrImportContacts = [[NSMutableArray alloc] init];
    BOOL blankContained = NO;
    for (NSMutableDictionary *dict in searchList) {
        if ([[dict objectForKey:@"type"] intValue] != -1) {
            if ([self isBlankContact:dict]) {
                blankContained = YES;
                [dict setObject:@(-1) forKey:@"type"];
                continue;
            }
            NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
            [paramDict setObject:[dict objectForKey:@"contact_id"] forKey:@"sync_contact_id"];
            [paramDict setObject:[dict objectForKey:@"type"] forKey:@"type"];
            [arrParam addObject:paramDict];
            [arrImportContacts addObject:dict];
        }
    }
    if (blankContained) {
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:MESSAGE_BLANK_CONTACT];
        if (![arrParam count]) {
            [tblSyncContacts reloadData];
            return;
        }
    }
    [self importContacts:arrParam import:arrImportContacts];
}

- (IBAction)onImport:(id)sender
{
//    if (_globalData.isFromMenu) {
        NSArray *arrControllers = self.navigationController.viewControllers;
        for (UIViewController *vc in arrControllers) {
            if ([vc isKindOfClass:[CIHomeViewController class]]) {
                [self.navigationController popToViewController:vc animated:YES];
            }
        }
        
//    } else {
//        [self.navigationController popToRootViewControllerAnimated:YES];
//    }
}

- (IBAction)onClose:(id)sender
{
    [self showEditPane:NO];
    [arrSelectedContacts removeAllObjects];
    btnRemove.hidden = YES;
    
    [tblSyncContacts reloadData];
}

- (IBAction)onRemove:(id)sender
{
    NSArray * selectedRows = [tblSyncContacts indexPathsForSelectedRows];
    if (![selectedRows count]) {
        [CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Oops!  You must select an item(s) to remove!"];
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GINKO" message:@"Do you want to remove selected contacts?" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
    alert.tag = 2;
    [alert show];
}

- (IBAction)onBack:(id)sender
{
    [self onImport:nil];
}

- (IBAction)onDone:(id)sender
{
    [self onNext:nil];
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isKindOfClass:[UIScrollView class]]) {
        return YES;
    }
    if ([searchList count] > 0) {
        return NO;
    }
    return YES;
}
- (void) hideKeyboard{
    [contactSearch resignFirstResponder];
}
@end
