//
//  AddInfoOfSubEntityViewController.m
//  ginko
//
//  Created by stepanekdavid on 4/17/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "AddInfoOfSubEntityViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "LocalDBManager.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+Resize.h"
#import "FieldTableCell.h"
#import "FieldTableTextViewCell.h"
#import "AddFieldCell.h"
#import "ProfileNamePictureCell.h"
#import "EntityDescriptionCell.h"
#import "WallpaperVideoCell.h"
#import "VideoPickerController.h"
#import "GreyClient.h"
#import "YYYCommunication.h"
#import "WallpaperEditViewController.h"
#import "ProfileImageEditViewController.h"
#import "PreviewEntityViewController.h"
#import "AddSubEntitiesViewController.h"
#import "CISyncContactsViewController.h"
#import "ContactImporterClient.h"

#import "VideoVoiceConferenceViewController.h"

#define TAG_LOGO_IMAGE   1000
#define TAG_WALLPAPER       1001
#define TAG_VIDEO           1002

@interface AddInfoOfSubEntityViewController () <ProfileNamePictureCellDelegate, WallpaperVideoCellDelegate, FieldTableCellDelegate, FieldTableTextViewCellDelegate, UIActionSheetDelegate, VideoPickerControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, WallpaperEditViewControllerDelegate, ProfileImageEditViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, EntityDescriptionCellDelegate, UIAlertViewDelegate, AddFieldCellDelegate> {
    // yes if keyboard is shown
    BOOL _keyboardShown;
    
    NSMutableArray *_fieldTableArray;
    
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
    
    int _photoMode;
    
    MBProgressHUD *_downloadProgressHUD; // Download progress hud for video
    
    // video player
    MPMoviePlayerViewController *_playerVC;
    
    // index path that should be first responder
    NSIndexPath *_nextIndexPathBeFirstResponder;
    
    // temp image views for loading images in background
    UIImageView *_tempLogoImageView, *_tempSnapshotImageView, *_tempWallpaperImageView;
    
    // width and height constraint for table
    NSLayoutConstraint *_tableWidth, *_tableHeight;
    
    // save created entity id in case the error happens when uploading photo or video
    NSString *_createdEntityId;
    
    BOOL _addressConfirmed;
    CLLocation *_location;
    
    NSIndexPath *currentIndexCell;
}
@end

@implementation AddInfoOfSubEntityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackArrow"] style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    
    currentIndexCell = nil;
    
    UITableView *table = [[UITableView alloc] initWithFrame:_entityScrollView.bounds];
    table.translatesAutoresizingMaskIntoConstraints = NO;
    table.delegate = self;
    table.dataSource = self;
    _tables = [NSMutableArray new];
    [_tables addObject:table];
    
    [_entityScrollView addSubview:table];
    
    NSDictionary *viewsDic = @{@"table": table};
    
    [_entityScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[table]|" options:kNilOptions metrics:0 views:viewsDic]];
    [_entityScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[table]|" options:kNilOptions metrics:0 views:viewsDic]];
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
    
        // right bar button is next
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(goDone:)];
    
    // add field table background is clear color
    _addFieldTable.backgroundColor = [UIColor clearColor];
    
    [self initialize];
    
    _nextIndexPathBeFirstResponder = nil;
    
    if ([_entityData[@"infos"] count] > 1) {
        _deleteButton.hidden = NO;
    }
}

- (void)viewDidLayoutSubviews {
    _tableWidth.constant = CGRectGetWidth(_entityScrollView.bounds);
    _tableHeight.constant = CGRectGetHeight(_entityScrollView.bounds);
}

