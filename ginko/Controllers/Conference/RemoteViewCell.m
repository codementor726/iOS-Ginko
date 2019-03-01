//
//  RemoteViewCell.m
//  ginko
//
//  Created by stepanekdavid on 3/19/17.
//  Copyright © 2017 com.xchangewithme. All rights reserved.
//

#import "RemoteViewCell.h"
#import "UIImageView+AFNetworking.h"
@implementation RemoteViewCell

@synthesize profileImageMember;
@synthesize imgIntiatingCall;
@synthesize delegate;
@synthesize alertCoverView;
+ (RemoteViewCell *)sharedCell
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"RemoteViewCell" owner:nil options:nil];
    RemoteViewCell *cell = [array objectAtIndex:0];
    
    return cell;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.imgIntiatingCall.hidden = YES;
    count = 0;
}
- (void)setBorder
{
    profileImageMember.layer.cornerRadius = profileImageMember.frame.size.height / 2.0f;
    profileImageMember.layer.masksToBounds = YES;
    profileImageMember.layer.borderWidth = 1.0f;
    profileImageMember.layer.borderColor = COLOR_PURPLE_THEME.CGColor;
}

- (void)setPhoto:(NSString *)photo
{
    [profileImageMember setImageWithURL:[NSURL URLWithString:photo] placeholderImage:nil];
}
- (void)setVideoView:(RTCEAGLVideoView *)videoView
{
    if (_remoteViewOne != videoView) {
        
        [_remoteViewOne removeFromSuperview];
        _remoteViewOne = videoView;
        _remoteViewOne.frame = self.bounds;
        [self.coverView insertSubview:_remoteViewOne belowSubview:self.maskView];
    }
}
-(void)showAnimationForInitial{
    self.imgIntiatingCall.hidden = NO;
    CGPoint ptCenter = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
    self.imgIntiatingCall.alpha = 0.0;
    self.imgIntiatingCall.center = ptCenter;
    self.imgIntiatingCall.transform = CGAffineTransformMakeScale(0.05, 0.05);
    double dDuration = 0.2;
    
    [UIView animateWithDuration:dDuration animations:^(void) {
        
        self.alpha = 1.0;
        self.imgIntiatingCall.alpha = 1.0;
        self.imgIntiatingCall.transform = CGAffineTransformMakeScale(1.05, 1.05);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^(void) {
            self.imgIntiatingCall.alpha = 1.0;
            self.imgIntiatingCall.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL finished) {
            [self.imgIntiatingCall startAnimating];
        }];
    }];
}
-(void)hideAnimationForInitial{
    double dDuration = 0.1;
    [UIView animateWithDuration:dDuration animations:^(void) {
        self.imgIntiatingCall.transform = CGAffineTransformMakeScale(1.05, 1.05);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^(void) {
            [UIView setAnimationDelay:0.05];
            self.imgIntiatingCall.transform = CGAffineTransformMakeScale(0.05, 0.05);
            self.imgIntiatingCall.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.imgIntiatingCall stopAnimating];
            self.imgIntiatingCall.hidden = YES;
        }];
    }];
}

- (void)setCurrentMemberId:(NSString *)userid{
    currentmemberId = userid;
}

-(void)startAcceptTimerCount{
    count = 0;
    if (!APPDELEGATE.isOwnerForConference) {
        count = APPDELEGATE.countTillAccept;
    }
    
    NSTimer* acceptTimer = [[NSTimer alloc] init];
    acceptTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(repeatUpdating:) userInfo:[NSString stringWithFormat:@"%@", currentmemberId] repeats:YES];
        NSLog(@"******User id : %@   -------- currentid : %@", currentmemberId, APPDELEGATE.userId);
}
-(void)endAcceptTimerCount{
    count = 0;
}

-(void)repeatUpdating:(NSTimer*)theTimer{
    NSString *userid = [NSString stringWithFormat:@"%@", [theTimer userInfo]];
        NSLog(@"******User id : %@   -------- %ld", userid, (long)count);
        BOOL isAvailale = NO;
        for (int i = 0 ; i < [APPDELEGATE.conferenceMembersForVideoCalling count]; i ++) {
            NSMutableDictionary *changeUser = [[APPDELEGATE.conferenceMembersForVideoCalling objectAtIndex:i] mutableCopy];
            if ([[changeUser objectForKey:@"user_id"] integerValue] == [userid integerValue]) {
                if ([[changeUser objectForKey:@"conferenceStatus"] integerValue] == 8 ) {
                    isAvailale = YES;
                }
            }
            
        }
        
        if (isAvailale) {
            count = count +1;
            if (count > 30) {
                [theTimer invalidate];
                theTimer = nil;
                count = 0;
//                if (APPDELEGATE.isOwnerForConference) {
//                    alertCoverView.hidden = NO;
//                }
                self.imgIntiatingCall.hidden = YES;
                for (int i = 0 ; i < [APPDELEGATE.conferenceMembersForVideoCalling count]; i ++) {
                    NSMutableDictionary *changeUser = [[APPDELEGATE.conferenceMembersForVideoCalling objectAtIndex:i] mutableCopy];
                    if ([[changeUser objectForKey:@"user_id"] integerValue] == [userid integerValue]) {
                        [changeUser setObject:@(9) forKey:@"conferenceStatus"];
                        [APPDELEGATE.conferenceMembersForVideoCalling replaceObjectAtIndex:i withObject:changeUser];
                        if ([[changeUser objectForKey:@"isInvitedByMe"] boolValue]){
                            alertCoverView.hidden = NO;
                        }else{
                            alertCoverView.hidden = YES;
                        }
                        [delegate noAnsweringNotification:userid];
                    }
                }
            }
        }else{
            [theTimer invalidate];
            theTimer = nil;
        }
}

-(void)showAlertOnCell{
    alertCoverView.hidden = NO;
}

-(void)hideAlertOnCell{
    alertCoverView.hidden = YES;
}

- (IBAction)onNoTry:(id)sender {
    alertCoverView.hidden = YES;
    [delegate didNoTryCalling:currentmemberId];
}

- (IBAction)onYesTry:(id)sender {
    alertCoverView.hidden = YES;
    [delegate didYesTryCalling:currentmemberId];
}

@end
