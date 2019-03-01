//
//  PhotoViewController.m
//  Xchangewithme
//
//  Created by Xin YingTai on 20/5/14.
//  Copyright (c) 2014 Xin YingTai. All rights reserved.
//

#import "PhotoPickerController.h"
#import "PhotoViewController.h"
#import "PhotoCameraController.h"
#import "PhotoEditController.h"
#import "PhotoBackgroundViewController.h"

#import "CustomTitleView.h"

#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"
#import "ELCAssetTablePicker.h"

#import "UIImageView+AFNetworking.h"
#import "YYYCommunication.h"

#import <AVFoundation/AVFoundation.h>

#import "UIImage+Resize.h"

@interface PhotoViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    NSMutableArray *arrImages;
}
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;

@end

@implementation PhotoViewController

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
    self.navigationItem.hidesBackButton = YES;
    
    if (viewController.showBackButton) {
        UIBarButtonItem *itemForBack = [[UIBarButtonItem alloc] initWithCustomView:btnForBack];
        self.navigationItem.leftBarButtonItem = itemForBack;
    } else if (viewController.showEditButton) {
        UIBarButtonItem *itemForEdit = [[UIBarButtonItem alloc] initWithCustomView:btnForEdit];
        self.navigationItem.leftBarButtonItem = itemForEdit;
    } else {
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    if (viewController.close) {
        UIBarButtonItem *itemForClose = [[UIBarButtonItem alloc] initWithCustomView:btnForClose];
        self.navigationItem.rightBarButtonItem = itemForClose;
        createWorkLabel.text = @"Edit Your Work Profile";
    } else {
        self.navigationItem.rightBarButtonItem = itemForSkip;
    }
    
    lblForHidden.hidden = !viewController.showEditButton;
	imgForHidden.hidden = !viewController.showEditButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([AppDelegate sharedDelegate].isProfileEdit || [AppDelegate sharedDelegate].isEditEntity) {
        arrImages = [[NSMutableArray alloc] init];
        
        lblSkip.hidden = YES;
        [self showArchiveView];
    }
//    self.navigationController.tabBarItem.title = @"Home Info";
    CreateTitleLabel.hidden = !self.isCreate;
    EditTitleLabel.hidden = self.isCreate;
    lblSkip.hidden = !self.isCreate;
}

- (void)showArchiveView
{
    lblArchive.hidden = NO;
    scvArchive.hidden = NO;
    
    if (self.entityID) {  //entity
        [self getEntityImageArchive];
    } else {  //profile
        [self getProfileImageArchive];
    }
}

