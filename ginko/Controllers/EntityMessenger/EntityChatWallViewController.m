//
//  EntityChatWallViewController.m
//  GINKO
//
//  Created by mobidev on 7/31/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import "EntityChatWallViewController.h"
#import "EntityChatDetailViewController.h"
#import "YYYCommunication.h"
#import "UIImageView+AFNetworking.h"
#import "SVPullToRefresh.h"

#import <MediaPlayer/MediaPlayer.h>
#import <AddressBook/AddressBook.h>

#import "EntityViewController.h"
#import "LocalDBManager.h"
#import "NSBubbleData.h"
#import "MainEntityViewController.h"

#define MAPBOUND	@"!@!#xyz!@#!"

@interface EntityChatWallViewController () <UIActionSheetDelegate>
{
    // for entity messages
    NSBubbleContentType longPressedDataType;
    NSString *longPressedDataPath;
    
    NSMutableArray *arrMessages;
    UIView *vwPhoto;
	UIImageView *imvPhoto;
    
    MBProgressHUD *downloadProgressHUD; // Download progress hud for video
    
    MPMoviePlayerViewController *playerVC;
    
    BOOL isFirst;
}
@end

@implementation EntityChatWallViewController
@synthesize navView, tblWall, lblTitle;
@synthesize entityID, entityImageURL, entityName;
@synthesize lblComment;

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
    isFirst = YES;
    [self.navigationItem setHidesBackButton:YES animated:NO];
    arrMessages = [[NSMutableArray alloc] init];
    
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
    
    [lblComment setHidden:YES];
    
    reloads_ = 0;
    
    pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f tableView:tblWall withClient:self];
    [tblWall addPullToRefreshWithActionHandler:^{
        [self reloadAllMessages];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessageAdding) name:ENTITY_MESSAGE_NOTIFICATION object:nil];
    
    [tblWall deselectRowAtIndexPath:[tblWall indexPathForSelectedRow] animated:animated];
    [self.navigationController.navigationBar addSubview:navView];
    
    lblTitle.text = entityName;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if ([arrMessages count] > 0) {
        [self newMessageAdding];
    }else{
        [self reloadAllMessages];
    }
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    [pullToRefreshManager_ relocatePullToRefreshView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ENTITY_MESSAGE_NOTIFICATION object:nil];
    [navView removeFromSuperview];
}

#pragma mark - UITableView DataSource, Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([arrMessages count] > 0)
        [lblComment setHidden:YES];
    else
        [lblComment setHidden:NO];
    
    return [arrMessages count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 209.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [arrMessages objectAtIndex:indexPath.row];
	
    EntityChatCell *cell = [tblWall dequeueReusableCellWithIdentifier:@"EntityChatCell"];
    
    if(cell == nil)
    {
        cell = [EntityChatCell sharedCell];
    }
    
    cell.entityID = entityID;
    cell.entityName = entityName;
    cell.entityImageURL = entityImageURL;
    cell.messageDict = dict;
    cell.delegate = self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *messageDict = [arrMessages objectAtIndex:indexPath.row];
    NSString *content = [messageDict objectForKey:@"content"];
    if (![[content substringToIndex:1] isEqualToString:@"{"])
    {
        if ([content rangeOfString:MAPBOUND].location != 0) {
            EntityChatDetailViewController *vc = [[EntityChatDetailViewController alloc] initWithNibName:@"EntityChatDetailViewController" bundle:nil];
            vc.strProfileImageURL = entityImageURL;
            vc.strMessage  = [messageDict objectForKey:@"content"];
            vc.strSentTime = [messageDict objectForKey:@"sent_time"];
            vc.strEntityName = entityName;
            [self presentViewController:vc animated:YES completion:nil];
        }
    }
    return;
}

#pragma mark -
#pragma mark MNMBottomPullToRefreshManagerClient
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [pullToRefreshManager_ tableViewScrolled];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [pullToRefreshManager_ tableViewReleased];
}

- (void)bottomPullToRefreshTriggered:(MNMBottomPullToRefreshManager *)manager {
    
    [self performSelector:@selector(getAllMessages) withObject:nil afterDelay:1.0f];
}

#pragma mark - EntityChatCell Delegate
- (void)didAvatar:(NSDictionary *)messageDict
{
    if (!self.isFromProfile) {
        
        APPDELEGATE.isPlayingAudio = NO;
        [self getEntityFollowerView:entityID following:YES notes:[messageDict objectForKey:@"notes"]];
    }
}

