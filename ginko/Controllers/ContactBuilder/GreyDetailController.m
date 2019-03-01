//
//  GreyDetailController.m
//  GINKO
//
//  Created by mobidev on 5/20/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import "GreyDetailController.h"
#import "GreyInfoController.h"
#import "GreyAddNotesController.h"
#import "ContactBuilderClient.h"
#import "LPlaceholderTextView.h"
#import "GreyClient.h"
#import "UIImage+Resize.h"
#import "MapViewController.h"
#import "SVGeocoder.h"
#import "UIImageView+AFNetworking.h"
#import <AVFoundation/AVFoundation.h>

#import "UIImage+Tint.h"

#import "PreviewFieldCell.h"
#import "FieldTableTextViewCell.h"
#import "FieldTableCell.h"
#import "AddFieldCell.h"

#import "ContactImporterClient.h"

@interface GreyDetailController ()<TTTAttributedLabelDelegate,FieldTableCellDelegate, FieldTableTextViewCellDelegate,AddFieldCellDelegate,UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
{
    BOOL isSelectedViewAddFields;
    
    BOOL _keyboardShown;
    int greyType;
    NSMutableArray *tempDataSource;
    NSMutableArray *arrInfoFiledNames;
    
    NSMutableArray *company;
    NSMutableArray *phones;
    NSMutableArray *emails;
    NSMutableArray *addresses;
    NSMutableArray *hours;
    NSMutableArray *birthday;
    NSMutableArray *socials;
    NSMutableArray *website;
    NSMutableArray *customs;
    
    NSMutableArray *sections;
    
    MBProgressHUD *_downloadProgressHUD; // Download progress hud for video
    
    BOOL _isViewMore;
    
    BOOL _shouldShowMore;
    NSIndexPath *_lastIndexPath;
    
    BOOL _didDetermineShowMore;
    
    BOOL _didFinishLayout;
    
    NSMutableArray *_tables;
    
    // width and height constraint for table
    NSLayoutConstraint *_tableWidth, *_tableHeight;
    
    
    UIImage *newImage;
    BOOL removedImage;
    
    NSString *photoName;
    
    
    // All field names (_allFieldNames - _fieldSelections)
    NSArray *_allFieldNames;
    // int array: 0: not included, 1: included, 2: mandatory and cannot be deleted
    // array of array
    NSMutableArray *_fieldSelectionsArray;
    // selected field names
    // array of array
    NSMutableArray *_fieldNamesArray;
    
    // Real field values
    // array of dictionary
    NSMutableArray *_fieldValuesArray;
    
    // field names, number of rows in add field table
    NSMutableArray *_addFieldNames;
    
    // 0: doesnt have more fields, 1: have one field, 2: have two field
    NSMutableArray *_addFieldNameValues;

    // index path that should be first responder
    NSIndexPath *_nextIndexPathBeFirstResponder;
    
    BOOL _addressConfirmed;
    CLLocation *_location;
    
    NSMutableArray *selectedRowsArray;
     NSIndexPath *currentIndexCell;
    
    BOOL isFavoriteStatus;
}
@end

@implementation GreyDetailController
@synthesize arrDataSource;
@synthesize curContactDict, strNotes;
@synthesize navView, viewTap, viewFirstCell;
@synthesize btnAvatar, imgAvatar, btnEdit, btnDel, btnEntity, btnHome, btnInfo, btnEditInfo, btnNotes, btnRemove, btnWork, btnBack, btnClose, btnDone, btnDoneReal, label, txtName, txtFirstName, txtLastName;
@synthesize isEditing, isContactFromBackup;

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
    // self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:230.0/256.0 green:1.0f blue:190.0/256.0 alpha:1.0f];
    
    // hide add field at first
    _addFieldView.hidden = YES;
    profileLogoContainerView.hidden = YES;
    profileLogoImageView.layer.cornerRadius = profileLogoImageView.frame.size.height / 2.0f;
    profileLogoImageView.layer.masksToBounds = YES;
    profileLogoImageView.layer.borderWidth = 4.0f;
    profileLogoImageView.layer.borderColor = [UIColor grayColor].CGColor;
    profilelogoPreView.hidden = YES;
    UITapGestureRecognizer *tapGestureRecognizerForLogo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideProfileImage)];
    // tapGestureRecognizer.cancelsTouchesInView = NO;
    tapGestureRecognizerForLogo.delegate = self;
    [profilelogoPreView addGestureRecognizer:tapGestureRecognizerForLogo];
    isSelectedViewAddFields = NO;
    
    isFavoriteStatus = NO;
    
    lblContacttype.hidden = YES;
    
    imgAvatar.layer.cornerRadius = imgAvatar.frame.size.height / 2.0f;
    imgAvatar.layer.masksToBounds = YES;
    imgAvatar.layer.borderColor = [UIColor grayColor].CGColor;
    imgAvatar.layer.borderWidth = 1.0f;
    
    txtFirstName.borderStyle = UITextBorderStyleNone;
    txtLastName.borderStyle = UITextBorderStyleNone;
    
    arrDataSource = [[NSMutableArray alloc] init];
    currentIndexCell = nil;
    _allFieldNames = @[@"Company", @"Mobile", @"Mobile#2", @"Mobile#3", @"Phone", @"Phone#2", @"Phone#3", @"Fax", @"Email", @"Email#2", @"Address", @"Address#2", @"Hours", @"Birthday", @"Facebook", @"Twitter", @"LinkedIn", @"Website", @"Custom", @"Custom#2", @"Custom#3"];
    
    selectedRowsArray = [[NSMutableArray alloc] init];
    
    [self layoutSubviews];
    
    //[btnRemove setImage:[[UIImage imageNamed:@"TrashIcon"] tintImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    //[btnDel setImage:[[UIImage imageNamed:@"TrashIcon"] tintImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    
    
    // set content mode for image view
    imgAvatar.contentMode = UIViewContentModeScaleAspectFill;
    
    _tables = [NSMutableArray new];
    UITableView *table = [[UITableView alloc] initWithFrame:_greyDetailsScrollView .bounds style:UITableViewStylePlain];
    table.translatesAutoresizingMaskIntoConstraints = NO;
    table.delegate = self;
    table.dataSource = self;
    [_greyDetailsScrollView addSubview:table];
    [_tables addObject:table];
    
    NSDictionary *viewsDic = @{@"table": table};
    
    [_greyDetailsScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[table]|" options:kNilOptions metrics:0 views:viewsDic]];
    [_greyDetailsScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[table]|" options:kNilOptions metrics:0 views:viewsDic]];
    _tableWidth = [NSLayoutConstraint constraintWithItem:table attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:320];
    _tableHeight = [NSLayoutConstraint constraintWithItem:table attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:self.view.bounds.size.height];
    [table addConstraint:_tableWidth];
    [table addConstraint:_tableHeight];
    
    // automatic row calculation
    table.rowHeight = UITableViewAutomaticDimension;
    _addFieldTable.rowHeight = UITableViewAutomaticDimension;
    
    // estimation height is 44
    table.estimatedRowHeight = 44;
    _addFieldTable.estimatedRowHeight = 44;
    
    // table has no cell separator
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    _addFieldTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // set wallpaper image and name view as table header view
    table.tableHeaderView = viewFirstCell;
    if (!isEditing) {
        [table registerNib:[UINib nibWithNibName:@"PreviewFieldCell" bundle:nil] forCellReuseIdentifier:@"PreviewFieldCell"];
    }
    
    
    // add field table background is clear color
    _addFieldTable.backgroundColor = [UIColor clearColor];
    
    _isViewMore = NO;
    
    [self reloadGreyDetails];
    
    
    _nextIndexPathBeFirstResponder = nil;

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    // tapGestureRecognizer.cancelsTouchesInView = NO;
    tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}
- (void)viewDidLayoutSubviews {
    _tableWidth.constant = CGRectGetWidth(_greyDetailsScrollView.bounds);
    _tableHeight.constant = CGRectGetHeight(_greyDetailsScrollView.bounds);
}

- (void)reloadGreyDetails {
    
    // initialize value dictionary array
    _fieldValuesArray = [NSMutableArray new];
    //
    [_fieldValuesArray addObject:[NSMutableDictionary new]];
    
    _fieldNamesArray = [NSMutableArray new];
    
    [_fieldNamesArray addObject:[NSMutableArray new]];
    
    // selection array
    _fieldSelectionsArray = [NSMutableArray new];
    
    [_fieldSelectionsArray addObject:[NSMutableArray new]];
    
    NSArray *fieldsArray;
    if (curContactDict) {
        fieldsArray = curContactDict[@"fields"];
    }
    
    for (NSString *fieldName in _allFieldNames) {
        if ([fieldName isEqualToString:@"Mobile"] || [fieldName isEqualToString:@"Email"] || [fieldName isEqualToString:@"Address"])
            [_fieldSelectionsArray[0] addObject:@1];
        else
            [_fieldSelectionsArray[0] addObject:@0];
    }
    
    if (fieldsArray && fieldsArray.count > 0) { // if edit for existing
        for (NSDictionary *fieldDic in fieldsArray) {
            NSString *fieldName = fieldDic[@"field_name"];
            
            NSUInteger index = [_allFieldNames indexOfObject:fieldName];
            if (index != NSNotFound) {
                _fieldSelectionsArray[0][index] = @1;
                _fieldValuesArray[0][fieldName] = fieldDic[@"field_value"];
            }
        }
        
        if (!_fieldValuesArray[0][@"Mobile"])   // if not exist
            _fieldSelectionsArray[0][[_allFieldNames indexOfObject:@"Mobile"]] = @0;
        
        if (!_fieldValuesArray[0][@"Email"])    // if not exist
            _fieldSelectionsArray[0][[_allFieldNames indexOfObject:@"Email"]] = @0;
        
        if (!_fieldValuesArray[0][@"Address"])    // if not exist
            _fieldSelectionsArray[0][[_allFieldNames indexOfObject:@"Address"]] = @0;
    }
    
    [self calculateFieldNames:0];
    [self calculateAddFieldNames:0];
    
    // parse fields
    company = [NSMutableArray new];
    phones = [NSMutableArray new];
    emails = [NSMutableArray new];
    addresses = [NSMutableArray new];
    hours = [NSMutableArray new];
    birthday = [NSMutableArray new];
    socials = [NSMutableArray new];
    website = [NSMutableArray new];
    customs = [NSMutableArray new];
    
    sections = [NSMutableArray new];
    
    //NSArray *allFields = @[@"Mobile", @"Mobile#2", @"Mobile#3", @"Phone", @"Phone#2", @"Phone#3", @"Fax", @"Email", @"Email#2", @"Address", @"Address#2", @"Hours", @"Birthday", @"Facebook", @"Twitter", @"LinkedIn", @"Website", @"Custom", @"Custom#2", @"Custom#3"];
    
    for (NSString *fieldName in _allFieldNames) {
        NSArray *filteredArray = [fieldsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"field_name == %@", fieldName]];
        if (filteredArray.count > 0) {
            NSString *fieldType = [self getFieldTypeForFieldName:fieldName];
            
            if ([fieldType isEqualToString:@"company"] || [fieldType isEqualToString:@"company"]) {
                [company addObject:filteredArray[0]];
            } else if ([fieldType isEqualToString:@"mobile"] || [fieldType isEqualToString:@"phone"]) {
                [phones addObject:filteredArray[0]];
            } else if ([fieldType isEqualToString:@"fax"]) {
                [phones addObject:filteredArray[0]];
            } else if ([fieldType isEqualToString:@"email"]) {
                [emails addObject:filteredArray[0]];
            } else if ([fieldType isEqualToString:@"address"]) {
                [addresses addObject:filteredArray[0]];
            } else if ([fieldType isEqualToString:@"hours"]) {
                [hours addObject:filteredArray[0]];
            } else if ([fieldType isEqualToString:@"date"]) {
                [birthday addObject:filteredArray[0]];
            } else if ([fieldType isEqualToString:@"facebook"] || [fieldType isEqualToString:@"twitter"] || [fieldType isEqualToString:@"linkedin"]) {
                [socials addObject:filteredArray[0]];
            } else if ([fieldType isEqualToString:@"url"]) {
                [website addObject:filteredArray[0]];
            } else if ([fieldType isEqualToString:@"custom"]) {
                [customs addObject:filteredArray[0]];
            }
        }
    }
    if (company.count > 0) {
        [sections addObject:company];
    }
    if (phones.count > 0) {
        [sections addObject:phones];
    }
    if (emails.count > 0) {
        [sections addObject:emails];
    }
    if (addresses.count > 0) {
        [sections addObject:addresses];
    }
    if (hours.count > 0) {
        [sections addObject:hours];
    }
    
    if (birthday.count > 0) {
        [sections addObject:birthday];
    }
    if (socials.count > 0) {
        [sections addObject:socials];
    }
    if (website.count > 0) {
        [sections addObject:website];
    }
    if (customs.count > 0) {
        [sections addObject:customs];
    }
    
    if (curContactDict)
        [((UITableView *)_tables[0]) reloadData];

}
- (void)calculateFieldNames:(NSInteger)index {
    if ([_fieldSelectionsArray[index][[_allFieldNames indexOfObject:@"Email"]] intValue] == 0 && [_fieldSelectionsArray[index][[_allFieldNames indexOfObject:@"Address"]] intValue] == 0) { // if email and address is deleted, mobile cannot be deleted
        _fieldSelectionsArray[index][[_allFieldNames indexOfObject:@"Mobile"]] = @2;
    }
    
    if ([_fieldSelectionsArray[index][[_allFieldNames indexOfObject:@"Mobile"]] intValue] == 0 && [_fieldSelectionsArray[index][[_allFieldNames indexOfObject:@"Address"]] intValue] == 0) { // if mobile and address is deleted, email cannot be deleted
        _fieldSelectionsArray[index][[_allFieldNames indexOfObject:@"Email"]] = @2;
    }
    
    if ([_fieldSelectionsArray[index][[_allFieldNames indexOfObject:@"Email"]] intValue] == 0 && [_fieldSelectionsArray[index][[_allFieldNames indexOfObject:@"Mobile"]] intValue] == 0) { // if mobile and address is deleted, email cannot be deleted
        _fieldSelectionsArray[index][[_allFieldNames indexOfObject:@"Address"]] = @2;
    }
    
    int count = 0;
    if ([_fieldSelectionsArray[index][[_allFieldNames indexOfObject:@"Email"]] intValue] > 0)
        count++;
    if ([_fieldSelectionsArray[index][[_allFieldNames indexOfObject:@"Mobile"]] intValue] > 0)
        count++;
    if ([_fieldSelectionsArray[index][[_allFieldNames indexOfObject:@"Address"]] intValue] > 0)
        count++;
    
    if (count >= 2) {
        if ([_fieldSelectionsArray[index][[_allFieldNames indexOfObject:@"Email"]] intValue] > 0)
            _fieldSelectionsArray[index][[_allFieldNames indexOfObject:@"Email"]] = @1;
        if ([_fieldSelectionsArray[index][[_allFieldNames indexOfObject:@"Mobile"]] intValue] > 0)
            _fieldSelectionsArray[index][[_allFieldNames indexOfObject:@"Mobile"]] = @1;
        if ([_fieldSelectionsArray[index][[_allFieldNames indexOfObject:@"Address"]] intValue] > 0)
            _fieldSelectionsArray[index][[_allFieldNames indexOfObject:@"Address"]] = @1;
    }
    
    _fieldNamesArray[index] = [NSMutableArray new];
    for (int i = 0; i < [_fieldSelectionsArray[index] count]; i++) {
        if ([_fieldSelectionsArray[index][i] intValue] > 0)
            [_fieldNamesArray[index] addObject:_allFieldNames[i]];
    }
}

