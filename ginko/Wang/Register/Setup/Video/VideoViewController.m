//
//  VideoViewController.m
//  Xchangewithme
//
//  Created by Xin YingTai on 21/5/14.
//  Copyright (c) 2014 Xin YingTai. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "VideoPickerController.h"
#import "VideoViewController.h"
#import "VideoCameraController.h"
#import "VideoEditController.h"

#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"
#import "ELCAssetTablePicker.h"

#import "UIImageView+AFNetworking.h"
#import "YYYCommunication.h"

#import "UIImage+Tint.h"

@interface VideoViewController () <ELCImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    NSMutableArray *arrVideos;
}

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;

@end

@implementation VideoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    VideoPickerController *viewController = (VideoPickerController *)self.navigationController;
    
    switch (viewController.type) {
        case 1:
        case 4:
            self.title = @"Personal Info";
            break;
        case 2:
            self.title = @"Work Info";
            break;
        case 3:
            self.title = @"Entity Info";
            break;
        default:
            break;
    }
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    if (!_isSetup) {
        // edit
        self.navigationController.navigationBar.barTintColor = COLOR_GREEN_THEME;
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
        _leafImageView.alpha = 0.2f;
        _leafImageView.image = [UIImage imageNamed:@"SetupLeaf.png"];
        _descLabel.textColor = RGBA(55, 99, 43, 1);
        [_cameraButton setImage:[UIImage imageNamed:@"BtnVideoSetup.png"] forState:UIControlStateNormal];
        [_pictureButton setImage:[UIImage imageNamed:@"BtnPhotoSetup.png"] forState:UIControlStateNormal];
        _videoArchiveImage.image = [UIImage imageNamed:@"VideoArchiveHome"];
        _videoArchiveLabel.textColor = RGBA(55, 99, 43, 1);
    } else {
        // create
        self.navigationController.navigationBar.barTintColor = COLOR_PURPLE_THEME;
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
        _leafImageView.alpha = 0.5f;
        _leafImageView.image = [UIImage imageNamed:@"LeafBgForBlank.png"];
        _descLabel.textColor = RGBA(134, 87, 129, 1);
        [_cameraButton setImage:[UIImage imageNamed:@"VideoBig"] forState:UIControlStateNormal];
        [_pictureButton setImage:[UIImage imageNamed:@"PhotoBig"] forState:UIControlStateNormal];
        _videoArchiveImage.image = [UIImage imageNamed:@"VideoArchiveWork"];
        _videoArchiveLabel.textColor = RGBA(134, 87, 129, 1);
    }
    
    if (viewController.showBackButton) {
        UIBarButtonItem *itemForBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackArrow"] style:UIBarButtonItemStylePlain target:self action:@selector(onBtnBack:)];
        self.navigationItem.leftBarButtonItem = itemForBack;
    } else {
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    if (viewController.close) {
        UIBarButtonItem *itemForClose = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close"] style:UIBarButtonItemStylePlain target:self action:@selector(onBtnBack:)];
        self.navigationItem.rightBarButtonItem = itemForClose;
    } else {
        self.navigationItem.rightBarButtonItem = itemForSkip;
    }
    
    if ([AppDelegate sharedDelegate].isProfileEdit || [AppDelegate sharedDelegate].isEditEntity) {
        arrVideos = [[NSMutableArray alloc] init];
        
        [self showArchiveView];
    }
}

- (void)showArchiveView
{
    viewArchive.hidden = NO;
    
    if (self.entityID) {  //entity
        [self getEntityVideoHistory];
    } else {  //profile
        [self getProfileVideoHistory];
    }
}

