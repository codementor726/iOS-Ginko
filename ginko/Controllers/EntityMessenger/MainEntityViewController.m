//
//  MainEntityViewController.m
//  ginko
//
//  Created by stepanekdavid on 4/19/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "MainEntityViewController.h"
#import <MessageUI/MessageUI.h>
#import <MediaPlayer/MediaPlayer.h>
#import <TTTAttributedLabel.h>
#import "LocalDBManager.h"
#import "UIImageView+AFNetworking.h"
#import "EntityPreviewDescriptionCell.h"
#import "SubEntityPreviewCell.h"
#import <MapKit/MapKit.h>
#import "EntityPreviewMapCell.h"
#import "EntityChatWallViewController.h"
#import "SearchAddNotesController.h"
#import "EntityInviteContactsViewController.h"
#import "YYYCommunication.h"
#import "MoreLocationCell.h"
#import "AllEntityViewController.h"

@interface MainEntityViewController () <MFMailComposeViewControllerDelegate, TTTAttributedLabelDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate,EntityViewControllerDelegate,AllEntityViewControllerDelegate,UIGestureRecognizerDelegate> {
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
    
    NSMutableArray *_tables;
    
    // width and height constraint for table
    NSLayoutConstraint *_tableWidth, *_tableHeight;
    
    NSMutableArray *arrLocationsOfSubEntity;
    
    NSArray *_allFieldNames;
    
    BOOL showMorebutton;
}
@end

@implementation MainEntityViewController
@synthesize appDelegate;
- (void)viewDidLoad {
    [super viewDidLoad];
    arrLocationsOfSubEntity = [NSMutableArray new];
//    _followButton.selected = _isFollowing;
//    _notesButton.hidden = !_isFollowing;
//    _btnEntityFavorite.hidden =!_isFollowing;
    _btnEntityFavorite.selected = _isFavorite;
    
    mainEntityObserveView.hidden = YES;
    
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    _getCurrentGPSCallTimer = [[NSTimer alloc] init];
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_locationManager requestWhenInUseAuthorization];
    }
    
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
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    if ([_entityData[@"privilege"] intValue] == 1)
        _inviteButton.hidden = NO;
    else if ([_entityData[@"privilege"] intValue] == 0)
        _inviteButton.hidden = YES;
    
    _profileImageView.layer.borderWidth = 1;
    _profileImageView.layer.borderColor = COLOR_PURPLE_THEME.CGColor;
    
    mainEntityProfileImageLarge.layer.borderWidth = 4.0f;
    mainEntityProfileImageLarge.layer.borderColor = COLOR_PURPLE_THEME.CGColor;
    mainEntityProfileContainerView.hidden = YES;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideProfileImage)];
    // tapGestureRecognizer.cancelsTouchesInView = NO;
    tapGestureRecognizer.delegate = self;
    [mainEntityObserveView addGestureRecognizer:tapGestureRecognizer];
    //UIBarButtonItem *wallButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"btn_wall"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(goWall:)];
    //self.navigationItem.rightBarButtonItem = wallButtonItem;
    
    // set content mode for image view
    _wallpaperImageView.contentMode = UIViewContentModeScaleAspectFill;
    //_profileImageView.contentMode = UIViewContentModeScaleAspectFill;
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
    
    
    [self reloadEntity];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_locationManager startUpdatingLocation];
    _getCurrentGPSCallTimer = [NSTimer scheduledTimerWithTimeInterval:(3.0) target:self selector:@selector(repeatLocationUpdating) userInfo:nil repeats:YES];
    
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
        _notesButton.hidden = !_isFollowing;
        _btnEntityFavorite.hidden =!_isFollowing;
    } failure:^(NSError *err) { }];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [navView removeFromSuperview];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [_locationManager stopUpdatingLocation];
    [_getCurrentGPSCallTimer invalidate];
    _getCurrentGPSCallTimer = nil;
    
    appDelegate.currentLocationforMultiLocations = _currentLocationforMultiLocations;
}
- (void)repeatLocationUpdating{
    [_locationManager startUpdatingLocation];
}

- (IBAction)onMainEntiyProfileObserveView:(id)sender {
    mainEntityObserveView.hidden = NO;
    CATransition *transition = [CATransition animation];
    transition.duration = 1.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionReveal;
    transition.delegate = self;
    [mainEntityProfileContainerView.layer addAnimation:transition forKey:nil];
    mainEntityProfileContainerView.hidden = NO;
}

