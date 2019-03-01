//
//  PreviewProfileViewController.m
//  ginko
//
//  Created by STAR on 15/12/29.
//  Copyright © 2015年 com.xchangewithme. All rights reserved.
//

#import "PreviewProfileViewController.h"
#import "ManageProfileViewController.h"
#import "LocalDBManager.h"
#import "UIImageView+AFNetworking.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MessageUI/MessageUI.h>
#import "YYYChatViewController.h"
#import "YYYCommunication.h"
#import "ProfileRequestController.h"
#import "InvitationQueryViewController.h"
#import "UIImage+Tint.h"
#import "PreviewFieldCell.h"
#import "GreyAddNotesController.h"
#import "ProfileViewController.h"
#import "VideoVoiceConferenceViewController.h"

@interface PreviewProfileViewController () <MFMailComposeViewControllerDelegate, TTTAttributedLabelDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate> {
    NSMutableArray *companyntitle;
    NSMutableArray *phones;
    NSMutableArray *emails;
    NSMutableArray *addresses;
    NSMutableArray *birthday;
    NSMutableArray *socials;
    NSMutableArray *website;
    NSMutableArray *customs;
    
    NSMutableArray *sections;
    
    NSString *_videoUrl;
    
    // video player
    MPMoviePlayerViewController *_playerVC;
    
    MBProgressHUD *_downloadProgressHUD; // Download progress hud for video
    
    BOOL _isViewMore;
    
    BOOL _shouldShowMore;
    NSIndexPath *_lastIndexPath;
    
    BOOL _didDetermineShowMore;
    
    CGFloat _tableHeight;
    
    BOOL homeExist, workExist, isExistForDirectoryUser;
}

@end

@implementation PreviewProfileViewController
@synthesize appDelegate;
@synthesize strNotes, directoryUser, groupInfo;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableHeight = 0;
    
    self.title = @"Preview";
    
    profileObserveView.hidden = YES;
    // for invitation viewcontroller
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    strNotes = @"";
    if ([_userData objectForKey:@"is_favorite"]) {
        _btFavorite.selected = [[_userData objectForKey:@"is_favorite"] boolValue];
    }
    if (directoryUser) {
        _btFavorite.hidden = YES;
        _noteDetailsBtn.hidden = YES;
    }else{
        _btFavorite.hidden = NO;
        _noteDetailsBtn.hidden = NO;
    }
    homeExist = (_userData[@"home"][@"fields"] && [_userData[@"home"][@"fields"] count] != 0);
    workExist = (_userData[@"work"][@"fields"] && [_userData[@"work"][@"fields"] count] != 0);
    
    isExistForDirectoryUser = NO;
    
    if (_isViewOnly) {
        strNotes = [_userData objectForKey:@"notes"];
        if (!_isChat) {
//            UIBarButtonItem *chatButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BtnChatNav"] style:UIBarButtonItemStylePlain target:self action:@selector(doChat:)];
//            UIBarButtonItem *videoChatButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"videocalling"] style:UIBarButtonItemStylePlain target:self action:@selector(doChat:)];
//            UIBarButtonItem *voiceChatButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"voicecalling"] style:UIBarButtonItemStylePlain target:self action:@selector(doChat:)];
//            self.navigationItem.rightBarButtonItems = @[chatButton,voiceChatButton, videoChatButton];
            UIView *chatView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 132, 44)];
            UIButton *videoBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
            [videoBtn setImage:[UIImage imageNamed:@"videocalling"] forState:UIControlStateNormal];
            [videoBtn addTarget:self action:@selector(doVideoChat:) forControlEvents:UIControlEventTouchUpInside];
            UIButton *voiceBtn = [[UIButton alloc] initWithFrame:CGRectMake(45, 0, 44, 44)];
            [voiceBtn setImage:[UIImage imageNamed:@"voicecalling"] forState:UIControlStateNormal];
            [voiceBtn addTarget:self action:@selector(doVoiceChat:) forControlEvents:UIControlEventTouchUpInside];
            UIButton *chatBtn = [[UIButton alloc] initWithFrame:CGRectMake(89, 0, 44, 44)];
            [chatBtn setImage:[UIImage imageNamed:@"BtnChatNav"] forState:UIControlStateNormal];
            [chatBtn addTarget:self action:@selector(doChat:) forControlEvents:UIControlEventTouchUpInside];
            //[chatView addSubview:videoBtn];
            [chatView addSubview:voiceBtn];
            [chatView addSubview:chatBtn];
            UIBarButtonItem *chatToolItemBtn = [[UIBarButtonItem alloc] initWithCustomView:chatView];
            self.navigationItem.rightBarButtonItem = chatToolItemBtn;
        }
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        view.backgroundColor = [UIColor clearColor];
        
        //checking if current user exists on main contact
        
        if (directoryUser) {
            for (NSDictionary *dic in APPDELEGATE.totalList) {
                if ([[dic objectForKey:@"contact_type"] integerValue] == 1) {
                    if ([[dic objectForKey:@"contact_id"] integerValue] == [[_userData objectForKey:@"user_id"] integerValue]) {
                        isExistForDirectoryUser = YES;
                    }
                }
            }
        }else if (!APPDELEGATE.isConferenceView){
            isExistForDirectoryUser = YES;
            UIButton *requestButton = [[UIButton alloc] initWithFrame:view.bounds];
            [requestButton setImage:[UIImage imageNamed:@"EditNav"] forState:UIControlStateNormal];
            [requestButton addTarget:self action:@selector(openProfileRequest:) forControlEvents:UIControlEventTouchUpInside];
            requestButton.frame = view.frame;
            
            [view addSubview:requestButton];
            
            self.navigationItem.titleView = view;
        }
        
        if (!isExistForDirectoryUser && !APPDELEGATE.isConferenceView) {//for directory member
            UIButton *requestButton = [[UIButton alloc] initWithFrame:view.bounds];
            [requestButton setImage:[UIImage imageNamed:@"EditNav"] forState:UIControlStateNormal];
            [requestButton addTarget:self action:@selector(openProfileRequest:) forControlEvents:UIControlEventTouchUpInside];
            requestButton.frame = view.frame;
            
            [view addSubview:requestButton];
            
            self.navigationItem.titleView = view;
        }
        
        if (!homeExist)
            _homeButton.enabled = NO;
        if (!workExist)
            _workButton.enabled = NO;
    } else {
        // add Edit and Done button in nav bar
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editProfile:)];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneProfile:)];
        self.navigationItem.leftBarButtonItem = editButton;
        self.navigationItem.rightBarButtonItem = doneButton;
        
        // does not have home
        if (!homeExist) {
            [_homeButton setImage:[[UIImage imageNamed:@"add_home_profile_button"] tintImageWithColor:COLOR_PURPLE_THEME] forState:UIControlStateNormal];
        }
        if (!workExist) {
            [_workButton setImage:[[UIImage imageNamed:@"add_work_profile_button"] tintImageWithColor:COLOR_PURPLE_THEME] forState:UIControlStateNormal];
        }
    }
    
    // set content mode and corner radius for header view
    _wallpaperImageView.contentMode = UIViewContentModeScaleAspectFill;
    _profileImageView.contentMode = UIViewContentModeScaleAspectFill;
    _profileImageContainerView.layer.cornerRadius = CGRectGetWidth(_profileImageContainerView.bounds) / 2;
    _profileImageView.layer.cornerRadius = CGRectGetWidth(_profileImageView.bounds) / 2;
    _profileImageView.layer.borderWidth = 1;
    _profileImageView.layer.borderColor = COLOR_PURPLE_THEME.CGColor;
    
