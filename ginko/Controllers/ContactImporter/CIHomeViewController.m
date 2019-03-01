//
//  CIHomeViewController.m
//  ContactImporter
//
//  Created by mobidev on 6/12/14.
//  Copyright (c) 2014 Ron. All rights reserved.
//

#import "CIHomeViewController.h"
#import "CIImportViewController.h"
#import <AddressBook/AddressBook.h>
#import "CISyncContactsViewController.h"
#import "ContactImporterClient.h"

@interface CIHomeViewController ()

@end

@implementation CIHomeViewController
@synthesize navView;
@synthesize btnBack, btnFormer, btnSkip, btnImportHistory;

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
    
//    if (_globalData.isFromMenu) {
        [self layoutMainLink];
//    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar addSubview:navView];
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
    btnFormer.hidden = YES;
    btnImportHistory.hidden = NO;
}

#pragma mark - get contacts from addressbook
-(void)getContactFromAddressBook
{
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(nil, nil);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                // If the app is authorized to access the first time then add the contact
                [self getAdressContactDetails];
            } else {
                // Show an alert here if user denies access telling that the contact cannot be added because you didn't allow it to access the contacts
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"GINKO" message:@"Oops!  You did not permit the GINKO to access your contacts. Please give GINKO access from your phone settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // If the user user has earlier provided the access, then add the contact
        [self getAdressContactDetails];
    }
    else {
        // If the user user has NOT earlier provided the access, create an alert to tell the user to go to Settings app and allow access
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"GINKO" message:@"Oops!  You did not permit the GINKO to access your contacts. Please give GINKO access from your phone settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)getAdressContactDetails
{
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    NSMutableArray *arrContacts = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < nPeople; i++) {
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);
        
        CFTypeRef copyval;
        NSString *strTemp;
        NSArray *arrTemp;
        NSMutableDictionary *dictContact = [[NSMutableDictionary alloc] init];
        
        copyval = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        strTemp = [NSString stringWithFormat:@"%@", copyval];
        if (copyval) {
            [dictContact setObject:strTemp forKey:@"first_name"];
        }
        
        copyval = ABRecordCopyValue(ref, kABPersonLastNameProperty);
        strTemp = [NSString stringWithFormat:@"%@", copyval];
        //        if (![strTemp isEqualToString:@"(null)"]) {
        if (copyval && ![strTemp isEqualToString:@"(null)"]) {
            [dictContact setObject:strTemp forKey:@"last_name"];
        }
        
        copyval = ABRecordCopyValue(ref, kABPersonMiddleNameProperty);
        strTemp = [NSString stringWithFormat:@"%@", copyval];
        //        if (![strTemp isEqualToString:@"(null)"]) {
        if (copyval && ![strTemp isEqualToString:@"(null)"]) {
            [dictContact setObject:strTemp forKey:@"middle_name"];
        }
        
        copyval = ABRecordCopyValue(ref, kABPersonEmailProperty);
        arrTemp = (__bridge NSArray*) ABMultiValueCopyArrayOfAllValues(copyval);
        if (arrTemp.count >0)
        {
            strTemp = [arrTemp objectAtIndex:0];
        }
        //        if (![strTemp isEqualToString:@"(null)"]) {
        if (copyval && ![strTemp isEqualToString:@"(null)"] && arrTemp.count) {
            [dictContact setObject:strTemp forKey:@"email"];
        }
        
        copyval = ABRecordCopyValue(ref, kABPersonNoteProperty);
        strTemp = [NSString stringWithFormat:@"%@", copyval];
        //        if (![strTemp isEqualToString:@"(null)"]) {
        if (copyval && ![strTemp isEqualToString:@"(null)"]) {
            [dictContact setObject:strTemp forKey:@"notes"];
        }
        
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        
        copyval = ABRecordCopyValue(ref, kABPersonPhoneProperty);
        arrTemp = (__bridge NSArray*) ABMultiValueCopyArrayOfAllValues(copyval);
        if (arrTemp.count >0)
        {
            strTemp = [arrTemp objectAtIndex:0];
        }
        //        if (![strTemp isEqualToString:@"(null)"]) {
        if (copyval && ![strTemp isEqualToString:@"(null)"] && arrTemp.count) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:@"Phone" forKey:@"field_name"];
            [dict setObject:strTemp forKey:@"field_value"];
            [dict setObject:@"phone" forKey:@"field_type"];
            [fields addObject:dict];
        }
        
        copyval = ABRecordCopyValue(ref, kABPersonAddressProperty);
        arrTemp = (__bridge NSArray*) ABMultiValueCopyArrayOfAllValues(copyval);
        NSDictionary *dict = [NSDictionary dictionary];
        if (arrTemp.count >0)
        {
            dict = [arrTemp objectAtIndex:0];
        }
        NSString *strAddress = @"";
        if ([[dict allKeys] count]) {
            if ([dict objectForKey:@"Street"]) {
                if (![strAddress length]) {
                    strAddress = [NSString stringWithFormat:@"%@%@", strAddress, [dict objectForKey:@"Street"]];
                } else {
                    strAddress = [NSString stringWithFormat:@"%@ %@", strAddress, [dict objectForKey:@"Street"]];
                }
                
            }
            if ([dict objectForKey:@"City"]) {
                if (![strAddress length]) {
                    strAddress = [NSString stringWithFormat:@"%@%@", strAddress, [dict objectForKey:@"City"]];
                } else {
                    strAddress = [NSString stringWithFormat:@"%@ %@", strAddress, [dict objectForKey:@"City"]];
                }
            }
            if ([dict objectForKey:@"State"]) {
                if (![strAddress length]) {
                    strAddress = [NSString stringWithFormat:@"%@%@", strAddress, [dict objectForKey:@"State"]];
                } else {
                    strAddress = [NSString stringWithFormat:@"%@ %@", strAddress, [dict objectForKey:@"State"]];
                }
            }
            if ([dict objectForKey:@"Country"]) {
                if (![strAddress length]) {
                    strAddress = [NSString stringWithFormat:@"%@%@", strAddress, [dict objectForKey:@"Country"]];
                } else {
                    strAddress = [NSString stringWithFormat:@"%@ %@", strAddress, [dict objectForKey:@"Country"]];
                }
            }
        }
        //        if (copyval && ![strTemp isEqualToString:@"(null)"] && arrTemp.count) {
        if ([strAddress length]) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:@"Address" forKey:@"field_name"];
            [dict setObject:strAddress forKey:@"field_value"];
            [dict setObject:@"address" forKey:@"field_type"];
            [fields addObject:dict];
        }
        
        copyval = ABRecordCopyValue(ref, kABPersonBirthdayProperty);
        strTemp = [NSString stringWithFormat:@"%@", copyval];
        //        if (![strTemp isEqualToString:@"(null)"]) {
        if (copyval && ![strTemp isEqualToString:@"(null)"]) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:@"Birthday" forKey:@"field_name"];
            [dict setObject:strTemp forKey:@"field_value"];
            [dict setObject:@"date" forKey:@"field_type"];
            [fields addObject:dict];
        }
        
        copyval = ABRecordCopyValue(ref, kABPersonURLProperty);
        arrTemp = (__bridge NSArray*) ABMultiValueCopyArrayOfAllValues(copyval);
        if (arrTemp.count >0)
        {
            strTemp = [arrTemp objectAtIndex:0];
        }
        //        if (![strTemp isEqualToString:@"(null)"]) {
        if (copyval && ![strTemp isEqualToString:@"(null)"] && arrTemp.count) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:@"Website" forKey:@"field_name"];
            [dict setObject:strTemp forKey:@"field_value"];
            [dict setObject:@"url" forKey:@"field_type"];
            [fields addObject:dict];
        }
        
        if ([fields count]) {
            [dictContact setObject:fields forKey:@"fields"];
        }
        
        dictContact[@"foreign_id"] = @(ABRecordGetRecordID(ref));
        
        if ([[dictContact allKeys] count]) {
            [arrContacts addObject:dictContact];
        }
    }
    
    if (![arrContacts count]) {
        [CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Oops!  There are no contacts to import into your address book!"];
        return;
    }
    
    [self syncMultipleContacts:arrContacts];
}