- (IBAction)onMainEntityProfileObserveViewClose:(id)sender {
    CATransition *transition = [CATransition animation];
    transition.duration = 2.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    transition.delegate = self;
    [mainEntityProfileContainerView.layer addAnimation:transition forKey:nil];
    mainEntityObserveView.hidden = YES;
    mainEntityProfileContainerView.hidden = YES;
    
}
- (void)hideProfileImage{
    CATransition *transition = [CATransition animation];
    transition.duration = 2.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    transition.delegate = self;
    [mainEntityProfileContainerView.layer addAnimation:transition forKey:nil];
    mainEntityObserveView.hidden = YES;
    mainEntityProfileContainerView.hidden = YES;
}
- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setNotes:(NSString *)notes {
    NSMutableDictionary *tempDic = [_entityData mutableCopy];
    tempDic[@"notes"] = notes;
    _entityData = [tempDic copy];
}

- (void)viewDidLayoutSubviews {
    _tableWidth.constant = CGRectGetWidth(_entityScrollView.bounds);
    _tableHeight.constant = CGRectGetHeight(_entityScrollView.bounds);
}

- (void)reloadEntity {
    _lastIndexPath = nil;
    [arrLocationsOfSubEntity removeAllObjects];
    NSMutableArray * sortedMtArray = [NSMutableArray new];
    sortedMtArray = _entityData[@"infos"];
    if ([sortedMtArray count] > 2) {
        showMorebutton = YES;
    }else{
        showMorebutton = NO;
    }
//    for (NSArray *tmp in arrLocationsOfSubEntity){
//        CGFloat aLatitude = [[tmp valueForKey:@"latitude"] floatValue];
//        CGFloat aLongitude = [[tmp valueForKey:@"longitude"] floatValue];
//        CLLocation *participantALocation = [[CLLocation alloc] initWithLatitude:aLatitude longitude:aLongitude];
//        CLLocation *myLocation = [[CLLocation alloc] initWithLatitude:[AppDelegate sharedDelegate].currentLocation.latitude longitude:[AppDelegate sharedDelegate].currentLocation.longitude];
//        
//        CLLocationDistance distanceA = [participantALocation distanceFromLocation:myLocation];
//        NSLog(@"distance----%f",distanceA);
//    }
    //sort by gps location
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
            mainEntityProfileImageLarge.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:localFilePath]];
        } else {
            [_profileImageLoadingIndicator startAnimating];
            [_profileImageView cancelImageRequestOperation];
            [_profileImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:profileImageUrl]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                [_profileImageView setImage:image];
                [mainEntityProfileImageLarge setImage:image];
                [LocalDBManager saveImage:image forRemotePath:profileImageUrl];
                [_profileImageLoadingIndicator stopAnimating];
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to load wallpaper image." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                [_profileImageLoadingIndicator stopAnimating];
            }];
        }
    } else {
        _profileImageView.image = [UIImage imageNamed:@"entity-dummy"];
        mainEntityProfileImageLarge.image = [UIImage imageNamed:@"entity-dummy"];
    }
    
    // set privilege
    int privilege = [_entityData[@"privilege"] intValue];
    _privilegeImageView.image = [UIImage imageNamed:(privilege == 1) ? @"personal_profile_preview_unlocked" : @"personal_profile_preview_locked"];
    _privilegeImageView.hidden = YES;
    
    
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
}
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
    controller.isMain = YES;
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
        _isFavorite = YES;
    }else{
        [appDelegate removeFavoriteContact:[_entityData objectForKey:@"entity_id"] contactType:@"3"];
        _isFavorite = NO;
    }
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
    
    cell.moreItems.text = [NSString stringWithFormat:@"%lu+",_locationsTotal - 2];
    
    return cell;

}

