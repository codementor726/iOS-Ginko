//
//  MainEntityViewController.h
//  ginko
//
//  Created by stepanekdavid on 4/19/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MainEntityViewController : UIViewController<CLLocationManagerDelegate>
{
    IBOutlet UIView * navView;
    
    __weak IBOutlet UIView *mainEntityObserveView;
    __weak IBOutlet UIView *mainEntityProfileContainerView;
    __weak IBOutlet UIImageView *mainEntityProfileImageLarge;
    
}

@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIButton *notesButton;
@property (weak, nonatomic) IBOutlet UIButton *inviteButton;
- (IBAction)follow:(id)sender;
- (IBAction)notes:(id)sender;
- (IBAction)invite:(id)sender;

@property (weak, nonatomic) IBOutlet UIScrollView *entityScrollView;

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *wallpaperImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *wallpaperLoadingIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *profileImageLoadingIndicator;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *privilegeImageView;

@property (weak, nonatomic) IBOutlet UIButton *btnEntityFavorite;
- (IBAction)onFavorite:(id)sender;

@property (nonatomic, retain) AppDelegate * appDelegate;

// set from outside
@property (nonatomic, strong) NSMutableDictionary *entityData;
@property (nonatomic, assign) BOOL isFollowing;
@property (nonatomic, assign) BOOL isFavorite;
@property (nonatomic, assign) NSInteger locationsTotal;


- (void)setNotes:(NSString *)notes;
- (IBAction)onBack:(id)sender;
- (IBAction)goWall:(id)sender;

@property (nonatomic, retain) CLLocationManager * locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D currentLocationforMultiLocations;
@property (nonatomic, retain) NSTimer * getCurrentGPSCallTimer;

-(void)repeatLocationUpdating;
- (IBAction)onMainEntiyProfileObserveView:(id)sender;
- (IBAction)onMainEntityProfileObserveViewClose:(id)sender;
@end

