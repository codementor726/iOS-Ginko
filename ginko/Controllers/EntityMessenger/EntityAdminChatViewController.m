//
//  EntityAdminChatViewController.m
//  GINKO
//
//  Created by mobidev on 7/24/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import "EntityAdminChatViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIBubbleTableView.h"
#import "UIBubbleTableViewDataSource.h"
#import "NSBubbleData.h"
#import "YYYLocationController.h"
#import "MBProgressHUD.h"
#import "YYYCommunication.h"
#import "AppDelegate.h"
#import "NSString+Utils.h"
#import "YYYMapViewController.h"
#import "YYYImageViewController.h"
#import "YYYVideoViewController.h"
#import "SVGeocoder.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "SVPullToRefresh.h"
#import "Reachability.h"
#import <AddressBook/AddressBook.h>
#import "UIImageView+AFNetworking.h"

#import "IMPhotoPickerController.h"
#import "IMVideoPickerController.h"
#import "LocalDBManager.h"

#define BUTTON_FONT_SIZE 32
#define EMOJICOL			7
#define EMOJIROW			3
#define BUTTON_WIDTH 45
#define BUTTON_HEIGHT 37

#define PHOTOBOUND	@"!@#!xyz!@#!"
#define MAPBOUND	@"!@!#xyz!@#!"
#define VIDEOBOUND	@"!@!x#yz!@#!"
#define VOICEBOUND	@"!@!xy#z!@#!"

@interface EntityAdminChatViewController () <IMPhotoPickerControllerDelegate,IMVideoPickerControllerDelegate, UIActionSheetDelegate>
{
    BOOL keyboardShown;
    
    MBProgressHUD *downloadProgressHUD; // Download progress hud for video
    
    NSBubbleContentType longPressedDataType;    // Save the type for long pressed bubble (video, photo, voice)
    NSString *longPressedDataPath;              // Save the data path for long pressed bubble
    IBOutlet UIButton *btDelete;
    
    BOOL isRecording;
}
@end

@implementation EntityAdminChatViewController

@synthesize emojis;
@synthesize boardid;
@synthesize playerVC;
@synthesize reachability;
@synthesize entityID;
@synthesize entityName;
@synthesize navBarColor;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.title = entityName;
    
	bFirstLoad = YES;
	lstMsgId = [[NSMutableArray alloc] init];
    
	bConnection = YES;
    isRecording = NO;
	reachability = [Reachability reachabilityForInternetConnection];
	[reachability startNotifier];
	
	NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"MyAudioMemo.m4a",
                               nil];
    audioURL = [NSURL fileURLWithPathComponents:pathComponents];
    
	// Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
	
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:audioURL settings:recordSetting error:NULL];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
	//
	
	UIButton *_btContact = [UIButton buttonWithType:UIButtonTypeCustom];
	[_btContact setFrame:CGRectMake(0, 0, 44, 28)];
	btContact = [[UIBarButtonItem alloc] initWithCustomView:_btContact];
    if (navBarColor) {
        btBack = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"whiteArrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(btBackClick:)];
        
        btClose = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"Close_wite"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(btCloseClick:)];
        
        btCloseKeyboard = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"Close_wite"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(btCloseChatClick:)];
    }else{
        btBack = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"BackArrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(btBackClick:)];
        
        btClose = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"close"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(btCloseClick:)];
        
        btCloseKeyboard = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"close"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(btCloseChatClick:)];
    }
	
	
	[self.navigationItem setLeftBarButtonItem:btBack];
	[self.navigationItem setRightBarButtonItem:btContact];
    
	UIButton *_btCloseEdit = [UIButton buttonWithType:UIButtonTypeCustom];
	[_btCloseEdit setFrame:CGRectMake(0, 0, 25, 25)];
    if (navBarColor) {
        [_btCloseEdit setImage:[UIImage imageNamed:@"Close_wite"] forState:UIControlStateNormal];
    }else{
        [_btCloseEdit setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    }
	
	[_btCloseEdit addTarget:self action:@selector(btCloseEditClick:) forControlEvents:UIControlEventTouchUpInside];
    
	btCloseEdit = [[UIBarButtonItem alloc] initWithCustomView:_btCloseEdit];
    if (navBarColor) {
	    btClear = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"img_car_white"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(btClearClick:)];
    }else{
        btClear = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"Truck"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(btClearClick:)];
    }   
	
    bubbleData = [NSMutableArray new];
    bubbleTable.bubbleDataSource = self;
    bubbleTable.snapInterval = 120;
    bubbleTable.showAvatars = YES;
    bubbleTable.bubbledelegate = self;
	
	[vwEmoItem setHidden:YES];
	
	[btSend setHidden:YES];
    btSend.enabled = NO;
    btWrite.enabled = NO;
//	[vwEmoticon setHidden:YES];
	[btRecording setHidden:YES];
	
//	vwPhoto = [[UIView alloc] initWithFrame:self.view.frame];
    vwPhoto = [[UIView alloc] initWithFrame:[AppDelegate sharedDelegate].window.bounds];
	imvPhoto = [[UIImageView alloc] initWithFrame:vwPhoto.frame];
	
	[vwPhoto addSubview:imvPhoto];
	[imvPhoto setBackgroundColor:[UIColor blackColor]];
	imvPhoto.contentMode = UIViewContentModeScaleAspectFit;
	
	UIButton *btDone = [UIButton buttonWithType:UIButtonTypeCustom];
	[btDone setTitle:@"Done" forState:UIControlStateNormal];
	[btDone.titleLabel setFont:[UIFont systemFontOfSize:18]];
	[btDone setFrame:CGRectMake(250, 30, 60, 30)];
	[btDone addTarget:self action:@selector(btPhotoDoneClick:) forControlEvents:UIControlEventTouchUpInside];
	[vwPhoto addSubview:btDone];
	
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
	[bubbleTable addGestureRecognizer:tapGesture];
	
	//Read Emoji
	NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"EmojisList"
                                                          ofType:@"plist"];
    emojis = [[NSDictionary dictionaryWithContentsOfFile:plistPath] copy];
	
	[self makeEmoji:0];
	
	__weak EntityAdminChatViewController *weakSelf = self;
    
    // setup pull-to-refresh
    [bubbleTable addPullToRefreshWithActionHandler:^{
        [weakSelf getAllMessages];
    }];
	
	[self outputSoundSpeaker];
	[self getAllMessages];
}

-(void)outputSoundSpeaker
{
	AVAudioSession* audioSession = [AVAudioSession sharedInstance];
	
	UInt32 doChangeDefaultRoute = 1;
	NSError* error4 = nil;
	
	OSStatus status = AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof (doChangeDefaultRoute), &doChangeDefaultRoute);
	if (status != kAudioSessionNoError) {
		NSLog(@"AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers) failed: %d", (int)status);
	}
	
	// Activate the audio session
	error4 = nil;
	if (![audioSession setActive:YES error:&error4]) {
		NSLog(@"AVAudioSession setActive:YES failed: %@", [error4 localizedDescription]);
	}
}