- (void)initialize {
    // set navigation bar title
    if (_isCreate) {
        self.title = @"Create Entity Profile";
    } else {
        self.title = @"Edit Entity Profile";
    }
    
    NSArray *fieldsArray = nil;
    
    if (_entityData && [_entityData[@"infos"] count] > 0 && [_entityData[@"infos"][_indexOfSubEntity][@"fields"] count] > 0) {
        fieldsArray = _entityData[@"infos"][_indexOfSubEntity][@"fields"];
    }
    // total field name array
    _allFieldNames = @[@"Mobile", @"Mobile#2", @"Mobile#3", @"Phone", @"Phone#2", @"Phone#3", @"Email", @"Email#2", @"Address", @"Fax", @"Hours", @"Birthday", @"Facebook", @"Twitter", @"LinkedIn", @"Website", @"Custom", @"Custom#2", @"Custom#3"];
    
    // initialize value dictionary array
    _fieldValuesArray = [NSMutableArray new];
    
    //
    [_fieldValuesArray addObject:[NSMutableDictionary new]];
    
    _fieldNamesArray = [NSMutableArray new];
    
    [_fieldNamesArray addObject:[NSMutableArray new]];
    
        // selection array
    _fieldSelectionsArray = [NSMutableArray new];
    
    [_fieldSelectionsArray addObject:[NSMutableArray new]];
    
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
    
    // calculate field names
    [self calculateFieldNames:0];
    [self calculateAddFieldNames:0];
    
    // hide add field at first
    _addFieldView.hidden = YES;
    
    [_tables[0] reloadData];
}
- (void)cancel:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // register keyboard observers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // unregister keyboard observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (IBAction)addField:(id)sender {
    [self.view endEditing:NO];
    
    [self calculateAddFieldNames:0];
    [_addFieldTable reloadData];
    _addFieldView.hidden = NO;
}

- (IBAction)hideAddFieldView:(id)sender {
    _addFieldView.hidden = YES;
}

- (IBAction)deleteLocation:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Do you want to delete this location?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    alert.tag = 300;
    [alert show];
}
- (void)goDone:(id)sender {
    [self.view endEditing:NO];
    
    // save and pop
    // validation
    if (((!_fieldValuesArray[0][@"Email"] || [_fieldValuesArray[0][@"Email"] isEqualToString:@""]) && (!_fieldValuesArray[0][@"Mobile"] || [_fieldValuesArray[0][@"Mobile"] isEqualToString:@""]) && (!_fieldValuesArray[0][@"Address"] || [_fieldValuesArray[0][@"Address"] isEqualToString:@""]))) {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Please fill all fields." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
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
                [self saveEntity];
            } else {
                //[[[UIAlertView alloc] initWithTitle:@"Oh no!" message:@"Cannot find the location from the address! Please retype the address field." delegate:self cancelButtonTitle:@"Skip" otherButtonTitles:@"OK", nil] show];
                [[[UIAlertView alloc] initWithTitle:@"Oh no!" message:@"Cannot find the location from the address! Please retype the address field." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
            }
        }];
    } else {
        [self saveEntity];
    }
}

- (void)saveEntity {
    
    NSMutableArray *fields = [NSMutableArray new];
    for (NSString *key in _fieldValuesArray[0]) {
        [fields addObject:@{@"field_name": key, @"field_value": _fieldValuesArray[0][key], @"field_type": [self getFieldTypeForFieldName: key]}];
    }
    
    NSMutableDictionary *dictInformation = [[NSMutableDictionary alloc] init];
    [dictInformation setObject:fields forKey:@"fields"];
    
    if (_addressConfirmed) {
        dictInformation[@"address_confirmed"] = @1;
        dictInformation[@"latitude"] = @(_location.coordinate.latitude);
        dictInformation[@"longitude"] = @(_location.coordinate.longitude);
    } else {
        dictInformation[@"address_confirmed"] = @0;
        dictInformation[@"latitude"] = @0;
        dictInformation[@"longitude"] = @0;
    }
    if (_entityData[@"infos"][_indexOfSubEntity][@"info_id"] && ![_entityData[@"infos"][_indexOfSubEntity][@"info_id"] isKindOfClass:[NSNull class]]) {
        if ([_entityData[@"infos"][_indexOfSubEntity][@"info_id"] integerValue] > 0) {
            dictInformation[@"info_id"] =  _entityData[@"infos"][_indexOfSubEntity][@"info_id"];
        }
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(didFinishAddSubEntity:)])
        [_delegate didFinishAddSubEntity:dictInformation];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
