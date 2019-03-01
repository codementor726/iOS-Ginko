//
//  GinkoConnectViewController.m
//  ginko
//
//  Created by STAR on 1/4/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "GinkoConnectViewController.h"
#import "ConnectGinkoUserCell.h"
#import "ConnectNonGinkoUserCell.h"
#import <AddressBook/AddressBook.h>
#import "YYYCommunication.h"
#import "ProfileRequestController.h"
#import "UIImageView+AFNetworking.h"
#import "LocalDBManager.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMessageComposeViewController.h>

@interface GinkoConnectViewController () <ConnectGinkoUserCellDelegate, ConnectNonGinkoUserCellDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate,UIScrollViewDelegate> {
    NSMutableArray *allContacts;
    NSMutableArray *ginkoContacts;
    NSMutableArray *nonGinkoContacts;
    
    NSMutableArray *filteredGinkoContacts;
    NSMutableArray *filteredNonGinkoContacts;
    
    NSDictionary *selectedContact;
    
    BOOL allLoaded;
    BOOL searchAllLoaded;
    BOOL doingLocalSearch;
    
    int currentPage;
    int currentSearchPage;
    int numbersPerPage;
    
    NSString *invitingEmail;
    NSString *invitingPhone;
    NSUInteger invitingRow;
    BOOL fromLocal;
    
    BOOL onlyOneCheck;
}
@end

@implementation GinkoConnectViewController

#define kNameKey    @"name"
#define kPhoneKey   @"phone"
#define kEmailKey   @"email"
#define kUserIdKey @"user_id"
#define kInvitationText @"Join Ginko and exchange your contact info with me.\n\nUser name: %@\n\n-Exchange contact info effortlessly\n-Your contact’s information is always current\n-Share what you want with whom you want\n-Permanently backup your contacts\n-Individual and group chat\n\nApp Store & Google Play:\nhttp://ginko.mobi/app"


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 68;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ConnectNonGinkoUserCell" bundle:nil] forCellReuseIdentifier:@"ConnectNonGinkoUserCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ConnectGinkoUserCell" bundle:nil] forCellReuseIdentifier:@"ConnectGinkoUserCell"];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(invite:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Skip" style:UIBarButtonItemStylePlain target:self action:@selector(skip:)];
    self.title = @"Ginko Connect";
    
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBarTintColor:COLOR_PURPLE_THEME];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    
    _isExchange = NO;
    
    allContacts = [NSMutableArray new];
    ginkoContacts = [NSMutableArray new];
    nonGinkoContacts = [NSMutableArray new];
    
    allLoaded = NO;
    searchAllLoaded = NO;
    currentPage = 1;
    currentSearchPage = 1;
    
    numbersPerPage = 20;
    onlyOneCheck = NO;
    
    if (!_isExchange) {
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                ABAddressBookCreate();
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self doCrossCheck];
                    });
                }
            });
        }
        else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
            [self doCrossCheck];
        }
        else {
            // Send an alert telling user to change privacy setting in settings app
            [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Could not get contact info from address book, you can allow Ginko to access your contacts in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
    
    _searchBar.delegate = self;
    filteredGinkoContacts = [NSMutableArray new];
    filteredNonGinkoContacts = [NSMutableArray new];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadGinkoContact:) name:GET_CONTACTLIST_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeInGinkoContact) name:CONTACT_SYNC_NOTIFICATION object:nil];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GET_CONTACTLIST_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CONTACT_SYNC_NOTIFICATION object:nil];
}
- (void)reloadGinkoContact:(NSNotification *) notification
{
    if (_isExchange) {
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                ABAddressBookCreate();
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self doCrossCheck];
                    });
                }
            });
        }
        else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
            [self doCrossCheck];
        }
        else {
            // Send an alert telling user to change privacy setting in settings app
            [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Could not get contact info from address book, you can allow Ginko to access your contacts in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
}
- (void)removeInGinkoContact
{
    if (_isExchange) {
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                ABAddressBookCreate();
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self doCrossCheck];
                    });
                }
            });
        }
        else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
            [self doCrossCheck];
        }
        else {
            // Send an alert telling user to change privacy setting in settings app
            [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Could not get contact info from address book, you can allow Ginko to access your contacts in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
}
- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBarTintColor:COLOR_PURPLE_THEME];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    
    allLoaded = NO;
    
    if (_isExchange) {
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                ABAddressBookCreate();
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self doCrossCheck];
                    });
                }
            });
        }
        else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
            [self doCrossCheck];
        }
        else {
            // Send an alert telling user to change privacy setting in settings app
            [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Could not get contact info from address book, you can allow Ginko to access your contacts in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        [self.tableView reloadData];
    }
}
- (void)loadInviteLists {
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[YYYCommunication sharedManager] getExchangeInvites:[AppDelegate sharedDelegate].sessionId keyword:nil pageNum:currentPage countPerPage:numbersPerPage successed:^(id _responseObject) {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            
            if ([_responseObject[@"success"] intValue] == 1) {
                // success
                NSArray *contactsDicArray = _responseObject[@"data"];
                if (contactsDicArray.count < numbersPerPage) {
                    allLoaded = YES;
                }
                
                currentPage++;
                
                for (NSDictionary *contactDic in contactsDicArray) {
                    if ([contactDic[@"in_ginko"] intValue] == 1) {
                        NSArray *filtered = [ginkoContacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"user_id == %@", contactDic[@"user_id"]]];
                        if (filtered.count == 0) {
                            [ginkoContacts addObject:contactDic];
                        }
                    } else {
                        if ([nonGinkoContacts indexOfObject:contactDic] == NSNotFound)
                            [nonGinkoContacts addObject:contactDic];
                    }
                }
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to load contacts. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
            
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        }];
    });
}

