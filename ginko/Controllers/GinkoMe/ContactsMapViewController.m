//
//  ContactsMapViewController.m
//  ginko
//
//  Created by ccom on 1/8/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "ContactsMapViewController.h"
//#import "ContactAnnotation.h"
#import <objc/runtime.h>
#import "ProfileViewController.h"
#import "ProfileRequestController.h"
#import "YYYCommunication.h"
#import "YYYChatViewController.h"
#import "EntityViewController.h"
#import "QCluster.h"
#import "PreviewProfileViewController.h"
#import "QNode.h"
#import "MainEntityViewController.h"
#import "UIButton+AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "LocationOfEntityAnnotoation.h"
#import "LocalDBManager.h"
#import "ContactsAnnotation.h"
#import "VideoVoiceConferenceViewController.h"

#import "MKMapView+ZoomLevel.h"
@interface ContactsMapViewController ()

@end
static NSString * const ExchangedInfoCellIdentifier = @"ExchangedInfoCell";
static NSString * const NotExchangedInfoCellIdentifier = @"NotExchangedInfoCell";
static NSString * const EntityCellIdentifier = @"EntityCell";

@implementation ContactsMapViewController {
    NSArray *contacts;
    NSArray *greys;
    NSArray *entities;
    NSArray *selectedContacts;
    NSArray *groupedAnns;
//    NSArray* purpleAnns;
//    NSArray* greyAnns;
//    NSArray* entityAnns;
    GinkoMeTabController *tabController;
    UIButton *prevButton;
    id prevAnnotation;
    BOOL userLocationShown;
    UIButton* tmpbut;
    
    BOOL isSelectedMultiLocation;
    NSInteger zoomLevel;
    
    id<MKAnnotation> currentAnn;
    
    NSString *selectedContactId;
    BOOL isExisted;
    
    NSArray *currentReginAreaForMap;
    
    NSInteger oldZoomLevel;
    BOOL isMovingMap;
    BOOL isZoomIn;
    
    float currentStateValue;
    
    NSMutableArray *selectedMultiLocations;
    
    int countOfLocations;
    
    UIActionSheet *disWithConferenceCallingActionSheet;
}
@synthesize tableView;
@synthesize qTree;
//@synthesize purpleTree;
//@synthesize greyTree;
//@synthesize entityTree;

- (void)viewDidLoad {
    [super viewDidLoad];
    [tableView registerNib:[UINib nibWithNibName:ExchangedInfoCellIdentifier bundle:nil] forCellReuseIdentifier:ExchangedInfoCellIdentifier];
    [tableView registerNib:[UINib nibWithNibName:NotExchangedInfoCellIdentifier bundle:nil] forCellReuseIdentifier:NotExchangedInfoCellIdentifier];
    [tableView registerNib:[UINib nibWithNibName:EntityCellIdentifier bundle:nil] forCellReuseIdentifier:EntityCellIdentifier];
    isSelectedMultiLocation = NO;
    currentAnn = nil;
    
    isMovingMap = NO;
    isZoomIn = NO;
    
    selectedMultiLocations = [[NSMutableArray alloc] init];
    countOfLocations = 0;
    selectedContactId = @"";
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    //[self reloadMap];
    
    //[self showlocationOfEntity];
    [self showContacts];
//    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(APPDELEGATE.latitude, APPDELEGATE.longitude), 100000, 100000);
//    [self.mapView setRegion:region animated:NO];
    
    // back button will not have title
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.mapView setShowsUserLocation:YES];
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    
    tabController = (GinkoMeTabController*)self.tabBarController;
    tabController.cDelegate = self;
    
    isExisted = NO;
    for (SearchedContact *contact in tabController.contacts) {
        if ([[NSString stringWithFormat:@"%@",contact.contact_id] isEqualToString:selectedContactId]) {
            isExisted = YES;
        }
    }
    for (SearchedContact *contact in tabController.greys) {
        if ([[NSString stringWithFormat:@"%@",contact.contact_id] isEqualToString:selectedContactId]) {
            isExisted = YES;
        }
    }
    if (!isExisted) {
        currentAnn = nil;
        selectedContacts = nil;
    }
    
    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadEntitiesForMap) name:CONTACT_SYNC_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeCurrentActionWhenConferenceView) name:CLOSE_ALERT_WHEN_CONFERENCEVIEW_NOTIFICATION object:nil];
}
- (void)viewWillDisAppear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.mapView setShowsUserLocation:NO];
    [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:NO];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CONTACT_SYNC_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CLOSE_ALERT_WHEN_CONFERENCEVIEW_NOTIFICATION object:nil];
    //[self showlocationOfEntity];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
#pragma mark -
#pragma mark - Function

//- (void)reloadMap {
//    qTree = [QTree new];
//    //NSLog(@"contacts----%@",tabController.contacts);
//    //NSLog(@"greys-----%@", tabController.greys);
//    for (SearchedContact *contact in tabController.contacts) {
//        ContactAnnotation *annotation = [[ContactAnnotation alloc] init];
//        annotation.coordinate = CLLocationCoordinate2DMake([contact.latitude doubleValue], [contact.longitude doubleValue]);
//        annotation.type = 0;//purple
//        annotation.contacts = @[contact];
//        annotation.contactId = contact.contact_id;
//        [qTree insertObject:annotation];
//    }
//    for (SearchedContact *contact in tabController.greys) {
//        ContactAnnotation *annotation = [[ContactAnnotation alloc] init];
//        annotation.coordinate = CLLocationCoordinate2DMake([contact.latitude doubleValue], [contact.longitude doubleValue]);
//        annotation.contacts = @[contact];
//        annotation.contactId = contact.contact_id;
//        if ([contact.contact_type isEqualToNumber:@(3)]) {
//            annotation.type = 2;//unfollowed entity
//            annotation.profileImg = contact.profile_image;
//            [qTree insertObject:annotation];
//        }
//        else {
//            annotation.type = 1;//grey
//            [qTree insertObject:annotation];
//        }
//    }
//    
//    [self reloadAnnotations];
//}

