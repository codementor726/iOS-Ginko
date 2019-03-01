//
//  RemoteViewCell.h
//  ginko
//
//  Created by stepanekdavid on 3/19/17.
//  Copyright © 2017 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <libjingle_peerconnection/RTCEAGLVideoView.h>
#import <libjingle_peerconnection/RTCVideoTrack.h>
@protocol RemoteViewCellDelegate

@optional;
- (void)didNoTryCalling:(NSString *)userId;
- (void)didYesTryCalling:(NSString *)userId;
-(void)noAnsweringNotification:(NSString *)userId;
@end

@interface RemoteViewCell : UICollectionViewCell{
    NSString *currentmemberId;
    NSInteger count;
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *remoteCellWidthCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *remoteCellHeightCons;
@property (weak, nonatomic) RTCEAGLVideoView *remoteViewOne;
@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageMember;
@property (weak, nonatomic) IBOutlet UIImageView *imgIntiatingCall;

@property BOOL isRendering;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileImageWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileImageHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alertWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alertheight;

@property (weak, nonatomic) IBOutlet UIButton *btnNo;
@property (weak, nonatomic) IBOutlet UIButton *btnYes;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnNoWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnYesWidth;

@property (nonatomic, retain) id<RemoteViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *alertCoverView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *remoteViewHeightCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *remoteViewWidthCons;

+ (RemoteViewCell *)sharedCell;
- (void)setPhoto:(NSString *)photo;
- (void)setBorder;
- (void)setCurrentMemberId:(NSString *)userid;

-(void)showAnimationForInitial;
-(void)hideAnimationForInitial;

-(void)showAlertOnCell;
-(void)hideAlertOnCell;


- (IBAction)onNoTry:(id)sender;
- (IBAction)onYesTry:(id)sender;
-(void)startAcceptTimerCount;
-(void)endAcceptTimerCount;
- (void)setVideoView:(RTCEAGLVideoView *)videoView;

@end
