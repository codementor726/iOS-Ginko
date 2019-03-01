//
//  ChatViewController.m
//  Ginko
//
//  Created by Mobile on 4/6/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import "ChatViewController.h"
#import "UIImageView+AFNetworking.h"
#import "YYYSelectContactController.h"
#import "YYYChatViewController.h"
#import "YYYCommunication.h"
#import "MBProgressHUD.h"
#import "SVPullToRefresh.h"
#import "AppDelegate.h"
#import "OpenUDID.h"

#import <MediaPlayer/MediaPlayer.h>
#import <AddressBook/AddressBook.h>
#import "EntityChatDetailViewController.h"
#import "EntityChatWallViewController.h"
#import "MainEntityViewController.h"

#import "EntityViewController.h"
#import "LocalDBManager.h"

#define MAPBOUND	@"!@!#xyz!@#!"

@interface ChatViewController () <UIActionSheetDelegate> {
    // for entity messages
    NSBubbleContentType longPressedDataType;
    NSString *longPressedDataPath;
    
    MBProgressHUD *downloadProgressHUD; // Download progress hud for video
    
    NSString *videoCallEmoji;
    NSString *voiceCallEmoji;
}
@end

@implementation ChatViewController

@synthesize bGoToChat;
@synthesize strIds;
@synthesize boardid;
@synthesize lstBoardUser;
@synthesize isWall;
@synthesize playerVC;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	lst_searched	= [[NSMutableArray alloc] init];
	lst_board		= [[NSMutableArray alloc] init];
	lst_delete		= [[NSMutableArray alloc] init];
    [self.navigationItem setHidesBackButton:YES animated:NO];
    UIView *vwBack = [[UIView alloc] initWithFrame:CGRectMake(-10, 0, 44, 44)];
    UIImageView *imgBack = [[UIImageView alloc] initWithFrame:CGRectMake(0, 11, 13, 21)];
    [imgBack setImage:[UIImage imageNamed:@"BackArrow"]];
    
    UIButton *btHomeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [btHomeButton setFrame:CGRectMake(0, 0, 44, 44)];
    [btHomeButton addTarget:self action:@selector(btHomeClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [vwBack addSubview:imgBack];
    [vwBack addSubview:btHomeButton];
    
    btHome = [[UIBarButtonItem alloc] initWithCustomView:vwBack];
	
    btChat = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"BtnChatNav"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(btChatClick:)];
    
	UIButton *_btClose = [UIButton buttonWithType:UIButtonTypeCustom];
	[_btClose setFrame:CGRectMake(0, 0, 15, 15)];
	[_btClose setImage:[UIImage imageNamed:@"BtnCloseHome"] forState:UIControlStateNormal];
	[_btClose addTarget:self action:@selector(btCloseClick:) forControlEvents:UIControlEventTouchUpInside];
	btClose = [[UIBarButtonItem alloc] initWithCustomView:_btClose];
	
	btClear = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"Truck"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(btClearClick:)];
    
    //wall
    UIButton *_btEmpty = [UIButton buttonWithType:UIButtonTypeCustom];
	[_btEmpty setFrame:CGRectMake(0, 0, 41, 32)];
	btEmpty = [[UIBarButtonItem alloc] initWithCustomView:_btEmpty];
    
	[self.navigationItem setRightBarButtonItem:btChat];
	[self.navigationItem setLeftBarButtonItem:btHome];
    [self.navigationItem setTitle:@"Chat"];
    
    UIFont *font = [UIFont boldSystemFontOfSize:17];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:font}];
//    self.navigation
	bGoToChat = FALSE;
	
	[vwEmpty setHidden:YES];
    
    //isWall = NO;
    btnChatHistory.selected = !isWall;
    btnWall.selected = isWall;
    
    vwPhoto = [[UIView alloc] initWithFrame:[AppDelegate sharedDelegate].window.frame];
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

    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"EmojisList"
                                                          ofType:@"plist"];
    NSDictionary *emojis = [[NSDictionary dictionaryWithContentsOfFile:plistPath] copy];
    voiceCallEmoji = [[emojis objectForKey:@"Objects"] objectAtIndex:32];
    videoCallEmoji = [[emojis objectForKey:@"Objects"] objectAtIndex:23];
    
}

-(void)selectAction:(int)index :(int)status
{
	if (status == 0) {
		[lst_delete removeObject:[[lst_searched objectAtIndex:index] objectForKey:@"board_id"]];
	}else{
		[lst_delete addObject:[[lst_searched objectAtIndex:index] objectForKey:@"board_id"]];
	}
	
	[tbl_chat reloadData];
    
	if ([lst_delete count]>0) {
		[self showDeleteView:1];
	}else{
		[self showDeleteView:0];
	}
}

