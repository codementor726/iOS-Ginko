//
//  AddSubEntitiesViewController.m
//  ginko
//
//  Created by stepanekdavid on 4/17/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "AddSubEntitiesViewController.h"
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
#import "AddLocationCell.h"
#import "AddInfoOfSubEntityViewController.h"
#import "PreviewEntityViewController.h"
#import "PreviewMainEntityViewController.h"

#import "VideoVoiceConferenceViewController.h"

#define TAG_LOGO_IMAGE   1000
#define TAG_WALLPAPER       1001
#define TAG_VIDEO           1002

@interface AddSubEntitiesViewController ()<ProfileNamePictureCellDelegate, WallpaperVideoCellDelegate, UIActionSheetDelegate, VideoPickerControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, WallpaperEditViewControllerDelegate, ProfileImageEditViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, EntityDescriptionCellDelegate, UIAlertViewDelegate,AddInfoOfSubEntityViewControllerDelegate>{
    
    BOOL _keyboardShown;
    
    // width and height constraint for table
    NSLayoutConstraint *_tableWidth, *_tableHeight;
    
    // entity privilege
    int _entityPrivilege;
    
    NSString *_entityName_sub;
    UIImage *_logoImage_sub;
    UIImage *_wallpaperImage_sub;
    UIImage *_snapshotImage_sub;
    NSString *_entityDescription_sub;
    NSString *_videoUrl_sub;
    
    // wallpaper image id
    NSString *_wallpaperImageId;
    NSString *strDeleteId;
    
    int _photoMode;
    
    MBProgressHUD *_downloadProgressHUD; // Download progress hud for video
    
    // video player
    MPMoviePlayerViewController *_playerVC;
    
    // index path that should be first responder
    NSIndexPath *_nextIndexPathBeFirstResponder;
    
    // temp image views for loading images in background
    UIImageView *_tempLogoImageView, *_tempSnapshotImageView, *_tempWallpaperImageView;
    
    // save created entity id in case the error happens when uploading photo or video
    NSString *_createdEntityId;
    
    BOOL _addressConfirmed;
    CLLocation *_location;
    
    int currentIndexCell;
    
    NSMutableArray *arrMultiLocation;
    
    NSMutableDictionary * _infoSubEntityDict;
    
    BOOL isAddedLocation;
    
    BOOL isCompleted;
    
    NSMutableArray *fieldIsCompletedArray;
}

@end

@implementation AddSubEntitiesViewController
@synthesize _videoData_sub;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    
    arrMultiLocation = [[NSMutableArray alloc] init];
    _infoSubEntityDict = [[NSMutableDictionary alloc] init];
    isAddedLocation = NO;
    isCompleted = YES;
    
    fieldIsCompletedArray = [[NSMutableArray alloc] init];
    
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
    
    // estimation height is 44
    table.estimatedRowHeight = 44;
    
    // table has no cell separator
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // right bar button is next
    if (_isCreate){
        // right bar button is next
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(goNext:)];
        
    }
    else{
        // right bar button is next
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(goDone:)];
        
    }
    if (_isMultiLocation) {
        _removeAllLocationButton.hidden = YES;
    }
    else{
        _removeAllLocationButton.hidden = NO;
    }
    [self initialize];
    _nextIndexPathBeFirstResponder = nil;
}

- (void) checkForAllRows {
    for (int i = 0; i < [arrMultiLocation count]; i++) {
        NSMutableDictionary *dict = [arrMultiLocation objectAtIndex:i][@"fields"];
        
        isCompleted = NO;
        if ([dict count] == 0) {
            isCompleted = NO;
        }
        for (NSDictionary *fieldDic in dict) {
            NSString *fieldName = fieldDic[@"field_name"];
            if ([fieldName  isEqual: @"Address"] && ![fieldDic[@"field_value"]  isEqual: @""]) {
                isCompleted = YES;
            }else if ([fieldName  isEqual: @"Address"] && [fieldDic[@"field_value"]  isEqual: @""]){
                isCompleted = NO;
            }
            if ([fieldDic[@"field_value"]  isEqual: @""]) {
                isCompleted = NO;
            }
            if ([fieldDic[@"field_name"] isEqual:@"Email"] || [fieldDic[@"field_name"] isEqual:@"Email#2"]) {
                if ([fieldDic[@"field_value"] isEqual:@""] || [fieldDic[@"field_value"] rangeOfString:@" "].length !=0 || ![self checkedEmail:fieldDic[@"field_value"]]){
                    isCompleted = NO;
                }
            }
        }
        
        if (isCompleted)
            [fieldIsCompletedArray replaceObjectAtIndex:i withObject:@1];
        else
            [fieldIsCompletedArray replaceObjectAtIndex:i withObject:@0];
        
    }
}

