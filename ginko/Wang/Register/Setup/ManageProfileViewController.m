//
//  ManageProfileViewController.m
//  ginko
//
//  Created by STAR on 15/12/23.
//  Copyright © 2015年 com.xchangewithme. All rights reserved.
//

#import "ManageProfileViewController.h"
#import "ProfileNamePictureCell.h"
#import "WallpaperVideoCell.h"
#import "FieldTableCell.h"
#import "FieldTableTextViewCell.h"
#import "GreyClient.h"
#import "YYYCommunication.h"
#import "UIImage+Resize.h"
#import "VideoPickerController.h"
#import "AddFieldCell.h"
#import "LocalDBManager.h"
#import <AVFoundation/AVFoundation.h>
#import "PreviewProfileViewController.h"
#import "UIImageView+AFNetworking.h"
#import <MediaPlayer/MediaPlayer.h>
#import "WallpaperEditViewController.h"
#import "ProfileImageEditViewController.h"

#define TAG_PROFILE_IMAGE   1000
#define TAG_WALLPAPER       1001
#define TAG_VIDEO           1002

@interface ManageProfileViewController () <UITextViewDelegate, ProfileNamePictureCellDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, WallpaperVideoCellDelegate, VideoPickerControllerDelegate, FieldTableCellDelegate, FieldTableTextViewCellDelegate, UIAlertViewDelegate, WallpaperEditViewControllerDelegate, ProfileImageEditViewControllerDelegate, AddFieldCellDelegate> {
    
    // yes if keyboard is shown
    BOOL _keyboardShown;
    
    // All field names (_allFieldNames - _fieldSelections)
    NSArray *_allFieldNames;
    
    // int array: 0: not included, 1: included, 2: mandatory and cannot be deleted
    NSMutableArray *_fieldSelections;
    
    // selected field names
    NSMutableArray *_fieldNames;
    
    // Real field values
    NSMutableDictionary *_fieldValues;
    
    // field names, number of rows in add field table
    NSMutableArray *_addFieldNames;
    
    // 0: doesnt have more fields, 1: have one field, 2: have two field
    NSMutableArray *_addFieldNameValues;
    
    // profile image
    UIImage *_profileImage;
    
    // profile wallpaper
    UIImage *_wallpaperImage;
    
    // wallpaper image id
    NSString *_wallpaperImageId;
    
    // the database video id
    NSString *_videoId;
    
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
    UIImageView *_tempProfileImageView, *_tempSnapshotImageView, *_tempWallpaperImageView;
    
    NSArray *fieldsArray;
    BOOL isFields;
}
@end

@implementation ManageProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isFields = YES;
    // automatic row calculation
    _fieldTable.rowHeight = UITableViewAutomaticDimension;
    _addFieldTable.rowHeight = UITableViewAutomaticDimension;
    
    // estimation height is 44
    _fieldTable.estimatedRowHeight = 44;
    _addFieldTable.estimatedRowHeight = 44;
    
    // table has no cell separator
    _fieldTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    _addFieldTable.separatorStyle = UITableViewCellSeparatorStyleNone;

    // add left bar button item
    UIImage *leftBarButtonImage;
    
    switch (_mode) {
        case ProfileModePersonal:
            leftBarButtonImage = [UIImage imageNamed:@"add_work_profile_button"];
            break;
        case ProfileModeWork:
            leftBarButtonImage = [UIImage imageNamed:@"add_home_profile_button"];
            break;
        case ProfileModeBoth:
            if (_isWork)
                leftBarButtonImage = [UIImage imageNamed:@"remove_work_profile_button"];
            else
                leftBarButtonImage = [UIImage imageNamed:@"remove_home_profile_button"];
            break;
        default:
            break;
    }
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
    if (_mode != ProfileModeBoth && !_isCreate)  // when edit, don't show add other profile
        [self.navigationItem setHidesBackButton:NO animated:YES];
    else
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:leftBarButtonImage style:UIBarButtonItemStylePlain target:self action:@selector(manageOtherProfile:)];
    
    // right bar button is next
    if (_isSetup) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(goNext:)];
    }else
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(goNext:)];
    }
    
    
    // add field table background is clear color
    _addFieldTable.backgroundColor = [UIColor clearColor];

    [self initialize];
    
    _nextIndexPathBeFirstResponder = nil;
}

