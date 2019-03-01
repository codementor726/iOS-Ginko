//
//  PreviewEntityViewController.m
//  ginko
//
//  Created by Harry on 1/15/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "PreviewEntityViewController.h"
#import "ManageEntityViewController.h"
#import "EntityInviteContactsViewController.h"
#import "LocalDBManager.h"
#import "UIImageView+AFNetworking.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MessageUI/MessageUI.h>
#import "YYYCommunication.h"
#import "UIImage+Tint.h"
#import "PreviewFieldCell.h"
#import "EntityPreviewDescriptionCell.h"
#import "EntityPreviewMapCell.h"
#import <MapKit/MapKit.h>
#import "EntityAdminChatViewController.h"
#import "TabRequestController.h"
#import "VideoVoiceConferenceViewController.h"

@interface PreviewEntityViewController () <MFMailComposeViewControllerDelegate, TTTAttributedLabelDelegate, UITableViewDataSource, UITableViewDelegate, ManageEntityViewControllerDelegate, UIAlertViewDelegate,UIGestureRecognizerDelegate> {
    NSMutableArray *phones;
    NSMutableArray *emails;
    NSMutableArray *addresses;
    NSMutableArray *hours;
    NSMutableArray *birthday;
    NSMutableArray *socials;
    NSMutableArray *website;
    NSMutableArray *customs;
    
    NSMutableArray *sections;
    
    NSString *_videoUrl;
    
    // video player
    MPMoviePlayerViewController *_playerVC;
    
    MBProgressHUD *_downloadProgressHUD; // Download progress hud for video
    
    BOOL _isViewMore;
    
    BOOL _shouldShowMore;
    NSIndexPath *_lastIndexPath;
    
    BOOL _didDetermineShowMore;
    
    BOOL _didFinishLayout;
    
    NSMutableArray *_tables;
    
    // width and height constraint for table
    NSLayoutConstraint *_tableWidth, *_tableHeight;
    
    NSInteger _mapSection;
    
    UIImage *_mapImage;
    
    NSMutableDictionary * _entityData;
    
    int current;
}
@end

@implementation PreviewEntityViewController

- (void)viewDidLoad { 
    [super viewDidLoad];
    selfEntityProfileObserveView.hidden = YES;
    
    _profileImageView.layer.borderWidth = 1;
    _profileImageView.layer.borderColor = COLOR_PURPLE_THEME.CGColor;
    
    selfEntityProfileImageLarge.layer.borderWidth = 4.0f;
    selfEntityProfileImageLarge.layer.borderColor = COLOR_PURPLE_THEME.CGColor;
    selfEntityProfileContainerView.hidden = YES;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideProfileImage)];
    // tapGestureRecognizer.cancelsTouchesInView = NO;
    tapGestureRecognizer.delegate = self;
    [selfEntityProfileObserveView addGestureRecognizer:tapGestureRecognizer];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    UIBarButtonItem *inviteButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Invite"] style:UIBarButtonItemStylePlain target:self action:@selector(goInvite:)];
    UIBarButtonItem *editButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(goEdit:)];
    UIBarButtonItem *chatButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BtnChatNav"] style:UIBarButtonItemStylePlain target:self action:@selector(goChat:)];
    
    self.title = @"Preview";
    
    _mapSection = -1;
    
    if (_isCreate && !_isMultiLocation) {
        self.navigationItem.leftBarButtonItems = @[editButtonItem, chatButtonItem];
        self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(goDone:)], inviteButtonItem];
        _deleteButtonHeight.constant = 0;
    } else {
        UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackArrow"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
        self.navigationItem.leftBarButtonItems = @[backButtonItem, chatButtonItem];
        self.navigationItem.rightBarButtonItems = @[editButtonItem, inviteButtonItem];
    }
    
    // set content mode for image view
    _wallpaperImageView.contentMode = UIViewContentModeScaleAspectFill;
   // _profileImageView.contentMode = UIViewContentModeScaleAspectFill;
    _snapshotImageView.contentMode = UIViewContentModeScaleAspectFill;
    _snapshotImageView.clipsToBounds = YES;
    
    _tables = [NSMutableArray new];
    UITableView *table = [[UITableView alloc] initWithFrame:_entityScrollView.bounds style:UITableViewStylePlain];
    table.translatesAutoresizingMaskIntoConstraints = NO;
    table.delegate = self;
    table.dataSource = self;
    [_entityScrollView addSubview:table];
    [_tables addObject:table];
    
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
    
    // set wallpaper image and name view as table header view
    table.tableHeaderView = _headerView;
    
    [table registerNib:[UINib nibWithNibName:@"PreviewFieldCell" bundle:nil] forCellReuseIdentifier:@"PreviewFieldCell"];
    [table registerNib:[UINib nibWithNibName:@"EntityPreviewDescriptionCell" bundle:nil] forCellReuseIdentifier:@"EntityPreviewDescriptionCell"];
    [table registerNib:[UINib nibWithNibName:@"EntityPreviewMapCell" bundle:nil] forCellReuseIdentifier:@"EntityPreviewMapCell"];
    
    _isViewMore = NO;
    
    //[self reloadEntity];
    
    _mapImage = nil;
}
- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getEntityDetails];
    
    _mapImage = nil;
}
- (void) getEntityDetails {
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    // get entity info for preview
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        if ([_responseObject[@"success"] intValue] == 1) {
            _entityData = _responseObject[@"data"];
            [self reloadEntity];
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
                                             entityid:_entityId
                                            successed:successed
                                              failure:failure];
}
- (void)determineShowMore {
    UITableView *table = _tables[0];
    _didDetermineShowMore = YES;
    if (_videoUrl && table.contentSize.height > CGRectGetHeight(table.bounds) + 113) { // show "Show more" only when video exists
        // subtract 226 / 2 = 113 from content size height
        NSIndexPath *indexPath = [table indexPathForRowAtPoint:CGPointMake(0, CGRectGetHeight(table.bounds) - 113 - 20 - 20 - 22)];
        if (indexPath) {
            _shouldShowMore = YES;
            _lastIndexPath = indexPath;
            [table reloadData];
        }
    }
}