- (void) initialize{
    // set navigation bar title
    if (_isCreate) {
        self.title = @"Create Entity Profile";
    } else {
        self.title = @"Edit Entity Profile";
    }
    
    _removeAllLocationButton.enabled = NO;
    // hide lock notice label at first, max alpha is 0.8
    _lockNoticeLabel.alpha = 0;
    
    if (_entityData[@"entity_id"]) {
        _createdEntityId = _entityData[@"entity_id"];
    }
    
    //Delete ID List
    strDeleteId = @"";
    
    // name
    _entityName_sub = _entityData ? _entityData[@"name"] : @"";
    
    // description
    _entityDescription_sub = _entityData ? _entityData[@"description"] : @"";
    
    // privilege
    _entityPrivilege = (_entityData && _entityData[@"privilege"]) ? [_entityData[@"privilege"] intValue] : 1;
    _lockButton.selected = (BOOL)_entityPrivilege;
    
    __weak UITableView *weakFieldTable = _tables[0];
    
    // profile image
    _logoImage_sub = nil;
    if (_entityData) {
        // parse profile image
        NSString *profileImageUrl = _entityData[@"profile_image"];
        
        if (profileImageUrl && ![profileImageUrl isEqualToString:@""]) {
            NSString *localFilePath = [LocalDBManager checkCachedFileExist:profileImageUrl];
            if (localFilePath) {
                // load from local
                _logoImage_sub = [UIImage imageWithData:[NSData dataWithContentsOfFile:localFilePath]];
            } else {
                _logoImage_sub = [UIImage imageNamed:@"entity_add_logo"];
                _tempLogoImageView = [UIImageView new];
                [_tempLogoImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:profileImageUrl]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                    _logoImage_sub = image;
                    [LocalDBManager saveImage:image forRemotePath:profileImageUrl];
                    [weakFieldTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to load entity image." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }];
            }
        }
    }
    
    // profile wallpaper
    _wallpaperImage_sub = nil;
    // wallpaper image id
    _wallpaperImageId = nil;
    if (_entityData) {
        if (_isCreate) {
            NSString *wallpaperImageUrl = _entityData[@"wallpaper_image"];
            
            if (wallpaperImageUrl && ![wallpaperImageUrl isEqualToString:@""]) {
                NSString *localFilePath = [LocalDBManager checkCachedFileExist:wallpaperImageUrl];
                if (localFilePath) {
                    // load from local
                    _wallpaperImage_sub = [UIImage imageWithData:[NSData dataWithContentsOfFile:localFilePath]];
                } else {
                    _wallpaperImage_sub = [UIImage imageNamed:@"add_wallpaper"];
                }
            }
        }else{
            NSArray *imagesArray = _entityData[@"images"];
            
            for (NSDictionary *imageDic in imagesArray) {
                if ([imageDic[@"z_index"] intValue] == 0) { // this is background
                    NSString *wallpaperImageUrl = imageDic[@"image_url"];
                    
                    if (wallpaperImageUrl && ![wallpaperImageUrl isEqualToString:@""]) {
                        _wallpaperImageId = imageDic[@"image_id"];
                        NSString *localFilePath = [LocalDBManager checkCachedFileExist:wallpaperImageUrl];
                        if (localFilePath) {
                            // load from local
                            _wallpaperImage_sub = [UIImage imageWithData:[NSData dataWithContentsOfFile:localFilePath]];
                        } else {
                            _wallpaperImage_sub = [UIImage imageNamed:@"add_wallpaper"];
                            _tempWallpaperImageView = [UIImageView new];
                            [_tempWallpaperImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:wallpaperImageUrl]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                _wallpaperImage_sub = image;
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
        
    }
    
    // video snapshot
    _snapshotImage_sub = nil;
    _videoUrl_sub = nil;
    if (_entityData) {
        if (_entityData[@"video_url"] && ![_entityData[@"video_url"] isEqualToString:@""]) {
            // video exists
            _videoUrl_sub = _entityData[@"video_url"];
            // load snapshot image
            NSString *thumbnailUrl = _entityData[@"video_thumbnail_url"];
            if (thumbnailUrl && ![thumbnailUrl isEqualToString:@""]) {
                NSString *localFilePath = [LocalDBManager checkCachedFileExist:thumbnailUrl];
                if (localFilePath) {
                    // load from local
                    _snapshotImage_sub = [UIImage imageWithData:[NSData dataWithContentsOfFile:localFilePath]];
                    //                    _snapshotImage = [_snapshotImage imageByCombiningImage:[[UIImage imageNamed:@"play_video_button"] resizedImage:CGSizeMake(_snapshotImage.size.height / 4, _snapshotImage.size.height / 4) interpolationQuality:kCGInterpolationDefault]];
                } else {
                    _snapshotImage_sub = [UIImage imageNamed:@"add_profile_video"];
                    _tempSnapshotImageView = [UIImageView new];
                    [_tempSnapshotImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:thumbnailUrl]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                        _snapshotImage_sub = image;
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
    
    arrMultiLocation = [_entityData[@"infos"] mutableCopy];
    
    for (int i = 0; i < [arrMultiLocation count]; i ++) {
        [fieldIsCompletedArray addObject:@0];
    }
    
    if ([arrMultiLocation count]>1) {
        _removeAllLocationButton.enabled = YES;
    }
    [_tables[0] reloadData];
    
}
- (void)viewDidLayoutSubviews {
    _tableWidth.constant = CGRectGetWidth(_entityScrollView.bounds);
    _tableHeight.constant = CGRectGetHeight(_entityScrollView.bounds);
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
- (IBAction)removeAllLocations:(id)sender{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Do you want to revert back to single location?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    alert.tag = 300;
    [alert show];
}

- (IBAction)doLockOrUnlock:(id)sender{
    _lockButton.selected = !_lockButton.selected;
    _lockNoticeLabel.text = (_lockButton.selected) ? @"Entity is public" : @"Entity is private";
    _lockNoticeLabel.alpha = 0.8f;
    [UIView animateWithDuration:0.5 delay:1.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _lockNoticeLabel.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)addLocationOfEntity:(id)sender{
    [self.view endEditing:NO];
    isAddedLocation = YES;
    [_infoSubEntityDict removeAllObjects];
    [self updateMainEntity];
    
    AddInfoOfSubEntityViewController *vc = [[AddInfoOfSubEntityViewController alloc] initWithNibName:@"AddInfoOfSubEntityViewController" bundle:nil];
    vc.isCreate = _isCreate;
    vc.entityData = _entityData;
    
    vc.indexOfSubEntity = (int)([arrMultiLocation count] - 1);
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
    
    [_tables[0] reloadData];
}
- (void)goNext:(id)sender {
    [self.view endEditing:NO];
    // validation
    if ((!_entityName_sub || [_entityName_sub isEqualToString:@""])) {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Name are required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    [self checkForAllRows];
    
    for (int i = 0; i < [fieldIsCompletedArray count]; i++) {
        if ([[fieldIsCompletedArray objectAtIndex:i] integerValue] == 0) {
            [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"All locations needs an address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return;
        }
    }
    
    [self createEntity];
}
- (void)goDone:(id)sender{
    [self.view endEditing:NO];
    // validation
    if ((!_entityName_sub || [_entityName_sub isEqualToString:@""])) {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Name are required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    [self checkForAllRows];
    
    for (int i = 0; i < [fieldIsCompletedArray count]; i++) {
        if ([[fieldIsCompletedArray objectAtIndex:i] integerValue] == 0) {
            [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"All locations needs an address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return;
        }
    }
    
    [self saveEntity];
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
                                                        name:_entityName_sub
                                                 description:_entityDescription_sub
                                                   keysearch:@""
                                                  background:_wallpaperImage_sub ? UIImageJPEGRepresentation(_wallpaperImage_sub, 1) : nil
                                                  foreground:nil
                                                   successed:successed
                                                     failure:failure];
    }
}

- (void)updateCreatedEntity {
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        // profile photo, video
        if (_logoImage_sub) {
            [self uploadPhoto:_logoImage_sub entityId:_createdEntityId completionHandler:^(BOOL success) {
                if (success) {
                    if (_videoData_sub) {
                        [self uploadVideo:_videoData_sub thumbnail:UIImageJPEGRepresentation(_snapshotImage_sub, 1) entityId:_createdEntityId completionHandler:^(BOOL success) {
                            if (success) {
                                [self navigateToPreviewScreen:_responseObject[@"data"]];
                            } else {
                                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to upload video, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                            }
                        }];
                    } else {
                        [self navigateToPreviewScreen:_responseObject[@"data"]];
                    }
                } else {
                    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to upload entity photo, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }
            }];
        } else if (_videoData_sub){
            [self uploadVideo:_videoData_sub thumbnail:UIImageJPEGRepresentation(_snapshotImage_sub, 1) entityId:_createdEntityId completionHandler:^(BOOL success) {
                if (success) {
                    [self navigateToPreviewScreen:_responseObject[@"data"]];
                } else {
                    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to upload video, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }
            }];
        } else {
            [self navigateToPreviewScreen:_responseObject[@"data"]];
        }
    };
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oh no!" message:@"Failed to save information. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    };
    
    
    [[YYYCommunication sharedManager] UpdateEntity1:[AppDelegate sharedDelegate].sessionId
                                           entityid:_createdEntityId
                                               name:_entityName_sub
                                        deleteInfos:strDeleteId
                                        description:_entityDescription_sub
                                          keysearch:@""
                                         categoryid:@""
                                          privilege:[NSString stringWithFormat:@"%d", (int)_lockButton.selected]
                                              infos:_entityData[@"infos"]
                                             images:nil
                                          successed:successed
                                            failure:failure];
}

- (void)navigateToPreviewScreen:(NSMutableDictionary *)response {
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    if (response != NULL) {
        if ([response[@"infos"] count] > 1) {
            PreviewMainEntityViewController *vc = [[PreviewMainEntityViewController alloc] initWithNibName:@"PreviewMainEntityViewController" bundle:nil];
            vc.isCreate = YES;
            vc.entityId = response[@"entity_id"];
            
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            PreviewEntityViewController *vc = [[PreviewEntityViewController alloc] initWithNibName:@"PreviewEntityViewController" bundle:nil];
            vc.isCreate = YES;
            vc.entityId = response[@"entity_id"];
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    }
}

- (void)navigateToPreview {
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        // get entity info for preview
        void ( ^successed )( id _responseObject ) = ^( id _responseObject )
        {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            if ([_responseObject[@"success"] intValue] == 1) {
                
                if ([_responseObject[@"data"][@"infos"] count] > 1) {
                    PreviewMainEntityViewController *vc = [[PreviewMainEntityViewController alloc] initWithNibName:@"PreviewMainEntityViewController" bundle:nil];
                    vc.isCreate = YES;
                    vc.entityId = _createdEntityId;
                    //vc.entityData = _responseObject[@"data"];
                    [self.navigationController pushViewController:vc animated:YES];
                }else{
                    PreviewEntityViewController *vc = [[PreviewEntityViewController alloc] initWithNibName:@"PreviewEntityViewController" bundle:nil];
                    vc.isCreate = YES;
                    //vc.entityData = _responseObject[@"data"];
                    vc.entityId = _createdEntityId;
                    [self.navigationController pushViewController:vc animated:YES];
                }
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
                                                 entityid:_createdEntityId
                                                successed:successed
                                                  failure:failure];
    });
}
- (void)removeAllLocationOfMainEntity{
    if (_isCreate) {
        
        NSMutableArray *arrInfo  = [[NSMutableArray alloc] init];
        [arrInfo addObject:_entityData[@"infos"][0]];
        //[_entityData removeAllObjects];
        
        _entityData[@"description"] = _entityDescription_sub;
        _entityData[@"name"] = _entityName_sub;
        
        [_entityData setObject:arrInfo forKey:@"infos"];
        
        if (_logoImage_sub) {
            [LocalDBManager saveImage:_logoImage_sub forRemotePath:@"logoImagePathOfCreatingSubEntities"];
            _entityData[@"profile_image"] = @"logoImagePathOfCreatingSubEntities";
        }else{
            _entityData[@"profile_image"] = @"";
        }
        if (_wallpaperImage_sub) {
            [LocalDBManager saveImage:_wallpaperImage_sub forRemotePath:@"wallPaperImagePathOfCreatingSubEntities"];
            _entityData[@"wallpaper_image"] = @"wallPaperImagePathOfCreatingSubEntities";
        }else{
            _entityData[@"wallpaper_image"] = @"";
        }
        if (_videoData_sub) {
            [LocalDBManager saveData:_videoData_sub forRemotePath:@"videoPathOfCreatingSubEntities.mp4"];
            [LocalDBManager saveImage:_snapshotImage_sub forRemotePath:@"thumnailPathOfCreatingSubEntities"];
            _entityData[@"video_thumbnail_url"] = @"thumnailPathOfCreatingSubEntities";
            _entityData[@"video_url"] = @"videoPathOfCreatingSubEntities.mp4";
            
        }else{
            
            _entityData[@"video_thumbnail_url"] = @"";
            _entityData[@"video_url"] = @"";
        }
        
        _entityData[@"privilege"] = [NSString stringWithFormat:@"%d", (int)_lockButton.selected];
        
        if (_delegate && [_delegate respondsToSelector:@selector(returnMainEdit:)])
            [_delegate returnMainEdit:[_entityData copy]];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)cancel:(id)sender {
    //if (_delegate && [_delegate respondsToSelector:@selector(returnMainEdit:)])
    //    [_delegate returnMainEdit:[_entityData copy]];
    [self.navigationController popViewControllerAnimated:YES];
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
        //        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter a valid email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return NO ;
    }
    
    return YES ;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:NO];
}
- (void)saveEntity {
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        //        dispatch_async(dispatch_get_main_queue(), ^{
        //            [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        //            // get entity info for preview
        //            void ( ^successed )( id _responseObject ) = ^( id _responseObject )
        //            {
        //                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        //                if ([_responseObject[@"success"] intValue] == 1) {
        if (_isMultiLocation) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            if ([_responseObject[@"data"][@"infos"] count] > 1) {
                PreviewMainEntityViewController *vc = [[PreviewMainEntityViewController alloc] initWithNibName:@"PreviewMainEntityViewController" bundle:nil];
                //UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
                vc.isCreate = NO;
                vc.entityId = _entityData[@"entity_id"];
                //vc.entityData = _responseObject[@"data"];
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                [self.navigationController popToRootViewControllerAnimated:YES];
                
            }
        }
        //                } else {
        //                    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to get entity info, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        //                }
        //            };
        //
        //            void ( ^failure )( NSError* _error ) = ^( NSError* _error )
        //            {
        //                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        //                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to get entity info, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        //            };
        //
        //            [[YYYCommunication sharedManager] GetEntityDetail:[AppDelegate sharedDelegate].sessionId
        //                                                     entityid:_entityData[@"entity_id"]
        //                                                    successed:successed
        //                                                      failure:failure];
        //});
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oh no!" message:@"Failed to save information. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    } ;
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    if (_wallpaperImage_sub) {
        [images addObject:@{@"image_id": _wallpaperImageId, @"z_index": @0}];
    }
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [[YYYCommunication sharedManager] UpdateEntity1:[AppDelegate sharedDelegate].sessionId
                                           entityid:_entityData[@"entity_id"]
                                               name:_entityName_sub
                                        deleteInfos:strDeleteId
                                        description:_entityDescription_sub
                                          keysearch:@""
                                         categoryid:@""
                                          privilege:[NSString stringWithFormat:@"%d", (int)_lockButton.selected]
                                              infos:_entityData[@"infos"]
                                             images:images
                                          successed:successed
                                            failure:failure];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0 || section == 1 || section == 2) {
        return 1;
    }
    
    if ([arrMultiLocation count] == 0) {
        return 1;
    }
    return [arrMultiLocation count];
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_nextIndexPathBeFirstResponder && [indexPath compare:_nextIndexPathBeFirstResponder] == NSOrderedSame) {
        if ([cell isKindOfClass:[EntityDescriptionCell class]])
            [((EntityDescriptionCell *)cell).descTextView becomeFirstResponder];
        _nextIndexPathBeFirstResponder = nil;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2) {
        return UITableViewAutomaticDimension;
    }
    
    return 64.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            ProfileNamePictureCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileNamePictureCell"];
            
            if (!cell) {
                [tableView registerNib:[UINib nibWithNibName:@"ProfileNamePictureCell" bundle:nil] forCellReuseIdentifier:@"ProfileNamePictureCell"];
                cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileNamePictureCell"];
            }
            
            cell.delegate = self;
            cell.roundCornerImage = NO;
            
            [cell setProfileImage:_logoImage_sub placeholderImage:[UIImage imageNamed:@"entity_add_logo"]];
            
            cell.textField.placeholder = @"Name";
            cell.textField.text = _entityName_sub;
            
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
            
            [cell setWallpaper:_wallpaperImage_sub];
            if (_snapshotImage_sub)
                [cell setVideoSnapshot:[_snapshotImage_sub imageByCombiningImage:[[UIImage imageNamed:@"play_video_button"] resizedImage:CGSizeMake(_snapshotImage_sub.size.height / 4, _snapshotImage_sub.size.height / 4) interpolationQuality:kCGInterpolationDefault]]];
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
            cell.descTextView.text = _entityDescription_sub;
            
            return cell;
        }
            break;
        default: {
            AddLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddLocationCell"];
            if (!cell) {
                [tableView registerNib:[UINib nibWithNibName:@"AddLocationCell" bundle:nil] forCellReuseIdentifier:@"AddLocationCell"];
                cell = [tableView dequeueReusableCellWithIdentifier:@"AddLocationCell"];
            }
            cell.locationOfSubEntity.text = [NSString stringWithFormat:@"Location # %ld",(long)indexPath.row + 1];
            cell.locationOfSubEntity.textColor = [UIColor lightGrayColor];
            cell.imgArrow.image = [UIImage imageNamed:@"location_arrow_grey"];
            cell.isCompleted.hidden = NO;
            NSMutableDictionary *dict = [arrMultiLocation objectAtIndex:indexPath.row][@"fields"];
            
            isCompleted = NO;
            if ([dict count] == 0) {
                isCompleted = NO;
            }
            for (NSDictionary *fieldDic in dict) {
                NSString *fieldName = fieldDic[@"field_name"];
                if ([fieldName  isEqual: @"Address"] && ![fieldDic[@"field_value"]  isEqual: @""]) {
                    isCompleted = YES;
                    cell.locationOfSubEntity.text = fieldDic[@"field_value"];
                    
                }else if ([fieldName  isEqual: @"Address"] && [fieldDic[@"field_value"]  isEqual: @""]){
                    isCompleted = NO;
                }
                if ([fieldDic[@"field_value"]  isEqual: @""]) {
                    isCompleted = NO;
                }
                if ([fieldDic[@"field_name"] isEqual:@"Email"] || [fieldDic[@"field_name"] isEqual:@"Email#2"]) {
                    if ([fieldDic[@"field_value"] isEqual:@""] || [fieldDic[@"field_value"] rangeOfString:@" "].length !=0 || ![self checkedEmail:fieldDic[@"field_value"]]){
                        isCompleted = NO;
                    }
                }
            }
            
            if (isCompleted) {
                cell.locationOfSubEntity.textColor=[UIColor blackColor];
                cell.imgArrow.image = [UIImage imageNamed:@"location_arrow_black"];
                cell.isCompleted.hidden = YES;
                //[fieldIsCompletedArray replaceObjectAtIndex:indexPath.row withObject:@1];
            }else{
                cell.locationOfSubEntity.textColor = [UIColor lightGrayColor];
                cell.imgArrow.image = [UIImage imageNamed:@"location_arrow_grey"];
                cell.isCompleted.hidden = NO;
                //[fieldIsCompletedArray replaceObjectAtIndex:indexPath.row withObject:@0];
            }
            
            return cell;
        }
            break;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2)
        [self.view endEditing:NO];
    if (indexPath.section == 3) {
        
        currentIndexCell = (int)indexPath.row;
        [_infoSubEntityDict removeAllObjects];
        isAddedLocation = NO;
        [self updateMainEntity];
        
        AddInfoOfSubEntityViewController *vc = [[AddInfoOfSubEntityViewController alloc] initWithNibName:@"AddInfoOfSubEntityViewController" bundle:nil];
        vc.isCreate = _isCreate;
        vc.entityData = _entityData;
        
        vc.indexOfSubEntity = (int)indexPath.row;
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void) updateMainEntity{
    
    NSMutableArray *arrInfo = [[NSMutableArray alloc] init];
    arrInfo = [_entityData[@"infos"] mutableCopy];
    
    if ([[_infoSubEntityDict objectForKey:@"fields"] count] != 0) {
        [arrInfo replaceObjectAtIndex:currentIndexCell withObject:[_infoSubEntityDict copy]];
        
        [arrMultiLocation replaceObjectAtIndex:currentIndexCell withObject:[_infoSubEntityDict copy]];
    }
    if (isAddedLocation) {
        NSMutableDictionary *dictInformation = [[NSMutableDictionary alloc] init];
        [dictInformation setObject:@{} forKey:@"fields"];
        dictInformation[@"address_confirmed"] = @0;
        dictInformation[@"latitude"] = @0;
        dictInformation[@"longitude"] = @0;
        
        [arrInfo addObject:dictInformation];
        [arrMultiLocation addObject:dictInformation];
        [fieldIsCompletedArray addObject:@0];
        
        currentIndexCell = (int)([arrMultiLocation count] - 1);
    }
    //[_entityData removeAllObjects];
    
    _entityData[@"description"] = _entityDescription_sub;
    _entityData[@"name"] = _entityName_sub;
    
    [_entityData setObject:arrInfo forKey:@"infos"];
    
    if (_isCreate) {
        if (_logoImage_sub) {
            [LocalDBManager saveImage:_logoImage_sub forRemotePath:@"logoImagePathOfCreatingSubEntities"];
            _entityData[@"profile_image"] = @"logoImagePathOfCreatingSubEntities";
        }else{
            _entityData[@"profile_image"] = @"";
        }
        if (_wallpaperImage_sub) {
            [LocalDBManager saveImage:_wallpaperImage_sub forRemotePath:@"wallPaperImagePathOfCreatingSubEntities"];
            _entityData[@"wallpaper_image"] = @"wallPaperImagePathOfCreatingSubEntities";
        }else{
            _entityData[@"wallpaper_image"] = @"";
        }
        if (_videoData_sub) {
            [LocalDBManager saveData:_videoData_sub forRemotePath:@"videoPathOfCreatingSubEntities"];
            [LocalDBManager saveImage:_snapshotImage_sub forRemotePath:@"thumnailPathOfCreatingSubEntities"];
            _entityData[@"video_thumbnail_url"] = @"thumnailPathOfCreatingSubEntities";
            _entityData[@"video_url"] = @"videoPathOfCreatingSubEntities";
            
        }else{
            
            _entityData[@"video_thumbnail_url"] = @"";
            _entityData[@"video_url"] = @"";
        }
    }
    _entityData[@"privilege"] = [NSString stringWithFormat:@"%d", (int)_lockButton.selected];
    
    if ([arrMultiLocation count]>1) {
        _removeAllLocationButton.enabled = YES;
    }
}
#pragma mark - ProfileNamePictureCellDelegate
- (void)profileNameDidChange:(NSString *)text {
    [UIView setAnimationsEnabled:NO];
    [_tables[0] beginUpdates];
    [_tables[0] endUpdates];
    [UIView setAnimationsEnabled:YES];
    
    _entityName_sub = text;
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
    if (_logoImage_sub) {
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
    if (_wallpaperImage_sub) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Remove wallpaper", @"Take wallpaper photo", @"Choose from library", nil];
        actionSheet.destructiveButtonIndex = 0;
        [actionSheet showInView:self.view];
    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take wallpaper photo", @"Choose from library", nil];
        [actionSheet showInView:self.view];
    }
}

- (void)tapProfileVideo:(WallpaperVideoCell *)sender {
    if (_videoUrl_sub || _videoData_sub) { // video exists
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
- (void)removePhoto {
    if (!_isCreate || _createdEntityId) {
        void (^successed)(id responseObject) = ^(id responseObject) {
            NSDictionary *result = responseObject;
            
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            
            if ([[result objectForKey:@"success"] boolValue]) {
                _logoImage_sub = nil;
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
        _logoImage_sub = nil;
        [_tables[0] reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)removeWallpaper {
    if (!_isCreate || _createdEntityId) {
        void (^successed)(id _responseObject) = ^(id _responseObject)
        {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            if ([[_responseObject objectForKey:@"success"] boolValue]) {
                _wallpaperImage_sub = nil;
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
        _wallpaperImage_sub = nil;
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
                _videoUrl_sub = nil;
                _videoData_sub = nil;
                _snapshotImage_sub = nil;
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
        _videoUrl_sub = nil;
        _videoData_sub = nil;
        _snapshotImage_sub = nil;
        [_tables[0] reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)uploadPhoto:(UIImage *)img entityId:(NSString *)entityId completionHandler:(void(^)(BOOL success))completion {
    void (^successed)(id responseObject) = ^(id responseObject) {
        NSDictionary *result = responseObject;
        
        if ([[result objectForKey:@"success"] boolValue]) {
            // save to local cache
            [LocalDBManager saveImage:img forRemotePath:result[@"data"][@"profile_image"]];
            _logoImage_sub = img;
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
        _logoImage_sub = img;
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
            _wallpaperImage_sub = img;
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
        _wallpaperImage_sub = img;
        
        [_tables[0] reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)uploadVideo:(NSData *)video thumbnail:(NSData *)thumb entityId:(NSString *)entityId  completionHandler:(void(^)(BOOL success))completion {
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            _videoData_sub = video;
            _videoUrl_sub = _responseObject[@"data"][@"video"];
            
            // save to local path
            [LocalDBManager saveData:thumb forRemotePath:_responseObject[@"data"][@"video_thumbnail_url"]];
            [LocalDBManager saveData:video forRemotePath:_videoUrl_sub];
            
            _snapshotImage_sub = [UIImage imageWithData:thumb];
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
        _videoData_sub = video;
        [pickerController dismissViewControllerAnimated:YES completion:^{
            _snapshotImage_sub = [UIImage imageWithData:thumb];
            //            _snapshotImage = [_snapshotImage imageByCombiningImage:[[UIImage imageNamed:@"play_video_button"] resizedImage:CGSizeMake(_snapshotImage.size.height / 4, _snapshotImage.size.height / 4) interpolationQuality:kCGInterpolationDefault]];
            [_tables[0] reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
    }
}

- (void)playVideo {
    if (_videoData_sub) {
        [self playVideoAtLocalPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"ZipedVideo.mp4"]];
        return;
    }
    if (!_videoUrl_sub)
        return;
    
    NSString *localFilePath = [LocalDBManager checkCachedFileExist:_videoUrl_sub];
    if (localFilePath) { // exists in local
        [self playVideoAtLocalPath:localFilePath];
    } else {
        // save to temp directory
        NSURL *url = [NSURL URLWithString:_videoUrl_sub];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
        NSProgress *progress;
        
        _downloadProgressHUD = [MBProgressHUD showHUDAddedTo:[AppDelegate sharedDelegate].window animated:YES];
        _downloadProgressHUD.mode = MBProgressHUDModeDeterminate;
        
        NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            return [NSURL fileURLWithPath:[LocalDBManager getCachedFileNameFromRemotePath:_videoUrl_sub]];
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            [progress removeObserver:self forKeyPath:@"fractionCompleted" context:NULL];
            [_downloadProgressHUD hide:YES];
            if (!error) {
                [self playVideoAtLocalPath:[LocalDBManager getCachedFileNameFromRemotePath:_videoUrl_sub]];
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
    
    _entityDescription_sub = description;
}
#pragma mark - ManageEntityViewControllerDelegate
- (void)didFinishAddSubEntity:(NSMutableDictionary *)infoSubEntity {
    _infoSubEntityDict = infoSubEntity;
    isAddedLocation = NO;
    [self updateMainEntity];
    [_tables[0] reloadData];
    
}

- (void)deletedLocationOfEntity:(int)index{
    
    NSMutableArray *arrInfo = [[NSMutableArray alloc] init];
    arrInfo = [_entityData[@"infos"] mutableCopy];
    
    if ([arrInfo[index] objectForKey:@"info_id"])
    {
        NSString *strInfoId = [NSString stringWithFormat:@"%@", arrInfo[index][@"info_id"]];
        strDeleteId = [NSString stringWithFormat: @"%@%@,",strDeleteId, strInfoId];
    }
    
    [arrInfo removeObjectAtIndex:index];
    [arrMultiLocation removeObjectAtIndex:index];
    [fieldIsCompletedArray removeObjectAtIndex:index];
    
    [_entityData setObject:arrInfo forKey:@"infos"];
    
    if ([arrMultiLocation count]>1) {
        _removeAllLocationButton.enabled = YES;
    }else
        _removeAllLocationButton.enabled = NO;
    [_tables[0] reloadData];
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex) {
        if (alertView.tag == 300) {
            [self removeAllLocationOfMainEntity];
            return;
        }
        if (_isCreate)
            [self createEntity];
        else {
            [self saveEntity];
        }
    }
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