-(void)showDeleteView:(int)index
{
	CGRect rt = tbl_chat.frame;
	if (index == 1) {
		[vwDelete setHidden:NO];
		rt.size.height = self.view.frame.size.height - 88 - 50;
	}else{
		[vwDelete setHidden:YES];
		rt.size.height = self.view.frame.size.height - 88;
	}
	tbl_chat.frame = rt;
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    [AppDelegate sharedDelegate].isChatViewScreen = YES;
    //wall
    if (isWall) {
        [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
        [AppDelegate sharedDelegate].isWallScreen = YES;
        [self getEntityMessages];
    } else {
    
        if (bGoToChat)
        {
            YYYChatViewController *viewcontroller = [[YYYChatViewController alloc] initWithNibName:@"YYYChatViewController" bundle:nil];
            bGoToChat = FALSE;
            viewcontroller.boardid = boardid;
            viewcontroller.lstUsers = lstBoardUser;
            [self.navigationController pushViewController:viewcontroller animated:NO];
        }
        else
        {
            [self getChatBoards];
            if (srb_chat.text && ![srb_chat.text  isEqual: @""]) {
                //[self searchBar:searchBarForList textDidChange:searchBarForList.text];
                [self searchBarSearchButtonClicked:srb_chat];
            }
        }
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadEntityMessages) name:ENTITY_MESSAGE_NOTIFICATION object:nil];    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessage:) name:CONTACT_SYNC_NOTIFICATION object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessage:) name:@"NEWMESSAGE" object:nil];
	
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [AppDelegate sharedDelegate].isChatViewScreen = NO;
    [AppDelegate sharedDelegate].isWallScreen = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NEWMESSAGE" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ENTITY_MESSAGE_NOTIFICATION object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:CONTACT_SYNC_NOTIFICATION object:nil];//******************** don't open this func again...You need to research it....Liu
}

-(void)newMessage : (NSNotification*) _notification
{
    if (!isWall) {
        [self getChatBoards];
    }
}

-(void)getChatBoards
{
    if (btEdit.selected) {
        [self.navigationItem setRightBarButtonItem:btClose];
    }
    else {
        [self.navigationItem setRightBarButtonItem:btChat];
    }
    isWall = NO;
    btEdit.hidden = NO;
    btnChatHistory.selected = !isWall;
    btnWall.selected = isWall;
    
	if (![AppDelegate sharedDelegate].sessionId) return;
	
	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideAllHUDsForView:self.view animated : YES ] ;
        
		[lst_board removeAllObjects];
		[tbl_chat.pullToRefreshView stopAnimating];
		
		if ([[_responseObject objectForKey:@"success"] boolValue])
		{
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NEWMESSAGE" object:nil];
                        
			for (NSDictionary *dict in [_responseObject objectForKey:@"data"])
			{
				//if ([[dict objectForKey:@"members"] count] > 1)
					[lst_board addObject:dict];
			}
            
			[vwEmpty setHidden:YES];
			if ([lst_board count] == 0)
			{
				[vwEmpty setHidden:NO];
                btEdit.enabled = NO;
            }else{
                btEdit.enabled = YES;
            }

//            lblDescription.hidden = isWall;
            [lblDescription setText:@"Select the chat icon to message a contact."];
//            if (isWall)
//                [lblDescription setText:@"Sorry, no posts to view. Check back later."];
//            else
//                [lblDescription setText:@"Select the chat icon to message a contact."];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessage:) name:@"NEWMESSAGE" object:nil];
            
			[self searchKeyword:srb_chat.text];
		}
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideAllHUDsForView:self.view animated : YES ] ;
		[tbl_chat.pullToRefreshView stopAnimating];
        [ self  showAlert: @"Internet Connection Error!" ] ;
		
    } ;
    
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
	[[YYYCommunication sharedManager] GetChatBoards:[AppDelegate sharedDelegate].sessionId successed:successed failure:failure];
}

//wall
- (void)getEntityMessages
{
    [self.navigationItem setRightBarButtonItem:btEmpty];
    isWall = YES;
    btEdit.hidden = YES;
    btnChatHistory.selected = !isWall;
    btnWall.selected = isWall;
    
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            [lst_board removeAllObjects];
            [tbl_chat.pullToRefreshView stopAnimating];
            
            for (NSDictionary *dict in [[_responseObject objectForKey:@"data"] objectForKey:@"data"])
            {
                if ([dict objectForKey:@"msg_id"])
                    [lst_board addObject:dict];
            }
            
            [vwEmpty setHidden:YES];
            if ([lst_board count] == 0)
            {
                [vwEmpty setHidden:NO];
                btEdit.enabled = NO;
            }else{
                btEdit.enabled = YES;
            }
            
            [lblDescription setText:@"Sorry, no posts to view. Check back later."];

            //            lblDescription.hidden = isWall;
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NEWMESSAGE" object:nil];
            
            [self searchKeyword:srb_chat.text];
        }  else {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSDictionary *dictError = [_responseObject objectForKey:@"err"];
            if (dictError) {
                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:[dictError objectForKey:@"errMsg"]];
            } else {
                [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Failed to connect to server!"];
            }
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Internet Connection Error!"];
    } ;
    
    [[YYYCommunication sharedManager] getEntityMessageHistory:[AppDelegate sharedDelegate].sessionId pageNum:nil countPerPage:nil successed:successed failure:failure];
    return;
}

-(void)showAlert:(NSString*)_message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:_message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

-(IBAction)btHomeClick:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
    if (isWall) {
        APPDELEGATE.isPlayingAudio = NO;
    }
}

-(IBAction)btChatClick:(id)sender
{
    [srb_chat setShowsCancelButton:NO animated:YES];
	bGoToChat = FALSE;
    YYYSelectContactController *viewcontroller = [[YYYSelectContactController alloc] initWithNibName:@"YYYSelectContactController" bundle:nil];
	viewcontroller.viewcontroller = self;
	viewcontroller.boardid = nil;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:viewcontroller];
	[self presentViewController:nc animated:YES completion:nil];
}