- (void) reachabilityChanged:(NSNotification *)note
{
	Reachability* curReach = [note object];
	NetworkStatus status = [curReach currentReachabilityStatus];
	
	if(status == NotReachable)
	{
		//No internet
		bConnection = NO;
	}
	else if (status == ReachableViaWiFi)
	{
		//WiFi
		if (!bConnection)
		{
			if (![bubbleData count])
			{
				[self getAllMessages];
			}
			else{
                if ([bubbleData count] == 0) {
                    btWrite.enabled = NO;
                }else{
                    btWrite.enabled = YES;
                }
				[bubbleTable reloadData];
			}
			
			bConnection = YES;
		}
	}
	else if (status == ReachableViaWWAN)
	{
		//3G
		if (!bConnection)
		{
			
			if (![bubbleData count])
			{
				[self getAllMessages];
			}
			else{
                if ([bubbleData count] == 0) {
                    btWrite.enabled = NO;
                }else{
                    btWrite.enabled = YES;
                }
				[bubbleTable reloadData];
			}
			
			bConnection = YES;
		}
	}
}

-(void)showAlert:(NSString*)_message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:_message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

-(void)sendMap:(float)flat :(float)flng
{
	[self sendMessage:nil image:nil voice:nil video:nil map:[NSString stringWithFormat:@"%f,%f",flat,flng]];
}

-(void)makeEmoji:(int)nIndex
{
	[btEmoji1 setSelected:NO];
	[btEmoji2 setSelected:NO];
	[btEmoji3 setSelected:NO];
	[btEmoji4 setSelected:NO];
	
	if (nIndex == 0) {
		[btEmoji1 setSelected:YES];
	}else if (nIndex == 1){
		[btEmoji2 setSelected:YES];
	}else if (nIndex == 2){
		[btEmoji3 setSelected:YES];
	}else if (nIndex == 3){
		[btEmoji4 setSelected:YES];
	}
	
	for (UIView *view in scvEmoji.subviews) {
		if ([view isKindOfClass:[UIButton class]]) {
			[view removeFromSuperview];
		}
	}
	
	NSArray *lstArray = [NSArray arrayWithObjects:@"People",@"Nature",@"Places",@"Objects", nil];
	NSArray *lstEmojis = [emojis objectForKey:[lstArray objectAtIndex:nIndex]];
    
	
	
	for (int i = 0; i < [lstEmojis count]; i++) {
		UIButton *btEmoji = [UIButton buttonWithType:UIButtonTypeCustom];
		[btEmoji setTitle:[lstEmojis objectAtIndex:i] forState:UIControlStateNormal];
		btEmoji.titleLabel.font = [UIFont fontWithName:@"Apple color emoji" size:BUTTON_FONT_SIZE];
		btEmoji.frame = CGRectIntegral(CGRectMake([self XMarginForButtonInColumn:i/3],
                                                  [self YMarginForButtonInRow:i%3] + 10,
                                                  BUTTON_WIDTH,
                                                  BUTTON_HEIGHT));
		[btEmoji addTarget:self action:@selector(btEmojiItemClick:) forControlEvents:UIControlEventTouchUpInside];
		
		[scvEmoji addSubview:btEmoji];
	}
	
	int nPageCount = (int)[lstEmojis count] / (EMOJIROW*EMOJICOL);
	if ([lstEmojis count] % (EMOJIROW*EMOJICOL) != 0) {
		nPageCount = nPageCount + 1;
	}
	
	scvEmoji.delegate = self;
	
	[pgCtl setNumberOfPages:nPageCount];
	
	[scvEmoji setContentSize:CGSizeMake(320 * nPageCount, scvEmoji.frame.size.height)];
}

-(IBAction)btEmojiItemClick:(id)sender
{
	[txtMessage setText:[NSString stringWithFormat:@"%@%@",txtMessage.text,[(UIButton*)sender currentTitle]]];
    [self textViewDidChange:txtMessage];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[pgCtl setCurrentPage:scrollView.contentOffset.x / 320];
}

- (CGFloat)XMarginForButtonInColumn:(NSInteger)column {
	CGFloat padding = ((CGRectGetWidth(scvEmoji.bounds) - EMOJICOL * BUTTON_WIDTH) / EMOJICOL);
	return (padding / 2 + column * (padding + BUTTON_WIDTH));
}

- (CGFloat)YMarginForButtonInRow:(NSInteger)rowNumber {
	CGFloat padding = ((CGRectGetHeight(scvEmoji.bounds) - 30 - EMOJIROW * BUTTON_WIDTH) / EMOJIROW);
	return (padding / 2 + rowNumber * (padding + BUTTON_WIDTH));
}

-(void)handleTap
{
    if (btWrite.selected) // no action if editing
        return;
    
	[self.view endEditing:YES];
    [self.navigationItem setRightBarButtonItem:btContact];
	
	if (!vwEmoItem.hidden)
	{
		[vwEmoItem setHidden:YES];
//		[vwEmoticon setHidden:YES];
		
		[btMap setEnabled:YES];
		[btVideo setEnabled:YES];
		[btPhoto setEnabled:YES];
		
		[btSend setHidden:YES];
		[btVoice setHidden:NO];
		
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationCurve:7];
        
        keyboardHeight.constant = 0;
        [self.view layoutIfNeeded];
        
        [UIView commitAnimations];

//		CGRect frame = vwSend.frame;
//		frame.origin.y += 216;
//		vwSend.frame = frame;
//		
//		frame = bubbleTable.frame;
//		frame.size.height += 216;
//		bubbleTable.frame = frame;
		
		[self.navigationItem setRightBarButtonItem:btContact];
	}
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        btSend.enabled = NO;
    }else{
        btSend.enabled = YES;
    }
    [self.navigationItem setRightBarButtonItem:btCloseKeyboard];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@""] && [txtMessage.text isEqualToString:@""]) {
        btSend.enabled = NO;
    }else{
        btSend.enabled = YES;
    }
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView {
    [textView layoutIfNeeded];
    if ([textView.text isEqualToString:@""] && [txtMessage.text isEqualToString:@""])
    {
        btSend.enabled = NO;
    }else{
        btSend.enabled = YES;
    }
    CGFloat height = MIN(MAX(33, ceil(textView.contentSize.height)), 60); // ceil to avoid decimal
    
    if (height != messageHeight.constant) { // set when height changed
        messageHeight.constant = height;
        [txtMessage setContentOffset:CGPointZero animated:NO]; // scroll to top to avoid "wrong contentOffset" artefact when line count changes
        [self.view layoutIfNeeded];
    }
}