//    profileImageViewLarge.contentMode = UIViewContentModeScaleAspectFit;
//    borderViewForProfile.layer.cornerRadius = CGRectGetWidth(borderViewForProfile.bounds) / 2;
//    profileImageViewLarge.layer.cornerRadius = CGRectGetWidth(profileImageViewLarge.bounds) / 2;
//    borderViewForProfile.layer.borderWidth = 4;
//    borderViewForProfile.layer.borderColor = COLOR_PURPLE_THEME.CGColor;
    
    profileImageViewLarge.layer.cornerRadius = profileImageViewLarge.frame.size.height / 2.0f;
    profileImageViewLarge.layer.masksToBounds = YES;
    profileImageViewLarge.layer.borderColor = COLOR_PURPLE_THEME.CGColor;
    profileImageViewLarge.layer.borderWidth = 4.0f;
    borderViewForProfile.hidden = YES;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideProfileImage)];
    // tapGestureRecognizer.cancelsTouchesInView = NO;
    tapGestureRecognizer.delegate = self;
    [profileObserveView addGestureRecognizer:tapGestureRecognizer];
    
    
    
    // automatic row calculation
    _fieldTable.estimatedRowHeight = 44;
    _fieldTable.rowHeight = UITableViewAutomaticDimension;
    _fieldTable.tableHeaderView = _headerView;
    _fieldTable.separatorStyle = UITableViewCellSeparatorStyleNone;

    [_fieldTable registerNib:[UINib nibWithNibName:@"PreviewFieldCell" bundle:nil] forCellReuseIdentifier:@"PreviewFieldCell"];
    
    UISwipeGestureRecognizer *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    [leftSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [_fieldTable addGestureRecognizer:leftSwipeRecognizer];
    
    UISwipeGestureRecognizer *rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    [rightSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [_fieldTable addGestureRecognizer:rightSwipeRecognizer];
    
    leftSwipeRecognizer.delegate = self;
    rightSwipeRecognizer.delegate = self;
    
    _isViewMore = NO;
    
    [self reloadCurrentProfile];
    
    if (homeExist && _isSelected) {
        [self navigateToHome:self];
    }
    if (workExist && !_isSelected){
        [self navigateToWork:self];
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_userData && isExistForDirectoryUser) {
        _btFavorite.hidden = YES;
        void ( ^successed )( id _responseObject ) = ^( id _responseObject )
        {
            NSDictionary *result = _responseObject;
            if ([[result objectForKey:@"success"] boolValue]) {
                NSDictionary *dict = [_responseObject objectForKey:@"data"];
                _btFavorite.hidden = NO;
                if ([dict objectForKey:@"is_favorite"]) {
                    _btFavorite.selected = [[dict objectForKey:@"is_favorite"] boolValue];
                }
                strNotes = [dict objectForKey:@"notes"];
                if (directoryUser) {
                    _btFavorite.hidden = YES;
                    _noteDetailsBtn.hidden = YES;
                }else{
                    _btFavorite.hidden = NO;
                    _noteDetailsBtn.hidden = NO;
                }
            } else {
                _btFavorite.hidden = NO;
                NSDictionary *dictError = [result objectForKey:@"err"];
                if (dictError) {
                    [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:[dictError objectForKey:@"errMsg"]];
                    if ([[NSString stringWithFormat:@"%@",[dictError objectForKey:@"errCode"]] isEqualToString:@"350"]) {
                        [[AppDelegate sharedDelegate] GetContactList];
                    }
                } else {
                    [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Failed to connect to server!"];
                    }
            }
            
        } ;
        
        void ( ^failure )( NSError* _error ) = ^( NSError* _error )
        {
            _btFavorite.hidden = NO;
            [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Failed to connect to server!"];
        } ;
        if (directoryUser) {
            [[Communication sharedManager] getContactDetail:[AppDelegate sharedDelegate].sessionId contactId:[_userData objectForKey:@"user_id"] contactType:@"1" successed:successed failure:failure];
        }else{
            [[Communication sharedManager] getContactDetail:[AppDelegate sharedDelegate].sessionId contactId:[_userData objectForKey:@"contact_id"] contactType:@"1" successed:successed failure:failure];
        }
    }
    
}
- (void)swipeLeft:(id)sender
{
    if(_homeButton.enabled)
    {
        [self navigateToHome:self];
    }
}

- (void)swipeRight:(id)sender
{
    if(_workButton.enabled)
    {
        [self navigateToWork:self];
    }
}

- (void)determineShowMore {
    _didDetermineShowMore = YES;
    if (_videoUrl && _fieldTable.contentSize.height > CGRectGetHeight(_fieldTable.bounds) + 113) { // show "Show more" only when video exists
        // subtract 226 / 2 = 113 from content size height
        NSIndexPath *indexPath = [_fieldTable indexPathForRowAtPoint:CGPointMake(0, CGRectGetHeight(_fieldTable.bounds) - 113 - 20 - 20 - 22)];
        if (indexPath) {
            _shouldShowMore = YES;
            _lastIndexPath = indexPath;
            [_fieldTable reloadData];
        }
    }
}

- (void)viewDidLayoutSubviews {
    _tableHeight = CGRectGetHeight(_fieldTable.bounds);
    
    if (!_didDetermineShowMore) {
        [self determineShowMore];
    }
}

- (void)reloadCurrentProfile {
    _didDetermineShowMore = NO;
    _shouldShowMore = NO;
    _lastIndexPath = nil;
    
    // toolbar cap
    _homeCapView.hidden = _isWork;
    _workCapView.hidden = !_isWork;
    
    NSDictionary *userDataDic = !_isWork ? _userData[@"home"] : _userData[@"work"];
    NSArray *fieldsArray = userDataDic[@"fields"];
    
    // name
    _nameLabel.text = @"";
    NSArray *nameArray = [fieldsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"field_name == %@", @"Name"]];
    if (nameArray.count > 0) {
        NSDictionary *nameFieldDic = nameArray[0];
        _nameLabel.text = nameFieldDic[@"field_value"];
    }
    
    // parse wallpaper
    NSArray *imagesArray = userDataDic[@"images"];
    [_wallpaperLoadingIndicator stopAnimating];
    _wallpaperImageView.image = [UIImage imageNamed:@"DummyProfileImage"];
    for (NSDictionary *imageDic in imagesArray) {
        if ([imageDic[@"z_index"] intValue] == 0) { // this is background
            NSString *wallpaperImageUrl = imageDic[@"image_url"];
            
            if (wallpaperImageUrl && ![wallpaperImageUrl isEqualToString:@""]) {
                NSString *localFilePath = [LocalDBManager checkCachedFileExist:wallpaperImageUrl];
                if (localFilePath) {
                    // load from local
                    _wallpaperImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:localFilePath]];
                } else {
                    [_wallpaperLoadingIndicator startAnimating];
                    [_wallpaperImageView cancelImageRequestOperation];
                    [_wallpaperImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:wallpaperImageUrl]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                        [_wallpaperImageView setImage:image];
                        [LocalDBManager saveImage:image forRemotePath:wallpaperImageUrl];
                        [_wallpaperLoadingIndicator stopAnimating];
                    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to load wallpaper image." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                        [_wallpaperLoadingIndicator stopAnimating];
                    }];
                }
            } else {
                _wallpaperImageView.image = nil;
            }
        }
    }
    
    // parse profile image
    NSString *profileImageUrl = userDataDic[@"profile_image"];
    
    [_profileImageLoadingIndicator stopAnimating];
    if (profileImageUrl && ![profileImageUrl isEqualToString:@""]) {
        NSString *localFilePath = [LocalDBManager checkCachedFileExist:profileImageUrl];
        if (localFilePath) {
            // load from local
            _profileImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:localFilePath]];
            profileImageViewLarge.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:localFilePath]];
            
        } else {
            [_profileImageLoadingIndicator startAnimating];
            [_profileImageView cancelImageRequestOperation];
            [_profileImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:profileImageUrl]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                [_profileImageView setImage:image];
                [profileImageViewLarge setImage:image];
                [LocalDBManager saveImage:image forRemotePath:profileImageUrl];
                [_profileImageLoadingIndicator stopAnimating];
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to load wallpaper image." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                [_profileImageLoadingIndicator stopAnimating];
            }];
        }
    } else {
        _profileImageView.image = nil;
        profileImageViewLarge.image = nil;
    }
    
    // set privilege
    NSArray *privilegeArray = [fieldsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"field_name == %@", @"Privilege"]];
    if(!_isViewOnly){
        if (privilegeArray.count > 0) {
            _privilegeImageView.hidden = NO;
            _btFavorite.hidden = YES;
            
            _noteDetailsBtn.hidden = YES;
            int privilege = [privilegeArray[0][@"field_value"] intValue];
            _privilegeImageView.image = [UIImage imageNamed:(privilege == 1) ? @"personal_profile_preview_unlocked" : @"personal_profile_preview_locked"];
        } else {
            _privilegeImageView.hidden = YES;
            _btFavorite.hidden = NO;
            _noteDetailsBtn.hidden = NO;
            if (directoryUser) {
                _btFavorite.hidden = YES;
                _noteDetailsBtn.hidden = YES;
            }else{
                _btFavorite.hidden = NO;
                _noteDetailsBtn.hidden = NO;
            }
        }
    }else
    {
        _privilegeImageView.hidden = YES;
        _btFavorite.hidden = NO;
        _noteDetailsBtn.hidden = NO;
        if (directoryUser) {
            _btFavorite.hidden = YES;
            _noteDetailsBtn.hidden = YES;
        }else{
            _btFavorite.hidden = NO;
            _noteDetailsBtn.hidden = NO;
        }
    }
    
    
    // parse fields
    companyntitle = [NSMutableArray new];
    phones = [NSMutableArray new];
    emails = [NSMutableArray new];
    addresses = [NSMutableArray new];
    birthday = [NSMutableArray new];
    socials = [NSMutableArray new];
    website = [NSMutableArray new];
    customs = [NSMutableArray new];
    
    sections = [NSMutableArray new];
    
    NSArray *allFields = @[@"Name", @"Company", @"Title", @"Mobile", @"Mobile#2", @"Mobile#3", @"Phone", @"Phone#2", @"Phone#3", @"Email", @"Email#2", @"Address", @"Address#2", @"Fax", @"Birthday", @"Facebook", @"Twitter", @"LinkedIn", @"Website", @"Custom", @"Custom#2", @"Custom#3"];
    
    for (NSString *fieldName in allFields) {
        NSArray *filteredArray = [fieldsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"field_name == %@", fieldName]];
        if (filteredArray.count > 0) {
            NSString *fieldType = [self getFieldTypeForFieldName:fieldName];
            if ([fieldType isEqualToString:@"company"] || [fieldType isEqualToString:@"title"]) {
                [companyntitle addObject:filteredArray[0]];
            } else if ([fieldType isEqualToString:@"mobile"] || [fieldType isEqualToString:@"phone"]) {
                [phones addObject:filteredArray[0]];
            } else if ([fieldType isEqualToString:@"fax"]) {
                [phones addObject:filteredArray[0]];
            } else if ([fieldType isEqualToString:@"email"]) {
                [emails addObject:filteredArray[0]];
            } else if ([fieldType isEqualToString:@"address"]) {
                [addresses addObject:filteredArray[0]];
            } else if ([fieldType isEqualToString:@"date"]) {
                [birthday addObject:filteredArray[0]];
            } else if ([fieldType isEqualToString:@"facebook"] || [fieldType isEqualToString:@"twitter"] || [fieldType isEqualToString:@"linkedin"]) {
                [socials addObject:filteredArray[0]];
            } else if ([fieldType isEqualToString:@"url"]) {
                [website addObject:filteredArray[0]];
            } else if ([fieldType isEqualToString:@"custom"]) {
                [customs addObject:filteredArray[0]];
            }
        }
    }
    
    if (companyntitle.count > 0) {
        [sections addObject:companyntitle];
    }
    if (phones.count > 0) {
        [sections addObject:phones];
    }
    if (emails.count > 0) {
        [sections addObject:emails];
    }
    if (addresses.count > 0) {
        [sections addObject:addresses];
    }
    if (birthday.count > 0) {
        [sections addObject:birthday];
    }
    if (socials.count > 0) {
        [sections addObject:socials];
    }
    if (website.count > 0) {
        [sections addObject:website];
    }
    if (customs.count > 0) {
        [sections addObject:customs];
    }
    
    // parse video
    NSDictionary *videoDic = userDataDic[@"video"];
    if ([videoDic isKindOfClass:[NSDictionary class]] && videoDic && videoDic[@"id"]) {
        // video exists
        _fieldTable.tableFooterView = _footerView;
        
        // load snapshot image
        NSString *thumbnailUrl = videoDic[@"thumbnail_url"];
        if (thumbnailUrl && ![thumbnailUrl isEqualToString:@""]) {
            NSString *localFilePath = [LocalDBManager checkCachedFileExist:thumbnailUrl];
            if (localFilePath) {
                // load from local
                _snapshotImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:localFilePath]];
            } else {
                [_snapshotImageView cancelImageRequestOperation];
                [_snapshotImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:thumbnailUrl]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                    [_snapshotImageView setImage:image];
                    [LocalDBManager saveImage:image forRemotePath:thumbnailUrl];
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to load video snapshot image." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }];
            }
        }
        
        NSString *videoUrl = videoDic[@"video_url"];
        if (videoUrl && ![videoUrl isEqualToString:@""]) {
            _videoUrl = videoUrl;
        } else {
            _videoUrl = nil;
        }
    } else {
        _videoUrl = nil;
        _fieldTable.tableFooterView = nil;
    }
    
    [_fieldTable reloadData];
    
    if (_tableHeight != 0) {
        [self determineShowMore];
    }
}