-(IBAction)btClearClick:(id)sender
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Do you want to delete your entire chat history?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
	[alert show];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)
	{
        if (alertView.tag == 300) {
            [self leaveBoard:lst_delete];
            return;
        }
		NSMutableArray *boardis = [[NSMutableArray alloc] init];
		
		for (NSDictionary *dict in lst_board) {
			[boardis addObject:[dict objectForKey:@"board_id"]];
		}
		
		[self leaveBoard:boardis];
	}
}

-(IBAction)btTrachClick:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Do you want to delete chat history with selected users?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    alert.tag = 300;
    [alert show];
	
}

-(void)leaveBoard:(NSMutableArray*)boardids
{
	if (![boardids count])
		return;
	
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
	
	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        
		[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
		
		if ([[_responseObject objectForKey:@"success"] boolValue])
		{
            
			NSMutableArray *lstNewBoards = [[NSMutableArray alloc] init];
			for (NSDictionary *dict in lst_board)
			{
				if (![boardids containsObject:[dict objectForKey:@"board_id"]])
				{
					[lstNewBoards addObject:dict];
				}
			}
			
            if (![lstNewBoards count]) [vwEmpty setHidden:NO];
			
			lst_board = [[NSMutableArray alloc] initWithArray:lstNewBoards];
			
            [btEdit setSelected:NO];
            [btEdit setImage:[UIImage imageNamed:@"EditIcon"] forState:UIControlStateNormal];
			[lst_delete removeAllObjects];
			
            if ([lst_board count] == 0)
            {
                [vwEmpty setHidden:NO];
                btEdit.enabled = NO;
            }else{
                btEdit.enabled = YES;
                [vwEmpty setHidden:YES];
            }
            
			[self.navigationItem setRightBarButtonItem:btChat];
			[self.navigationItem setLeftBarButtonItem:btHome];
			[self showDeleteView:0];
			
			[self searchKeyword:srb_chat.text];
		}
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
		
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
		
    } ;
	
	NSString *ids = @"";
	for (int i = 0; i < [boardids count]; i++)
	{
		ids = [NSString stringWithFormat:@"%@,%@",ids,[NSString stringWithFormat:@"%@",[boardids objectAtIndex:i]]];
        [[LocalDBManager sharedManager] deleteAllMessagesForBoard:[boardids objectAtIndex:i]];
	}
	
	ids = [ids substringFromIndex:1];
	
	[[YYYCommunication sharedManager] LeaveBoard:[AppDelegate sharedDelegate].sessionId boardids:ids successed:successed failure:failure];
}

-(IBAction)btCloseClick:(id)sender
{
	[btEdit setSelected:NO];
    [btEdit setImage:[UIImage imageNamed:@"EditIcon"] forState:UIControlStateNormal];
	[lst_delete removeAllObjects];
	[tbl_chat reloadData];
	
	if (![lst_board count]) [vwEmpty setHidden:NO];
	
	[self.navigationItem setRightBarButtonItem:btChat];
	[self.navigationItem setLeftBarButtonItem:btHome];
	
	[self showDeleteView:0];
}

-(IBAction)btEditClick:(id)sender
{
    //wall
    if (isWall) {
        return;
    }
    
	if (btEdit.selected) {
		[btEdit setSelected:NO];
        [btEdit setImage:[UIImage imageNamed:@"EditIcon"] forState:UIControlStateNormal];
		[lst_delete removeAllObjects];
		[tbl_chat reloadData];
		[self showDeleteView:0];
		[self.navigationItem setRightBarButtonItem:btChat];
		[self.navigationItem setLeftBarButtonItem:btHome];
	}
	else
	{
        [btEdit setSelected:YES];
        [btEdit setImage:[UIImage imageNamed:@"Done"] forState:UIControlStateNormal];
		[tbl_chat reloadData];
        if([lst_searched count] == 0){
           [self.navigationItem setLeftBarButtonItem:nil];
        }
        else{
            [self.navigationItem setLeftBarButtonItem:btClear];
        }
		[self.navigationItem setRightBarButtonItem:btClose];
	}
}

#pragma mark - EntityChatCell Delegate
- (void)didAvatar:(NSDictionary *)messageDict
{
    /*EntityChatWallViewController *vc = [[EntityChatWallViewController alloc] initWithNibName:@"EntityChatWallViewController" bundle:nil];
    vc.entityID = [messageDict objectForKey:@"entity_id"];
    vc.entityName = [messageDict objectForKey:@"entity_name"];
    vc.entityImageURL = [messageDict objectForKey:@"profile_image"];
    [self.navigationController pushViewController:vc animated:YES];*/
    APPDELEGATE.isPlayingAudio = NO;
    [self getEntityFollowerView:[messageDict objectForKey:@"entity_id"] following:YES notes:[messageDict objectForKey:@"notes"]];
}