-(void)enterBackground
{
	bFirstLoad = YES;
	[self getAllMessages];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
	[AppDelegate sharedDelegate].isChatScreen = YES;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];

    //	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground) name:@"ENTERFROMBACKGROUND" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
	[AppDelegate sharedDelegate].isChatScreen = NO;
	APPDELEGATE.isPlayingAudio = NO;
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    //	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"ENTERFROMBACKGROUND" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
	[self performSelector:@selector(btCloseClick:) withObject:btClose];
	
	[btSend setHidden:NO];
    if ([txtMessage.text isEqualToString:@""]) {
        btSend.enabled = NO;
    }else{
        btSend.enabled = YES;
    }
    
	[btVoice setHidden:YES];
	
    NSDictionary* userInfo = [aNotification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    if(!keyboardShown)
    {
        CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:duration];
        [UIView setAnimationCurve:[userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    }

    keyboardHeight.constant = kbSize.height;
    [self.view layoutIfNeeded];
    
    if(!keyboardShown)
        [UIView commitAnimations];
    
    keyboardShown = YES;
    
    //	CGRect frame = self.view.bounds;
    //    frame.size.height -= CGRectGetHeight(vwSend.frame);
    //	frame.size.height -= kbSize.height;
    //	bubbleTable.frame = frame;
    //
    //    frame = vwSend.frame;
    //    frame.origin.y = CGRectGetMaxY(bubbleTable.frame);
    //    vwSend.frame = frame;
	
	[self scrollToBottom : FALSE];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [self.navigationItem setRightBarButtonItem:btContact];
    keyboardShown = NO;
	[btSend setHidden:YES];
	[btVoice setHidden:NO];
	
    NSDictionary *userInfo = [aNotification userInfo];
    CGFloat duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:[userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    keyboardHeight.constant = 0;
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

-(void)scrollToBottom : (BOOL)_animated
{
	CGFloat yoffset = 0;
	if (bubbleTable.contentSize.height > bubbleTable.bounds.size.height) {
		yoffset = bubbleTable.contentSize.height - bubbleTable.bounds.size.height;
	}
	
	[bubbleTable setContentOffset:CGPointMake(0, yoffset) animated:_animated];
}

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [bubbleData count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [bubbleData objectAtIndex:row];
}

-(IBAction)btEmoji1Click:(id)sender
{
	[self makeEmoji:0];
}

-(IBAction)btEmoji2Click:(id)sender
{
	[self makeEmoji:1];
}

-(IBAction)btEmoji3Click:(id)sender
{
	[self makeEmoji:2];
}

-(IBAction)btEmoji4Click:(id)sender
{
	[self makeEmoji:3];
}

-(IBAction)btBackClick:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
    APPDELEGATE.isPlayingAudio = NO;
    if (isRecording) {
        isRecording = NO;
        [self setEnabledOfSubviewsOfvwSend:YES];
        [recorder stop];
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
        
        [timer invalidate];
        [btWrite setHidden:NO];
        [btRecording setHidden:YES];
        [txtMessage setText:@""];
        [self textViewDidChange:txtMessage];
        nVoiceSec = 0;
    }
}

-(IBAction)btCloseClick:(id)sender
{
	if (vwEmoItem.hidden) {
		return;
	}
	
	[vwEmoItem setHidden:YES];
	// [vwEmoticon setHidden:YES];
	
	[btMap setEnabled:YES];
	[btVideo setEnabled:YES];
	[btPhoto setEnabled:YES];
	
	[btSend setHidden:YES];
	[btVoice setHidden:NO];
    
//	CGRect frame = vwSend.frame;
//	frame.origin.y += 216;
//	vwSend.frame = frame;
//	
//	frame = bubbleTable.frame;
//	frame.size.height += 216;
//	bubbleTable.frame = frame;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationCurve:7];
    
    keyboardHeight.constant = 0;
    [self.view layoutIfNeeded];
    
    [UIView commitAnimations];
	
	[self.navigationItem setRightBarButtonItem:btContact];
}

- (void)btCloseChatClick:(id)sender {
    [txtMessage resignFirstResponder];
    
    [self.navigationItem setRightBarButtonItem:btContact];
}

-(IBAction)btMapClick:(id)sender
{
	YYYLocationController *viewcontroller = [[YYYLocationController alloc] initWithNibName:@"YYYLocationController" bundle:nil];
	viewcontroller.entityChatController = self;
    viewcontroller.navBarColor = navBarColor;
	[self.navigationController presentViewController:viewcontroller animated:YES completion:nil];
}

-(IBAction)btVideoClick:(id)sender
{
    //	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    //	picker.delegate = self;
    //	picker.allowsEditing = YES;
    //	picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //	picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    //	picker.videoMaximumDuration = 30.0f;
    //	isVideo = YES;
    //	[self presentViewController:picker animated:YES completion:NULL];
	
	[self.view endEditing:YES];
    [self.navigationItem setRightBarButtonItem:btContact];
	
	IMVideoPickerController *viewController = [[IMVideoPickerController alloc] initWithType];
    viewController.pickerDelegate = self;
    viewController.navBarColor = navBarColor;
	[self presentViewController:viewController animated:NO completion:nil];
}

-(IBAction)btPhotoClick:(id)sender
{
	[self.view endEditing:YES];
    [self.navigationItem setRightBarButtonItem:btContact];
	
	IMPhotoPickerController *viewController = [[IMPhotoPickerController alloc] initWithType];
	viewController.pickerDelegate = self;
	[self presentViewController:viewController animated:NO completion:nil];
}

-(void)IMphotoPickerController:(IMPhotoPickerController *)pickerController didSelectBackground:(UIImage *)background avatar:(UIImage *)avatar
{
	[pickerController dismissViewControllerAnimated:NO completion:^{
		[self sendMessage:nil image:UIImageJPEGRepresentation(background,0.2f) voice:nil video:nil map:nil];
    }];
}

-(void)IMphotoPickerControllerDidCancel:(IMPhotoPickerController *)pickerController
{
	[pickerController dismissViewControllerAnimated:NO completion:^{
	    
    }];
}

- (void)videoPickerController:(IMVideoPickerController *)pickerController didSelectVideo:(NSURL *)videoURL
{
	[pickerController dismissViewControllerAnimated:NO completion:^{
		NSArray *pathComponents = [NSArray arrayWithObjects:
								   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
								   @"ZipedVideo.mp4",
								   nil];
		NSURL *outputURL = [NSURL fileURLWithPathComponents:pathComponents];
		
		MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[AppDelegate sharedDelegate].window animated:YES];
		[hud setLabelText:@"Sending..."];
		
		[self convertVideoToLowQuailtyWithInputURL:videoURL outputURL:outputURL handler:^(AVAssetExportSession *exportSession)
		 {
			 if (exportSession.status == AVAssetExportSessionStatusCompleted)
			 {
				 printf("completed\n");
				 NSData *videoData = [NSData dataWithContentsOfURL:outputURL];
				 thumbnail = UIImageJPEGRepresentation([self generateThumbImage:outputURL], 0.3);
				 [self sendMessage:nil image:nil voice:nil video:videoData map:nil];
			 }
			 else
			 {
				 [MBProgressHUD hideAllHUDsForView:[AppDelegate sharedDelegate].window animated:YES];
				 printf("error\n");
				 [self showAlert:@"Oops! Error occurred while compressing video file."];
			 }
		 }];
    }];
}

- (void)videoPickerControllerDidCancel:(IMVideoPickerController *)pickerController
{
	[pickerController dismissViewControllerAnimated:NO completion:^{
        
    }];
}


- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	if (isVideo)
	{
		[viewController.navigationItem setTitle:@"Videos"];
	}
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
	
	if (isVideo)
	{
        //		NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        //		NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
		
		isVideo = FALSE;
		
		NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
		NSArray *pathComponents = [NSArray arrayWithObjects:
								   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
								   @"ZipedVideo.mp4",
								   nil];
		NSURL *outputURL = [NSURL fileURLWithPathComponents:pathComponents];
        
		[self convertVideoToLowQuailtyWithInputURL:videoURL outputURL:outputURL handler:^(AVAssetExportSession *exportSession)
		 {
			 if (exportSession.status == AVAssetExportSessionStatusCompleted)
			 {
				 printf("completed\n");
				 NSData *videoData = [NSData dataWithContentsOfURL:outputURL];
				 thumbnail = UIImageJPEGRepresentation([self generateThumbImage:outputURL], 0.3);
				 [self sendMessage:nil image:nil voice:nil video:videoData map:nil];
			 }
			 else
			 {
				 printf("error\n");
				 [self showAlert:@"Oops! Error occurred while compressing video file."];
			 }
		 }];
        
	}
	else
	{
        
		[self sendMessage:nil image:UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerEditedImage],1.0f) voice:nil video:nil map:nil];
	}
	
	[picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL
                                   outputURL:(NSURL*)outputURL
                                     handler:(void (^)(AVAssetExportSession*))handler
{
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
//    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.outputURL = outputURL;
//    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
	 {
		 handler(exportSession);
	 }];
}