//-(void)reloadAnnotations
//{
//    if( !self.isViewLoaded ) {
//        return;
//    }
//
//    const MKCoordinateRegion mapRegion = self.mapView.region;
//    const CLLocationDegrees minNonClusteredSpan = MIN(mapRegion.span.latitudeDelta, mapRegion.span.longitudeDelta) / 5;
//    
//    groupedAnns = [qTree getObjectsInRegion:mapRegion minNonClusteredSpan:minNonClusteredSpan];
//    NSArray * oldArrayAnn = self.mapView.annotations;
//    NSMutableArray * oldAnnotation = [[NSMutableArray alloc] init];
//    for (id<MKAnnotation> oldAnn in oldArrayAnn) {
//        if (![oldAnn isKindOfClass:[LocationOfEntityAnnotoation class]]) {
//            [oldAnnotation addObject:oldAnn];
//        }
//    }
//    [self removeAndAddAnnotations:groupedAnns oldAnnotations:[NSArray arrayWithArray:oldAnnotation]];
//    if(tmpbut){
//        id<MKAnnotation> annotation = objc_getAssociatedObject(tmpbut, @"Annotation");
//        if (![self.mapView.annotations containsObject:annotation]) {
//            selectedContacts = [NSArray array];
//        }
//        else {
//            if ([annotation isKindOfClass:[LocationOfEntityAnnotoation class]]) {
//                selectedContacts = ((LocationOfEntityAnnotoation*)annotation).locations;
//            }else if ([annotation isKindOfClass:[ContactAnnotation class]]) {
//                selectedContacts = ((ContactAnnotation*)annotation).contacts;
//            }
//            else {
//                NSMutableArray *anncontacts = [NSMutableArray array];
//                NSArray *anns = ((QCluster*)annotation).objects;
//                for (ContactAnnotation *ann in anns) {
//                    [anncontacts addObjectsFromArray:ann.contacts];
//                }
//                selectedContacts = anncontacts;
//            }
//        }
//        [self.tableView reloadData];
//    }
//}
- (void) reloadEntitiesForMap{
    [CommonMethods loadAvaiableEntityNew];//sycn entity
    if (zoomLevel > 9) {
        [self reloadEntities];
    }else{
        [self removeAllEntities];
    }
}
- (void) reloadEntities{
    if( !self.isViewLoaded ) {
        return;
    }
    NSArray * oldArrayAnn = self.mapView.annotations;
    NSMutableArray * oldAnnotation = [[NSMutableArray alloc] init];
    for (id<MKAnnotation> oldAnn in oldArrayAnn) {
        if ([oldAnn isKindOfClass:[LocationOfEntityAnnotoation class]]) {
            [oldAnnotation addObject:oldAnn];
        }
    }
    
    [self showlocationOfEntity];
    
    [self.mapView removeAnnotations:oldAnnotation];
    [self.tableView reloadData];
    
}
- (void) removeAllEntities{
    if( !self.isViewLoaded ) {
        return;
    }
    NSArray * oldArrayAnn = self.mapView.annotations;
    NSMutableArray * oldAnnotation = [[NSMutableArray alloc] init];
    for (id<MKAnnotation> oldAnn in oldArrayAnn) {
        if ([oldAnn isKindOfClass:[LocationOfEntityAnnotoation class]]) {
            [oldAnnotation addObject:oldAnn];
        }
    }
    
    [self.mapView removeAnnotations:oldAnnotation];
    [self.tableView reloadData];
}
- (void)showlocationOfEntity{
    NSManagedObjectContext *context = [AppDelegate sharedDelegate].managedObjectContext;
    
    NSFetchRequest *allContacts = [[NSFetchRequest alloc] init];
    [allContacts setEntity:[NSEntityDescription entityForName:@"LocationOfEntity" inManagedObjectContext:context]];
    NSError *error;
    NSArray *entitieResult = [context executeFetchRequest:allContacts error:&error];
    NSArray *foundContacts = [entitieResult filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"entity_Id != 0 AND latitude > %@ AND latitude < %@ AND longitude > %@ AND longitude < %@",[NSNumber numberWithFloat:[[currentReginAreaForMap objectAtIndex:0] floatValue]] ,[NSNumber numberWithFloat:[[currentReginAreaForMap objectAtIndex:2] floatValue]] ,[NSNumber numberWithFloat:[[currentReginAreaForMap objectAtIndex:1] floatValue]] ,[NSNumber numberWithFloat:[[currentReginAreaForMap objectAtIndex:3] floatValue]]]];
    
