//
//  EntityFollowerViewController.h
//  GINKO
//
//  Created by mobidev on 7/23/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TouchImageView.h"
#import "TouchLabel.h"

#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MessageUI.h>

#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface EntityFollowerViewController : UIViewController <UIAlertViewDelegate, MFMailComposeViewControllerDelegate>
{
    IBOutlet UIButton *btFollow;
	IBOutlet UIButton *btInvite;
	IBOutlet UIButton *btNotes;
	IBOutlet UIButton *btPlay;
	IBOutlet UIView	*vwContent;
	
	IBOutlet UIImageView	*imvBackground;
	IBOutlet UIScrollView	*scvContent;
}

-(IBAction)btFollowClick:(id)sender;
-(IBAction)btPlayClick:(id)sender;
-(IBAction)btInviteClick:(id)sender;
-(IBAction)btNotesClick:(id)sender;

@property (nonatomic,retain) NSMutableDictionary *dictEntity;
@property (nonatomic,retain) NSString *entityID;
@property (nonatomic,readwrite) BOOL isFollowing;
@property (nonatomic, readwrite) BOOL isFromRequest;
//@property (nonatomic, readwrite) BOOL isFromOwnWall;//should hide wall button
@property (nonatomic, strong) NSString *strNotes;

@end
