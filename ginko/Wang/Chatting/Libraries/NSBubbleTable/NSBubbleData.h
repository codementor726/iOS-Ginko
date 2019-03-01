//
//  NSBubbleData.h
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import <Foundation/Foundation.h>
#import "NSBubbleMap.h"
#import "NSBubbleVideoPlayer.h"

@protocol NSBubbleDataDelegate <NSObject>

- (void)mapTouched:(float)latitude :(float)longitude;
- (void)videoTouched:(NSString*)videoPath;
- (void)videoLongPressed:(NSString *)videoPath;
- (void)imageTouched:(NSString*)imageurl;
- (void)photoLongPressed:(NSString *)photoPath;
- (void)voiceLongPressed:(NSString *)audioPath;

@end

typedef enum _NSBubbleType
{
    BubbleTypeMine = 0,
    BubbleTypeSomeoneElse = 1
} NSBubbleType;

typedef enum : NSUInteger {
    NSBubbleContentTypeText = 0,    // map also included
    NSBubbleContentTypePhoto,
    NSBubbleContentTypeVoice,
    NSBubbleContentTypeVideo
} NSBubbleContentType;

@interface NSBubbleData : NSObject<NSBubbleMapDelegate,NSBubbleVideoDelegate>
{
	NSString *strimageurl;
}
@property (readonly, nonatomic, strong) NSDate *date;
@property (readonly, nonatomic) NSBubbleType type;
@property (readonly, nonatomic) NSBubbleContentType contentType;
@property (readonly, nonatomic) NSString *mediaFilePath; // exists for photo, voice, video
@property (readonly, nonatomic) NSString *videoThumbPath; // exists for video only
@property (readonly, nonatomic) NSString *contentText;  // exists for text and map
@property (readonly, nonatomic, strong) UIView *view;
@property (readonly, nonatomic) UIEdgeInsets insets;
@property (nonatomic, strong) UIImage *avatar;
@property (nonatomic, strong) NSURL *avatar_url;
@property (nonatomic,retain) NSString *msg_id;
@property (nonatomic,retain) NSString *msg_userid;
@property (nonatomic,retain) NSString *msg_userfname;
@property (nonatomic,retain) NSString *msg_userlname;
@property (nonatomic,retain) NSString *msg_entityname;

@property (nonatomic,retain) id<NSBubbleDataDelegate> delegate;

- (id)initWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type;
+ (id)dataWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type;
- (id)initWithImage:(NSString *)image date:(NSDate *)date type:(NSBubbleType)type;
+ (id)dataWithImage:(NSString *)image date:(NSDate *)date type:(NSBubbleType)type;
- (id)initWithView:(UIView *)view date:(NSDate *)date type:(NSBubbleType)type contentType:(NSBubbleContentType)contentType insets:(UIEdgeInsets)insets;
+ (id)dataWithView:(UIView *)view date:(NSDate *)date type:(NSBubbleType)type contentType:(NSBubbleContentType)contentType insets:(UIEdgeInsets)insets;

- (id)initWithAudio:(NSString *)audio date:(NSDate *)date type:(NSBubbleType)type;
+ (id)dataWithAudio:(NSString *)audio date:(NSDate *)date type:(NSBubbleType)type;

- (id)initWithVideo:(NSString *)video thumb:(NSString*)thumburl date:(NSDate *)date type:(NSBubbleType)type;
+ (id)dataWithVideo:(NSString *)video thumb:(NSString*)thumburl date:(NSDate *)date type:(NSBubbleType)type;

- (id)initWithMap:(NSString *)location date:(NSDate *)date type:(NSBubbleType)type;
+ (id)dataWithMap:(NSString *)location date:(NSDate *)date type:(NSBubbleType)type;

@end