//    NSLog(@"%f", [[[self getBoundingBox:mRect] objectAtIndex:2] doubleValue] - [[[self getBoundingBox:mRect] objectAtIndex:0] doubleValue]);
    if (foundContacts.count > 0) {
        for (LocationOfEntity *location in foundContacts) {
            LocationOfEntityAnnotoation *annotation = [[LocationOfEntityAnnotoation alloc] initWithLatitude:[location.latitude doubleValue] andLongitude:[location.longitude doubleValue]];
            //annotation.coordinate = CLLocationCoordinate2DMake([location.latitude doubleValue], [location.longitude doubleValue]);
            [annotation setProfile:location.profile_image entityID:location.entity_Id];
            annotation.locations = @[location];
            
            if (zoomLevel > 8) {
                [self.mapView addAnnotation:annotation];
            }
//            }
            
        }
    }
}
- (void) reloadContacts{
    if( !self.isViewLoaded ) {
        return;
    }
    NSArray * oldArrayAnn = self.mapView.annotations;
    NSMutableArray * oldAnnotation = [[NSMutableArray alloc] init];
    for (id<MKAnnotation> oldAnn in oldArrayAnn) {
        if ([oldAnn isKindOfClass:[ContactsAnnotation class]]) {
            [oldAnnotation addObject:oldAnn];
        }
    }
    
    [self showContacts];
    
    [self.mapView removeAnnotations:oldAnnotation];
    
    [oldAnnotation removeAllObjects];
    
    oldArrayAnn = nil;
    oldArrayAnn = self.mapView.annotations;
    NSMutableArray * oldAnnContactID = [[NSMutableArray alloc] init];
    for (id<MKAnnotation> oldAnn in oldArrayAnn) {
        if ([oldAnn isKindOfClass:[ContactsAnnotation class]]) {
            [oldAnnContactID addObject:((ContactsAnnotation*)oldAnn).contactId];
        }
    }
    if (currentAnn) {
        isSelectedMultiLocation = NO;
        if([currentAnn isKindOfClass:[LocationOfEntityAnnotoation class]]){
            NSMutableArray *selectedEntities = [NSMutableArray array];
            NSManagedObjectContext *context = [AppDelegate sharedDelegate].managedObjectContext;
            
            NSFetchRequest *allContacts = [[NSFetchRequest alloc] init];
            [allContacts setEntity:[NSEntityDescription entityForName:@"LocationOfEntity" inManagedObjectContext:context]];
            NSError *error;
            NSArray *entitieResult = [context executeFetchRequest:allContacts error:&error];
            NSArray *foundContacts = [entitieResult filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"((latitude == %@) AND (longitude == %@))",@(((LocationOfEntityAnnotoation*)currentAnn).coordinate.latitude),@(((LocationOfEntityAnnotoation*)currentAnn).coordinate.longitude)]];
            if (foundContacts.count > 0) {
                for (LocationOfEntity *location in foundContacts) {
                    [selectedEntities addObjectsFromArray:@[location]];
                }
            }
            
            selectedContacts = selectedEntities;
            
                isSelectedMultiLocation = YES;
                [self.tableView reloadData];
        }else if([currentAnn isKindOfClass:[ContactsAnnotation class]]){
            if ([oldAnnContactID containsObject:((ContactsAnnotation*)currentAnn).contactId]) {
                selectedContacts = ((ContactsAnnotation*)currentAnn).contacts;
                [self.tableView reloadData];
            }else{
                currentAnn = nil;
                selectedContacts = nil;
                [self.tableView reloadData];
            }
        }
    }else {
        currentAnn = nil;
        selectedContacts = nil;
        [self.tableView reloadData];
    }
    
    
    
}
-(void)showContacts{
    for (SearchedContact *contact in tabController.contacts) {
        ContactsAnnotation *annotation = [[ContactsAnnotation alloc] initWithLatitude:[contact.latitude doubleValue] andLongitude:[contact.longitude doubleValue]];
        annotation.type = 0;//purple
        annotation.contacts = @[contact];
        annotation.contactId = contact.contact_id;
        annotation.profileImg = contact.profile_image;
        [self.mapView addAnnotation:annotation];
    }
    for (SearchedContact *contact in tabController.greys) {
        ContactsAnnotation *annotation = [[ContactsAnnotation alloc] initWithLatitude:[contact.latitude doubleValue] andLongitude:[contact.longitude doubleValue]];
        annotation.contacts = @[contact];
        annotation.contactId = contact.contact_id;
        //[self.mapView addAnnotation:annotation];
        if ([contact.contact_type isEqualToNumber:@(3)]) {
            annotation.type = 2;//unfollowed entity
            annotation.profileImg = contact.profile_image;
            [self.mapView addAnnotation:annotation];
        }
        else {
            annotation.type = 1;//grey
            [self.mapView addAnnotation:annotation];
        }
    }
}

- (void)removeAndAddAnnotations:(NSArray*)anns oldAnnotations:(NSArray*)oldAnns {
    NSMutableArray* annotationsToRemove = [oldAnns mutableCopy];
    [self removeAnnotionsInAray:anns from:annotationsToRemove];
    [self.mapView removeAnnotations:annotationsToRemove];
    
    NSMutableArray* annotationsToAdd = [anns mutableCopy];
    [self removeAnnotionsInAray:oldAnns from:annotationsToAdd];
    [self.mapView addAnnotations:annotationsToAdd];
    //[self showlocationOfEntity];
}

- (void)removeAnnotionsInAray:(NSArray*)anns from:(NSMutableArray*)orgAnns {
    NSMutableArray *toRemoves = [NSMutableArray array];
    for (ContactsAnnotation *cann in orgAnns) {
        for (ContactsAnnotation *rann in anns) {
            if ([self compareAnnotation:cann withB:rann]) {
                [toRemoves addObject:cann];
                break;
            }
        }
    }
    [orgAnns removeObjectsInArray:toRemoves];
}

- (BOOL)compareAnnotation:(ContactsAnnotation*)a withB:(ContactsAnnotation*)b {
    if ([a isKindOfClass:[ContactsAnnotation class]] && [b isKindOfClass:[ContactsAnnotation class]]) {
        //will remove different types
        return [a.contactId isEqualToNumber:b.contactId] && (a.type == b.type);
    }
    return NO;
}
//
//- (NSSet*)setOfContactIdsOfQCluster:(QCluster*)c {
//    NSMutableSet *set = [NSMutableSet set];
//    for (ContactAnnotation *cont in c.objects) {
//        [set addObject:cont.contactId];
//    }
//    return set;
//}

//- (UIColor*)annotationColorOfAnnotation:(ContactAnnotation*)ann {
//    NSInteger annType = ann.type;
//    UIColor *buttonColor = (annType) ? [UIColor darkGrayColor] : COLOR_PURPLE_THEME;
//    buttonColor = (annType == 2) ? COLOR_GREEN_THEME : buttonColor;
//    return buttonColor;
//}
- (UIColor*)annotationColorOfContactAnnotation:(ContactsAnnotation*)ann {
    NSInteger annType = ann.type;
    UIColor *buttonColor = (annType) ? [UIColor darkGrayColor] : COLOR_PURPLE_THEME;
    buttonColor = (annType == 2) ? COLOR_GREEN_THEME : buttonColor;
    return buttonColor;
}
- (NSString *)annotationProfileImageOfAnnotation:(LocationOfEntityAnnotoation *)ann{
    NSString *buttonImg = @"";
    buttonImg = ann.profileImg;
    
    return buttonImg;
}
#pragma mark -
- (void)getContactDetail : (NSString *)_contactId {
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    [[Communication sharedManager] getContactDetail:[AppDelegate sharedDelegate].sessionId contactId:_contactId contactType:@"1" successed:^(id _responseObject) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            NSDictionary *dict = [_responseObject objectForKey:@"data"];

            PreviewProfileViewController *vc = [[PreviewProfileViewController alloc] initWithNibName:@"PreviewProfileViewController" bundle:nil];
            vc.userData = dict;
            
            BOOL isWork;
            if ([dict[@"work"][@"fields"] count] > 0) {
                isWork = YES;
            } else {    // really new and show profile selection screen
                isWork = NO;
            }
            vc.isWork = isWork;
            vc.isViewOnly = YES;
            vc.isChat = NO;
            
            [self.navigationController pushViewController:vc animated:YES];
        }else {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSDictionary *dictError = [_responseObject objectForKey:@"err"];
            if (dictError) {
                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:[dictError objectForKey:@"errMsg"]];
                if ([[NSString stringWithFormat:@"%@",[dictError objectForKey:@"errCode"]] isEqualToString:@"350"]) {
                    [[AppDelegate sharedDelegate] GetContactList];
                }
            } else {
                [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Failed to connect to server!"];
            }
        }
    } failure:^(NSError *err) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
    }];
}