- (void)getProfileVideoHistory
{
    [MBProgressHUD showHUDAddedTo:[AppDelegate sharedDelegate].window animated:YES];
    
    void (^successed)(id responseObject) = ^(id responseObject) {
        [MBProgressHUD hideHUDForView:[AppDelegate sharedDelegate].window animated:YES];
        NSDictionary *result = responseObject;
        NSLog(@"Video Result: %@", result);
        if ([[result objectForKey:@"success"] boolValue]) {
            [arrVideos removeAllObjects];
            for (NSDictionary *dict in [[result objectForKey:@"data"] objectForKey:@"data"]) {
                [arrVideos addObject:dict];
            }
            [self loadArchiveVideos];
        } else {
            NSDictionary *dictError = [result objectForKey:@"err"];
            if (dictError) {
                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:[dictError objectForKey:@"errMsg"]];
            } else {
                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Failed to connect to server!"];
            }
        }
    };
    
    void (^failure)(NSError* error) = ^(NSError* error) {
        [MBProgressHUD hideHUDForView:[AppDelegate sharedDelegate].window animated:YES];
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Failed to connect to server!"];
    };
    
    [[YYYCommunication sharedManager] getProfileVideoHistory:[AppDelegate sharedDelegate].sessionId type:[NSString stringWithFormat:@"%d", (int)self.type] pageNum:nil countPerPage:nil successed:successed failure:failure];
}

- (void)getEntityVideoHistory
{
    [MBProgressHUD showHUDAddedTo:[AppDelegate sharedDelegate].window animated:YES];
    
    void (^successed)(id responseObject) = ^(id responseObject) {
        [MBProgressHUD hideHUDForView:[AppDelegate sharedDelegate].window animated:YES];
        NSDictionary *result = responseObject;
        
        if ([[result objectForKey:@"success"] boolValue]) {
            [arrVideos removeAllObjects];
            for (NSDictionary *dict in [[result objectForKey:@"data"] objectForKey:@"data"]) {
                [arrVideos addObject:dict];
            }
            [self loadArchiveVideos];
        } else {
            NSDictionary *dictError = [result objectForKey:@"err"];
            if (dictError) {
                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:[dictError objectForKey:@"errMsg"]];
            } else {
                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Failed to connect to server!"];
            }
        }
    };
    
    void (^failure)(NSError* error) = ^(NSError* error) {
        [MBProgressHUD hideHUDForView:[AppDelegate sharedDelegate].window animated:YES];
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Failed to connect to server!"];
    };

    [[YYYCommunication sharedManager] getEntityVideoHistory:[AppDelegate sharedDelegate].sessionId entity_id:self.entityID pageNum:nil countPerPage:nil successed:successed failure:failure];
}

- (void)loadArchiveVideos
{
    for (UIView *view in scvArchive.subviews) {
        [view removeFromSuperview];
    }
    
    int originX = 20;
    int count = [arrVideos count];
    
    if (count == 0) {
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(20, 5, 60, 100)];
        NSString *strImgFileName = @"NoVideoHome";
//        if (self.type > 1) {
//            strImgFileName = @"NoVideoWork";
//        }
        [img setImage:[UIImage imageNamed:strImgFileName]];
        [scvArchive addSubview:img];
        [scvArchive setContentSize:CGSizeMake(80, 0)];
        return;
    }
    
    UIButton *btnArchives[count];
    UIImageView *img[count];
    
    for (int i=0; i<count; i++) {
        NSDictionary *dict = [arrVideos objectAtIndex:i];
        img[i] = [[UIImageView alloc] initWithFrame:CGRectMake(originX, 5, 60, 100)];
        [img[i] setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"thumbnail_url"]]];
        
        btnArchives[i] = [UIButton buttonWithType:UIButtonTypeSystem];
        btnArchives[i].frame = CGRectMake(originX, 5, 60, 100);
        [btnArchives[i] addTarget:self action:@selector(onBtnVideoArchive:) forControlEvents:UIControlEventTouchUpInside];
        [btnArchives[i] setTag:100 + i];
        UIButton *btnRemove = [UIButton buttonWithType:UIButtonTypeCustom];
        
        UIView *viewRemove = [[UIView alloc] initWithFrame:CGRectMake(originX + 45, 5, 15, 15)];
        viewRemove.backgroundColor = [UIColor clearColor];
        
        btnRemove.frame = CGRectMake(0, 0, 15, 15);
        [btnRemove addTarget:self action:@selector(onRemove:) forControlEvents:UIControlEventTouchUpInside];
        [btnRemove setTag:200 + i];
        [btnRemove setImage:[UIImage imageNamed:@"close_icon"] forState:UIControlStateNormal];
        
        [viewRemove addSubview:btnRemove];
        
        [scvArchive addSubview:img[i]];
        [scvArchive addSubview:btnArchives[i]];
        [scvArchive addSubview:viewRemove];
        
        originX += 80;
    }
    
    [scvArchive setContentSize:CGSizeMake(80*count + 20, 0)];
}