- (void)didEntityName:(NSDictionary *)messageDict
{
    APPDELEGATE.isPlayingAudio = NO;
    EntityChatWallViewController *vc = [[EntityChatWallViewController alloc] initWithNibName:@"EntityChatWallViewController" bundle:nil];
    vc.entityID = [messageDict objectForKey:@"entity_id"];
    vc.entityName = [messageDict objectForKey:@"entity_name"];
    vc.entityImageURL = [messageDict objectForKey:@"profile_image"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReturn:(NSDictionary *)messageDict
{//GID-409
    
    NSString *content = [messageDict objectForKey:@"content"];
    if (![[content substringToIndex:1] isEqualToString:@"{"])
    {
        if ([content rangeOfString:MAPBOUND].location != 0) {
            
            APPDELEGATE.isPlayingAudio = NO;
            EntityChatDetailViewController *vc = [[EntityChatDetailViewController alloc] initWithNibName:@"EntityChatDetailViewController" bundle:nil];
            vc.strProfileImageURL = [messageDict objectForKey:@"profile_image"];
            vc.strMessage  = [messageDict objectForKey:@"content"];
            vc.strEntityName = [messageDict objectForKey:@"entity_name"];
            vc.strSentTime = [messageDict objectForKey:@"sent_time"];
            [self presentViewController:vc animated:YES completion:nil];
        }
    }
}

- (void)didContent:(NSDictionary *)messageDic
{
    return;
}

- (void)didVideoTouch:(NSString *)videoPath
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

- (void)didImageTouch:(NSString *)photoURL
{
	[imvPhoto setImageWithURL:[NSURL URLWithString:photoURL]];
	[[AppDelegate sharedDelegate].window addSubview:vwPhoto];
}

- (void)didMapTouch:(float)latitude :(float)longitude
{
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
}

- (void)photoLongPressed:(NSString *)photoPath {
    longPressedDataType = NSBubbleContentTypePhoto;
    longPressedDataPath = photoPath;
    [self.view endEditing:YES];
    [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share", nil] showInView:self.navigationController.view];
}

- (void)videoLongPressed:(NSString *)videoPath {
    longPressedDataType = NSBubbleContentTypeVideo;
    longPressedDataPath = videoPath;
    [self.view endEditing:YES];
    [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share", nil] showInView:self.navigationController.view];
}

- (void)voiceLongPressed:(NSString *)audioPath {
    longPressedDataType = NSBubbleContentTypeVoice;
    longPressedDataPath = audioPath;
    [self.view endEditing:YES];
    [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share", nil] showInView:self.navigationController.view];
}

#pragma mark - Share
- (void)shareWithPath:(NSString *)videoPath {
    NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
    NSArray* dataToShare = @[SHARE_MAIL_TEXT, videoURL];
    UIActivityViewController* activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:dataToShare
                                      applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

#pragma mark - Go To Entity Follower View
//em classes
-(void)getEntityFollowerView:(NSString *)entityID following:(BOOL)isFollowing notes:(NSString *)notes
{
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        NSDictionary *result = _responseObject;
        if ([[result objectForKey:@"success"] boolValue]) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if ([_responseObject[@"data"][@"infos"] count] > 1){
                MainEntityViewController *vc = [[MainEntityViewController alloc] initWithNibName:@"MainEntityViewController" bundle:nil];
                vc.entityData = _responseObject[@"data"];
                vc.isFollowing = isFollowing;
                vc.isFavorite = [[_responseObject[@"data"] objectForKey:@"is_favorite"] boolValue];
                vc.locationsTotal = [[_responseObject[@"data"] objectForKey:@"info_total"] integerValue];
                [self.navigationController pushViewController:vc animated:YES];
            }else if ([_responseObject[@"data"][@"infos"] count] == 1){
                EntityViewController *vc = [[EntityViewController alloc] initWithNibName:@"EntityViewController" bundle:nil];
                vc.entityData = _responseObject[@"data"];
                vc.isFollowing = isFollowing;
                vc.isFavorite = [[_responseObject[@"data"] objectForKey:@"is_favorite"] boolValue];
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"GINKO" message:@"Oops! Current Entity hasn't informations!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                
                [alertView show];
            }
        } else {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSDictionary *dictError = [result objectForKey:@"err"];
            if (dictError) {
                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:[dictError objectForKey:@"errMsg"]];
                if ([[NSString stringWithFormat:@"%@",[dictError objectForKey:@"errCode"]] isEqualToString:@"700"]) {
                    [CommonMethods loadFetchAllEntityNew];
                    [[NSNotificationCenter defaultCenter] postNotificationName:CONTACT_SYNC_NOTIFICATION object:nil];
                }
            } else {
                [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Failed to connect to server!"];
            }
        }
    };
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Internet Connection Error!"];
    };
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    //[[YYYCommunication sharedManager] GetEntityByFollowr:[AppDelegate sharedDelegate].sessionId entityid:entityID successed:successed failure:failure];
    [[YYYCommunication sharedManager] GetEntityByFollowrNew:[AppDelegate sharedDelegate].sessionId entityid:entityID infoFrom:@"0" infoCount:@"20" latitude:[AppDelegate sharedDelegate].currentLocationforMultiLocations.latitude longitude:[AppDelegate sharedDelegate].currentLocationforMultiLocations.longitude successed:successed failure:failure];
}

#pragma mark - UITableView Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [lst_searched count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isWall) {
        return 209.0f;
    } else {
        return 85.0f;
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:NO];
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *dict = [lst_searched objectAtIndex:indexPath.row];
	
    NSString *newMessageOwner = @"";
    
    //wall
    if (isWall) {
        EntityChatCell *cell = [tbl_chat dequeueReusableCellWithIdentifier:@"EntityChatCell"];
        
        if(cell == nil)
        {
            cell = [EntityChatCell sharedCell];
        }

        cell.messageDict = dict;
        cell.delegate = self;
        UITapGestureRecognizer *gestureOne = [[UITapGestureRecognizer alloc] initWithTarget:cell action:@selector(redirectHistory)];
        [cell.lblMessage addGestureRecognizer:gestureOne];
        return cell;
    }
    
	NSString *strIdentifier = @"YYYCustomInboxCell";
	YYYCustomInboxCell *cell = [tableView dequeueReusableCellWithIdentifier:strIdentifier];
    if (cell == nil) {
        cell = [YYYCustomInboxCell sharedCell];
    }
	cell.delegate = self;
	
    [(UILabel*)[cell viewWithTag:102] setText:@""];
    
	UILabel *lblName = (UILabel*)[cell viewWithTag:101];
    
    
    if ([[dict objectForKey:@"is_group"] boolValue]) { //directory
        UIImageView *profileImageView = (UIImageView*)[cell viewWithTag:100];
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2.0f;
        profileImageView.layer.masksToBounds = YES;
        profileImageView.layer.borderColor = [UIColor colorWithRed:128.0/256.0 green:100.0/256.0 blue:162.0/256.0 alpha:1.0f].CGColor;
        profileImageView.layer.borderWidth = 1.0f;
        
        if (![[dict objectForKey:@"profile_image"] isEqualToString:@""]) {
            [(UIImageView*)[cell viewWithTag:100] setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"profile_image"]]];
        }else{
            [(UIImageView*)[cell viewWithTag:100] setImage:[UIImage imageNamed:@"group_chat_img"]];
        }
        [lblName setText:[dict objectForKey:@"board_name"]];
    }else{
        for (NSDictionary *dictmember in [dict objectForKey:@"members"])
        {
            if ([[[dictmember objectForKey:@"memberinfo"] objectForKey:@"user_id"] intValue] == [[AppDelegate sharedDelegate].userId intValue]) {
                continue;
            }
            
            UIImageView *profileImageView = (UIImageView*)[cell viewWithTag:100];
            
            profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2.0f;
            profileImageView.layer.masksToBounds = YES;
            profileImageView.layer.borderColor = [UIColor colorWithRed:128.0/256.0 green:100.0/256.0 blue:162.0/256.0 alpha:1.0f].CGColor;
            profileImageView.layer.borderWidth = 1.0f;
            
            if ([[dict objectForKey:@"members"] count] < 3)
            {
                [(UIImageView*)[cell viewWithTag:100] setImageWithURL:[NSURL URLWithString:[[dictmember objectForKey:@"memberinfo"] objectForKey:@"photo_url"]]];
            }
            [lblName setText:[NSString stringWithFormat:@"%@ %@",[[dictmember objectForKey:@"memberinfo"] objectForKey:@"fname"],[[dictmember objectForKey:@"memberinfo"] objectForKey:@"lname"]]];
            
            if ([[[dictmember objectForKey:@"memberinfo"] objectForKey:@"user_id"] integerValue] == [[[dict objectForKey:@"recent_messages"][0] objectForKey:@"send_from"] integerValue]) {
                newMessageOwner =[[dictmember objectForKey:@"memberinfo"] objectForKey:@"fname"];
            }
        }
        
        if ([[dict objectForKey:@"members"] count] > 2)
        {
            NSString *firstMember = [dict objectForKey:@"members"][0][@"memberinfo"][@"fname"];
            for (NSDictionary *dictMember in [dict objectForKey:@"members"]) {
                if ([[[dictMember objectForKey:@"memberinfo"] objectForKey:@"user_id"] integerValue] == [[[dict objectForKey:@"recent_messages"][0] objectForKey:@"send_from"] integerValue]) {
                    firstMember = [dictMember objectForKey:@"memberinfo"][@"fname"];
                }
            }
            if ([firstMember isEqualToString:@""]) {
                firstMember = [dict objectForKey:@"members"][0][@"memberinfo"][@"fname"];
            }
            [lblName setText:[NSString stringWithFormat:@"%@+%lu",firstMember,[[dict objectForKey:@"members"] count] - 2]];
            [(UIImageView*)[cell viewWithTag:100] setImage:[UIImage imageNamed:@"group_chat_img"]];
        }
    }
    
    
    UIImageView *imvArrow = (UIImageView*)[cell viewWithTag:105];
    UILabel *dataLable = (UILabel*)[cell viewWithTag:103];
	if ([[dict objectForKey:@"recent_messages"] count])
	{
		NSDictionary *dictMsg = [[dict objectForKey:@"recent_messages"] objectAtIndex:0];
		
		
		[cell setBackgroundColor:[UIColor whiteColor]];
		
		if([[dictMsg objectForKey:@"send_from"] intValue] == [[AppDelegate sharedDelegate].userId intValue])
		{
			[imvArrow setImage:[UIImage imageNamed:@"arrow_right.png"]];
            if (![[dictMsg objectForKey:@"is_read"] intValue])
            {
                [cell setBackgroundColor:[UIColor colorWithRed:223/255.0f green:209/255.0f blue:237/255.0f alpha:1.0f]];
            }
		}
		else
		{
			if (![[dictMsg objectForKey:@"is_read"] intValue])
			{
				[cell setBackgroundColor:[UIColor colorWithRed:223/255.0f green:209/255.0f blue:237/255.0f alpha:1.0f]];
			}
			[imvArrow setImage:[UIImage imageNamed:@"arrow_left.png"]];
		}
		
		if ([[dictMsg objectForKey:@"msgType"] intValue] == 1)
		{
			if ([dictMsg objectForKey:@"content"] && [[dictMsg objectForKey:@"content"] rangeOfString:MAPBOUND].location == 0)
			{
				[(UILabel*)[cell viewWithTag:102] setText:@"#Location"];
			}
            else if ([dictMsg objectForKey:@"content"] && [[dictMsg objectForKey:@"content"] rangeOfString:@"{\"msgType\":\""].location == 0){
                id jsonData = [[dictMsg objectForKey:@"content"] dataUsingEncoding:NSUTF8StringEncoding]; //if input is NSString
                id content = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
                NSString *emoT = videoCallEmoji;
                if ([[content objectForKey:@"msgType"] isEqualToString:@"audioCall"]) {
                    emoT = voiceCallEmoji;
                }
                switch ([[content objectForKey:@"endType"] integerValue]) {
                    case 1:
                        [(UILabel*)[cell viewWithTag:102] setText:[NSString stringWithFormat:@"%@ Call ended", emoT]];
                        break;
                    case 2:
                        [(UILabel*)[cell viewWithTag:102] setText:[NSString stringWithFormat:@"%@ %@ no answer", newMessageOwner, emoT]];
                        break;
                    case 3:
                        [(UILabel*)[cell viewWithTag:102] setText:[NSString stringWithFormat:@"%@ %@ is busy",newMessageOwner, emoT]];
                        break;
                    case 4:
                        [(UILabel*)[cell viewWithTag:102] setText:[NSString stringWithFormat:@"%@ Missing a call from %@", emoT, newMessageOwner]];
                        break;
                        
                    default:
                        break;
                }
            }else{
				[(UILabel*)[cell viewWithTag:102] setText:[dictMsg objectForKey:@"content"]];
			}
		}
		else
		{
			id jsonData = [[dictMsg objectForKey:@"content"] dataUsingEncoding:NSUTF8StringEncoding]; //if input is NSString
			id content = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
			
			if ([[content objectForKey:@"file_type"] isEqualToString:@"photo"])
			{
				[(UILabel*)[cell viewWithTag:102] setText:@"#Photo"];
			}
			else if ([[content objectForKey:@"file_type"] isEqualToString:@"voice"])
			{
				[(UILabel*)[cell viewWithTag:102] setText:@"#Voice"];
			}
			else if ([[content objectForKey:@"file_type"] isEqualToString:@"video"])
			{
				[(UILabel*)[cell viewWithTag:102] setText:@"#Video"];
			}
		}
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
		[formatter setTimeZone :[NSTimeZone timeZoneForSecondsFromGMT: 0]];
		NSDate *utcdate = [formatter dateFromString:[NSString stringWithFormat:@"%@",[dictMsg objectForKey:@"send_time"]]];
		
		[formatter setTimeZone:[NSTimeZone localTimeZone]];
		NSDate *localdate = [formatter dateFromString:[formatter stringFromDate:utcdate]];
        
		[formatter setDateStyle:NSDateFormatterShortStyle];
		[formatter setTimeStyle:NSDateFormatterShortStyle];
		
		[dataLable setText:[self getDate:localdate]];
	}
	
    UIView *viewiewContainer = [cell viewWithTag:200];
	if (btEdit.selected) {
        [viewiewContainer setFrame:CGRectMake(0, 0, 340, 85)];
        [imvArrow setFrame:CGRectMake(277, 23, 20, 15)];
        [dataLable setFrame:CGRectMake(212, 42, 99, 21)];
	}else{
        [viewiewContainer setFrame:CGRectMake(-25, 0, 340, 85)];
        [imvArrow setFrame:CGRectMake(302, 23, 20, 15)];
        [dataLable setFrame:CGRectMake(237, 42, 99, 21)];
	}
	
	if ([lst_delete containsObject:[[lst_searched objectAtIndex:indexPath.row] objectForKey:@"board_id"]]) {
		[(UIButton*)[cell viewWithTag:104] setSelected:YES];
	}else{
		[(UIButton*)[cell viewWithTag:104] setSelected:NO];
	}
	
	[cell initWithData:(int)indexPath.row];
	
	return cell;
}