-(void)CreateMessageBoard:(NSString*)ids dict:(NSDictionary *)contactInfo {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            NSMutableArray *lstTemp = [[NSMutableArray alloc] init];
            NSMutableDictionary *dictTemp = [[NSMutableDictionary alloc] init];
            
            [dictTemp setObject:[contactInfo objectForKey:@"first_name"] forKey:@"fname"];
            [dictTemp setObject:[contactInfo objectForKey:@"last_name"] forKey:@"lname"];
            [dictTemp setObject:[contactInfo objectForKey:@"profile_image"] forKey:@"photo_url"];
            [dictTemp setObject:[contactInfo objectForKey:@"contact_id"] forKey:@"user_id"];
            
            [lstTemp addObject:dictTemp];
            
            NSMutableDictionary *dictTemp1 = [[NSMutableDictionary alloc] init];
            
            [dictTemp1 setObject:[AppDelegate sharedDelegate].firstName forKey:@"fname"];
            [dictTemp1 setObject:[AppDelegate sharedDelegate].lastName forKey:@"lname"];
            [dictTemp1 setObject:[AppDelegate sharedDelegate].photoUrl forKey:@"photo_url"];
            [dictTemp1 setObject:[AppDelegate sharedDelegate].userId forKey:@"user_id"];
            
            [lstTemp addObject:dictTemp1];
            
            YYYChatViewController *viewcontroller = [[YYYChatViewController alloc] initWithNibName:@"YYYChatViewController" bundle:nil];
            viewcontroller.boardid = [[_responseObject objectForKey:@"data"] objectForKey:@"board_id"];
            viewcontroller.lstUsers = [[NSMutableArray alloc] initWithArray:lstTemp];;
            [self.navigationController pushViewController:viewcontroller animated:YES];
            
        }else{
            [CommonMethods showAlertUsingTitle:@"Error!" andMessage:[[_responseObject objectForKey:@"err"] objectForKey:@"errMsg"]];
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Internet Connection Error!"];
        
    } ;
    
    [[YYYCommunication sharedManager] CreateChatBoard:[AppDelegate sharedDelegate].sessionId userids:ids successed:successed failure:failure];
}

-(void)getEntityFollowerView:(NSString *)entityID following:(BOOL)isFollowing notes:(NSString *)notes
{
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        NSDictionary *result = _responseObject;
        if ([[result objectForKey:@"success"] boolValue]) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];

            if ([_responseObject[@"data"][@"infos"] count] > 1){
                MainEntityViewController *vc = [[MainEntityViewController alloc] initWithNibName:@"MainEntityViewController" bundle:nil];
                vc.entityData = _responseObject[@"data"];
                vc.isFollowing = isFollowing;
                vc.isFavorite = [[_responseObject[@"data"] objectForKey:@"is_favorite"] boolValue];
                vc.locationsTotal = [[_responseObject[@"data"] objectForKey:@"info_total"] integerValue];
                [self.navigationController pushViewController:vc animated:YES];
            }else if ([_responseObject[@"data"][@"infos"] count] == 1){
                EntityViewController *vc = [[EntityViewController alloc] initWithNibName:@"EntityViewController" bundle:nil];
                vc.entityData = _responseObject[@"data"];
                vc.isFollowing = isFollowing;
                vc.isFavorite = [[_responseObject[@"data"] objectForKey:@"is_favorite"] boolValue];
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"GINKO" message:@"Oops! Current Entity hasn't informations!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                
                [alertView show];
            }
        } else {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSDictionary *dictError = [result objectForKey:@"err"];
            if (dictError) {
                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:[dictError objectForKey:@"errMsg"]];
                if ([[NSString stringWithFormat:@"%@",[dictError objectForKey:@"errCode"]] isEqualToString:@"700"]) {
                    [CommonMethods loadFetchAllEntityNew];
                    [[NSNotificationCenter defaultCenter] postNotificationName:CONTACT_SYNC_NOTIFICATION object:nil];
                }
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
    
    //[[YYYCommunication sharedManager] GetEntityByFollowr:[AppDelegate sharedDelegate].sessionId entityid:entityID successed:successed failure:failure];
    [[YYYCommunication sharedManager] GetEntityByFollowrNew:[AppDelegate sharedDelegate].sessionId entityid:entityID infoFrom:@"0" infoCount:@"20" latitude:[AppDelegate sharedDelegate].currentLocationforMultiLocations.latitude longitude:[AppDelegate sharedDelegate].currentLocationforMultiLocations.longitude successed:successed failure:failure];
}

#pragma mark -
#pragma mark - Action

- (void)annotationTouched:(UIButton*)but {
    tmpbut = but;
    id<MKAnnotation> annotation = objc_getAssociatedObject(but, @"Annotation");
    if ([annotation isEqual:prevAnnotation]) {
        return;
    }
    prevAnnotation = annotation;
//    if ([prevButton isEqual:but]) {
//        return;
//    }
    UIColor *color = but.backgroundColor;
    but.backgroundColor = [color colorWithAlphaComponent:0.5];
    if (![prevButton isEqual:but]) {
        color = prevButton.backgroundColor;
        prevButton.backgroundColor = [color colorWithAlphaComponent:1];
        prevButton = but;
    }
    isSelectedMultiLocation = NO;
   if ([annotation isKindOfClass:[LocationOfEntityAnnotoation class]]) {
        selectedContacts = ((LocationOfEntityAnnotoation*)annotation).locations;
       isSelectedMultiLocation = YES;
    }else if ([annotation isKindOfClass:[ContactsAnnotation class]]) {
        selectedContacts = ((ContactsAnnotation*)annotation).contacts;
    }
//    else {
//        NSMutableArray *anncontacts = [NSMutableArray array];
//        NSArray *anns = ((QCluster*)annotation).objects;
//        for (ContactAnnotation *ann in anns) {
//            [anncontacts addObjectsFromArray:ann.contacts];
//        }
//        selectedContacts = anncontacts;
//    }
    [self.tableView reloadData];
}