-(void)deleteLocationOfMainEntity{
    if (!_isCreate) {
        /*
        if (_entityData[@"infos"][_indexOfSubEntity][@"info_id"]) {
            [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            
            void (^successed)( id _responseObject ) = ^(id _responseObject ) {
                [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                
                if ([[_responseObject objectForKey:@"success"] boolValue]) {
                    if (_delegate && [_delegate respondsToSelector:@selector(deletedLocationOfEntity:)])
                        [_delegate deletedLocationOfEntity:_indexOfSubEntity];
                    
                    [self.navigationController popViewControllerAnimated:YES];
                }
            };
            
            void (^failure)(NSError* _error) = ^(NSError* _error) {
                [ MBProgressHUD hideHUDForView:self.view animated : YES ] ;
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to delete Location, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            };
            [[YYYCommunication sharedManager] DeleteLocation:[AppDelegate sharedDelegate].sessionId
                                                    entityid:_entityData[@"entity_id"]
                                                      infoid:_entityData[@"infos"][_indexOfSubEntity][@"info_id"]
                                                   successed:successed
                                                     failure:failure];

        }else{
         */
            if (_delegate && [_delegate respondsToSelector:@selector(deletedLocationOfEntity:)])
                [_delegate deletedLocationOfEntity:_indexOfSubEntity];
            
            [self.navigationController popViewControllerAnimated:YES];
        //}
        
    }else{
        if (_delegate && [_delegate respondsToSelector:@selector(deletedLocationOfEntity:)])
            [_delegate deletedLocationOfEntity:_indexOfSubEntity];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    
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
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:NO];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:_addFieldTable]) {
        if (_addFieldNames.count == 0) {
            [self hideAddFieldView:self];
        }
        return [_addFieldNames count];
    }
    
    return [_fieldNamesArray[0] count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_nextIndexPathBeFirstResponder && [indexPath compare:_nextIndexPathBeFirstResponder] == NSOrderedSame) {
        if ([cell isKindOfClass:[FieldTableCell class]])
            [((FieldTableCell *)cell).textField becomeFirstResponder];
        else if ([cell isKindOfClass:[FieldTableTextViewCell class]])
            [((FieldTableTextViewCell *)cell).textView becomeFirstResponder];
        else if ([cell isKindOfClass:[EntityDescriptionCell class]])
            [((EntityDescriptionCell *)cell).descTextView becomeFirstResponder];
        _nextIndexPathBeFirstResponder = nil;
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
    // if textview cell
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
        
        if ([_fieldNamesArray[0][indexPath.row] rangeOfString:@"Address"].location != NSNotFound){
            cell.iconImage.image = [UIImage imageNamed:@"field_icon_grey_address"];
            cell.deleteButton.hidden = YES;
        }
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

- (void)refreshAddFieldCell:(AddFieldCell *)cell fieldName:(NSString *)fieldName {
    if ([fieldName isEqualToString:@"Mobile"]) {
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
    } else if ([fieldName rangeOfString:@"Hours"].location != NSNotFound) {
        fieldType = @"hours";
    } else if ([fieldName rangeOfString:@"Address"].location != NSNotFound) {
        fieldType = @"address";
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:_addFieldTable]) {
        return;
    }
    if (indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2)
        [self.view endEditing:NO];
    if (indexPath.section == 3) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[FieldTableCell class]])
            [((FieldTableCell *)cell).textField becomeFirstResponder];
        else if ([cell isKindOfClass:[FieldTableTextViewCell class]])
            [((FieldTableTextViewCell *)cell).textView becomeFirstResponder];
    }
}

#pragma mark - FieldTableCellDelegate
- (void)fieldTableCellDeleteField:(FieldTableCell *)cell {
    [self.view endEditing:NO];
    NSUInteger index = [_allFieldNames indexOfObject:cell.textField.placeholder];
    
    if (index == NSNotFound)
        return;
    
    _fieldSelectionsArray[0][index] = @(0);
    [_fieldValuesArray[0] removeObjectForKey:cell.textField.placeholder];
    
    [self calculateFieldNames:0];
    
    [_tables[0] reloadData];
}

- (void)fieldTableCell:(FieldTableCell *)cell textDidChange:(NSString *)text {
    _fieldValuesArray[0][cell.textField.placeholder] = text;
}

