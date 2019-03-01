//
//  ManageEntityViewController.m
//  ginko
//
//  Created by Harry on 1/13/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "ManageEntityViewController.h"
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
#import "VideoVoiceConferenceViewController.h"

#import "YYYChatViewController.h"

#define TAG_LOGO_IMAGE   1000
#define TAG_WALLPAPER       1001
#define TAG_VIDEO           1002

@interface ManageEntityViewController () <ProfileNamePictureCellDelegate, WallpaperVideoCellDelegate, FieldTableCellDelegate, FieldTableTextViewCellDelegate, UIActionSheetDelegate, VideoPickerControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, WallpaperEditViewControllerDelegate, ProfileImageEditViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, EntityDescriptionCellDelegate, UIAlertViewDelegate, AddFieldCellDelegate, AddSubEntitiesViewControllerDelegate> {
    // yes if keyboard is shown
    BOOL _keyboardShown;
    
    NSMutableArray *_fieldTableArray;
    
    // All field names (_allFieldNames - _fieldSelections)
    NSArray *_allFieldNames;
    
    // int array: 0: not included, 1: included, 2: mandatory and cannot be deleted
    // array of array
    NSMutableArray *_fieldSelectionsArray;
    
    // entity name
    NSString *_entityName;
    
    // entity description
    NSString *_entityDescription;
    
    // entity privilege
    int _entityPrivilege;
    
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
    
    // logo image
    UIImage *_logoImage;
    
    // profile wallpaper
    UIImage *_wallpaperImage;
    
    // wallpaper image id
    NSString *_wallpaperImageId;
    
    // video data(only used when create to upload later)
    NSData *_videoData;
    
    // video snapshot
    UIImage *_snapshotImage;
    
    // remote video url
    NSString *_videoUrl;
    
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
    
    BOOL _isSelectedAddSubEntity;
    
    BOOL _isAddressField;
}
@end

@implementation ManageEntityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    currentIndexCell = nil;
    _isSelectedAddSubEntity = NO;
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
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    if (_isCreate && !_isMultiLocation){
        // right bar button is next
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(goNext:)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackArrow"] style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    }
    else{
        // right bar button is next
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(goDone:)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    }
    
    // add field table background is clear color
    _addFieldTable.backgroundColor = [UIColor clearColor];
    
    [self initialize];
    
    _nextIndexPathBeFirstResponder = nil;
}

- (void)viewDidLayoutSubviews {
    _tableWidth.constant = CGRectGetWidth(_entityScrollView.bounds);
    _tableHeight.constant = CGRectGetHeight(_entityScrollView.bounds);
}