-(IBAction)btEmoticonClick:(id)sender
{
	if (!vwEmoItem.hidden) {
		return;
	}
	
	[txtMessage resignFirstResponder];
	
	// [vwEmoticon setHidden:NO];
	[vwEmoItem setHidden:NO];
	
	[btMap setEnabled:NO];
	[btVideo setEnabled:NO];
	[btPhoto setEnabled:NO];
	
	[btSend setHidden:NO];
	[btVoice setHidden:YES];
	
//	CGRect frame = vwSend.frame;
//	frame.origin.y -= 216;
//	vwSend.frame = frame;
//	
//	frame = bubbleTable.frame;
//	frame.size.height -= 216;
//	bubbleTable.frame = frame;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationCurve:7];
    keyboardHeight.constant = 216;
    [self.view layoutIfNeeded];

	[self scrollToBottom : NO];
    
    [UIView commitAnimations];
    
	[self.navigationItem setRightBarButtonItem:btClose];
}

-(IBAction)btWriteClick:(id)sender
{
	//Edit
	[self btCloseClick:self];  // Close Emoticon view if shown

    [self btCloseChatClick:self]; // Close keyboard if shown
	
	if (btWrite.selected)
	{
		[btWrite setSelected:NO];
		bubbleTable.bEdit = NO;
		[bubbleTable.lstSelected removeAllObjects];
		[vwTrash setHidden:YES];
        [vwSend setHidden:NO];
		
		[self.navigationItem setLeftBarButtonItem:btBack];
		[self.navigationItem setRightBarButtonItem:btContact];
	}
	else
	{
        //[txtMessage setText:@""];
        //[self textViewDidChange:txtMessage];
        
        APPDELEGATE.isPlayingAudio = NO;
		[btWrite setSelected:YES];
		[btWrite setHidden:YES];
		bubbleTable.bEdit = YES;
		[vwTrash setHidden:NO];
        [vwSend setHidden:YES];
		
		[self.navigationItem setLeftBarButtonItem:btClear];
		[self.navigationItem setRightBarButtonItem:btCloseEdit];
	}
    if ([bubbleData count] == 0) {
        btWrite.enabled = NO;
    }else{
        btWrite.enabled = YES;
    }
	[bubbleTable reloadData];
}

-(IBAction)btCloseEditClick:(id)sender
{
	[btWrite setSelected:NO];
	[btWrite setHidden:NO];
	bubbleTable.bEdit = NO;
	[bubbleTable.lstSelected removeAllObjects];
    
    if ([bubbleData count] == 0) {
        btWrite.enabled = NO;
    }else {
        btWrite.enabled = YES;
    }
    
	[bubbleTable reloadData];
	[vwTrash setHidden:YES];
    
    [vwSend setHidden:NO];
	
    btDelete.enabled = bubbleTable.lstSelected.count;
    
	[self.navigationItem setLeftBarButtonItem:btBack];
	[self.navigationItem setRightBarButtonItem:btContact];
}

-(IBAction)btClearClick:(id)sender
{
    
    APPDELEGATE.isPlayingAudio = NO;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Do you want to delete all the messages?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
	alert.tag = 1000;
	[alert show];
}

-(IBAction)btDeleteClick:(id)sender
{
	if ([bubbleTable.lstSelected count] == 0) {
		return;
	}
    NSString * messageAlert = @"";
    if ([bubbleTable.lstSelected count] == 1) {
        messageAlert = @"Do you want to delete the selected message?";
    }else{
        messageAlert = @"Do you want to delete the selected messages?";
    }
    APPDELEGATE.isPlayingAudio = NO;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:messageAlert delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    alert.tag = 1001;
    [alert show];
}

-(IBAction)btVoiceStart:(id)sender
{
    [self setEnabledOfSubviewsOfvwSend:NO];
    APPDELEGATE.isPlayingAudio = NO;
    bubbleTable.userInteractionEnabled = NO;
    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            if (!granted) {
                [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your microphone is disabled.\nPlease go to settings and grant access to microphone."];
                [self setEnabledOfSubviewsOfvwSend:YES];
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    AVAudioSession *session = [AVAudioSession sharedInstance];
                    [session setActive:YES error:nil];
                    
                    // Start recording
                    [recorder record];
                    isRecording = YES;
                    [self timer];
                    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timer) userInfo:nil repeats:YES];
                    [btWrite setHidden:YES];
                    [btRecording setHidden:NO];
                });
            }
        }];
    }
	
}