#pragma mark - UITableViewCellDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0)
        [self.view endEditing:NO];
    else if (indexPath.section == 1) {
        EntityViewController *vc = [[EntityViewController alloc] initWithNibName:@"EntityViewController" bundle:nil];
        vc.entityData = _entityData;
        vc.infoId = (int)[[[arrLocationsOfSubEntity objectAtIndex:indexPath.row] valueForKey:@"info_id"] integerValue] ;
        vc.isFollowing = _isFollowing;
        vc.isFavorite = _isFavorite;
        vc.isMultiLocations = true;
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.section ==2){
        AllEntityViewController *vc = [[AllEntityViewController alloc] initWithNibName:@"AllEntityViewController" bundle:nil];
        vc.isCreate = NO;
        vc.entityData = _entityData;
        vc.isFollowing = _isFollowing;
        vc.isFavorite = _isFavorite;
        vc.delegate = self;
        vc.locationsTotal = _locationsTotal;
        [self.navigationController pushViewController:vc animated:YES];
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
        [MBProgressHUD hideHUDForView:appDelegate.window animated:YES];
        NSDictionary *result = _responseObject;
        if ([[result objectForKey:@"success"] boolValue]) {
            _isFollowing = YES;
            _followButton.selected = _isFollowing;
            _notesButton.hidden = !_isFollowing;
            
            _btnEntityFavorite.hidden =!_isFollowing;
            _btnEntityFavorite.selected = _isFavorite;
            //[CommonMethods loadFetchAllEntity];
            //[[NSNotificationCenter defaultCenter] postNotificationName:CONTACT_SYNC_NOTIFICATION object:nil];
        } else {
            [MBProgressHUD hideHUDForView:appDelegate.window animated:YES];
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
    
    [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
    
    [[YYYCommunication sharedManager] FollowEntity:[AppDelegate sharedDelegate].sessionId entityid:_entityData[@"entity_id"] successed:successed failure:failure];
}

-(void)unFollowEntity
{
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        NSDictionary *result = _responseObject;
        if ([[result objectForKey:@"success"] boolValue]) {
            _isFollowing = NO;
            _followButton.selected = _isFollowing;
            _notesButton.hidden = !_isFollowing;
            _btnEntityFavorite.hidden =!_isFollowing;
            _btnEntityFavorite.selected = NO;
            _isFavorite = NO;
            [self setNotes:@""];
            [MBProgressHUD hideHUDForView:appDelegate.window animated:YES];
            //[CommonMethods loadFetchAllEntity];
            //[[NSNotificationCenter defaultCenter] postNotificationName:CONTACT_SYNC_NOTIFICATION object:nil];
        } else {
            [MBProgressHUD hideHUDForView:appDelegate.window animated:YES];
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
    
    [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
    
    [[YYYCommunication sharedManager] UnFollowEntity:[AppDelegate sharedDelegate].sessionId entityid:_entityData[@"entity_id"] successed:successed failure:failure];
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        if (alertView.tag == 1) {
            [self followEntity];
        } else if (alertView.tag == 2) {
            [self unFollowEntity];
        } else if (alertView.tag == 1001){
            [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
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
        if ([sortedMtArray count] > 2) {
            showMorebutton = YES;
        }else{
            showMorebutton = NO;
        }
        //    for (NSArray *tmp in arrLocationsOfSubEntity){
        //        CGFloat aLatitude = [[tmp valueForKey:@"latitude"] floatValue];
        //        CGFloat aLongitude = [[tmp valueForKey:@"longitude"] floatValue];
        //        CLLocation *participantALocation = [[CLLocation alloc] initWithLatitude:aLatitude longitude:aLongitude];
        //        CLLocation *myLocation = [[CLLocation alloc] initWithLatitude:[AppDelegate sharedDelegate].currentLocation.latitude longitude:[AppDelegate sharedDelegate].currentLocation.longitude];
        //
        //        CLLocationDistance distanceA = [participantALocation distanceFromLocation:myLocation];
        //        NSLog(@"distance----%f",distanceA);
        //    }
        //sort by gps location
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
    
    [_locationManager stopUpdatingLocation];
}
#pragma mark - EntityViewControllerDelegate
- (void)returnIsFollowing:(BOOL)isFollowing{
    _isFollowing = isFollowing;
    _followButton.selected = _isFollowing;
    _notesButton.hidden = !_isFollowing;
    _btnEntityFavorite.hidden =!_isFollowing;
}
- (void)returnIsFavorite:(BOOL)isFavorite{
    _isFavorite = isFavorite;
    _btnEntityFavorite.selected = _isFavorite;
}
#pragma mark - AllEntityViewControllerDelegate
- (void)returnAllEntityIsFollowing:(BOOL)isFollowing isFavorite:(BOOL)isFavorite{
    _isFollowing = isFollowing;
    _isFavorite = isFavorite;
    _followButton.selected = _isFollowing;
    _notesButton.hidden = !_isFollowing;
    _btnEntityFavorite.hidden =!_isFollowing;
    _btnEntityFavorite.selected = _isFavorite;
}
@end
