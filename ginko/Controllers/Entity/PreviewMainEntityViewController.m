//
//  PreviewMainEntityViewController.m
//  ginko
//
//  Created by stepanekdavid on 4/18/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "PreviewMainEntityViewController.h"

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
#import "SubEntityPreviewCell.h"
#import "MoreLocationCell.h"
#import "PreviewEntityViewController.h"
#import "AddSubEntitiesViewController.h"
#import "AllEntityPreviewViewController.h"
#import "TabRequestController.h"
#import "VideoVoiceConferenceViewController.h"

@interface PreviewMainEntityViewController () <MFMailComposeViewControllerDelegate, TTTAttributedLabelDelegate, UITableViewDataSource, UITableViewDelegate, ManageEntityViewControllerDelegate, UIAlertViewDelegate,AddSubEntitiesViewControllerDelegate,AllEntityPreviewViewControllerDelegate,UIGestureRecognizerDelegate> {
    NSMutableArray *phones;
    NSMutableArray *emails;
    NSMutableArray *addresses;
    NSMutableArray *hours;
    NSMutableArray *birthday;
    NSMutableArray *socials;
    NSMutableArray *website;
    NSMutableArray *customs;
    
    NSMutableArray *sections;
    
    NSIndexPath *_lastIndexPath;
    
    BOOL _didFinishLayout;
    
    NSMutableArray *_tables;
    
    // width and height constraint for table
    NSLayoutConstraint *_tableWidth, *_tableHeight;
    
    NSMutableArray *arrLocationsOfSubEntity;
    
    NSArray *_allFieldNames;
    
    BOOL showMorebutton;
    
    NSMutableDictionary * _entityData;
    
    AppDelegate *appDelegate;
    
}
@end

@implementation PreviewMainEntityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    selfMainEntityObserveView.hidden = YES;
    
    arrLocationsOfSubEntity = [NSMutableArray new];
    // total field name array
    _allFieldNames = @[@"Mobile", @"Mobile#2", @"Mobile#3", @"Phone", @"Phone#2", @"Phone#3", @"Email", @"Email#2", @"Address", @"Address#2", @"Fax", @"Hours", @"Birthday", @"Facebook", @"Twitter", @"LinkedIn", @"Website", @"Custom", @"Custom#2", @"Custom#3"];
    _profileImageView.layer.borderWidth = 1;
    _profileImageView.layer.borderColor = COLOR_PURPLE_THEME.CGColor;
    
    showMorebutton = NO;
    
    _getCurrentGPSCallTimer = [[NSTimer alloc] init];
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_locationManager requestWhenInUseAuthorization];
    }
    appDelegate = [AppDelegate sharedDelegate];
    _currentLocationforMultiLocations = appDelegate.currentLocationforMultiLocations;
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusDenied) {
        NSString *title;
        title = (status == kCLAuthorizationStatusDenied)?@"Location services are off" : @"Background location is not enabled";
        NSString *message = @"To use background location you must turn on 'Always' or 'While Using the App' in the Location Services Settings";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
        alert.tag = 1001;
        [alert show];
    }
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    UIBarButtonItem *inviteButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Invite"] style:UIBarButtonItemStylePlain target:self action:@selector(goInvite:)];
    UIBarButtonItem *editButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(goEdit:)];
    UIBarButtonItem *chatButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BtnChatNav"] style:UIBarButtonItemStylePlain target:self action:@selector(goChat:)];
    
    self.title = @"Preview";
    
    if (_isCreate) {
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
    //_profileImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    
    selfMainEntityProfileImageLarge.layer.borderWidth = 4.0f;
    selfMainEntityProfileImageLarge.layer.borderColor = COLOR_PURPLE_THEME.CGColor;
    selfMainEntityProfileContainerView.hidden = YES;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideProfileImage)];
    // tapGestureRecognizer.cancelsTouchesInView = NO;
    tapGestureRecognizer.delegate = self;
    [selfMainEntityObserveView addGestureRecognizer:tapGestureRecognizer];
    
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
    
    [table registerNib:[UINib nibWithNibName:@"SubEntityPreviewCell" bundle:nil] forCellReuseIdentifier:@"SubEntityPreviewCell"];
    [table registerNib:[UINib nibWithNibName:@"MoreLocationCell" bundle:nil] forCellReuseIdentifier:@"MoreLocationCell"];
    [table registerNib:[UINib nibWithNibName:@"EntityPreviewDescriptionCell" bundle:nil] forCellReuseIdentifier:@"EntityPreviewDescriptionCell"];
    [table registerNib:[UINib nibWithNibName:@"EntityPreviewMapCell" bundle:nil] forCellReuseIdentifier:@"EntityPreviewMapCell"];

}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [_locationManager startUpdatingLocation];
    _getCurrentGPSCallTimer = [NSTimer scheduledTimerWithTimeInterval:(3.0) target:self selector:@selector(repeatLocationUpdating) userInfo:nil repeats:YES];
    
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
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_locationManager stopUpdatingLocation];
    [_getCurrentGPSCallTimer invalidate];
    _getCurrentGPSCallTimer = nil;
    appDelegate.currentLocationforMultiLocations = _currentLocationforMultiLocations;
    
}
- (void)viewDidLayoutSubviews {
    _didFinishLayout = YES;
    _tableWidth.constant = CGRectGetWidth(_entityScrollView.bounds);
    _tableHeight.constant = CGRectGetHeight(_entityScrollView.bounds);
}