- (void)getProfileImageArchive
{
    [MBProgressHUD showHUDAddedTo:[AppDelegate sharedDelegate].window animated:YES];
    
    void (^successed)(id responseObject) = ^(id responseObject) {
        [MBProgressHUD hideHUDForView:[AppDelegate sharedDelegate].window animated:YES];
        NSDictionary *result = responseObject;
        
        if ([[result objectForKey:@"success"] boolValue]) {
            [arrImages removeAllObjects];
            for (NSDictionary *dict in [[result objectForKey:@"data"] objectForKey:@"data"]) {
                [arrImages addObject:dict];
            }
            [self loadArchiveImages];
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
    
    [[YYYCommunication sharedManager] getProfileImageArchive:[AppDelegate sharedDelegate].sessionId type:[NSString stringWithFormat:@"%d", (int)self.type] pageNum:nil countPerPage:nil successed:successed failure:failure];
}

- (void)getEntityImageArchive
{
    [MBProgressHUD showHUDAddedTo:[AppDelegate sharedDelegate].window animated:YES];
    
    void (^successed)(id responseObject) = ^(id responseObject) {
        [MBProgressHUD hideHUDForView:[AppDelegate sharedDelegate].window animated:YES];
        NSDictionary *result = responseObject;
        
        if ([[result objectForKey:@"success"] boolValue]) {
            [arrImages removeAllObjects];
            for (NSDictionary *dict in [[result objectForKey:@"data"] objectForKey:@"data"]) {
                [arrImages addObject:dict];
            }
            [self loadArchiveImages];
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
    
    [[YYYCommunication sharedManager] getEntityImageArchive:[AppDelegate sharedDelegate].sessionId entity_id:self.entityID pageNum:nil countPerPage:nil successed:successed failure:failure];
}

- (void)loadArchiveImages
{
    for (UIView *view in scvArchive.subviews) {
        [view removeFromSuperview];
    }
    
    int originX = 20;
    int count = (int)[arrImages count];
    
    if (count == 0) {
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(20, 5, 60, 100)];
        NSString *strImgFileName = @"NoImageHome";
        if (self.type > 1) {
            strImgFileName = @"NoImageWork";
        }
        [img setImage:[UIImage imageNamed:strImgFileName]];
        [scvArchive addSubview:img];
        [scvArchive setContentSize:CGSizeMake(80, 0)];
        return;
    }
    
    
    UIButton *btnArchives[count];
    UIImageView *img[count];
    
    for (int i=0; i<count; i++) {
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(originX, 5, 60, 100)];
        backView.clipsToBounds = YES;
        backView.backgroundColor = [UIColor clearColor];
        backView.layer.borderColor = [UIColor grayColor].CGColor;
        backView.layer.borderWidth = 1.0f;
        
        NSDictionary *dict = [arrImages objectAtIndex:i];
        img[i] = [[UIImageView alloc] initWithFrame:CGRectMake(originX, 5, 60, 100)];
        
        btnArchives[i] = [UIButton buttonWithType:UIButtonTypeSystem];
        btnArchives[i].frame = CGRectMake(originX, 5, 60, 100);
        [btnArchives[i] addTarget:self action:@selector(onBtnImgArchive:) forControlEvents:UIControlEventTouchUpInside];
        [btnArchives[i] setTag:100 + i];
        btnArchives[i].layer.borderColor = [UIColor grayColor].CGColor;
        btnArchives[i].layer.borderWidth = 1.0f;
        
        UIButton *btnRemove = [UIButton buttonWithType:UIButtonTypeCustom];
        
        UIView *viewRemove = [[UIView alloc] initWithFrame:CGRectMake(originX + 45, 5, 15, 15)];
        viewRemove.backgroundColor = [UIColor clearColor];
        
        btnRemove.frame = CGRectMake(0, 0, 15, 15);
        [btnRemove addTarget:self action:@selector(onRemove:) forControlEvents:UIControlEventTouchUpInside];
        [btnRemove setTag:200 + i];
        [btnRemove setImage:[UIImage imageNamed:@"close_icon"] forState:UIControlStateNormal];
        
        [viewRemove addSubview:btnRemove];
        
        [scvArchive addSubview:img[i]];
        for (NSDictionary *ddict in [dict objectForKey:@"images"]) {
            if ([[ddict objectForKey:@"z_index"] integerValue] == 0) {
                [img[i] setImageWithURL:[NSURL URLWithString:[ddict objectForKey:@"image_url"]]];
            } else {
                UIImageView *imgFore = [[UIImageView alloc] init];
                [imgFore setContentMode:UIViewContentModeScaleAspectFit];
                [imgFore setImageWithURL:[NSURL URLWithString:[ddict objectForKey:@"image_url"]]];
                if ([ddict objectForKey:@"top"] != [NSNull null] && [ddict objectForKey:@"left"] != [NSNull null] && [ddict objectForKey:@"width"] != [NSNull null] && [ddict objectForKey:@"height"] != [NSNull null]) {
                    [imgFore setFrame:CGRectMake([[ddict objectForKey:@"left"] floatValue] * 60 / 307, [[ddict objectForKey:@"top"] floatValue] * 100 / 429, [[ddict objectForKey:@"width"] floatValue] * 60 / 307, [[ddict objectForKey:@"height"] floatValue] * 100 / 429)];
                } else {
                    [imgFore setFrame:CGRectMake(30 * 60 / 307, 30 * 100 / 429, 150 * 60 / 307, 150 * 100 / 429)];
                }
                [backView addSubview:imgFore];
                [scvArchive addSubview:backView];
            }
        }
        
        [scvArchive addSubview:btnArchives[i]];
        [scvArchive addSubview:viewRemove];
        
        originX += 80;
    }
    
    [scvArchive setContentSize:CGSizeMake(80*count + 20, 0)];
}

- (IBAction)onBtnImgArchive:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    NSDictionary *dict = [arrImages objectAtIndex:btn.tag - 100];
//    [self downloadImage:dict];
    [self pickupImage:dict];
}

- (IBAction)onRemove:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Do you want to delete image from the archive?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    alert.tag = btn.tag + 100;
    [alert show];
}