- (void)initialize {
    // set navigation bar title
    if (!_isWork) {
        self.title = @"Personal";
    } else {
        self.title = @"Work";
    }
    
    NSDictionary *userDataDic = (_userData != nil) ? (!_isWork ? _userData[@"home"] : _userData[@"work"]) : nil;
    fieldsArray = (userDataDic != nil) ? userDataDic[@"fields"] : nil;
    
    // hide lock notice label at first, max alpha is 0.8
    _lockNoticeLabel.alpha = 0;
    
    // total field name array
    if (_isWork) {
        _allFieldNames = @[@"Name", @"Company", @"Title", @"Mobile", @"Mobile#2", @"Mobile#3", @"Phone", @"Phone#2", @"Phone#3", @"Email", @"Email#2", @"Address", @"Address#2", @"Fax", @"Birthday", @"Facebook", @"Twitter", @"LinkedIn", @"Website", @"Custom", @"Custom#2", @"Custom#3"];
    } else {
        _allFieldNames = @[@"Name", @"Mobile", @"Mobile#2", @"Mobile#3", @"Phone", @"Phone#2", @"Phone#3", @"Email", @"Email#2", @"Address", @"Address#2", @"Fax", @"Birthday", @"Facebook", @"Twitter", @"LinkedIn", @"Website", @"Custom", @"Custom#2", @"Custom#3"];
    }
    
    _lockButton.selected = NO;
    
    // initialize value dictionary
    _fieldValues = [NSMutableDictionary new];
    
    // selection array
    _fieldSelections = [NSMutableArray new];
    for (NSString *fieldName in _allFieldNames) {
        if ([fieldName isEqualToString:@"Name"])
            [_fieldSelections addObject:@2];
        else if ([fieldName isEqualToString:@"Mobile"] || [fieldName isEqualToString:@"Email"] || [fieldName isEqualToString:@"Company"] || [fieldName isEqualToString:@"Title"])
            [_fieldSelections addObject:@1];
        else
            [_fieldSelections addObject:@0];
    }
    if (fieldsArray && fieldsArray.count > 0) { // if edit for existing
        for (NSDictionary *fieldDic in fieldsArray) {
            NSString *fieldName = fieldDic[@"field_name"];
            
            if ([fieldName isEqualToString:@"Privilege"]) {
                _lockButton.selected = [fieldDic[@"field_value"] intValue];
            }
            
            NSUInteger index = [_allFieldNames indexOfObject:fieldName];
            if (index != NSNotFound) {
                _fieldSelections[index] = @1;
                _fieldValues[fieldName] = fieldDic[@"field_value"];
            }
        }
        
        if (!_fieldValues[@"Mobile"])   // if not exist
            _fieldSelections[[_allFieldNames indexOfObject:@"Mobile"]] = @0;

        if (!_fieldValues[@"Email"])    // if not exist
            _fieldSelections[[_allFieldNames indexOfObject:@"Email"]] = @0;
        
        if (_isWork) {
            if (!_fieldValues[@"Company"])    // if not exist
                _fieldSelections[[_allFieldNames indexOfObject:@"Company"]] = @0;
            
            if (!_fieldValues[@"Title"])    // if not exist
                _fieldSelections[[_allFieldNames indexOfObject:@"Title"]] = @0;
        }
    } else {
        _fieldValues[@"Name"] = [[NSString stringWithFormat:@"%@ %@", [AppDelegate sharedDelegate].firstName, [AppDelegate sharedDelegate].lastName] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        _fieldValues[@"Email"] = _globalData.scbEmail;
    }
    
    // calculate field names
    [self calculateFieldNames];
    [self calculateAddFieldNames];
    
    // hide add field at first
    _addFieldView.hidden = YES;
    
    __weak UITableView *weakFieldTable = _fieldTable;
    
    // profile image
    _profileImage = nil;
    if (_userData) {
        // parse profile image
        NSString *profileImageUrl = userDataDic[@"profile_image"];
        
        if (profileImageUrl && ![profileImageUrl isEqualToString:@""] && [profileImageUrl rangeOfString:@"no-face"].location == NSNotFound) {
            NSString *localFilePath = [LocalDBManager checkCachedFileExist:profileImageUrl];
            if (localFilePath) {
                // load from local
                _profileImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:localFilePath]];
            } else {
                _profileImage = [UIImage imageNamed:@"add_personal_profile_photo_bg"];
                _tempProfileImageView = [UIImageView new];
                [_tempProfileImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:profileImageUrl]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                    _profileImage = image;
                    [LocalDBManager saveImage:image forRemotePath:profileImageUrl];
                    [weakFieldTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to load profile image." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }];
            }
        }
    }
    
    // profile wallpaper
    _wallpaperImage = nil;
    // wallpaper image id
    _wallpaperImageId = nil;
    if (_userData) {
        NSArray *imagesArray = userDataDic[@"images"];
        
        for (NSDictionary *imageDic in imagesArray) {
            if ([imageDic[@"z_index"] intValue] == 0) { // this is background
                NSString *wallpaperImageUrl = imageDic[@"image_url"];
                
                if (wallpaperImageUrl && ![wallpaperImageUrl isEqualToString:@""]) {
                    _wallpaperImageId = imageDic[@"id"];
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
    }
    
    // the database video id
    _videoId = nil;
    // video snapshot
    _snapshotImage = nil;
    _videoUrl = nil;
    if (_userData) {
        NSDictionary *videoDic = userDataDic[@"video"];
        if ([videoDic isKindOfClass:[NSDictionary class]] && videoDic && videoDic[@"id"]) {
            // video exists
            _videoId = videoDic[@"id"];
            _videoUrl = videoDic[@"video_url"];
            // load snapshot image
            NSString *thumbnailUrl = videoDic[@"thumbnail_url"];
            if (thumbnailUrl && ![thumbnailUrl isEqualToString:@""]) {
                NSString *localFilePath = [LocalDBManager checkCachedFileExist:thumbnailUrl];
                if (localFilePath) {
                    // load from local
                    _snapshotImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:localFilePath]];
                    _snapshotImage = [_snapshotImage imageByCombiningImage:[[UIImage imageNamed:@"play_video_button"] resizedImage:CGSizeMake(_snapshotImage.size.height / 4, _snapshotImage.size.height / 4) interpolationQuality:kCGInterpolationDefault]];
                } else {
                    _snapshotImage = [UIImage imageNamed:@"add_profile_video"];
                    _tempSnapshotImageView = [UIImageView new];
                    [_tempSnapshotImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:thumbnailUrl]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                        _snapshotImage = image;
                        _snapshotImage = [_snapshotImage imageByCombiningImage:[[UIImage imageNamed:@"play_video_button"] resizedImage:CGSizeMake(_snapshotImage.size.height / 4, _snapshotImage.size.height / 4) interpolationQuality:kCGInterpolationDefault]];
                        [LocalDBManager saveImage:image forRemotePath:thumbnailUrl];
                        [weakFieldTable reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
                    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to load video snapshot image." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    }];
                }
            }
        }
    }
    
    [_fieldTable reloadData];
}

- (void)calculateFieldNames {
    if ([_fieldSelections[[_allFieldNames indexOfObject:@"Email"]] intValue] == 0) { // if email is deleted, mobile cannot be deleted
        _fieldSelections[[_allFieldNames indexOfObject:@"Mobile"]] = @2;
    }
    
    if ([_fieldSelections[[_allFieldNames indexOfObject:@"Mobile"]] intValue] == 0) { // if mobile is deleted, email cannot be deleted
        _fieldSelections[[_allFieldNames indexOfObject:@"Email"]] = @2;
    }
    
    if ([_fieldSelections[[_allFieldNames indexOfObject:@"Email"]] intValue] > 0 && [_fieldSelections[[_allFieldNames indexOfObject:@"Mobile"]] intValue] > 0) {
        _fieldSelections[[_allFieldNames indexOfObject:@"Mobile"]] = @1;
        _fieldSelections[[_allFieldNames indexOfObject:@"Email"]] = @1;
    }
    
    _fieldNames = [NSMutableArray new];
    for (int i = 0; i < _fieldSelections.count; i++) {
        if ([_fieldSelections[i] intValue] > 0) {
            if (![_allFieldNames[i] isEqualToString:@"Name"]) // name should be not included, because we have in the top section
                [_fieldNames addObject:_allFieldNames[i]];
        }
    }
}

- (void)calculateAddFieldNames {
    // first get the list of the field names which is not added
    _addFieldNames = [NSMutableArray new];
    for (int i = 0; i < _fieldSelections.count; i++) {
        if ([_fieldSelections[i] intValue] == 0) {
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
        for (int i = 0; i < _fieldSelections.count; i++) {
            if ([_allFieldNames[i] rangeOfString:fieldName].location != NSNotFound && [_fieldSelections[i] intValue] > 0) {
                NSUInteger index = [tempFieldNames indexOfObject:fieldName];
                _addFieldNameValues[index] = @([_addFieldNameValues[index] intValue] + 1);
            }
        }
    }
}

- (void)manageOtherProfile:(id)sender {
    [self.view endEditing:NO];
    
    NSString *alertText;
    
    switch (_mode) {
        case ProfileModePersonal:
            alertText = @"Would you like to add work profile?";
            break;
        case ProfileModeWork:
            alertText = @"Would you like to add personal profile?";
            break;
        case ProfileModeBoth:
            if (_isWork) {
                alertText = @"Would you like to delete work profile?";
            } else {
                alertText = @"Would you like to delete personal profile?";
            }
            break;
        default:
            break;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GINKO" message:alertText delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (void)goNext:(id)sender {
    [self hideAddFieldView:self];
    if ([_fieldValues[@"Name"] isEqualToString:@" "]) {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Name with only \"space\" cannot be created" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
        
    }
    // validation
    if ((!_fieldValues[@"Name"] || [_fieldValues[@"Name"] isEqualToString:@""]) || ((!_fieldValues[@"Email"] || [_fieldValues[@"Email"] isEqualToString:@""]) && (!_fieldValues[@"Mobile"] || [_fieldValues[@"Mobile"] isEqualToString:@""]))) {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Name and either Mobile or Email are required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    [self.view endEditing:NO];
    
    //Make Post Body-----------------------------------
    NSMutableArray *lstPostbody = [NSMutableArray new];
    
    // check if all fields exist
    int i;
    for (i = 0; i < _fieldSelections.count; i++) {
        if ([_fieldSelections[i] intValue] > 0) {
            NSString *fieldValue = _fieldValues[_allFieldNames[i]];
            if (!fieldValue) {
                break;
            }
            
            fieldValue = [fieldValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([fieldValue isEqualToString:@""])
                break;
        }
    }
    
    if (i != _fieldSelections.count) {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Please fill all fields." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    if (_fieldValues[@"Email"] && [_fieldValues[@"Email"] rangeOfString:@" "].length != 0) {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Email field contains space. Please input again"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    if (_fieldValues[@"Email#2"] && [_fieldValues[@"Email#2"] rangeOfString:@" "].length != 0) {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Email field contains space. Please input again"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    if (_fieldValues[@"Email"] && ![self checkedEmail:_fieldValues[@"Email"]]) {
        return;
    }
    if ( _fieldValues[@"Email#2"] && ![self checkedEmail:_fieldValues[@"Email#2"]]) {
        return;
    }
    for (NSString *key in _fieldValues) {
        isFields = NO;
        if (fieldsArray && fieldsArray.count > 0) { // if edit for existing
            for (NSDictionary *fieldDic in fieldsArray) {
                NSString *fieldName = fieldDic[@"field_name"];
                if ([fieldName isEqual:key]) {
                    [lstPostbody addObject:@{@"field_id":fieldDic[@"field_id"],@"field_name": key, @"field_value": _fieldValues[key], @"field_type": [self getFieldTypeForFieldName: key]}];
                    isFields = YES;
                }
            }
        }
        if (!isFields) {
            [lstPostbody addObject:@{@"field_name": key, @"field_value": _fieldValues[key], @"field_type": [self getFieldTypeForFieldName: key]}];
        }
    }

    [lstPostbody addObject:@{@"field_name": @"Privilege", @"field_value": @((int)(_lockButton.selected))}];
    
    NSMutableArray *lstImages = [NSMutableArray new];
    if (_wallpaperImageId) {
        [lstImages addObject:@{@"id": _wallpaperImageId, @"width": @0, @"height": @0, @"top": @0, @"left": @0, @"type": (!_isWork ? @1 : @2), @"z_index": @0}];
    }
    
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    void(^successed)(id _responseObject) = ^(id _responseObject)
    {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self navigateToNext];
        });
    };
    
    void(^failure)(NSError* _error) = ^(NSError* _error)
    {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oh no!" message:@"Failed to save information. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    };
    
    [[YYYCommunication sharedManager] SetInfo1:[AppDelegate sharedDelegate].sessionId group:(!_isWork ? @"home" : @"work") fields:lstPostbody images:lstImages successed:successed failure:failure];
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
- (void)navigateToNext {
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    void (^successed)(id _responseObject) = ^(id _responseObject){
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        
        if ([[_responseObject objectForKey:@"success"] boolValue]) {
            if (!_isCreate || _mode != ProfileModeBoth || _isSecond) { // if edit or has only one profile, or last setup
                PreviewProfileViewController *vc = [[PreviewProfileViewController alloc] initWithNibName:@"PreviewProfileViewController" bundle:nil];
                vc.userData = _responseObject[@"data"];
                if (!_isCreate && _mode == ProfileModeBoth) {// if user has both profile, work is default. but if it's edit, show the one the user has edited
                    vc.isWork = YES;
                    vc.isSelected = _isSelected;
                }
                else
                    vc.isWork = _isWork;
                
                vc.isSetup = _isSetup;
                
                [self.navigationController pushViewController:vc animated:YES];
                
                NSMutableArray *vcs = [self.navigationController.viewControllers mutableCopy];
                [vcs removeObjectAtIndex:vcs.count - 2];
                [self.navigationController setViewControllers:[vcs copy]];
            } else {
                ManageProfileViewController *vc = [[ManageProfileViewController alloc] initWithNibName:@"ManageProfileViewController" bundle:nil];
                vc.userData = _responseObject[@"data"];
                vc.isCreate = YES;
                vc.isWork = !_isWork;
                vc.isSecond = YES;
                vc.mode = _mode;
                
                vc.isSetup = _isSetup;
                
                [self.navigationController pushViewController:vc animated:YES];
                
                NSMutableArray *vcs = [self.navigationController.viewControllers mutableCopy];
                [vcs removeObjectAtIndex:vcs.count - 2];
                [self.navigationController setViewControllers:[vcs copy]];
            }
        }
    };
    
    void (^failure)(NSError* _error) = ^(NSError* _error)
    {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to load user info." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    };
    
    [[YYYCommunication sharedManager] GetInfo:[AppDelegate sharedDelegate].sessionId successed:successed failure:failure];
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
    
    [self calculateAddFieldNames];
    [_addFieldTable reloadData];
    _addFieldView.hidden = NO;
}

- (IBAction)hideAddFieldView:(id)sender {
    _addFieldView.hidden = YES;
}

- (IBAction)doLockOrUnlock:(id)sender {
    _lockButton.selected = !_lockButton.selected;
    _lockNoticeLabel.text = (_lockButton.selected) ? @"Profile is public" : @"Profile is private";
    _lockNoticeLabel.alpha = 0.8f;
    [UIView animateWithDuration:0.5 delay:1.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _lockNoticeLabel.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:NO];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([tableView isEqual:_addFieldTable])
        return 1;
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:_addFieldTable]) {
        if (_addFieldNames.count == 0) {
            [self hideAddFieldView:self];
        }
        return [_addFieldNames count];
    }
    
    if (section == 0 || section == 1) {
        return 1;
    }
    
    return _fieldNames.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_nextIndexPathBeFirstResponder && [indexPath compare:_nextIndexPathBeFirstResponder] == NSOrderedSame) {
        if ([cell isKindOfClass:[FieldTableCell class]])
            [((FieldTableCell *)cell).textField becomeFirstResponder];
        else if ([cell isKindOfClass:[FieldTableTextViewCell class]])
            [((FieldTableTextViewCell *)cell).textView becomeFirstResponder];
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
        
        cell.delegate = self;
        cell.fieldLabel.text = _addFieldNames[indexPath.row];
        
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
            cell.roundCornerImage = YES;
            
            [cell setProfileImage:_profileImage placeholderImage:[UIImage imageNamed:@"add_personal_profile_photo_bg"]];
            
            cell.textField.text = _fieldValues[@"Name"];

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
            [cell setVideoSnapshot:_snapshotImage];
            
            return cell;
        }
            break;
        default: {
            // if textview cell
            if ([_fieldNames[indexPath.row] rangeOfString:@"Address"].location != NSNotFound) {
                FieldTableTextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FieldTableTextViewCell"];
                
                if (!cell) {
                    [tableView registerNib:[UINib nibWithNibName:@"FieldTableTextViewCell" bundle:nil] forCellReuseIdentifier:@"FieldTableTextViewCell"];
                    cell = [tableView dequeueReusableCellWithIdentifier:@"FieldTableTextViewCell"];
                }
                
                cell.delegate = self;
                
                cell.textView.text = _fieldValues[_fieldNames[indexPath.row]];
                
                cell.textView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_fieldNames[indexPath.row] attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:0.8 alpha:1], NSFontAttributeName: [UIFont systemFontOfSize:17]}];
                
                if ([_fieldSelections[[_allFieldNames indexOfObject:_fieldNames[indexPath.row]]] intValue] == 2) {   // delete button should be hidden when it's mandatory cell
                    cell.deleteButton.hidden = YES;
                } else {
                    cell.deleteButton.hidden = NO;
                }
                
                cell.iconImage.image = [UIImage imageNamed:@"field_icon_grey_address"];
                
                return cell;
            }
            
            FieldTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FieldTableCell"];
            
            if (!cell) {
                [tableView registerNib:[UINib nibWithNibName:@"FieldTableCell" bundle:nil] forCellReuseIdentifier:@"FieldTableCell"];
                cell = [tableView dequeueReusableCellWithIdentifier:@"FieldTableCell"];
            }
            
            cell.delegate = self;
            
            cell.textField.text = _fieldValues[_fieldNames[indexPath.row]];
            cell.textField.placeholder = _fieldNames[indexPath.row];
            
            if ([_fieldSelections[[_allFieldNames indexOfObject:_fieldNames[indexPath.row]]] intValue] == 2) {   // delete button should be hidden when it's mandatory cell
                cell.deleteButton.hidden = YES;
            } else {
                cell.deleteButton.hidden = NO;
            }
            
            [self refreshFieldCell:cell fieldName:_fieldNames[indexPath.row]];
            
            return cell;
        }
            break;
    }
}