- (void)repeatLocationUpdating{
    [_locationManager startUpdatingLocation];
}
- (void)reloadEntity {
    _lastIndexPath = nil;
    [arrLocationsOfSubEntity removeAllObjects];
    NSMutableArray * sortedMtArray = [NSMutableArray new];
    sortedMtArray = _entityData[@"infos"];
    NSArray *orderedUsers = [sortedMtArray sortedArrayUsingComparator:^(id a,id b) {
        NSArray *userA = (NSArray *)a;
        NSArray *userB = (NSArray *)b;
        NSLog(@"%@", [userA valueForKey:@"latitude"]);
        if ([[userA valueForKey:@"latitude"] isKindOfClass:[NSNull class]] && ![[userB valueForKey:@"latitude"] isKindOfClass:[NSNull class]]) {
            return NSOrderedDescending;
        }else if (![[userA valueForKey:@"latitude"] isKindOfClass:[NSNull class]] && [[userB valueForKey:@"latitude"] isKindOfClass:[NSNull class]]){
            return NSOrderedAscending;
        }else if ([[userA valueForKey:@"latitude"] isKindOfClass:[NSNull class]] && [[userB valueForKey:@"latitude"] isKindOfClass:[NSNull class]]){
            return NSOrderedSame;
        }else {
            CGFloat aLatitude = [[userA valueForKey:@"latitude"] floatValue];
            CGFloat aLongitude = [[userA valueForKey:@"longitude"] floatValue];
            
            CLLocation *participantALocation = [[CLLocation alloc] initWithLatitude:aLatitude longitude:aLongitude];
            
            CGFloat bLatitude = [[userB valueForKey:@"latitude"] floatValue];
            CGFloat bLongitude = [[userB valueForKey:@"longitude"] floatValue];
            CLLocation *participantBLocation = [[CLLocation alloc] initWithLatitude:bLatitude longitude:bLongitude];
            
            CLLocation *myLocation = [[CLLocation alloc] initWithLatitude:_currentLocationforMultiLocations.latitude longitude:_currentLocationforMultiLocations.longitude];
            
            CLLocationDistance distanceA = [participantALocation distanceFromLocation:myLocation];
            CLLocationDistance distanceB = [participantBLocation distanceFromLocation:myLocation];
            if (distanceA < distanceB) {
                return NSOrderedAscending;
            } else if (distanceA > distanceB) {
                return NSOrderedDescending;
            } else {
                return NSOrderedSame;
            }
        }
        
        
        
    }];
    
    //update EntityData by Sorted Data
    for (int i = 0; i < orderedUsers.count; i ++) {
        [arrLocationsOfSubEntity addObject:orderedUsers[i]];
    }
    
    // name
    if ([sortedMtArray count] > 2) {
        showMorebutton = YES;
    }else{
        showMorebutton = NO;
    }
    
    
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
            selfMainEntityProfileImageLarge.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:localFilePath]];
        } else {
            [_profileImageLoadingIndicator startAnimating];
            [_profileImageView cancelImageRequestOperation];
            [_profileImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:profileImageUrl]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                [_profileImageView setImage:image];
                [selfMainEntityProfileImageLarge setImage:image];
                [LocalDBManager saveImage:image forRemotePath:profileImageUrl];
                [_profileImageLoadingIndicator stopAnimating];
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to load wallpaper image." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                [_profileImageLoadingIndicator stopAnimating];
            }];
        }
    } else {
        _profileImageView.image = [UIImage imageNamed:@"entity-dummy"];
        selfMainEntityProfileImageLarge.image = [UIImage imageNamed:@"entity-dummy"];
    }
    
    // set privilege
    int privilege = [_entityData[@"privilege"] intValue];
    _privilegeImageView.image = [UIImage imageNamed:(privilege == 1) ? @"personal_profile_preview_unlocked" : @"personal_profile_preview_locked"];
    
    
    [((UITableView *)_tables[0]) reloadData];
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
   [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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


- (IBAction)deleteEntity:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GINKO" message:@"Are you sure you want to remove this entity?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (IBAction)onFavority:(id)sender {
}

- (void)goEdit:(id)sender {
    //    if (_isCreate) {
    //        [self goBack:sender];
    //        return;
    //    }
//    ManageEntityViewController *vc = [[ManageEntityViewController alloc] initWithNibName:@"ManageEntityViewController" bundle:nil];
//    vc.isCreate = NO;
//    vc.entityData = _entityData;
//    vc.delegate = self;
//    [self.navigationController pushViewController:vc animated:YES];
    
    
    AddSubEntitiesViewController *vc = [[AddSubEntitiesViewController alloc] initWithNibName:@"AddSubEntitiesViewController" bundle:nil];
    vc.isCreate = NO;
    vc.entityData = [_entityData mutableCopy];
    vc.isMultiLocation = YES;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!showMorebutton) {
        return 2;
    }
    return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return 0;
    return 20;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)   // category
        return 1;
    if (showMorebutton){
        if (section == 1)
            return 2;
        else if (section == 2)
            return 1;
    }
    return [arrLocationsOfSubEntity count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return UITableViewAutomaticDimension;
    }
    
    return 64.0f;
}
-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    UITableViewHeaderFooterView *v = (UITableViewHeaderFooterView *)view;
    //v.backgroundView.backgroundColor = [UIColor lightGrayColor];
    v.backgroundView.backgroundColor = [UIColor whiteColor];
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
    }else if (indexPath.section == 1){
        SubEntityPreviewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SubEntityPreviewCell"];
        
        cell.subEntityImg.image =  _profileImageView.image;
        
        [cell.subEntityImg setImageWithURL:[NSURL URLWithString:_entityData[@"profile_image"]]];
        
        NSMutableDictionary *dict = [arrLocationsOfSubEntity objectAtIndex:indexPath.row][@"fields"];
        
        
        cell.lblLocation.text = @"Can't Location field!";
        cell.lblLocation.textColor=[UIColor lightGrayColor];
        
        for (NSDictionary *fieldDic in dict) {
            NSString *fieldName = fieldDic[@"field_name"];
            if ([fieldName  isEqual: @"Address"]) {
                cell.lblLocation.text = fieldDic[@"field_value"];
                cell.lblLocation.textColor=[UIColor blackColor];
            }
        }
        if([[arrLocationsOfSubEntity objectAtIndex:indexPath.row][@"address_confirmed"] intValue] == 0){
            cell.lblDistance.text = @"No address!";
            cell.lblDistance.textColor = [UIColor lightGrayColor];
        }else
        {
            //calculate distance
            CGFloat aLatitude = [[arrLocationsOfSubEntity objectAtIndex:indexPath.row][@"latitude"] floatValue];
            CGFloat aLongitude = [[arrLocationsOfSubEntity objectAtIndex:indexPath.row][@"longitude"] floatValue];
            CLLocation *participantALocation = [[CLLocation alloc] initWithLatitude:aLatitude longitude:aLongitude];
            CLLocation *myLocation = [[CLLocation alloc] initWithLatitude:_currentLocationforMultiLocations.latitude longitude:_currentLocationforMultiLocations.longitude];
            
            CLLocationDistance distanceA = [participantALocation distanceFromLocation:myLocation];
            
            cell.lblDistance.text = [NSString stringWithFormat:@"%0.2f mi", ((int)((distanceA / 1609.344)*100))/100.f];
            cell.lblDistance.textColor = [UIColor blackColor];
        }
        return cell;
    }
    MoreLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MoreLocationCell"];
    
    cell.moreItems.text = [NSString stringWithFormat:@"%lu+",[arrLocationsOfSubEntity count] - 2];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0)
        [self.view endEditing:NO];
    else if (indexPath.section == 1) {
        PreviewEntityViewController *vc = [[PreviewEntityViewController alloc] initWithNibName:@"PreviewEntityViewController" bundle:nil];
        vc.isCreate = _isCreate;
        vc.infoId = (int)[[[arrLocationsOfSubEntity objectAtIndex:indexPath.row] valueForKey:@"info_id"] integerValue] ;
        //vc.entityData = _entityData ;
        vc.entityId = [_entityData objectForKey:@"entity_id"] ;
        vc.isMultiLocation = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.section ==2){
        AllEntityPreviewViewController *vc = [[AllEntityPreviewViewController alloc] initWithNibName:@"AllEntityPreviewViewController" bundle:nil];
        vc.isCreate = _isCreate;
        vc.entityId = _entityData[@"entity_id"];
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
#pragma mark - ManageEntityViewControllerDelegate
- (void)returnMainEdit:(NSDictionary *)entityData {
    _entityData = [entityData mutableCopy];
    
    [self reloadEntity];
}
#pragma mark - AllEntityPreviewViewControllerDelegate
- (void)didFinishAllEntity:(NSMutableDictionary *)entityDataChanged {
    _entityData = entityDataChanged;
    [self reloadEntity];
    
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        if (alertView.tag == 1001){
            [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }else {
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
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation * location = locations.lastObject;
    
    CLLocation *oldLocation = [[CLLocation alloc] initWithLatitude:_currentLocationforMultiLocations.latitude longitude:_currentLocationforMultiLocations.longitude];
    
    CLLocationDistance distance = [oldLocation distanceFromLocation:location];
    
    if (distance > 50.0) {
        _currentLocationforMultiLocations = location.coordinate;
        [arrLocationsOfSubEntity removeAllObjects];
        NSMutableArray * sortedMtArray = [NSMutableArray new];
        sortedMtArray = _entityData[@"infos"];
        NSArray *orderedUsers = [sortedMtArray sortedArrayUsingComparator:^(id a,id b) {
            NSArray *userA = (NSArray *)a;
            NSArray *userB = (NSArray *)b;
            if ([[userA valueForKey:@"latitude"] isKindOfClass:[NSNull class]] && ![[userB valueForKey:@"latitude"] isKindOfClass:[NSNull class]]) {
                return NSOrderedDescending;
            }else if (![[userA valueForKey:@"latitude"] isKindOfClass:[NSNull class]] && [[userB valueForKey:@"latitude"] isKindOfClass:[NSNull class]]){
                return NSOrderedAscending;
            }else if ([[userA valueForKey:@"latitude"] isKindOfClass:[NSNull class]] && [[userB valueForKey:@"latitude"] isKindOfClass:[NSNull class]]){
                return NSOrderedSame;
            }else {
                CGFloat aLatitude = [[userA valueForKey:@"latitude"] floatValue];
                CGFloat aLongitude = [[userA valueForKey:@"longitude"] floatValue];
                
                CLLocation *participantALocation = [[CLLocation alloc] initWithLatitude:aLatitude longitude:aLongitude];
                
                CGFloat bLatitude = [[userB valueForKey:@"latitude"] floatValue];
                CGFloat bLongitude = [[userB valueForKey:@"longitude"] floatValue];
                CLLocation *participantBLocation = [[CLLocation alloc] initWithLatitude:bLatitude longitude:bLongitude];
                
                CLLocation *myLocation = [[CLLocation alloc] initWithLatitude:_currentLocationforMultiLocations.latitude longitude:_currentLocationforMultiLocations.longitude];
                
                CLLocationDistance distanceA = [participantALocation distanceFromLocation:myLocation];
                CLLocationDistance distanceB = [participantBLocation distanceFromLocation:myLocation];
                if (distanceA < distanceB) {
                    return NSOrderedAscending;
                } else if (distanceA > distanceB) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedSame;
                }
            }
            
            
            
        }];
        
        //update EntityData by Sorted Data
        for (int i = 0; i < orderedUsers.count; i ++) {
            [arrLocationsOfSubEntity addObject:orderedUsers[i]];
        }
        [((UITableView *)_tables[0]) reloadData];
    }
//    cell.lblDistance.text = [NSString stringWithFormat:@"%0.2f mi", ((int)((distanceA / 1609.344)*100))/100.f];
//    _currentLocationforMultiLocations = location.coordinate;
    
    [_locationManager stopUpdatingLocation];
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

- (IBAction)onSelfMainEntityObserveView:(id)sender {
    selfMainEntityObserveView.hidden = NO;
    CATransition *transition = [CATransition animation];
    transition.duration = 1.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionReveal;
    transition.delegate = self;
    [selfMainEntityProfileContainerView.layer addAnimation:transition forKey:nil];
    selfMainEntityProfileContainerView.hidden = NO;
}

- (IBAction)onSelfMainEntityObserveClose:(id)sender {
    CATransition *transition = [CATransition animation];
    transition.duration = 2.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    transition.delegate = self;
    [selfMainEntityProfileContainerView.layer addAnimation:transition forKey:nil];
    selfMainEntityObserveView.hidden = YES;
    selfMainEntityProfileContainerView.hidden = YES;
}
- (void)hideProfileImage{
    CATransition *transition = [CATransition animation];
    transition.duration = 2.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    transition.delegate = self;
    [selfMainEntityProfileContainerView.layer addAnimation:transition forKey:nil];
    selfMainEntityObserveView.hidden = YES;
    selfMainEntityProfileContainerView.hidden = YES;
}
@end