- (void)pickupImage:(NSDictionary *)dict
{
    PhotoPickerController *viewController = (PhotoPickerController *)self.navigationController;
    
    if ([viewController.pickerDelegate respondsToSelector:@selector(photoPickerController:didPickupImage:)]) {
        [viewController.pickerDelegate photoPickerController:viewController didPickupImage:dict];
    }
}

- (void)downloadImage:(NSDictionary *)dict
{
    void ( ^successed )( NSString *str ) = ^( NSString *str  )
    {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        PhotoEditController *viewController = [[PhotoEditController alloc] initWithNibName:@"PhotoEditController" bundle:nil];
        viewController.backgroundImage = [UIImage imageWithContentsOfFile:str];
        
        [self.navigationController pushViewController:viewController animated:YES];
    };
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Failed to connect to server!"];
        
    } ;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[YYYCommunication sharedManager] download:[dict objectForKey:@"image_url"] fileName:@"img_file" success:successed failure:failure];
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
        
        NSDictionary *dict = [arrImages objectAtIndex:alertView.tag - 300];
        
        if (self.entityID) {
            [[YYYCommunication sharedManager] deleteEntityImageArchive:[AppDelegate sharedDelegate].sessionId archive:[dict objectForKey:@"archive_id"] entity_id:self.entityID successed:successed failure:failure];
        } else {
            [[YYYCommunication sharedManager] deleteProfileImageArchive:[AppDelegate sharedDelegate].sessionId archiveid:[dict objectForKey:@"archive_id"] type:[NSString stringWithFormat:@"%d", (int)self.type] successed:successed failure:failure];
        }
    }
}

- (IBAction)onBtnBack:(id)sender
{
    PhotoPickerController *viewController = (PhotoPickerController *)self.navigationController;
    
    if ([viewController.pickerDelegate respondsToSelector:@selector(photoPickerControllerDidCancel:)]) {
        [viewController.pickerDelegate photoPickerControllerDidCancel:viewController];
    }
}

- (IBAction)onBtnEdit:(id)sender
{
    PhotoPickerController *viewController = (PhotoPickerController *)self.navigationController;
    
    if ([viewController.pickerDelegate respondsToSelector:@selector(photoPickerControllerDidEdit:)]) {
        [viewController.pickerDelegate photoPickerControllerDidEdit:viewController];
    }
}

- (IBAction)onBtnSkip:(id)sender
{
    PhotoPickerController *viewController = (PhotoPickerController *)self.navigationController;
    
    if ([viewController.pickerDelegate respondsToSelector:@selector(photoPickerControllerDidCancel:)]) {
        [viewController.pickerDelegate photoPickerControllerDidCancel:viewController];
    }
}

- (void)openCameraViewController
{
    PhotoCameraController *viewController = [[PhotoCameraController alloc] initWithNibName:@"PhotoCameraController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)showCameraNotAuthorizedAlert
{
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Cannot access Camera. Please open Settings and allow ginko to access Camera" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (IBAction)onBtnTake:(id)sender
{
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        [self openCameraViewController];
    } else if(authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted){
        // denied or restricted
        [self showCameraNotAuthorizedAlert];
    } else if(authStatus == AVAuthorizationStatusNotDetermined){
        // not determined
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(granted){
                    [self openCameraViewController];
                } else {
                    [self showCameraNotAuthorizedAlert];
                }
            });
        }];
    } else {
        // unknown authorization status
    }
}