- (void)addToGlobalArray:(NSMutableArray *)addContactArray history:(BOOL)isHistory
{
    if (isHistory) {
        [_globalData.arrSyncContacts removeAllObjects];
    }
    for (NSMutableDictionary *dict in addContactArray) {
        int k=0;
        for (NSMutableDictionary *g_dict in _globalData.arrSyncContacts) {
            if ([[dict objectForKey:@"contact_id"] intValue] == [[g_dict objectForKey:@"contact_id"] intValue]) {
                k++;
            }
        }
        if (k==0) {
            [_globalData.arrSyncContacts addObject:[NSMutableDictionary dictionaryWithDictionary:dict]];
        }
    }
}

#pragma mark - WEB API integration
- (void)syncMultipleContacts:(NSArray *)data
{
    void (^successed)(id responseObject) = ^(id responseObject) {
        NSDictionary *result = responseObject;
        
        NSLog(@"sync contact result = %@", result);
        
        if ([[result objectForKey:@"success"] boolValue]) {
            
            NSMutableArray *arrContacts = [[NSMutableArray alloc] init];
            NSArray *contactsArray = [result objectForKey:@"data"];
            //            NSArray *contactsArray = [[result objectForKey:@"data"] objectForKey:@"contacts"];
            for (NSDictionary *dict in contactsArray) {
                [arrContacts addObject:[[NSMutableDictionary alloc] initWithDictionary:dict]];
            }
            
            [self addToGlobalArray:arrContacts history:NO];
            
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:@"Successed"];
            
            CISyncContactsViewController *vc = [[CISyncContactsViewController alloc] initWithNibName:@"CISyncContactsViewController" bundle:nil];
            vc.isHistory = YES;
            [self.navigationController pushViewController:vc animated:YES];
            
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
    [[ContactImporterClient sharedClient] syncMultipleContacts:[AppDelegate sharedDelegate].sessionId data:data successed:successed failure:failure];
}

- (void)getSyncHistory
{
    void (^successed)(id responseObject) = ^(id responseObject) {
        NSDictionary *result = responseObject;
        
        //NSLog(@"sync history result = %@", result);
        
        if ([[result objectForKey:@"success"] boolValue]) {
            NSMutableArray *arrContacts = [[NSMutableArray alloc] init];
            //            NSArray *contactsArray = [result objectForKey:@"data"];
            NSArray *contactsArray = [[result objectForKey:@"data"] objectForKey:@"contacts"];
            for (NSDictionary *dict in contactsArray) {
                [arrContacts addObject:dict];
            }
            
            [self addToGlobalArray:arrContacts history:YES];
            
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:@"Successed"];
            
            CISyncContactsViewController *vc = [[CISyncContactsViewController alloc] initWithNibName:@"CISyncContactsViewController" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
            
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
    [[ContactImporterClient sharedClient] getSyncHistory:[AppDelegate sharedDelegate].sessionId successed:successed failure:failure];
}

#pragma mark - Actions
- (IBAction)onImportItem:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    CIImportViewController *vc = [[CIImportViewController alloc] initWithNibName:@"CIImportViewController" bundle:nil];
    [vc setType:(int)btn.tag];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onFormer:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSkip:(id)sender
{
//    [[AppDelegate sharedDelegate] setWizardPage:@"2"];
}

- (IBAction)onAddressBook:(id)sender
{
    [self getContactFromAddressBook];
}

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onImportHistory:(id)sender
{
    [self getSyncHistory];
//    CISyncContactsViewController *vc = [[CISyncContactsViewController alloc] initWithNibName:@"CISyncContactsViewController" bundle:nil];
//    [self.navigationController pushViewController:vc animated:YES];
}

@end