-(IBAction)btVoiceSend:(id)sender
{
    isRecording = NO;
    [self setEnabledOfSubviewsOfvwSend:YES];
    bubbleTable.userInteractionEnabled = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [recorder stop];
        [timer invalidate];
        timer = nil;
        
        if(nVoiceSec < 2)
        {
            nVoiceSec = 0;
            [btWrite setHidden:NO];
            [btRecording setHidden:YES];
            [txtMessage setText:@""];
            [self textViewDidChange:txtMessage];
            return;
        }
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Do you want to send your voice message?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        [alert show];
    });
}
- (void)setEnabledOfSubviewsOfvwSend:(BOOL)enabled {
    for (UIView *view in vwSend.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            ((UIButton*)view).enabled = enabled;
        }
    }
    if ([bubbleData count] == 0) {
        btWrite.enabled = NO;
    }else {
        btWrite.enabled = YES;
    }
    
    txtMessage.userInteractionEnabled = enabled;
}
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == 1000)
	{
		if (buttonIndex == 0)
		{
			void ( ^successed )( id _responseObject ) = ^( id _responseObject )
			{
				
				if ([[_responseObject objectForKey:@"success"] boolValue])
				{
					[bubbleData removeAllObjects];
					
					[btWrite setSelected:NO];
					[btWrite setHidden:NO];
                    btWrite.enabled = NO;
					bubbleTable.bEdit = NO;
					[bubbleTable.lstSelected removeAllObjects];
					[bubbleTable reloadData];
                    [vwTrash setHidden:YES];
                    
                    [vwSend setHidden:NO];
                    
                    btDelete.enabled = NO;
					
					[self.navigationItem setLeftBarButtonItem:btBack];
					[self.navigationItem setRightBarButtonItem:btContact];
				}
			} ;
			
			void ( ^failure )( NSError* _error ) = ^( NSError* _error )
			{
				
			} ;
            [[YYYCommunication sharedManager] ClearEntityMessage:[AppDelegate sharedDelegate].sessionId entityId:entityID successed:successed failure:failure];
		}
	}
    else if(alertView.tag == 1001) {
        if(buttonIndex == alertView.cancelButtonIndex) {
            NSString *msgIds = @"";
            for (int i = 0; i < [bubbleTable.lstSelected count]; i++) {
                msgIds = [NSString stringWithFormat:@"%@,%@",msgIds,[bubbleTable.lstSelected objectAtIndex:i]];
            }
            
            msgIds = [msgIds substringFromIndex:1];
            
            
            //	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
                
                //		[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                
                if ([[_responseObject objectForKey:@"success"] boolValue])
                {
                    NSMutableArray *newBubbleData = [[NSMutableArray alloc] init];
                    
                    for (NSBubbleData *data in bubbleData)
                    {
                        if (![bubbleTable.lstSelected containsObject:data.msg_id])
                        {
                            [newBubbleData addObject:data];
                        }
                    }
                    
                    bubbleData = [[NSMutableArray alloc] initWithArray:newBubbleData];
                    
                    if (bubbleData.count == 0) {
                        [btWrite setSelected:NO];
                        [btWrite setHidden:NO];
                        bubbleTable.bEdit = NO;
                        [bubbleTable.lstSelected removeAllObjects];
                        [bubbleTable reloadData];
                        [vwTrash setHidden:YES];
                        [vwSend setHidden:NO];
                        
                        btDelete.enabled = NO;
                        btWrite.enabled = NO;
                        [self.navigationItem setLeftBarButtonItem:btBack];
                        [self.navigationItem setRightBarButtonItem:btContact];
                    }
                    
                    
                    [bubbleTable reloadData];
                    
                    btDelete.enabled = NO;
                    
                    [[LocalDBManager sharedManager] deleteSelectedMessages:bubbleTable.lstSelected];
                    [bubbleTable.lstSelected removeAllObjects];                }
            } ;
            
            void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
                
                //        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
                
            } ;
            
            //	[[YYYCommunication sharedManager] DeleteMessages:[[YYYCommunication sharedManager].me objectForKey:@"sessionId"]
            //											 boardid:boardid
            //										  messageids:msgIds
            //										   successed:successed
            //											 failure:failure];
            [[YYYCommunication sharedManager] DeleteEntityMessages:[AppDelegate sharedDelegate].sessionId entityid:entityID messageids:msgIds successed:successed failure:failure];
        }
    }
	else
	{
		nVoiceSec = 0;
		[timer invalidate];
		[btWrite setHidden:NO];
		[btRecording setHidden:YES];
		[txtMessage setText:@""];
		[self textViewDidChange:txtMessage];
		if (buttonIndex == 0)
		{
			[self sendMessage:nil image:nil voice:[NSData dataWithContentsOfURL:audioURL] video:nil map:nil];
		}
	}
}

-(IBAction)btVoiceCancel:(id)sender
{
    isRecording = NO;
    [self setEnabledOfSubviewsOfvwSend:YES];
	[recorder stop];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
	
	[timer invalidate];
	[btWrite setHidden:NO];
	[btRecording setHidden:YES];
	[txtMessage setText:@""];
    [self textViewDidChange:txtMessage];
	nVoiceSec = 0;
}

- (IBAction)btVoiceTouchCancel:(id)sender {
    [self setEnabledOfSubviewsOfvwSend:YES];
    [recorder stop];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    
    [timer invalidate];
    [btWrite setHidden:NO];
    [btRecording setHidden:YES];
    [txtMessage setText:@""];
    [self textViewDidChange:txtMessage];
    nVoiceSec = 0;
}

-(void)timer
{
	[txtMessage setText:[NSString stringWithFormat:@"%.2d:%.2d          Slide to Cancel <",nVoiceSec/60,nVoiceSec%60]];
    [self textViewDidChange:txtMessage];
	nVoiceSec++;
    //	[self performSelector:@selector(timer) withObject:nil afterDelay:1];
}

-(IBAction)btSendClick:(id)sender
{
	if (!txtMessage.text.length) {
		return;
	}
	
	[self sendMessage:txtMessage.text image:nil voice:nil video:nil map:nil];
}

