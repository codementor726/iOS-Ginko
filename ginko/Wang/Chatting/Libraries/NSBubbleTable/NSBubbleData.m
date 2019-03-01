//
//  NSBubbleData.m
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import "NSBubbleData.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+AFNetworking.h"
#import "NSBubbleAudioPlayer.h"
#import "NSBubbleVideoPlayer.h"
#import <MapKit/MapKit.h>
#import "Place.h"
#import "PlaceMark.h"
#import "NSBubbleMap.h"
#import "LocalDBManager.h"

@implementation NSBubbleData

#pragma mark - Properties

@synthesize delegate;
@synthesize date = _date;
@synthesize type = _type;
@synthesize contentType = _contentType;
@synthesize mediaFilePath = _mediaFilePath;
@synthesize videoThumbPath = _videoThumbPath;
@synthesize contentText = _contentText;
@synthesize view = _view;
@synthesize insets = _insets;
@synthesize avatar = _avatar;
@synthesize avatar_url = _avatar_url;
@synthesize msg_id = _msg_id;
@synthesize msg_userid = _msg_userid;
@synthesize msg_userfname = _msg_userfname;
@synthesize msg_userlname = _msg_userlname;
@synthesize msg_entityname = _msg_entityname;


#pragma mark - Lifecycle

#if !__has_feature(objc_arc)
- (void)dealloc
{
    [_date release];
	_date = nil;
    [_view release];
    _view = nil;
    
    self.avatar = nil;

    [super dealloc];
}
#endif

#pragma mark - Text bubble

const UIEdgeInsets textInsetsMine = {5, 10, 11, 17};
const UIEdgeInsets textInsetsSomeone = {5, 15, 11, 10};

+ (id)dataWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type
{
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithText:text date:date type:type] autorelease];
#else
    return [[NSBubbleData alloc] initWithText:text date:date type:type];
#endif    
}

+ (id)dataWithAudio:(NSString *)audio date:(NSDate *)date type:(NSBubbleType)type
{
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithAudio:audio date:date type:type] autorelease];
#else
    return [[NSBubbleData alloc] initWithAudio:audio date:date type:type];
#endif
}

- (id)initWithAudio:(NSString *)audio date:(NSDate *)date type:(NSBubbleType)type
{
	NSBubbleAudioPlayer *audioplayer = [NSBubbleAudioPlayer customView];
	[audioplayer setFrame:CGRectMake(0, 0, 230, 36)];
	[audioplayer initWithUrl:audio];
	
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAudio:)];
    [audioplayer addGestureRecognizer:longPress];
    
    _mediaFilePath = audio;
    
	UIEdgeInsets insets = (type == BubbleTypeMine ? textInsetsMine : textInsetsSomeone);
    return [self initWithView:audioplayer date:date type:type contentType:NSBubbleContentTypeVoice insets:insets];
}

- (void)longPressAudio:(UILongPressGestureRecognizer *)recognizer {
    if (((NSBubbleAudioPlayer *)_view).btPlay.hidden == NO && recognizer.state == UIGestureRecognizerStateBegan) { // check if play button is shown, means the audio is downloaded
        [self.delegate voiceLongPressed:_mediaFilePath];
    }
}

+ (id)dataWithVideo:(NSString *)video thumb:(NSString *)thumburl date:(NSDate *)date type:(NSBubbleType)type
{
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithVideo:video thumb:thumburl date:date type:type] autorelease];
#else
    return [[NSBubbleData alloc] initWithVideo:video thumb:thumburl date:date type:type];
#endif
}

- (id)initWithVideo:(NSString *)video thumb:(NSString *)thumburl date:(NSDate *)date type:(NSBubbleType)type
{
	NSBubbleVideoPlayer *videoplayer = [NSBubbleVideoPlayer customView];
	[videoplayer setFrame:CGRectMake(0, 0, 230, 230)];
	videoplayer.delegate = self;
	[videoplayer initWithUrl:video thumb:thumburl];
    
    _mediaFilePath = video;
    _videoThumbPath = thumburl;
	
	UIEdgeInsets insets = (type == BubbleTypeMine ? textInsetsMine : textInsetsSomeone);
    return [self initWithView:videoplayer date:date type:type contentType:NSBubbleContentTypeVideo insets:insets];
}

+ (id)dataWithMap:(NSString *)location date:(NSDate *)date type:(NSBubbleType)type
{
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithMap:location date:date type:type] autorelease];
#else
    return [[NSBubbleData alloc] initWithMap:location date:date type:type];
#endif
}

- (id)initWithMap:(NSString *)location date:(NSDate *)date type:(NSBubbleType)type
{
    _contentText = [MAPBOUND stringByAppendingString:location];
    
	NSBubbleMap *map = [NSBubbleMap customView];
	[map setFrame:CGRectMake(0, 0, 100, 100)];
	map.delegate = self;
	[map initWithLocation:location];
	
	UIEdgeInsets insets = (type == BubbleTypeMine ? textInsetsMine : textInsetsSomeone);
    return [self initWithView:map date:date type:type contentType:NSBubbleContentTypeText insets:insets];
}

-(void)mapTouched:(float)lat :(float)lng
{
	[delegate mapTouched:lat :lng];
}

