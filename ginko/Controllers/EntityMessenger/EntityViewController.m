//
//  EntityViewController.m
//  ginko
//
//  Created by Harry on 2/20/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "EntityViewController.h"
#import <MessageUI/MessageUI.h>
#import <MediaPlayer/MediaPlayer.h>
#import <TTTAttributedLabel.h>
#import "LocalDBManager.h"
#import "UIImageView+AFNetworking.h"
#import "EntityPreviewDescriptionCell.h"
#import "PreviewFieldCell.h"
#import <MapKit/MapKit.h>
#import "EntityPreviewMapCell.h"
#import "EntityChatWallViewController.h"
#import "SearchAddNotesController.h"
#import "EntityInviteContactsViewController.h"
#import "YYYCommunication.h"

@interface EntityViewController () <MFMailComposeViewControllerDelegate, TTTAttributedLabelDelegate, UITableViewDataSource,UIGestureRecognizerDelegate, UITableViewDelegate, UIAlertViewDelegate> {
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
    
    int crrIndex;
}
@end

@implementation EntityViewController
@synthesize appDelegate;
- (void)viewDidLoad {
    [super viewDidLoad];
    
//    _followButton.selected = _isFollowing;
//    _notesButton.hidden = !_isFollowing;
//    _btnEntityFavorite.hidden =!_isFollowing;
    _btnEntityFavorite.selected = _isFavorite;
    
    entityProfileObserveView.hidden = YES;

    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
  
    if ([_entityData[@"privilege"] intValue] == 1)
        _inviteButton.hidden = NO;
    else if ([_entityData[@"privilege"] intValue] == 0)
        _inviteButton.hidden = YES;
    
    if (_isMultiLocations)
        _notesButton.hidden = true;
    
    _profileImageView.layer.borderWidth = 1;
    _profileImageView.layer.borderColor = COLOR_PURPLE_THEME.CGColor;
    
    entityProfileImageLarge.layer.borderWidth = 4.0f;
    entityProfileImageLarge.layer.borderColor = COLOR_PURPLE_THEME.CGColor;
    entityProfileContainerView.hidden = YES;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideProfileImage)];
    // tapGestureRecognizer.cancelsTouchesInView = NO;
    tapGestureRecognizer.delegate = self;
    [entityProfileObserveView addGestureRecognizer:tapGestureRecognizer];
    
    //UIBarButtonItem *wallButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"btn_wall"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(goWall:)];
    //self.navigationItem.rightBarButtonItem = wallButtonItem;
    
    _mapSection = -1;
    
    // set content mode for image view
    _wallpaperImageView.contentMode = UIViewContentModeScaleAspectFill;
    //_profileImageView.contentMode = UIViewContentModeScaleAspectFill;
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
    
    [self reloadEntity];
    
    _mapImage = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setHidden:NO];
    [self.navigationController.navigationBar addSubview:navView];
    // self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:230.0/256.0 green:1.0f blue:190.0/256.0 alpha:1.0f];
    [self.navigationItem setHidesBackButton:YES animated:NO];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self getCurrentEntityStatus];
}
- (void)getCurrentEntityStatus{
    [[Communication sharedManager] SelectedEntitySummary:[AppDelegate sharedDelegate].sessionId entityId:_entityData[@"entity_id"] successed:^(id _responseObject) {
        _isFollowing = [[[_responseObject objectForKey:@"data"] objectForKey:@"is_followed"] boolValue];
        _followButton.selected = _isFollowing;
        if (!_isMultiLocations)
            _notesButton.hidden = !_isFollowing;
        
        _btnEntityFavorite.hidden =!_isFollowing;
    } failure:^(NSError *err) { }];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [navView removeFromSuperview];
}
- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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

