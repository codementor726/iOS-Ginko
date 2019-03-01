//
//  IMVideoViewController.m
//  Xchangewithme
//
//  Created by Xin YingTai on 21/5/14.
//  Copyright (c) 2014 Xin YingTai. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "IMVideoPickerController.h"
#import "IMVideoViewController.h"
#import "IMVideoCameraController.h"
#import "IMVideoEditController.h"

#import "CustomTitleView.h"

#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"
#import "ELCAssetTablePicker.h"
#import "AppDelegate.h"

#import "VideoVoiceConferenceViewController.h"
@interface IMVideoViewController () <ELCImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;

@end

@implementation IMVideoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.navigationItem.title = @"Choose Video";
	
	[btnForClose addTarget:self action:@selector(onBtnClose:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *itemForClose = [[UIBarButtonItem alloc] initWithCustomView:btnForClose];
	self.navigationItem.rightBarButtonItem = itemForClose;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)onBtnClose:(id)sender
{
    IMVideoPickerController *viewController = (IMVideoPickerController *)self.navigationController;
    
    if ([viewController.pickerDelegate respondsToSelector:@selector(videoPickerControllerDidCancel:)]) {
        [viewController.pickerDelegate videoPickerControllerDidCancel:viewController];
    }
}

- (IBAction)onBtnTake:(id)sender
{
    if (APPDELEGATE.isConferenceView) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"You can't use Camera becuase you're currently on a video call." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!granted) {
                        [CommonMethods showAlertUsingTitle:@"" andMessage:MESSAGE_CAMERA_DISABLED];
                    }
                    else {
                        [AppDelegate sharedDelegate].bCamera = YES;
                        IMVideoCameraController *viewController = [[IMVideoCameraController alloc] initWithNibName:@"IMVideoCameraController" bundle:nil];
                        [self.navigationController pushViewController:viewController animated:YES];
                    }
                });
            }];
        }
        //    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        //    } else {
        //        [[[UIAlertView alloc] initWithTitle:@"Warning" message:@"Camera Unavailable" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil] show];
        //    }
    }
}

- (IBAction)onBtnChoose:(id)sender
{
	[AppDelegate sharedDelegate].bCamera = NO;
	
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
            [[[UIAlertView alloc] initWithTitle:@"" message:@"This app does not have access to your photos or videos" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error Accessing Photo Library" message:@"Device Does not support photo library" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil] show];
    }
}

- (void)displayPickerForGroup:(ALAssetsGroup *)group
{	
	ELCAssetTablePicker *tablePicker = [[ELCAssetTablePicker alloc] initWithStyle:UITableViewStylePlain];
    tablePicker.singleSelection = YES;
    tablePicker.immediateReturn = YES;
    tablePicker.title = @"Choose video";
	ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:tablePicker];
    elcPicker.maximumImagesCount = 1;
    elcPicker.imagePickerDelegate = self;
    elcPicker.returnsOriginalImage = NO; //Only return the fullScreenImage, not the fullResolutionImage
	tablePicker.parent = elcPicker;
	
    // Move me
    tablePicker.assetGroup = group;
    [tablePicker.assetGroup setAssetsFilter:[ALAssetsFilter allVideos]];
    
    [self presentViewController:elcPicker animated:YES completion:^{
        
    }];
}

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        NSDictionary *asset = [info firstObject];
        NSURL* videoURL = [asset objectForKey:UIImagePickerControllerReferenceURL];
        IMVideoEditController *viewController = [[IMVideoEditController alloc] initWithNibName:@"IMVideoEditController" bundle:nil];
        viewController.videoURL = videoURL;
        [self.navigationController pushViewController:viewController animated:YES];
    }];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
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
    [self.navigationController  pushViewController:viewcontroller animated:YES];
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
