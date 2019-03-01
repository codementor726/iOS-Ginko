//
//  PhotoEditController.m
//  Xchangewithme
//
//  Created by Xin YingTai on 21/5/14.
//  Copyright (c) 2014 Xin YingTai. All rights reserved.
//

#import "PhotoPickerController.h"
#import "PhotoEditController.h"

#import "CustomTitleView.h"
#import "FilterView.h"
#import "TouchView.h"

#import "GPUImage.h"

#import "PECropViewController.h"

@interface PhotoData : NSObject

@property (nonatomic, strong) GPUImagePicture *picture;
@property (nonatomic, strong) GPUImageView *imageView;
@property (nonatomic, assign) UIImageOrientation imageOrientation;
@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *filter;
@property (nonatomic, strong) GPUImageBrightnessFilter *brightness;
@property (nonatomic, assign) CGFloat transparency;

@end

@implementation PhotoData

@end

@interface PhotoEditController () <FilterViewDelegate, PECropViewControllerDelegate>
{
    NSInteger sliderType;
}

@property (nonatomic, strong) PhotoData *background;
@property (nonatomic, strong) PhotoData *foreground;
@property (nonatomic, weak) PhotoData *selectedData;

@end

@implementation PhotoEditController

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
    
    if ([UIScreen mainScreen].bounds.size.height == 568.0f) {
        CGRect frame = viewForPhoto.frame;
//		frame.size.height = 462.0f;
		frame.size.height = 320.0f; // don't modify this
        viewForPhoto.frame = frame;
    }
	else
	{
		CGRect frame = viewForPhoto.frame;
//		frame.size.height = 356.0f;
		frame.size.height = 320.f; // don't modify this
        viewForPhoto.frame = frame;
	}
    
    self.navigationItem.titleView = titleView;
    self.navigationItem.hidesBackButton = YES;
    
    UIBarButtonItem *itemForDelete = [[UIBarButtonItem alloc] initWithCustomView:btnForDelete];
    self.navigationItem.leftBarButtonItem = itemForDelete;
    
    UIBarButtonItem *itemForApply = [[UIBarButtonItem alloc] initWithCustomView:btnForApply];
    self.navigationItem.rightBarButtonItem = itemForApply;

    // Photo View;
    CGRect frame = [self imageSize:self.backgroundImage forRect:backgroundView.bounds];
    backgroundView.frame = frame;
    backgroundView.center = viewForPhoto.center;
	
    self.background = [[PhotoData alloc] init];
    self.background.picture = [[GPUImagePicture alloc] initWithImage:self.backgroundImage smoothlyScaleOutput:NO];
    self.background.imageView = [[GPUImageView alloc] initWithFrame:frame];
    [backgroundView addSubview:self.background.imageView];
	
//  self.background.imageOrientation = UIImageOrientationDown;
    self.background.filter = [[GPUImageFilter alloc] init];
    self.background.brightness = [[GPUImageBrightnessFilter alloc] init];
    self.background.brightness.brightness = 0.0f;
    self.background.transparency = 1.0f;
    
    self.selectedData = self.background;
    
    // Slider;
    slider.center = CGPointMake(300, 160);
    slider.transform = CGAffineTransformMakeRotation(-M_PI_2);
    
    // Filter View;
    FilterView *filterView = [FilterView sharedView];
    filterView.delegate = self;
    filterView.frame = viewForFilter.bounds;    
    [viewForFilter addSubview:filterView];
 
	rtBackgroundView = backgroundView.frame;
}