- (void)calculateAddFieldNames:(int)index {
    // first get the list of the field names which is not added
    _addFieldNames = [NSMutableArray new];
    for (int i = 0; i < [_fieldSelectionsArray[index] count]; i++) {
        if ([_fieldSelectionsArray[index][i] intValue] == 0) {
            [_addFieldNames addObject:_allFieldNames[i]];
        }
    }
    
    NSMutableArray *tempFieldNames = [NSMutableArray new];
    
    _addFieldNameValues = [NSMutableArray new];
    
    // elimiate the ones which have #
    for (NSString *fieldName in _addFieldNames) {
        NSString *prefix;
        if ([fieldName rangeOfString:@"#"].location == NSNotFound)
            prefix = fieldName;
        else
            prefix = [fieldName substringToIndex:[fieldName rangeOfString:@"#"].location];
        if ([tempFieldNames indexOfObject:prefix] == NSNotFound) {
            [tempFieldNames addObject:prefix];
            [_addFieldNameValues addObject:@0];
        }
    }
    
    _addFieldNames = tempFieldNames;
    
    // for ones which are currently added to the field list, increment them
    for (NSString *fieldName in _addFieldNames) {
        for (int i = 0; i < [_fieldSelectionsArray[0] count]; i++) {
            if ([_allFieldNames[i] rangeOfString:fieldName].location != NSNotFound && [_fieldSelectionsArray[0][i] intValue] > 0) {
                NSUInteger index = [tempFieldNames indexOfObject:fieldName];
                _addFieldNameValues[index] = @([_addFieldNameValues[index] intValue] + 1);
            }
        }
    }
}
- (NSString *)getFieldTypeForFieldName:(NSString *)fieldName {
    NSString *fieldType = nil;
    if ([fieldName rangeOfString:@"Name"].location != NSNotFound) {
        fieldType = @"name";
    } else if ([fieldName rangeOfString:@"Company"].location != NSNotFound) {
        fieldType = @"company";
    } else if ([fieldName rangeOfString:@"Title"].location != NSNotFound) {
        fieldType = @"title";
    } else if ([fieldName rangeOfString:@"Mobile"].location != NSNotFound) {
        fieldType = @"mobile";
    } else if ([fieldName rangeOfString:@"Phone"].location != NSNotFound) {
        fieldType = @"phone";
    } else if ([fieldName rangeOfString:@"Fax"].location != NSNotFound) {
        fieldType = @"fax";
    } else if ([fieldName rangeOfString:@"Email"].location != NSNotFound) {
        fieldType = @"email";
    } else if ([fieldName rangeOfString:@"Address"].location != NSNotFound) {
        fieldType = @"address";
    } else if ([fieldName rangeOfString:@"Hours"].location != NSNotFound) {
        fieldType = @"hours";
    } else if ([fieldName rangeOfString:@"Birthday"].location != NSNotFound) {
        fieldType = @"date";
    } else if ([fieldName rangeOfString:@"Facebook"].location != NSNotFound) {
        fieldType = @"facebook";
    } else if ([fieldName rangeOfString:@"Twitter"].location != NSNotFound) {
        fieldType = @"twitter";
    } else if ([fieldName rangeOfString:@"LinkedIn"].location != NSNotFound) {
        fieldType = @"linkedin";
    } else if ([fieldName rangeOfString:@"Website"].location != NSNotFound) {
        fieldType = @"url";
    } else if ([fieldName rangeOfString:@"Custom"].location != NSNotFound) {
        fieldType = @"custom";
    }
    return fieldType;
}