- (void)setNotes:(NSString *)notes {
    NSMutableDictionary *tempDic = [_entityData mutableCopy];
    tempDic[@"notes"] = notes;
    _entityData = [tempDic copy];
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
        crrIndex = 0;
    }
    
    if (_infoId) {
        for (int i = 0 ; i < [infosArray count]; i ++) {
            if ([infosArray[i][@"info_id"] integerValue] == _infoId) {
                crrIndex = i;
            }
        }
    }
    
    NSArray *fieldsArray = infosArray[crrIndex][@"fields"];
    
    // name
    _nameLabel.text = _entityData[@"name"];
    
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
            entityProfileImageLarge.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:localFilePath]];
        } else {
            [_profileImageLoadingIndicator startAnimating];
            [_profileImageView cancelImageRequestOperation];
            [_profileImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:profileImageUrl]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                [_profileImageView setImage:image];
                [entityProfileImageLarge setImage:image];
                [LocalDBManager saveImage:image forRemotePath:profileImageUrl];
                [_profileImageLoadingIndicator stopAnimating];
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to load wallpaper image." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                [_profileImageLoadingIndicator stopAnimating];
            }];
        }
    } else {
        _profileImageView.image = [UIImage imageNamed:@"entity-dummy"];
        entityProfileImageLarge.image = [UIImage imageNamed:@"entity-dummy"];
    }
    
    // set privilege
    int privilege = [_entityData[@"privilege"] intValue];
    _privilegeImageView.image = [UIImage imageNamed:(privilege == 1) ? @"personal_profile_preview_unlocked" : @"personal_profile_preview_locked"];
    _privilegeImageView.hidden = YES;
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
    
    if ([infosArray[crrIndex][@"address_confirmed"] intValue] == 1) {
        _mapSection = sections.count + 1;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)goWall:(id)sender {
    EntityChatWallViewController *vc = [[EntityChatWallViewController alloc] initWithNibName:@"EntityChatWallViewController" bundle:nil];
    vc.entityID = _entityData[@"entity_id"];
    vc.entityName = _entityData[@"name"];
    vc.entityImageURL = _entityData[@"profile_image"];
    vc.isFromProfile = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)follow:(id)sender {
    NSString *msg;
    msg = [NSString stringWithFormat:@"Do you want to %@ this entity?", _isFollowing ? @"unfollow" : @"follow"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.tag = _isFollowing ? 2 : 1;
    [alert show];
}

- (IBAction)notes:(id)sender {
    SearchAddNotesController *controller = [[SearchAddNotesController alloc] initWithNibName:@"SearchAddNotesController" bundle:nil];
    controller.parentController = self;
    if (_entityData[@"notes"] && ![_entityData[@"notes"] isEqual:[NSNull null]])
        controller.strNotes = _entityData[@"notes"];
    else
        controller.strNotes = @"";
    controller.entityID = _entityData[@"entity_id"];
    controller.isMain = NO;
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)invite:(id)sender {
    EntityInviteContactsViewController *vc = [[EntityInviteContactsViewController alloc] initWithNibName:@"EntityInviteContactsViewController" bundle:nil];
    vc.entityID = _entityData[@"entity_id"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onFavorite:(id)sender {
    _btnEntityFavorite.selected = !_btnEntityFavorite.selected;
    if (_btnEntityFavorite.selected) {
        [appDelegate addFavoriteContact:[_entityData objectForKey:@"entity_id"] contactType:@"3"];
        if (_delegate && [_delegate respondsToSelector:@selector(returnIsFavorite:)])
                    [_delegate returnIsFavorite:YES];
    }else{
        [appDelegate removeFavoriteContact:[_entityData objectForKey:@"entity_id"] contactType:@"3"];
        if (_delegate && [_delegate respondsToSelector:@selector(returnIsFavorite:)])
            [_delegate returnIsFavorite:NO];
    }
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

- (void)playVideoAtLocalPath:(NSString *)videoPath {
    _playerVC = [[MPMoviePlayerViewController alloc] init];
    
    _playerVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    _playerVC.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    _playerVC.moviePlayer.contentURL = [NSURL fileURLWithPath:videoPath];
    
    [self presentMoviePlayerViewControllerAnimated:_playerVC];
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
            
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([_entityData[@"infos"][crrIndex][@"latitude"] doubleValue], [_entityData[@"infos"][crrIndex][@"longitude"] doubleValue]);
            
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
        NSString *addressString = [NSString stringWithFormat:@"http://maps.apple.com/?q=%f,%f", [_entityData[@"infos"][crrIndex][@"latitude"] doubleValue], [_entityData[@"infos"][crrIndex][@"longitude"] doubleValue]];
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

#pragma mark - Web API integration
-(void)followEntity
{
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary *result = _responseObject;
        if ([[result objectForKey:@"success"] boolValue]) {
            _isFollowing = YES;
            _isFavorite = YES;
            _followButton.selected = _isFollowing;
            _notesButton.hidden = !_isFollowing;
            
            _btnEntityFavorite.hidden =!_isFollowing;
            _followButton.selected = _isFollowing;
            //[CommonMethods loadFetchAllEntity];
            [[NSNotificationCenter defaultCenter] postNotificationName:CONTACT_SYNC_NOTIFICATION object:nil];
        } else {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSDictionary *dictError = [result objectForKey:@"err"];
            if (dictError) {
                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:[dictError objectForKey:@"errMsg"]];
            } else {
                [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Failed to connect to server!"];
            }
        }
    };
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Internet Connection Error!"];
    };
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[YYYCommunication sharedManager] FollowEntity:[AppDelegate sharedDelegate].sessionId entityid:_entityData[@"entity_id"] successed:successed failure:failure];
}

-(void)unFollowEntity
{
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        NSDictionary *result = _responseObject;
        if ([[result objectForKey:@"success"] boolValue]) {
            _isFollowing = NO;
            _isFavorite = NO;
            _followButton.selected = _isFollowing;
            if (!_isMultiLocations)
                _notesButton.hidden = ! _isFollowing;
            _btnEntityFavorite.hidden =!_isFollowing;
            _btnEntityFavorite.selected = NO;
            _isFavorite = NO;
            _followButton.selected = _isFollowing;
            [self setNotes:@""];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            //[CommonMethods loadFetchAllEntity];
            [[NSNotificationCenter defaultCenter] postNotificationName:CONTACT_SYNC_NOTIFICATION object:nil];
        } else {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSDictionary *dictError = [result objectForKey:@"err"];
            if (dictError) {
                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:[dictError objectForKey:@"errMsg"]];
            } else {
                [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Failed to connect to server!"];
            }
        }
    };
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
        [CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Internet Connection Error!"];
    };
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[YYYCommunication sharedManager] UnFollowEntity:[AppDelegate sharedDelegate].sessionId entityid:_entityData[@"entity_id"] successed:successed failure:failure];
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        if (alertView.tag == 1) {
            [self followEntity];
            if (_delegate && [_delegate respondsToSelector:@selector(returnIsFollowing:)])
                [_delegate returnIsFollowing:YES];
        } else if (alertView.tag == 2) {
            [self unFollowEntity];
            if (_delegate && [_delegate respondsToSelector:@selector(returnIsFollowing:)])
                [_delegate returnIsFollowing:NO];
        }
    }
}

- (IBAction)onProfileImageObserveView:(id)sender {
    entityProfileObserveView.hidden = NO;
    CATransition *transition = [CATransition animation];
    transition.duration = 1.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionReveal;
    transition.delegate = self;
    [entityProfileContainerView.layer addAnimation:transition forKey:nil];
    entityProfileContainerView.hidden = NO;
}

- (IBAction)onEntityProfileObserveViewClose:(id)sender {
    CATransition *transition = [CATransition animation];
    transition.duration = 2.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    transition.delegate = self;
    [entityProfileContainerView.layer addAnimation:transition forKey:nil];
    entityProfileObserveView.hidden = YES;
    entityProfileContainerView.hidden = YES;
}
- (void)hideProfileImage{
    CATransition *transition = [CATransition animation];
    transition.duration = 2.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    transition.delegate = self;
    [entityProfileContainerView.layer addAnimation:transition forKey:nil];
    entityProfileObserveView.hidden = YES;
    entityProfileContainerView.hidden = YES;
}
@end