- (IBAction)onMapTapped:(id)sender {
    //[self annotationTouched:nil];
    
    selectedContacts = nil;
    currentAnn = nil;
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark - MKMapView

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    if ([annotation isKindOfClass:[LocationOfEntityAnnotoation class]]) {
        
        MKAnnotationView *pinView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomAnnotation"];
        if (pinView == nil) {
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomAnnotation"];
            
        }
        if (zoomLevel > 8  && isZoomIn && isMovingMap) {
            NSString * profileImage=@"";
            profileImage = [self annotationProfileImageOfAnnotation:(LocationOfEntityAnnotoation *) annotation];
            NSString *localFilePath = [LocalDBManager checkCachedFileExist:profileImage];
            if (localFilePath) {
                pinView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:localFilePath]];
            } else {
                UIImageView * _tempProfileImageView;
                _tempProfileImageView = [UIImageView new];
                [_tempProfileImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:profileImage]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                    [LocalDBManager saveImage:image forRemotePath:profileImage];
                    pinView.image = image;
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                    NSLog(@"Failed to load profile image.");
                }];
            }
        }else{
            pinView.image = nil;
        }
        
        if (zoomLevel > 10) {
            pinView.frame = CGRectMake(0, 0, 35, 35);
        }else
            pinView.frame = CGRectMake(0, 0, 10+ zoomLevel * 2, 10 + zoomLevel * 2);
        pinView.backgroundColor = COLOR_GREEN_THEME;
        [pinView setIsRound:YES];
        [pinView setBorderColor:[UIColor whiteColor]];
        [pinView setBorderWidth:1];
        return pinView;

    }
    if ([annotation isKindOfClass:[ContactsAnnotation class]]) {
        
        
        
        MKAnnotationView *pinView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"ContactsAnnotation"];
        if (pinView == nil) {
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"ContactsAnnotation"];
            
        }
        
        if ([selectedContactId isEqualToString:[NSString stringWithFormat:@"%@",((ContactsAnnotation *) annotation).contactId]]) {
            [[pinView superview] bringSubviewToFront:pinView];
        }else{
            [[pinView superview] sendSubviewToBack:pinView];
        }
        
        if (zoomLevel > 8) {
            NSString * profileImage=@"";
            profileImage = ((ContactsAnnotation *) annotation).profileImg;
            if (profileImage && ![profileImage isEqualToString:@""]) {
                NSString *localFilePath = [LocalDBManager checkCachedFileExist:profileImage];
                if (localFilePath) {
                    //[pinView setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:localFilePath]]];
                    UIView *curView = [[UIImageView alloc] initWithFrame:pinView.frame];
                    UIImage *curImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:localFilePath]];
                    curView.backgroundColor = [UIColor colorWithPatternImage:[self imageWithImage:curImage scaledToSize:pinView.frame.size]];
                    UIImage *pinImage = [self imageFromUIView:curView];
                    pinView.image = pinImage;
                    
                    //                NSError *error;
                    //                pinView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:localFilePath options:NSDataReadingMappedIfSafe error:&error]];
                    //[pinView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:profileImage]]]];
                } else {
                    UIImageView * _tempProfileImageView;
                    _tempProfileImageView = [UIImageView new];
                    [_tempProfileImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:profileImage]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                        [LocalDBManager saveImage:image forRemotePath:profileImage];
                        UIView *curView = [[UIImageView alloc] initWithFrame:pinView.frame];
                        curView.backgroundColor = [UIColor colorWithPatternImage:[self imageWithImage:image scaledToSize:pinView.frame.size]];
                        UIImage *pinImage = [self imageFromUIView:curView];
                        pinView.image = pinImage;
                        
                        //pinView.image = image;
                    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                        NSLog(@"Failed to load profile image.");
                    }];
                }
            }else{
                pinView.image = nil;
            }
            
        }else{
            pinView.image = nil;
        }
        
        
        
        if (zoomLevel > 10) {
            pinView.frame = CGRectMake(0, 0, 35, 35);
        }else
            pinView.frame = CGRectMake(0, 0, 10+ zoomLevel * 2, 10 + zoomLevel * 2);
        
        [pinView setBackgroundColor:[self annotationColorOfContactAnnotation:(ContactsAnnotation*)annotation]];
        [pinView setIsRound:YES];
        [pinView setBorderColor:[UIColor whiteColor]];
        [pinView setBorderWidth:1];
        return pinView;
        
//            NSString *AnnotationIdentifier = @"ContactsAnnotation";
//            UIColor *buttonColor;
//        
//        
//            if ([annotation isKindOfClass:[ContactsAnnotation class]]) {
//                buttonColor = [self annotationColorOfContactAnnotation:(ContactsAnnotation*)annotation];
//            }
//        
//            UIButton *button;
//            MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
//            if(!annotationView) {
//                annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];
//                annotationView.frame = CGRectMake(0, 0, 10, 10);
//                button = [[UIButton alloc] init];
//                [annotationView addSubview:button];
//                [button addTarget:self action:@selector(annotationTouched:) forControlEvents:UIControlEventTouchUpInside];
//                button.tag = 333;
//        
//                annotationView.backgroundColor = [UIColor whiteColor];
//            }
//        
//        
//        if (zoomLevel > 10) {
//            annotationView.frame = CGRectMake(0, 0, 35, 35);
//            button.frame =  CGRectMake(0, 0, 35, 35);
//        }else{
//            annotationView.frame = CGRectMake(0, 0, 10+ zoomLevel * 2, 10 + zoomLevel * 2);
//            button.frame = CGRectMake(0, 0, 10+ zoomLevel * 2, 10 + zoomLevel * 2);
//        }
//        button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        button = [annotationView viewWithTag:333];
//        objc_setAssociatedObject(button, @"Annotation", annotation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//        [button setImage:nil forState:UIControlStateNormal];
//        [button setBackgroundColor:buttonColor];
//        [button setIsRound:YES];
//        [button setBorderColor:[UIColor whiteColor]];
//        [button setBorderWidth:1];
//        [annotationView setIsRound:YES];
//        return annotationView;
        
    }