-(void)getAllMessages
{
	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
		
		[bubbleTable.pullToRefreshView stopAnimating];
		
		if ([[_responseObject objectForKey:@"success"] boolValue])
		{
			[bubbleData removeAllObjects];
			
			[lstMsgId removeAllObjects];
			
			for (NSDictionary *dict in [[_responseObject objectForKey:@"data"] objectForKey:@"data"])
			{
				NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
				[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
				[formatter setTimeZone :[NSTimeZone timeZoneForSecondsFromGMT: 0]];
				NSDate *utcdate = [formatter dateFromString:[NSString stringWithFormat:@"%@",[dict objectForKey:@"sent_time"]]];
				
				[formatter setTimeZone:[NSTimeZone localTimeZone]];
				NSDate *localdate = [formatter dateFromString:[formatter stringFromDate:utcdate]];
				
				[lstMsgId addObject:[dict objectForKey:@"msg_id"]];
                
//                if ([[dict objectForKey:@"msgType"] intValue] == 1)
                if (![[[dict objectForKey:@"content"] substringToIndex:1] isEqualToString:@"{"])
                {
                    if ([[dict objectForKey:@"content"] rangeOfString:MAPBOUND].location == 0) {
                        
                        NSBubbleData *sayBubble = [NSBubbleData dataWithMap:[[dict objectForKey:@"content"] substringFromIndex:MAPBOUND.length] date:localdate type:BubbleTypeMine];
                        sayBubble.delegate = self;
                        sayBubble.msg_id = [NSString stringWithFormat:@"%@",[dict objectForKey:@"msg_id"]];
                        sayBubble.msg_userid = entityID;
                        sayBubble.msg_entityname = entityName;
                        [bubbleData addObject:sayBubble];
                    }
                    else
                    {
                        NSBubbleData *sayBubble = [NSBubbleData dataWithText:[dict objectForKey:@"content"] date:localdate type:BubbleTypeMine];
                        sayBubble.msg_id = [NSString stringWithFormat:@"%@",[dict objectForKey:@"msg_id"]];
                        sayBubble.msg_userid = entityID;
                        sayBubble.msg_entityname = entityName;
                        [bubbleData addObject:sayBubble];
                    }
                }
                else
                {
                    NSString *content = [dict objectForKey:@"content"];
                    id jsonData = [content dataUsingEncoding:NSUTF8StringEncoding]; //if input is NSString
                    id dictMsg = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
                    
                    if([[dictMsg objectForKey:@"file_type"] isEqualToString:@"photo"])
                    {
                        NSBubbleData *sayBubble = [NSBubbleData dataWithImage:[dictMsg objectForKey:@"url"] date:localdate type:BubbleTypeMine];
                        sayBubble.msg_id = [NSString stringWithFormat:@"%@",[dict objectForKey:@"msg_id"]];
                        sayBubble.msg_userid = entityID;
                        sayBubble.msg_entityname = entityName;
                        sayBubble.delegate = self;
                        [bubbleData addObject:sayBubble];
                    }
                    else if ([[dictMsg objectForKey:@"file_type"] isEqualToString:@"voice"])
                    {
                        NSBubbleData *sayBubble = [NSBubbleData dataWithAudio:[dictMsg objectForKey:@"url"] date:localdate type:BubbleTypeMine];
                        sayBubble.msg_id = [NSString stringWithFormat:@"%@",[dict objectForKey:@"msg_id"]];
                        sayBubble.msg_userid = entityID;
                        sayBubble.msg_entityname = entityName;
                        sayBubble.delegate = self;
                        [bubbleData addObject:sayBubble];
                    }
                    else if ([[dictMsg objectForKey:@"file_type"] isEqualToString:@"video"])
                    {
                        NSBubbleData *sayBubble = [NSBubbleData dataWithVideo:[dictMsg objectForKey:@"url"] thumb:[dictMsg objectForKey:@"thumnail_url"] date:localdate type:BubbleTypeMine];
                        sayBubble.msg_id = [NSString stringWithFormat:@"%@",[dict objectForKey:@"msg_id"]];
                        sayBubble.msg_userid = entityID;
                        sayBubble.msg_entityname = entityName;
                        sayBubble.delegate = self;
                        [bubbleData addObject:sayBubble];
                    }
                }
			}
			
            if ([bubbleData count] == 0) {
                btWrite.enabled = NO;
            }else{
                btWrite.enabled = YES;
            }
			[bubbleTable reloadData];
			
			if (bFirstLoad)
			{
				[self scrollToBottom : YES];
				bFirstLoad = NO;
			}
		}
    } ;
    
	void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        
		[MBProgressHUD hideHUDForView:self.view animated:YES];
		[bubbleTable.pullToRefreshView stopAnimating];
		
    } ;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[YYYCommunication sharedManager] getAllEntityMessages:[AppDelegate sharedDelegate].sessionId entityid:entityID pageNum:[NSString stringWithFormat:@"%lu",[bubbleData count] + 10] countPerPage:nil successed:successed failure:failure];
}

-(void)checkAction:(NSString *)msgid :(int)status
{
    btDelete.enabled = bubbleTable.lstSelected.count;
}