#pragma mark - Custom Methods
- (void)layoutSubviews
{
    
    if (!curContactDict) {
        lblContacttype.hidden = NO;
        btnDel.hidden = YES;
        btnEdit.hidden = YES;
        
        txtFirstName.hidden = YES;
        txtLastName.hidden = YES;
        txtName.hidden = NO;
        
        btnAddInfo.hidden = NO;
        
        [self initDataSource];
        _lblTitle.text = @"Add Contact";
    } else {
        lblContacttype.hidden = YES;
        _lblTitle.text = @"Contact";
        btnAddInfo.hidden = YES;
        btnInfo.hidden = YES;
        txtName.hidden = YES;
        
        if ([curContactDict objectForKey:@"is_favorite"]) {
            isFavoriteStatus = [[curContactDict objectForKey:@"is_favorite"] boolValue];
            _btGreyFavorite.selected = [[curContactDict objectForKey:@"is_favorite"] boolValue];
        }
        
        NSURL * imageURL = [NSURL URLWithString:[curContactDict objectForKey:@"photo_url"]];
        
        [imgAvatar setImageWithURL:imageURL];
        [profileLogoImageView setImageWithURL:imageURL];
        txtName.text = [NSString stringWithFormat:@"%@", [curContactDict objectForKey:@"first_name"]];
        if ([curContactDict objectForKey:@"middle_name"] != [NSNull null]) {
            if (![[curContactDict objectForKey:@"middle_name"] isEqualToString:@""]) {
                txtName.text = [NSString stringWithFormat:@"%@ %@", txtName.text, [curContactDict objectForKey:@"middle_name"]];
            }
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

#pragma mark - Information DataSource
- (void)initDataSource
{
    for (int i=0; i<21; i++) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [arrDataSource addObject:dict];
        if (i == 1 || i == 8 || i == 10) {
            [dict setObject:[NSString stringWithFormat:@"%d", i] forKey:@"name_index"];
            [dict setObject:@"" forKey:@"value"];
            [arrDataSource replaceObjectAtIndex:i withObject:dict];
        }
    }
}
//
- (void)setDataSourceFromContactInfo
{
    [arrDataSource removeAllObjects];
    for (int i=0; i<21; i++) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [arrDataSource addObject:dict];
        NSArray *arrFields = [curContactDict objectForKey:@"fields"];
        for (int j=0;j<[arrFields count];j++) {
            NSDictionary *field = [arrFields objectAtIndex:j];
            if ([[field objectForKey:@"field_name"] isEqualToString:@"Email"]) {
                if ([[field objectForKey:@"field_value"] isEqualToString:@""]) {
                    continue;
                }
            }
            NSString *tmp1 = [field objectForKey:@"field_name"];
            NSString *tmp2 = [_allFieldNames objectAtIndex:i];
            if ([tmp1 isEqualToString:tmp2]) {
                
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                [dict setObject:[NSString stringWithFormat:@"%d", i] forKey:@"name_index"];
                
                
                NSData *decodeData = [[NSData alloc] initWithBase64EncodedString:[field objectForKey:@"field_value"] options:0];
                NSString *decodedString = [[NSString alloc] initWithData:decodeData encoding:NSUTF8StringEncoding];//added by jella
                
                if ((i == 10 || i == 9) && decodedString) {
                    [dict setObject:decodedString forKey:@"value"];
                }else{
                    [dict setObject:[field objectForKey:@"field_value"] forKey:@"value"];
                }
                [dict setObject:[field objectForKey:@"field_value"] forKey:@"value"];
                [arrDataSource replaceObjectAtIndex:i withObject:dict];
            }
        }
    }
    
    //[tblInfo reloadData];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[tblInfo deselectRowAtIndexPath:[tblInfo indexPathForSelectedRow] animated:animated];
    [self.navigationController.navigationBar addSubview:navView];
    //[self.view endEditing:NO];
    _bottomSpacing.constant = 0;
    //[self.view layoutIfNeeded];
    
    //[UIView commitAnimations];
    
    _keyboardShown = NO;
}

- (void)dealloc
{
    [navView removeFromSuperview];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // unregister keyboard observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // register keyboard observers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([tableView isEqual:_addFieldTable]) {
        return 1;
    }
    if (!isEditing) {
        return sections.count;
    }else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    if ([tableView isEqual:_addFieldTable]) {
        return [_addFieldNames count];
    }
    if (!isEditing) {
        return [sections[section] count];
    }else {
        return [_fieldNamesArray[0] count];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isEditing) {
        if (_nextIndexPathBeFirstResponder && [indexPath compare:_nextIndexPathBeFirstResponder] == NSOrderedSame) {
            if ([cell isKindOfClass:[FieldTableCell class]])
                [((FieldTableCell *)cell).textField becomeFirstResponder];
            else if ([cell isKindOfClass:[FieldTableTextViewCell class]])
                [((FieldTableTextViewCell *)cell).textView becomeFirstResponder];
            _nextIndexPathBeFirstResponder = nil;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_addFieldTable]) {
        AddFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddFieldCell"];
        
        if (!cell) {
            [tableView registerNib:[UINib nibWithNibName:@"AddFieldCell" bundle:nil] forCellReuseIdentifier:@"AddFieldCell"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"AddFieldCell"];
        }
        
        cell.fieldLabel.text = _addFieldNames[indexPath.row];
        
        cell.delegate = self;
        
        [self refreshAddFieldCell:cell fieldName:_addFieldNames[indexPath.row]];
        
        [cell setBadgeCount:[_addFieldNameValues[indexPath.row] intValue]];
        
        return cell;
    }
    if (!isEditing) {
        PreviewFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PreviewFieldCell"];
        
        if (!cell) {
            [tableView registerNib:[UINib nibWithNibName:@"PreviewFieldCell" bundle:nil] forCellReuseIdentifier:@"PreviewFieldCell"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"PreviewFieldCell"];
        }
        
        cell.fieldLabel.font = [UIFont systemFontOfSize:15];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.fieldLabel.enabledTextCheckingTypes = 0;
        cell.fieldLabel.delegate = self;
        
        NSDictionary *fieldDic;
        fieldDic = sections[indexPath.section][indexPath.row];
        
        NSString *fieldType = [self getFieldTypeForFieldName:fieldDic[@"field_name"]];
        if ([fieldType isEqualToString:@"company"]) {
            cell.iconImageView.image = [UIImage imageNamed:@"field_icon_grey_company"];
        } else if ([fieldType isEqualToString:@"title"]) {
            cell.iconImageView.image = [UIImage imageNamed:@"field_icon_grey_title"];
        } else if ([fieldType isEqualToString:@"mobile"]) {
            cell.iconImageView.image = [UIImage imageNamed:@"field_icon_grey_mobile"];
        } else if ([fieldType isEqualToString:@"phone"]) {
            cell.iconImageView.image = [UIImage imageNamed:@"field_icon_grey_phone"];
        } else if ([fieldType isEqualToString:@"fax"]) {
            cell.iconImageView.image = [UIImage imageNamed:@"field_icon_grey_fax"];
        } else if ([fieldType isEqualToString:@"email"]) {
            cell.iconImageView.image = [UIImage imageNamed:@"field_icon_grey_email"];
        } else if ([fieldType isEqualToString:@"address"]) {
            cell.iconImageView.image = [UIImage imageNamed:@"field_icon_grey_address"];
        } else if ([fieldType isEqualToString:@"hours"]) {
            cell.iconImageView.image = [UIImage imageNamed:@"field_icon_grey_hours"];
        } else if ([fieldType isEqualToString:@"date"]) {
            cell.iconImageView.image = [UIImage imageNamed:@"field_icon_grey_birthday"];
        } else if ([fieldType isEqualToString:@"facebook"]) {
            cell.iconImageView.image = [UIImage imageNamed:@"field_icon_grey_facebook"];
        } else if ([fieldType isEqualToString:@"twitter"]) {
            cell.iconImageView.image = [UIImage imageNamed:@"field_icon_grey_twitter"];
        } else if ([fieldType isEqualToString:@"linkedin"]) {
            cell.iconImageView.image = [UIImage imageNamed:@"field_icon_grey_linkedin"];
        } else if ([fieldType isEqualToString:@"url"]) {
            cell.iconImageView.image = [UIImage imageNamed:@"field_icon_grey_website"];
        } else if ([fieldType isEqualToString:@"custom"]) {
            cell.iconImageView.image = [UIImage imageNamed:@"field_icon_grey_custom"];
            cell.fieldLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
        }
        
        cell.fieldLabel.text = fieldDic[@"field_value"];
        
        return cell;
    }else{
        if ([_fieldNamesArray[0][indexPath.row] rangeOfString:@"Address"].location != NSNotFound || [_fieldNamesArray[0][indexPath.row] rangeOfString:@"Hours"].location != NSNotFound) {
            FieldTableTextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FieldTableTextViewCell"];
            
            if (!cell) {
                [tableView registerNib:[UINib nibWithNibName:@"FieldTableTextViewCell" bundle:nil] forCellReuseIdentifier:@"FieldTableTextViewCell"];
                cell = [tableView dequeueReusableCellWithIdentifier:@"FieldTableTextViewCell"];
            }
            
            cell.delegate = self;
            
            cell.textView.text = _fieldValuesArray[0][_fieldNamesArray[0][indexPath.row]];
            
            cell.textView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_fieldNamesArray[0][indexPath.row] attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.8 alpha:1], NSFontAttributeName: [UIFont systemFontOfSize:17]}];
            
            if ([_fieldSelectionsArray[0][[_allFieldNames indexOfObject:_fieldNamesArray[0][indexPath.row]]] intValue] == 2) {   // delete button should be hidden when it's mandatory cell
                cell.deleteButton.hidden = YES;
            } else {
                cell.deleteButton.hidden = NO;
            }
            
            if ([_fieldNamesArray[0][indexPath.row] rangeOfString:@"Address"].location != NSNotFound)
                cell.iconImage.image = [UIImage imageNamed:@"field_icon_grey_address"];
            if ([_fieldNamesArray[0][indexPath.row] rangeOfString:@"Hours"].location != NSNotFound)
                cell.iconImage.image = [UIImage imageNamed:@"field_icon_grey_hours"];
            
            return cell;
        }
        
        FieldTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FieldTableCell"];
        
        if (!cell) {
            [tableView registerNib:[UINib nibWithNibName:@"FieldTableCell" bundle:nil] forCellReuseIdentifier:@"FieldTableCell"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"FieldTableCell"];
        }
        
        cell.delegate = self;
        
        cell.textField.text = _fieldValuesArray[0][_fieldNamesArray[0][indexPath.row]];
        cell.textField.placeholder = _fieldNamesArray[0][indexPath.row];
        
        if ([_fieldSelectionsArray[0][[_allFieldNames indexOfObject:_fieldNamesArray[0][indexPath.row]]] intValue] == 2) {   // delete button should be hidden when it's mandatory cell
            cell.deleteButton.hidden = YES;
        } else {
            cell.deleteButton.hidden = NO;
        }
        
        [self refreshFieldCell:cell fieldName:_fieldNamesArray[0][indexPath.row]];
        
        return cell;
    }
    
}
- (void)refreshAddFieldCell:(AddFieldCell *)cell fieldName:(NSString *)fieldName {
    if ([fieldName isEqualToString:@"Company"]) {
        cell.iconImage.image = [UIImage imageNamed:@"field_icon_big_company"];
    }else  if ([fieldName isEqualToString:@"Mobile"]) {
        cell.iconImage.image = [UIImage imageNamed:@"field_icon_big_mobile"];
    } else if ([fieldName isEqualToString:@"Phone"]) {
        cell.iconImage.image = [UIImage imageNamed:@"field_icon_big_phone"];
    } else if ([fieldName isEqualToString:@"Fax"]) {
        cell.iconImage.image = [UIImage imageNamed:@"field_icon_big_fax"];
    } else if ([fieldName isEqualToString:@"Email"]) {
        cell.iconImage.image = [UIImage imageNamed:@"field_icon_big_email"];
    } else if ([fieldName isEqualToString:@"Address"]) {
        cell.iconImage.image = [UIImage imageNamed:@"field_icon_big_address"];
    } else if ([fieldName isEqualToString:@"Hours"]) {
        cell.iconImage.image = [UIImage imageNamed:@"field_icon_big_hours"];
    } else if ([fieldName isEqualToString:@"Birthday"]) {
        cell.iconImage.image = [UIImage imageNamed:@"field_icon_big_birthday"];
    } else if ([fieldName isEqualToString:@"Facebook"]) {
        cell.iconImage.image = [UIImage imageNamed:@"field_icon_big_facebook"];
    } else if ([fieldName isEqualToString:@"Twitter"]) {
        cell.iconImage.image = [UIImage imageNamed:@"field_icon_big_twitter"];
    } else if ([fieldName isEqualToString:@"LinkedIn"]) {
        cell.iconImage.image = [UIImage imageNamed:@"field_icon_big_linkedin"];
    } else if ([fieldName isEqualToString:@"Website"]) {
        cell.iconImage.image = [UIImage imageNamed:@"field_icon_big_website"];
    } else if ([fieldName isEqualToString:@"Custom"]) {
        cell.iconImage.image = [UIImage imageNamed:@"field_icon_big_custom"];
    }
}
- (void)refreshFieldCell:(FieldTableCell *)cell fieldName:(NSString *)fieldName {
    NSString *fieldType = [self getFieldTypeForFieldName:fieldName];
    if ([fieldType isEqualToString:@"company"]) {
        cell.textField.keyboardType = UIKeyboardTypeDefault;
        cell.textField.returnKeyType = UIReturnKeyNext;
        cell.iconImage.image = [UIImage imageNamed:@"field_icon_grey_company"];
    } else if ([fieldType isEqualToString:@"title"]) {
        cell.textField.keyboardType = UIKeyboardTypeDefault;
        cell.textField.returnKeyType = UIReturnKeyNext;
        cell.iconImage.image = [UIImage imageNamed:@"field_icon_grey_title"];
    } else if ([fieldType isEqualToString:@"mobile"]) {
        cell.textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        cell.textField.returnKeyType = UIReturnKeyNext;
        cell.iconImage.image = [UIImage imageNamed:@"field_icon_grey_mobile"];
    } else if ([fieldType isEqualToString:@"phone"]) {
        cell.textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        cell.textField.returnKeyType = UIReturnKeyNext;
        cell.iconImage.image = [UIImage imageNamed:@"field_icon_grey_phone"];
    } else if ([fieldType isEqualToString:@"fax"]) {
        cell.textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        cell.textField.returnKeyType = UIReturnKeyNext;
        cell.iconImage.image = [UIImage imageNamed:@"field_icon_grey_fax"];
    } else if ([fieldType isEqualToString:@"email"]) {
        cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
        cell.textField.returnKeyType = UIReturnKeyNext;
        cell.iconImage.image = [UIImage imageNamed:@"field_icon_grey_email"];
    } else if ([fieldType isEqualToString:@"hours"]) {
        cell.textField.keyboardType = UIKeyboardTypeDefault;
        cell.textField.returnKeyType = UIReturnKeyNext;
        cell.iconImage.image = [UIImage imageNamed:@"field_icon_grey_hours"];
    } else if ([fieldType isEqualToString:@"address"]) {
        cell.textField.keyboardType = UIKeyboardTypeDefault;
        cell.textField.returnKeyType = UIReturnKeyNext;
        cell.iconImage.image = [UIImage imageNamed:@"field_icon_grey_address"];
    } else if ([fieldType isEqualToString:@"date"]) {
        cell.textField.keyboardType = UIKeyboardTypeDefault;
        cell.textField.returnKeyType = UIReturnKeyNext;
        cell.iconImage.image = [UIImage imageNamed:@"field_icon_grey_birthday"];
    } else if ([fieldType isEqualToString:@"facebook"]) {
        cell.textField.keyboardType = UIKeyboardTypeDefault;
        cell.textField.returnKeyType = UIReturnKeyNext;
        cell.iconImage.image = [UIImage imageNamed:@"field_icon_grey_facebook"];
    } else if ([fieldType isEqualToString:@"twitter"]) {
        cell.textField.keyboardType = UIKeyboardTypeDefault;
        cell.textField.returnKeyType = UIReturnKeyNext;
        cell.iconImage.image = [UIImage imageNamed:@"field_icon_grey_twitter"];
    } else if ([fieldType isEqualToString:@"linkedin"]) {
        cell.textField.keyboardType = UIKeyboardTypeDefault;
        cell.textField.returnKeyType = UIReturnKeyNext;
        cell.iconImage.image = [UIImage imageNamed:@"field_icon_grey_linkedin"];
    } else if ([fieldType isEqualToString:@"url"]) {
        cell.textField.keyboardType = UIKeyboardTypeURL;
        cell.textField.returnKeyType = UIReturnKeyNext;
        cell.iconImage.image = [UIImage imageNamed:@"field_icon_grey_website"];
    } else if ([fieldType isEqualToString:@"custom"]) {
        cell.textField.keyboardType = UIKeyboardTypeDefault;
        cell.textField.returnKeyType = UIReturnKeyNext;
        cell.iconImage.image = [UIImage imageNamed:@"field_icon_grey_custom"];
    }
}