- (IBAction)onBtnVideoArchive:(id)sender
{
    [AppDelegate sharedDelegate].bLibrary = NO;
    UIButton *btn = (UIButton *)sender;
    NSDictionary *dict = [arrVideos objectAtIndex:btn.tag - 100];
    [self downloadVideo:dict];
}

- (IBAction)onRemove:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Do you want to delete video from the archive?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    alert.tag = btn.tag + 100;
    [alert show];
}

- (void)downloadVideo:(NSDictionary *)dict
{
    void ( ^successed )( NSString *str ) = ^( NSString *str  )
    {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        VideoEditController *viewController = [[VideoEditController alloc] initWithNibName:@"VideoEditController" bundle:nil];
        viewController.videoURL = [NSURL fileURLWithPath:str];
        
        if (self.type == 3) { //entity
            [AppDelegate sharedDelegate].videoEntityID = [NSString stringWithFormat:@"%@", [dict objectForKey:@"video_id"]];
        } else {
            [AppDelegate sharedDelegate].videoID = [NSString stringWithFormat:@"%@", [dict objectForKey:@"id"]];
        }
        
        [self.navigationController pushViewController:viewController animated:YES];
    };
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Failed to connect to server!"];
        
    } ;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:@"Downloading..."];
    [[YYYCommunication sharedManager] download:[dict objectForKey:@"video_url"] fileName:@"video.mp4" success:successed failure:failure];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        
        [MBProgressHUD showHUDAddedTo:[AppDelegate sharedDelegate].window animated:YES];
        
        void (^successed)(id responseObject) = ^(id responseObject) {
            [MBProgressHUD hideHUDForView:[AppDelegate sharedDelegate].window animated:YES];
            NSDictionary *result = responseObject;
            NSLog(@"Remove : %@", result);
            if ([[result objectForKey:@"success"] boolValue]) {
                [self showArchiveView];
            } else {
                NSDictionary *dictError = [result objectForKey:@"err"];
                if (dictError) {
                    [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:[dictError objectForKey:@"errMsg"]];
                } else {
                    [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Failed to connect to server!"];
                }
            }
        };
        
        void (^failure)(NSError* error) = ^(NSError* error) {
            [MBProgressHUD hideHUDForView:[AppDelegate sharedDelegate].window animated:YES];
            [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Failed to connect to server!"];
        };
        
        NSDictionary *dict = [arrVideos objectAtIndex:alertView.tag - 300];
        
        if (self.entityID) {
            [[YYYCommunication sharedManager] deleteEntityVideoHistory:[AppDelegate sharedDelegate].sessionId video:[dict objectForKey:@"video_id"] entity_id:self.entityID successed:successed failure:failure];
        } else {
            [[YYYCommunication sharedManager] deleteProfileVideoHistory:[AppDelegate sharedDelegate].sessionId video:[dict objectForKey:@"id"] type:[NSString stringWithFormat:@"%d", (int)self.type] successed:successed failure:failure];
        }
    }
}