-(void)sendMessage:(NSString*)text image:(NSData*)image voice:(NSData*)voice video:(NSData*)video map:(NSString*)map
{
	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
		
        [ MBProgressHUD hideHUDForView : [AppDelegate sharedDelegate].window animated : YES ] ;
		[btSend setUserInteractionEnabled:YES];
		[txtMessage setText:@""];
        [self textViewDidChange:txtMessage];
		
		if ([[_responseObject objectForKey:@"success"] boolValue])
		{
            NSDictionary *dict = [_responseObject objectForKey:@"data"];
            
            
			if ([dict objectForKey:@"msg_id"])
			{
				[lstMsgId addObject:[dict objectForKey:@"msg_id"]];
			}
			
            btWrite.enabled = YES;
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            [formatter setTimeZone :[NSTimeZone timeZoneForSecondsFromGMT: 0]];
            NSDate *utcdate;
            if([[dict objectForKey:@"file_type"] isEqualToString:@"photo"] || [[dict objectForKey:@"file_type"] isEqualToString:@"video"] || [[dict objectForKey:@"file_type"] isEqualToString:@"voice"])
            {
                utcdate = [formatter dateFromString:[NSString stringWithFormat:@"%@",[dict objectForKey:@"send_time"]]];
            }else{
                utcdate = [formatter dateFromString:[NSString stringWithFormat:@"%@",[dict objectForKey:@"sent_time"]]];
            }
            [formatter setTimeZone:[NSTimeZone localTimeZone]];
            NSDate *localdate1 = [formatter dateFromString:[formatter stringFromDate:utcdate]];
            
			if([[dict objectForKey:@"file_type"] isEqualToString:@"photo"])
			{
				NSBubbleData *sayBubble = [NSBubbleData dataWithImage:[dict objectForKey:@"url"] date:localdate1 type:BubbleTypeMine];
				sayBubble.delegate = self;
				sayBubble.msg_id = [NSString stringWithFormat:@"%@",[dict objectForKey:@"msg_id"]];
                sayBubble.msg_userid = entityID;
                sayBubble.msg_entityname = entityName;
				[bubbleData addObject:sayBubble];
			}
			else if([[dict objectForKey:@"file_type"] isEqualToString:@"voice"])
			{
				NSBubbleData *sayBubble = [NSBubbleData dataWithAudio:[dict objectForKey:@"url"] date:localdate1 type:BubbleTypeMine];
                sayBubble.delegate = self;
				sayBubble.msg_id = [NSString stringWithFormat:@"%@",[dict objectForKey:@"msg_id"]];
				sayBubble.msg_userid = entityID;
                sayBubble.msg_entityname = entityName;
				[bubbleData addObject:sayBubble];
			}
			else if([[dict objectForKey:@"file_type"] isEqualToString:@"video"])
			{
				NSLog(@"%@",dict);
				NSBubbleData *sayBubble = [NSBubbleData dataWithVideo:[dict objectForKey:@"url"] thumb:[dict objectForKey:@"thumnail_url"] date:localdate1 type:BubbleTypeMine];
				sayBubble.delegate = self;
				sayBubble.msg_id = [NSString stringWithFormat:@"%@",[dict objectForKey:@"msg_id"]];
				sayBubble.msg_userid = entityID;
                sayBubble.msg_entityname = entityName;
				[bubbleData addObject:sayBubble];
			}
			else
			{
				if (text)
				{
					NSBubbleData *sayBubble = [NSBubbleData dataWithText:text date:localdate1 type:BubbleTypeMine];
					sayBubble.msg_id = [NSString stringWithFormat:@"%@",[dict objectForKey:@"msg_id"]];
					sayBubble.msg_userid = entityID;
                    sayBubble.msg_entityname = entityName;
					[bubbleData addObject:sayBubble];
				}
				else
				{
					NSBubbleData *sayBubble = [NSBubbleData dataWithMap:map date:localdate1 type:BubbleTypeMine];
					sayBubble.msg_id = [NSString stringWithFormat:@"%@",[dict objectForKey:@"msg_id"]];
					sayBubble.msg_userid = entityID;
                    sayBubble.msg_entityname = entityName;
					[bubbleData addObject:sayBubble];
				}
			}
            if ([bubbleData count] == 0) {
                btWrite.enabled = NO;
            }else{
                btWrite.enabled = YES;
            }
			[bubbleTable reloadData];
            
			[self scrollToBottom:YES];
		} else {
            NSDictionary *dictError = [_responseObject objectForKey:@"err"];
            if (dictError) {
                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:[dictError objectForKey:@"errMsg"]];
            } else {
                [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Failed to connect to server!"];
            }
        }
    };
	
	void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
		
		[btSend setUserInteractionEnabled:YES];
		[txtMessage setText:@""];
        [self textViewDidChange:txtMessage];
        [ MBProgressHUD hideHUDForView : [AppDelegate sharedDelegate].window animated : YES ] ;
        [ self  showAlert: @"Internet Connection Error!" ] ;
		
    } ;
	
	//082e5f286fb2
	
	if (text)
	{
		[btSend setUserInteractionEnabled:NO];

        [[YYYCommunication sharedManager] SendEntityMessage:[AppDelegate sharedDelegate].sessionId entityid:entityID content:text successed:successed failure:failure];
	}
	else if (map)
	{
//		[[YYYCommunication sharedManager] SendMessage:[[YYYCommunication sharedManager].me objectForKey:@"sessionId"] board_id:boardid message:[NSString stringWithFormat:@"%@%@",MAPBOUND,map] successed:successed failure:nil];
        [[YYYCommunication sharedManager] SendEntityMessage:[AppDelegate sharedDelegate].sessionId entityid:entityID content:[NSString stringWithFormat:@"%@%@",MAPBOUND,map] successed:successed failure:failure];
	}
	else if(image)
	{
//		[[YYYCommunication sharedManager] SendFile:[[YYYCommunication sharedManager].me objectForKey:@"sessionId"] data:image thumbnail:nil name:@"file" mimetype:@"image/jpeg" boardid:boardid successed:successed failure:nil];
        [[YYYCommunication sharedManager] SendEntityFile:[AppDelegate sharedDelegate].sessionId entityid:entityID data:image thumbnail:nil name:@"file" mimetype:@"image/jpeg" successed:successed failure:failure];
	}
	else if(voice)
	{
//		[[YYYCommunication sharedManager] SendFile:[[YYYCommunication sharedManager].me objectForKey:@"sessionId"] data:voice thumbnail:nil name:@"file" mimetype:@"audio/aac" boardid:boardid successed:successed failure:nil];
        [ MBProgressHUD showHUDAddedTo: [AppDelegate sharedDelegate].window animated : YES ] ;
        [[YYYCommunication sharedManager] SendEntityFile:[AppDelegate sharedDelegate].sessionId entityid:entityID data:voice thumbnail:nil name:@"file" mimetype:@"audio/aac" successed:successed failure:failure];
	}
	else if(video)
	{
//		[[YYYCommunication sharedManager] SendFile:[[YYYCommunication sharedManager].me objectForKey:@"sessionId"] data:video thumbnail:thumbnail name:@"file" mimetype:@"video/quicktime" boardid:boardid successed:successed failure:nil];
        [[YYYCommunication sharedManager] SendEntityFile:[AppDelegate sharedDelegate].sessionId entityid:entityID data:video thumbnail:thumbnail name:@"file" mimetype:@"video/quicktime" successed:successed failure:failure];
	}
}

-(UIImage *)generateThumbImage : (NSURL *)url
{
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime time = [asset duration];
    time.value = 0;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *_thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
	
//	if ([AppDelegate sharedDelegate].bCamera)
//		_thumbnail = [UIImage imageWithCGImage:_thumbnail.CGImage scale:_thumbnail.scale orientation:UIImageOrientationLeft];
    
	return _thumbnail;
}

-(void)profileAction:(NSString *)userid
{

}

-(void)videoTouched:(NSString *)videoPath
{
    // Check cache first
    NSString *cachedPath = [LocalDBManager checkCachedFileExist:videoPath];
    
    if (cachedPath) {
        // load from cache
        [self playVideoAtLocalPath:cachedPath];
    } else {
        // save to temp directory
        NSURL *url = [NSURL URLWithString:videoPath];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
        NSProgress *progress;
        
        downloadProgressHUD = [MBProgressHUD showHUDAddedTo:[AppDelegate sharedDelegate].window animated:YES];
        downloadProgressHUD.mode = MBProgressHUDModeDeterminate;
        
        NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            return [NSURL fileURLWithPath:[LocalDBManager getCachedFileNameFromRemotePath:videoPath]];
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            [progress removeObserver:self forKeyPath:@"fractionCompleted" context:NULL];
            [downloadProgressHUD hide:YES];
            if (!error) {
                [self playVideoAtLocalPath:[LocalDBManager getCachedFileNameFromRemotePath:videoPath]];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not download video, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }];
        
        [downloadTask resume];
        [progress addObserver:self
                   forKeyPath:@"fractionCompleted"
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
        
        //        data = [NSData dataWithContentsOfURL:[NSURL URLWithString:audioUrl]];
        //        [data writeToFile:[LocalDBManager getCachedFileNameFromRemotePath:audioUrl] atomically:YES];
    }
}

- (void)playVideoAtLocalPath:(NSString *)videoPath {
    playerVC = [[MPMoviePlayerViewController alloc] init];
    
    playerVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    playerVC.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
    playerVC.moviePlayer.contentURL = [NSURL fileURLWithPath:videoPath];
    
    [self presentMoviePlayerViewControllerAnimated:playerVC];
}

