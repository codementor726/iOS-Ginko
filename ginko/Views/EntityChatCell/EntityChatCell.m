//
//  EntityChatCell.m
//  GINKO
//
//  Created by mobidev on 7/25/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import "EntityChatCell.h"
#import "UIImageView+AFNetworking.h"
#import "LocalDBManager.h"

#define PHOTOBOUND	@"!@#!xyz!@#!"
#define MAPBOUND	@"!@!#xyz!@#!"
#define VIDEOBOUND	@"!@!x#yz!@#!"
#define VOICEBOUND	@"!@!xy#z!@#!"

@implementation EntityChatCell
@synthesize delegate;
@synthesize messageDict = _messageDict;
@synthesize entityID = _entityID;
@synthesize entityName = _entityName;
@synthesize entityImageURL = _entityImageURL;
@synthesize imgProfile, lblMessage, lblName, lblSentTime, viewMedia, btnContent, lblContent;

+ (EntityChatCell *)sharedCell
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"EntityChatCell" owner:nil options:nil];
    EntityChatCell *cell = [array objectAtIndex:0];
    
    return cell;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    imgProfile.layer.cornerRadius = imgProfile.frame.size.width/2;
    imgProfile.layer.masksToBounds = YES;
    imgProfile.layer.borderColor = [UIColor colorWithRed:128.0/256.0 green:100.0/256.0 blue:162.0/256.0 alpha:1.0f].CGColor;
    imgProfile.layer.borderWidth = 1.0f;
    
    viewMedia.layer.cornerRadius = 5.0;
    viewMedia.layer.masksToBounds = YES;
    
    [lblMessage setEditable:NO];
    [lblMessage setScrollEnabled:YES];
    [lblMessage setSelectable:NO];
    [lblMessage setDataDetectorTypes:UIDataDetectorTypeLink];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMessageDict:(NSDictionary *)messageDict
{
    _messageDict = messageDict;
    if (_entityID) {
        [imgProfile setImageWithURL:[NSURL URLWithString:_entityImageURL] placeholderImage:[UIImage imageNamed:@"entity-dummy"]];
//        lblName.hidden = YES;
//        CGRect frame = lblMessage.frame;
//        frame.origin.y -= 20;
//        frame.size.height += 20;
//        lblMessage.frame = frame;
//        viewMedia.frame = frame;
        lblName.text = _entityName;
    } else {
        [imgProfile setImageWithURL:[NSURL URLWithString:[_messageDict objectForKey:@"profile_image"]] placeholderImage:[UIImage imageNamed:@"entity-dummy"]];
        lblName.text = [_messageDict objectForKey:@"entity_name"];
    }
//    lblSentTime.text = [_messageDict objectForKey:@"sent_time"];
//    NSDate *date = [CommonMethods str2date:[_messageDict objectForKey:@"sent_time"] withFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [formatter setTimeZone :[NSTimeZone timeZoneForSecondsFromGMT: 0]];
    NSDate *utcdate = [formatter dateFromString:[NSString stringWithFormat:@"%@",[_messageDict objectForKey:@"sent_time"]]];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    NSDate *date = [formatter dateFromString:[formatter stringFromDate:utcdate]];
    
    lblSentTime.text = [CommonMethods date2str:date withFormat:@"MMM dd, yyyy,  hh:mm:ss"];
    [self setMessageContent];
}

- (void)setMessageContent
{
    if (![[[_messageDict objectForKey:@"content"] substringToIndex:1] isEqualToString:@"{"])
    {
        if ([[_messageDict objectForKey:@"content"] rangeOfString:MAPBOUND].location == 0) {
            lblMessage.text = @"";
            btnContent.hidden = YES;
            viewMedia.hidden = NO;
            [self createMapView:[[_messageDict objectForKey:@"content"] substringFromIndex:MAPBOUND.length]];
        } else {
            NSString *message = [_messageDict objectForKey:@"content"];
//            if ([message length] > 160) {
//                message = [NSString stringWithFormat:@"%@..", [message substringToIndex:160]];
//            }
            lblMessage.text = message;
//            [lblMessage sizeToFit];
        }
    } else {
        lblMessage.text = @"";
        btnContent.hidden = YES;
        viewMedia.hidden = NO;
        NSString *content = [_messageDict objectForKey:@"content"];
        id jsonData = [content dataUsingEncoding:NSUTF8StringEncoding]; //if input is NSString
        id dictMsg = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        if([[dictMsg objectForKey:@"file_type"] isEqualToString:@"photo"])
        {
            [self createImageView:[dictMsg objectForKey:@"url"]];
        }
        else if ([[dictMsg objectForKey:@"file_type"] isEqualToString:@"voice"])
        {
            [self createAudioView:[dictMsg objectForKey:@"url"]];
        }
        else if ([[dictMsg objectForKey:@"file_type"] isEqualToString:@"video"])
        {
            [self createVideoView:[dictMsg objectForKey:@"url"] thumb:[dictMsg objectForKey:@"thumnail_url"]];
        }
    }
}