//    NSString *AnnotationIdentifier = @"AnnotationIdentifier";
//    NSString *count = @"";
//    UIColor *buttonColor;
//    
//    
//    if ([annotation isKindOfClass:[ContactAnnotation class]]) {
//        buttonColor = [self annotationColorOfAnnotation:(ContactAnnotation*)annoupdatedtation];
//    }
//    else {
//        NSArray *anns = ((QCluster*)annotation).objects;
//        NSInteger n = anns.count;
//        anns = [anns sortedArrayUsingComparator:^(ContactAnnotation *obj1,ContactAnnotation *obj2) {
//            return (NSComparisonResult) [@(obj1.type) compare:@(obj2.type)];
//        }];
//        buttonColor = [self annotationColorOfAnnotation:[anns firstObject]];
//        count = [@(n) stringValue];
//    }
//    UIButton *button;
//    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
//    if(!annotationView) {
//        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];
//        annotationView.frame = CGRectMake(0, 0, 40, 40);
//        button = [[UIButton alloc] initWithFrame:annotationView.bounds];
//        [annotationView addSubview:button];
//        [button addTarget:self action:@selector(annotationTouched:) forControlEvents:UIControlEventTouchUpInside];
//        [button setIsRound:YES];
//        [button setBorderColor:[UIColor whiteColor]];
//        [button setBorderWidth:2];
//        button.tag = 333;
//        
//        annotationView.backgroundColor = [UIColor whiteColor];
//        [annotationView setIsRound:YES];
//    }
//    
//    button = [annotationView viewWithTag:333];
//    objc_setAssociatedObject(button, @"Annotation", annotation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    
//    [button setImage:nil forState:UIControlStateNormal];
//    [button setBackgroundColor:buttonColor];
//    [button setTitle:count forState:UIControlStateNormal];
    return nil;
}

- (UIImage *) imageFromUIView:(UIView *)view{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return  image;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return  newImage;
}
-(void)mapView:(MKMapView*)mapView regionDidChangeAnimated:(BOOL)animated {
    
    MKMapRect mRect = self.mapView.visibleMapRect;
    currentReginAreaForMap = [self getBoundingBox:mRect];
    zoomLevel = [self.mapView zoomLevel];
    
    isZoomIn = YES;
    isMovingMap = YES;
    if (zoomLevel > 9) {
        [self reloadEntities];
    }else{
        [self removeAllEntities];
    }
    [self reloadContacts];
}
- (void) reloadEntitiesForMoveMap{
    if( !self.isViewLoaded ) {
        return;
    }
    NSArray * oldArrayAnn = self.mapView.annotations;
    NSMutableArray * oldAnnotation = [[NSMutableArray alloc] init];
    for (id<MKAnnotation> oldAnn in oldArrayAnn) {
        if ([oldAnn isKindOfClass:[LocationOfEntityAnnotoation class]]) {
            [oldAnnotation addObject:oldAnn];
        }
    }
    [self.mapView removeAnnotations:oldAnnotation];
    [self.mapView addAnnotations:oldAnnotation];
    
}
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    selectedContacts = nil;
    currentAnn = nil;
    [self.tableView reloadData];
    
    if (zoomLevel == [self.mapView zoomLevel] && zoomLevel < 12) {
        isMovingMap = NO;
        isZoomIn = NO;
        if (zoomLevel > 9) {
            //[self reloadEntities];
            [self reloadEntitiesForMoveMap];
        }else{
            [self removeAllEntities];
        }
        [self reloadContacts];
    }else{
        isZoomIn = YES;
        isMovingMap = YES;
        if (zoomLevel > 9) {
            //[self reloadEntities];
            [self reloadEntitiesForMoveMap];
        }else{
            [self removeAllEntities];
        }
        [self reloadContacts];
    }
}
-(CLLocationCoordinate2D)getNECoordinate:(MKMapRect)mRect{
    return [self getCoordinateFromMapRectanglePoint:MKMapRectGetMaxX(mRect) y:mRect.origin.y];
}
-(CLLocationCoordinate2D)getNWCoordinate:(MKMapRect)mRect{
    return [self getCoordinateFromMapRectanglePoint:MKMapRectGetMinX(mRect) y:mRect.origin.y];
}
-(CLLocationCoordinate2D)getSECoordinate:(MKMapRect)mRect{
    return [self getCoordinateFromMapRectanglePoint:MKMapRectGetMaxX(mRect) y:MKMapRectGetMaxY(mRect)];
}
-(CLLocationCoordinate2D)getSWCoordinate:(MKMapRect)mRect{
    return [self getCoordinateFromMapRectanglePoint:mRect.origin.x y:MKMapRectGetMaxY(mRect)];
}
-(CLLocationCoordinate2D)getCoordinateFromMapRectanglePoint:(double)x y:(double)y{
    MKMapPoint swMapPoint = MKMapPointMake(x, y);
    return MKCoordinateForMapPoint(swMapPoint);
}
-(NSArray *)getBoundingBox:(MKMapRect)mRect{
    CLLocationCoordinate2D bottomLeft = [self getSWCoordinate:mRect];
    CLLocationCoordinate2D topRight = [self getNECoordinate:mRect];
    return @[[NSNumber numberWithDouble:bottomLeft.latitude ],
             [NSNumber numberWithDouble:bottomLeft.longitude],
             [NSNumber numberWithDouble:topRight.latitude],
             [NSNumber numberWithDouble:topRight.longitude]];
}
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (userLocationShown) {
        return;
    }
    userLocationShown = YES;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 30000, 30000);
    [self.mapView setRegion:region animated:NO];
}
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(nonnull MKAnnotationView *)view{
    
//    [self performSelector:@selector(openCallout:) withObject:[view annotation] afterDelay:0.2];
    
//    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(view.annotation.coordinate.latitude, view.annotation.coordinate.longitude) zoomLevel:zoomLevel animated:YES];
    currentAnn = view.annotation;
    isSelectedMultiLocation = NO;
    [tableView setScrollEnabled:NO];
    if([view.annotation isKindOfClass:[LocationOfEntityAnnotoation class]]){
        NSMutableArray *selectedEntities = [NSMutableArray array];
        NSManagedObjectContext *context = [AppDelegate sharedDelegate].managedObjectContext;
        
        NSFetchRequest *allContacts = [[NSFetchRequest alloc] init];
        [allContacts setEntity:[NSEntityDescription entityForName:@"LocationOfEntity" inManagedObjectContext:context]];
        NSError *error;
        NSArray *entitieResult = [context executeFetchRequest:allContacts error:&error];
        NSArray *foundContacts = [entitieResult filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"((latitude == %@) AND (longitude == %@))",@(((LocationOfEntityAnnotoation*)view.annotation).coordinate.latitude),@(((LocationOfEntityAnnotoation*)view.annotation).coordinate.longitude)]];
        if (foundContacts.count > 0) {
            for (LocationOfEntity *location in foundContacts) {
                [selectedEntities addObjectsFromArray:@[location]];
            }
        }
        
        selectedContacts = selectedEntities;
        if ([selectedContacts count] > 1) {
            [tableView setScrollEnabled:YES];
        }
        isSelectedMultiLocation = YES;
        [selectedMultiLocations removeAllObjects];
        for (LocationOfEntity *location in selectedContacts) {
            NSDictionary *dict = [location getDataDictionary];
            [selectedMultiLocations addObject:dict];
        }
        [self.tableView reloadData];
        [self updatedSelectedLocations];
        
        //[self.tableView reloadData];
    }else{
        if([view.annotation isKindOfClass:[ContactsAnnotation class]]){
            selectedContacts = ((ContactsAnnotation*)view.annotation).contacts;
            selectedContactId = [NSString stringWithFormat:@"%@", ((ContactsAnnotation*)view.annotation).contactId];
            [self.tableView reloadData];
        }
    }
}
- (void)updatedSelectedLocations{
    //[selectedMultiLocations removeAllObjects];
    countOfLocations = 0;
    if (isSelectedMultiLocation){
        for (LocationOfEntity *oneLocation in selectedContacts) {
            NSDictionary *dict = [oneLocation getDataDictionary];
            [[Communication sharedManager] SelectedEntitySummary:[AppDelegate sharedDelegate].sessionId entityId:[dict objectForKey:@"entity_id"] successed:^(id _responseObject) {
                countOfLocations++;
                for (int i = 0 ; i < [selectedMultiLocations count]; i ++)
                {
                    NSDictionary *dic = [selectedMultiLocations objectAtIndex:i];
                    if ([[NSString stringWithFormat:@"%@",[dic objectForKey:@"entity_id"]] isEqualToString:[NSString stringWithFormat:@"%@",[[_responseObject objectForKey:@"data"] objectForKey:@"entity_id"]]]) {
                        [selectedMultiLocations replaceObjectAtIndex:countOfLocations-1 withObject:[_responseObject objectForKey:@"data"]];
                    }
                }
                //[selectedMultiLocations addObject:[_responseObject objectForKey:@"data"]];
                if ([selectedContacts count] == countOfLocations) {
                    countOfLocations = 0;
                    [self.tableView reloadData];
                }
            } failure:^(NSError *err) { }];
        }
    }
}
- (void) mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray<MKAnnotationView *> *)views{
    for (MKAnnotationView *view in views)
    {
        if ([[view annotation] isKindOfClass:[ContactsAnnotation class]]) {
            if ([selectedContactId isEqualToString:[NSString stringWithFormat:@"%@",((ContactsAnnotation *) [view annotation]).contactId]]) {
                [[view superview] bringSubviewToFront:view];
            }
        }
    }
}