- (void)didReturn:(NSDictionary *)messageDict
{
    NSString *content = [messageDict objectForKey:@"content"];
    if (![[content substringToIndex:1] isEqualToString:@"{"])
    {
        if ([content rangeOfString:MAPBOUND].location != 0) {
            APPDELEGATE.isPlayingAudio = NO;
            EntityChatDetailViewController *vc = [[EntityChatDetailViewController alloc] initWithNibName:@"EntityChatDetailViewController" bundle:nil];
            vc.strProfileImageURL = entityImageURL;
            vc.strMessage  = [messageDict objectForKey:@"content"];
            vc.strSentTime = [messageDict objectForKey:@"sent_time"];
            vc.strEntityName = entityName;
            [self presentViewController:vc animated:YES completion:nil];
        }
    }
}

- (void)didContent:(NSDictionary *)messageDict
{
    return;
}

- (void)didEntityName:(NSDictionary *)messageDict
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
    
    [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share", nil] showInView:self.navigationController.view];
}

- (void)videoLongPressed:(NSString *)videoPath {
    longPressedDataType = NSBubbleContentTypeVideo;
    longPressedDataPath = videoPath;
    
    [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share", nil] showInView:self.navigationController.view];
}

- (void)voiceLongPressed:(NSString *)audioPath {
    longPressedDataType = NSBubbleContentTypeVoice;
    longPressedDataPath = audioPath;
    
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
-(void)getEntityFollowerView:(NSString *)entityID_ following:(BOOL)isFollowing notes:(NSString *)notes
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
            }else if([_responseObject[@"data"][@"infos"] count] == 1){
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

#pragma mark - Web API Integration
-(void)newMessageAdding {
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            NSMutableArray *arrTmpMessages = [[NSMutableArray alloc] init];
            arrTmpMessages = [arrMessages mutableCopy];
            
            NSMutableArray *arrTmpMessagesForRemove = [[NSMutableArray alloc] init];
            arrTmpMessagesForRemove = [arrMessages mutableCopy];
            [arrMessages removeAllObjects];
            
            if (![APPDELEGATE.removedMsgIdsForEntity isEqualToString:@""]) {
                NSArray *idsArr = [APPDELEGATE.removedMsgIdsForEntity componentsSeparatedByString:@","];
                for (int i = 0; i < idsArr.count; i ++) {
                    NSString *removeId = [idsArr objectAtIndex:i];
                    for (NSDictionary *dic in arrTmpMessages)
                    {
                        if ([[dic objectForKey:@"msg_id"] integerValue] == [removeId integerValue]) {
                            [arrTmpMessagesForRemove removeObject:dic];
                        }
                    }
                }
            }
            
            
            for (NSDictionary *dict in [[_responseObject objectForKey:@"data"] objectForKey:@"data"])
            {
                if ([dict objectForKey:@"msg_id"]){
                    if ([arrTmpMessagesForRemove containsObject:dict]) {
                        for (NSDictionary *dc in arrTmpMessagesForRemove) {
                            [arrMessages addObject:dc];
                        }
                        break;
                    }else{
                        [arrMessages addObject:dict];
                    }
                }
            }
            
            [tblWall reloadData];
            
            [pullToRefreshManager_ tableViewReloadFinished];
            [tblWall.pullToRefreshView stopAnimating];
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
    } ;
    
    [[YYYCommunication sharedManager] getAllEntityMessages:[AppDelegate sharedDelegate].sessionId entityid:entityID pageNum:@"0" countPerPage:@"20" successed:successed failure:failure];
}
-(void)reloadAllMessages {
    reloads_ = 0;
//    [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Got Entity post!"];
    [self getAllMessages];
}

-(void)getAllMessages
{
    reloads_++;
	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
		
		if ([[_responseObject objectForKey:@"success"] boolValue])
		{
//			[arrMessages removeAllObjects];
			if(reloads_ == 1)
                [arrMessages removeAllObjects];
			for (NSDictionary *dict in [[_responseObject objectForKey:@"data"] objectForKey:@"data"])
            {
                if ([dict objectForKey:@"msg_id"])
                    [arrMessages addObject:dict];
            }
			
			[tblWall reloadData];
            
            [pullToRefreshManager_ tableViewReloadFinished];
            [tblWall.pullToRefreshView stopAnimating];
		}
    } ;
    
	void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        
		[MBProgressHUD hideHUDForView:self.view animated:YES];
		
    } ;
    
    
    
    [[YYYCommunication sharedManager] getAllEntityMessages:[AppDelegate sharedDelegate].sessionId entityid:entityID pageNum:[NSString stringWithFormat:@"%lu", (unsigned long)reloads_] countPerPage:@"10" successed:successed failure:failure];
}

#pragma mark = Actions
-(IBAction)btPhotoDoneClick:(id)sender
{
	[imvPhoto setImage:nil];
	[vwPhoto removeFromSuperview];
}

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    APPDELEGATE.isPlayingAudio = NO;
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