- (void)initialize {
    // set navigation bar title
    if (_isCreate&& !_isMultiLocation) {
        self.title = @"Create Entity Profile";
        _subEntityAddButton.hidden = NO;
    } else {
        self.title = @"Edit Entity Profile";
        _subEntityAddButton.hidden = _isSubEntity;
    }
    
    NSArray *fieldsArray = [NSArray new];
    if (_currentIndex) {
        fieldsArray = (_entityData != nil) ? ([_entityData[@"infos"] count] > 0 ? _entityData[@"infos"][_currentIndex][@"fields"] : nil) : nil;
    }else{
        fieldsArray = (_entityData != nil) ? ([_entityData[@"infos"] count] > 0 ? _entityData[@"infos"][0][@"fields"] : nil) : nil;
    }
    
    if (_entityData[@"entity_id"]) {
        _createdEntityId = _entityData[@"entity_id"];
    }
    
    // hide lock notice label at first, max alpha is 0.8
    _lockNoticeLabel.alpha = 0;
    
    // total field name array
    _allFieldNames = @[@"Mobile", @"Mobile#2", @"Mobile#3", @"Phone", @"Phone#2", @"Phone#3", @"Email", @"Email#2", @"Address", @"Fax", @"Hours", @"Birthday", @"Facebook", @"Twitter", @"LinkedIn", @"Website", @"Custom", @"Custom#2", @"Custom#3"];
    
    _lockButton.selected = NO;
    
    // initialize value dictionary array
    _fieldValuesArray = [NSMutableArray new];
    
    //
    [_fieldValuesArray addObject:[NSMutableDictionary new]];
    
    _fieldNamesArray = [NSMutableArray new];
    
    [_fieldNamesArray addObject:[NSMutableArray new]];
    
    // name
    _entityName = _entityData ? _entityData[@"name"] : @"";
    
    // description
    _entityDescription = _entityData ? _entityData[@"description"] : @"";
    
    // privilege
    _entityPrivilege = (_entityData && _entityData[@"privilege"]) ? [_entityData[@"privilege"] intValue] : 1;
    _lockButton.selected = (BOOL)_entityPrivilege;
    
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
    
    __weak UITableView *weakFieldTable = _tables[0];
    
    // profile image
    _logoImage = nil;
    if (_entityData) {
        // parse profile image
        NSString *profileImageUrl = _entityData[@"profile_image"];
        
        if (profileImageUrl && ![profileImageUrl isEqualToString:@""]) {
            NSString *localFilePath = [LocalDBManager checkCachedFileExist:profileImageUrl];
            if (localFilePath) {
                // load from local
                _logoImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:localFilePath]];
            } else {
                _logoImage = [UIImage imageNamed:@"entity_add_logo"];
                _tempLogoImageView = [UIImageView new];
                [_tempLogoImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:profileImageUrl]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                    _logoImage = image;
                    [LocalDBManager saveImage:image forRemotePath:profileImageUrl];
                    [weakFieldTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to load entity image." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }];
            }
        }
    }
    
    // profile wallpaper
    _wallpaperImage = nil;
    // wallpaper image id
    _wallpaperImageId = nil;
    if (_entityData) {
        /*
        if (_isCreate && !_isMultiLocation) {
            NSString *wallpaperImageUrl = _entityData[@"wallpaper_image"];
            
            if (wallpaperImageUrl && ![wallpaperImageUrl isEqualToString:@""]) {
                NSString *localFilePath = [LocalDBManager checkCachedFileExist:wallpaperImageUrl];
                if (localFilePath) {
                    // load from local
                    _wallpaperImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:localFilePath]];
                } else {
                    _wallpaperImage = [UIImage imageNamed:@"add_wallpaper"];
                }
            }
        }else{
         */
        NSArray *imagesArray = _entityData[@"images"];
        
        for (NSDictionary *imageDic in imagesArray) {
            if ([imageDic[@"z_index"] intValue] == 0) { // this is background
                NSString *wallpaperImageUrl = imageDic[@"image_url"];
                
                if (wallpaperImageUrl && ![wallpaperImageUrl isEqualToString:@""]) {
                    _wallpaperImageId = imageDic[@"image_id"];
                    NSString *localFilePath = [LocalDBManager checkCachedFileExist:wallpaperImageUrl];
                    if (localFilePath) {
                        // load from local
                        _wallpaperImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:localFilePath]];
                    } else {
                        _wallpaperImage = [UIImage imageNamed:@"add_wallpaper"];
                        _tempWallpaperImageView = [UIImageView new];
                        [_tempWallpaperImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:wallpaperImageUrl]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                            _wallpaperImage = image;
                            [LocalDBManager saveImage:image forRemotePath:wallpaperImageUrl];
                            [weakFieldTable reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to load wallpaper image." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                        }];
                    }
                }
            }
        }
        //}
    }
    
    // video snapshot
    _snapshotImage = nil;
    _videoUrl = nil;
    if (_entityData) {
        if (_entityData[@"video_url"] && ![_entityData[@"video_url"] isEqualToString:@""]) {
            // video exists
            _videoUrl = _entityData[@"video_url"];
            // load snapshot image
            NSString *thumbnailUrl = _entityData[@"video_thumbnail_url"];
            if (thumbnailUrl && ![thumbnailUrl isEqualToString:@""]) {
                NSString *localFilePath = [LocalDBManager checkCachedFileExist:thumbnailUrl];
                if (localFilePath) {
                    // load from local
                    _snapshotImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:localFilePath]];
//                    _snapshotImage = [_snapshotImage imageByCombiningImage:[[UIImage imageNamed:@"play_video_button"] resizedImage:CGSizeMake(_snapshotImage.size.height / 4, _snapshotImage.size.height / 4) interpolationQuality:kCGInterpolationDefault]];
                } else {
                    _snapshotImage = [UIImage imageNamed:@"add_profile_video"];
                    _tempSnapshotImageView = [UIImageView new];
                    [_tempSnapshotImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:thumbnailUrl]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                        _snapshotImage = image;
//                        _snapshotImage = [_snapshotImage imageByCombiningImage:[[UIImage imageNamed:@"play_video_button"] resizedImage:CGSizeMake(_snapshotImage.size.height / 4, _snapshotImage.size.height / 4) interpolationQuality:kCGInterpolationDefault]];
                        [LocalDBManager saveImage:image forRemotePath:thumbnailUrl];
                        [weakFieldTable reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
                    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to load video snapshot image." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    }];
                }
            }
        }
    }
    
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