- (void)openCallout:(id<MKAnnotation>) annotation{
    //CLLocationDistance distance = REGIONZOOM;
//    MKMapRect mRect = self.mapView.visibleMapRect;
//    MKMapPoint eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect));
//    MKMapPoint westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect));
//    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, MKMetersBetweenMapPoints(eastMapPoint, westMapPoint), MKMetersBetweenMapPoints(eastMapPoint, westMapPoint));
    MKCoordinateRegion region = MKCoordinateRegionMake(annotation.coordinate, MKCoordinateSpanMake(0.01, 0.01));
    [self.mapView setRegion:region animated:YES];
    
}
#pragma mark -
#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger heightMultiplier = (selectedContacts.count > 3) ? 3 : selectedContacts.count;
    self.heightConstraint.constant = self.tableView.rowHeight * heightMultiplier;
    [self.view setNeedsLayout];
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    return selectedContacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)ttableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isSelectedMultiLocation) {
        //LocationOfEntity *location = selectedContacts[indexPath.row];
        //NSDictionary *dict = [location getDataDictionary];
        
        NSDictionary *dict = [selectedMultiLocations objectAtIndex:indexPath.row];
        
        EntityCell *cell = [tableView dequeueReusableCellWithIdentifier:EntityCellIdentifier];
        cell.delegate = self;
        cell.curDict = dict;
        cell.isFollowing =[[dict objectForKey:@"is_followed"] boolValue];
//        if ([self checkEntityExistedOnLocal:[dict objectForKey:@"entity_id"]]) {
//            cell.isFollowing =YES;
//        }else{
//            cell.isFollowing = NO;
//        }
        return cell;
    }
    SearchedContact *contact = selectedContacts[indexPath.row];
    if ([contact.exchanged boolValue] && [contact.contact_type isEqualToNumber:@(1)]) {
        ExchangedInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExchangedInfoCell"];
        [cell populateCellWithContact:contact];
        cell.delegate = self;
        return cell;
    }
    else {
        if ([contact.contact_type isEqualToNumber:@(3)]) {
            NSDictionary *dict = [contact getDataDictionary];
            EntityCell *cell = [tableView dequeueReusableCellWithIdentifier:EntityCellIdentifier];
            cell.delegate = self;
            cell.curDict = dict;
            cell.isFollowing = NO;
            return cell;
        }
        NotExchangedInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotExchangedInfoCell"];
        [cell populateCellWithContact:contact];
        cell.delegate = self;
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)ttableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (isSelectedMultiLocation) {
         LocationOfEntity *location = selectedContacts[indexPath.row];
        NSDictionary *dictFromDB = [location getDataDictionary];
        
        NSDictionary *dict = [selectedMultiLocations objectAtIndex:indexPath.row];
        BOOL isfollowing = NO;
        isfollowing =[[dict objectForKey:@"is_followed"] boolValue];
//        if ([self checkEntityExistedOnLocal:[dict objectForKey:@"entity_id"]]) {
//            isfollowing =YES;
//        }else{
//            isfollowing = NO;
//        }
         [self getEntityFollowerView:[dict objectForKey:@"entity_id"] following:isfollowing notes:[dictFromDB objectForKey:@"notes"]];
        return;
    }
    SearchedContact *contact = selectedContacts[indexPath.row];
    if ([contact.exchanged boolValue] && [contact.contact_type isEqualToNumber:@(1)]) {
        if ([contact.sharing_status integerValue] == 4) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"GINKO" message:@"Oops! Contact would like to chat only" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alertView show];
            return;
        }
        [self getContactDetail:[contact.contact_id stringValue]];
    }
    else {
        NSDictionary *dict = [contact getDataDictionary];
        if ([contact.contact_type isEqualToNumber:@(3)]) {
            [self getEntityFollowerView:[contact.contact_id stringValue] following:NO notes:[dict objectForKey:@"notes"]];
        }
        else {
            if ([[dict objectForKey:@"is_pending"] boolValue]) {
                APPDELEGATE.type = 2;
            }else{
                APPDELEGATE.type = 5;
            }
            ProfileViewController * controller = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
            controller.contactInfo = [contact getDataDictionary];
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

- (BOOL)checkEntityExistedOnLocal:entityid{
    NSManagedObjectContext *context = [AppDelegate sharedDelegate].managedObjectContext;
    
    NSFetchRequest *allContacts = [[NSFetchRequest alloc] init];
    [allContacts setEntity:[NSEntityDescription entityForName:@"Contact" inManagedObjectContext:context]];
    
    NSError *error = nil;
    NSArray *contacts = [context executeFetchRequest:allContacts error:&error];
    
    // remove contacts
    NSArray *foundLocations = [contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(contact_id == %@) AND (contact_type == 3)", [NSString stringWithFormat:@"%@", entityid]]];
    if (foundLocations.count > 0) {
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark - ExchangedInfoCell Delegate

- (void)didChat:(NSDictionary *)contactDict {
    [self CreateMessageBoard:[contactDict objectForKey:@"contact_id"] dict:contactDict];
}
- (void)didPhone:(UIActionSheet *)actionSheet{
    disWithConferenceCallingActionSheet = actionSheet;
}
- (void)closeCurrentActionWhenConferenceView{
    if (disWithConferenceCallingActionSheet) {
        [disWithConferenceCallingActionSheet dismissWithClickedButtonIndex:-1 animated:YES];
    }
}
- (void)didCallVideo:(NSDictionary *)contactDict{
    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted) {
                    [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your Camera or Microphone is disabled.\nPlease go to settings and grant access to it."];
                }
                else {
                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                        if (!granted) {
                            [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your Camera or Microphone is disabled.\nPlease go to settings and grant access to it."];
                        }
                        else {
                            [self CreateVideoAndVoiceConferenceBoard:[contactDict objectForKey:@"contact_id"] dict:contactDict type:1];
                        }
                    }];
                }
            });
        }];
    }
    
}
- (void)didCallVoice:(NSDictionary *)contactDict{
    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted) {
                    [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your Camera or Microphone is disabled.\nPlease go to settings and grant access to it."];
                }
                else {
                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                        if (!granted) {
                            [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your Camera or Microphone is disabled.\nPlease go to settings and grant access to it."];
                        }
                        else {
                            [self CreateVideoAndVoiceConferenceBoard:[contactDict objectForKey:@"contact_id"] dict:contactDict type:2];
                        }
                    }];
                }
            });
        }];
    }
}