- (void)createMapView:(NSString *)location
{
	NSBubbleMap *map = [NSBubbleMap customView];
	[map setFrame:CGRectMake(5, 5, 90, 90)];
	map.delegate = self;
	[map initWithLocation:location];
    viewMedia.frame = CGRectMake(170, 85, 100, 100);
    
    [viewMedia addSubview:map];
}

- (void)createImageView:(NSString *)imageurl
{
	CGSize size = CGSizeMake(150, 90);
	
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, size.width, size.height)];
    strImageURL = imageurl;
    
    // Check cache first
    NSString *cachedPath = [LocalDBManager checkCachedFileExist:strImageURL];
    
    if (cachedPath) {
        // load from cache
        [imageView setImage:[UIImage imageWithContentsOfFile:cachedPath]];
    } else {
        // save to temp directory
        __weak UIImageView *weakImageView = imageView;
        [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:strImageURL]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            weakImageView.image = image;
            [UIImageJPEGRepresentation(image, 1.0) writeToFile:[LocalDBManager getCachedFileNameFromRemotePath:strImageURL] atomically:YES];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            
        }];
    }
    
    imageView.layer.cornerRadius = 5.0;
    imageView.layer.masksToBounds = YES;
	
	imageView.userInteractionEnabled = YES;
    
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handelTap)];
	[imageView addGestureRecognizer:tapGesture];
    viewMedia.frame = CGRectMake(145, 85, 160, 100);
    [viewMedia addSubview:imageView];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressPhoto:)];
    [imageView addGestureRecognizer:longPress];
}

- (void)createVideoView:(NSString *)video thumb:(NSString *)thumburl
{
	NSBubbleVideoPlayer *videoplayer = [NSBubbleVideoPlayer customView];
	[videoplayer setFrame:CGRectMake(5, 5, 130, 120)];
	videoplayer.delegate = self;
	[videoplayer initWithUrl:video thumb:thumburl];
    [videoplayer setImageFrame:CGRectMake(0, 0, 130, 120)];
    viewMedia.frame = CGRectMake(165, 55, 140, 130);
    [viewMedia addSubview:videoplayer];
}

- (void)createAudioView:(NSString *)audio
{
	NSBubbleAudioPlayer *audioplayer = [NSBubbleAudioPlayer customView];
    strAudioURL = audio;
	[audioplayer setFrame:CGRectMake(5, 5, 160, 36)];
	[audioplayer initWithUrl:audio];
    audioplayer.prgAudio.frame = CGRectMake(audioplayer.prgAudio.frame.origin.x, audioplayer.prgAudio.frame.origin.y, 100, audioplayer.prgAudio.frame.size.height);
    viewMedia.frame = CGRectMake(130, 85, 170, 46);
    [viewMedia addSubview:audioplayer];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAudio:)];
    [audioplayer addGestureRecognizer:longPress];
}

#pragma mark - Gesture Recognizer

-(void)handelTap
{
    [delegate didImageTouch:strImageURL];
}

- (void)longPressPhoto:(UILongPressGestureRecognizer *)recognizer {
    UIImageView *imageView = viewMedia.subviews[0];
    if (imageView != nil && recognizer.state == UIGestureRecognizerStateBegan) { // check if image is loaded
        [self.delegate photoLongPressed:strImageURL];
    }
}

- (void)longPressAudio:(UILongPressGestureRecognizer *)recognizer {
    NSBubbleAudioPlayer *audioPlayer = viewMedia.subviews[0];
    if (audioPlayer.btPlay.hidden == NO && recognizer.state == UIGestureRecognizerStateBegan) { // check if play button is shown, means the audio is downloaded
        [self.delegate voiceLongPressed:strAudioURL];
    }
}

#pragma mark - NSBubbleVideoDelegate
- (void)videoTouched:(NSString*)url
{
    [delegate didVideoTouch:url];
}

- (void)videoLongPressed:(NSString *)videoPath {
    [delegate videoLongPressed:videoPath];
}

#pragma mark - NSBubbleMapDelegate
-(void)mapTouched:(float)lat :(float)lng
{
    [delegate didMapTouch:lat :lng];
}

#pragma mark - Action
- (IBAction)onAvatar:(id)sender
{
//    if (_entityID) {
//        return;
//    }
    [delegate didAvatar:_messageDict];
}

- (IBAction)onEntityName:(id)sender
{
    [delegate didEntityName:_messageDict];
}
- (void)redirectHistory{
    [delegate didEntityName:_messageDict];
}
- (IBAction)onContent:(id)sender
{
    [delegate didContent:_messageDict];
}

- (IBAction)onReturn:(id)sender
{
    [delegate didReturn:_messageDict];
}

@end
