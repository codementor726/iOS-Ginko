//
//  PhotoCameraController.m
//  Xchangewithme
//
//  Created by Xin YingTai on 21/5/14.
//  Copyright (c) 2014 Xin YingTai. All rights reserved.
//

#import "PhotoPickerController.h"
#import "PhotoCameraController.h"
#import "PhotoEditController.h"

#import "VideoVoiceConferenceViewController.h"

#import "CustomTitleView.h"

#import "GPUImage.h"

#import "UIImage+Resize.h"

static NSString * const kNotificationDidChangeOrientation = @"didChangeOrientation";

@interface PhotoCameraController ()
{
    GPUImageStillCamera *camera;
    GPUImageView *imageView;
    GPUImageOutput<GPUImageInput> *filter;
    
    NSMutableSet *buttons;
}

@end

@implementation PhotoCameraController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        buttons = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    PhotoPickerController *viewController = (PhotoPickerController *)self.navigationController;
    
    // Navigation Bar;
    CustomTitleView *titleView = nil;
    
    switch (viewController.type) {
        case 1:
            titleView = [CustomTitleView homeInfoView];
            break;
            
        case 2:
            titleView = [CustomTitleView workInfoView];
            break;
        case 3:
            titleView = [CustomTitleView entityView:@"Entity Info"];
            break;
        case 4:
            titleView = [CustomTitleView homeInfoView];
            break;
            
        default:
            break;
    }
    
    self.navigationItem.titleView = titleView;

    UIBarButtonItem *itemForBack = [[UIBarButtonItem alloc] initWithCustomView:btnForBack];
    self.navigationItem.leftBarButtonItem = itemForBack;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGesture:)];
    [viewForPhoto addGestureRecognizer:tapGesture];
    
    camera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
    camera.horizontallyMirrorFrontFacingCamera = YES;
    camera.outputImageOrientation = UIInterfaceOrientationPortrait;

    imageView = [[GPUImageView alloc] initWithFrame:viewForPhoto.bounds];
    [viewForPhoto addSubview:imageView];
    [viewForPhoto sendSubviewToBack:imageView];

    filter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0.0f, 0.0f, 1.0f, 0.75f)];
    
    [camera addTarget:filter];
    [filter addTarget:imageView];
    
    [buttons addObject:btnForGrid];
    [buttons addObject:btnForFlip];
    [buttons addObject:btnForFlash];
    if ([camera.inputCamera lockForConfiguration:nil]) {
        if ([camera.inputCamera hasFlash]) {
            switch (camera.inputCamera.flashMode) {
                case AVCaptureFlashModeOff:
                {
                    break;
                }
                    
                case AVCaptureFlashModeOn:
                {
                    camera.inputCamera.flashMode = AVCaptureFlashModeOff;
                    [btnForFlash setImage:[UIImage imageNamed:@"flashing_off.png"] forState:UIControlStateNormal];
                    break;
                }
                    
                case AVCaptureFlashModeAuto:
                {
                    camera.inputCamera.flashMode = AVCaptureFlashModeOff;
                    [btnForFlash setImage:[UIImage imageNamed:@"flashing_off.png"] forState:UIControlStateNormal];
                    break;
                }
                    
                default:
                    break;
            }
        } else {
            
        }
        
        [camera.inputCamera unlockForConfiguration];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeOrientation:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [camera startCameraCapture];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [camera stopCameraCapture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [camera removeAllTargets];
    [filter removeAllTargets];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidChangeOrientation object:nil];
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidChangeOrientation object:nil];
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
	return UIInterfaceOrientationPortrait;
}

- (void)didChangeOrientation:(NSNotification *)notification
{
    if (!buttons || [buttons count] <= 0) {
        return;
    }
    
    [buttons enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        UIButton *button = [obj isKindOfClass:[UIButton class]]?obj:nil;
        
        if (!button) {
            *stop = YES;
            return;
        }

        button.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
        CGAffineTransform transform = CGAffineTransformMakeRotation(0);
        
        switch ([UIDevice currentDevice].orientation) {
            case UIDeviceOrientationPortrait:
                transform = CGAffineTransformMakeRotation(0);
                break;
                
            case UIDeviceOrientationPortraitUpsideDown:
                transform = CGAffineTransformMakeRotation(M_PI);
                break;

            case UIDeviceOrientationLandscapeLeft:
                transform = CGAffineTransformMakeRotation(M_PI_2);
                break;

            case UIDeviceOrientationLandscapeRight:
                transform = CGAffineTransformMakeRotation(-M_PI_2);
                break;

            default:
                break;
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            button.transform = transform;
        }];
    }];
}