- (IBAction)doLockOrUnlock:(id)sender {
    _lockButton.selected = !_lockButton.selected;
    _lockNoticeLabel.text = (_lockButton.selected) ? @"Entity is public" : @"Entity is private";
    _lockNoticeLabel.alpha = 0.8f;
    [UIView animateWithDuration:0.5 delay:1.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _lockNoticeLabel.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)subEntityAdd:(id)sender{
    [self.view endEditing:NO];
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
                [self createTmpDictionary];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oh no!" message:@"Cannot find the location from the address! Please retype the address field." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                alert.tag = 1001;
                [alert show];
            }
        }];
    } else {
        [self createTmpDictionary];
    }
    
    
}
- (void)createTmpDictionary{
    NSLog(@"%@",_fieldValuesArray[0][@"Email"]);
    if ((_fieldValuesArray[0][@"Email"] && ![_fieldValuesArray[0][@"Email"] isEqualToString:@""]) || (_fieldValuesArray[0][@"Email#2"] && ![_fieldValuesArray[0][@"Email#2"] isEqualToString:@""])) {
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

    }
        AddSubEntitiesViewController *vc = [[AddSubEntitiesViewController alloc] initWithNibName:@"AddSubEntitiesViewController" bundle:nil];
    if (_isCreate) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        dict[@"description"] = _entityDescription;
        dict[@"name"] = _entityName;
        
        if (_createdEntityId) {
            dict[@"entity_id"] = _createdEntityId;
        }
        
        NSMutableArray *lstPostBody = [[NSMutableArray alloc] init];
        
        NSMutableArray *fields = [NSMutableArray new];
        _isAddressField = NO;
        for (int i = 0; i<[_fieldNamesArray[0] count]; i ++) {
            NSString *key = _fieldNamesArray[0][i];
            if (_fieldValuesArray[0][key] && ![_fieldValuesArray[0][key] isEqualToString:@""]) {
                if ([key isEqual:@"Address"])
                    _isAddressField = YES;
                
                [fields addObject:@{@"field_name": key, @"field_value": _fieldValuesArray[0][key]?_fieldValuesArray[0][key]:@"", @"field_type": [self getFieldTypeForFieldName: key]}];
            }
        }
        if ([fields count] == 0) {
            for (int i = 0; i<[_fieldNamesArray[0] count]; i ++) {
                NSString *key = _fieldNamesArray[0][i];
                if ([key isEqual:@"Address"])
                    _isAddressField = YES;
                [fields addObject:@{@"field_name": key, @"field_value": _fieldValuesArray[0][key]?_fieldValuesArray[0][key]:@"", @"field_type": [self getFieldTypeForFieldName: key]}];
            }
        }
        if (!_isAddressField) {
            [fields addObject:@{@"field_name":@"Address",@"field_value":@"",@"field_type":@"address"}];
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
        if (_entityData[@"infos"] > 0 && _entityData[@"infos"][_currentIndex][@"info_id"]) {
            dictInformation[@"info_id"] = _entityData[@"infos"][_currentIndex][@"info_id"];
        }
        [lstPostBody addObject:dictInformation];
        
        [dict setObject:lstPostBody forKey:@"infos"];
        
        if (_logoImage) {
            [LocalDBManager saveImage:_logoImage forRemotePath:@"logoImagePathOfCreatingSubEntities"];
            dict[@"profile_image"] = @"logoImagePathOfCreatingSubEntities";
        }else{
            dict[@"profile_image"] = @"";
        }
        if (_wallpaperImage) {
            [LocalDBManager saveImage:_wallpaperImage forRemotePath:@"wallPaperImagePathOfCreatingSubEntities"];
            dict[@"wallpaper_image"] = @"wallPaperImagePathOfCreatingSubEntities";
        }else{
            dict[@"wallpaper_image"] = @"";
        }
        if (_videoData) {
            [LocalDBManager saveData:_videoData forRemotePath:@"videoPathOfCreatingSubEntities.mp4"];
            [LocalDBManager saveData:UIImageJPEGRepresentation(_snapshotImage, 1) forRemotePath:@"thumnailPathOfCreatingSubEntities"];
            dict[@"video_thumbnail_url"] = @"thumnailPathOfCreatingSubEntities";
            dict[@"video_url"] = @"videoPathOfCreatingSubEntities.mp4";
            vc._videoData_sub = _videoData;
            
        }else{
            
            dict[@"video_thumbnail_url"] = @"";
            dict[@"video_url"] = @"";
        }
        
        dict[@"privilege"] = [NSString stringWithFormat:@"%d", (int)_lockButton.selected];
        
        vc.entityData = dict;
        
    }else{
        NSMutableArray *lstPostBody = [[NSMutableArray alloc] init];
        
        NSMutableArray *fields = [NSMutableArray new];
        
        _isAddressField = NO;
        
        for (NSString *key in _fieldValuesArray[0]) {
            [fields addObject:@{@"field_name": key, @"field_value": _fieldValuesArray[0][key], @"field_type": [self getFieldTypeForFieldName: key]}];
            if ([key isEqual:@"Address"]) {
                _isAddressField = YES;
            }
        }
        if (!_isAddressField) {
            [fields addObject:@{@"field_name":@"Address",@"field_type":@"address",@"field_value":@""}];
        }
        NSMutableDictionary *dictInformation = [[NSMutableDictionary alloc] init];
        [dictInformation setObject:fields forKey:@"fields"];
        
        if (_entityData[@"infos"] > 0 && _entityData[@"infos"][_currentIndex][@"info_id"]) {
            dictInformation[@"info_id"] = _entityData[@"infos"][_currentIndex][@"info_id"];
        }
        if (_addressConfirmed) {
            dictInformation[@"address_confirmed"] = @1;
            dictInformation[@"latitude"] = @(_location.coordinate.latitude);
            dictInformation[@"longitude"] = @(_location.coordinate.longitude);
        } else {
            dictInformation[@"address_confirmed"] = @0;
            dictInformation[@"latitude"] = @0;
            dictInformation[@"longitude"] = @0;
        }
        //[lstPostBody addObject:dictInformation];
        
        lstPostBody =[_entityData[@"infos"] mutableCopy];
        [lstPostBody replaceObjectAtIndex:_currentIndex withObject:dictInformation];
        
        NSMutableDictionary *tmp = [_entityData mutableCopy];
        [tmp setObject:[lstPostBody mutableCopy] forKey:@"infos"];
        vc.entityData = tmp;
    }
    vc.isCreate = _isCreate;
    vc.isSetup = _isSetup;
    vc.delegate = self;
    vc.isMultiLocation = _isMultiLocation;
    [self.navigationController pushViewController:vc animated:YES];
    
}
- (IBAction)hideAddFieldView:(id)sender {
    _addFieldView.hidden = YES;
}

- (void)navigateToPreview {
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//        // get entity info for preview
//        void ( ^successed )( id _responseObject ) = ^( id _responseObject )
//        {
//            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
//            if ([_responseObject[@"success"] intValue] == 1) {
                PreviewEntityViewController *vc = [[PreviewEntityViewController alloc] initWithNibName:@"PreviewEntityViewController" bundle:nil];
                vc.isCreate = _isCreate;
                vc.entityId = _createdEntityId;
                [self.navigationController pushViewController:vc animated:YES];
//            } else {
//                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to get entity info, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//            }
//        };
//        
//        void ( ^failure )( NSError* _error ) = ^( NSError* _error )
//        {
//            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
//            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to get entity info, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//        };
//        
//        [[YYYCommunication sharedManager] GetEntityDetail:[AppDelegate sharedDelegate].sessionId
//                                                 entityid:_createdEntityId
//                                                successed:successed
//                                                  failure:failure];
//    });
}