-(void)videoTouched:(NSString *)url
{
	[delegate videoTouched:url];
}

- (void)videoLongPressed:(NSString *)videoPath {
    [delegate videoLongPressed:videoPath];
}

- (id)initWithText:(NSString *)text date:(NSDate *)date type:(NSBubbleType)type
{
    _contentText = text;
    
    UIFont *font = [UIFont systemFontOfSize:17];
//    UIFont *font = [UIFont systemFontOfSize:16];
    CGSize size = [(text ? text : @"") boundingRectWithSize:CGSizeMake(220, 9999) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: font} context:nil].size;
    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
//    label.numberOfLines = 0;
//    label.lineBreakMode = NSLineBreakByWordWrapping;
//    label.text = (text ? text : @"");
//    label.font = font;
//    label.backgroundColor = [UIColor clearColor];
    
    UITextView *txt = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
//    txt.contentInset = UIEdgeInsetsMake(-2,-3,0,0);
    txt.textContainerInset = UIEdgeInsetsZero;
    txt.textContainer.lineFragmentPadding = 0;
    txt.text = (text ? text : @"");
    txt.font = font;
    txt.backgroundColor = [UIColor clearColor];

    [txt setEditable:NO];
    [txt setScrollEnabled:NO];
    [txt setDataDetectorTypes:UIDataDetectorTypeLink];
    
#if !__has_feature(objc_arc)
//    [label autorelease];
    [txt autorelease];
#endif
    
    UIEdgeInsets insets = (type == BubbleTypeMine ? textInsetsMine : textInsetsSomeone);
//    return [self initWithView:label date:date type:type insets:insets];
    return [self initWithView:txt date:date type:type contentType:NSBubbleContentTypeText insets:insets];
}

#pragma mark - Image bubble

const UIEdgeInsets imageInsetsMine = {11, 13, 16, 22};
const UIEdgeInsets imageInsetsSomeone = {11, 18, 16, 14};

+ (id)dataWithImage:(NSString *)imageurl date:(NSDate *)date type:(NSBubbleType)type
{
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithImage:imageurl date:date type:type] autorelease];
#else
    return [[NSBubbleData alloc] initWithImage:imageurl date:date type:type];
#endif    
}

- (id)initWithImage:(NSString *)imageurl date:(NSDate *)date type:(NSBubbleType)type
{
	CGSize size = CGSizeMake(150, 150);
//    CGSize size = image.size;
//    if (size.width > 220)
//    {
//        size.height /= (size.width / 220);
//        size.width = 220;
//    }
    
	strimageurl = imageurl;
    
    _mediaFilePath = imageurl;
	
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    // Check cache first
    NSString *cachedPath = [LocalDBManager checkCachedFileExist:strimageurl];
    
    if (cachedPath) {
        // load from cache
        [imageView setImage:[UIImage imageWithContentsOfFile:cachedPath]];
    } else {
        // save to temp directory
        __weak UIImageView *weakImageView = imageView;
        [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:strimageurl]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            weakImageView.image = image;
            [UIImageJPEGRepresentation(image, 1.0) writeToFile:[LocalDBManager getCachedFileNameFromRemotePath:strimageurl] atomically:YES];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            
        }];
    }
    
    imageView.layer.cornerRadius = 5.0;
    imageView.layer.masksToBounds = YES;
	
	imageView.userInteractionEnabled = YES;

	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handelTap)];
	[imageView addGestureRecognizer:tapGesture];
	
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressPhoto:)];
    [imageView addGestureRecognizer:longPress];
    
#if !__has_feature(objc_arc)
    [imageView autorelease];
#endif
    
    UIEdgeInsets insets = (type == BubbleTypeMine ? imageInsetsMine : imageInsetsSomeone);
    return [self initWithView:imageView date:date type:type contentType:NSBubbleContentTypePhoto insets:insets];
}

- (void)longPressPhoto:(UILongPressGestureRecognizer *)recognizer {
    if ([(UIImageView *)_view image] != nil && recognizer.state == UIGestureRecognizerStateBegan) { // check if image is loaded
        [self.delegate photoLongPressed:_mediaFilePath];
    }
}

-(void)handelTap
{
	[delegate imageTouched:strimageurl];
}

#pragma mark - Custom view bubble

+ (id)dataWithView:(UIView *)view date:(NSDate *)date type:(NSBubbleType)type contentType:(NSBubbleContentType)contentType insets:(UIEdgeInsets)insets
{
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithView:view date:date type:type contentType:contentType insets:insets] autorelease];
#else
    return [[NSBubbleData alloc] initWithView:view date:date type:type contentType:contentType insets:insets];
#endif    
}

- (id)initWithView:(UIView *)view date:(NSDate *)date type:(NSBubbleType)type contentType:(NSBubbleContentType)contentType insets:(UIEdgeInsets)insets
{
    self = [super init];
    if (self)
    {
#if !__has_feature(objc_arc)
        _view = [view retain];
        _date = [date retain];
#else
        _view = view;
        _date = date;
#endif
        _type = type;
        _contentType = contentType;
        _insets = insets;
    }
    return self;
}

@end