/*
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
    
	if (height * (320/width) > 462)
	{
		return CGRectMake(0, 0, 320, height * (320/width));
	}
	else
	{
		return CGRectMake(0, 0, width * (462/height), 462);
	}
}
*/

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
    
	return CGRectMake(0, 0, 320, height * (320/width));
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self performSelector:@selector(didSelectFilter:) withObject:@0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)didSelectFilter:(NSNumber *)index
{
    FilterType filterType = [index integerValue];
    
    [self removeAllTargets];
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    if (![UIImageJPEGRepresentation(image, 0.5f) writeToFile:TEMP_IMAGE_PATH atomically:YES]) {
        [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Failed to save information. Please try again."];
        return;
    }
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage* imgForOrder = [UIImage imageNamed:@"btn_layer_order.png"];
        
        [btnForLayer setImage:imgForOrder forState:UIControlStateNormal];
        self.foregroundImage = image;
        
        // Photo View;
        self.foreground = [[PhotoData alloc] init];
        self.foreground.picture = [[GPUImagePicture alloc] initWithImage:self.foregroundImage smoothlyScaleOutput:NO];
        self.foreground.imageView = [[GPUImageView alloc] initWithFrame:foregroundView.bounds];
        self.foreground.imageView.backgroundColor = [UIColor clearColor];
        [foregroundView addSubview:self.foreground.imageView];
        self.background.imageOrientation = image.imageOrientation;
        self.foreground.filter = [[GPUImageFilter alloc] init];
        self.foreground.brightness = [[GPUImageBrightnessFilter alloc] init];
        self.foreground.transparency = 1.0f;
    
        self.selectedData = self.foreground;
        
        [self performSelector:@selector(didSelectFilter:) withObject:@0];
        [viewForPhoto bringSubviewToFront:foregroundView];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    if (self.selectedData == self.background) {
        CGRect frame = [self imageSize:croppedImage forRect:viewForPhoto.frame];
        backgroundView.transform = CGAffineTransformIdentity;
        backgroundView.frame = frame;
        backgroundView.center = viewForPhoto.center;
        self.selectedData.imageView.frame = frame;
    } else {
        CGRect frame = [self imageSize:croppedImage forRect:foregroundView.frame];
        CGPoint center = foregroundView.center;
        foregroundView.transform = CGAffineTransformIdentity;
        foregroundView.frame = frame;
        foregroundView.center = center;
        self.selectedData.imageView.frame = frame;
    }
    NSLog(@"did crop size = %@ : %@", NSStringFromCGSize(croppedImage.size), NSStringFromCGRect(foregroundView.frame));
    self.selectedData.picture = [[GPUImagePicture alloc] initWithImage:croppedImage smoothlyScaleOutput:NO];
    
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
            self.selectedData.filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageToneCurveFilter *tone = [[GPUImageToneCurveFilter alloc] initWithACV:@"BookStore"];
            GPUImageSaturationFilter *saturation = [[GPUImageSaturationFilter alloc] init];
            
            [(GPUImageFilterGroup *)self.selectedData.filter addFilter:saturation];
            [tone addTarget:saturation];
            [saturation addTarget:self.selectedData.brightness];
            
            [(GPUImageFilterGroup *)self.selectedData.filter setInitialFilters:[NSArray arrayWithObject:tone]];
            [(GPUImageFilterGroup *)self.selectedData.filter setTerminalFilter:self.selectedData.brightness];
            break;
        }
            
        case FilterTypeCity:
        {
            self.selectedData.filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageToneCurveFilter *tone = [[GPUImageToneCurveFilter alloc] initWithACV:@"City"];
            GPUImageSaturationFilter *saturation = [[GPUImageSaturationFilter alloc] init];
            
            [(GPUImageFilterGroup *)self.selectedData.filter addFilter:saturation];
            [tone addTarget:saturation];
            [saturation addTarget:self.selectedData.brightness];
            
            [(GPUImageFilterGroup *)self.selectedData.filter setInitialFilters:[NSArray arrayWithObject:tone]];
            [(GPUImageFilterGroup *)self.selectedData.filter setTerminalFilter:self.selectedData.brightness];
            break;
        }
            
        case FilterTypeCountry:
        {
            self.selectedData.filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageToneCurveFilter *tone = [[GPUImageToneCurveFilter alloc] initWithACV:@"Country"];
            GPUImageSaturationFilter *saturation = [[GPUImageSaturationFilter alloc] init];
            
            [(GPUImageFilterGroup *)self.selectedData.filter addFilter:saturation];
            [tone addTarget:saturation];
            [saturation addTarget:self.selectedData.brightness];
            
            [(GPUImageFilterGroup *)self.selectedData.filter setInitialFilters:[NSArray arrayWithObject:tone]];
            [(GPUImageFilterGroup *)self.selectedData.filter setTerminalFilter:self.selectedData.brightness];
            break;
        }
            
        case FilterTypeFilm:
        {
            self.selectedData.filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageToneCurveFilter *tone = [[GPUImageToneCurveFilter alloc] initWithACV:@"Film"];
            GPUImageSaturationFilter *saturation = [[GPUImageSaturationFilter alloc] init];
            
            [(GPUImageFilterGroup *)self.selectedData.filter addFilter:saturation];
            [tone addTarget:saturation];
            [saturation addTarget:self.selectedData.brightness];
            
            [(GPUImageFilterGroup *)self.selectedData.filter setInitialFilters:[NSArray arrayWithObject:tone]];
            [(GPUImageFilterGroup *)self.selectedData.filter setTerminalFilter:self.selectedData.brightness];
            break;
        }
            
        case FilterTypeForest:
        {
            self.selectedData.filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageToneCurveFilter *tone = [[GPUImageToneCurveFilter alloc] initWithACV:@"Forest"];
            GPUImageSaturationFilter *saturation = [[GPUImageSaturationFilter alloc] init];
            
            [(GPUImageFilterGroup *)self.selectedData.filter addFilter:saturation];
            [tone addTarget:saturation];
            [saturation addTarget:self.selectedData.brightness];
            
            [(GPUImageFilterGroup *)self.selectedData.filter setInitialFilters:[NSArray arrayWithObject:tone]];
            [(GPUImageFilterGroup *)self.selectedData.filter setTerminalFilter:self.selectedData.brightness];
            break;
        }
            
        case FilterTypeLake:
        {
            self.selectedData.filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageToneCurveFilter *tone = [[GPUImageToneCurveFilter alloc] initWithACV:@"Lake"];
            GPUImageSaturationFilter *saturation = [[GPUImageSaturationFilter alloc] init];
            
            [(GPUImageFilterGroup *)self.selectedData.filter addFilter:saturation];
            [tone addTarget:saturation];
            [saturation addTarget:self.selectedData.brightness];
            
            [(GPUImageFilterGroup *)self.selectedData.filter setInitialFilters:[NSArray arrayWithObject:tone]];
            [(GPUImageFilterGroup *)self.selectedData.filter setTerminalFilter:self.selectedData.brightness];
            break;
        }
            
        case FilterTypeMoment:
        {
            self.selectedData.filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageToneCurveFilter *tone = [[GPUImageToneCurveFilter alloc] initWithACV:@"Moment"];
            GPUImageSaturationFilter *saturation = [[GPUImageSaturationFilter alloc] init];
            
            [(GPUImageFilterGroup *)self.selectedData.filter addFilter:saturation];
            [tone addTarget:saturation];
            [saturation addTarget:self.selectedData.brightness];
            
            [(GPUImageFilterGroup *)self.selectedData.filter setInitialFilters:[NSArray arrayWithObject:tone]];
            [(GPUImageFilterGroup *)self.selectedData.filter setTerminalFilter:self.selectedData.brightness];
            break;
        }
            
        case FilterTypeNYC:
        {
            self.selectedData.filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageToneCurveFilter *tone = [[GPUImageToneCurveFilter alloc] initWithACV:@"NYC"];
            GPUImageSaturationFilter *saturation = [[GPUImageSaturationFilter alloc] init];
            
            [(GPUImageFilterGroup *)self.selectedData.filter addFilter:saturation];
            [tone addTarget:saturation];
            [saturation addTarget:self.selectedData.brightness];
            
            [(GPUImageFilterGroup *)self.selectedData.filter setInitialFilters:[NSArray arrayWithObject:tone]];
            [(GPUImageFilterGroup *)self.selectedData.filter setTerminalFilter:self.selectedData.brightness];
            break;
        }
            
        case FilterTypeTea:
        {
            self.selectedData.filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageToneCurveFilter *tone = [[GPUImageToneCurveFilter alloc] initWithACV:@"Tea"];
            GPUImageSaturationFilter *saturation = [[GPUImageSaturationFilter alloc] init];
            
            [(GPUImageFilterGroup *)self.selectedData.filter addFilter:saturation];
            [tone addTarget:saturation];
            [saturation addTarget:self.selectedData.brightness];
            
            [(GPUImageFilterGroup *)self.selectedData.filter setInitialFilters:[NSArray arrayWithObject:tone]];
            [(GPUImageFilterGroup *)self.selectedData.filter setTerminalFilter:self.selectedData.brightness];
            break;
        }
            
        case FilterTypeVintage:
        {
            self.selectedData.filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageToneCurveFilter *tone = [[GPUImageToneCurveFilter alloc] initWithACV:@"Vintage"];
            GPUImageVignetteFilter *vintage = [[GPUImageVignetteFilter alloc] init];
            
            [(GPUImageFilterGroup *)self.selectedData.filter addFilter:vintage];
            [tone addTarget:vintage];
            [vintage addTarget:self.selectedData.brightness];
            
            [(GPUImageFilterGroup *)self.selectedData.filter setInitialFilters:[NSArray arrayWithObject:tone]];
            [(GPUImageFilterGroup *)self.selectedData.filter setTerminalFilter:self.selectedData.brightness];
            break;
        }
            
        case FilterType1Q84:
        {
            self.selectedData.filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageToneCurveFilter *tone = [[GPUImageToneCurveFilter alloc] initWithACV:@"1Q84"];
            GPUImageSaturationFilter *saturation = [[GPUImageSaturationFilter alloc] init];
            
            [(GPUImageFilterGroup *)self.selectedData.filter addFilter:saturation];
            [tone addTarget:saturation];
            [saturation addTarget:self.selectedData.brightness];
            
            [(GPUImageFilterGroup *)self.selectedData.filter setInitialFilters:[NSArray arrayWithObject:tone]];
            [(GPUImageFilterGroup *)self.selectedData.filter setTerminalFilter:self.selectedData.brightness];
            break;
        }
            
        case FilterTypeBW:
        {
            self.selectedData.filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageToneCurveFilter *tone = [[GPUImageToneCurveFilter alloc] initWithACV:@"B&W"];
            GPUImageGrayscaleFilter *gray = [[GPUImageGrayscaleFilter alloc] init];
            
            [(GPUImageFilterGroup *)self.selectedData.filter addFilter:gray];
            [tone addTarget:gray];
            [gray addTarget:self.selectedData.brightness];
            
            [(GPUImageFilterGroup *)self.selectedData.filter setInitialFilters:[NSArray arrayWithObject:tone]];
            [(GPUImageFilterGroup *)self.selectedData.filter setTerminalFilter:self.selectedData.brightness];
            break;
        }
            
        default:
        {
            self.selectedData.filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageGammaFilter *gamma = [[GPUImageGammaFilter alloc] init];
            
            [(GPUImageFilterGroup *)self.selectedData.filter addFilter:gamma];
            [gamma addTarget:self.selectedData.brightness];
            
            [(GPUImageFilterGroup *)self.selectedData.filter setInitialFilters:[NSArray arrayWithObject:gamma]];
            [(GPUImageFilterGroup *)self.selectedData.filter setTerminalFilter:self.selectedData.brightness];
            break;
        }
    }
}