- (void)goDone:(id)sender {
    [self.view endEditing:NO];
    
    // save and pop
    // validation
    if ((!_entityName || [_entityName isEqualToString:@""]) || ((!_fieldValuesArray[0][@"Email"] || [_fieldValuesArray[0][@"Email"] isEqualToString:@""]) && (!_fieldValuesArray[0][@"Mobile"] || [_fieldValuesArray[0][@"Mobile"] isEqualToString:@""]) && (!_fieldValuesArray[0][@"Address"] || [_fieldValuesArray[0][@"Address"] isEqualToString:@""]))) {
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
                [[[UIAlertView alloc] initWithTitle:@"Oh no!" message:@"Cannot find the location from the address! Please retype the address field." delegate:self cancelButtonTitle:@"Skip" otherButtonTitles:@"OK", nil] show];
            }
        }];
    } else {
        [self saveEntity];
    }
}

- (void)saveEntity {
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            // get entity info for preview
            void ( ^successed )( id _responseObject ) = ^( id _responseObject )
            {
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                if ([_responseObject[@"success"] intValue] == 1) {
                    if (_delegate && [_delegate respondsToSelector:@selector(didFinishEdit:)])
                        [_delegate didFinishEdit:_responseObject[@"data"]];
                    [self.navigationController popViewControllerAnimated:YES];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to get entity info, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }
            };
            
            void ( ^failure )( NSError* _error ) = ^( NSError* _error )
            {
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to get entity info, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            };
            
            [[YYYCommunication sharedManager] GetEntityDetail:[AppDelegate sharedDelegate].sessionId
                                                     entityid:_entityData[@"entity_id"]
                                                    successed:successed
                                                      failure:failure];
        });
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oh no!" message:@"Failed to save information. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    } ;
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    if (_wallpaperImage) {
        [images addObject:@{@"image_id": _wallpaperImageId, @"z_index": @0}];
    }
    
    NSMutableArray *lstPostBody = [[NSMutableArray alloc] init];
    
    NSMutableArray *fields = [NSMutableArray new];
    for (NSString *key in _fieldValuesArray[0]) {
        [fields addObject:@{@"field_name": key, @"field_value": _fieldValuesArray[0][key], @"field_type": [self getFieldTypeForFieldName: key]}];
    }
    
    NSMutableDictionary *dictInformation = [[NSMutableDictionary alloc] init];
    [dictInformation setObject:fields forKey:@"fields"];
    if ([_entityData[@"infos"] count] > 0){
        if (_entityData[@"infos"][_currentIndex][@"info_id"]) {
            dictInformation[@"info_id"] = _entityData[@"infos"][_currentIndex][@"info_id"];
        }
    }
    
    if (_addressConfirmed) {
        dictInformation[@"address_confirmed"] = @1;
        dictInformation[@"latitude"] = @(_location.coordinate.latitude);
        dictInformation[@"longitude"] = @(_location.coordinate.longitude);
    } else {
        dictInformation[@"address_confirmed"] = @0;
        dictInformation[@"latitude"] = @0;
        dictInformation[@"longitude"] = @0;
    }
    [lstPostBody addObject:dictInformation];
    
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    [[YYYCommunication sharedManager] UpdateEntity1:[AppDelegate sharedDelegate].sessionId
                                           entityid:_entityData[@"entity_id"]
                                               name:_entityName
                                        deleteInfos:@""
                                        description:_entityDescription
                                          keysearch:@""
                                         categoryid:@""
                                          privilege:[NSString stringWithFormat:@"%d", (int)_lockButton.selected]
                                              infos:lstPostBody
                                             images:images
                                          successed:successed
                                            failure:failure];
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
- (void)goNext:(id)sender {
    
    [self.view endEditing:NO];
    
    // validation
    if ((!_entityName || [_entityName isEqualToString:@""]) || ((!_fieldValuesArray[0][@"Email"] || [_fieldValuesArray[0][@"Email"] isEqualToString:@""]) && (!_fieldValuesArray[0][@"Mobile"] || [_fieldValuesArray[0][@"Mobile"] isEqualToString:@""]) && (!_fieldValuesArray[0][@"Address"] || [_fieldValuesArray[0][@"Address"] isEqualToString:@""]))) {
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
                [self createEntity];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Oh no!" message:@"Cannot find the location from the address! Please retype the address field." delegate:self cancelButtonTitle:@"Skip" otherButtonTitles:@"OK", nil] show];
            }
        }];
    } else {
        [self createEntity];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:NO];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([tableView isEqual:_addFieldTable])
        return 1;
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:_addFieldTable]) {
        if (_addFieldNames.count == 0) {
            [self hideAddFieldView:self];
        }
        return [_addFieldNames count];
    }
    
    if (section == 0 || section == 1 || section == 2) {
        return 1;
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
    
    switch (indexPath.section) {
        case 0: {
            ProfileNamePictureCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileNamePictureCell"];
            
            if (!cell) {
                [tableView registerNib:[UINib nibWithNibName:@"ProfileNamePictureCell" bundle:nil] forCellReuseIdentifier:@"ProfileNamePictureCell"];
                cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileNamePictureCell"];
            }
            
            cell.delegate = self;
            cell.roundCornerImage = NO;
            
            [cell setProfileImage:_logoImage placeholderImage:[UIImage imageNamed:@"entity_add_logo"]];
            
            cell.textField.placeholder = @"Name";
            cell.textField.text = _entityName;
            
            return cell;
        }
            break;
        case 1: {
            WallpaperVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WallpaperVideoCell"];
            
            if (!cell) {
                [tableView registerNib:[UINib nibWithNibName:@"WallpaperVideoCell" bundle:nil] forCellReuseIdentifier:@"WallpaperVideoCell"];
                cell = [tableView dequeueReusableCellWithIdentifier:@"WallpaperVideoCell"];
            }
            
            cell.delegate = self;
            
            [cell setWallpaper:_wallpaperImage];
            if (_snapshotImage)
                [cell setVideoSnapshot:[_snapshotImage imageByCombiningImage:[[UIImage imageNamed:@"play_video_button"] resizedImage:CGSizeMake(_snapshotImage.size.height / 4, _snapshotImage.size.height / 4) interpolationQuality:kCGInterpolationDefault]]];
            else
                [cell setVideoSnapshot:nil];
            
            return cell;
        }
            break;
        case 2:
        {
            EntityDescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EntityDescriptionCell"];
            
            if (!cell) {
                [tableView registerNib:[UINib nibWithNibName:@"EntityDescriptionCell" bundle:nil] forCellReuseIdentifier:@"EntityDescriptionCell"];
                cell = [tableView dequeueReusableCellWithIdentifier:@"EntityDescriptionCell"];
            }
            
            cell.delegate = self;
            cell.descTextView.text = _entityDescription;
            
            return cell;
        }
            break;
        default: {
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
                    //cell.deleteButton.hidden = YES;
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
            break;
    }
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
#pragma mark - ManageEntityViewControllerDelegate
- (void)returnMainEdit:(NSMutableDictionary *)entityData {
    _entityData = entityData;
    
    [self initialize];
}
#pragma mark - ProfileNamePictureCellDelegate
- (void)profileNameDidChange:(NSString *)text {
    [UIView setAnimationsEnabled:NO];
    [_tables[0] beginUpdates];
    [_tables[0] endUpdates];
    [UIView setAnimationsEnabled:YES];
    
    _entityName = text;
}

- (void)profileNameDidReturn {
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    [_tables[0] scrollToRowAtIndexPath:nextIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    UITableViewCell *cell = [_tables[0] cellForRowAtIndexPath:nextIndexPath];
    if (cell) {
        if ([cell isKindOfClass:[FieldTableCell class]])
            [((FieldTableCell *)cell).textField becomeFirstResponder];
        else if ([cell isKindOfClass:[FieldTableTextViewCell class]])
            [((FieldTableTextViewCell *)cell).textView becomeFirstResponder];
        else if ([cell isKindOfClass:[EntityDescriptionCell class]])
            [((EntityDescriptionCell *)cell).descTextView becomeFirstResponder];
    } else {
        _nextIndexPathBeFirstResponder = nextIndexPath;
    }
}

- (void)tapProfileImage:(ProfileNamePictureCell *)sender {
    [self.view endEditing:NO];
    _photoMode = TAG_LOGO_IMAGE;
    if (_logoImage) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Remove photo", @"Take entity photo", @"Choose from library", nil];
        actionSheet.destructiveButtonIndex = 0;
        [actionSheet showInView:self.view];
    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take entity photo", @"Choose from library", nil];
        [actionSheet showInView:self.view];
    }
}

#pragma mark - WallpaperVideoCellDelegate
- (void)tapWallpaper:(WallpaperVideoCell *)sender {
    [self.view endEditing:NO];
    _photoMode = TAG_WALLPAPER;
    if (_wallpaperImage) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Remove wallpaper", @"Take wallpaper photo", @"Choose from library", nil];
        actionSheet.destructiveButtonIndex = 0;
        [actionSheet showInView:self.view];
    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take wallpaper photo", @"Choose from library", nil];
        [actionSheet showInView:self.view];
    }
}

- (void)tapProfileVideo:(WallpaperVideoCell *)sender {
    if (_videoUrl || _videoData) { // video exists
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Remove video", @"Play video", nil];
        actionSheet.destructiveButtonIndex = 0;
        [actionSheet showInView:self.view];
        _photoMode = TAG_VIDEO;
    } else {
        VideoPickerController *viewController = [[VideoPickerController alloc] initWithType:3 entityID:nil isSetup:_isCreate];
        viewController.pickerDelegate = self;
        viewController.close = YES;
        [self presentViewController:viewController animated:YES completion:nil];
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
        if (_isCreate)
            // right bar button is next
            [self goNext:nil];
        else
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
    //CGRect rect = _entityScrollView.frame;
    CGPoint pt = [_tables[0] contentOffset];
    [UIView setAnimationsEnabled:NO];
    [_tables[0] beginUpdates];
    [_tables[0] endUpdates];
    [UIView setAnimationsEnabled:YES];
    _fieldValuesArray[0][cell.textView.placeholder] = text;
    if(text.length > 0 &&[[text substringFromIndex:text.length-1] isEqual:@"\n"]){
        pt.y += 20;
        [_tables[0] setContentOffset:pt animated:YES];
    }
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
    
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        if (_photoMode == TAG_LOGO_IMAGE)
            [self removePhoto];
        else if (_photoMode == TAG_WALLPAPER)
            [self removeWallpaper];
        else if (_photoMode == TAG_VIDEO) {
            [self removeVideo];
        }
        return;
    }
    
    if (_photoMode == TAG_VIDEO) {
        [self playVideo];
        return;
    }
    
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    
    if (buttonIndex == actionSheet.numberOfButtons - 3) {
        imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imgPicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
    } else if (buttonIndex == actionSheet.numberOfButtons - 2) {
        imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imgPicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
    }
    
    imgPicker.delegate = self;
    
    // [self saveData];
    [self presentViewController:imgPicker animated:YES completion:nil];
    
    [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

#pragma mark - API Helper methods

- (void)updateCreatedEntity {
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        // profile photo, video
        if (_logoImage) {
            [self uploadPhoto:_logoImage entityId:_createdEntityId completionHandler:^(BOOL success) {
                if (success) {
                    if (_videoData) {
                        [self uploadVideo:_videoData thumbnail:UIImageJPEGRepresentation(_snapshotImage, 1) entityId:_createdEntityId completionHandler:^(BOOL success) {
                            if (success) {
                                [self navigateToPreview];
                            } else {
                                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to upload video, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                            }
                        }];
                    } else {
                        [self navigateToPreview];
                    }
                } else {
                    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to upload entity photo, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }
            }];
        } else if (_videoData){
            [self uploadVideo:_videoData thumbnail:UIImageJPEGRepresentation(_snapshotImage, 1) entityId:_createdEntityId completionHandler:^(BOOL success) {
                if (success) {
                    [self navigateToPreview];
                } else {
                    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to upload video, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }
            }];
        } else {
            [self navigateToPreview];
        }
    };
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oh no!" message:@"Failed to save information. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    };
    
    NSMutableArray *lstPostBody = [[NSMutableArray alloc] init];
    
    NSMutableArray *fields = [NSMutableArray new];
    for (NSString *key in _fieldValuesArray[0]) {
        [fields addObject:@{@"field_name": key, @"field_value": _fieldValuesArray[0][key], @"field_type": [self getFieldTypeForFieldName: key]}];
    }
    
    NSMutableDictionary *dictInformation = [[NSMutableDictionary alloc] init];
    [dictInformation setObject:fields forKey:@"fields"];
    if (_entityData[@"infos"] > 0 && _entityData[@"infos"][_currentIndex][@"info_id"]) {
        dictInformation[@"info_id"] = _entityData[@"infos"][_currentIndex][@"info_id"];
    }
    
    if (_addressConfirmed) {
        dictInformation[@"address_confirmed"] = @1;
        dictInformation[@"latitude"] = @(_location.coordinate.latitude);
        dictInformation[@"longitude"] = @(_location.coordinate.longitude);
    } else {
        dictInformation[@"address_confirmed"] = @0;
        dictInformation[@"latitude"] = @0;
        dictInformation[@"longitude"] = @0;
    }

    [lstPostBody addObject:dictInformation];
    
    [[YYYCommunication sharedManager] UpdateEntity1:[AppDelegate sharedDelegate].sessionId
                                           entityid:_createdEntityId
                                               name:_entityName
                                        deleteInfos:@""
                                        description:_entityDescription
                                          keysearch:@""
                                         categoryid:@""
                                          privilege:[NSString stringWithFormat:@"%d", (int)_lockButton.selected]
                                              infos:lstPostBody
                                             images:nil
                                          successed:successed
                                            failure:failure];
}

- (void)createEntity {
    if (_createdEntityId) {
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [self updateCreatedEntity];
    } else {
        void (^successed)(id _responseObject) = ^(id _responseObject) {
            
            if ([[_responseObject objectForKey:@"success"] boolValue]) {
                _createdEntityId = _responseObject[@"data"][@"entity_id"];
                
                [self updateCreatedEntity];
            } else {
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to create entity, please try later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        };
        
        void (^failure)(NSError* _error) = ^(NSError* _error) {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            [[[UIAlertView alloc] initWithTitle:@"Oh no!" message:@"Internet Connection Error." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        };
        
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [[YYYCommunication sharedManager] SaveEntityPowerful:[AppDelegate sharedDelegate].sessionId
                                                  categoryid:[NSString stringWithFormat:@"%d",_category]
                                                        name:_entityName
                                                 description:_entityDescription
                                                   keysearch:@""
                                                  background:_wallpaperImage ? UIImageJPEGRepresentation(_wallpaperImage, 1) : nil
                                                  foreground:nil
                                                   successed:successed
                                                     failure:failure];
    }
}

- (void)removePhoto {
    if (!_isCreate || _createdEntityId) {
        void (^successed)(id responseObject) = ^(id responseObject) {
            NSDictionary *result = responseObject;
            
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            
            if ([[result objectForKey:@"success"] boolValue]) {
                _logoImage = nil;
                [_tables[0] reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            } else {
                NSDictionary *dictError = [result objectForKey:@"err"];
                if (dictError) {
                    [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:[dictError objectForKey:@"errMsg"]];
                } else {
                    [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Failed to connect to server!"];
                }
            }
        };
        
        void (^failure)(NSError* error) = ^(NSError* error) {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            
            [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Failed to connect to server!"];
        };
        
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [[GreyClient sharedClient] removeEntityPhoto:[AppDelegate sharedDelegate].sessionId entityID:!_isCreate ? _entityData[@"entity_id"] : _createdEntityId successed:successed failure:failure];
    } else {
        _logoImage = nil;
        [_tables[0] reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)removeWallpaper {
    if (!_isCreate || _createdEntityId) {
        void (^successed)(id _responseObject) = ^(id _responseObject)
        {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            if ([[_responseObject objectForKey:@"success"] boolValue]) {
                _wallpaperImage = nil;
                [_tables[0] reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
            } else {
                NSDictionary *dictError = [_responseObject objectForKey:@"err"];
                if (dictError) {
                    [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:[dictError objectForKey:@"errMsg"]];
                } else {
                    [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Failed to connect to server!"];
                }
            }
        };
        
        void (^failure )(NSError* _error) = ^(NSError* _error)
        {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oh no!" message:@"Failed to remove video. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            
            [alert show];
            return;
        };
        
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [[YYYCommunication sharedManager] RmoveEntityPhoto:[AppDelegate sharedDelegate].sessionId entityid:!_isCreate ? _entityData[@"entity_id"] : _createdEntityId imageid:_wallpaperImageId successed:successed failure:failure];
    } else {
        _wallpaperImage = nil;
        [_tables[0] reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)removeVideo {
    if (!_isCreate || _createdEntityId) {
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        void ( ^successed )( id _responseObject ) = ^( id _responseObject )
        {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            if ([[_responseObject objectForKey:@"success"] boolValue]) {
                _videoUrl = nil;
                _videoData = nil;
                _snapshotImage = nil;
                [_tables[0] reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
            } else {
                NSDictionary *dictError = [_responseObject objectForKey:@"err"];
                if (dictError) {
                    [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:[dictError objectForKey:@"errMsg"]];
                } else {
                    [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Failed to connect to server!"];
                }
            }
        } ;
        
        void ( ^failure )( NSError* _error ) = ^( NSError* _error )
        {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oh no!" message:@"Failed to remove video. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            
            [alert show];
            return;
        } ;
        
        [[YYYCommunication sharedManager] RmoveEntityVideo:[AppDelegate sharedDelegate].sessionId entityid:!_isCreate ? _entityData[@"entity_id"] : _createdEntityId successed:successed failure:failure];
    } else {
        _videoUrl = nil;
        _videoData = nil;
        _snapshotImage = nil;
        [_tables[0] reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)uploadPhoto:(UIImage *)img entityId:(NSString *)entityId completionHandler:(void(^)(BOOL success))completion {
    void (^successed)(id responseObject) = ^(id responseObject) {
        NSDictionary *result = responseObject;
        
        if ([[result objectForKey:@"success"] boolValue]) {
            // save to local cache
            [LocalDBManager saveImage:img forRemotePath:result[@"data"][@"profile_image"]];
            _logoImage = img;
            completion(YES);
        } else {
            completion(NO);
        }
    };
    
    void (^failure)(NSError* error) = ^(NSError* error) {
        completion(NO);
    };
    
    [[GreyClient sharedClient] uploadEntityPhoto:[AppDelegate sharedDelegate].sessionId entityID:entityId imgData:UIImageJPEGRepresentation(img, 1) successed:successed failure:failure];
}

- (void)uploadPhoto:(UIImage *)img {
    if (!_isCreate || _createdEntityId) {
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [self uploadPhoto:img entityId:!_isCreate ? _entityData[@"entity_id"] : _createdEntityId completionHandler:^(BOOL success) {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            if (success) {
                [_tables[0] reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to upload photo, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }];
    } else {
        _logoImage = img;
        [_tables[0] reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)uploadWallpaper:(UIImage *)img entityId:(NSString *)entityId completionHandler:(void(^)(BOOL success))completion {
    void (^successed)(id responseObject) = ^(id responseObject) {
        NSArray *response = [responseObject objectForKey:@"data"];
        
        if ([response count]) {
            NSDictionary *dict = [response objectAtIndex:0];
            
            // save to local path
            [LocalDBManager saveImage:img forRemotePath:dict[@"image_url"]];
            _wallpaperImageId = dict[@"image_id"];
            _wallpaperImage = img;
            completion(YES);
        } else {
            completion(NO);
        }
    };
    
    void (^failure)(NSError* error) = ^(NSError* error) {
        completion(NO);
    };
    
    [[YYYCommunication sharedManager] UploadMultipleImagesForEntity:[AppDelegate sharedDelegate].sessionId entityid:entityId background:UIImageJPEGRepresentation(img, 1.0) foreground:nil successed:successed failure:failure];
}

- (void)uploadWallpaper:(UIImage *)img {
    if (!_isCreate || _createdEntityId) {
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        
        [self uploadWallpaper:img entityId:!_isCreate ? _entityData[@"entity_id"] : _createdEntityId completionHandler:^(BOOL success) {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            if (success) {
                [_tables[0] reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oh no!" message:@"Failed to upload photos. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }
        }];
    } else {
        _wallpaperImage = img;
        
        [_tables[0] reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)uploadVideo:(NSData *)video thumbnail:(NSData *)thumb entityId:(NSString *)entityId  completionHandler:(void(^)(BOOL success))completion {
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            _videoData = video;
            _videoUrl = _responseObject[@"data"][@"video"];
            
            // save to local path
            [LocalDBManager saveData:thumb forRemotePath:_responseObject[@"data"][@"video_thumbnail_url"]];
            [LocalDBManager saveData:video forRemotePath:_videoUrl];

            _snapshotImage = [UIImage imageWithData:thumb];
//            _snapshotImage = [_snapshotImage imageByCombiningImage:[[UIImage imageNamed:@"play_video_button"] resizedImage:CGSizeMake(_snapshotImage.size.height / 4, _snapshotImage.size.height / 4) interpolationQuality:kCGInterpolationDefault]];
            completion(YES);
        } else {
            completion(NO);
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
        completion(NO);
    };
    
    [[YYYCommunication sharedManager] UploadEntityVideo:[AppDelegate sharedDelegate].sessionId entityid:entityId video:video thumbnail:thumb successed:successed failure:failure];
}
-(void)uploadVideo:(NSData*)video :(NSData *)thumb :(VideoPickerController*)pickerController
{
    if (!_isCreate || _createdEntityId) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[AppDelegate sharedDelegate].window animated:YES];
        [hud setLabelText:@"Uploading..."];
        [self uploadVideo:video thumbnail:thumb entityId:!_isCreate ? _entityData[@"entity_id"] : _createdEntityId completionHandler:^(BOOL success) {
            [MBProgressHUD hideHUDForView:[AppDelegate sharedDelegate].window animated:YES];
            if (success) {
                [pickerController dismissViewControllerAnimated:YES completion:^{
                    [_tables[0] reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
                }];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to upload video, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }];
    } else {
        _videoData = video;
        [pickerController dismissViewControllerAnimated:YES completion:^{
            _snapshotImage = [UIImage imageWithData:thumb];
//            _snapshotImage = [_snapshotImage imageByCombiningImage:[[UIImage imageNamed:@"play_video_button"] resizedImage:CGSizeMake(_snapshotImage.size.height / 4, _snapshotImage.size.height / 4) interpolationQuality:kCGInterpolationDefault]];
            [_tables[0] reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
    }
}

- (void)playVideo {
    if (_videoData) {
        [self playVideoAtLocalPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"ZipedVideo.mp4"]];
        return;
    }
    if (!_videoUrl)
        return;
    
    NSString *localFilePath = [LocalDBManager checkCachedFileExist:_videoUrl];
    if (localFilePath) { // exists in local
        [self playVideoAtLocalPath:localFilePath];
    } else {
        // save to temp directory
        NSURL *url = [NSURL URLWithString:_videoUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
        NSProgress *progress;
        
        _downloadProgressHUD = [MBProgressHUD showHUDAddedTo:[AppDelegate sharedDelegate].window animated:YES];
        _downloadProgressHUD.mode = MBProgressHUDModeDeterminate;
        
        NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            return [NSURL fileURLWithPath:[LocalDBManager getCachedFileNameFromRemotePath:_videoUrl]];
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            [progress removeObserver:self forKeyPath:@"fractionCompleted" context:NULL];
            [_downloadProgressHUD hide:YES];
            if (!error) {
                [self playVideoAtLocalPath:[LocalDBManager getCachedFileNameFromRemotePath:_videoUrl]];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not download video, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }];
        
        [downloadTask resume];
        [progress addObserver:self
                   forKeyPath:@"fractionCompleted"
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
    }
}

- (void)playVideoAtLocalPath:(NSString *)videoPath {
    _playerVC = [[MPMoviePlayerViewController alloc] init];
    
    _playerVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    _playerVC.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    _playerVC.moviePlayer.contentURL = [NSURL fileURLWithPath:videoPath];
    
    [self presentMoviePlayerViewControllerAnimated:_playerVC];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(640, 640) interpolationQuality:kCGInterpolationDefault];
    image = [image fixOrientation];
    
    if (![UIImageJPEGRepresentation(image, 1) writeToFile:TEMP_IMAGE_PATH atomically:YES]) {
        [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Failed to save information. Please try again."];
        return;
    }
    
    if (_photoMode == TAG_WALLPAPER) {
        WallpaperEditViewController *vc = [[WallpaperEditViewController alloc] initWithNibName:@"WallpaperEditViewController" bundle:nil];
        vc.sourceImage = image;
        vc.delegate = self;
        [picker pushViewController:vc animated:YES];
    } else {
        ProfileImageEditViewController *vc = [[ProfileImageEditViewController alloc] initWithNibName:@"ProfileImageEditViewController" bundle:nil];
        vc.isEntity = YES;
        vc.sourceImage = image;
        vc.delegate = self;
        [picker pushViewController:vc animated:YES];
        //        [picker dismissViewControllerAnimated:YES completion:^(void){
        //            if (_photoMode == TAG_PROFILE_IMAGE)
        //                [self uploadPhoto:image];
        //            else if (_photoMode == TAG_WALLPAPER)
        //                [self uploadWallpaper:image];
        //        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - VideoPickerControllerDelegate
- (void)videoPickerController:(VideoPickerController *)pickerController didSelectVideo:(NSURL *)videoURL {
    if (!videoURL)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Compression Failed. Please try again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"ZipedVideo.mp4",
                               nil];
    NSURL *outputURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[AppDelegate sharedDelegate].window animated:YES];
    [hud setLabelText:@"Exporting..."];
    [self convertVideoToLowQuailtyWithInputURL:videoURL outputURL:outputURL handler:^(AVAssetExportSession *exportSession)
     {
         [MBProgressHUD hideHUDForView:[AppDelegate sharedDelegate].window animated:YES];
         if (exportSession.status == AVAssetExportSessionStatusCompleted)
         {
             NSData *videoData = [NSData dataWithContentsOfURL:outputURL];
             UIImage *thumbnail = [self generateThumbImage:outputURL];
             if (thumbnail) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self uploadVideo:videoData :UIImageJPEGRepresentation(thumbnail, 1.0) :pickerController];
                 });
             } else {
                 [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to generate thumbnail for video. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
             }
         }
         else
         {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Video Compression Failed. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
             [alert show];
         }
     }];
}

- (void)videoPickerControllerDidCancel:(VideoPickerController *)pickerController {
    [pickerController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - Video processing helper methods
- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL
                                   outputURL:(NSURL*)outputURL
                                     handler:(void (^)(AVAssetExportSession*))handler
{
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    //    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.outputURL = outputURL;
    //    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(exportSession);
        });
    }];
}

-(UIImage *)generateThumbImage : (NSURL *)url
{
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform  = YES;
    CMTime time = [asset duration];
    time.value = 0;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
    
    return thumbnail;
}

#pragma mark - Download progress
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"fractionCompleted"]) {
        NSProgress *progress = (NSProgress *)object;
        NSLog(@"Progress… %f", progress.fractionCompleted);
        _downloadProgressHUD.progress = progress.fractionCompleted;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - WallpaperEditViewControllerDelegate
- (void)didSelectWallpaperImage:(UIImage *)image {
    image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(image.size.width, image.size.height) interpolationQuality:kCGInterpolationLow];
    [self uploadWallpaper:image];
}

#pragma mark - ProfileImageEditViewControllerDelegate
- (void)didSelectProfileImage:(UIImage *)image {
    image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(image.size.width/2, image.size.height/2) interpolationQuality:kCGInterpolationMedium];
    [self uploadPhoto:image];
}

#pragma mark - EntityDescriptionCellDelegate
- (void)didChangeEntityDescription:(NSString *)description {
    [UIView setAnimationsEnabled:NO];
    [_tables[0] beginUpdates];
    [_tables[0] endUpdates];
    [UIView setAnimationsEnabled:YES];
    
    _entityDescription = description;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex) {
        if (_isCreate){
            if (alertView.tag == 1001) {
                [self createTmpDictionary];
            }else{
                [self createEntity];
            }
        }
        else {
            if (alertView.tag == 1001) {
                [self createTmpDictionary];
            }else{
                [self saveEntity];
            }
        }
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

@end
