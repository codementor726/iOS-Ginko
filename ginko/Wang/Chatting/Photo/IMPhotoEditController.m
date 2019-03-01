//
//  IMPhotoEditController.m
//  Xchangewithme
//
//  Created by Xin YingTai on 21/5/14.
//  Copyright (c) 2014 Xin YingTai. All rights reserved.
//

#import "IMPhotoPickerController.h"
#import "IMPhotoEditController.h"

#import "CustomTitleView.h"
#import "FilterView.h"
#import "TouchView.h"

#import "GPUImage.h"

#import "PECropViewController.h"
#import "VideoVoiceConferenceViewController.h"

//@interface IMPhotoData : NSObject
//
//@property (nonatomic, strong) GPUImagePicture *picture;
//@property (nonatomic, strong) GPUImageView *imageView;
//@property (nonatomic, assign) UIImageOrientation imageOrientation;
//@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *filter;
//@property (nonatomic, strong) GPUImageBrightnessFilter *brightness;
//@property (nonatomic, assign) CGFloat transparency;
//
//@end
//
//@implementation IMPhotoData
//
//@end

@interface IMPhotoEditController () <FilterViewDelegate, PECropViewControllerDelegate>
{
    NSInteger sliderType;
    GPUImagePicture *picture;
    //GPUImageView *imageView;
    //UIImageOrientation imageOrientation;
    GPUImageOutput<GPUImageInput> *filter;
    GPUImageBrightnessFilter *brightness;
    //CGFloat transparency;
    FilterView *realFilterView;
    //GPUImageView *imageView;
}

//@property (nonatomic, strong) IMPhotoData *background;
//@property (nonatomic, strong) IMPhotoData *foreground;
//@property (nonatomic, weak) IMPhotoData *selectedData;

@end

@implementation IMPhotoEditController

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
    
    // Navigation Bar;
    
    if ([UIScreen mainScreen].bounds.size.height == 568.0f) {
        CGRect frame = viewForPhoto.frame;
        frame.size.height = 320.0; // don't modify this
        viewForPhoto.frame = frame;
    }
    
	[self.navigationItem setTitle:@"Choose Photo"];
	
    self.navigationItem.hidesBackButton = YES;
    
    UIBarButtonItem *itemForDelete = [[UIBarButtonItem alloc] initWithCustomView:btnForDelete];
    self.navigationItem.leftBarButtonItem = itemForDelete;
    
    UIBarButtonItem *itemForApply = [[UIBarButtonItem alloc] initWithCustomView:btnForApply];
    self.navigationItem.rightBarButtonItem = itemForApply;