- (void)prepareFilter
{
    [self.selectedData.picture addTarget:self.selectedData.filter];
    [self.selectedData.filter addTarget:self.selectedData.imageView];
    
    GPUImageRotationMode imageViewRotationMode = kGPUImageNoRotation;
    
    switch (self.selectedData.imageOrientation) {
        case UIImageOrientationLeft:
            imageViewRotationMode = kGPUImageRotateLeft;
            break;
            
        case UIImageOrientationRight:
            imageViewRotationMode = kGPUImageRotateRight;
            break;
            
        case UIImageOrientationDown:
            imageViewRotationMode = kGPUImageRotate180;
            break;
            
        case UIImageOrientationUp:
            break;
            
        default:
            imageViewRotationMode = kGPUImageNoRotation;
            break;
    }
    
    [self.selectedData.imageView setInputRotation:imageViewRotationMode atIndex:0];
    [self.selectedData.picture processImage];
}

- (void)removeAllTargets;
{
    [self.selectedData.picture removeAllTargets];
    [self.selectedData.filter removeAllTargets];
}

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
    if (sliderType == 1) {
        self.selectedData.brightness.brightness = slider.value;
        [self.selectedData.picture processImage];
    } else {
        self.selectedData.imageView.alpha = slider.value;
    }
}