- (void)refreshAddFieldCell:(AddFieldCell *)cell fieldName:(NSString *)fieldName {
    if ([fieldName isEqualToString:@"Company"]) {
        cell.iconImage.image = [UIImage imageNamed:@"field_icon_big_company"];
    } else if ([fieldName isEqualToString:@"Title"]) {
        cell.iconImage.image = [UIImage imageNamed:@"field_icon_big_title"];
    } else if ([fieldName isEqualToString:@"Mobile"]) {
        cell.iconImage.image = [UIImage imageNamed:@"field_icon_big_mobile"];
    } else if ([fieldName isEqualToString:@"Phone"]) {
        cell.iconImage.image = [UIImage imageNamed:@"field_icon_big_phone"];
    } else if ([fieldName isEqualToString:@"Fax"]) {
        cell.iconImage.image = [UIImage imageNamed:@"field_icon_big_fax"];
    } else if ([fieldName isEqualToString:@"Email"]) {
        cell.iconImage.image = [UIImage imageNamed:@"field_icon_big_email"];
    } else if ([fieldName isEqualToString:@"Address"]) {
        cell.iconImage.image = [UIImage imageNamed:@"field_icon_big_address"];
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
    if (indexPath.section == 0 || indexPath.section == 1)
        [self.view endEditing:NO];
    if (indexPath.section == 2) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[FieldTableCell class]])
            [((FieldTableCell *)cell).textField becomeFirstResponder];
        else if ([cell isKindOfClass:[FieldTableTextViewCell class]])
            [((FieldTableTextViewCell *)cell).textView becomeFirstResponder];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex)
        return;
    
    if (_mode == ProfileModeBoth) { // this is delete
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        
        void (^successed)(id _responseObject) = ^(id _responseObject) {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            
            UIImage *leftBarButtonImage;

            if (_isWork) {
                _isWork = NO;
                _mode = ProfileModePersonal;
                leftBarButtonImage = [UIImage imageNamed:@"add_work_profile_button"];
            } else {
                _isWork = YES;
                _mode = ProfileModeWork;
                leftBarButtonImage = [UIImage imageNamed:@"add_home_profile_button"];
            }
            
            if (!_isCreate || _isSecond) { // if this is second setup profile or edit existing, delete and navigate to preview
                [self navigateToNext];
            } else {
                [self initialize];
                
                [self.navigationItem.leftBarButtonItem setImage:leftBarButtonImage];
            }
        };
        
        void (^failure)(NSError* _error) = ^(NSError* _error) {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to delete profile. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        };
        
        [[YYYCommunication sharedManager] deleteWorkProfile:[AppDelegate sharedDelegate].sessionId group:!_isWork ? @"home" : @"work" successed:successed failure:failure];
    } else { // add other profile
        // add left bar button item
        UIImage *leftBarButtonImage;
        
        switch (_mode) {
            case ProfileModePersonal:
                _mode = ProfileModeBoth;
                leftBarButtonImage = [UIImage imageNamed:@"remove_home_profile_button"];
                break;
            case ProfileModeWork:
                _mode = ProfileModeBoth;
                leftBarButtonImage = [UIImage imageNamed:@"remove_work_profile_button"];
                break;
            default:
                break;
        }
        
        [self.navigationItem.leftBarButtonItem setImage:leftBarButtonImage];
    }
}