-(NSString*)getDate : (NSDate*)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if ([[[date description] substringToIndex:10] isEqualToString:[[[NSDate date] description] substringToIndex:10]]) {
        formatter.timeStyle = NSDateFormatterShortStyle;
    }else{
        formatter.dateFormat = @"MMM dd, yyyy";
    }
    return [formatter stringFromDate:date];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //wall
    if (isWall) {
//        NSDictionary *dict = [lst_searched objectAtIndex:indexPath.row];
//        NSString *content = [dict objectForKey:@"content"];
//        if (![[content substringToIndex:1] isEqualToString:@"{"])
//        {
//            if ([content rangeOfString:MAPBOUND].location != 0) {
//                EntityChatDetailViewController *vc = [[EntityChatDetailViewController alloc] initWithNibName:@"EntityChatDetailViewController" bundle:nil];
//                vc.strProfileImageURL = [dict objectForKey:@"profile_image"];
//                vc.strMessage  = [dict objectForKey:@"content"];
//                vc.strEntityName = [dict objectForKey:@"entity_name"];
//                [self presentViewController:vc animated:YES completion:nil];
//            }
//        }
        
        return;
    }
    if (btEdit.selected) {
        if ([lst_delete containsObject:[[lst_searched objectAtIndex:indexPath.row] objectForKey:@"board_id"]]) {
            [lst_delete removeObject:[[lst_searched objectAtIndex:indexPath.row] objectForKey:@"board_id"]];
        }else{
            [lst_delete addObject:[[lst_searched objectAtIndex:indexPath.row] objectForKey:@"board_id"]];
        }
        
        [tbl_chat reloadData];
        
        if ([lst_delete count]>0) {
            [self showDeleteView:1];
        }else{
            [self showDeleteView:0];
        }
    }else{
        YYYChatViewController *viewcontroller = [[YYYChatViewController alloc] initWithNibName:@"YYYChatViewController" bundle:nil];
        viewcontroller.boardid = [[lst_searched objectAtIndex:indexPath.row] objectForKey:@"board_id"];
        NSDictionary *dict = [lst_searched objectAtIndex:indexPath.row];
        
        if ([[dict objectForKey:@"is_group"] boolValue]) {
            viewcontroller.isDeletedFriend = NO;
            viewcontroller.fromHistoryGroupDic = dict;
            viewcontroller.groupName = [dict objectForKey:@"board_name"];
            viewcontroller.isMemberForDiectory = YES;
            viewcontroller.isDirectory = YES;
            viewcontroller.isFromChatHistory = YES;
        }else{
            NSArray *members = [[lst_searched objectAtIndex:indexPath.row] objectForKey:@"members"];
            
            //NSLog(@"asf---%@",[lst_searched objectAtIndex:indexPath.row]);
            //NSLog(@"contact---%@",[AppDelegate sharedDelegate].existedContactIDs);
            BOOL isDeleted = YES;
            BOOL isMembersSameDirectory = NO;
            for (NSDictionary *memberDic in members) {
                //if ([memberDic[@"is_friend"] boolValue] && [[AppDelegate sharedDelegate].existedContactIDs containsObject:[memberDic[@"memberinfo"] objectForKey:@"user_id"]]) {
                if ([memberDic[@"is_friend"] boolValue]) {
                    isDeleted = NO;
                }
                if ([memberDic[@"in_same_directory"] boolValue]) {
                    isMembersSameDirectory = YES;
                }
            }
            viewcontroller.isDeletedFriend = isDeleted;
            if (isMembersSameDirectory) {
                viewcontroller.isDeletedFriend = NO;
                viewcontroller.groupName = [dict objectForKey:@"board_name"];
                viewcontroller.isMemberForDiectory = YES;
                viewcontroller.isDirectory = NO;
            }
            NSMutableArray *lstTemp = [[NSMutableArray alloc] init];
            NSDictionary *newMessageOwner;
            for (NSDictionary *dictMember in [[lst_searched objectAtIndex:indexPath.row] objectForKey:@"members"]) {
                if ([[[dictMember objectForKey:@"memberinfo"] objectForKey:@"user_id"] integerValue] == [[[dict objectForKey:@"recent_messages"][0] objectForKey:@"send_from"] integerValue]) {
                    newMessageOwner = [dictMember objectForKey:@"memberinfo"];
                }else{
                    [lstTemp addObject:[dictMember objectForKey:@"memberinfo"]];
                }
            }
            if (newMessageOwner) {
                [lstTemp addObject:newMessageOwner];
            }
            viewcontroller.lstUsers = [[NSMutableArray alloc] initWithArray:lstTemp];
            if(lstTemp.count > 2)
                viewcontroller.isFromChatHistory = YES;
            NSLog(@"%lu users",(unsigned long)lstTemp.count);
        }
        
        if ([[dict objectForKey:@"members"] count] < 3){
            NSInteger otherUserid = 0;
            for (NSDictionary *info in [dict objectForKey:@"members"]) {
                if ([APPDELEGATE.userId integerValue] != [[[info objectForKey:@"memberinfo"] objectForKey:@"user_id"] integerValue]) {
                    otherUserid = [[[info objectForKey:@"memberinfo"] objectForKey:@"user_id"] integerValue];
                }
            }
            if (otherUserid != 0) {
                for (NSDictionary *userPro in APPDELEGATE.totalList) {
                    if ([userPro objectForKey:@"contact_type"] && [[userPro objectForKey:@"contact_type" ] integerValue] == 1) {
                        if ([[userPro objectForKey:@"contact_id"] integerValue] == otherUserid) {
                            if ([[userPro objectForKey:@"sharing_status"] integerValue] == 4) {
                                viewcontroller.isAbleVideoConference = YES;
                            }
                        }
                    }
                }
            }
        }
        
        //[srb_chat.delegate searchBarCancelButtonClicked:srb_chat];
        [self.navigationController pushViewController:viewcontroller animated:YES];
    }
    
}