- (IBAction)onBtnDelete:(id)sender
{
    if (!self.foreground) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        self.selectedData = self.background;
        
        [self.foreground.imageView removeFromSuperview];
        self.foreground = nil;
        
        UIImage* imgForOrder = [UIImage imageNamed:@"btn_layer.png"];
        [btnForLayer setImage:imgForOrder forState:UIControlStateNormal];
        
        [viewForPhoto bringSubviewToFront:backgroundView];
        
        [[[UIActionSheet alloc] initWithTitle:@"Pick a Photo Source" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"Camera",@"Photo Library", nil] showInView:self.view];
    }
}

- (IBAction)onBtnApply:(id)sender
{
	PhotoPickerController *viewController = (PhotoPickerController *)self.navigationController;

    [self.background.filter useNextFrameForImageCapture];
    [self.background.picture processImage];
    UIImage *backgroundImage = [self.background.filter imageFromCurrentFramebuffer];

	UIGraphicsBeginImageContextWithOptions(viewForPhoto.bounds.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, viewForPhoto.bounds);
	
	if(CGRectEqualToRect(rtBackgroundView, backgroundView.frame))
	{
		[backgroundImage drawInRect:CGRectMake(0, 0, 320, 320)];
	}
	else
	{
		[backgroundImage drawInRect:backgroundView.frame];
	}
	
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext() ;
    UIGraphicsEndImageContext() ;
    
    [self.foreground.filter useNextFrameForImageCapture];
    [self.foreground.picture processImage];
    UIImage *foregroundImage = [self.foreground.filter imageFromCurrentFramebuffer];
    NSLog(@"on done image = %@:%@, background imageframe : %@:%@", NSStringFromCGSize(foregroundImage.size), NSStringFromCGRect(foregroundView.frame), NSStringFromCGSize(image.size), NSStringFromCGSize(backgroundImage.size));
    
    if ([viewController.pickerDelegate respondsToSelector:@selector(photoPickerController:didSelectBackground:avatar:)]) {
        [viewController.pickerDelegate photoPickerController:viewController didSelectBackground:image avatar:foregroundImage];

    } else if ([viewController.pickerDelegate respondsToSelector:@selector(photoPickerController:didSelectImage:avatar:frame:)]) {
        [viewController.pickerDelegate photoPickerController:viewController didSelectImage:image avatar:foregroundImage frame:foregroundView.frame];
    }
	
	
//	PhotoPickerController *viewController = (PhotoPickerController *)self.navigationController;
//	
//    [self.background.filter useNextFrameForImageCapture];
//    [self.background.picture processImage];
//    UIImage *backgroundImage = [self.background.filter imageFromCurrentFramebuffer];
//	
//    [self.foreground.filter useNextFrameForImageCapture];
//    [self.foreground.picture processImage];
//    UIImage *foregroundImage = [self.foreground.filter imageFromCurrentFramebuffer];
//    
//    if ([viewController.pickerDelegate respondsToSelector:@selector(photoPickerController:didSelectBackground:avatar:)]) {
//        [viewController.pickerDelegate photoPickerController:viewController didSelectBackground:backgroundImage avatar:foregroundImage];
//    }
}