- (void)viewDidLayoutSubviews {
    _didFinishLayout = YES;
    _tableWidth.constant = CGRectGetWidth(_entityScrollView.bounds);
    _tableHeight.constant = CGRectGetHeight(_entityScrollView.bounds);
    if (!_didDetermineShowMore) {
        [self determineShowMore];
    }
}

- (void)reloadEntity {
    _didDetermineShowMore = NO;
    _shouldShowMore = NO;
    _lastIndexPath = nil;
    
    NSArray *infosArray = _entityData[@"infos"];
    if ([infosArray count] == 1) {
        [_btnRemoveLocation setTitle:@"Remove entity" forState:UIControlStateNormal];
        current = 0;
    }else{
        [_btnRemoveLocation setTitle:@"Remove location" forState:UIControlStateNormal];
    }
    
    if (_infoId) {
        for (int i = 0 ; i < [infosArray count]; i ++) {
            if ([infosArray[i][@"info_id"] integerValue] == _infoId) {
                current = i;
            }
        }
    }
    
    NSArray *fieldsArray = infosArray[current][@"fields"];
    
    // name
    _nameLabel.text = _entityData[@"name"];
    _nameLabel.hidden = NO;
    
    // parse wallpaper
    NSArray *imagesArray = _entityData[@"images"];
    [_wallpaperLoadingIndicator stopAnimating];
    _wallpaperImageView.image = [UIImage imageNamed:@"DummyProfileImage"];
    for (NSDictionary *imageDic in imagesArray) {
        if ([imageDic[@"z_index"] intValue] == 0) { // this is background
            NSString *wallpaperImageUrl = imageDic[@"image_url"];
            
            if (wallpaperImageUrl && ![wallpaperImageUrl isEqualToString:@""]) {
                NSString *localFilePath = [LocalDBManager checkCachedFileExist:wallpaperImageUrl];
                if (localFilePath) {
                    // load from local
                    _wallpaperImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:localFilePath]];
                } else {
                    [_wallpaperLoadingIndicator startAnimating];
                    [_wallpaperImageView cancelImageRequestOperation];
                    [_wallpaperImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:wallpaperImageUrl]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                        [_wallpaperImageView setImage:image];
                        [LocalDBManager saveImage:image forRemotePath:wallpaperImageUrl];
                        [_wallpaperLoadingIndicator stopAnimating];
                    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to load wallpaper image." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                        [_wallpaperLoadingIndicator stopAnimating];
                    }];
                }
            } else {
                _wallpaperImageView.image = nil;
            }
        }
    }
    
    // parse profile image
    NSString *profileImageUrl = _entityData[@"profile_image"];
    
    [_profileImageLoadingIndicator stopAnimating];
    if (profileImageUrl && ![profileImageUrl isEqualToString:@""]) {
        NSString *localFilePath = [LocalDBManager checkCachedFileExist:profileImageUrl];
        if (localFilePath) {
            // load from local
            _profileImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:localFilePath]];
            selfEntityProfileImageLarge.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:localFilePath]];
        } else {
            [_profileImageLoadingIndicator startAnimating];
            [_profileImageView cancelImageRequestOperation];
            [_profileImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:profileImageUrl]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                [_profileImageView setImage:image];
                 [selfEntityProfileImageLarge setImage:image];
                [LocalDBManager saveImage:image forRemotePath:profileImageUrl];
                [_profileImageLoadingIndicator stopAnimating];
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to load wallpaper image." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                [_profileImageLoadingIndicator stopAnimating];
            }];
        }
    } else {
        _profileImageView.image = [UIImage imageNamed:@"entity-dummy"];
        selfEntityProfileImageLarge.image = [UIImage imageNamed:@"entity-dummy"];
    }
    
    // set privilege
    int privilege = [_entityData[@"privilege"] intValue];
    _privilegeImageView.image = [UIImage imageNamed:(privilege == 1) ? @"personal_profile_preview_unlocked" : @"personal_profile_preview_locked"];
    
    // parse fields
    phones = [NSMutableArray new];
    emails = [NSMutableArray new];
    addresses = [NSMutableArray new];
    hours = [NSMutableArray new];
    birthday = [NSMutableArray new];
    socials = [NSMutableArray new];
    website = [NSMutableArray new];
    customs = [NSMutableArray new];
    
    sections = [NSMutableArray new];
    
    NSArray *allFields = @[@"Mobile", @"Mobile#2", @"Mobile#3", @"Phone", @"Phone#2", @"Phone#3", @"Email", @"Email#2", @"Address",@"Address#2", @"Fax", @"Hours", @"Birthday", @"Facebook", @"Twitter", @"LinkedIn", @"Website", @"Custom", @"Custom#2", @"Custom#3"];
    
    for (NSString *fieldName in allFields) {
        NSArray *filteredArray = [fieldsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"field_name == %@", fieldName]];
        if (filteredArray.count > 0) {
            NSString *fieldType = [self getFieldTypeForFieldName:fieldName];
            if ([fieldType isEqualToString:@"mobile"] || [fieldType isEqualToString:@"phone"]) {
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
    
    if ([infosArray[current][@"address_confirmed"] intValue] == 1) {
        _mapSection = sections.count + 1;
    }else{
        _mapSection = -1;
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
    NSLog(@"sections--%lu",(unsigned long)sections.count);
    // parse video
    _snapshotImageView.backgroundColor = [UIColor blackColor];
    if (_entityData[@"video_url"] && ![_entityData[@"video_url"] isEqualToString:@""]) {
        // video exists
        ((UITableView *)_tables[0]).tableFooterView = _videoView;
        
        // load snapshot image
        NSString *thumbnailUrl = _entityData[@"video_thumbnail_url"];
        if (thumbnailUrl && ![thumbnailUrl isEqualToString:@""]) {
            NSString *localFilePath = [LocalDBManager checkCachedFileExist:thumbnailUrl];
            if (localFilePath) {
                // load from local
                _snapshotImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:localFilePath]];
            } else {
                [_snapshotImageView cancelImageRequestOperation];
                [_snapshotImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:thumbnailUrl]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                    [_snapshotImageView setImage:image];
                    [LocalDBManager saveImage:image forRemotePath:thumbnailUrl];
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to load video snapshot image." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }];
            }
        }
        
        NSString *videoUrl = _entityData[@"video_url"];
        if (videoUrl && ![videoUrl isEqualToString:@""]) {
            _videoUrl = videoUrl;
        } else {
            _videoUrl = nil;
        }
    } else {
        _videoUrl = nil;
        ((UITableView *)_tables[0]).tableFooterView = nil;
    }
    
    [((UITableView *)_tables[0]) reloadData];
    
    if (_didFinishLayout) {
        [self determineShowMore];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goChat:(id)sender {
    EntityAdminChatViewController *vc = [[EntityAdminChatViewController alloc] initWithNibName:@"EntityAdminChatViewController" bundle:nil];
    vc.entityID = _entityData[@"entity_id"];
    vc.entityName = _entityData[@"name"];
    vc.navBarColor = _isCreate;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goBack:(id)sender {
    if (_isMultiLocation) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)goDone:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)goInvite:(id)sender {
    EntityInviteContactsViewController *vc = [[EntityInviteContactsViewController alloc] initWithNibName:@"EntityInviteContactsViewController" bundle:nil];
    vc.entityID = _entityData[@"entity_id"];
    vc.navBarColor = _isCreate;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)playVideo:(id)sender {
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

- (IBAction)deleteEntity:(id)sender {
    if ([_entityData[@"infos"] count] == 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GINKO" message:@"Are you sure you want to remove this entity?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alert.tag = 100;
        [alert show];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GINKO" message:@"Are you sure you want to remove this location?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alert.tag = 200;
        [alert show];
    }
    
}

- (IBAction)onFavority:(id)sender {
}

- (void)playVideoAtLocalPath:(NSString *)videoPath {
    _playerVC = [[MPMoviePlayerViewController alloc] init];
    
    _playerVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    _playerVC.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    _playerVC.moviePlayer.contentURL = [NSURL fileURLWithPath:videoPath];
    
    [self presentMoviePlayerViewControllerAnimated:_playerVC];
}

- (void)goEdit:(id)sender {
    
    ManageEntityViewController *vc = [[ManageEntityViewController alloc] initWithNibName:@"ManageEntityViewController" bundle:nil];
    vc.isCreate = _isCreate;
    vc.entityData = _entityData;
    vc.currentIndex = current;
    if ([_entityData[@"infos"] count] == 1) {
        vc.isSubEntity = NO;
    }else
        vc.isSubEntity = YES;
    
    if ([_entityData[@"infos"] count] == 1) {
        vc.isMultiLocation = NO;
    }else{
        vc.isMultiLocation = YES;
    }    
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showMore:(id)sender {
    _isViewMore = !_isViewMore;
    UITableView *table = _tables[0];
    [table reloadData];
}

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return 0;
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    //    if (section != [self numberOfSectionsInTableView:tableView] - 1 && _isViewMore) {
    //        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 46)];
    //        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 25, CGRectGetWidth(tableView.frame) - 20 * 2, 15)];
    //        label.font = [UIFont boldSystemFontOfSize:12];
    //        NSMutableArray *selectedArray = sections[section];
    //        if ([selectedArray isEqual:companyntitle])
    //            label.text = @"";
    //        if ([selectedArray isEqual:phones])
    //            label.text = @"PHONES";
    //        if ([selectedArray isEqual:emails])
    //            label.text = @"E-MAILS";
    //        if ([selectedArray isEqual:addresses])
    //            label.text = @"ADDRESSES";
    //        if ([selectedArray isEqual:birthday])
    //            label.text = @"BIRTHDAY";
    //        if ([selectedArray isEqual:socials])
    //            label.text = @"SOCIAL NETWORKS";
    //        if ([selectedArray isEqual:website])
    //            label.text = @"WEBSITE";
    //        if ([selectedArray isEqual:customs])
    //            label.text = @"CUSTOMS";
    //
    //        [view addSubview:label];
    //        view.backgroundColor = [UIColor whiteColor];
    //        return view;
    //    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), section == 0 ? 0 : 20)];
    
//    if (section == 0) { // category
//        
//    }
    
    if (_shouldShowMore && section == [self numberOfSectionsInTableView:tableView] - 1) {
        UIButton *moreButton = [[UIButton alloc] initWithFrame:view.bounds];
        [moreButton setImage:[UIImage imageNamed:_isViewMore ? @"ShowLessButton" : @"ShowMoreButton"] forState:UIControlStateNormal];
        [moreButton setTitle:_isViewMore ? @"Show less" : @"Show more" forState:UIControlStateNormal];
        moreButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        moreButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
        [moreButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [moreButton addTarget:self action:@selector(showMore:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:moreButton];
    }
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_shouldShowMore) {
        if (_isViewMore) {
            if (_mapSection == -1)
                return sections.count + 2;  // 1 for category, 1 for view more
            else
                return sections.count + 3;  // plus 1 for map
        } else {
            return (_lastIndexPath.section + 2);    // 1 for view more, 1 for index
        }
    } else {
        if (_mapSection == -1)
            return sections.count + 1;  // 1 for category
        else
            return sections.count + 2;  // plus 1 for map
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)   // category
        return 1;
    
    if (_shouldShowMore) {
        if (section == [self numberOfSectionsInTableView:tableView] - 1)    // last is for view more
            return 0;
        else {
            if (_isViewMore) {
                if (_mapSection == -1 || section < _mapSection)
                    return [sections[section - 1] count];
                else if (section == _mapSection)
                    return 1;
                else
                    return [sections[section - 2] count];
            } else {
                if (section == _lastIndexPath.section)
                    return _lastIndexPath.row + 1;
                else {
                    if (_mapSection == -1 || section < _mapSection)
                        return [sections[section - 1] count];
                    else if (section == _mapSection)
                        return 1;
                    else
                        return [sections[section - 2] count];
                }
            }
        }
    } else {
        if (_mapSection == -1 || section < _mapSection)
            return [sections[section - 1] count];
        else if (section == _mapSection)
            return 1;
        else
            return [sections[section - 2] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        EntityPreviewDescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EntityPreviewDescriptionCell"];
        
        cell.categoryLabel.textColor = [UIColor colorWithWhite:141.f/255 alpha:1];
        switch ([_entityData[@"category_id"] intValue]) {
            case 0:
                cell.categoryLabel.text = @"Local Business or Place";
                break;
            case 1:
                cell.categoryLabel.text = @"Company, Organization or Institution";
                break;
            case 2:
                cell.categoryLabel.text = @"Brand or Product";
                break;
            case 3:
                cell.categoryLabel.text = @"Entertainment";
                break;
            case 4:
                cell.categoryLabel.text = @"Artist, Band or Public Figure";
                break;
            case 5:
                cell.categoryLabel.text = @"Cause or Community";
                break;
            default:
                break;
        }
        
        if (_entityData[@"description"] && ![_entityData[@"description"] isEqualToString:@""]) {
            cell.descLabel.text = _entityData[@"description"];
            cell.descLabel.textColor = [UIColor blackColor];
        } else {
            cell.descLabel.text = @"";
//            cell.descLabel.textColor = [UIColor colorWithWhite:141.f/255 alpha:1];
        }
        return cell;
    }
    PreviewFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PreviewFieldCell"];
    
    cell.fieldLabel.font = [UIFont systemFontOfSize:15];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.fieldLabel.enabledTextCheckingTypes = 0;
    cell.fieldLabel.delegate = self;
    
    if (_mapSection == indexPath.section) { // map cell
        EntityPreviewMapCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EntityPreviewMapCell"];

        if (_mapImage) {
            cell.mapImageView.image = _mapImage;
        } else {
            MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
            
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([_entityData[@"infos"][current][@"latitude"] doubleValue], [_entityData[@"infos"][current][@"longitude"] doubleValue]);
            
            options.region = MKCoordinateRegionMake(coord, MKCoordinateSpanMake(0.01, 0.01));
            options.scale = [UIScreen mainScreen].scale;
            options.size = CGSizeMake(320, 146);
            
            MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
            [snapshotter startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
                MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:nil];
//                pin.pinColor = [UIColor redColor];
                
                UIImage *image = snapshot.image;
                UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale);
                [image drawAtPoint:CGPointZero];
                
                CGPoint point = [snapshot pointForCoordinate:coord];
                point.x = point.x + pin.centerOffset.x - (pin.bounds.size.width / 2);
                point.y = point.y + pin.centerOffset.y - (pin.bounds.size.height / 2);
                [pin.image drawAtPoint:point];
                
                UIImage *compositeImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                _mapImage = compositeImage;
                if ([tableView.indexPathsForVisibleRows containsObject:indexPath]) {
                    cell.mapImageView.image = _mapImage;
                }
            }];
        }
        
        return cell;
    }
    
    
    NSDictionary *fieldDic;
    if (_mapSection == -1 || indexPath.section < _mapSection)
        fieldDic = sections[indexPath.section - 1][indexPath.row];
    else {
        fieldDic = sections[indexPath.section - 2][indexPath.row];
    }
    
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

#pragma mark - UITableViewCellDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        return;
    
    if (indexPath.section == _mapSection) {
        NSString *addressString = [NSString stringWithFormat:@"http://maps.apple.com/?q=%f,%f", [_entityData[@"infos"][current][@"latitude"] doubleValue], [_entityData[@"infos"][current][@"longitude"] doubleValue]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:addressString]];
        return;
    }
    
    NSDictionary *fieldDic;
    
    if (_mapSection == -1 || indexPath.section < _mapSection)
        fieldDic = sections[indexPath.section - 1][indexPath.row];
    else {
        fieldDic = sections[indexPath.section - 2][indexPath.row];
    }
    
    NSString *fieldType = [self getFieldTypeForFieldName:fieldDic[@"field_name"]];
    NSString *fieldValue = fieldDic[@"field_value"];
    
    if (!fieldValue || [fieldValue isEqualToString:@""])
        return;
    
    if ([fieldType isEqualToString:@"company"]) {
        
    } else if ([fieldType isEqualToString:@"title"]) {
        
    } else if ([fieldType isEqualToString:@"mobile"] || [fieldType isEqualToString:@"phone"] || [fieldType isEqualToString:@"fax"]) {
        NSString *phoneNumStr =fieldValue;
        NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"() "];
        phoneNumStr = [[phoneNumStr componentsSeparatedByCharactersInSet:doNotWant] componentsJoinedByString:@""];
        NSURL *phoneUrl = [NSURL URLWithString:[@"telprompt://" stringByAppendingString:phoneNumStr]];
        NSURL *phoneFallbackUrl = [NSURL URLWithString:[@"tel://" stringByAppendingString:phoneNumStr]];
        
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
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    //    if(result == MFMailComposeResultSent)
    //        [[[UIAlertView alloc] initWithTitle:@"Mail sent!" message:nil delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil] show];
    [controller dismissViewControllerAnimated:YES completion:nil];
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

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if (url)
        [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - ManageEntityViewControllerDelegate
- (void)didFinishEdit:(NSMutableDictionary *)entityData {
    _entityData = entityData;
    
    [self reloadEntity];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        if (alertView.tag == 100) {
            [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            
            void (^successed)( id _responseObject ) = ^(id _responseObject ) {
                [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                
                if ([[_responseObject objectForKey:@"success"] boolValue]) {
                   [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                }
            };
            
            void (^failure)(NSError* _error) = ^(NSError* _error) {
                [ MBProgressHUD hideHUDForView:self.view animated : YES ] ;
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to delete entity, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            };
            
            [[YYYCommunication sharedManager] DeleteEntity:[AppDelegate sharedDelegate].sessionId
                                                  entityid:_entityData[@"entity_id"]
                                                 successed:successed
                                                   failure:failure];
        }else if (alertView.tag == 200){
            [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            
            void (^successed)( id _responseObject ) = ^(id _responseObject ) {
                [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                
                if ([[_responseObject objectForKey:@"success"] boolValue]) {
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
                                                      infoid:_entityData[@"infos"][current][@"info_id"]
                                                   successed:successed
                                                     failure:failure];
        }
        
    }
}
- (void)movePushNotificationViewController{
    TabRequestController *tabRequestController = [TabRequestController sharedController];
    tabRequestController.selectedIndex = 1;
    [self.navigationController pushViewController:tabRequestController animated:YES];
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
    viewcontroller.navBarColor = _isCreate;
    [self.navigationController pushViewController:viewcontroller animated:YES];
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
- (IBAction)onSelfEntityObserveView:(id)sender {
    selfEntityProfileObserveView.hidden = NO;
    CATransition *transition = [CATransition animation];
    transition.duration = 1.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionReveal;
    transition.delegate = self;
    [selfEntityProfileContainerView.layer addAnimation:transition forKey:nil];
    selfEntityProfileContainerView.hidden = NO;
}

- (IBAction)onSelfEntityObserveViewClose:(id)sender {
    CATransition *transition = [CATransition animation];
    transition.duration = 2.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    transition.delegate = self;
    [selfEntityProfileContainerView.layer addAnimation:transition forKey:nil];
    selfEntityProfileObserveView.hidden = YES;
    selfEntityProfileContainerView.hidden = YES;
}
- (void)hideProfileImage{
    CATransition *transition = [CATransition animation];
    transition.duration = 2.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    transition.delegate = self;
    [selfEntityProfileContainerView.layer addAnimation:transition forKey:nil];
    selfEntityProfileObserveView.hidden = YES;
    selfEntityProfileContainerView.hidden = YES;
}
@end