- (void)onBtnBack:(id)sender
{
    VideoPickerController *viewController = (VideoPickerController *)self.navigationController;
    
    if ([viewController.pickerDelegate respondsToSelector:@selector(videoPickerControllerDidCancel:)]) {
        [viewController.pickerDelegate videoPickerControllerDidCancel:viewController];
    }
}

- (IBAction)onBtnSkip:(id)sender
{
    VideoPickerController *viewController = (VideoPickerController *)self.navigationController;
    
    if ([viewController.pickerDelegate respondsToSelector:@selector(videoPickerControllerDidCancel:)]) {
        [viewController.pickerDelegate videoPickerControllerDidCancel:viewController];
    }
}

- (IBAction)onBtnTake:(id)sender
{
    [AppDelegate sharedDelegate].bLibrary = NO;
    
    VideoCameraController *viewController = [[VideoCameraController alloc] initWithNibName:@"VideoCameraController" bundle:nil];
    viewController.isSetup = _isSetup;
    [AppDelegate sharedDelegate].videoID = @"";
    [AppDelegate sharedDelegate].videoEntityID = @"";
    [self.navigationController pushViewController:viewController animated:YES];
    return;
    
//    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//    } else {
//        [[[UIAlertView alloc] initWithTitle:@"Warning" message:@"Camera Unavailable" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil] show];
//    }
}

- (IBAction)onBtnChoose:(id)sender
{
    [AppDelegate sharedDelegate].bLibrary = YES;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        NSMutableArray *groups = [NSMutableArray array];
        self.assetsLibrary = [[ALAssetsLibrary alloc] init];
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
//		[self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupLibrary usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group) {
                [groups addObject:group];
            } else {
                [self displayPickerForGroup:[groups firstObject]];
            }
        } failureBlock:^(NSError *error) {
//            [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Album Error: %@ - %@", [error localizedDescription], [error localizedRecoverySuggestion]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            [[[UIAlertView alloc] initWithTitle:@"This app does not have access your videos." message:@"You can enable access in Privacy Settings" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error Accessing Photo Library" message:@"Device Does not support photo library" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil] show];
    }
}

- (void)displayPickerForGroup:(ALAssetsGroup *)group
{
	VideoPickerController *viewController = (VideoPickerController *)self.navigationController;
	
	ELCAssetTablePicker *tablePicker = [[ELCAssetTablePicker alloc] initWithStyle:UITableViewStylePlain];
    tablePicker.singleSelection = YES;
    tablePicker.immediateReturn = YES;
    
	ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:tablePicker];
    elcPicker.maximumImagesCount = 1;
    elcPicker.imagePickerDelegate = self;
    elcPicker.returnsOriginalImage = NO; //Only return the fullScreenImage, not the fullResolutionImage
	tablePicker.parent = elcPicker;
    tablePicker.type = viewController.type;
	
    // Move me
    tablePicker.assetGroup = group;
    [tablePicker.assetGroup setAssetsFilter:[ALAssetsFilter allVideos]];
    
    elcPicker.navigationBar.translucent = NO;
    [elcPicker.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    elcPicker.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
    elcPicker.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
    [elcPicker.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: self.navigationController.navigationBar.titleTextAttributes[NSForegroundColorAttributeName]}];
    
    [self presentViewController:elcPicker animated:YES completion:^{
        [AppDelegate sharedDelegate].videoID = @"";
        [AppDelegate sharedDelegate].videoEntityID = @"";
    }];
}

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        NSDictionary *asset = [info firstObject];
        NSURL* videoURL = [asset objectForKey:UIImagePickerControllerReferenceURL];
        VideoEditController *viewController = [[VideoEditController alloc] initWithNibName:@"VideoEditController" bundle:nil];
        viewController.videoURL = videoURL;
        [AppDelegate sharedDelegate].videoID = @"";
        [AppDelegate sharedDelegate].videoEntityID = @"";
        [self.navigationController pushViewController:viewController animated:YES];
    }];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