#pragma mark - ProfileNamePictureCellDelegate
- (void)profileNameDidChange:(NSString *)text {
    [UIView setAnimationsEnabled:NO];
    [_fieldTable beginUpdates];
    [_fieldTable endUpdates];
    [UIView setAnimationsEnabled:YES];
    
    _fieldValues[@"Name"] = text;
}

- (void)profileNameDidReturn {
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    [_fieldTable scrollToRowAtIndexPath:nextIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    UITableViewCell *cell = [_fieldTable cellForRowAtIndexPath:nextIndexPath];
    if (cell) {
        if ([cell isKindOfClass:[FieldTableCell class]])
            [((FieldTableCell *)cell).textField becomeFirstResponder];
        else if ([cell isKindOfClass:[FieldTableTextViewCell class]])
            [((FieldTableTextViewCell *)cell).textView becomeFirstResponder];
    } else {
        _nextIndexPathBeFirstResponder = nextIndexPath;
    }
}

- (void)tapProfileImage:(ProfileNamePictureCell *)sender {
    [self.view endEditing:NO];
    _photoMode = TAG_PROFILE_IMAGE;
    if (_profileImage) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Remove photo", @"Take profile photo", @"Choose from library", nil];
        actionSheet.destructiveButtonIndex = 0;
        [actionSheet showInView:self.view];
    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take profile photo", @"Choose from library", nil];
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
    [self.view endEditing:NO];
    if (_videoId) { // video exists
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Remove video", @"Play video", nil];
        actionSheet.destructiveButtonIndex = 0;
        [actionSheet showInView:self.view];
        _photoMode = TAG_VIDEO;
    } else {
        VideoPickerController *viewController = [[VideoPickerController alloc] initWithType:!_isWork ? 1 : 2 entityID:nil isSetup:_isSetup];
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
    
    _fieldSelections[index] = @(0);
    [_fieldValues removeObjectForKey:cell.textField.placeholder];
    
    [self calculateFieldNames];
    
    [_fieldTable reloadData];
}

- (void)fieldTableCell:(FieldTableCell *)cell textDidChange:(NSString *)text {
    _fieldValues[cell.textField.placeholder] = text;
}

- (void)fieldTableCellTextFieldDidReturn:(FieldTableCell *)cell {
    NSIndexPath *indexPath = [_fieldTable indexPathForCell:cell];
    if (indexPath && indexPath.row < [_fieldTable numberOfRowsInSection:indexPath.section] - 1) {
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
        [_fieldTable scrollToRowAtIndexPath:nextIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        UITableViewCell *cell = [_fieldTable cellForRowAtIndexPath:nextIndexPath];
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
    
    _fieldSelections[index] = @(0);
    [_fieldValues removeObjectForKey:cell.textView.placeholder];
    
    [self calculateFieldNames];
    
    [_fieldTable reloadData];
}

- (void)fieldTableTextViewCell:(FieldTableTextViewCell *)cell textDidChange:(NSString *)text {
    [UIView setAnimationsEnabled:NO];
    [_fieldTable beginUpdates];
    [_fieldTable endUpdates];
    [UIView setAnimationsEnabled:YES];
    
    _fieldValues[cell.textView.placeholder] = text;
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
        if (_photoMode == TAG_PROFILE_IMAGE)
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
        if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!granted) {
                        [CommonMethods showAlertUsingTitle:@"" andMessage:MESSAGE_CAMERA_DISABLED];
                    }
                    else {
                        
                        imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                        imgPicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
                        
                        imgPicker.delegate = self;
                        [self presentViewController:imgPicker animated:YES completion:nil];
                    }
                });
            }];
        }
        
        
    } else if (buttonIndex == actionSheet.numberOfButtons - 2) {
        imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imgPicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
        
        imgPicker.delegate = self;
        
        // [self saveData];
        [self presentViewController:imgPicker animated:YES completion:nil];
    }

    
    
    [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

#pragma mark - API Helper methods
- (void)removePhoto {
    void (^successed)(id responseObject) = ^(id responseObject) {
        NSDictionary *result = responseObject;
        
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        
        if ([[result objectForKey:@"success"] boolValue]) {
            _profileImage = nil;
            [_fieldTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
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
    [[GreyClient sharedClient] deleteProfilePhoto:[AppDelegate sharedDelegate].sessionId type:!_isWork ? @"1" : @"2" successed:successed failure:failure];
}

- (void)removeWallpaper {
    void (^successed)(id _responseObject) = ^(id _responseObject)
    {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        if ([[_responseObject objectForKey:@"success"] boolValue]) {
            _wallpaperImage = nil;
            [_fieldTable reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
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
    [[YYYCommunication sharedManager] removePhoto:[AppDelegate sharedDelegate].sessionId image:_wallpaperImageId type:@"2" successed:successed failure:failure];
}

- (void)removeVideo {
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        if ([[_responseObject objectForKey:@"success"] boolValue]) {
            _videoId = nil;
            _snapshotImage = nil;
            [_fieldTable reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
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
    
    [[YYYCommunication sharedManager] removeProfileVideo:[AppDelegate sharedDelegate].sessionId video:_videoId type:!_isWork ? @"1" : @"2" successed:successed failure:failure];
}

- (void)uploadPhoto:(UIImage *)img
{
    void (^successed)(id responseObject) = ^(id responseObject) {
        NSDictionary *result = responseObject;
        
        if ([[result objectForKey:@"success"] boolValue]) {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];

            // save to local cache
            [LocalDBManager saveImage:img forRemotePath:result[@"data"][@"profile_image"]];
            
            _profileImage = img;
            [_fieldTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
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
    [[GreyClient sharedClient] uploadProfilePhoto:[AppDelegate sharedDelegate].sessionId type:!_isWork ? @"1" : @"2" imgData:UIImageJPEGRepresentation(img, 0.5f) successed:successed failure:failure];
}

- (void)uploadWallpaper:(UIImage *)img {
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    void (^successed)(id _responseObject) = ^(id _responseObject)
    {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        
        NSArray *response = [_responseObject objectForKey:@"data"];
        
        if ([response count]) {
            NSDictionary *dict = [response objectAtIndex:0];
            _wallpaperImageId = dict[@"id"];
            _wallpaperImage = img;
            
            // save to local path
            [LocalDBManager saveImage:img forRemotePath:dict[@"image_url"]];
            
            [_fieldTable reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    };
    
    void (^failure)(NSError* _error) = ^(NSError* _error)
    {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oh no!" message:@"Failed to upload photos. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    };
    
    [[YYYCommunication sharedManager] UploadMultipleImages:[AppDelegate sharedDelegate].sessionId type:!_isWork ? @"1" : @"2" background:UIImageJPEGRepresentation(img, 1.0) foreground:nil successed:successed failure:failure];
}

-(void)uploadVideo:(NSData*)video :(NSData *)thumb :(VideoPickerController*)pickerController
{
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        [MBProgressHUD hideHUDForView:[AppDelegate sharedDelegate].window animated:YES];
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            
//            VideoURL = [[_responseObject objectForKey:@"data"] objectForKey:@"video_url"];

            _videoId = _responseObject[@"data"][@"id"];
            _videoUrl = _responseObject[@"data"][@"video_url"];
            // save to local path
            [LocalDBManager saveData:thumb forRemotePath:_responseObject[@"data"][@"thumbnail_url"]];
            [LocalDBManager saveData:video forRemotePath:_videoUrl];
            
            [pickerController dismissViewControllerAnimated:YES completion:^{
                _snapshotImage = [UIImage imageWithData:thumb];
                _snapshotImage = [_snapshotImage imageByCombiningImage:[[UIImage imageNamed:@"play_video_button"] resizedImage:CGSizeMake(_snapshotImage.size.height / 4, _snapshotImage.size.height / 4) interpolationQuality:kCGInterpolationDefault]];
                [_fieldTable reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
            }];
        }  else {
            NSDictionary *dictError = [_responseObject objectForKey:@"err"];
            if (dictError) {
                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:[dictError objectForKey:@"errMsg"]];
            } else {
                [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Failed to connect to server!"];
            }
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
        [MBProgressHUD hideHUDForView:[AppDelegate sharedDelegate].window animated:YES];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oh no!" message:@"Failed to save Video. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    };
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[AppDelegate sharedDelegate].window animated:YES];
    [hud setLabelText:@"Uploading..."];
    
    [[YYYCommunication sharedManager] UploadVideo:[AppDelegate sharedDelegate].sessionId type:!_isWork ? @"1" : @"2" video:video thumbnail:thumb successed:successed failure:failure];
}

- (void)playVideo {
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
    _playerVC.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
    _playerVC.moviePlayer.contentURL = [NSURL fileURLWithPath:videoPath];
    
    [self presentMoviePlayerViewControllerAnimated:_playerVC];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(640, 640) interpolationQuality:kCGInterpolationDefault];
    image = [image fixOrientation];
    
    if (![UIImageJPEGRepresentation(image, 0.5f) writeToFile:TEMP_IMAGE_PATH atomically:YES]) {
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
        vc.sourceImage = image;
        vc.delegate = self;
        vc.isEntity = NO;
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

#pragma mark - AddFieldCellDelegate
- (void)didAddField:(NSString *)fieldName {
    for (int i = 0; i < _fieldSelections.count; i++) {
        if ([_fieldSelections[i] intValue] == 0) {
            if ([_allFieldNames[i] rangeOfString:fieldName].location != NSNotFound)
            {
                _fieldSelections[i] = @(1);
                break;
            }
        }
    }
    
    [self calculateFieldNames];
    [self calculateAddFieldNames];
    [_fieldTable reloadData];
    [_addFieldTable reloadData];
}

@end