-(void)CreateVideoAndVoiceConferenceBoard:(NSString*)ids dict:(NSDictionary *)contactInfo type:(NSInteger)_type
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            [APPDELEGATE.conferenceMembersForVideoCalling removeAllObjects];
            NSMutableDictionary *dictOfUser = [[NSMutableDictionary alloc] init];
            
            [dictOfUser setObject:[contactInfo valueForKey:@"contact_id"] forKey:@"user_id"];
            [dictOfUser setObject:[NSString stringWithFormat:@"%@ %@", [contactInfo objectForKey:@"first_name"], [contactInfo objectForKey:@"last_name"]] forKey:@"name"];
            [dictOfUser setObject:[contactInfo objectForKey:@"profile_image"] forKey:@"photo_url"];
            if (_type == 1) {
                [dictOfUser setObject:@"on" forKey:@"videoStatus"];
            }else{
                [dictOfUser setObject:@"off" forKey:@"videoStatus"];
            }
            [dictOfUser setObject:@"on" forKey:@"voiceStatus"];
            [dictOfUser setObject:@(1) forKey:@"conferenceStatus"];
            [dictOfUser setObject:@(0) forKey:@"isOwner"];
            [dictOfUser setObject:@(0) forKey:@"isInvited"];
            [dictOfUser setObject:@(1) forKey:@"isInvitedByMe"];
            
            [APPDELEGATE.conferenceMembersForVideoCalling addObject:dictOfUser];
            
            VideoVoiceConferenceViewController *viewcontroller = [[VideoVoiceConferenceViewController alloc] initWithNibName:@"VideoVoiceConferenceViewController" bundle:nil];
            APPDELEGATE.isOwnerForConference = YES;
            APPDELEGATE.isJoinedOnConference = YES;
            APPDELEGATE.conferenceId = [[_responseObject objectForKey:@"data"] objectForKey:@"board_id"];
            viewcontroller.boardId = [[_responseObject objectForKey:@"data"] objectForKey:@"board_id"];
            viewcontroller.conferenceType = _type;
            viewcontroller.conferenceName =[NSString stringWithFormat:@"%@ %@", [contactInfo objectForKey:@"first_name"], [contactInfo objectForKey:@"last_name"]];
            [self.navigationController pushViewController:viewcontroller animated:YES];
            
        }else{
            [CommonMethods showAlertUsingTitle:@"Error!" andMessage:[[_responseObject objectForKey:@"err"] objectForKey:@"errMsg"]];
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Internet Connection Error!"];
        
    } ;
    
    [[YYYCommunication sharedManager] CreateChatBoard:[AppDelegate sharedDelegate].sessionId userids:ids successed:successed failure:failure];
}

- (void)didEdit:(NSDictionary *)contactDict {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.type = 4;
    
    if ([contactDict objectForKey:@"detected_location"] && ![[contactDict objectForKey:@"detected_location"] isEqualToString:@""])
    {
        ProfileViewController * controller = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
        controller.contactInfo = contactDict;
        [self.navigationController pushViewController:controller animated:YES];
    }else{
        ProfileRequestController * controller = [[ProfileRequestController alloc] initWithNibName:@"ProfileRequestController" bundle:nil];
        controller.contactInfo = contactDict;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark -
#pragma mark - GinkoMeTabDelegate

- (void)updated:(NSArray *)contacts greys:(NSArray *)greys{
    //[self reloadMap];
    [self reloadContacts];
}
- (void)updateTableView{
    [self updatedSelectedLocations];
}
- (void) malloc{
    self.mapView.delegate = nil;
    self.mapView = nil;
    [self.mapView removeFromSuperview];
    tabController = nil;
    tabController.cDelegate = nil;
    currentAnn = nil;
    [self.mapView removeAnnotations:self.mapView.annotations];
}
-(void)hideKeyBoard{

}
@end