- (void)loadSearchInviteLists {
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[YYYCommunication sharedManager] getExchangeInvites:[AppDelegate sharedDelegate].sessionId keyword:self.searchBar.text pageNum:currentSearchPage countPerPage:numbersPerPage successed:^(id _responseObject) {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            
            if ([_responseObject[@"success"] intValue] == 1) {
                // success
                NSArray *contactsDicArray = _responseObject[@"data"];
                if (contactsDicArray.count < numbersPerPage) {
                    searchAllLoaded = YES;
                }
                
                currentSearchPage++;
                
                for (NSDictionary *contactDic in contactsDicArray) {
                    if ([contactDic[@"in_ginko"] intValue] == 1) {
                        NSArray *filtered = [filteredGinkoContacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"user_id == %@", contactDic[@"user_id"]]];
                        if (filtered.count == 0) {
                            [filteredGinkoContacts addObject:contactDic];
                        }
                    } else {
                        if ([filteredNonGinkoContacts indexOfObject:contactDic] == NSNotFound)
                            [filteredNonGinkoContacts addObject:contactDic];
                    }
                }
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to load contacts. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
            
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        }];
    });
}

- (void)doCrossCheck {
    allContacts = [NSMutableArray new];
    
    CFErrorRef *error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    CFMutableArrayRef peopleMutable = CFArrayCreateMutableCopy(kCFAllocatorDefault, CFArrayGetCount(allPeople), allPeople);
    
    CFArraySortValues(peopleMutable, CFRangeMake(0, CFArrayGetCount(peopleMutable)), (CFComparatorFunction)ABPersonComparePeopleByName, kABPersonSortByFirstName);
    
    CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    
    NSMutableArray *arrEmailForChecking = [NSMutableArray new];
    NSMutableArray *arrPhoneForChecking = [NSMutableArray new];
    
    for(int i = 0; i < numberOfPeople; i++) {
        ABRecordRef person = CFArrayGetValueAtIndex(peopleMutable, i);
        
        //get First Name
        CFStringRef firstNameRef = (CFStringRef)ABRecordCopyValue(person,kABPersonFirstNameProperty);
        NSString *firstName = [(__bridge NSString*)firstNameRef copy];
        
        if (firstNameRef != NULL) {
            CFRelease(firstNameRef);
        }
        
        //get Last Name
        CFStringRef lastNameRef = (CFStringRef)ABRecordCopyValue(person,kABPersonLastNameProperty);
        NSString *lastName = [(__bridge NSString*)lastNameRef copy];
        
        if (lastNameRef != NULL) {
            CFRelease(lastNameRef);
        }
        
        if (!firstName) {
            firstName = @"";
        }
        
        if (!lastName) {
            lastName = @"";
        }
        
        NSString *fullname = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        fullname = [fullname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        //get Phone Numbers
        NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
        ABMultiValueRef multiPhones = ABRecordCopyValue(person, kABPersonPhoneProperty);
        
        for(CFIndex i=0; i<ABMultiValueGetCount(multiPhones); i++) {
            @autoreleasepool {
                CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, i);
                NSString *phoneNumber = CFBridgingRelease(phoneNumberRef);
                if (phoneNumber != nil && ![arrPhoneForChecking containsObject:phoneNumber]) {
                    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
                    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
                    [phoneNumbers addObject:phoneNumber];
                    [arrPhoneForChecking addObject:phoneNumber];
                }
                //NSLog(@"All numbers %@", phoneNumbers);
            }
        }
        
        if (multiPhones != NULL) {
            CFRelease(multiPhones);
        }
        
        //get Contact email
        NSMutableArray *contactEmails = [NSMutableArray new];
        ABMultiValueRef multiEmails = ABRecordCopyValue(person, kABPersonEmailProperty);
        
        for (CFIndex i=0; i<ABMultiValueGetCount(multiEmails); i++) {
            @autoreleasepool {
                CFStringRef contactEmailRef = ABMultiValueCopyValueAtIndex(multiEmails, i);
                NSString *contactEmail = CFBridgingRelease(contactEmailRef);
                if (contactEmail != nil && ![arrEmailForChecking containsObject:contactEmail]){
                    [contactEmails addObject:contactEmail];
                    [arrEmailForChecking addObject:contactEmail];
                }
                // NSLog(@"All emails are:%@", contactEmails);
            }
        }
        
        if (multiPhones != NULL) {
            CFRelease(multiEmails);
        }
        
        if (phoneNumbers.count == 0 && contactEmails.count == 0)
            continue;
        
        NSMutableDictionary *contactDic = [NSMutableDictionary new];
        contactDic[kNameKey] = fullname;
        if (phoneNumbers.count > 0)
            contactDic[kPhoneKey] = phoneNumbers;
        if (contactEmails.count > 0)
            contactDic[kEmailKey] = contactEmails[0];
        
        [allContacts addObject:[contactDic copy]];
    }
    
    if (allContacts.count > 0) {
        if (!onlyOneCheck) {
            [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            onlyOneCheck = YES;
        }
        NSMutableArray *postArray = [NSMutableArray new];
        for (NSDictionary *contact in allContacts) {
            NSMutableDictionary *temp = [contact mutableCopy];
            [temp removeObjectForKey:kNameKey];
            [postArray addObject:[temp copy]];
        }
        [[YYYCommunication sharedManager] checkUsers:[AppDelegate sharedDelegate].sessionId data:postArray successed:^(id _responseObject) {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            onlyOneCheck = NO;
            if (_responseObject && [_responseObject[@"success"] boolValue]) {
                ginkoContacts = [NSMutableArray new];
                nonGinkoContacts = [allContacts mutableCopy];
                
                for (NSDictionary *data in _responseObject[@"data"]) {
                    if ([data[@"in_ginko"] integerValue] == 1) {
                        [ginkoContacts addObject:data];
                    }
                }
                
                for (NSDictionary *contact in allContacts) {
                    for (NSDictionary *data in ginkoContacts) {
                        if ([data[@"in_ginko"] integerValue] == 1) {
                            if ((contact[kEmailKey] && data[kEmailKey] && [contact[kEmailKey] isEqualToString:data[kEmailKey]])
                                || (contact[kPhoneKey] && data[kPhoneKey] && (([contact[kPhoneKey] isKindOfClass:[NSArray class]] && [contact[kPhoneKey] indexOfObject:data[kPhoneKey]] != NSNotFound) || ([contact[kPhoneKey] isKindOfClass:[NSString class]] && [contact[kPhoneKey] isEqualToString:data[kPhoneKey]])))) {
                                [nonGinkoContacts removeObject:contact];
                                
                            }
                        }
                    }
                }
                
                [ginkoContacts removeAllObjects];
                for (NSDictionary *data in _responseObject[@"data"]) {
                    if ([data[@"in_ginko"] integerValue] == 1 && [data[@"is_friend"] integerValue] != 1) {
                        [ginkoContacts addObject:data];
                    }
                }
                
                for (int i = 0; i < [nonGinkoContacts count]; i++) { // add a flag that the contact is from local
                    NSMutableDictionary *temp = [nonGinkoContacts[i] mutableCopy];
                    temp[@"is_local"] = @YES;
                    [nonGinkoContacts replaceObjectAtIndex:i withObject:[temp copy]];
                }
                for (NSDictionary *data in _responseObject[@"data"]) {
                    if ([data[@"in_ginko"] integerValue] == 0 && [data[@"is_send"] integerValue] == 1) {
                        for (int i = 0; i < [nonGinkoContacts count]; i++) {
                            NSDictionary *contact = nonGinkoContacts[i];
                            if ((contact[kEmailKey] && data[kEmailKey] && [contact[kEmailKey] isEqualToString:data[kEmailKey]])
                                || (contact[kPhoneKey] && data[kPhoneKey] && (([contact[kPhoneKey] isKindOfClass:[NSArray class]] && [contact[kPhoneKey] indexOfObject:data[kPhoneKey]] != NSNotFound) || ([contact[kPhoneKey] isKindOfClass:[NSString class]] && [contact[kPhoneKey] isEqualToString:data[kPhoneKey]])))) {
                                NSMutableDictionary *temp = [contact mutableCopy];
                                temp[@"is_send"] = @1;
                                [nonGinkoContacts replaceObjectAtIndex:i withObject:[temp copy]];
                            }
                        }
                    }
                }
                
                
//                [self loadInviteLists]
                if (_searchBar.text && ![_searchBar.text  isEqual: @""]) {
                    //[self searchBar:searchBarForList textDidChange:searchBarForList.text];
                    [self searchBar:_searchBar textDidChange:_searchBar.text];
                }

                [self.tableView reloadData];
                
            } else {
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                onlyOneCheck = NO;
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to connect to server." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        } failure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            onlyOneCheck = NO;
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to connect to server." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
        
    }
}

- (void)skip:(id)sender {
    APPDELEGATE.isPreviewPhoneVerifyView = NO;
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    if (_isFromContacts)
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    else
        [[AppDelegate sharedDelegate] setWizardPage:@"2"];
}

- (void)invite:(id)sender {
    [self.view endEditing:NO];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invite"
                                                        message:@"Enter a mobile number or email for a contact."
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[alertView textFieldAtIndex:0] setTextAlignment:NSTextAlignmentCenter];
    [alertView setTag:100];
    UITextField *textField = [alertView textFieldAtIndex:0];
    [textField setKeyboardType:UIKeyboardTypeEmailAddress];
    [alertView show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)isSearching {
    return ![self.searchBar.text isEqualToString:@""];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
        int section = 0;
    if (![self isSearching]) {
        if ([ginkoContacts count] != 0)
            section++;
        if ([nonGinkoContacts count] != 0)
            section++;
    } else {
        if ([filteredGinkoContacts count] != 0)
            section++;
        if ([filteredNonGinkoContacts count] != 0)
            section++;
    }
    
    return section;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (![self isSearching]) {
        if (section == 1)
            return nonGinkoContacts.count;
        if (ginkoContacts.count != 0)
            return ginkoContacts.count;
        return nonGinkoContacts.count;
    } else {
        if (section == 1)
            return filteredNonGinkoContacts.count;
        if (filteredGinkoContacts.count != 0)
            return filteredGinkoContacts.count;
        return filteredNonGinkoContacts.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1)
        return @"NOT IN GINKO";
    if (![self isSearching]) {
        if (ginkoContacts.count != 0)
            return @"IN GINKO";
    } else {
        if (filteredGinkoContacts.count != 0)
            return @"IN GINKO";
    }
    return @"NOT IN GINKO";
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == [self numberOfSectionsInTableView:tableView] - 1 && !allLoaded && ![self isSearching])
        return 40;
    if (section == [self numberOfSectionsInTableView:tableView] - 1 && !searchAllLoaded && [self isSearching] && !doingLocalSearch)
        return 40;
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == [self numberOfSectionsInTableView:tableView] - 1 && !allLoaded && ![self isSearching]) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [indicator startAnimating];
        indicator.hidesWhenStopped = YES;
        [view addSubview:indicator];
        indicator.center = CGPointMake(160, 20);
        
        [self loadInviteLists];
        
        return view;
    }
    
    if (section == [self numberOfSectionsInTableView:tableView] - 1 && !searchAllLoaded && [self isSearching] && !doingLocalSearch) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [indicator startAnimating];
        indicator.hidesWhenStopped = YES;
        [view addSubview:indicator];
        indicator.center = CGPointMake(160, 20);
        
        [self loadSearchInviteLists];
        
        return view;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self isSearching]) {
        if (indexPath.section == 0 && ginkoContacts.count != 0) {
            ConnectGinkoUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConnectGinkoUserCell" forIndexPath:indexPath];
            cell.delegate = self;
            NSDictionary *contactDic = ginkoContacts[indexPath.row];
            cell.nameLabel.text = contactDic[kNameKey];
            if (contactDic[kPhoneKey])
                cell.phoneLabel.text = contactDic[kPhoneKey][0];
            else
                cell.phoneLabel.text = contactDic[kEmailKey];
            
            NSString *profileImageUrl = contactDic[@"profile_image"];
            cell.profileImageView.image = nil;
            if (profileImageUrl && ![profileImageUrl isEqualToString:@""]) {
                NSString *localFilePath = [LocalDBManager checkCachedFileExist:profileImageUrl];
                if (localFilePath) {
                    // load from local
                    cell.profileImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:localFilePath]];
                } else {
                    [cell.profileImageView cancelImageRequestOperation];
                    [cell.profileImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:profileImageUrl]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                        [cell.profileImageView setImage:image];
                        [LocalDBManager saveImage:image forRemotePath:profileImageUrl];
                    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                        
                    }];
                }
            }
            
            if (contactDic[@"is_send"] && [contactDic[@"is_send"] intValue] == 1) {
                [cell setInviteStatus:YES];
            } else {
                [cell setInviteStatus:NO];
            }
            
            return cell;
        }
        
        ConnectNonGinkoUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConnectNonGinkoUserCell" forIndexPath:indexPath];
        cell.delegate = self;
        NSDictionary *contactDic = nonGinkoContacts[indexPath.row];
        cell.nameLabel.text = contactDic[kNameKey];
        if (contactDic[kPhoneKey]) {
            if ([contactDic[kPhoneKey] isKindOfClass:[NSArray class]])
                cell.phoneLabel.text = contactDic[kPhoneKey][0];
            else
                cell.phoneLabel.text = contactDic[kPhoneKey];
        }
        else
            cell.phoneLabel.text = @"";
        
        if (contactDic[kEmailKey])
            cell.emailLabel.text = contactDic[kEmailKey];
        else
            cell.emailLabel.text = @"";
        
        if (contactDic[@"is_send"] && [contactDic[@"is_send"] intValue] == 1) {
            [cell setInviteStatus:YES];
        } else {
            [cell setInviteStatus:NO];
        }
        
        return cell;
    } else {
        if (indexPath.section == 0 && filteredGinkoContacts.count != 0) {
            ConnectGinkoUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConnectGinkoUserCell" forIndexPath:indexPath];
            cell.delegate = self;
            NSDictionary *contactDic = filteredGinkoContacts[indexPath.row];
            cell.nameLabel.text = contactDic[kNameKey];
            if (contactDic[kPhoneKey])
                cell.phoneLabel.text = contactDic[kPhoneKey][0];
            else
                cell.phoneLabel.text = contactDic[kEmailKey];
            
            NSString *profileImageUrl = contactDic[@"profile_image"];
            cell.profileImageView.image = nil;
            if (profileImageUrl && ![profileImageUrl isEqualToString:@""]) {
                NSString *localFilePath = [LocalDBManager checkCachedFileExist:profileImageUrl];
                if (localFilePath) {
                    // load from local
                    cell.profileImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:localFilePath]];
                } else {
                    [cell.profileImageView cancelImageRequestOperation];
                    [cell.profileImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:profileImageUrl]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                        [cell.profileImageView setImage:image];
                        [LocalDBManager saveImage:image forRemotePath:profileImageUrl];
                    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                        
                    }];
                }
            }
            if (contactDic[@"is_send"] && [contactDic[@"is_send"] intValue] == 1) {
                [cell setInviteStatus:YES];
            } else {
                [cell setInviteStatus:NO];
            }
            return cell;
        }
        
        ConnectNonGinkoUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConnectNonGinkoUserCell" forIndexPath:indexPath];
        cell.delegate = self;
        NSDictionary *contactDic = filteredNonGinkoContacts[indexPath.row];
        cell.nameLabel.text = contactDic[kNameKey];
        if (contactDic[kPhoneKey]) {
            if ([contactDic[kPhoneKey] isKindOfClass:[NSArray class]])
                cell.phoneLabel.text = contactDic[kPhoneKey][0];
            else
                cell.phoneLabel.text = contactDic[kPhoneKey];
        }
        else
            cell.phoneLabel.text = @"";
        if (contactDic[kEmailKey])
            cell.emailLabel.text = contactDic[kEmailKey];
        else
            cell.emailLabel.text = @"";
        
        if (contactDic[@"is_send"] && [contactDic[@"is_send"] intValue] == 1) {
            [cell setInviteStatus:YES];
        } else {
            [cell setInviteStatus:NO];
        }
        
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    [_searchBar endEditing:YES];
    
}
#pragma mark - Scroll View Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_searchBar resignFirstResponder];
}
#pragma mark - ConnectGinkoUserCellDelegate
- (void)connectGinkoUserCellDoExchange:(ConnectGinkoUserCell *)cell {
    _isExchange = YES;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath) {
        ProfileRequestController *controller = [[ProfileRequestController alloc] initWithNibName:@"ProfileRequestController" bundle:nil];
        if (![self isSearching]){
            controller.contactInfo = @{@"contact_id": ginkoContacts[indexPath.row][kUserIdKey]};
            if (ginkoContacts[indexPath.row][@"is_send"] && [ginkoContacts[indexPath.row][@"is_send"] intValue] == 1) {
                controller.navBarColor = YES;
            } else {
                controller.navBarColor = NO;
            }
        }
        else{
            controller.contactInfo = @{@"contact_id": filteredGinkoContacts[indexPath.row][kUserIdKey]};
            if (filteredGinkoContacts[indexPath.row][@"is_send"] && [ginkoContacts[indexPath.row][@"is_send"] intValue] == 1) {
                controller.navBarColor = YES;
            } else {
                controller.navBarColor = NO;
            }
        }
        
        [AppDelegate sharedDelegate].type = 1;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - ConnectNonGinkoUserCellDelegate
- (void)connectNonGinkoUserCellInvite:(ConnectNonGinkoUserCell *)cell {
    _isExchange = NO;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath) {
        NSDictionary *contact = ![self isSearching] ? nonGinkoContacts[indexPath.row] : filteredNonGinkoContacts[indexPath.row];
        invitingRow = indexPath.row;
        if (contact[@"is_local"])
            fromLocal = YES;
        else
            fromLocal = NO;
        if (contact[kPhoneKey]) {
            if (!contact[kEmailKey]) {
                if ([contact[kPhoneKey] isKindOfClass:[NSArray class]] && [contact[kPhoneKey] count] == 1)
                    [self sendSMSToPhone:contact[kPhoneKey][0]];
                else{
                    [self.view endEditing:NO];
                    selectedContact = contact;
                    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
                    if (contact[kPhoneKey]) {
                        for (NSString *phone in contact[kPhoneKey]) {
                            [sheet addButtonWithTitle:phone];
                        }
                    }
                    sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
                    
                    [sheet showInView:self.view];
                }
                   // [self sendSMSToPhone:contact[kPhoneKey]];
                
            } else {
                [self.view endEditing:NO];
                selectedContact = contact;
                UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
                if (contact[kPhoneKey]) {
                    for (NSString *phone in contact[kPhoneKey]) {
                        [sheet addButtonWithTitle:phone];
                    }
                }
                if (contact[kEmailKey]) {
                    [sheet addButtonWithTitle:contact[kEmailKey]];
                }
                
                sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
                
                [sheet showInView:self.view];
            }
        } else if (contact[kEmailKey]) {
            [self sendMailToEmailAddress:contact[kEmailKey]];
        }
        // Do by api
//        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//        [[YYYCommunication sharedManager] inviteUsers:[AppDelegate sharedDelegate].sessionId emails:contact[kEmailKey] ? @[contact[kEmailKey]] : nil phones:contact[kPhoneKey] ? @[contact[kPhoneKey]] : nil successed:^(id _responseObject) {
//            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
//            if (_responseObject && [_responseObject[@"success"] boolValue]) {
//                [[[UIAlertView alloc] initWithTitle:@"GINKO" message:@"Invited successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//            } else {
//                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to connect to server." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//            }
//        } failure:^(NSError *error) {
//            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
//            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to connect to server." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//        }];
    }
}