#pragma mark - UISearchBarDelegate

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    return TRUE;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [self searchKeyword:@""];
	[self.view endEditing:YES];
    [searchBar setShowsCancelButton:NO animated:YES];
}

-(BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	return YES;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self searchKeyword:searchBar.text];
    [self.view endEditing:YES];
    [searchBar setShowsCancelButton:NO animated:YES];
    /*
     //observing search bar cancel button
     for (UIView *view in [srb_chat subviews]){
     for (id subview in view.subviews){
     if ([subview isKindOfClass:[UIButton class]]){
     [subview setEnabled:YES];
     return;
     }
     }
     }*/
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
//	if ([searchText isEqualToString:@""]) {
//		[self searchKeyword:@""];
//	}
    
    [self searchKeyword:searchText];
    
//    NSString *strKeyword = searchBar.text;
//	if ([text isEqualToString:@""])
//	{
//		//Backspace
//		if ([strKeyword length]) {
//			strKeyword = [strKeyword substringToIndex:[strKeyword length] - 1];
//		}
//	}
//	else
//	{
//		strKeyword = [NSString stringWithFormat:@"%@%@",strKeyword,text];
//	}
//	
//	[self searchKeyword:strKeyword];
}



-(void)searchKeyword:(NSString*)keyword
{
	if ([keyword isEqualToString:@""])
	{
        lst_searched = [[NSMutableArray alloc] initWithArray:lst_board];
	}
	else
	{
		[lst_searched removeAllObjects];
		for (NSDictionary *dict in lst_board)
		{
            //wall
            if (isWall) {
                if ([[[dict objectForKey:@"entity_name"] lowercaseString] rangeOfString:keyword.lowercaseString].location != NSNotFound) {
                    [lst_searched addObject:dict];
                }
            } else {
                BOOL isCompleted = false;
                if ([[dict objectForKey:@"is_group"] boolValue]) { //directory
                    if ([[[NSString stringWithFormat:@"%@",[dict objectForKey:@"board_name"]] lowercaseString] rangeOfString:keyword.lowercaseString].location != NSNotFound) {
                        [lst_searched addObject:dict];
                        isCompleted = true;
                    }
                }else{
                    for (NSDictionary *dictMember in [dict objectForKey:@"members"])
                    {
                        if ([[[NSString stringWithFormat:@"%@ %@",[[dictMember objectForKey:@"memberinfo"] objectForKey:@"fname"],[[dictMember objectForKey:@"memberinfo"] objectForKey:@"lname"]] lowercaseString] rangeOfString:keyword.lowercaseString].location != NSNotFound) {
                            [lst_searched addObject:dict];
                            isCompleted = true;
                            break;
                        }
                    }
                }
     
                if (isCompleted == false)
                {
                    if ([[dict objectForKey:@"recent_messages"] count])
                    {
                        NSDictionary *dictMsg = [[dict objectForKey:@"recent_messages"] objectAtIndex:0];
                        
                        NSString *latestMsg = @"";
                        if ([[dictMsg objectForKey:@"msgType"] intValue] == 1)
                        {
                            if ([dictMsg objectForKey:@"content"] && [[dictMsg objectForKey:@"content"] rangeOfString:MAPBOUND].location == 0)
                            {
                                latestMsg = @"Location";
                            }
                            else
                            {
                                latestMsg = [dictMsg objectForKey:@"content"];
                            }
                        }
                        else
                        {
                            id jsonData = [[dictMsg objectForKey:@"content"] dataUsingEncoding:NSUTF8StringEncoding]; //if input is NSString
                            id content = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
                            
                            if ([[content objectForKey:@"file_type"] isEqualToString:@"photo"])
                            {
                                latestMsg = @"Photo";
                            }
                            else if ([[content objectForKey:@"file_type"] isEqualToString:@"voice"])
                            {
                                latestMsg = @"Voice";
                            }
                            else if ([[content objectForKey:@"file_type"] isEqualToString:@"video"])
                            {
                                latestMsg = @"Video";
                            }
                        }
                        
                        if ([[latestMsg lowercaseString] rangeOfString:keyword.lowercaseString].location != NSNotFound)
                            [lst_searched addObject:dict];
                        
                    }
                }
            }
		}
	}
    if ([lst_searched count] == 0)
    {
        [vwEmpty setHidden:NO];
        btEdit.enabled = NO;
    }else{
        [vwEmpty setHidden:YES];
        btEdit.enabled = YES;
    }
    
    [tbl_chat reloadData];
}

-(IBAction)btPhotoDoneClick:(id)sender
{
	[imvPhoto setImage:nil];
	[vwPhoto removeFromSuperview];
}

//wall
- (IBAction)onChatHistory:(id)sender
{
    
    if (!isWall) {
        return;
    }
    
    [AppDelegate sharedDelegate].isWallScreen = NO;
    // clear table view
    lst_searched = [NSMutableArray new];
    [tbl_chat reloadData];
    
    [self getChatBoards];
}

- (IBAction)onWall:(id)sender
{
    if (isWall) {
        return;
    }
    [AppDelegate sharedDelegate].isWallScreen = YES;
    if (btEdit.selected) {
        [self btEditClick:nil];
    }
    
    // clear table view
    lst_searched = [NSMutableArray new];
    [tbl_chat reloadData];
    
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    
    [self getEntityMessages];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadEntityMessages {
    if (isWall) {
        [self getEntityMessages];
    }
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
    }else{
        if (isWall) {
            [srb_chat becomeFirstResponder];
        }
    }
}

- (void)moveWallHistory{
    [self onWall:nil];
}

@end