- (void)onTapGesture:(UITapGestureRecognizer *)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateRecognized) {
        CGPoint location = [tapGesture locationInView:imageView];
        CGPoint interest = CGPointZero;
        CGSize frameSize = [imageView frame].size;
        
        // UI;
        imgForFocus.center = location;
        imgForFocus.transform = CGAffineTransformMakeScale(2.0, 2.0);
        
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
            imgForFocus.alpha = 1.0f;
            imgForFocus.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5f delay:0.5f options:UIViewAnimationOptionAllowUserInteraction animations:^{
                imgForFocus.alpha = 0.0f;
            } completion:^(BOOL finished) {
                
            }];
        }];
        
        // Device;
        if ([camera cameraPosition] == AVCaptureDevicePositionFront) {
            location.x = frameSize.width - location.x;
        }
        
        interest = CGPointMake(location.y / frameSize.height, 1.f - (location.x / frameSize.width));
        
        if ([camera.inputCamera lockForConfiguration:nil]) {
            if ([camera.inputCamera isFocusPointOfInterestSupported] && [camera.inputCamera isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
                [camera.inputCamera setFocusPointOfInterest:interest];
                [camera.inputCamera setFocusMode:AVCaptureFocusModeAutoFocus];
            }
            
            if ([camera.inputCamera isExposurePointOfInterestSupported] && [camera.inputCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                [camera.inputCamera setExposurePointOfInterest:interest];
                [camera.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            }
            
            [camera.inputCamera unlockForConfiguration];
        }
    }
}

- (IBAction)onBtnBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onBtnGrid:(id)sender
{
    btnForGrid.selected = !btnForGrid.selected;
    
    if (!btnForGrid.selected) {
        imgForGrid.hidden = YES;
    } else {
        imgForGrid.hidden = NO;
    }
}

- (IBAction)onBtnFlip:(id)sender
{
    btnForFlip.selected = !btnForFlip.selected;
    btnForFlip.enabled = NO;
    [camera rotateCamera];
    btnForFlip.enabled = YES;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        if (!camera) {
            return;
        }
        
        if ([camera.inputCamera hasFlash] && [camera.inputCamera hasTorch]) {
            btnForFlash.enabled = YES;
        } else {
            btnForFlash.enabled = NO;
        }
    }
}

- (IBAction)onBtnFlash:(id)sender
{
    if ([camera.inputCamera lockForConfiguration:nil]) {
        if ([camera.inputCamera hasFlash]) {
            switch (camera.inputCamera.flashMode) {
                case AVCaptureFlashModeOff:
                {
                    camera.inputCamera.flashMode = AVCaptureFlashModeOn;
                    [btnForFlash setImage:[UIImage imageNamed:@"flashing_on.png"] forState:UIControlStateNormal];
                    break;
                }
                    
                case AVCaptureFlashModeOn:
                {
                    camera.inputCamera.flashMode = AVCaptureFlashModeAuto;
                    [btnForFlash setImage:[UIImage imageNamed:@"flashing_auto.png"] forState:UIControlStateNormal];
                    break;
                }
                    
                case AVCaptureFlashModeAuto:
                {
                    camera.inputCamera.flashMode = AVCaptureFlashModeOff;
                    [btnForFlash setImage:[UIImage imageNamed:@"VideoTool2.png"] forState:UIControlStateNormal];
                    break;
                }
                    
                default:
                    break;
            }
        } else {
            
        }
        
        [camera.inputCamera unlockForConfiguration];
    }
}

- (IBAction)onBtnTake:(id)sender
{
    btnForTake.enabled = NO;
    [camera capturePhotoAsImageProcessedUpToFilter:filter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        btnForTake.enabled = YES;
        
        PhotoEditController *viewController = [[PhotoEditController alloc] initWithNibName:@"PhotoEditController" bundle:nil];
        
        processedImage = [processedImage fixOrientation];
        
        if (!IS_IPHONE_5) {
            processedImage = [processedImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(processedImage.size.width/processedImage.size.height*320, 320) interpolationQuality:0];
        }
        NSLog(@"Image Size : %@", NSStringFromCGSize(processedImage.size));
        viewController.backgroundImage = processedImage;
        [self.navigationController pushViewController:viewController animated:YES];
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
