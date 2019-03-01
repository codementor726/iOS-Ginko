//
//  CISyncDetailController.m
//  ContactImporter
//
//  Created by mobidev on 6/20/14.
//  Copyright (c) 2014 Ron. All rights reserved.
//

#import "CISyncDetailController.h"
#import "GreyInfoController.h"
#import "GreyAddNotesController.h"
#import "LPlaceholderTextView.h"
#import "GreyClient.h"
#import "UIImage+Resize.h"
#import "SVGeocoder.h"
#import "ContactImporterClient.h"
#import "UIImageView+AFNetworking.h"

#import "UIImage+Tint.h"

@interface CISyncDetailController ()
{
    int greyType;
    CGRect frmTable;
    
    NSMutableArray *tempDataSource;
    NSMutableArray *arrInfoFiledNames;
    
    NSString *photoName;
    NSString *photoURL;
    
    UITapGestureRecognizer *tapRecognizer;
    BOOL removeItemFlag;
    
    UIView *footView;
    
    NSMutableArray *cells;
}
@end

@implementation CISyncDetailController
@synthesize arrDataSource;
@synthesize curContactDict, strNotes;
@synthesize navView, tblInfo, viewTap, viewFirstCell;
@synthesize btnAvatar, imgAvatar, btnEdit, btnDel, btnEntity, btnHome, btnInfo, btnEditInfo, btnNotes, btnRemove, btnWork, btnBack, btnClose, btnDone, label, txtName, txtFirstName, txtLastName;
@synthesize appDelegate;
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
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    if (_globalData.isFromMenu) {
//        curContactDict = [[NSMutableDictionary alloc] initWithDictionary:appDelegate.importDict];
    curContactDict = appDelegate.importDict;
//    }
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    // self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:230.0/256.0 green:1.0f blue:190.0/256.0 alpha:1.0f];
    
    frmTable = tblInfo.frame;
    
    greyType = 0;
    strNotes = @"";
    
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    arrDataSource = [[NSMutableArray alloc] init];
    
    arrInfoFiledNames = [[NSMutableArray alloc] init];
    NSArray *arr = [NSArray arrayWithObjects:@"Company", @"Mobile", @"Mobile#2", @"Phone", @"Phone#2", @"Phone#3", @"Email", @"Email#2", @"Address", @"Address#2", @"Fax", @"Birthday", @"Facebook", @"Twitter", @"Website", @"Custom", @"Custom#2", @"Custom#3", nil];
    for (int i=0;i<[arr count];i++) {
        [arrInfoFiledNames addObject:[arr objectAtIndex:i]];
    }
    
    photoName = @"";
    photoURL = @"";
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    tapRecognizer.delegate = self;
    [viewTap addGestureRecognizer:tapRecognizer];
    
    removeItemFlag = NO;
    
    imgAvatar.layer.cornerRadius = imgAvatar.frame.size.height / 2.0f;
    imgAvatar.layer.masksToBounds = YES;
    imgAvatar.layer.borderColor = [UIColor colorWithRed:134.0/256.0 green:87.0/256.0 blue:129.0/256.0 alpha:1.0f].CGColor;
    imgAvatar.layer.borderWidth = 1.0f;
    
    txtFirstName.borderStyle = UITextBorderStyleNone;
    txtLastName.borderStyle = UITextBorderStyleNone;
    
    [self layoutSubviews];
    
    [btnDel setImage:[[UIImage imageNamed:@"TrashIcon"] tintImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [btnRemove setImage:[[UIImage imageNamed:@"TrashIcon"] tintImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    
    profileLogoContainerView.hidden = YES;
    profileLogoImageView.layer.cornerRadius = profileLogoImageView.frame.size.height / 2.0f;
    profileLogoImageView.layer.masksToBounds = YES;
    profileLogoImageView.layer.borderWidth = 4.0f;
    profileLogoImageView.layer.borderColor = COLOR_PURPLE_THEME.CGColor;
    profilelogoPreView.hidden = YES;
    UITapGestureRecognizer *tapGestureRecognizerForLogo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideProfileImage)];
    // tapGestureRecognizer.cancelsTouchesInView = NO;
    tapGestureRecognizerForLogo.delegate = self;
    [profilelogoPreView addGestureRecognizer:tapGestureRecognizerForLogo];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [tblInfo deselectRowAtIndexPath:[tblInfo indexPathForSelectedRow] animated:animated];
    [self.navigationController.navigationBar addSubview:navView];
    
    //    CGRect rect = tblInfo.bounds;
    footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
    [tblInfo setTableFooterView:footView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [navView removeFromSuperview];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
	
    footView.frame = CGRectMake(0, 0, 320, kbSize.height);
    
    [tblInfo setTableFooterView:footView];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
	footView.frame = CGRectMake(0, 0, 320, 0);
    
    [tblInfo setTableFooterView:footView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Methods
- (void)layoutSubviews
{
    if (curContactDict) {
        btnInfo.hidden = YES;
        NSURL * imageURL = [NSURL URLWithString:[curContactDict objectForKey:@"photo_url"]];
//        NSData *data = [NSData dataWithContentsOfURL:imageURL];
//        UIImage *profileImage = [[UIImage alloc] initWithData:data];
//        [btnAvatar setImage:profileImage forState:UIControlStateNormal];
        [imgAvatar setImageWithURL:imageURL];
        [profileLogoImageView setImageWithURL:imageURL];
        txtName.text = [NSString stringWithFormat:@"%@", [curContactDict objectForKey:@"first_name"]];
        if ([curContactDict objectForKey:@"middle_name"] != [NSNull null]) {
            if (![[curContactDict objectForKey:@"middle_name"] isEqualToString:@""]) {
                txtName.text = [NSString stringWithFormat:@"%@ %@", txtName.text, [curContactDict objectForKey:@"middle_name"]];
            }
        }
        if ([curContactDict objectForKey:@"is_favorite"]) {
            _btGreyFavorite.selected = [[curContactDict objectForKey:@"is_favorite"] boolValue];
        }
        txtFirstName.text = txtName.text; // Zhun's
        
        if (![[curContactDict objectForKey:@"last_name"] isEqualToString:@""]) {
            txtName.text = [NSString stringWithFormat:@"%@ %@", txtName.text, [curContactDict objectForKey:@"last_name"]];
            txtLastName.text = [NSString stringWithFormat:@"%@", [curContactDict objectForKey:@"last_name"]]; // Zhun's
        }
        txtName.borderStyle = UITextBorderStyleNone;
        
        int type = [[curContactDict objectForKey:@"type"] intValue];
        switch (type) {
            case 0:
                greyType = 10;
                break;
            case 2:
                greyType = 20;
                break;
            case 1:
                greyType = 30;
                break;
            default:
                break;
        }
        label.hidden = YES;
        
        strNotes = [curContactDict objectForKey:@"notes"];
        
        [self setDataSourceFromContactInfo];
    }
    else
    {
        btnDel.hidden = YES;
        btnEdit.hidden = YES;
        
        txtFirstName.hidden = YES;
        txtLastName.hidden = YES;
        [self initDataSource];
    }
    
    [self colorTypeButtons];
}

- (void)colorTypeButtons
{
    [btnEntity setSelected:NO];
    [btnWork setSelected:NO];
    [btnHome setSelected:NO];
    switch (greyType) {
        case 10:
            [btnEntity setSelected:YES];
            break;
        case 20:
            [btnWork setSelected:YES];
            break;
        case 30:
            [btnHome setSelected:YES];
            break;
        default:
            break;
    }
}

// Set flag to YES to change the table to editing state
- (void)showEditPane:(BOOL)flag
{
    if (!flag) {
        btnDone.hidden = YES;
        txtName.borderStyle = UITextBorderStyleNone;
        
        txtFirstName.hidden = NO;
        txtLastName.hidden = NO;
    } else {
        txtName.borderStyle = UITextBorderStyleRoundedRect;
        
        txtFirstName.hidden = YES;
        txtLastName.hidden = YES;
    }
    
    btnEdit.hidden = flag;
    btnDel.hidden = flag;
    //    btnInfo.hidden = flag;
    btnNotes.hidden = flag;
    btnRemove.hidden = !flag;
    btnEditInfo.hidden = !flag;
    
    btnBack.hidden = flag;
    btnClose.hidden = !flag;
    
    [tblInfo setEditing:flag animated:flag];
//    [tblInfo reloadData];
    [self loaddata];
}

- (NSString *)getPrefixForFieldName:(int)fieldIndex
{
    NSString *str = @"";
    switch (fieldIndex) {
        case 0:
        case 1:
            str = @"m. ";
            break;
        case 5:
        case 6:
            str = @"e. ";
            break;
        case 7:
        case 8:
            str = @"a. ";
            break;
        case 2:
        case 3:
        case 4:
            str = @"p. ";
            break;
        case 9:
        case 11:
            str = @"f. ";
            break;
        case 10:
            str = @"b. ";
            break;
        case 12:
            str = @"t. ";
            break;
        case 13:
            str = @"w. ";
            break;
        default:
            break;
    }
    return str;
}

- (NSString *)getFieldType:(int)fieldIndex
{
    NSString *str = @"";
    switch (fieldIndex) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
            str = @"phone";
            break;
        case 5:
        case 6:
            str = @"email";
            break;
        case 9:
            str = @"fax";
            break;
        case 7:
        case 8:
            str = @"address";
            break;
        case 10:
            str = @"date";
            break;
        case 11:
            str = @"facebook";
            break;
        case 12:
            str = @"twitter";
            break;
        case 13:
            str = @"website";
            break;
        case 14:
        case 15:
        case 16:
            str = @"custom";
        default:
            break;
    }
    return str;
}

- (void)navigateToMap:(NSString *)address
{
    //    NSString *str = @"213 Main Street Ann Arbor, MI 48105";
    //    str = @"7617 Brookview Drive Brighton, MI 48116";
    //    address = str;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeClear];
    [geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
        [SVProgressHUD dismiss];
        if (error) {
            NSLog(@"%@", error);
            [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Oh no!  Cannot find the location from the address!"];
        } else {
            
            CLPlacemark *placeMark = [placemarks lastObject];
            
            [self openAppleMap:placeMark.location.coordinate.latitude :placeMark.location.coordinate.longitude];
        }
    }];
}

- (void)openAppleMap:(float)latitude :(float)longitude
{
    [SVGeocoder reverseGeocode:CLLocationCoordinate2DMake(latitude, longitude)
                    completion:^(NSArray *placemarks, NSHTTPURLResponse *urlResponse, NSError *error)
     {
         if (!error)
         {
             MKPlacemark *place = [[MKPlacemark alloc]
                                   initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude)
                                   addressDictionary:nil];
             
             MKMapItem *mapItem = [[MKMapItem alloc]initWithPlacemark:place];
             [mapItem setName:[NSString stringWithFormat:@"%@",[(SVPlacemark*)[placemarks objectAtIndex:0] formattedAddress]]];
             [mapItem openInMapsWithLaunchOptions:nil];
         } else {
             [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Internet Connection Error!"];
         }
         
     }];
}

#pragma mark - WebAPI integration
- (void)addOrUpdateContact
{
    NSString *firstName = @"";
    NSString *lastName = @"";
    NSString *middleName = @"";
    NSArray *arrName = [txtName.text componentsSeparatedByString:@" "];
    
    if ([arrName count]) {
        firstName = [arrName objectAtIndex:0];
        if ([arrName count] == 2) {
            lastName = [arrName objectAtIndex:1];
        } else if ([arrName count] > 2) {
            middleName = [arrName objectAtIndex:1];
            lastName = [txtName.text substringFromIndex:[firstName length] + [middleName length] + 2];
        }
    }
    
    // Zhun's
    txtFirstName.text = @"";
    txtLastName.text = @"";
    
    if (firstName.length > 0)
        txtFirstName.text = firstName;
    if (middleName.length > 0)
        txtFirstName.text = [NSString stringWithFormat:@"%@ %@", txtFirstName.text, middleName];
    if (lastName.length > 0)
        txtLastName.text = lastName;
    
    NSString *type = @"";
    switch (greyType) {
        case 10:
            type = @"0";
            break;
        case 20:
            type = @"2";
            break;
        case 30:
            type = @"1";
            break;
        default:
            break;
    }
    NSString *email = @"";
    
    NSMutableArray *arrFields = [[NSMutableArray alloc] init];
    for (int i =0; i<18; i++) {
        NSMutableDictionary *dict = [arrDataSource objectAtIndex:i];
        if ([dict objectForKey:@"value"]) {
            if (![[dict objectForKey:@"value"] isEqualToString:@""]) {
                if (i == 6) {
                    email = [dict objectForKey:@"value"];
                    continue;
                }
                if (i == 7) {
                    if ([email isEqualToString:@""]) {
                        email = [dict objectForKey:@"value"];
                        continue;
                    }
                }
                
                NSMutableDictionary *field = [NSMutableDictionary dictionary];
                [field setObject:[arrInfoFiledNames objectAtIndex:i]        forKey:@"field_name"];
                [field setObject:[dict objectForKey:@"value"]               forKey:@"field_value"];
                [field setObject:[self getFieldType:i]                      forKey:@"field_type"];
                [arrFields addObject:field];
            }
        }
    }
    
    
    void (^successed)(id responseObject) = ^(id responseObject) {
        NSDictionary *result = responseObject;
        NSLog(@"add grey contact result = %@", result);
        
        if ([[result objectForKey:@"success"] boolValue]) {
            
            [SVProgressHUD dismiss];
 
            [curContactDict setObject:type forKey:@"type"];
            [curContactDict setObject:_btGreyFavorite.selected ? @"1" : @"0" forKey:@"is_favorite"];
            [curContactDict setObject:email forKey:@"email"];
            if (![email isEqualToString:@""]) {
                NSMutableDictionary *field = [NSMutableDictionary dictionary];
                [field setObject:@"Email"        forKey:@"field_name"];
                [field setObject:email           forKey:@"field_value"];
                [field setObject:@"email"        forKey:@"field_type"];
                [arrFields addObject:field];
            }
            [curContactDict setObject:arrFields forKey:@"fields"];
            [curContactDict setObject:firstName forKey:@"first_name"];
            [curContactDict setObject:middleName forKey:@"middle_name"];
            [curContactDict setObject:lastName forKey:@"last_name"];
            [curContactDict setObject:strNotes forKey:@"notes"];
            if (![photoName isEqualToString:@""]) {
                [curContactDict setObject:photoURL forKey:@"photo_url"];
            }
            
            [self showEditPane:NO];
            [_globalData.arrSyncContacts setObject:curContactDict atIndexedSubscript:[_globalData.arrSyncContacts indexOfObject:[AppDelegate sharedDelegate].importDict]];
            [AppDelegate sharedDelegate].importDict = curContactDict;
            [self fitToScroll];
            
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
    [[GreyClient sharedClient] addUpdateGreyContact:[AppDelegate sharedDelegate].sessionId contactID:[curContactDict objectForKey:@"id"] firstName:firstName middleName:middleName lastName:lastName email:email photoName:[photoName isEqualToString:@""] ? nil : photoName notes:strNotes type:type favorite:_btGreyFavorite.selected ? TRUE : FALSE fields:[arrFields count] ? arrFields : nil successed:successed failure:failure];
}

- (void)updateNotes
{
    if (!curContactDict) {
        return;
    }
    NSString *firstName = @"";
    NSString *lastName = @"";
    NSString *middleName = @"";
    NSArray *arrName = [txtName.text componentsSeparatedByString:@" "];
    
    if ([arrName count]) {
        firstName = [arrName objectAtIndex:0];
        if ([arrName count] == 2) {
            lastName = [arrName objectAtIndex:1];
        } else if ([arrName count] > 2) {
            middleName = [arrName objectAtIndex:1];
            lastName = [txtName.text substringFromIndex:[firstName length] + [middleName length] + 2];
        }
    }
    
    NSString *type = @"";
    switch (greyType) {
        case 10:
            type = @"0";
            break;
        case 20:
            type = @"2";
            break;
        case 30:
            type = @"1";
            break;
        default:
            break;
    }
    NSString *email = @"";
    
    NSMutableArray *arrFields = [[NSMutableArray alloc] init];
    for (int i =0; i<18; i++) {
        NSMutableDictionary *dict = [arrDataSource objectAtIndex:i];
        if ([dict objectForKey:@"value"]) {
            if (![[dict objectForKey:@"value"] isEqualToString:@""]) {
                if (i == 6) {
                    email = [dict objectForKey:@"value"];
                    continue;
                }
                if (i == 7) {
                    if ([email isEqualToString:@""]) {
                        email = [dict objectForKey:@"value"];
                        continue;
                    }
                }
                
                NSMutableDictionary *field = [NSMutableDictionary dictionary];
                [field setObject:[arrInfoFiledNames objectAtIndex:i]        forKey:@"field_name"];
                [field setObject:[dict objectForKey:@"value"]               forKey:@"field_value"];
                [field setObject:[self getFieldType:i]                      forKey:@"field_type"];
                [arrFields addObject:field];
            }
        }
    }
    
    void (^successed)(id responseObject) = ^(id responseObject) {
        NSDictionary *result = responseObject;
        
        if ([[result objectForKey:@"success"] boolValue]) {
            
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:@"Uploaded"];
            
            [curContactDict setObject:strNotes forKey:@"notes"];
            
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
    
    [SVProgressHUD showWithStatus:@"Updating..." maskType:SVProgressHUDMaskTypeClear];
//    [[GreyClient sharedClient] updateNotes:[AppDelegate sharedDelegate].sessionId contactID:[curContactDict objectForKey:@"id"] notes:strNotes successed:successed failure:failure];
    [[GreyClient sharedClient] addUpdateGreyContact:[AppDelegate sharedDelegate].sessionId contactID:[curContactDict objectForKey:@"id"] firstName:firstName middleName:middleName lastName:lastName email:email photoName:[photoName isEqualToString:@""] ? nil : photoName notes:strNotes type:type favorite:_btGreyFavorite.selected ? TRUE : FALSE fields:[arrFields count] ? arrFields : nil successed:successed failure:failure];
}

- (void)uploadPhoto
{
    void (^successed)(id responseObject) = ^(id responseObject) {
        NSDictionary *result = responseObject;
        
        NSLog(@"upload photo result = %@", result);
        
        if ([[result objectForKey:@"success"] boolValue]) {
            
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:@"Uploaded"];
            
            photoName = [(NSDictionary *)[result objectForKey:@"data"] objectForKey:@"photo_name"];
            photoURL = [(NSDictionary *)[result objectForKey:@"data"] objectForKey:@"photo_url"];
            
            btnDone.hidden = NO;
            
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
    
    [SVProgressHUD showWithStatus:@"Uploading..." maskType:SVProgressHUDMaskTypeClear];
    [[GreyClient sharedClient] uploadPhoto:[AppDelegate sharedDelegate].sessionId contactID:[curContactDict objectForKey:@"id"] successed:successed failure:failure];
}

- (void)removeContact
{
    void (^successed)(id responseObject) = ^(id responseObject) {
        NSDictionary *result = responseObject;
        
        NSLog(@"remove contact result = %@", result);
        
        if ([[result objectForKey:@"success"] boolValue]) {
            
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:@"Removed"];
            [_globalData.arrSyncContacts removeObject:curContactDict];
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
    
    [SVProgressHUD showWithStatus:@"Removing..." maskType:SVProgressHUDMaskTypeClear];
    [[ContactImporterClient sharedClient] removeSyncContact:[AppDelegate sharedDelegate].sessionId syncContacts:[curContactDict objectForKey:@"contact_id"] successed:successed failure:failure];
}

#pragma mark - Information DataSource
- (void)initDataSource
{
    for (int i=0; i<18; i++) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [arrDataSource addObject:dict];
        if (i == 1 || i == 6 || i == 8) {
            [dict setObject:[NSString stringWithFormat:@"%d", i] forKey:@"name_index"];
            [dict setObject:@"" forKey:@"value"];
            //            [arrDataSource replaceObjectAtIndex:i withObject:dict];
        }
    }
    [tblInfo reloadData];
}

- (void)loaddata
{
    if ([cells count]) {
        [cells removeAllObjects];
    }
    cells = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0 ; i < [self getCountDataSource] + 1; i++) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        
        UIView *selectionColor = [[UIView alloc] init];
        selectionColor.backgroundColor = [UIColor whiteColor];
        cell.selectedBackgroundView = selectionColor;
        
        if (i == 0) {
            [cell addSubview:viewFirstCell];
        } else {
            NSDictionary *dict = (NSDictionary *)[self getDictFromRow:(int)i];
            int nameIndex = [[dict objectForKey:@"name_index"] intValue];
            if (nameIndex == 7 || nameIndex == 8) {
                LPlaceholderTextView *txtField = [[LPlaceholderTextView alloc] initWithFrame:CGRectMake(50, 7, 250, 60)];
                txtField.delegate = self;
                txtField.placeholderColor = [UIColor lightGrayColor];
                [txtField setFont:[UIFont systemFontOfSize:15.0f]];
                
                //To make the border look very close to a UITextField
                [txtField.layer setBorderColor:[[[UIColor lightGrayColor] colorWithAlphaComponent:0.5] CGColor]];
                [txtField.layer setBorderWidth:1.0];
                
                //The rounded corner part, where you specify your view's corner radius:
                txtField.layer.cornerRadius = 5;
                txtField.clipsToBounds = YES;
                
                txtField.tag = 100 *(nameIndex + 1);
                txtField.placeholderText = [arrInfoFiledNames objectAtIndex:nameIndex];
                
                //set text
                [txtField setText:[dict objectForKey:@"value"]];
                if (!tblInfo.editing) {
                    [txtField.layer setBorderWidth:0];
                }
                
                [txtField setTextColor:[UIColor colorWithRed:134.0/256.0 green:87.0/256.0 blue:129.0/256.0 alpha:1.0f]];
                [cell addSubview:txtField];
            } else {
                UITextField *txtField = [[UITextField alloc] initWithFrame:CGRectMake(50, 7, 250, 35)];
                txtField.delegate = self;
                [txtField setFont:[UIFont systemFontOfSize:15.0f]];
                txtField.borderStyle = UITextBorderStyleRoundedRect;
                
                txtField.tag = 100 *(nameIndex + 1);
                [txtField setPlaceholder:(NSString *)[arrInfoFiledNames objectAtIndex:nameIndex]];
                
                txtField.returnKeyType = UIReturnKeyNext;
                if (i == [self getCountDataSource]) { //changed
                    txtField.returnKeyType = UIReturnKeyDone;
                }
                
                txtField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                
                NSString *fieldType = [self getFieldType:nameIndex];
                if ([fieldType isEqualToString:@"phone"]) {
                    txtField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                } else if ([fieldType isEqualToString:@"email"] || [fieldType isEqualToString:@"facebook"]) {
                    txtField.keyboardType = UIKeyboardTypeEmailAddress;
                } else if ([fieldType isEqualToString:@"twitter"]) {
                    txtField.keyboardType = UIKeyboardTypeTwitter;
                } else if ([fieldType isEqualToString:@"date"]) {
                    txtField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                } else if ([fieldType isEqualToString:@"website"]) {
                    txtField.keyboardType = UIKeyboardTypeURL;
                }
                
                UILabel *lblEmail = [[UILabel alloc] initWithFrame:CGRectMake(52, 42, 248, 8)];
                //email label add
                if (nameIndex == 5 || nameIndex == 6) {
                    [lblEmail setFont:[UIFont systemFontOfSize:10.0f]];
                    [lblEmail setTextColor:[UIColor lightGrayColor]];
                    [lblEmail setText:@"include email to invite"];
                    
                    lblEmail.tag = 100 *(nameIndex + 1) + 50;
                    [cell addSubview:lblEmail];
                }
                
                //set text
                if (!tblInfo.editing) {
                    [txtField setText:[NSString stringWithFormat:@"%@%@", [self getPrefixForFieldName:nameIndex], [dict objectForKey:@"value"]]];
                    lblEmail.hidden = YES;
                    txtField.borderStyle = UITextBorderStyleNone;
                } else {
                    [txtField setText:[dict objectForKey:@"value"]];
                }
                
                [txtField setTextColor:[UIColor colorWithRed:134.0/256.0 green:87.0/256.0 blue:129.0/256.0 alpha:1.0f]];
                [cell addSubview:txtField];
            }
            
            NSString *fieldType = [self getFieldType:nameIndex];
            if ([fieldType isEqualToString:@"phone"] || [fieldType isEqualToString:@"email"] || [fieldType isEqualToString:@"address"] || [fieldType isEqualToString:@"website"]) {
                UIView *touchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
                touchView.backgroundColor = [UIColor clearColor];
                touchView.tag = 50 + i;
                
                UITapGestureRecognizer *touchRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchAction:)];
                
                touchRecognizer.delegate = self;
                [touchView addGestureRecognizer:touchRecognizer];
                
                [cell addSubview:touchView];
                
                if (!tblInfo.editing) {
                    touchView.hidden = NO;
                } else {
                    touchView.hidden = YES;
                }
            }
        }
        
        [cells addObject:cell];
    }

    [tblInfo reloadData];
    
    if(tblInfo.editing) { // the delete button is disabled by default since no items are selected
        btnRemove.enabled = false;
    }
}

- (void)setDataSourceFromContactInfo
{
    [arrDataSource removeAllObjects];
    for (int i=0; i<18; i++) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [arrDataSource addObject:dict];
        NSArray *arrFields = [curContactDict objectForKey:@"fields"];
        //for email
        if (![arrFields count]) {
            if (i == 6) {
                if ([curContactDict objectForKey:@"email"] != [NSNull null]) {
                    if (![[curContactDict objectForKey:@"email"] isEqualToString:@""]) {
                        [dict setObject:@"5" forKey:@"name_index"];
                        [dict setObject:[curContactDict objectForKey:@"email"] forKey:@"value"];
                        [arrDataSource replaceObjectAtIndex:i withObject:dict];
                    }
                }
            }
        } else {
            for (int j=0;j<[arrFields count];j++) {
                NSDictionary *field = [arrFields objectAtIndex:j];
                if ([[field objectForKey:@"field_name"] isEqualToString:@"Email"]) {
                    if ([[field objectForKey:@"field_value"] isEqualToString:@""]) {
                        continue;
                    }
                }
                if ([[field objectForKey:@"field_name"] isEqualToString:[arrInfoFiledNames objectAtIndex:i]]) {
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                    [dict setObject:[NSString stringWithFormat:@"%d", i] forKey:@"name_index"];
                    [dict setObject:[field objectForKey:@"field_value"] forKey:@"value"];
                    [arrDataSource replaceObjectAtIndex:i withObject:dict];
                }
            }
        }
        
    }
    
    [self loaddata];
}

- (void)syncDataSource
{
    for (int i=0; i<18; i++) {
        NSMutableDictionary *dict = [arrDataSource objectAtIndex:i];
        if ([dict objectForKey:@"value"]) {
            UIView *viewText = [self.view viewWithTag:100 *([[dict objectForKey:@"name_index"] intValue] + 1)];
            NSString *value = nil;
            if ([viewText isKindOfClass:[UITextField class]]) {
                value = [(UITextField *)viewText text];
            } else if ([viewText isKindOfClass:[LPlaceholderTextView class]]) {
                value = [(LPlaceholderTextView *)viewText text];
            }
            if (value) {
                [dict setObject:value forKey:@"value"];
            }
        }
    }
}

//- (void)addDataSource:(NSMutableArray *)arrAddItems
//{
//    for (int i=0; i<17; i++) {
//        for (NSString *infoFieldName in arrAddItems) {
//            if ([infoFieldName isEqualToString:[arrInfoFiledNames objectAtIndex:i]]) {
//                NSMutableDictionary *dict = [arrDataSource objectAtIndex:i];
//                [dict setObject:[NSString stringWithFormat:@"%d", i] forKey:@"name_index"];
//                [dict setObject:@"" forKey:@"value"];
//                [arrAddInfoItems removeObject:infoFieldName];
//            }
//        }
//    }
//    [tblInfo reloadData];
//}

- (int)getCountDataSource
{
    int count = 0;
    for (int i=0; i<18; i++) {
        NSMutableDictionary *dict = [arrDataSource objectAtIndex:i];
        if ([dict objectForKey:@"value"]) {
            count++;
        }
    }
    return count;
}

- (NSMutableDictionary *)getDictFromRow:(int)row
{
    int count = 0;
    for (int i=0; i<18; i++) {
        NSMutableDictionary *dict = [arrDataSource objectAtIndex:i];
        if ([dict objectForKey:@"value"]) {
            count++;
            if (count == row) {
                return dict;
            }
        }
    }
    return nil;
}

- (void)removeFieldsFromDataSource
{
    NSArray *selectedRows = [tblInfo indexPathsForSelectedRows];
    NSMutableArray *arrTemp = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexPath in selectedRows) {
        NSLog(@"remove item row : %ld", (long)indexPath.row);
        NSMutableDictionary *dict = [self getDictFromRow:indexPath.row];
        [arrTemp addObject:dict];
    }
    for (int i=0; i<[arrTemp count]; i++) {
        NSMutableDictionary *tempDict = [arrTemp objectAtIndex:i];
        int nameIndex = [[tempDict objectForKey:@"name_index"] intValue];
        NSMutableDictionary *dict = [arrDataSource objectAtIndex:nameIndex];
        [dict removeAllObjects];
        [arrDataSource replaceObjectAtIndex:nameIndex withObject:dict];
    }
    removeItemFlag = YES;
}

- (BOOL)isEmptyDatSource
{
    for (int i=0; i<18; i++) {
        NSMutableDictionary *dict = [arrDataSource objectAtIndex:i];
        if (![[(UITextField *)[self.view viewWithTag:100 *([[dict objectForKey:@"name_index"] intValue] + 1)] text] isEqualToString:@""]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - tableview scroll up down
- (void)fitToScroll
{
    [tblInfo scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - resign textfield
- (void)tapView:(UITapGestureRecognizer *)gestureRecognizer
{
    //    UIView *hitView = [gestureRecognizer.view hitTest:[gestureRecognizer locationInView:gestureRecognizer.view] withEvent:nil];
    //    if (hitView == viewTap || [hitView isKindOfClass:[UITableViewCellContentView class]]) {
    [self.view findAndResignFirstResponder];
    //        [self fitToScroll];
    //    }
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.returnKeyType == UIReturnKeyDone) {
        [textField resignFirstResponder];
        [self fitToScroll];
        return YES;
    }
    
    UITableViewCell *cell = (UITableViewCell *)[[textField superview] superview];
    
    NSDictionary *dict;
    if (textField.tag == 99) {
        dict = [self getDictFromRow:1];
    } else {
        dict = [self getDictFromRow:(int)[tblInfo indexPathForCell:cell].row + 1];
    }
    UIView *view = [self.view viewWithTag:100 *([[dict objectForKey:@"name_index"] intValue] + 1)];
    
    if ([view isKindOfClass:[UITextField class]]) {
        [(UITextField *)view becomeFirstResponder];
        return YES;
    } else if ([view isKindOfClass:[UITextView class]]) {
        [(UITextView *)view becomeFirstResponder];
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (!tblInfo.editing) {
        return NO;
    }
    if (textField.tag == 99) {
        [self fitToScroll];
        return YES;
    }
    
    UITableViewCell *cell = (UITableViewCell *)[[textField superview] superview];
    
    footView.frame = CGRectMake(0, 0, 320, 170);
    
    [tblInfo setTableFooterView:footView];
    
    [tblInfo scrollToRowAtIndexPath:[tblInfo indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [self syncDataSource];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *text = textField.text;
    //    NSString *newText = [text stringByReplacingCharactersInRange:range withString:string];
    
    int newLength = (int)[text length] - (int)range.length + (int)string.length;
    if (textField.tag == 99) {
        if (newLength == 0) {
            btnDone.hidden = YES;
            return YES;
        } else {
            if ([self isEmptyDatSource]) {
                btnDone.hidden = YES;
            } else btnDone.hidden = NO;
            return YES;
        }
    }
    
    if ([txtName.text isEqualToString:@""]) {
        btnDone.hidden = YES;
        return YES;
    }
    
    if (newLength == 0) {
        if ([self isEmptyDatSource]) {
            btnDone.hidden = YES;
            return YES;
        }
    }
    
    btnDone.hidden = NO;
    return YES;
}

#pragma mark - UITextView Delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    int newLength = (int)textView.text.length - (int)range.length + (int)text.length;
    if (newLength == 0) {
        if ([self isEmptyDatSource]) {
            btnDone.hidden = YES;
            return YES;
        }
    }
    
    btnDone.hidden = NO;
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (!tblInfo.editing) {
        return NO;
    }
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    UITableViewCell *cell = (UITableViewCell *)[[textView superview] superview];
    
    NSLog(@"index = %d, count = %d", (int)[tblInfo indexPathForCell:cell].row, [self getCountDataSource]);
    
    footView.frame = CGRectMake(0, 0, 320, 170);
    
    [tblInfo setTableFooterView:footView];
    
    [tblInfo scrollToRowAtIndexPath:[tblInfo indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [self syncDataSource];
    //    [self fitToScroll];
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self getCountDataSource] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 188;
    }
    int nameIndex = [[[self getDictFromRow:(int)(indexPath.row)] objectForKey:@"name_index"] intValue];
    if (nameIndex == 7 || nameIndex == 8) {
        return 75;
    }
    return 50.0f;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return NO;
    }
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cells[indexPath.row];
    /*
    UITableViewCell *cell = [tblInfo dequeueReusableCellWithIdentifier:@"TableViewCellIdentifier"];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] init];
    }
    
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor whiteColor];
    cell.selectedBackgroundView = selectionColor;
    
    if (indexPath.row == 0) {
        [cell addSubview:viewFirstCell];
    } else {
        NSDictionary *dict = [self getDictFromRow:indexPath.row];
        int nameIndex = [[dict objectForKey:@"name_index"] intValue];
        if (nameIndex == 7 || nameIndex == 8) {
            LPlaceholderTextView *txtField = [[LPlaceholderTextView alloc] initWithFrame:CGRectMake(50, 7, 250, 60)];
            txtField.delegate = self;
            txtField.placeholderColor = [UIColor lightGrayColor];
            [txtField setFont:[UIFont systemFontOfSize:15.0f]];
            
            //To make the border look very close to a UITextField
            [txtField.layer setBorderColor:[[[UIColor lightGrayColor] colorWithAlphaComponent:0.5] CGColor]];
            [txtField.layer setBorderWidth:1.0];
            
            //The rounded corner part, where you specify your view's corner radius:
            txtField.layer.cornerRadius = 5;
            txtField.clipsToBounds = YES;
            
            txtField.tag = 100 *(nameIndex + 1);
            txtField.placeholderText = [arrInfoFiledNames objectAtIndex:nameIndex];
            
            //set text
            [txtField setText:[dict objectForKey:@"value"]];
            if (!tblInfo.editing) {
                [txtField.layer setBorderWidth:0];
            }
            
            [txtField setTextColor:[UIColor colorWithRed:134.0/256.0 green:87.0/256.0 blue:129.0/256.0 alpha:1.0f]];
            
            [cell addSubview:txtField];
        } else {
            UITextField *txtField = [[UITextField alloc] initWithFrame:CGRectMake(50, 7, 250, 35)];
            txtField.delegate = self;
            [txtField setFont:[UIFont systemFontOfSize:15.0f]];
            txtField.borderStyle = UITextBorderStyleRoundedRect;
            
            txtField.tag = 100 *(nameIndex + 1);
            [txtField setPlaceholder:(NSString *)[arrInfoFiledNames objectAtIndex:nameIndex]];
            
            txtField.returnKeyType = UIReturnKeyNext;
            if (indexPath.row == [self getCountDataSource]) { //changed
                txtField.returnKeyType = UIReturnKeyDone;
            }
            
            txtField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            
            NSString *fieldType = [self getFieldType:nameIndex];
            if ([fieldType isEqualToString:@"phone"]) {
                txtField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            } else if ([fieldType isEqualToString:@"email"] || [fieldType isEqualToString:@"facebook"]) {
                txtField.keyboardType = UIKeyboardTypeEmailAddress;
            } else if ([fieldType isEqualToString:@"twitter"]) {
                txtField.keyboardType = UIKeyboardTypeTwitter;
            } else if ([fieldType isEqualToString:@"date"]) {
                txtField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            } else if ([fieldType isEqualToString:@"website"]) {
                txtField.keyboardType = UIKeyboardTypeURL;
            }
            
            UILabel *lblEmail = [[UILabel alloc] initWithFrame:CGRectMake(52, 42, 248, 8)];
            //email label add
            if (nameIndex == 5 || nameIndex == 6) {
                [lblEmail setFont:[UIFont systemFontOfSize:10.0f]];
                [lblEmail setTextColor:[UIColor lightGrayColor]];
                [lblEmail setText:@"include email to invite"];
                
                lblEmail.tag = 100 *(nameIndex + 1) + 50;
                [cell addSubview:lblEmail];
            }
            
            //set text
            if (!tblInfo.editing) {
                [txtField setText:[NSString stringWithFormat:@"%@%@", [self getPrefixForFieldName:nameIndex], [dict objectForKey:@"value"]]];
                lblEmail.hidden = YES;
                txtField.borderStyle = UITextBorderStyleNone;
            } else {
                [txtField setText:[dict objectForKey:@"value"]];
            }
            
            [txtField setTextColor:[UIColor colorWithRed:110.0f/255.0f green:75.0f/255.0f blue:154.0f/255.0f alpha:1.0f]];
            
            [cell addSubview:txtField];
        }
        
        NSString *fieldType = [self getFieldType:nameIndex];
        if ([fieldType isEqualToString:@"phone"] || [fieldType isEqualToString:@"email"] || [fieldType isEqualToString:@"address"] || [fieldType isEqualToString:@"website"]) {
            UIView *touchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
            touchView.backgroundColor = [UIColor clearColor];
            touchView.tag = 50 + indexPath.row;
            
            UITapGestureRecognizer *touchRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchAction:)];
            
            touchRecognizer.delegate = self;
            [touchView addGestureRecognizer:touchRecognizer];
            
            [cell addSubview:touchView];
            
            if (!tblInfo.editing) {
                touchView.hidden = NO;
            } else {
                touchView.hidden = YES;
            }
        }
    }
    
    return cell;
     */
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!tblInfo.editing || indexPath.row == 0) { // deselect rows when not editing and first row
        [tblInfo deselectRowAtIndexPath:indexPath animated:NO];
    } else { // when editing, determinate the enabled state of the remove button
        btnRemove.enabled = ([tblInfo indexPathsForSelectedRows].count > 0);
    }

    [self tapView:nil];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tblInfo.editing) { // when editing, determinate the enabled state of the remove button
        btnRemove.enabled = ([tblInfo indexPathsForSelectedRows].count > 0);
    }
}

#pragma mark - UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    image = [image fixOrientation];
    
    image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(640, 640) interpolationQuality:0];

    NSLog(@"image size = %@", NSStringFromCGSize(image.size));
    if (![UIImageJPEGRepresentation(image, 0.5f) writeToFile:TEMP_IMAGE_PATH atomically:YES]) {
        [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Oh no!  Failed to save information. Please try again."];
        return;
    }
//    [btnAvatar setImage:image forState:UIControlStateNormal];
    [imgAvatar setImage:image];
    [profileLogoImageView setImage:image];
    [self uploadPhoto];
    [picker dismissViewControllerAnimated:YES completion:^(void){
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex == 2) {
        [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
        return;
    }
    
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    
    switch (buttonIndex) {
        case 0:
            imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imgPicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
            break;
        case 1:
            imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imgPicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
            break;
        default:
            break;
    }
    
    imgPicker.delegate = self;
    
    [self presentViewController:imgPicker animated:YES completion:nil];
    
    [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        switch (alertView.tag) {
            case 1:
                [self removeContact];
                break;
            case 2: // when saving remove blank fields
                [self syncDataSource];
                
                for (int i=0; i<18; i++) {
                    NSMutableDictionary *dict = [arrDataSource objectAtIndex:i];
                    if ([dict objectForKey:@"value"] && [[dict objectForKey:@"value"] isEqualToString:@""])
                        [arrDataSource replaceObjectAtIndex:i withObject:@{}];
                }
                
                [self addOrUpdateContact];
                break;
            case 3:
                [self removeFieldsFromDataSource];
                [self addOrUpdateContact];
                break;
            default:
                break;
        }
    }
}

#pragma mark - MFMailComposerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0)
{
    if ((result == MFMailComposeResultFailed) && (error != NULL)) {
        [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Oh no!  Cannot send mail.  Please try again."];
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Custom Actions
- (void)touchAction:(UITapGestureRecognizer *)gestureRecognizer
{
    UIView *touchView = gestureRecognizer.view;
    NSDictionary *dict = [self getDictFromRow:touchView.tag - 50];
    NSString *fieldType = [self getFieldType:[[dict objectForKey:@"name_index"] intValue]];
    NSString *fieldValue = [dict objectForKey:@"value"];
    [self touchAction:fieldType value:fieldValue];
}
- (void)touchAction:(NSString *)fieldType value:(NSString *)value
{
    if ([fieldType isEqualToString:@"phone"]) {
        NSString* urlString = [NSString stringWithFormat: @"tel://%@", [CommonMethods removeNanString:value]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    } else if ([fieldType isEqualToString:@"email"]) {
        if(![MFMailComposeViewController canSendMail])
        {
            [[[UIAlertView alloc] initWithTitle:@"No Mail Accounts" message:@"You don't have a mail account configured, please configure to send email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            return;
        }
        
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        
        controller.mailComposeDelegate = self;
        
        [controller setMessageBody:@"" isHTML:YES];
        [controller setToRecipients:[NSArray arrayWithObject:value]];
        
        controller.modalPresentationStyle = UIModalPresentationFormSheet;
        [self.navigationController presentViewController:controller animated:YES completion:nil];
    } else if ([fieldType isEqualToString:@"address"]) {
        [self navigateToMap:value];
    } else if ([fieldType isEqualToString:@"website"]) {
        NSLog(@"ddd = %@", [value substringToIndex:4]);
        if (![[value substringToIndex:4] isEqualToString:@"http"]) {
            value = [NSString stringWithFormat:@"http://%@", value];
        }
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:value]];
    }
}

#pragma mark - Actions
- (IBAction)onAvatar:(id)sender
{
    if (!tblInfo.editing) {
        profilelogoPreView.hidden = NO;
        CATransition *transition = [CATransition animation];
        transition.duration = 1.0f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionReveal;
        [profileLogoContainerView.layer addAnimation:transition forKey:nil];
        profileLogoContainerView.hidden = NO;
        
        return;
    }
    if (!tblInfo.editing && curContactDict) {
        return;
    }
    [self.view findAndResignFirstResponder];
    [self fitToScroll];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Add your photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Take a Photo" otherButtonTitles:@"Photo From Gallery", nil];
    [actionSheet showInView:self.view];
}

- (IBAction)onType:(id)sender
{
    if (!tblInfo.editing) {
        return;
    }
    UIButton *btnType = (UIButton *)sender;
    if (greyType == btnType.tag) {
        return;
    }
    
    btnDone.hidden = NO;
    greyType = btnType.tag;
    label.hidden = YES;
    [self colorTypeButtons];
}

- (IBAction)onDel:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GINKO" message:@"Do you want to permanently delete this contact from the GINKO address book?" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
    alert.tag = 1;
    [alert show];
}

- (IBAction)onInfo:(id)sender
{
    [self.view findAndResignFirstResponder];
    GreyInfoController *vc = [[GreyInfoController alloc] initWithNibName:@"GreyInfoController" bundle:nil];
    [vc setParentController:self];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)onNotes:(id)sender
{
    [self.view findAndResignFirstResponder];
    GreyAddNotesController *vc = [[GreyAddNotesController alloc] initWithNibName:@"GreyAddNotesController" bundle:nil];
    [vc setParentController:self];
    if (![strNotes isEqualToString:@""]) {
        vc.strNotes = strNotes;
    }
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)onRemove:(id)sender
{
    [self.view findAndResignFirstResponder];
    
    NSLog(@"%@", tblInfo.indexPathsForSelectedRows);
    
    if (![[tblInfo indexPathsForSelectedRows] count]) {
        return;
    }
    
    if ([[tblInfo indexPathsForSelectedRows] count] == [self getCountDataSource]) {
        [CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Oops!  Name and at least one other field required!"];
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GINKO" message:@"Do you want to delete the selected field(s)?" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
    alert.tag = 3;
    [alert show];

    //    [self fitToScroll];
    //    [self showEditPane:NO];
}

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onDone:(id)sender
{
    [self.view findAndResignFirstResponder];
    if (greyType == 0) {
        [CommonMethods showAlertUsingTitle:@"Ginko" andMessage:@"Oops!  You must select a category to import contact!"];
        return;
    }
    NSString *name = self.txtName.text;
    name = [name stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    if (!name.length) {
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:MESSAGE_BLANK_CONTACT];
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:@"Do you want to make changes to this contact's info?" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
    alert.tag = 2;
    [alert show];
    return;
}


- (IBAction)onEdit:(id)sender
{
//weird
//    tempDataSource = (NSMutableArray *)CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (CFPropertyListRef)arrDataSource, kCFPropertyListMutableContainers);
    tempDataSource = (NSMutableArray *)CFBridgingRelease(CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (CFPropertyListRef)arrDataSource, kCFPropertyListMutableContainers));
    //    if ([tempDataSource count]) {
    //        [tempDataSource removeAllObjects];
    //    }
    //    for (int i=0; i<[arrDataSource count]; i++) {
    //        NSMutableArray *arrItem = [[NSMutableArray alloc] init];
    //        NSMutableArray *arrOrigin = [arrDataSource objectAtIndex:i];
    //        for (NSMutableDictionary *dict in arrOrigin) {
    //            [arrItem addObject:dict];
    //        }
    //        [tempDataSource addObject:arrItem];
    //    }
    [self showEditPane:YES];
}

- (IBAction)onClose:(id)sender
{
    [self.view findAndResignFirstResponder];
//    arrDataSource = (NSMutableArray *)CFBridgingRelease(CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (CFPropertyListRef)tempDataSource, kCFPropertyListMutableContainers));
    arrDataSource = (NSMutableArray *)CFBridgingRelease(CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (CFPropertyListRef)tempDataSource, kCFPropertyListMutableContainers));
    
    NSString *firstName = [curContactDict objectForKey:@"first_name"];
    NSString *middleName = [curContactDict objectForKey:@"middle_name"];
    NSString *lastName = [curContactDict objectForKey:@"last_name"];
    
    txtName.text = @"";
    txtFirstName.text = @"";
    txtLastName.text = @"";
    
    if (firstName.length > 0)
    {
        txtName.text = firstName;
        txtFirstName.text = firstName;
    }
    if (middleName.length > 0)
    {
        txtName.text = [NSString stringWithFormat:@"%@ %@", txtName.text, middleName];
        txtFirstName.text = [NSString stringWithFormat:@"%@ %@", txtFirstName.text, middleName];
    }
    if (lastName.length > 0)
    {
        txtName.text = [NSString stringWithFormat:@"%@ %@", txtName.text, lastName];
        txtLastName.text = lastName;
    }
    
    //    if ([arrDataSource count]) {
    //        [arrDataSource removeAllObjects];
    //    }
    //    for (int i=0; i<[tempDataSource count]; i++) {
    //        NSMutableArray *arrItem = [[NSMutableArray alloc] init];
    //        NSMutableArray *arrOrigin = [tempDataSource objectAtIndex:i];
    //        for (NSMutableDictionary *dict in arrOrigin) {
    //            [arrItem addObject:dict];
    //        }
    //        [arrDataSource addObject:arrItem];
    //    }
    //    [self fitToScroll];
    [self showEditPane:NO];
}
- (IBAction)onFavorite:(id)sender {
    
    _btGreyFavorite.selected = !_btGreyFavorite.selected;
    if (!btnEdit.hidden) {
        if (_btGreyFavorite.selected) {
            [appDelegate addFavoriteContact:[curContactDict objectForKey:@"contact_id"] contactType:@"2"];
        }else{
            [appDelegate removeFavoriteContact:[curContactDict objectForKey:@"contact_id"] contactType:@"2"];
        }
    }
}
- (IBAction)onCloseProfileView:(id)sender {
    
    CATransition *transition = [CATransition animation];
    transition.duration = 2.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [profileLogoContainerView.layer addAnimation:transition forKey:nil];
    profilelogoPreView.hidden = YES;
    profileLogoContainerView.hidden = YES;
}
- (void)hideProfileImage{
    CATransition *transition = [CATransition animation];
    transition.duration = 2.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [profileLogoContainerView.layer addAnimation:transition forKey:nil];
    profilelogoPreView.hidden = YES;
    profileLogoContainerView.hidden = YES;
}
@end
