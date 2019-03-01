//
//  EntityViewController.h
//  ginko
//
//  Created by Harry on 2/20/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EntityViewControllerDelegate <NSObject>

- (void)returnIsFollowing:(BOOL)isFollowing;
- (void)returnIsFavorite:(BOOL)isFavorite;

@end
@interface EntityViewController : UIViewController
{
    IBOutlet UIView * navView;
    
    __weak IBOutlet UIView *entityProfileObserveView;
    __weak IBOutlet UIView *entityProfileContainerView;    
    __weak IBOutlet UIImageView *entityProfileImageLarge;
    
    
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
@property (strong, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UIImageView *snapshotImageView;

@property (weak, nonatomic) IBOutlet UIButton *btnEntityFavorite;
- (IBAction)onFavorite:(id)sender;

@property (nonatomic, retain) AppDelegate * appDelegate;

- (IBAction)playVideo:(id)sender;

// set from outside
@property (nonatomic, strong) NSDictionary *entityData;
@property (nonatomic, assign) BOOL isFollowing;
@property (nonatomic, assign) BOOL isFavorite;
@property (nonatomic, assign) BOOL isMultiLocations;
@property (nonatomic, assign) int infoId;
- (void)setNotes:(NSString *)notes;
- (IBAction)onBack:(id)sender;
- (IBAction)goWall:(id)sender;

@property (weak, nonatomic) id<EntityViewControllerDelegate> delegate;

- (IBAction)onProfileImageObserveView:(id)sender;
- (IBAction)onEntityProfileObserveViewClose:(id)sender;
@end