- (IBAction)onBtnChoose:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
		UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
		pickerController.delegate = self;
		pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		[self presentViewController:pickerController animated:YES completion:^{

		}];
//        NSMutableArray *groups = [NSMutableArray array];
//        self.assetsLibrary = [[ALAssetsLibrary alloc] init];
//        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
////		[self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupLibrary usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
//            if (group) {
//                [groups addObject:group];
//            } else {
//                [self displayPickerForGroup:[groups firstObject]];
//            }
//        } failureBlock:^(NSError *error) {
//            [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Album Error: %@ - %@", [error localizedDescription], [error localizedRecoverySuggestion]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
//        }];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error Accessing Photo Library" message:@"Device Does not support photo library" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil] show];
    }
}

- (IBAction)onBackgroundColor:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    [self didSelectBackgroundColor:(int)(btn.tag)];
}

- (IBAction)onMore:(id)sender
{
    PhotoBackgroundViewController *vc = [[PhotoBackgroundViewController alloc] initWithNibName:@"PhotoBackgroundViewController" bundle:nil];
    vc.parentController = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)displayPickerForGroup:(ALAssetsGroup *)group
{
	PhotoPickerController *viewController = (PhotoPickerController *)self.navigationController;
	
	ELCAssetTablePicker *tablePicker = [[ELCAssetTablePicker alloc] initWithStyle:UITableViewStylePlain];
    tablePicker.singleSelection = YES;
    tablePicker.immediateReturn = YES;
    
	ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:tablePicker];
    elcPicker.maximumImagesCount = 1;
//	elcPicker.imagePickerDelegate = self;
    elcPicker.returnsOriginalImage = NO; //Only return the fullScreenImage, not the fullResolutionImage
	tablePicker.parent = elcPicker;
    tablePicker.type = viewController.type;
	
    // Move me
    tablePicker.assetGroup = group;
    [tablePicker.assetGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
    
    [self presentViewController:elcPicker animated:YES completion:^{
        
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    image = [image fixOrientation];
    
    if (![UIImageJPEGRepresentation(image, 0.5f) writeToFile:TEMP_IMAGE_PATH atomically:YES]) {
        [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Failed to save information. Please try again."];
        return;
    }
    [picker dismissViewControllerAnimated:YES completion:^{
        
        PhotoEditController *viewController = [[PhotoEditController alloc] initWithNibName:@"PhotoEditController" bundle:nil];
        viewController.backgroundImage = image;
        [self.navigationController pushViewController:viewController animated:YES];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        NSDictionary *asset = [info firstObject];
        UIImage* image = [asset objectForKey:UIImagePickerControllerOriginalImage];
        
        PhotoEditController *viewController = [[PhotoEditController alloc] initWithNibName:@"PhotoEditController" bundle:nil];
        viewController.backgroundImage = image;
        [self.navigationController pushViewController:viewController animated:YES];
    }];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)didSelectBackgroundColor:(int)index
{
    UIImage *image;
    if (index > 200) {
        switch (index) {
            case 201:
                image = [UIImage imageNamed:@"bc_black"];
                break;
            case 202:
                image = [UIImage imageNamed:@"bc_grey"];
                break;
            case 203:
                image = [UIImage imageNamed:@"bc_silver"];
                break;
            case 204:
                image = [UIImage imageNamed:@"bc_white"];
                break;
            default:
                image = [UIImage imageNamed:@"bc_white"];
                break;
        }
    } else {
        image = [UIImage imageNamed:[NSString stringWithFormat:@"bc_%d", index]];
    }
    
    PhotoEditController *viewController = [[PhotoEditController alloc] initWithNibName:@"PhotoEditController" bundle:nil];
    viewController.backgroundImage = image;
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