#pragma mark - UITableViewCellDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //if (indexPath.section == 0)
      //  return;
    if ([tableView isEqual:_addFieldTable]) {
        return;
    }
    if (!isEditing) {
        NSDictionary *fieldDic;
        
        fieldDic = sections[indexPath.section][indexPath.row];
        
        NSString *fieldType = [self getFieldTypeForFieldName:fieldDic[@"field_name"]];
        NSString *fieldValue = fieldDic[@"field_value"];
        
        if (!fieldValue || [fieldValue isEqualToString:@""])
            return;
        
        if ([fieldType isEqualToString:@"company"]) {
            
        } else if ([fieldType isEqualToString:@"title"]) {
            
        } else if ([fieldType isEqualToString:@"mobile"] || [fieldType isEqualToString:@"phone"] || [fieldType isEqualToString:@"fax"]) {
            NSURL *phoneUrl = [NSURL URLWithString:[@"telprompt://" stringByAppendingString:[fieldValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            NSURL *phoneFallbackUrl = [NSURL URLWithString:[@"tel://" stringByAppendingString:[fieldValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            
            if ([UIApplication.sharedApplication canOpenURL:phoneUrl]) {
                [UIApplication.sharedApplication openURL:phoneUrl];
            } else if ([UIApplication.sharedApplication canOpenURL:phoneFallbackUrl]) {
                [UIApplication.sharedApplication openURL:phoneFallbackUrl];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Your device is not compatible with phone calls." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        } else if ([fieldType isEqualToString:@"email"]) {
            [self sendMailToEmailAddress:fieldValue];
        } else if ([fieldType isEqualToString:@"address"]) {
            NSString *addressString = [@"http://maps.apple.com/?q=" stringByAppendingString:[[fieldValue stringByReplacingOccurrencesOfString:@" " withString:@"+"] stringByReplacingOccurrencesOfString:@"\n" withString:@"+"]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:addressString]];
        } else if ([fieldType isEqualToString:@"hours"]) {
            
        } else if ([fieldType isEqualToString:@"date"]) {
            
        } else if ([fieldType isEqualToString:@"facebook"]) {
            
        } else if ([fieldType isEqualToString:@"twitter"]) {
            
        } else if ([fieldType isEqualToString:@"linkedin"]) {
            
        } else if ([fieldType isEqualToString:@"url"]) {
            NSURL *url = [[NSURL alloc] initWithString:fieldValue];
            
            if (url.scheme.length == 0) {
                url = [[NSURL alloc] initWithString:[@"http://" stringByAppendingString:fieldValue]];
            }
            
            [[UIApplication sharedApplication] openURL:url];
        } else if ([fieldType isEqualToString:@"custom"]) {
            
        }
    }else{
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[FieldTableCell class]])
            [((FieldTableCell *)cell).textField becomeFirstResponder];
        else if ([cell isKindOfClass:[FieldTableTextViewCell class]])
            [((FieldTableTextViewCell *)cell).textView becomeFirstResponder];
    }
}


#pragma mark - Helper methods
- (void)sendMailToEmailAddress:(NSString *)email {
    if([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        [picker setToRecipients:@[email]];
        [picker setSubject:@""];
        
        [self presentViewController:picker animated:YES completion:^{
            //            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        }];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Please configure mail accounts to send mail." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:NO];
}
#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    //    if(result == MFMailComposeResultSent)
    //        [[[UIAlertView alloc] initWithTitle:@"Mail sent!" message:nil delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil] show];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if (url)
        [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - FieldTableCellDelegate
- (void)fieldTableCellDeleteField:(FieldTableCell *)cell {
    NSUInteger index = [_allFieldNames indexOfObject:cell.textField.placeholder];
    [self.view endEditing:NO];
    if (index == NSNotFound)
        return;
    
    _fieldSelectionsArray[0][index] = @(0);
    [_fieldValuesArray[0] removeObjectForKey:cell.textField.placeholder];
    
    [self calculateFieldNames:0];
    
    int i;
    for (i = 0; i < [_fieldSelectionsArray[0] count]; i++) {
        if ([_fieldSelectionsArray[0][i] intValue] > 0) {
            NSString *fieldValue = _fieldValuesArray[0][_allFieldNames[i]];
            if (!fieldValue) {
                break;
            }
            
            fieldValue = [fieldValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([fieldValue isEqualToString:@""])
                break;
        }
    }
    
    if (i != [_fieldSelectionsArray[0] count]) {
        btnDone.hidden = YES;
        btnDoneReal.hidden = YES;
    }else{
        if (greyType != 0) {
            btnDone.hidden = NO;
            btnDoneReal.hidden = NO;
        }
    }
    
    [_tables[0] reloadData];
}

- (void)fieldTableCell:(FieldTableCell *)cell textDidChange:(NSString *)text {
    _fieldValuesArray[0][cell.textField.placeholder] = text;
    
    if ([txtName.text isEqualToString:@""]) {
        btnDone.hidden = YES;
        btnDoneReal.hidden = YES;
        return;
    }
    int i;
    for (i = 0; i < [_fieldSelectionsArray[0] count]; i++) {
        if ([_fieldSelectionsArray[0][i] intValue] > 0) {
            NSString *fieldValue = _fieldValuesArray[0][_allFieldNames[i]];
            if (!fieldValue) {
                break;
            }
            
            fieldValue = [fieldValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([fieldValue isEqualToString:@""])
                break;
        }
    }
    
    if (i != [_fieldSelectionsArray[0] count]) {
        btnDone.hidden = YES;
        btnDoneReal.hidden = YES;
    }else{
        if (greyType != 0) {
            btnDone.hidden = NO;
            btnDoneReal.hidden = NO;
        }
    }
    
//    BOOL isEmptyDataSource = NO;
//    for (NSString *fieldName in _allFieldNames) {
//        if (_fieldValuesArray[0][fieldName]) {
//            if (![_fieldValuesArray[0][fieldName] isEqualToString:@""]) {
//                isEmptyDataSource = NO;
//            }
//        }
//    }
//    if (!isEmptyDataSource) {
//        btnDone.hidden = NO;
//        btnDoneReal.hidden = NO;
//    }else{
//        btnDone.hidden = YES;
//        btnDoneReal.hidden = YES;
//    }
}
- (void)fieldTableCellTextFieldShouldBeginEditing:(FieldTableCell *)cell{
    
    currentIndexCell = [_tables[0] indexPathForCell:cell];
    NSLog(@"selected cell");
    
    if (currentIndexCell.row == [_fieldNamesArray[0] count]-1) { //changed
        cell.textField.returnKeyType = UIReturnKeyDone;
    }
}
-(void)fieldTableCellTextFieldDidBeginEditing:(FieldTableCell *)cell{
    currentIndexCell = [_tables[0] indexPathForCell:cell];
}
- (void)fieldTableCellTextFieldDidReturn:(FieldTableCell *)cell {
    NSIndexPath *indexPath = [_tables[0] indexPathForCell:cell];
    if (indexPath && indexPath.row < [_tables[0] numberOfRowsInSection:indexPath.section] - 1) {
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
        [_tables[0] scrollToRowAtIndexPath:nextIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        UITableViewCell *cell = [_tables[0] cellForRowAtIndexPath:nextIndexPath];
        if (cell) {
            if ([cell isKindOfClass:[FieldTableCell class]])
                [((FieldTableCell *)cell).textField becomeFirstResponder];
            else if ([cell isKindOfClass:[FieldTableTextViewCell class]])
                [((FieldTableTextViewCell *)cell).textView becomeFirstResponder];
        } else {
            _nextIndexPathBeFirstResponder = nextIndexPath;
        }
    }
}

#pragma mark - FieldTableTextViewCellDelegate
- (void)fieldTableTextViewCellDeleteField:(FieldTableTextViewCell *)cell {
    NSUInteger index = [_allFieldNames indexOfObject:cell.textView.placeholder];
    
    if (index == NSNotFound)
        return;
    
    _fieldSelectionsArray[0][index] = @(0);
    [_fieldValuesArray[0] removeObjectForKey:cell.textView.placeholder];
    
    [self calculateFieldNames:0];
    int i;
    for (i = 0; i < [_fieldSelectionsArray[0] count]; i++) {
        if ([_fieldSelectionsArray[0][i] intValue] > 0) {
            NSString *fieldValue = _fieldValuesArray[0][_allFieldNames[i]];
            if (!fieldValue) {
                break;
            }
            
            fieldValue = [fieldValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([fieldValue isEqualToString:@""])
                break;
        }
    }
    
    if (i != [_fieldSelectionsArray[0] count]) {
        btnDone.hidden = YES;
        btnDoneReal.hidden = YES;
    }else{
        if (greyType != 0) {
            btnDone.hidden = NO;
            btnDoneReal.hidden = NO;
        }
    }
    [_tables[0] reloadData];
}

- (void)fieldTableTextViewCell:(FieldTableTextViewCell *)cell textDidChange:(NSString *)text {
  
    [UIView setAnimationsEnabled:NO];
    [_tables[0] beginUpdates];
    [_tables[0] endUpdates];
    [UIView setAnimationsEnabled:YES];
    
    _fieldValuesArray[0][cell.textView.placeholder] = text;
    if ([txtName.text isEqualToString:@""]) {
        btnDone.hidden = YES;
        btnDoneReal.hidden = YES;
        return;
    }
    int i;
    for (i = 0; i < [_fieldSelectionsArray[0] count]; i++) {
        if ([_fieldSelectionsArray[0][i] intValue] > 0) {
            NSString *fieldValue = _fieldValuesArray[0][_allFieldNames[i]];
            if (!fieldValue) {
                break;
            }
            
            fieldValue = [fieldValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([fieldValue isEqualToString:@""])
                break;
        }
    }
    
    if (i != [_fieldSelectionsArray[0] count]) {
        btnDone.hidden = YES;
        btnDoneReal.hidden = YES;
    }else{
        if (greyType != 0) {
            btnDone.hidden = NO;
            btnDoneReal.hidden = NO;
        }
    }
    
//    BOOL isEmptyDataSource = YES;
//    for (NSString *fieldName in _allFieldNames) {
//        if (_fieldValuesArray[0][fieldName]) {
//            if (![_fieldValuesArray[0][fieldName] isEqualToString:@""]) {
//                isEmptyDataSource = NO;
//            }
//        }
//    }
//    if (!isEmptyDataSource) {
//        btnDone.hidden = NO;
//        btnDoneReal.hidden = NO;
//    }else{
//        btnDone.hidden = YES;
//        btnDoneReal.hidden = YES;
//    }
}

#pragma mark - Keyboard Notifications
- (void)keyboardWillShow:(NSNotification*)aNotification {
    NSDictionary* userInfo = [aNotification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    if(!_keyboardShown)
    {
        CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:duration];
        [UIView setAnimationCurve:[userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    }
    
    _bottomSpacing.constant = kbSize.height;
    [self.view layoutIfNeeded];
    
    if(!_keyboardShown)
        [UIView commitAnimations];
    
    _keyboardShown = YES;
}

- (void)keyboardWillHide:(NSNotification*)aNotification {
    NSDictionary *userInfo = [aNotification userInfo];
    CGFloat duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:[userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    
    _bottomSpacing.constant = 0;
    [self.view layoutIfNeeded];
    
    [UIView commitAnimations];
    
    _keyboardShown = NO;
}
- (void)showEditPane:(BOOL)flag
{
    if (!flag) {
        lblContacttype.hidden = YES;
        btnDone.hidden = YES;
        btnDoneReal.hidden = YES;
        txtName.borderStyle = UITextBorderStyleNone;
        
        txtFirstName.hidden = NO;
        txtLastName.hidden = NO;
        txtName.hidden = YES;
    } else {
        lblContacttype.hidden = NO;
        txtName.borderStyle = UITextBorderStyleRoundedRect;
        if (greyType != 0) {
            btnDone.hidden = NO;
            btnDoneReal.hidden = NO;
        }
        txtFirstName.hidden = YES;
        txtLastName.hidden = YES;
        txtName.hidden = NO;
    }
    isEditing = flag;
    btnEdit.hidden = flag;
    btnDel.hidden = flag;
    //    btnInfo.hidden = flag;
    btnNotes.hidden = flag;
    //btnRemove.hidden = !flag;
    btnEditInfo.hidden = !flag;
    
    btnBack.hidden = flag;
    btnClose.hidden = !flag;
     [((UITableView *)_tables[0]) reloadData];
    
    
  //  if(tblInfo.editing) { // the delete button is disabled by default since no items are selected
   //     btnRemove.enabled = false;
  //  }
}
- (NSString *)getFieldType:(int)fieldIndex
{
    NSString *str = @"";
    switch (fieldIndex) {
        case 0:
            str = @"company";
            break;
        case 1:
        case 2:
        case 3:
            str = @"mobile";
            break;
        case 4:
        case 5:
        case 6:
            str = @"phone";
            break;
        case 7:
            str = @"fax";
            break;
        case 8:
        case 9:
            str = @"email";
            break;
        case 10:
        case 11:
            str = @"address";
            break;
        case 12:
            str = @"hours";
            break;
        case 13:
            str = @"birthday";
            break;
        case 14:
            str = @"facebook";
            break;
        case 15:
            str = @"twitter";
            break;
        case 16:
            str = @"linkedIn";
            break;
        case 17:
            str = @"website";
            break;
        case 18:
        case 19:
        case 20:
            str = @"custom";
            break;
        default:
            break;
    }
    return str;
}

#pragma mark - WebAPI integration
- (void)addOrUpdateContact
{
    NSLog(@"updatecontact");
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
    
    [arrDataSource removeAllObjects];
    
    // check if all fields exist
    int i;
    for (i = 0; i < [_fieldSelectionsArray[0] count]; i++) {
        if ([_fieldSelectionsArray[0][i] intValue] > 0) {
            NSString *fieldValue = _fieldValuesArray[0][_allFieldNames[i]];
            if (!fieldValue) {
                break;
            }
            
            fieldValue = [fieldValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([fieldValue isEqualToString:@""])
                break;
        }
    }
    
    if (i != [_fieldSelectionsArray[0] count]) {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Please fill all fields." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    if (_fieldValuesArray[0][@"Email"] && [_fieldValuesArray[0][@"Email"] rangeOfString:@" "].length != 0) {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Email field contains space. Please input again"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    if (_fieldValuesArray[0][@"Email#2"] && [_fieldValuesArray[0][@"Email#2"] rangeOfString:@" "].length != 0) {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Email field contains space. Please input again"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    if (_fieldValuesArray[0][@"Email"] && ![self checkedEmail:_fieldValuesArray[0][@"Email"]]) {
        return;
    }
    if ( _fieldValuesArray[0][@"Email#2"] && ![self checkedEmail:_fieldValuesArray[0][@"Email#2"]]) {
        return;
    }
    
    for (int i=0; i<21; i++) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [arrDataSource addObject:dict];
        
        for (int j=0;j<[_fieldNamesArray[0] count];j++) {
            
            NSString *tmp1 = _fieldNamesArray[0][j];
            NSString *tmp2 = [_allFieldNames objectAtIndex:i];
            if ([tmp1 isEqualToString:tmp2]) {
                
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                [dict setObject:[NSString stringWithFormat:@"%d", i] forKey:@"name_index"];
                [dict setObject:_fieldValuesArray[0][tmp1] forKey:@"value"];
                [arrDataSource replaceObjectAtIndex:i withObject:dict];
            }
        }
    }
    
    NSMutableArray *arrFields = [[NSMutableArray alloc] init];
    for (int i =0; i<21; i++) {
        NSMutableDictionary *dict = [arrDataSource objectAtIndex:i];
        if ([dict objectForKey:@"value"]) {
            if (![[dict objectForKey:@"value"] isEqualToString:@""]) {
                if (i == 8) {
                    email = [dict objectForKey:@"value"];
                    //continue;
                }
                if (i == 9) {
                    if ([email isEqualToString:@""]) {
                        email = [dict objectForKey:@"value"];
                        //continue;
                    }
                }
                
                NSMutableDictionary *field = [NSMutableDictionary dictionary];
                [field setObject:[_allFieldNames objectAtIndex:i]        forKey:@"field_name"];
                NSData *plainData = [[dict objectForKey:@"value"] dataUsingEncoding:NSUTF8StringEncoding];
                NSString *encodevalue= [plainData base64EncodedStringWithOptions:0];
                
                if (i == 10 || i == 11) {
                    [field setObject:encodevalue  forKey:@"field_value"];
                }else{
                    [field setObject:[dict objectForKey:@"value"] forKey:@"field_value"];
                }
                [field setObject:[dict objectForKey:@"value"]               forKey:@"field_value"];
                [field setObject:[self getFieldType:i]                      forKey:@"field_type"];
                [arrFields addObject:field];
            }
        }
    }
    if (email.length > 0 && ![CommonMethods checkEmailAddress:email]) {
        return;
    }
    
    if (arrFields.count == 0 && [email isEqualToString:@""]) { // if all fields are empty
        [CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Oops!  Name and at least one other field required!"];
        return;
    }

    void (^successed)(id responseObject) = ^(id responseObject) {
        NSDictionary *result = responseObject;
        
        if ([[result objectForKey:@"success"] boolValue]) {
            NSString *contactId;
            if (curContactDict) {
                contactId = curContactDict[@"contact_id"];
            } else {
                contactId = result[@"data"][@"contact_id"];
            }
            if(removedImage && curContactDict) { // image removed
                [self deletePhoto];
                removedImage = NO;
            } else if(newImage) { // upload new image
                [self uploadPhotoWithContactId:contactId];
                newImage = nil;
            } else { // nothing
                [self getUpdatedContactDetail:contactId];
            }
        } else {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            NSDictionary *dictError = [result objectForKey:@"err"];
            if (dictError) {
                [SVProgressHUD showErrorWithStatus:[dictError objectForKey:@"errMsg"]];
            } else {
                [SVProgressHUD showErrorWithStatus:@"Failed to connect to server!"];
            }
        }
        
        //isEditing = NO;
        //[((UITableView *)_tables[0]) reloadData];
    };
    
    void (^failure)(NSError* error) = ^(NSError* error) {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        //[SVProgressHUD showErrorWithStatus:@"Failed to connect to server!"];
    };
    
    //[SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeClear];
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [[GreyClient sharedClient] addUpdateGreyContact:[AppDelegate sharedDelegate].sessionId contactID:curContactDict ? [curContactDict objectForKey:@"id"] : nil firstName:firstName middleName:middleName lastName:lastName email:email photoName:[photoName isEqualToString:@""] ? nil : photoName notes:strNotes type:type favorite:_btGreyFavorite.selected ? TRUE : FALSE fields:[arrFields count] ? arrFields : nil successed:successed failure:failure];
}
- (BOOL)checkedEmail:(NSString *)checkText
{
    BOOL filter = YES ;
    NSString *filterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = filter ? filterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    if([emailTest evaluateWithObject:checkText] == NO)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter a valid email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return NO ;
    }
    
    return YES ;
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
    for (int i =0; i<21; i++) {
        NSMutableDictionary *dict = [arrDataSource objectAtIndex:i];
        if ([dict objectForKey:@"value"]) {
            if (![[dict objectForKey:@"value"] isEqualToString:@""]) {
                if (i == 8) {
                    email = [dict objectForKey:@"value"];
                    continue;
                }
                if (i == 9) {
                    if ([email isEqualToString:@""]) {
                        email = [dict objectForKey:@"value"];
                        continue;
                    }
                }
                
                NSMutableDictionary *field = [NSMutableDictionary dictionary];
                [field setObject:[_allFieldNames objectAtIndex:i]        forKey:@"field_name"];
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
    [[GreyClient sharedClient] addUpdateGreyContact:[AppDelegate sharedDelegate].sessionId contactID:curContactDict ? [curContactDict objectForKey:@"id"] : nil firstName:firstName middleName:middleName lastName:lastName email:email photoName:[photoName isEqualToString:@""] ? nil : photoName notes:strNotes type:type favorite:_btGreyFavorite.selected ? TRUE : FALSE fields:[arrFields count] ? arrFields : nil successed:successed failure:failure];
    
}

- (void)getUpdatedContactDetail:(NSString *)contactID
{
    void (^successed)(id responseObject) = ^(id responseObject) {
        //[SVProgressHUD dismiss];
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        NSDictionary *result = responseObject;
        //NSLog(@"contacts result = %@", result);
        if ([[result objectForKey:@"success"] boolValue]) {
            curContactDict = [result objectForKey:@"data"];
            
            [self layoutSubviews];
            [self reloadGreyDetails];
            [self showEditPane:NO];
            tempDataSource = (NSMutableArray *)CFBridgingRelease(CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (CFPropertyListRef)arrDataSource, kCFPropertyListMutableContainers));
            
            if ([curContactDict objectForKey:@"is_favorite"]) {
                _btGreyFavorite.selected = [[curContactDict objectForKey:@"is_favorite"] boolValue];
            }
            
            NSManagedObjectContext *context = [AppDelegate sharedDelegate].managedObjectContext;
            
            NSFetchRequest *allContacts = [[NSFetchRequest alloc] init];
            [allContacts setEntity:[NSEntityDescription entityForName:@"Contact" inManagedObjectContext:context]];
            
            NSError *error = nil;
            NSArray *contacts = [context executeFetchRequest:allContacts error:&error];
            NSArray *foundContacts = [contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"contact_id == %@ AND contact_type == 2", [NSString stringWithFormat:@"%@", [curContactDict objectForKey:@"contact_id"]]]];
            if (foundContacts.count > 0) { // existing
                Contact *contact = foundContacts[0];
                contact.data = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:curContactDict options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
            }
            NSError *saveError = nil;
            [context save:&saveError];
            if (saveError) {
                NSLog(@"Error when saving managed object context : %@", saveError);
            }
        
        } else {
            NSDictionary *dictError = [result objectForKey:@"err"];
            if (dictError) {
                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:[dictError objectForKey:@"errMsg"]];
                if ([[NSString stringWithFormat:@"%@",[dictError objectForKey:@"errCode"]] isEqualToString:@"350"]) {
                    [[AppDelegate sharedDelegate] GetContactList];
                }
            } else {
                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Failed to connect to server!"];
            }
        }
        
    };
    
    void (^failure)(NSError* error) = ^(NSError* error) {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        [SVProgressHUD showErrorWithStatus:@"Failed to connect to server!"];
    };
    
    ///[SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeClear];
    //[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [[Communication sharedManager] getContactDetail:[AppDelegate sharedDelegate].sessionId contactId:contactID contactType:@"2" successed:successed failure:failure];
}

- (void)uploadPhotoWithContactId:(NSString *)contactId
{
    void (^successed)(id responseObject) = ^(id responseObject) {
        //[MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        NSDictionary *result = responseObject;
        
        NSLog(@"upload photo result = %@", result);
        
        if ([[result objectForKey:@"success"] boolValue]) {
            
            photoName = [(NSDictionary *)[result objectForKey:@"data"] objectForKey:@"photo_name"];
            
            if (curContactDict) {
                if (greyType != 0) {
                    btnDone.hidden = NO;
                    btnDoneReal.hidden = NO;
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self getUpdatedContactDetail:contactId];
            });
            
        } else {
            
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            NSDictionary *dictError = [result objectForKey:@"err"];
            if (dictError) {
                [SVProgressHUD showErrorWithStatus:[dictError objectForKey:@"errMsg"]];
            } else {
                [SVProgressHUD showErrorWithStatus:@"Failed to connect to server!"];
            }
        }
    };
    
    void (^failure)(NSError* error) = ^(NSError* error) {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
       // [SVProgressHUD showErrorWithStatus:@"Failed to connect to server!"];
    };
    
    ///[SVProgressHUD showWithStatus:@"Uploading..." maskType:SVProgressHUDMaskTypeClear];
   // [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [[GreyClient sharedClient] uploadPhoto:[AppDelegate sharedDelegate].sessionId contactID:contactId successed:successed failure:failure];
}

- (void)deletePhoto
{
    void (^successed)(id responseObject) = ^(id responseObject) {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        NSDictionary *result = responseObject;
        
        NSLog(@"delete photo result = %@", result);
        
        if ([[result objectForKey:@"success"] boolValue]) {
            
            photoName = nil;
            
            if (curContactDict) {
                if (greyType != 0) {
                    btnDone.hidden = NO;
                    btnDoneReal.hidden = NO;
                }
            }
            
            if (curContactDict) {
                [self getUpdatedContactDetail:[curContactDict objectForKey:@"contact_id"]];
            } else {
                [self getUpdatedContactDetail:[[result objectForKey:@"data"] objectForKey:@"contact_id"]];
            }
            
        } else {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];        }
    };
    
    void (^failure)(NSError* error) = ^(NSError* error) {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        //[SVProgressHUD showErrorWithStatus:@"Failed to connect to server!"];
    };
    
    ///[SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeClear];
    //[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [[GreyClient sharedClient] deletePhoto:[AppDelegate sharedDelegate].sessionId contactID:curContactDict ? [curContactDict objectForKey:@"id"] : nil successed:successed failure:failure];
}

- (void)removeContact
{
    if (!isContactFromBackup) {
        
        void (^successed)(id responseObject) = ^(id responseObject) {
            NSDictionary *result = responseObject;
            
            NSLog(@"remove contact result = %@", result);
            
            if ([[result objectForKey:@"success"] boolValue]) {
                
                [SVProgressHUD dismiss];
                [SVProgressHUD showSuccessWithStatus:@"Removed"];
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
        [[GreyClient sharedClient] removeContact:[AppDelegate sharedDelegate].sessionId contactID:[curContactDict objectForKey:@"id"] successed:successed failure:failure];
    }
    else{
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
}



- (void)syncDataSource
{
    //[self.view endEditing:NO];
    
    // save and pop
    // validation
    if ((!txtName.text || [txtName.text isEqualToString:@""]) || ((!_fieldValuesArray[0][@"Email"] || [_fieldValuesArray[0][@"Email"] isEqualToString:@""]) && (!_fieldValuesArray[0][@"Mobile"] || [_fieldValuesArray[0][@"Mobile"] isEqualToString:@""]) && (!_fieldValuesArray[0][@"Address"] || [_fieldValuesArray[0][@"Address"] isEqualToString:@""]))) {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Name and one field are required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    // check if all fields exist
    int i;
    for (i = 0; i < [_fieldSelectionsArray[0] count]; i++) {
        if ([_fieldSelectionsArray[0][i] intValue] > 0) {
            NSString *fieldValue = _fieldValuesArray[0][_allFieldNames[i]];
            if (!fieldValue) {
                break;
            }
            
            fieldValue = [fieldValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([fieldValue isEqualToString:@""])
                break;
        }
    }
    
    if (i != [_fieldSelectionsArray[0] count]) {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Please fill all fields." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    _addressConfirmed = NO;
    if (_fieldValuesArray[0][@"Address"] && ![_fieldValuesArray[0][@"Address"] isEqualToString:@""]) {
        // geocode
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:_fieldValuesArray[0][@"Address"] completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            if ([placemarks count] > 0) {
                _addressConfirmed = YES;
                _location = [(CLPlacemark *)placemarks[0] location];
                [self addOrUpdateContact];
            } else {
               // [[[UIAlertView alloc] initWithTitle:@"Oh no!" message:@"Cannot find the location from the address! Please retype the address field." delegate:self cancelButtonTitle:@"Skip" otherButtonTitles:@"OK", nil] show];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oh no!" message:@"Cannot find the location from the address! Please retype the address field." delegate:self cancelButtonTitle:@"Skip" otherButtonTitles:@"OK", nil];
                alert.tag = 4;
                [alert show];
                return;
                
            }
        }];
    } else {
        [self addOrUpdateContact];
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
    newImage = image;
    removedImage = NO;
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
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
        return;
    } else if(buttonIndex == 2) { // delete photo
        newImage = nil;
        removedImage = YES;
        [imgAvatar setImage:[UIImage imageNamed:@"greyblank"]];
        [profileLogoImageView setImage:[UIImage imageNamed:@"greyblank"]];
        return;
    }
    
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.delegate = self;
    
    if (buttonIndex) {// photo library
        imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imgPicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
        [self presentViewController:imgPicker animated:YES completion:nil];
    }
    else {
        if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!granted) {
                        [CommonMethods showAlertUsingTitle:@"" andMessage:MESSAGE_CAMERA_DISABLED];
                    }
                    else {
                        imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                        imgPicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
                        [self presentViewController:imgPicker animated:YES completion:nil];
                    }
                });
            }];
        }
    }
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        switch (alertView.tag) {
            case 1:
                [self removeContact];
                break;
            case 2:
                [self syncDataSource];
                //[self addOrUpdateContact];
                break;
            case 3:
                //[self removeFieldsFromDataSource];
                //[tblInfo reloadData];
                //btnRemove.enabled = NO;
                //                [self addOrUpdateContact];
                break;
            case 4:
                [self addOrUpdateContact];
                break;
            default:
                break;
        }
    }
}

#pragma mark - Actions
- (IBAction)onAvatar:(id)sender
{
    if (!isEditing && curContactDict) {
        return;
    }
    [self.view endEditing:NO];
    //[self fitToScroll];
    
    UIActionSheet *actionSheet;
    if (!removedImage && ((curContactDict && [curContactDict[@"photo_url"] rangeOfString:@"greyblank"].location == NSNotFound )|| newImage)) { // photo exists
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"Add your photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Take a Photo" otherButtonTitles:@"Photo From Gallery", @"Remove photo", nil];
        actionSheet.destructiveButtonIndex = 2;
    } else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"Add your photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a Photo", @"Photo From Gallery", nil];
    }

    [actionSheet showInView:self.view];
}

- (IBAction)onType:(id)sender
{
    [self.view endEditing:NO];
    if (!isEditing && curContactDict) {
        return;
    }
    UIButton *btnType = (UIButton *)sender;
    if (greyType == btnType.tag) {
        return;
    }
    greyType = btnType.tag;
    
//    BOOL isEmptyDataSource = NO;
//    for (NSString *fieldName in _allFieldNames) {
//        if (_fieldValuesArray[0][fieldName]) {
//            if ([_fieldValuesArray[0][fieldName] isEqualToString:@""]) {
//                isEmptyDataSource = YES;
//            }
//        }
//    }
//    if (!isEmptyDataSource && txtName.text.length > 0 && [_fieldValuesArray[0] count] > 0) {
//        if (greyType != 0) {
//            btnDone.hidden = NO;
//            btnDoneReal.hidden = NO;
//        }
//    }else{
//        btnDone.hidden = YES;
//        btnDoneReal.hidden = YES;
//    }
    int i;
    for (i = 0; i < [_fieldSelectionsArray[0] count]; i++) {
        if ([_fieldSelectionsArray[0][i] intValue] > 0) {
            NSString *fieldValue = _fieldValuesArray[0][_allFieldNames[i]];
            if (!fieldValue) {
                break;
            }
            
            fieldValue = [fieldValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([fieldValue isEqualToString:@""])
                break;
        }
    }
    
    if (i != [_fieldSelectionsArray[0] count]) {
        btnDone.hidden = YES;
        btnDoneReal.hidden = YES;
    }else{
        if (greyType != 0) {
            btnDone.hidden = NO;
            btnDoneReal.hidden = NO;
        }
    }
//    if (curContactDict && txtName.text.length > 0) {
//        if (greyType != 0) {
//            btnDone.hidden = NO;
//            btnDoneReal.hidden = NO;
//        }
//    }
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
    
    [self.view endEditing:NO];
   // GreyInfoController *vc = [[GreyInfoController alloc] initWithNibName:@"GreyInfoController" bundle:nil];
   // [vc setParentController:self];
    //[self presentViewController:vc animated:YES completion:nil];
    
    // hide add field at first
    [self calculateAddFieldNames:0];
    if ([_addFieldNames count] == 0) {
        return;
    }
    [_addFieldTable reloadData];
    _addFieldView.hidden = NO;
    isSelectedViewAddFields = YES;
}
- (IBAction)hideAddFieldView:(id)sender {
    _addFieldView.hidden = YES;
    isSelectedViewAddFields = NO;
}
- (IBAction)onNotes:(id)sender
{
    //[self.view endEditing:NO];
    GreyAddNotesController *vc = [[GreyAddNotesController alloc] initWithNibName:@"GreyAddNotesController" bundle:nil];
    [vc setParentController:self];
    if (![strNotes isEqualToString:@""]) {
        vc.strNotes = strNotes;
    }
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)onRemove:(id)sender
{
    [self.view endEditing:NO];
   // if (![[tblInfo indexPathsForSelectedRows] count]) {
        [CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"You need to select at least one field to delete."];
        return;
 //   }
    
    //if ([[tblInfo indexPathsForSelectedRows] count] == [self getCountDataSource]) {
        [CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Oops!  Name and at least one other field required!"];
        return;
   // }
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
    [self.view endEditing:NO];
    if (isSelectedViewAddFields) {
        _addFieldView.hidden = YES;
        isSelectedViewAddFields = NO;
        return;
    }
    if (greyType == 0) {
        [CommonMethods showAlertUsingTitle:@"Ginko" andMessage:@"Oops!  You must select a category to register contact!"];
        return;
    }
    if (curContactDict) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GINKO" message:@"Do you want to make changes to this contact's info" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
        alert.tag = 2;
        [alert show];
        return;
    }
    [self addOrUpdateContact];
}


- (IBAction)onEdit:(id)sender
{
    [self reloadGreyDetails];
    tempDataSource = (NSMutableArray *)CFBridgingRelease(CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (CFPropertyListRef)arrDataSource, kCFPropertyListMutableContainers));
    [self showEditPane:YES];
}

- (IBAction)onClose:(id)sender
{
    [self.view endEditing:NO];
    if (isSelectedViewAddFields) {
        _addFieldView.hidden = YES;
    }
    [selectedRowsArray removeAllObjects];
    arrDataSource = (NSMutableArray *)CFBridgingRelease(CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (CFPropertyListRef)tempDataSource, kCFPropertyListMutableContainers));
    //arrDataSource = (NSMutableArray *)CFBridgingRelease(CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (CFPropertyListRef)tempDataSource, kCFPropertyListMutableContainers));
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
    [self showEditPane:NO];
    
    removedImage = NO;
    newImage = nil;
    NSURL * imageURL = [NSURL URLWithString:[curContactDict objectForKey:@"photo_url"]];
    [imgAvatar setImageWithURL:imageURL];
    [profileLogoImageView setImageWithURL:imageURL];
    
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
    [self colorTypeButtons];
    
    //if ([curContactDict objectForKey:@"is_favorite"]) {
        _btGreyFavorite.selected = isFavoriteStatus;
    //}
}
#pragma mark - AddFieldCellDelegate
- (void)didAddField:(NSString *)fieldName {
    for (int i = 0; i < [_fieldSelectionsArray[0] count]; i++) {
        if ([_fieldSelectionsArray[0][i] intValue] == 0) {
            if ([_allFieldNames[i] rangeOfString:fieldName].location != NSNotFound)
            {
                _fieldSelectionsArray[0][i] = @(1);
                break;
            }
        }
    }
    
    [self calculateFieldNames:0];
    [self calculateAddFieldNames:0];
    [_tables[0] reloadData];
    [_addFieldTable reloadData];
    
    if ([_addFieldNames count] == 0) {
        _addFieldView.hidden = YES;
    }
}
#pragma mark - TextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *text = textField.text;
    int newLength = (int)[text length] - (int)range.length + (int)string.length;
    if (textField.tag == 99) {
        if (newLength == 0) {
            btnDone.hidden = YES;
            btnDoneReal.hidden = YES;
            return YES;
        } else {
            BOOL isEmptyDataSource = NO;
            for (NSString *fieldName in _allFieldNames) {
                if (_fieldValuesArray[0][fieldName]) {
                    if ([_fieldValuesArray[0][fieldName] isEqualToString:@""]) {
                        isEmptyDataSource = YES;
                    }
                }
            }
            if (!isEmptyDataSource && [_fieldValuesArray[0] count] > 0) {
                if (greyType != 0) {
                    btnDone.hidden = NO;
                    btnDoneReal.hidden = NO;
                }
            }else{
                btnDone.hidden = YES;
                btnDoneReal.hidden = YES;
            }
            return YES;
        }
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 99) {
        [self.view endEditing:NO];
        return NO;
    }
    return  YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (curContactDict && !isEditing) {
        return NO;
    }
    if (textField.tag == 99) {
        [self fitToScroll];
        return YES;
    }
    
    return YES;
}
#pragma mark - tableview scroll up down
- (void)fitToScroll
{
    _greyDetailsScrollView.contentOffset = CGPointZero;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    //[self syncDataSource];
    return YES;
}
- (BOOL)isEmptyDatSource:(NSString *)changedText tag:(int)changedTag
{
    for (int i=0; i<20; i++) {
        NSMutableDictionary *dict = [arrDataSource objectAtIndex:i];
        if (changedTag == 100 * ([[dict objectForKey:@"name_index"] intValue] + 1)) {
            if (![changedText isEqualToString:@""]) {
                return NO;
            }
        } else if (![[(UITextField *)[self.view viewWithTag:100 *([[dict objectForKey:@"name_index"] intValue] + 1)] text] isEqualToString:@""]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - UITextView Delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([txtName.text isEqualToString:@""]) {
        btnDone.hidden = YES;
        btnDoneReal.hidden = YES;
        return YES;
    }
    int newLength = (int)textView.text.length - (int)range.length + (int)text.length;
    NSString *newText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if (newLength == 0) {
        if ([self isEmptyDatSource:newText tag:(int)textView.tag]) {
            btnDone.hidden = YES;
            btnDoneReal.hidden = YES;
            return YES;
        }
    }
    
    if (greyType != 0) {
        btnDone.hidden = NO;
        btnDoneReal.hidden = NO;
    }
    return YES;
}

//- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
//{
//    if (curContactDict && !tblInfo.editing) {
//        return NO;
//    }
//    
//    return YES;
//}
//
//- (void)textViewDidBeginEditing:(UITextView *)textView
//{
//    UITableViewCell *cell = (UITableViewCell *)[textView superview];
//    
//    NSLog(@"index = %ld, count = %d", [tblInfo indexPathForCell:cell].row, [self getCountDataSource]);
//    
//    [tblInfo scrollToRowAtIndexPath:[tblInfo indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
//}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [self syncDataSource];
    //    [self fitToScroll];
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    
}
- (IBAction)onFavorite:(id)sender {
//    if (lblContacttype.hidden == NO) {
//        return;
//    }
    [self.view endEditing:NO];
    _btGreyFavorite.selected = !_btGreyFavorite.selected;
    if (!btnEdit.hidden) {
        if (_btGreyFavorite.selected) {
            isFavoriteStatus = YES;
            [[AppDelegate sharedDelegate] addFavoriteContact:[curContactDict objectForKey:@"contact_id"] contactType:@"2"];
        }else{
            isFavoriteStatus = NO;
            [[AppDelegate sharedDelegate] removeFavoriteContact:[curContactDict objectForKey:@"contact_id"] contactType:@"2"];
        }
    }
}

- (IBAction)onCloseProfilelogoPreview:(id)sender {
    CATransition *transition = [CATransition animation];
    transition.duration = 2.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [profileLogoContainerView.layer addAnimation:transition forKey:nil];
    profilelogoPreView.hidden = YES;
    profileLogoContainerView.hidden = YES;
}

- (IBAction)onOpenProfilelogoPreview:(id)sender {
    if (!isEditing) {
        profilelogoPreView.hidden = NO;
        CATransition *transition = [CATransition animation];
        transition.duration = 1.0f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionReveal;
        [profileLogoContainerView.layer addAnimation:transition forKey:nil];
        profileLogoContainerView.hidden = NO;
        
        return;
    }
    if (!isEditing && curContactDict) {
        return;
    }
    [self.view endEditing:NO];
    //[self fitToScroll];
    
    UIActionSheet *actionSheet;
    if (!removedImage && ((curContactDict && [curContactDict[@"photo_url"] rangeOfString:@"greyblank"].location == NSNotFound )|| newImage)) { // photo exists
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"Add your photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Take a Photo" otherButtonTitles:@"Photo From Gallery", @"Remove photo", nil];
        actionSheet.destructiveButtonIndex = 2;
    } else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"Add your photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a Photo", @"Photo From Gallery", nil];
    }
    
    [actionSheet showInView:self.view];
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
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
//    if ([touch.view isKindOfClass:[UIScrollView class]]) {
//        return YES;
//    }else {
//        return NO;
//    }
//    return YES;
//}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if([touch.view isKindOfClass:[UITableViewCell class]]) {
        return NO;
    }
    // UITableViewCellContentView => UITableViewCell
    if([touch.view.superview isKindOfClass:[UITableViewCell class]]) {
        return NO;
    }
    // UITableViewCellContentView => UITableViewCellScrollView => UITableViewCell
    if([touch.view.superview.superview isKindOfClass:[UITableViewCell class]]) {
        return NO;
    }
    if([touch.view isKindOfClass:[UITextField class]]) {
        return NO;
    }
    if([touch.view isKindOfClass:[SAMTextView class]]) {
        return NO;
    }
    return YES;
}
- (void) hideKeyboard{
    [self.view endEditing:NO];
}
@end