#pragma mark - Helper methods
- (void)sendSMSToPhone:(NSString *)phone {
    if([MFMessageComposeViewController canSendText]) {
        invitingPhone = phone;
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        NSString *userName = [NSString stringWithFormat:@"%@",[AppDelegate sharedDelegate].userName];
        controller.body = [NSString stringWithFormat:kInvitationText, userName];
        controller.recipients = @[phone];
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Your device is not compatible with SMS." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (void)sendMailToEmailAddress:(NSString *)email {
    if([MFMailComposeViewController canSendMail])
    {
        invitingEmail = email;
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        [picker setToRecipients:@[email]];
        NSString *userName = [NSString stringWithFormat:@"%@",[AppDelegate sharedDelegate].userName];
        [picker setMessageBody:[NSString stringWithFormat:kInvitationText, userName] isHTML:NO];
        [picker setSubject:@"Exchange contact info with me via Ginko"];
        
        [self presentViewController:picker animated:YES completion:^{
            //            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        }];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Please configure mail accounts to send mail." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
}

#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    NSMutableDictionary *tempDic = [NSMutableDictionary new];
    
    if (result == MessageComposeResultSent) {
        if (invitingRow != -1) {
            tempDic = ![self isSearching] ? [nonGinkoContacts[invitingRow] mutableCopy] : [filteredNonGinkoContacts[invitingRow] mutableCopy];
            tempDic[@"is_send"] = @1;
            
            if (![self isSearching])
                [nonGinkoContacts replaceObjectAtIndex:invitingRow withObject:[tempDic copy]];
            else {
                NSDictionary *oldDic = filteredNonGinkoContacts[invitingRow];
                NSInteger index = [nonGinkoContacts indexOfObject:oldDic];
                if (index != NSNotFound)
                    [nonGinkoContacts replaceObjectAtIndex:index withObject:[tempDic copy]];
                [filteredNonGinkoContacts replaceObjectAtIndex:invitingRow withObject:[tempDic copy]];
            }
        } else {
            tempDic = [NSMutableDictionary new];
            tempDic[@"in_ginko"] = @0;
            tempDic[@"is_send"] = @1;
            tempDic[@"name"] = @"";
            tempDic[@"profile_image"] = @"http://image.ginko.mobi/Photos/greyblank.png";
            tempDic[kPhoneKey] = invitingPhone;
            [nonGinkoContacts addObject:tempDic];
        }
        
        [self.tableView reloadData];
        
        [[YYYCommunication sharedManager] didSentInvite:[AppDelegate sharedDelegate].sessionId email:nil phone:invitingPhone fromLocal:fromLocal successed:^(id responseObject) {
            NSLog(@"%@", responseObject);
        } failure:nil];
    } else if (invitingRow == -1) {
        NSMutableDictionary *tempDic = [NSMutableDictionary new];
        tempDic[@"in_ginko"] = @0;
        tempDic[@"is_send"] = @0;
        tempDic[@"name"] = @"";
        tempDic[@"profile_image"] = @"http://image.ginko.mobi/Photos/greyblank.png";
        tempDic[kPhoneKey] = invitingPhone;
        [nonGinkoContacts addObject:tempDic];
        
        [self.tableView reloadData];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
    if (result == MFMailComposeResultSent) {
        NSMutableDictionary *tempDic;
        if (invitingRow != -1) {
            tempDic = ![self isSearching] ? [nonGinkoContacts[invitingRow] mutableCopy] : [filteredNonGinkoContacts[invitingRow] mutableCopy];
            tempDic[@"is_send"] = @1;
            if (![self isSearching])
                [nonGinkoContacts replaceObjectAtIndex:invitingRow withObject:[tempDic copy]];
            else {
                NSDictionary *oldDic = filteredNonGinkoContacts[invitingRow];
                NSInteger index = [nonGinkoContacts indexOfObject:oldDic];
                if (index != NSNotFound)
                    [nonGinkoContacts replaceObjectAtIndex:index withObject:[tempDic copy]];
                [filteredNonGinkoContacts replaceObjectAtIndex:invitingRow withObject:[tempDic copy]];
            }
        } else {
            tempDic = [NSMutableDictionary new];
            tempDic[@"in_ginko"] = @0;
            tempDic[@"is_send"] = @1;
            tempDic[@"name"] = @"";
            tempDic[@"profile_image"] = @"http://image.ginko.mobi/Photos/greyblank.png";
            tempDic[kEmailKey] = invitingEmail;
            [nonGinkoContacts addObject:tempDic];
        }
        
        [self.tableView reloadData];
        
        [[YYYCommunication sharedManager] didSentInvite:[AppDelegate sharedDelegate].sessionId email:invitingEmail phone:nil fromLocal:fromLocal successed:^(id responseObject) {
            NSLog(@"%@", responseObject);
        } failure:nil];
    } else if (invitingRow == -1) {
        NSMutableDictionary *tempDic = [NSMutableDictionary new];
        tempDic[@"in_ginko"] = @0;
        tempDic[@"is_send"] = @0;
        tempDic[@"name"] = @"";
        tempDic[@"profile_image"] = @"http://image.ginko.mobi/Photos/greyblank.png";
        tempDic[kEmailKey] = invitingEmail;
        [nonGinkoContacts addObject:[tempDic copy]];
        
        [self.tableView reloadData];
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        //[_searchBar becomeFirstResponder];
        return;
    }
    
    if (buttonIndex < [selectedContact[kPhoneKey] count]) {
        [self sendSMSToPhone:selectedContact[kPhoneKey][buttonIndex]];
    } else {
        [self sendMailToEmailAddress:selectedContact[kEmailKey]];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([alertView tag] == 100 && buttonIndex == 1)
    {
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSString *text = textField.text;
        
        if (text.length == 0) {
            [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"The input field is empty." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return;
        }
        
        void (^successed)(id _responseObject) = ^(id _responseObject) {
            if ([[_responseObject objectForKey:@"success"] boolValue]) {
                NSDictionary *data = _responseObject[@"data"][0];
                if (data[@"user_id"]) { // IN GINKO
                    if (data[@"is_friend"]) { // already a friend, show alert message
                        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"The user is already in your contact list." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    } else {
                        NSMutableDictionary *tempDic = [data mutableCopy];
                        tempDic[@"in_ginko"] = @1;
                        [ginkoContacts addObject:[tempDic copy]];
                        //NSLog(@"response---%@",_responseObject);
                        [self.tableView reloadData];
                        
                        // show request view controller
                        ProfileRequestController *controller = [[ProfileRequestController alloc] initWithNibName:@"ProfileRequestController" bundle:nil];
                        controller.contactInfo = @{@"contact_id": data[@"user_id"]};
                        [AppDelegate sharedDelegate].type = 1;
                        [self.navigationController pushViewController:controller animated:YES];
                    }
                } else {    // NOT IN GINKO, show sms or email
                    invitingRow = -1;
                    if (data[@"email"]) {
                        [self sendMailToEmailAddress:data[@"email"]];
                    } else if (data[@"phone"]) {
                        [self sendSMSToPhone:data[@"phone"]];
                    } else {
                        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Invalid email or mobile number." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    }
                }
                allLoaded = NO;
                [self.tableView reloadData];
                // get sent invitation
            } else {
                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:_responseObject[@"err"][@"errMsg"]];
            }
        };
        
        void (^failure)(NSError *_error) = ^(NSError *_error) {
            NSLog(@"Connection failed - %@", _error);
        };
        
        BOOL filter = YES ;
        NSString *filterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,99}";
        NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
        NSString *emailRegex = filter ? filterString : laxString;
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        
        if ([emailTest evaluateWithObject:text] == YES) {
            [[Communication sharedManager] AddInvitations:[AppDelegate sharedDelegate].sessionId email:text phone:nil successed:successed failure:failure];
        } else {    // phone
            NSError *error = nil;
            NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber
                                                                       error:&error];
            NSUInteger numberOfMatches = [detector numberOfMatchesInString:text
                                                                   options:0
                                                                     range:NSMakeRange(0, [text length])];
            NSLog(@"%lu", (unsigned long)numberOfMatches);
            if (numberOfMatches != -1) {
                [[Communication sharedManager] AddInvitations:[AppDelegate sharedDelegate].sessionId email:nil phone:text successed:successed failure:failure];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Please input correct email or phone number." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }
    }
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    doingLocalSearch = NO;
    
    NSString *searchText = [searchBar.text lowercaseString];
    
    filteredGinkoContacts = [NSMutableArray new];
    for (NSDictionary *contact in ginkoContacts) {
        if (contact[@"name"] && [[contact[@"name"] lowercaseString] rangeOfString:searchText].location != NSNotFound) {
            [filteredGinkoContacts addObject:contact];
            continue;
        }
        
        if (contact[@"email"] && [[contact[@"email"] lowercaseString] rangeOfString:searchText].location != NSNotFound) {
            [filteredGinkoContacts addObject:contact];
            continue;
        }
        
        if (contact[@"phone"]) {
            if ([contact[@"phone"] isKindOfClass:[NSString class]] && [[contact[@"phone"] lowercaseString] rangeOfString:searchText].location != NSNotFound) {
                [filteredGinkoContacts addObject:contact];
                continue;
            }
            if ([contact[@"phone"] isKindOfClass:[NSArray class]]) {
                BOOL exist = NO;
                for (NSString *phone in contact[@"phone"]) {
                    if ([[phone lowercaseString] rangeOfString:searchText].location != NSNotFound)
                        exist = YES;
                }
                if (exist) {
                    [filteredGinkoContacts addObject:contact];
                    continue;
                }
            }
        }
    }
    
    filteredNonGinkoContacts = [NSMutableArray new];
    for (NSDictionary *contact in nonGinkoContacts) {
        if (contact[@"name"] && [[contact[@"name"] lowercaseString] rangeOfString:searchText].location != NSNotFound) {
            [filteredNonGinkoContacts addObject:contact];
            continue;
        }
        
        if (contact[@"email"] && [[contact[@"email"] lowercaseString] rangeOfString:searchText].location != NSNotFound) {
            [filteredNonGinkoContacts addObject:contact];
            continue;
        }
        
        if (contact[@"phone"]) {
            if ([contact[@"phone"] isKindOfClass:[NSString class]] && [[contact[@"phone"] lowercaseString] rangeOfString:searchText].location != NSNotFound) {
                [filteredNonGinkoContacts addObject:contact];
                continue;
            }
            if ([contact[@"phone"] isKindOfClass:[NSArray class]]) {
                BOOL exist = NO;
                for (NSString *phone in contact[@"phone"]) {
                    if ([[phone lowercaseString] rangeOfString:searchText].location != NSNotFound)
                        exist = YES;
                }
                if (exist) {
                    [filteredNonGinkoContacts addObject:contact];
                    continue;
                }
            }
        }
    }
    
//    filteredGinkoContacts = [NSMutableArray new];
//    filteredNonGinkoContacts = [NSMutableArray new];
    currentSearchPage = 1;
    
    [self loadSearchInviteLists];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0) {
        doingLocalSearch = YES;
        searchText = [searchText lowercaseString];
        filteredGinkoContacts = [NSMutableArray new];
        for (NSDictionary *contact in ginkoContacts) {
            if (contact[@"name"] && [[contact[@"name"] lowercaseString] rangeOfString:searchText].location != NSNotFound) {
                [filteredGinkoContacts addObject:contact];
                continue;
            }
            
            if (contact[@"email"] && [[contact[@"email"] lowercaseString] rangeOfString:searchText].location != NSNotFound) {
                [filteredGinkoContacts addObject:contact];
                continue;
            }
            
            if (contact[@"phone"]) {
                if ([contact[@"phone"] isKindOfClass:[NSString class]] && [[contact[@"phone"] lowercaseString] rangeOfString:searchText].location != NSNotFound) {
                    [filteredGinkoContacts addObject:contact];
                    continue;
                }
                if ([contact[@"phone"] isKindOfClass:[NSArray class]]) {
                    BOOL exist = NO;
                    for (NSString *phone in contact[@"phone"]) {
                        if ([[phone lowercaseString] rangeOfString:searchText].location != NSNotFound)
                            exist = YES;
                    }
                    if (exist) {
                        [filteredGinkoContacts addObject:contact];
                        continue;
                    }
                }
            }
        }
        
        filteredNonGinkoContacts = [NSMutableArray new];
        for (NSDictionary *contact in nonGinkoContacts) {
            if (contact[@"name"] && [[contact[@"name"] lowercaseString] rangeOfString:searchText].location != NSNotFound) {
                [filteredNonGinkoContacts addObject:contact];
                continue;
            }
            
            if (contact[@"email"] && [[contact[@"email"] lowercaseString] rangeOfString:searchText].location != NSNotFound) {
                [filteredNonGinkoContacts addObject:contact];
                continue;
            }
            
            if (contact[@"phone"]) {
                if ([contact[@"phone"] isKindOfClass:[NSString class]] && [[contact[@"phone"] lowercaseString] rangeOfString:searchText].location != NSNotFound) {
                    [filteredNonGinkoContacts addObject:contact];
                    continue;
                }
                if ([contact[@"phone"] isKindOfClass:[NSArray class]]) {
                    BOOL exist = NO;
                    for (NSString *phone in contact[@"phone"]) {
                        if ([[phone lowercaseString] rangeOfString:searchText].location != NSNotFound)
                            exist = YES;
                    }
                    if (exist) {
                        [filteredNonGinkoContacts addObject:contact];
                        continue;
                    }
                }
            }
        }
    }
    
    [self.tableView reloadData];
}

@end