- (void)fieldTableCellTextFieldShouldBeginEditing:(FieldTableCell *)cell{
    
    currentIndexCell = [_tables[0] indexPathForCell:cell];
    //    NSLog(@"currentIndex------%ld",(long)currentIndexCell.row);
    //    NSLog(@"cellcount------%lu",(unsigned long)[_fieldNamesArray[0] count]);
    NSLog(@"selected cell");
    
    if (currentIndexCell.row == [_fieldNamesArray[0] count]-1) { //changed
        cell.textField.returnKeyType = UIReturnKeyDone;
    }
}
//- (void)fieldtableCellTextfieldShouldEndEditing:(FieldTableCell *)cell{
//    currentIndexCell = nil;
//    NSLog(@"deselected cell");
//}
-(void)fieldTableCellTextFieldDidBeginEditing:(FieldTableCell *)cell{
    currentIndexCell = [_tables[0] indexPathForCell:cell];
    //NSLog(@"currentIndex------%ld",(long)currentIndexCell.row);
    //NSLog(@"selected cell");
}
- (void)fieldTableCellTextFieldDidReturn:(FieldTableCell *)cell {
    if (cell.textField.returnKeyType == UIReturnKeyDone) {
        // right bar button is next
        [self goDone:nil];
    }
    
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
    [self.view endEditing:NO];
    NSUInteger index = [_allFieldNames indexOfObject:cell.textView.placeholder];
    
    if (index == NSNotFound)
        return;
    
    _fieldSelectionsArray[0][index] = @(0);
    [_fieldValuesArray[0] removeObjectForKey:cell.textView.placeholder];
    
    [self calculateFieldNames:0];
    
    [_tables[0] reloadData];
}

- (void)fieldTableTextViewCell:(FieldTableTextViewCell *)cell textDidChange:(NSString *)text {
    [UIView setAnimationsEnabled:NO];
    [_tables[0] beginUpdates];
    [_tables[0] endUpdates];
    [UIView setAnimationsEnabled:YES];
    
    _fieldValuesArray[0][cell.textView.placeholder] = text;
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

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
        return;
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex) {
        if (alertView.tag == 300) {
            [self deleteLocationOfMainEntity];
            return;
        }
        [self saveEntity];
    }
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
    [self.navigationController pushViewController:viewcontroller animated:YES];
    if (_isCreate) {
        [self.navigationController.navigationBar setBarTintColor:COLOR_GREEN_THEME];
    }

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
- (void)moveRedirectCISyncContactsViewController:(NSString *)redirectURL{
    //com.ginko.app://sync/redirect?code=4/t2LkZQb2CqtGggbUzwYL6Zi3zjio.4g5M6ypzggIWgrKXntQAax1-HNgXjwI
    NSRange range;
    //    switch (type) {
    //        case 100:
    //        case 101:
    //            range = [redirectURL rangeOfString:@"oauth_verifier"];
    //            break;
    //        case 102:
    //            range = [redirectURL rangeOfString:@"access_token"];
    //            break;
    //        case 103:
    //            range = [redirectURL rangeOfString:@"code"];
    //            break;
    //        default:
    //            break;
    //    }
    range = [redirectURL rangeOfString:@"redirect?"];
    
    NSString *code = @"";
    
    if (!(range.location == NSNotFound)) {
        code = [redirectURL substringFromIndex:range.location + range.length];
        NSLog(@"code = %@", code);
    }
    
    void (^successed)(id responseObject) = ^(id responseObject) {
        NSDictionary *result = responseObject;
        
        NSLog(@"sync contact result = %@", result);
        
        if ([[result objectForKey:@"success"] boolValue]) {
            
            NSMutableArray *arrContacts = [[NSMutableArray alloc] init];
            NSArray *contactsArray = [result objectForKey:@"data"];
            
            for (NSDictionary *dict in contactsArray) {
                [arrContacts addObject:[[NSMutableDictionary alloc] initWithDictionary:dict]];
            }
            
           // [self addToGlobalArray:arrContacts];
            
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
    
    if (![code isEqualToString:@""]) {
       // [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeClear];
       // [[ContactImporterClient sharedClient] syncContactByOAuth:[AppDelegate sharedDelegate].sessionId email:txtEmail.text provider:provider code:code successed:successed failure:failure];
    }
}
@end