- (void)shareWithPath:(NSString *)videoPath {
    NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
    NSArray* dataToShare = @[SHARE_MAIL_TEXT, videoURL];
    UIActivityViewController* activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:dataToShare
                                      applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

-(void)movieFinishedCallback:(NSNotification*)aNotification
{
	// Obtain the reason why the movie playback finished
    NSNumber *finishReason = [[aNotification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
	
    // Dismiss the view controller ONLY when the reason is not "playback ended"
    if ([finishReason intValue] != MPMovieFinishReasonPlaybackEnded)
    {
        MPMoviePlayerController *moviePlayer = [aNotification object];
		
        // Remove this class from the observers
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:MPMoviePlayerPlaybackDidFinishNotification
                                                      object:moviePlayer];
		[moviePlayer.view removeFromSuperview];
	}
}

-(IBAction)btPhotoDoneClick:(id)sender
{
	[imvPhoto setImage:nil];
	[vwPhoto removeFromSuperview];
}

#pragma mark - NSBubbleDataDelegate
-(void)mapTouched:(float)latitude :(float)longitude
{
    
    APPDELEGATE.isPlayingAudio = NO;
    if (!bConnection) {
        [self showAlert:@"Internet Connection Error"];
        return;
    }
    
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    CLLocation *newLocation = [[CLLocation alloc]initWithLatitude:latitude
                                                        longitude:longitude];
    
    [geocoder reverseGeocodeLocation:newLocation
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       
                       if (error) {
                           [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Internet Connection Error!"];
                           return;
                       }
                       
                       if (placemarks && placemarks.count > 0)
                       {
                           CLPlacemark *placemark = placemarks[0];
                           
                           NSDictionary *addressDictionary =
                           placemark.addressDictionary;
                           
                           NSString *address = [addressDictionary
                                                objectForKey:(NSString *)kABPersonAddressStreetKey];
                           NSString *city = [addressDictionary
                                             objectForKey:(NSString *)kABPersonAddressCityKey];
                           NSString *state = [addressDictionary
                                              objectForKey:(NSString *)kABPersonAddressStateKey];
                           NSString *zip = [addressDictionary
                                            objectForKey:(NSString *)kABPersonAddressZIPKey];
                           
                           if (!address) address = @"";
                           if (!city) city = @"";
                           if (!state) state = @"";
                           if (!zip) zip = @"";
                           
                           MKPlacemark *place = [[MKPlacemark alloc]
                                                 initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude)
                                                 addressDictionary:nil];
                           
                           MKMapItem *mapItem = [[MKMapItem alloc]initWithPlacemark:place];
                           [mapItem setName: [NSString stringWithFormat:@"%@ %@ %@ %@", address,city, state, zip]];
                           [mapItem openInMapsWithLaunchOptions:nil];
                       }
                       
                   }];
    
    
    
    
    //	[SVGeocoder reverseGeocode:CLLocationCoordinate2DMake(latitude, longitude)
    //                    completion:^(NSArray *placemarks, NSHTTPURLResponse *urlResponse, NSError *error)
    //	 {
    //		 if (!error)
    //		 {
    //			 MKPlacemark *place = [[MKPlacemark alloc]
    //								   initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude)
    //								   addressDictionary:nil];
    //
    //			 MKMapItem *mapItem = [[MKMapItem alloc]initWithPlacemark:place];
    //			 [mapItem setName:[NSString stringWithFormat:@"%@",[(SVPlacemark*)[placemarks objectAtIndex:0] formattedAddress]]];
    //			 [mapItem openInMapsWithLaunchOptions:nil];
    //		 }
    //		 else
    //		 {
    //			 NSLog(@"%@",[error description]);
    //		 }
    //	 }];
}

- (void)videoLongPressed:(NSString *)videoPath {
    APPDELEGATE.isPlayingAudio = NO;
    longPressedDataType = NSBubbleContentTypeVideo;
    longPressedDataPath = videoPath;
    [self.view endEditing:YES];
    [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share", nil] showInView:self.navigationController.view];
}

- (void)voiceLongPressed:(NSString *)audioPath {
    
    APPDELEGATE.isPlayingAudio = NO;
    longPressedDataType = NSBubbleContentTypeVoice;
    longPressedDataPath = audioPath;
    [self.view endEditing:YES];
    [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share", nil] showInView:self.navigationController.view];
}

- (void)photoLongPressed:(NSString *)photoPath {
    longPressedDataType = NSBubbleContentTypePhoto;
    longPressedDataPath = photoPath;
    
    APPDELEGATE.isPlayingAudio = NO;
    [self.view endEditing:YES];
    [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share", nil] showInView:self.navigationController.view];
}

-(void)imageTouched:(NSString *)imageurl
{
    
    APPDELEGATE.isPlayingAudio = NO;
    [self.view endEditing:YES];
//    [self.navigationItem setRightBarButtonItem:btContact];
	[imvPhoto setImageWithURL:[NSURL URLWithString:imageurl]];
	[[AppDelegate sharedDelegate].window addSubview:vwPhoto];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Download progress
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"fractionCompleted"]) {
        NSProgress *progress = (NSProgress *)object;
        NSLog(@"Progress… %f", progress.fractionCompleted);
        downloadProgressHUD.progress = progress.fractionCompleted;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        switch (longPressedDataType) {
            case NSBubbleContentTypeVideo:
            {
                // Check cache first
                NSString *cachedPath = [LocalDBManager checkCachedFileExist:longPressedDataPath];
                
                if (cachedPath) {
                    // load from cache
                    [self shareWithPath:cachedPath];
                } else {
                    // save to temp directory
                    NSURL *url = [NSURL URLWithString:longPressedDataPath];
                    NSURLRequest *request = [NSURLRequest requestWithURL:url];
                    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
                    NSProgress *progress;
                    
                    downloadProgressHUD = [MBProgressHUD showHUDAddedTo:[AppDelegate sharedDelegate].window animated:YES];
                    downloadProgressHUD.mode = MBProgressHUDModeDeterminate;
                    
                    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                        return [NSURL fileURLWithPath:[LocalDBManager getCachedFileNameFromRemotePath:longPressedDataPath]];
                    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                        [progress removeObserver:self forKeyPath:@"fractionCompleted" context:NULL];
                        [downloadProgressHUD hide:YES];
                        if (!error) {
                            [self shareWithPath:[LocalDBManager getCachedFileNameFromRemotePath:longPressedDataPath]];
                        } else {
                            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not download video, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                        }
                    }];
                    
                    [downloadTask resume];
                    [progress addObserver:self
                               forKeyPath:@"fractionCompleted"
                                  options:NSKeyValueObservingOptionNew
                                  context:NULL];
                    
                    //        data = [NSData dataWithContentsOfURL:[NSURL URLWithString:audioUrl]];
                    //        [data writeToFile:[LocalDBManager getCachedFileNameFromRemotePath:audioUrl] atomically:YES];
                }
            }
                break;
                
            case NSBubbleContentTypeVoice:
            {
                NSString *cachedPath = [LocalDBManager checkCachedFileExist:longPressedDataPath];
                
                if (cachedPath) {
                    // load from cache
                    [self shareWithPath:cachedPath];
                }
            }
                break;
                
            case NSBubbleContentTypePhoto:
            {
                NSString *cachedPath = [LocalDBManager checkCachedFileExist:longPressedDataPath];
                
                if (cachedPath) {
                    // load from cache
                    [self shareWithPath:cachedPath];
                }
            }
                break;
                
            default:
                break;
        }
    }
}

@end