//    // Photo View;
//    CGRect frame = [self imageSize:self.backgroundImage forRect:backgroundView.bounds];
//    backgroundView.frame = frame;
//    backgroundView.center = viewForPhoto.center;
//    
//    self.background = [[IMPhotoData alloc] init];
//    self.background.picture = [[GPUImagePicture alloc] initWithImage:self.backgroundImage smoothlyScaleOutput:YES];
//    self.background.imageView = [[GPUImageView alloc] initWithFrame:frame];
//    [backgroundView addSubview:self.background.imageView];
////  self.background.imageOrientation = UIImageOrientationDown;
//    self.background.filter = [[GPUImageFilter alloc] init];
//    self.background.brightness = [[GPUImageBrightnessFilter alloc] init];
//    self.background.brightness.brightness = 0.0f;
//    self.background.transparency = 1.0f;
//    
//    self.selectedData = self.background;
    
    _imageCropperView = [[HIPImageCropperView alloc]
                         initWithFrame:self.view.bounds
                         cropAreaSize:CGSizeMake(viewForPhoto.frame.size.width, viewForPhoto.frame.size.height)
                         position:HIPImageCropperViewPositionCenter
                         borderVisible:YES];
    _imageCropperView.isOval = NO;
    _imageCropperView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_imageCropperView];
    
    NSDictionary *viewsDictionary = @{@"cropperView":_imageCropperView};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[cropperView]|" options:0 metrics:0 views:viewsDictionary]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_imageCropperView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_imageCropperView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:viewForFilter attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    
    [_imageCropperView setOriginalImage:_backgroundImage];
    
    realFilterView = [FilterView sharedView];
    realFilterView.delegate = self;
    realFilterView.frame = viewForFilter.bounds;
    realFilterView.translatesAutoresizingMaskIntoConstraints = NO;
    [viewForFilter addSubview:realFilterView];
    
    [viewForFilter addConstraint:[NSLayoutConstraint constraintWithItem:realFilterView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:viewForFilter attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [viewForFilter addConstraint:[NSLayoutConstraint constraintWithItem:realFilterView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:viewForFilter attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    [viewForFilter addConstraint:[NSLayoutConstraint constraintWithItem:realFilterView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:viewForFilter attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [viewForFilter addConstraint:[NSLayoutConstraint constraintWithItem:realFilterView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:viewForFilter attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    picture = [[GPUImagePicture alloc] initWithImage:_backgroundImage smoothlyScaleOutput:NO];
    filter = [[GPUImageFilter alloc] init];
    brightness = [[GPUImageBrightnessFilter alloc] init];
    brightness.brightness = 0.0f;
    
    [self didSelectFilter:@0];
    
    slider.center = CGPointMake(300, 160);
    slider.transform = CGAffineTransformMakeRotation(-M_PI_2);
    [self.view bringSubviewToFront:slider];
//    // Slider;
//    slider.center = CGPointMake(300, 160);
//    slider.transform = CGAffineTransformMakeRotation(-M_PI_2);
//    
//    // Filter View;
//    FilterView *filterView = [FilterView sharedView];
//    filterView.delegate = self;
//    filterView.frame = viewForFilter.bounds;    
//    [viewForFilter addSubview:filterView];
    
}

- (CGRect)imageSize:(UIImage *)image forRect:(CGRect)frame
{
    CGSize imageSize = image.size;
    
    double wRate = frame.size.width / imageSize.width;
    double hRate = frame.size.height / imageSize.height;
    double dRate = 0.0f ;
    
    if (wRate > hRate) {
        dRate = wRate;
    } else {
        dRate = hRate;
    }
    
    double width = imageSize.width * dRate;
    double height = imageSize.height * dRate;
    
    return CGRectMake(0, 0, width, height);
    
//	if (height * (320/width) > 462)
//	{
//		return CGRectMake(0, 0, 320, height * (320/width));
//	}
//	else
//	{
//		return CGRectMake(0, 0, width * (462/height), 462);
//	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self performSelector:@selector(didSelectFilter:) withObject:@0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)didSelectFilter:(NSNumber *)index
{
    FilterType filterType = [index integerValue];
    
    [picture removeAllTargets];
    [filter removeAllTargets];
    
    [self setFilterType:filterType];
    
    [self prepareFilter];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
                pickerController.delegate = self;
                pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                pickerController.allowsEditing = YES;
                [self presentViewController:pickerController animated:YES completion:^{
                    
                }];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Error Accessing Photo Library" message:@"Device Does not support photo library" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil] show];
            }
        }
            
        case 1:
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
                pickerController.delegate = self;
                pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                pickerController.allowsEditing = YES;
                [self presentViewController:pickerController animated:YES completion:^{
                    
                }];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Error Accessing Photo Library" message:@"Device Does not support photo library" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil] show];
            }
            break;
        }
            
        default:
            break;
    }
}

//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//{
//    [picker dismissViewControllerAnimated:YES completion:^{
//        UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
//        UIImage* imgForOrder = [UIImage imageNamed:@"btn_layer_order.png"];
//        
//        [btnForLayer setImage:imgForOrder forState:UIControlStateNormal];
//        self.foregroundImage = image;
//        
//        // Photo View;
//        self.foreground = [[IMPhotoData alloc] init];
//        self.foreground.picture = [[GPUImagePicture alloc] initWithImage:self.foregroundImage smoothlyScaleOutput:YES];
//        self.foreground.imageView = [[GPUImageView alloc] initWithFrame:foregroundView.bounds];
//        self.foreground.imageView.backgroundColor = [UIColor clearColor];
//        [foregroundView addSubview:self.foreground.imageView];
//        self.background.imageOrientation = image.imageOrientation;
//        self.foreground.filter = [[GPUImageFilter alloc] init];
//        self.foreground.brightness = [[GPUImageBrightnessFilter alloc] init];
//        self.foreground.transparency = 1.0f;
//    
//        self.selectedData = self.foreground;
//        
//        [self performSelector:@selector(didSelectFilter:) withObject:@0];
//        [viewForPhoto bringSubviewToFront:foregroundView];
//    }];
//}

//- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
//{
//    [picker dismissViewControllerAnimated:YES completion:^{
//        
//    }];
//}

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    //if (self.selectedData == self.background) {
        CGRect frame = [self imageSize:croppedImage forRect:viewForPhoto.frame];
        //backgroundView.transform = CGAffineTransformIdentity;
        //backgroundView.frame = frame;
        //backgroundView.center = viewForPhoto.center;
        //imageView.frame = frame;
//    } else {
//        CGRect frame = [self imageSize:croppedImage forRect:foregroundView.frame];
//        CGPoint center = foregroundView.center;
//        foregroundView.transform = CGAffineTransformIdentity;
//        foregroundView.frame = frame;
//        foregroundView.center = center;
//        self.selectedData.imageView.frame = frame;
//    }
    CGFloat scale = croppedImage.size.width / croppedImage.size.height;
    CGFloat curWidth;
    CGFloat curHeight;
    if (croppedImage.size.width > croppedImage.size.height) {
        curWidth = viewForPhoto.frame.size.width;
        curHeight = viewForPhoto.frame.size.width / scale;
    }else{
        curWidth = viewForPhoto.frame.size.height * scale;
        curHeight = viewForPhoto.frame.size.height;
    }
    //r (UIView *subUIView in self.view.subviews) {
    [_imageCropperView removeFromSuperview];
    //}
    NSLog(@"%@", NSStringFromCGSize(croppedImage.size));
    _imageCropperView = [[HIPImageCropperView alloc]
                         initWithFrame:self.view.bounds
                         cropAreaSize:CGSizeMake(curWidth, curHeight)
                         position:HIPImageCropperViewPositionCenter
                         borderVisible:YES];
    _imageCropperView.isOval = NO;
    _imageCropperView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_imageCropperView];
    NSDictionary *viewsDictionary = @{@"cropperView":_imageCropperView};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[cropperView]|" options:0 metrics:0 views:viewsDictionary]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_imageCropperView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_imageCropperView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:viewForFilter attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [_imageCropperView setOriginalImage:croppedImage];
    
    picture = [[GPUImagePicture alloc] initWithImage:croppedImage smoothlyScaleOutput:NO];
    slider.center = CGPointMake(300, 160);
    slider.transform = CGAffineTransformMakeRotation(-M_PI_2);
    [self.view bringSubviewToFront:slider];
    [controller.navigationController dismissViewControllerAnimated:YES completion:^{
        [self prepareFilter];
    }];
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)setFilterType:(FilterType)filterType
{
    switch (filterType) {
        case FilterTypeBookStore:
        {
            filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageToneCurveFilter *tone = [[GPUImageToneCurveFilter alloc] initWithACV:@"BookStore"];
            GPUImageSaturationFilter *saturation = [[GPUImageSaturationFilter alloc] init];
            
            [(GPUImageFilterGroup *)filter addFilter:saturation];
            [tone addTarget:saturation];
            [saturation addTarget:brightness];
            
            [(GPUImageFilterGroup *)filter setInitialFilters:[NSArray arrayWithObject:tone]];
            [(GPUImageFilterGroup *)filter setTerminalFilter:brightness];
            break;
        }
            
        case FilterTypeCity:
        {
            filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageToneCurveFilter *tone = [[GPUImageToneCurveFilter alloc] initWithACV:@"City"];
            GPUImageSaturationFilter *saturation = [[GPUImageSaturationFilter alloc] init];
            
            [(GPUImageFilterGroup *)filter addFilter:saturation];
            [tone addTarget:saturation];
            [saturation addTarget:brightness];
            
            [(GPUImageFilterGroup *)filter setInitialFilters:[NSArray arrayWithObject:tone]];
            [(GPUImageFilterGroup *)filter setTerminalFilter:brightness];
            break;
        }
            
        case FilterTypeCountry:
        {
            filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageToneCurveFilter *tone = [[GPUImageToneCurveFilter alloc] initWithACV:@"Country"];
            GPUImageSaturationFilter *saturation = [[GPUImageSaturationFilter alloc] init];
            
            [(GPUImageFilterGroup *)filter addFilter:saturation];
            [tone addTarget:saturation];
            [saturation addTarget:brightness];
            
            [(GPUImageFilterGroup *)filter setInitialFilters:[NSArray arrayWithObject:tone]];
            [(GPUImageFilterGroup *)filter setTerminalFilter:brightness];
            break;
        }
            
        case FilterTypeFilm:
        {
            filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageToneCurveFilter *tone = [[GPUImageToneCurveFilter alloc] initWithACV:@"Film"];
            GPUImageSaturationFilter *saturation = [[GPUImageSaturationFilter alloc] init];
            
            [(GPUImageFilterGroup *)filter addFilter:saturation];
            [tone addTarget:saturation];
            [saturation addTarget:brightness];
            
            [(GPUImageFilterGroup *)filter setInitialFilters:[NSArray arrayWithObject:tone]];
            [(GPUImageFilterGroup *)filter setTerminalFilter:brightness];
            break;
        }
            
        case FilterTypeForest:
        {
            filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageToneCurveFilter *tone = [[GPUImageToneCurveFilter alloc] initWithACV:@"Forest"];
            GPUImageSaturationFilter *saturation = [[GPUImageSaturationFilter alloc] init];
            
            [(GPUImageFilterGroup *)filter addFilter:saturation];
            [tone addTarget:saturation];
            [saturation addTarget:brightness];
            
            [(GPUImageFilterGroup *)filter setInitialFilters:[NSArray arrayWithObject:tone]];
            [(GPUImageFilterGroup *)filter setTerminalFilter:brightness];
            break;
        }
            
        case FilterTypeLake:
        {
            filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageToneCurveFilter *tone = [[GPUImageToneCurveFilter alloc] initWithACV:@"Lake"];
            GPUImageSaturationFilter *saturation = [[GPUImageSaturationFilter alloc] init];
            
            [(GPUImageFilterGroup *)filter addFilter:saturation];
            [tone addTarget:saturation];
            [saturation addTarget:brightness];
            
            [(GPUImageFilterGroup *)filter setInitialFilters:[NSArray arrayWithObject:tone]];
            [(GPUImageFilterGroup *)filter setTerminalFilter:brightness];
            break;
        }
            
        case FilterTypeMoment:
        {
            filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageToneCurveFilter *tone = [[GPUImageToneCurveFilter alloc] initWithACV:@"Moment"];
            GPUImageSaturationFilter *saturation = [[GPUImageSaturationFilter alloc] init];
            
            [(GPUImageFilterGroup *)filter addFilter:saturation];
            [tone addTarget:saturation];
            [saturation addTarget:brightness];
            
            [(GPUImageFilterGroup *)filter setInitialFilters:[NSArray arrayWithObject:tone]];
            [(GPUImageFilterGroup *)filter setTerminalFilter:brightness];
            break;
        }
            
        case FilterTypeNYC:
        {
            filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageToneCurveFilter *tone = [[GPUImageToneCurveFilter alloc] initWithACV:@"NYC"];
            GPUImageSaturationFilter *saturation = [[GPUImageSaturationFilter alloc] init];
            
            [(GPUImageFilterGroup *)filter addFilter:saturation];
            [tone addTarget:saturation];
            [saturation addTarget:brightness];
            
            [(GPUImageFilterGroup *)filter setInitialFilters:[NSArray arrayWithObject:tone]];
            [(GPUImageFilterGroup *)filter setTerminalFilter:brightness];
            break;
        }
            
        case FilterTypeTea:
        {
            filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageToneCurveFilter *tone = [[GPUImageToneCurveFilter alloc] initWithACV:@"Tea"];
            GPUImageSaturationFilter *saturation = [[GPUImageSaturationFilter alloc] init];
            
            [(GPUImageFilterGroup *)filter addFilter:saturation];
            [tone addTarget:saturation];
            [saturation addTarget:brightness];
            
            [(GPUImageFilterGroup *)filter setInitialFilters:[NSArray arrayWithObject:tone]];
            [(GPUImageFilterGroup *)filter setTerminalFilter:brightness];
            break;
        }
            
        case FilterTypeVintage:
        {
            filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageToneCurveFilter *tone = [[GPUImageToneCurveFilter alloc] initWithACV:@"Vintage"];
            GPUImageVignetteFilter *vintage = [[GPUImageVignetteFilter alloc] init];
            
            [(GPUImageFilterGroup *)filter addFilter:vintage];
            [tone addTarget:vintage];
            [vintage addTarget:brightness];
            
            [(GPUImageFilterGroup *)filter setInitialFilters:[NSArray arrayWithObject:tone]];
            [(GPUImageFilterGroup *)filter setTerminalFilter:brightness];
            break;
        }
            
        case FilterType1Q84:
        {
            filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageToneCurveFilter *tone = [[GPUImageToneCurveFilter alloc] initWithACV:@"1Q84"];
            GPUImageSaturationFilter *saturation = [[GPUImageSaturationFilter alloc] init];
            
            [(GPUImageFilterGroup *)filter addFilter:saturation];
            [tone addTarget:saturation];
            [saturation addTarget:brightness];
            
            [(GPUImageFilterGroup *)filter setInitialFilters:[NSArray arrayWithObject:tone]];
            [(GPUImageFilterGroup *)filter setTerminalFilter:brightness];
            break;
        }
            
        case FilterTypeBW:
        {
            filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageToneCurveFilter *tone = [[GPUImageToneCurveFilter alloc] initWithACV:@"B&W"];
            GPUImageGrayscaleFilter *gray = [[GPUImageGrayscaleFilter alloc] init];
            
            [(GPUImageFilterGroup *)filter addFilter:gray];
            [tone addTarget:gray];
            [gray addTarget:brightness];
            
            [(GPUImageFilterGroup *)filter setInitialFilters:[NSArray arrayWithObject:tone]];
            [(GPUImageFilterGroup *)filter setTerminalFilter:brightness];
            break;
        }
            
        default:
        {
            filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageGammaFilter *gamma = [[GPUImageGammaFilter alloc] init];
            
            [(GPUImageFilterGroup *)filter addFilter:gamma];
            [gamma addTarget:brightness];
            
            [(GPUImageFilterGroup *)filter setInitialFilters:[NSArray arrayWithObject:gamma]];
            [(GPUImageFilterGroup *)filter setTerminalFilter:brightness];
            break;
        }
    }
}

- (void)prepareFilter
{
    [picture addTarget:filter];
    [filter useNextFrameForImageCapture];
    [picture processImageWithCompletionHandler:^{
        UIImage *image = [filter imageFromCurrentFramebuffer];
        dispatch_async(dispatch_get_main_queue(), ^{
            //            [_imageCropperView setOriginalImage:image withCropFrame:_imageCropperView.cropFrame];
            _imageCropperView.imageView.image = image;
        });
    }];
    
//    [filter addTarget:self.selectedData.imageView];
//    
//    GPUImageRotationMode imageViewRotationMode = kGPUImageNoRotation;
//    
//    switch (self.selectedData.imageOrientation) {
//        case UIImageOrientationLeft:
//            imageViewRotationMode = kGPUImageRotateLeft;
//            break;
//            
//        case UIImageOrientationRight:
//            imageViewRotationMode = kGPUImageRotateRight;
//            break;
//            
//        case UIImageOrientationDown:
//            imageViewRotationMode = kGPUImageRotate180;
//            break;
//            
//        case UIImageOrientationUp:
//            break;
//            
//        default:
//            imageViewRotationMode = kGPUImageNoRotation;
//            break;
//    }
//    
//    [self.selectedData.imageView setInputRotation:imageViewRotationMode atIndex:0];
//    [self.selectedData.picture processImage];
}

//- (void)removeAllTargets;
//{
//    [self.selectedData.picture removeAllTargets];
//    [self.selectedData.filter removeAllTargets];
//}

- (void)showSlider:(CGFloat)value;
{
    slider.value = value;
    [UIView animateWithDuration:0.3f animations:^{
        slider.alpha = 1.0f;
    }];
}

- (void)hideSlider
{
    [UIView animateWithDuration:0.3f animations:^{
        slider.alpha = 0.0f;
    }];
}

- (IBAction)onSliderChange:(id)sender
{
//    if (sliderType == 1) {
//        self.selectedData.brightness.brightness = slider.value;
//        [self.selectedData.picture processImage];
//    } else {
//        self.selectedData.imageView.alpha = slider.value;
//    }
    if (sliderType == 1) {
        brightness.brightness = slider.value;
        [filter useNextFrameForImageCapture];
        
        [picture processImageWithCompletionHandler:^{
            UIImage *image = [filter imageFromCurrentFramebuffer];
            dispatch_async(dispatch_get_main_queue(), ^{
                //                [_imageCropperView setOriginalImage:image withCropFrame:_imageCropperView.cropFrame];
                _imageCropperView.imageView.image = image;
            });
        }];
    } else {
        _imageCropperView.imageView.alpha = slider.value;
    }
}

- (IBAction)onBtnDelete:(id)sender
{
//    if (!self.foreground) {
        [self.navigationController popViewControllerAnimated:YES];
//    } else {
//        self.selectedData = self.background;
//        
//        [self.foreground.imageView removeFromSuperview];
//        self.foreground = nil;
//        
//        UIImage* imgForOrder = [UIImage imageNamed:@"btn_layer.png"];
//        [btnForLayer setImage:imgForOrder forState:UIControlStateNormal];
//        
//        [viewForPhoto bringSubviewToFront:backgroundView];
//        
//        [[[UIActionSheet alloc] initWithTitle:@"Pick a Photo Source" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"Camera",@"Photo Library", nil] showInView:self.view];
//    }
}

- (IBAction)onBtnApply:(id)sender
{
    IMPhotoPickerController *viewController = (IMPhotoPickerController *)self.navigationController;

//    [self.background.filter useNextFrameForImageCapture];
//    [self.background.picture processImage];
//    UIImage *backgroundImage = [self.background.filter imageFromCurrentFramebuffer];
//
//    UIGraphicsBeginImageContextWithOptions(viewForPhoto.bounds.size, NO, [[UIScreen mainScreen] scale]);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextClearRect(context, viewForPhoto.bounds);
//
//    [backgroundImage drawInRect:backgroundView.frame];
//    UIImage* image = UIGraphicsGetImageFromCurrentImageContext() ;
//    UIGraphicsEndImageContext() ;
//    
//    [self.foreground.filter useNextFrameForImageCapture];
//    [self.foreground.picture processImage];
//    UIImage *foregroundImage = [self.foreground.filter imageFromCurrentFramebuffer];
    
    UIImage *resultImage = [_imageCropperView processedImage];
    if ([viewController.pickerDelegate respondsToSelector:@selector(IMphotoPickerController:didSelectBackground:avatar:)]) {
        [viewController.pickerDelegate IMphotoPickerController:viewController didSelectBackground:resultImage avatar:resultImage];
    }
}

- (IBAction)onBtnLayer:(id)sender
{
//    [self hideSlider];
//    
//    if (!self.foreground) {
//        [[[UIActionSheet alloc] initWithTitle:@"Pick a Photo Source" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"Camera",@"Photo Library", nil] showInView:self.view];
//    } else {
//        if (self.selectedData == self.background) {
//            self.selectedData = self.foreground;
//            [viewForPhoto bringSubviewToFront:foregroundView];
//        } else {
//            self.selectedData = self.background;
//            [viewForPhoto bringSubviewToFront:backgroundView];
//        }
//    }
}

- (IBAction)onBtnBrightness:(id)sender
{
    sliderType = 1;
    
    slider.minimumValue = -1.0f;
    slider.maximumValue = 1.0f;
    
    [self showSlider:brightness.brightness];
}

- (IBAction)onBtnTransprency:(id)sender
{
    sliderType = 2;
    
    slider.minimumValue = 0.0f;
    slider.maximumValue = 1.0f;
    
    [self showSlider:_imageCropperView.imageView.alpha];
}

- (IBAction)onBtnCrop:(id)sender
{
    [self hideSlider];

    UIImageView *imageView = [[viewForPhoto subviews] lastObject];
    PECropViewController *viewController = [[PECropViewController alloc] init];
    viewController.delegate = self;
    viewController.cropRect = imageView.bounds;

    //if (self.selectedData == self.background) {
        viewController.image = self.backgroundImage;
    //} else {
    //    viewController.image = self.foregroundImage;
    //}
    
    UINavigationController *naviController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:naviController animated:YES completion:^{
        
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
