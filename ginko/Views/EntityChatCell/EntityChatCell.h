//
//  EntityChatCell.h
//  GINKO
//
//  Created by mobidev on 7/25/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSBubbleVideoPlayer.h"
#import "NSBubbleAudioPlayer.h"
#import "NSBubbleMap.h"

@protocol EntityChatCellDelegate
@optional;
- (void)didVideoTouch:(NSString *)videoURL;
- (void)didImageTouch:(NSString *)photoURL;
- (void)didMapTouch:(float)lat :(float)lng;
- (void)didAvatar:(NSDictionary *)messageDict;
- (void)didEntityName:(NSDictionary *)messageDict;
- (void)didContent:(NSDictionary *)messageDict;
- (void)didReturn:(NSDictionary *)messageDict;

// long press
- (void)photoLongPressed:(NSString *)photoPath;
- (void)videoLongPressed:(NSString *)videoPath;
- (void)voiceLongPressed:(NSString *)audioPath;
@end

@interface EntityChatCell : UITableViewCell <NSBubbleVideoDelegate, NSBubbleMapDelegate, UIGestureRecognizerDelegate>
{
    NSString *strImageURL;
    NSString *strAudioURL;
}

@property (nonatomic, retain) IBOutlet UIImageView * imgProfile;
@property (nonatomic, retain) IBOutlet UILabel *lblName;
@property (nonatomic, retain) IBOutlet UITextView *lblMessage;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;
@property (nonatomic, retain) IBOutlet UILabel *lblSentTime;
@property (nonatomic, retain) IBOutlet UIView  *viewMedia;
@property (nonatomic, retain) IBOutlet UIButton  *btnContent;

@property (nonatomic, retain) NSDictionary *messageDict;
@property (nonatomic, retain) NSString *entityID;
@property (nonatomic, retain) NSString *entityName;
@property (nonatomic, retain) NSString *entityImageURL;

@property (nonatomic, retain) id<EntityChatCellDelegate> delegate;

- (IBAction)onAvatar:(id)sender;
- (IBAction)onEntityName:(id)sender;
- (IBAction)onContent:(id)sender;
- (IBAction)onReturn:(id)sender;

+ (EntityChatCell *)sharedCell;

@end