- (NSString *)getFieldTypeForFieldName:(NSString *)fieldName {
    NSString *fieldType = nil;
    if ([fieldName rangeOfString:@"Name"].location != NSNotFound) {
        fieldType = @"name";
    } else if ([fieldName rangeOfString:@"Company"].location != NSNotFound) {
        fieldType = @"company";
    } else if ([fieldName rangeOfString:@"Title"].location != NSNotFound) {
        fieldType = @"title";
    } else if ([fieldName rangeOfString:@"Mobile"].location != NSNotFound) {
        fieldType = @"mobile";
    } else if ([fieldName rangeOfString:@"Phone"].location != NSNotFound) {
        fieldType = @"phone";
    } else if ([fieldName rangeOfString:@"Fax"].location != NSNotFound) {
        fieldType = @"fax";
    } else if ([fieldName rangeOfString:@"Email"].location != NSNotFound) {
        fieldType = @"email";
    } else if ([fieldName rangeOfString:@"Address"].location != NSNotFound) {
        fieldType = @"address";
    } else if ([fieldName rangeOfString:@"Birthday"].location != NSNotFound) {
        fieldType = @"date";
    } else if ([fieldName rangeOfString:@"Facebook"].location != NSNotFound) {
        fieldType = @"facebook";
    } else if ([fieldName rangeOfString:@"Twitter"].location != NSNotFound) {
        fieldType = @"twitter";
    } else if ([fieldName rangeOfString:@"LinkedIn"].location != NSNotFound) {
        fieldType = @"linkedin";
    } else if ([fieldName rangeOfString:@"Website"].location != NSNotFound) {
        fieldType = @"url";
    } else if ([fieldName rangeOfString:@"Custom"].location != NSNotFound) {
        fieldType = @"custom";
    }
    return fieldType;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playVideo:(id)sender {
    if (!_videoUrl || _isFromVideoChat)
        return;
    
    NSString *localFilePath = [LocalDBManager checkCachedFileExist:_videoUrl];
    if (localFilePath) { // exists in local
        [self playVideoAtLocalPath:localFilePath];
    } else {
        // save to temp directory
        NSURL *url = [NSURL URLWithString:_videoUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
        NSProgress *progress;
        
        _downloadProgressHUD = [MBProgressHUD showHUDAddedTo:[AppDelegate sharedDelegate].window animated:YES];
        _downloadProgressHUD.mode = MBProgressHUDModeDeterminate;
        
        NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            return [NSURL fileURLWithPath:[LocalDBManager getCachedFileNameFromRemotePath:_videoUrl]];
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            [progress removeObserver:self forKeyPath:@"fractionCompleted" context:NULL];
            [_downloadProgressHUD hide:YES];
            if (!error) {
                [self playVideoAtLocalPath:[LocalDBManager getCachedFileNameFromRemotePath:_videoUrl]];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not download video, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }];
        
        [downloadTask resume];
        [progress addObserver:self
                   forKeyPath:@"fractionCompleted"
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
    }
}

- (IBAction)onProfileFavorite:(id)sender {
    _btFavorite.selected = !_btFavorite.selected;
    if (_btFavorite.selected) {
        [appDelegate addFavoriteContact:[_userData objectForKey:@"contact_id"] contactType:@"1"];
    }else{
        [appDelegate removeFavoriteContact:[_userData objectForKey:@"contact_id"] contactType:@"1"];
    }
}

- (IBAction)onNoteBtn:(id)sender {
    GreyAddNotesController *vc = [[GreyAddNotesController alloc] initWithNibName:@"GreyAddNotesController" bundle:nil];
    [vc setParentController:self];
    if (![strNotes isEqualToString:@""]) {
        vc.strNotes = strNotes;
    }
    [self presentViewController:vc animated:YES completion:nil];
}
- (void)updateNotes
{
        [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    
    	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
    
                void ( ^successed )( id _responseObject ) = ^( id _responseObject )
                {
                    
                    [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
                    NSDictionary *result = _responseObject;
                    if ([[result objectForKey:@"success"] boolValue]) {
                        NSDictionary *dict = [_responseObject objectForKey:@"data"];
                        if ([dict objectForKey:@"is_favorite"]) {
                            _btFavorite.selected = [[dict objectForKey:@"is_favorite"] boolValue];
                        }
                        strNotes = [dict objectForKey:@"notes"];
                    } else {
                        NSDictionary *dictError = [result objectForKey:@"err"];
                        if (dictError) {
                            [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:[dictError objectForKey:@"errMsg"]];
                            if ([[NSString stringWithFormat:@"%@",[dictError objectForKey:@"errCode"]] isEqualToString:@"350"]) {
                                [[AppDelegate sharedDelegate] GetContactList];
                            }
                        } else {
                            [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Failed to connect to server!"];
                        }
                    }
                    
                } ;
                
                void ( ^failure )( NSError* _error ) = ^( NSError* _error )
                {
                
                    [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
                    [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Failed to connect to server!"];
                } ;
                if (directoryUser) {
                    [[Communication sharedManager] getContactDetail:[AppDelegate sharedDelegate].sessionId contactId:[_userData objectForKey:@"user_id"] contactType:@"1" successed:successed failure:failure];
                }else{
                    [[Communication sharedManager] getContactDetail:[AppDelegate sharedDelegate].sessionId contactId:[_userData objectForKey:@"contact_id"] contactType:@"1" successed:successed failure:failure];
                }
            
        } ;
    
        void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
            [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
    
            NSLog(@"Connection failed - %@", _error);
        } ;
    if (directoryUser) {
        [[Communication sharedManager] UpdateNote:[AppDelegate sharedDelegate].sessionId  contactIds:[[_userData objectForKey:@"user_id"] stringValue] notes:strNotes successed:successed failure:failure];
    }else{
        [[Communication sharedManager] UpdateNote:[AppDelegate sharedDelegate].sessionId  contactIds:[[_userData objectForKey:@"contact_id"] stringValue] notes:strNotes successed:successed failure:failure];
    }
}

- (IBAction)onProfileObserve:(id)sender {
    profileObserveView.hidden = NO;
    CATransition *transition = [CATransition animation];
    transition.duration = 1.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionReveal;
    transition.delegate = self;
    [borderViewForProfile.layer addAnimation:transition forKey:nil];
    
//    CGAffineTransform translate = CGAffineTransformMakeTranslation(_profileImageContainerView.frame.origin.x,_profileImageContainerView.frame.origin.y);
//    CGAffineTransform scale = CGAffineTransformMakeScale(0.6, 0.6);
//    CGAffineTransform transform =  CGAffineTransformConcat(translate, scale);
//    transform = CGAffineTransformRotate(transform, 0);
//    
//    [UIView beginAnimations:@"MoveAndRotateAnimation" context:nil];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//    [UIView setAnimationDuration:2.0];
//    
//    borderViewForProfile.transform = transform;
//    
//    [UIView commitAnimations];
    
    borderViewForProfile.hidden = NO;
}

- (IBAction)onCloseProfileObserveView:(id)sender {
    
    CATransition *transition = [CATransition animation];
    transition.duration = 2.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    transition.delegate = self;
    [borderViewForProfile.layer addAnimation:transition forKey:nil];
    profileObserveView.hidden = YES;
    borderViewForProfile.hidden = YES;
}
- (void)hideProfileImage{
    CATransition *transition = [CATransition animation];
    transition.duration = 2.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    transition.delegate = self;
    [borderViewForProfile.layer addAnimation:transition forKey:nil];
    profileObserveView.hidden = YES;
    borderViewForProfile.hidden = YES;
}
- (void)playVideoAtLocalPath:(NSString *)videoPath {
    _playerVC = [[MPMoviePlayerViewController alloc] init];
    
    _playerVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    _playerVC.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
    _playerVC.moviePlayer.contentURL = [NSURL fileURLWithPath:videoPath];
    
    [self presentMoviePlayerViewControllerAnimated:_playerVC];
}

- (void)editProfile:(id)sender {
    ManageProfileViewController *vc = [[ManageProfileViewController alloc] initWithNibName:@"ManageProfileViewController" bundle:nil];
    vc.isCreate = NO;   // this is edit, not create
    vc.isWork = _isWork;
    vc.isSecond = YES;
    vc.isSelected = _isSelected;
    if ([_userData[@"home"][@"fields"] count] > 0)
    {
        if ([_userData[@"work"][@"fields"] count] > 0) {
            vc.mode = ProfileModeBoth;
        } else {
            // work does not exist
            if (_isWork) {
                vc.isCreate = YES;
                vc.mode = ProfileModeBoth;
            } else {
                vc.mode = ProfileModePersonal;
            }
        }
    } else if ([_userData[@"work"][@"fields"] count] > 0) {
        // home does not exist
        if (!_isWork) {
            vc.isCreate = YES;
            vc.mode = ProfileModeBoth;
        } else {
            vc.mode = ProfileModeWork;
        }
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Something wrong with this account, please contact admin." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    vc.userData = _userData;
    
    vc.isSetup = _isSetup;
    
    [self.navigationController pushViewController:vc animated:YES];
    
    NSMutableArray *vcs = [self.navigationController.viewControllers mutableCopy];
    [vcs removeObjectAtIndex:vcs.count - 2];
    [self.navigationController setViewControllers:[vcs copy]];
}

- (void)doneProfile:(id)sender {
    if (_isSetup) {
        InvitationQueryViewController *vc = [[InvitationQueryViewController alloc] initWithNibName:@"InvitationQueryViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
        [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)navigateToWork:(id)sender {
    if (_isWork)
        return;
    
    _isSelected = NO;
    CATransition *animation = [CATransition animation];
    [animation setDelegate:self];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromLeft];
    [animation setDuration:0.30];
    [animation setTimingFunction:
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [_fieldTable.layer addAnimation:animation forKey:kCATransition];

    _isWork = YES;
    _isViewMore = NO;
    
    if (!_isViewOnly && !workExist) {
        [self editProfile:self];
        return;
    }
    
    [self reloadCurrentProfile];
}

- (IBAction)navigateToHome:(id)sender {
    if (!_isWork)
        return;
    
    _isSelected = YES;
    CATransition *animation = [CATransition animation];
    [animation setDelegate:self];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromRight];
    [animation setDuration:0.30];
    [animation setTimingFunction:
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [_fieldTable.layer addAnimation:animation forKey:kCATransition];
    
    _isWork = NO;
    _isViewMore = NO;
    
    if (!_isViewOnly && !homeExist) {
        [self editProfile:self];
        return;
    }
    
    [self reloadCurrentProfile];
}

- (void)showMore:(id)sender {
    _isViewMore = !_isViewMore;
    [_fieldTable reloadData];
}

#pragma mark - Actions for other users
- (void)openProfileRequest:(id)sender
{
    if (directoryUser) {
        if (groupInfo) {
            if (isExistForDirectoryUser) {
                [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
                void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
                    [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
                    
                    if ([[_responseObject objectForKey:@"success"] boolValue])
                    {
                        
                        APPDELEGATE.type = 7;
                        ProfileRequestController * controller = [[ProfileRequestController alloc] initWithNibName:@"ProfileRequestController" bundle:nil];
                        //controller.contactInfo = contactDict;
                        controller.directoryId = [groupInfo objectForKey:@"group_id"];
                        controller.directoryName = [groupInfo objectForKey:@"name"];
                        controller.contactInfo = [_responseObject objectForKey:@"data"];
                        [self.navigationController pushViewController:controller animated:YES];
                    }
                } ;
                
                void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
                    [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
                    
                    [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Internet Connection Error!"];
                } ;
                
                [[YYYCommunication sharedManager] GetPermissionMemberDirectory:APPDELEGATE.sessionId directoryId:[groupInfo objectForKey:@"group_id"]  successed:successed failure:failure];
            }else{
                APPDELEGATE.type = 5;
                ProfileRequestController * controller = [[ProfileRequestController alloc] initWithNibName:@"ProfileRequestController" bundle:nil];
                controller.contactInfo = _userData;
                controller.isRequestForDirectoryUser = YES;
                [self.navigationController pushViewController:controller animated:YES];
            }
        }
    }else{
        [AppDelegate sharedDelegate].type = 4;
        if ([_userData objectForKey:@"detected_location"] && ![[_userData objectForKey:@"detected_location"] isEqualToString:@""])
        {
            ProfileViewController * controller = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
            controller.contactInfo = _userData;
            [self.navigationController pushViewController:controller animated:YES];
        }else{
            [AppDelegate sharedDelegate].type = 4;
            
            ProfileRequestController * controller = [[ProfileRequestController alloc] initWithNibName:@"ProfileRequestController" bundle:nil];
            controller.contactInfo = _userData;
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

- (void)doChat:(id)sender {
    if (directoryUser) {
        [self CreateMessageBoard:[_userData objectForKey:@"user_id"]];
    }else{
        [self CreateMessageBoard:[_userData objectForKey:@"contact_id"]];
    }
}
- (void)doVideoChat:(id)sender {
    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted) {
                    [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your Camera or Microphone is disabled.\nPlease go to settings and grant access to it."];
                }
                else {
                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                        if (!granted) {
                            [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your Camera or Microphone is disabled.\nPlease go to settings and grant access to it."];
                        }
                        else {
                            [self CreateVideoAndVoiceConferenceBoard:[self.userData objectForKey:@"contact_id"] dict:self.userData type:1];
                        }
                    }];
                }
            });
        }];
    }
}
- (void)doVoiceChat:(id)sender {
    if ([[_userData objectForKey:@"phones"] count] == 0)
    {
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            
            [sheet setTag:102];
            [sheet addButtonWithTitle:@"Ginko Video Call"];
            [sheet addButtonWithTitle:@"Ginko Voice Call"];
            [sheet addButtonWithTitle:@"Cancel"];
            sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
            [sheet showInView:self.view];
        
    }
    else if ([[_userData objectForKey:@"phones"] count] == 1){
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            
            [sheet setTag:101];
            [sheet addButtonWithTitle:@"Ginko Video Call"];
            [sheet addButtonWithTitle:@"Ginko Voice Call"];
            [sheet addButtonWithTitle:[[_userData objectForKey:@"phones"] objectAtIndex:0]];
            [sheet addButtonWithTitle:@"Cancel"];
            sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
            [sheet showInView:self.view];
        
    }
    else
    {
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            
            [sheet setTag:100];
            [sheet addButtonWithTitle:@"Ginko Video Call"];
            [sheet addButtonWithTitle:@"Ginko Voice Call"];
            for (int i = 0; i < [[_userData objectForKey:@"phones"] count]; i++)
                [sheet addButtonWithTitle:[[_userData objectForKey:@"phones"] objectAtIndex:i]];
            
            [sheet addButtonWithTitle:@"Cancel"];
            sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
            [sheet showInView:self.view];
    }
    
//    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
//    [sheet setTag:100];
//    [sheet addButtonWithTitle:@"Ginko Video Call"];
//    [sheet addButtonWithTitle:@"Ginko Voice Call"];
//    for (int i = 0; i < [[_userData objectForKey:@"phones"] count]; i++)
//        [sheet addButtonWithTitle:[[_userData objectForKey:@"phones"] objectAtIndex:i]];
//    [sheet addButtonWithTitle:@"Cancel"];
//    sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
//    [sheet showInView:self.view];
}
#pragma - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != (actionSheet.numberOfButtons - 1))
    {
        switch ([actionSheet tag]) {
            case 100:
            {
                
                if (buttonIndex == 0) {
                    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
                        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (!granted) {
                                    [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your Camera or Microphone is disabled.\nPlease go to settings and grant access to it."];
                                }
                                else {
                                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                                        if (!granted) {
                                            [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your Camera or Microphone is disabled.\nPlease go to settings and grant access to it."];
                                        }
                                        else {
                                            if([self.userData objectForKey:@"contact_id"] != nil)
                                                [self CreateVideoAndVoiceConferenceBoard:[self.userData objectForKey:@"contact_id"] dict:self.userData type:1];
                                            else if([self.userData objectForKey:@"user_id"] != nil)
                                                [self CreateVideoAndVoiceConferenceBoard:[self.userData objectForKey:@"user_id"] dict:self.userData type:1];
                                        }
                                    }];
                                }
                            });
                        }];
                    }
                }else if(buttonIndex == 1){
                    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
                        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (!granted) {
                                    [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your Camera or Microphone is disabled.\nPlease go to settings and grant access to it."];
                                }
                                else {
                                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                                        if (!granted) {
                                            [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your Camera or Microphone is disabled.\nPlease go to settings and grant access to it."];
                                        }
                                        else {
                                            if([self.userData objectForKey:@"contact_id"] != nil)
                                                [self CreateVideoAndVoiceConferenceBoard:[self.userData objectForKey:@"contact_id"] dict:self.userData type:2];
                                            else if([self.userData objectForKey:@"user_id"] != nil)
                                                [self CreateVideoAndVoiceConferenceBoard:[self.userData objectForKey:@"user_id"] dict:self.userData type:2];
                                        }
                                    }];
                                }
                            });
                        }];
                    }
                }else{
                    if ([[[_userData objectForKey:@"phones"] objectAtIndex:buttonIndex-2] rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]].location == NSNotFound) {
                        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Invalid mobile number." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                        return;
                    }
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [CommonMethods removeNanString:[[_userData objectForKey:@"phones"] objectAtIndex:buttonIndex-2]]]]];
                }
                break;
            }
            case 101:
            {
                
                if (buttonIndex == 0) {
                    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
                        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (!granted) {
                                    [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your Camera or Microphone is disabled.\nPlease go to settings and grant access to it."];
                                }
                                else {
                                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                                        if (!granted) {
                                            [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your Camera or Microphone is disabled.\nPlease go to settings and grant access to it."];
                                        }
                                        else {
                                            if([self.userData objectForKey:@"contact_id"] != nil)
                                                [self CreateVideoAndVoiceConferenceBoard:[self.userData objectForKey:@"contact_id"] dict:self.userData type:1];
                                            else if([self.userData objectForKey:@"user_id"] != nil)
                                                [self CreateVideoAndVoiceConferenceBoard:[self.userData objectForKey:@"user_id"] dict:self.userData type:1];
                                        }
                                    }];
                                }
                            });
                        }];
                    }
                }else if(buttonIndex == 1){
                    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
                        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (!granted) {
                                    [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your Camera or Microphone is disabled.\nPlease go to settings and grant access to it."];
                                }
                                else {
                                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                                        if (!granted) {
                                            [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your Camera or Microphone is disabled.\nPlease go to settings and grant access to it."];
                                        }
                                        else {
                                            if([self.userData objectForKey:@"contact_id"] != nil)
                                                [self CreateVideoAndVoiceConferenceBoard:[self.userData objectForKey:@"contact_id"] dict:self.userData type:2];
                                            else if([self.userData objectForKey:@"user_id"] != nil)
                                                [self CreateVideoAndVoiceConferenceBoard:[self.userData objectForKey:@"user_id"] dict:self.userData type:2];
                                        }
                                    }];
                                }
                            });
                        }];
                    }
                }else{
                    if ([[[_userData objectForKey:@"phones"] objectAtIndex:0] rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]].location == NSNotFound) {
                        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Invalid mobile number." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                        return;
                    }
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [CommonMethods removeNanString:[[_userData objectForKey:@"phones"] objectAtIndex:0]]]]];
                }
                break;
            }
            case 102:
            {
                
                if (buttonIndex == 0) {
                    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
                        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (!granted) {
                                    [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your Camera or Microphone is disabled.\nPlease go to settings and grant access to it."];
                                }
                                else {
                                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                                        if (!granted) {
                                            [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your Camera or Microphone is disabled.\nPlease go to settings and grant access to it."];
                                        }
                                        else {
                                            if([self.userData objectForKey:@"contact_id"] != nil)
                                                [self CreateVideoAndVoiceConferenceBoard:[self.userData objectForKey:@"contact_id"] dict:self.userData type:1];
                                            else if([self.userData objectForKey:@"user_id"] != nil)
                                                [self CreateVideoAndVoiceConferenceBoard:[self.userData objectForKey:@"user_id"] dict:self.userData type:1];
                                        }
                                    }];
                                }
                            });
                        }];
                    }
                }else if(buttonIndex == 1){
                    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
                        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (!granted) {
                                    [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your Camera or Microphone is disabled.\nPlease go to settings and grant access to it."];
                                }
                                else {
                                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                                        if (!granted) {
                                            [CommonMethods showAlertUsingTitle:@"" andMessage:@"Your Camera or Microphone is disabled.\nPlease go to settings and grant access to it."];
                                        }
                                        else {
                                            if([self.userData objectForKey:@"contact_id"] != nil)
                                                [self CreateVideoAndVoiceConferenceBoard:[self.userData objectForKey:@"contact_id"] dict:self.userData type:2];
                                            else if([self.userData objectForKey:@"user_id"] != nil)
                                                [self CreateVideoAndVoiceConferenceBoard:[self.userData objectForKey:@"user_id"] dict:self.userData type:2];
                                        }
                                    }];
                                }
                            });
                        }];
                    }
                }
                break;
            }
            default:
                break;
        }
    }
}
-(void)CreateVideoAndVoiceConferenceBoard:(NSString*)ids dict:(NSDictionary *)contactInfo type:(NSInteger)_type
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            [APPDELEGATE.conferenceMembersForVideoCalling removeAllObjects];
            NSMutableDictionary *dictOfUser = [[NSMutableDictionary alloc] init];
            if([contactInfo valueForKey:@"contact_id"] != nil)
                [dictOfUser setObject:[contactInfo valueForKey:@"contact_id"] forKey:@"user_id"];
            if([contactInfo valueForKey:@"user_id"] != nil)
                [dictOfUser setObject:[contactInfo valueForKey:@"user_id"] forKey:@"user_id"];
            [dictOfUser setObject:[NSString stringWithFormat:@"%@ %@", [contactInfo objectForKey:@"first_name"], [contactInfo objectForKey:@"last_name"]] forKey:@"name"];
            [dictOfUser setObject:[contactInfo objectForKey:@"profile_image"] forKey:@"photo_url"];
            if (_type == 1) {
                [dictOfUser setObject:@"on" forKey:@"videoStatus"];
            }else{
                [dictOfUser setObject:@"off" forKey:@"videoStatus"];
            }
            [dictOfUser setObject:@"on" forKey:@"voiceStatus"];
            [dictOfUser setObject:@(1) forKey:@"conferenceStatus"];
            [dictOfUser setObject:@(0) forKey:@"isOwner"];
            [dictOfUser setObject:@(0) forKey:@"isInvited"];
            [dictOfUser setObject:@(1) forKey:@"isInvitedByMe"];
            
            [APPDELEGATE.conferenceMembersForVideoCalling addObject:dictOfUser];
            
            VideoVoiceConferenceViewController *viewcontroller = [[VideoVoiceConferenceViewController alloc] initWithNibName:@"VideoVoiceConferenceViewController" bundle:nil];
            APPDELEGATE.isOwnerForConference = YES;
            APPDELEGATE.isJoinedOnConference = YES;
            APPDELEGATE.conferenceId = [[_responseObject objectForKey:@"data"] objectForKey:@"board_id"];
            viewcontroller.boardId = [[_responseObject objectForKey:@"data"] objectForKey:@"board_id"];
            viewcontroller.conferenceType = _type;
            viewcontroller.conferenceName =[NSString stringWithFormat:@"%@ %@", [contactInfo objectForKey:@"first_name"], [contactInfo objectForKey:@"last_name"]];
            [self.navigationController pushViewController:viewcontroller animated:YES];
            
        }else{
            [CommonMethods showAlertUsingTitle:@"Error!" andMessage:[[_responseObject objectForKey:@"err"] objectForKey:@"errMsg"]];
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Internet Connection Error!"];
        
    } ;
    
    [[YYYCommunication sharedManager] CreateChatBoard:[AppDelegate sharedDelegate].sessionId userids:ids successed:successed failure:failure];
}
-(void)CreateMessageBoard:(NSString*)ids
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
        
        if ([[_responseObject objectForKey:@"success"] boolValue])
        {
            void ( ^successed )( id _responseObject ) = ^( id _responseObject )
            {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                NSDictionary *result = _responseObject;
                if ([[result objectForKey:@"success"] boolValue]) {
                    YYYChatViewController *viewcontroller = [[YYYChatViewController alloc] initWithNibName:@"YYYChatViewController" bundle:nil];
                    viewcontroller.boardid = [[_responseObject objectForKey:@"data"] objectForKey:@"board_id"];
                    
                    NSArray *members = [[result objectForKey:@"data"] objectForKey:@"members"];
                    if(members.count == 2)
                    {
                        [viewcontroller setPhoneNumbers:_userData];
                    }
                    BOOL isDeleted = YES;
                    for (NSDictionary *memberDic in members) {
                        if ([memberDic[@"is_friend"] boolValue]) {
                            isDeleted = NO;
                        }
                    }
                    
                    NSMutableArray *lstTemp = [[NSMutableArray alloc] init];
                    for (NSDictionary *dictMember in [[result objectForKey:@"data"] objectForKey:@"members"]) {
                        [lstTemp addObject:[dictMember objectForKey:@"memberinfo"]];
                    }
                    if ([[groupInfo objectForKey:@"type"] integerValue] != 2) {
                        viewcontroller.isMemberForDiectory = NO;
                        viewcontroller.isDeletedFriend = isDeleted;
                    }else{
                        viewcontroller.isMemberForDiectory = YES;
                        viewcontroller.isDeletedFriend = NO;
                    }
                    viewcontroller.lstUsers = [[NSMutableArray alloc] initWithArray:lstTemp];
                    [self.navigationController pushViewController:viewcontroller animated:YES];
                }
                
            } ;
            
            void ( ^failure )( NSError* _error ) = ^( NSError* _error )
            {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [CommonMethods showAlertUsingTitle:@"Error!" andMessage:[[_responseObject objectForKey:@"err"] objectForKey:@"errMsg"]];
            } ;
            
            [[Communication sharedManager] GetBoardInformation:APPDELEGATE.sessionId boardid:[NSString stringWithFormat:@"%@",[[_responseObject objectForKey:@"data"] objectForKey:@"board_id"]] successed:successed failure:failure];
            
//            NSMutableArray *lstTemp = [[NSMutableArray alloc] init];
//            NSMutableDictionary *dictTemp = [[NSMutableDictionary alloc] init];
//            
//            [dictTemp setObject:[_userData objectForKey:@"first_name"] forKey:@"fname"];
//            [dictTemp setObject:[_userData objectForKey:@"last_name"] forKey:@"lname"];
//            [dictTemp setObject:[_userData objectForKey:@"profile_image"] forKey:@"photo_url"];
//            [dictTemp setObject:[_userData objectForKey:@"contact_id"] forKey:@"user_id"];
//            
//            [lstTemp addObject:dictTemp];
//            
//            NSMutableDictionary *dictTemp1 = [[NSMutableDictionary alloc] init];
//            
//            [dictTemp1 setObject:[AppDelegate sharedDelegate].firstName forKey:@"fname"];
//            [dictTemp1 setObject:[AppDelegate sharedDelegate].lastName forKey:@"lname"];
//            [dictTemp1 setObject:[AppDelegate sharedDelegate].photoUrl forKey:@"photo_url"];
//            [dictTemp1 setObject:[AppDelegate sharedDelegate].userId forKey:@"user_id"];
//            
//            [lstTemp addObject:dictTemp1];
//            
//            YYYChatViewController *viewcontroller = [[YYYChatViewController alloc] initWithNibName:@"YYYChatViewController" bundle:nil];
//            viewcontroller.boardid = [[_responseObject objectForKey:@"data"] objectForKey:@"board_id"];
//            viewcontroller.lstUsers = [[NSMutableArray alloc] initWithArray:lstTemp];
//            [self.navigationController pushViewController:viewcontroller animated:YES];
            
        }else{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [CommonMethods showAlertUsingTitle:@"Error!" andMessage:[[_responseObject objectForKey:@"err"] objectForKey:@"errMsg"]];
        }
    } ;
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
        
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Internet Connection Error!"];
        
    } ;
    
    [[YYYCommunication sharedManager] CreateChatBoard:[AppDelegate sharedDelegate].sessionId userids:ids successed:successed failure:failure];
}

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    if (section != [self numberOfSectionsInTableView:tableView] - 1 && _isViewMore) {
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 46)];
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 25, CGRectGetWidth(tableView.frame) - 20 * 2, 15)];
//        label.font = [UIFont boldSystemFontOfSize:12];
//        NSMutableArray *selectedArray = sections[section];
//        if ([selectedArray isEqual:companyntitle])
//            label.text = @"";
//        if ([selectedArray isEqual:phones])
//            label.text = @"PHONES";
//        if ([selectedArray isEqual:emails])
//            label.text = @"E-MAILS";
//        if ([selectedArray isEqual:addresses])
//            label.text = @"ADDRESSES";
//        if ([selectedArray isEqual:birthday])
//            label.text = @"BIRTHDAY";
//        if ([selectedArray isEqual:socials])
//            label.text = @"SOCIAL NETWORKS";
//        if ([selectedArray isEqual:website])
//            label.text = @"WEBSITE";
//        if ([selectedArray isEqual:customs])
//            label.text = @"CUSTOMS";
//        
//        [view addSubview:label];
//        view.backgroundColor = [UIColor whiteColor];
//        return view;
//    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 20)];
    
    if (_shouldShowMore && section == [self numberOfSectionsInTableView:tableView] - 1) {
        UIButton *moreButton = [[UIButton alloc] initWithFrame:view.bounds];
        [moreButton setImage:[UIImage imageNamed:_isViewMore ? @"ShowLessButton" : @"ShowMoreButton"] forState:UIControlStateNormal];
        [moreButton setTitle:_isViewMore ? @"Show less" : @"Show more" forState:UIControlStateNormal];
        moreButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        moreButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
        [moreButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [moreButton addTarget:self action:@selector(showMore:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:moreButton];
    }
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _shouldShowMore ? (_isViewMore ? sections.count + 1 : (_lastIndexPath.section + 2)) : sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_shouldShowMore) {
        if (section == [self numberOfSectionsInTableView:tableView] - 1)
            return 0;
        else {
            if (_isViewMore) {
                return [sections[section] count];
            } else {
                if (section == _lastIndexPath.section)
                    return _lastIndexPath.row + 1;
                else {
                    return [sections[section] count];
                }
            }
        }
    } else {
        return [sections[section] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PreviewFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PreviewFieldCell"];
    
    cell.fieldLabel.font = [UIFont systemFontOfSize:15];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.fieldLabel.enabledTextCheckingTypes = 0;
    cell.fieldLabel.delegate = self;
    
    NSDictionary *fieldDic = sections[indexPath.section][indexPath.row];
    
    NSString *fieldType = [self getFieldTypeForFieldName:fieldDic[@"field_name"]];
    if ([fieldType isEqualToString:@"company"]) {
        cell.iconImageView.image = [UIImage imageNamed:@"field_icon_grey_company"];
    } else if ([fieldType isEqualToString:@"title"]) {
        cell.iconImageView.image = [UIImage imageNamed:@"field_icon_grey_title"];
    } else if ([fieldType isEqualToString:@"mobile"]) {
        cell.iconImageView.image = [UIImage imageNamed:@"field_icon_grey_mobile"];
    } else if ([fieldType isEqualToString:@"phone"]) {
        cell.iconImageView.image = [UIImage imageNamed:@"field_icon_grey_phone"];
    } else if ([fieldType isEqualToString:@"fax"]) {
        cell.iconImageView.image = [UIImage imageNamed:@"field_icon_grey_fax"];
    } else if ([fieldType isEqualToString:@"email"]) {
        cell.iconImageView.image = [UIImage imageNamed:@"field_icon_grey_email"];
    } else if ([fieldType isEqualToString:@"address"]) {
        cell.iconImageView.image = [UIImage imageNamed:@"field_icon_grey_address"];
    } else if ([fieldType isEqualToString:@"date"]) {
        cell.iconImageView.image = [UIImage imageNamed:@"field_icon_grey_birthday"];
    } else if ([fieldType isEqualToString:@"facebook"]) {
        cell.iconImageView.image = [UIImage imageNamed:@"field_icon_grey_facebook"];
    } else if ([fieldType isEqualToString:@"twitter"]) {
        cell.iconImageView.image = [UIImage imageNamed:@"field_icon_grey_twitter"];
    } else if ([fieldType isEqualToString:@"linkedin"]) {
        cell.iconImageView.image = [UIImage imageNamed:@"field_icon_grey_linkedin"];
    } else if ([fieldType isEqualToString:@"url"]) {
        cell.iconImageView.image = [UIImage imageNamed:@"field_icon_grey_website"];
    } else if ([fieldType isEqualToString:@"custom"]) {
        cell.iconImageView.image = [UIImage imageNamed:@"field_icon_grey_custom"];
        cell.fieldLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    }
    
    cell.fieldLabel.text = fieldDic[@"field_value"];
    
//    CGSize itemSize = CGSizeMake(20, 20);
//    UIGraphicsBeginImageContextWithOptions(itemSize, NO, 0);
//    CGRect imageRect = CGRectMake((itemSize.width - cell.imageView.image.size.width) / 2, (itemSize.height - cell.imageView.image.size.height) / 2, cell.imageView.image.size.width, cell.imageView.image.size.height);
//    [cell.imageView.image drawInRect:imageRect];
//    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    
    return cell;
}

#pragma mark - Helper methods
- (void)sendMailToEmailAddress:(NSString *)email {
    if([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        [picker setToRecipients:@[email]];
        [picker setSubject:@""];
        
        [self presentViewController:picker animated:YES completion:^{
//            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        }];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Please configure mail accounts to send mail." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
}

#pragma mark - UITableViewCellDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *fieldDic = sections[indexPath.section][indexPath.row];
    NSString *fieldType = [self getFieldTypeForFieldName:fieldDic[@"field_name"]];
    NSString *fieldValue = fieldDic[@"field_value"];
    
    if (!fieldValue || [fieldValue isEqualToString:@""])
        return;
    
    if ([fieldType isEqualToString:@"company"]) {
        
    } else if ([fieldType isEqualToString:@"title"]) {
        
    } else if ([fieldType isEqualToString:@"mobile"] || [fieldType isEqualToString:@"phone"] || [fieldType isEqualToString:@"fax"]) {
        if (_isViewOnly) {
            NSString *phoneNumStr =fieldValue;
            NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"() "];
            phoneNumStr = [[phoneNumStr componentsSeparatedByCharactersInSet:doNotWant] componentsJoinedByString:@""];
            NSURL *phoneUrl = [NSURL URLWithString:[@"telprompt://" stringByAppendingString:phoneNumStr]];
            NSURL *phoneFallbackUrl = [NSURL URLWithString:[@"tel://" stringByAppendingString:phoneNumStr]];
            
            if ([UIApplication.sharedApplication canOpenURL:phoneUrl]) {
                [UIApplication.sharedApplication openURL:phoneUrl];
            } else if ([UIApplication.sharedApplication canOpenURL:phoneFallbackUrl]) {
                [UIApplication.sharedApplication openURL:phoneFallbackUrl];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Your device is not compatible with phone calls." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }
    } else if ([fieldType isEqualToString:@"email"]) {
        if (_isViewOnly) {
            [self sendMailToEmailAddress:fieldValue];
        }
    } else if ([fieldType isEqualToString:@"address"]) {
        if (_isViewOnly) {
            NSString *addressString = [@"http://maps.apple.com/?q=" stringByAppendingString:[[fieldValue stringByReplacingOccurrencesOfString:@" " withString:@"+"] stringByReplacingOccurrencesOfString:@"\n" withString:@"+"]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:addressString]];
        }
    } else if ([fieldType isEqualToString:@"date"]) {
        
    } else if ([fieldType isEqualToString:@"facebook"]) {
        if (_isViewOnly) {
            [self gotoLinkAddress:fieldValue];
        }
    } else if ([fieldType isEqualToString:@"twitter"]) {
        if (_isViewOnly) {
            [self gotoLinkAddress:fieldValue];
        }
    } else if ([fieldType isEqualToString:@"linkedin"]) {
        if (_isViewOnly) {
           [self gotoLinkAddress:fieldValue];
        }
    } else if ([fieldType isEqualToString:@"url"]) {
        [self gotoLinkAddress:fieldValue];
    } else if ([fieldType isEqualToString:@"custom"]) {
        
    }
}

- (void)gotoLinkAddress:(NSString *)address{
    NSURL *url = [[NSURL alloc] initWithString:address];
    
    if (url.scheme.length == 0) {
        url = [[NSURL alloc] initWithString:[@"http://" stringByAppendingString:address]];
    }
    
    [[UIApplication sharedApplication] openURL:url];
}
#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    //    if(result == MFMailComposeResultSent)
    //        [[[UIAlertView alloc] initWithTitle:@"Mail sent!" message:nil delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil] show];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Download progress
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"fractionCompleted"]) {
        NSProgress *progress = (NSProgress *)object;
        NSLog(@"Progress… %f", progress.fractionCompleted);
        _downloadProgressHUD.progress = progress.fractionCompleted;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if (url)
        [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
- (void)movePushNotificationChatViewController:(NSNumber *)boardID isDeletedFriend:(BOOL)isDetetedFriend users:(NSMutableArray *)lstUsers isDirectory:(NSDictionary *)directoryInfo{
    YYYChatViewController *viewcontroller = [[YYYChatViewController alloc] initWithNibName:@"YYYChatViewController" bundle:nil];
    viewcontroller.isDeletedFriend = isDetetedFriend;
    viewcontroller.boardid = boardID;
    viewcontroller.lstUsers = lstUsers;
    BOOL isMembersSameDirectory = NO;
    if ([[directoryInfo objectForKey:@"is_group"] boolValue]) {//directory chat for members
        viewcontroller.isDeletedFriend = NO;
        viewcontroller.groupName = [directoryInfo objectForKey:@"board_name"];
        viewcontroller.isMemberForDiectory = YES;
        viewcontroller.isDirectory = YES;
    }else{
        viewcontroller.lstUsers = lstUsers;
        
        viewcontroller.isDeletedFriend = YES;
        for (NSDictionary *memberDic in directoryInfo[@"members"]) {
            if ([memberDic[@"in_same_directory"] boolValue]) {
                isMembersSameDirectory = YES;
            }
        }
        if (isMembersSameDirectory) {
            viewcontroller.isDeletedFriend = NO;
            viewcontroller.groupName = [directoryInfo objectForKey:@"board_name"];
            viewcontroller.isMemberForDiectory = YES;
            viewcontroller.isDirectory = NO;
        }
    }
    [self.navigationController pushViewController:viewcontroller animated:YES];
}
- (void)movePushNotificationConferenceViewController:(NSDictionary *)dic{
    VideoVoiceConferenceViewController *vc = [[VideoVoiceConferenceViewController alloc] initWithNibName:@"VideoVoiceConferenceViewController" bundle:nil];
    vc.infoCalling = dic;
    vc.boardId = [dic objectForKey:@"board_id"];
    if ([[dic objectForKey:@"callType"] integerValue] == 1) {
        vc.conferenceType = 1;
    }else{
        vc.conferenceType = 2;
    }
    vc.conferenceName = [dic objectForKey:@"uname"];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