- (IBAction)onBtnLayer:(id)sender
{
    [self hideSlider];
    
    if (!self.foreground) {
        [[[UIActionSheet alloc] initWithTitle:@"Pick a Photo Source" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"Camera",@"Photo Library", nil] showInView:self.view];
    } else {
        if (self.selectedData == self.background) {
            self.selectedData = self.foreground;
            [viewForPhoto bringSubviewToFront:foregroundView];
        } else {
            self.selectedData = self.background;
            [viewForPhoto bringSubviewToFront:backgroundView];
        }
    }
}

- (IBAction)onBtnBrightness:(id)sender
{
    sliderType = 1;
    
    slider.minimumValue = -1.0f;
    slider.maximumValue = 1.0f;
    
    [self showSlider:self.selectedData.brightness.brightness];
}

- (IBAction)onBtnTransprency:(id)sender
{
    sliderType = 2;
    
    slider.minimumValue = 0.0f;
    slider.maximumValue = 1.0f;
    
    [self showSlider:self.selectedData.imageView.alpha];
}

- (IBAction)onBtnCrop:(id)sender
{
    [self hideSlider];

    UIImageView *imageView = [[viewForPhoto subviews] lastObject];
    PECropViewController *viewController = [[PECropViewController alloc] init];
    viewController.delegate = self;
    viewController.cropRect = imageView.bounds;

    if (self.selectedData == self.background) {
        viewController.image = self.backgroundImage;
    } else {
        viewController.image = self.foregroundImage;
    }
    
    UINavigationController *naviController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:naviController animated:YES completion:^{
        
    }];
}

@end
