//
//  WallpaperEditViewController.m
//  ginko
//
//  Created by STAR on 1/5/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "WallpaperEditViewController.h"
#import "FilterView.h"
#import "GPUImage.h"

@interface WallpaperEditViewController () <FilterViewDelegate> {
    GPUImagePicture *picture;
    GPUImageOutput<GPUImageInput> *filter;
    GPUImageBrightnessFilter *brightness;
    FilterView *realFilterView;
    
    NSInteger sliderType;
}
@end

@implementation WallpaperEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    _imageCropperView = [[HIPImageCropperView alloc]
                         initWithFrame:self.view.bounds
                         cropAreaSize:CGSizeMake(320, 130)
                         position:HIPImageCropperViewPositionCenter
                         borderVisible:YES];
    _imageCropperView.isOval = NO;
    _imageCropperView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_imageCropperView];
    
    NSDictionary *viewsDictionary = @{@"cropperView":_imageCropperView};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[cropperView]|" options:0 metrics:0 views:viewsDictionary]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_imageCropperView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_imageCropperView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_filterView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    
    [_imageCropperView setOriginalImage:_sourceImage];
    
    realFilterView = [FilterView sharedView];
    realFilterView.delegate = self;
    realFilterView.frame = _filterView.bounds;
    realFilterView.translatesAutoresizingMaskIntoConstraints = NO;
    [_filterView addSubview:realFilterView];
    
    [_filterView addConstraint:[NSLayoutConstraint constraintWithItem:realFilterView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_filterView attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [_filterView addConstraint:[NSLayoutConstraint constraintWithItem:realFilterView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_filterView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    [_filterView addConstraint:[NSLayoutConstraint constraintWithItem:realFilterView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_filterView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [_filterView addConstraint:[NSLayoutConstraint constraintWithItem:realFilterView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_filterView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    
    picture = [[GPUImagePicture alloc] initWithImage:_sourceImage smoothlyScaleOutput:NO];
    filter = [[GPUImageFilter alloc] init];
    brightness = [[GPUImageBrightnessFilter alloc] init];
    brightness.brightness = 0.0f;
    
    [self didSelectFilter:@0];
    
    _slider.center = CGPointMake(300, 160);
    _slider.transform = CGAffineTransformMakeRotation(-M_PI_2);
    [self.view bringSubviewToFront:_slider];
}

- (void)viewDidLayoutSubviews {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)choose:(id)sender {
    UIImage *resultImage = [_imageCropperView processedImage];
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectWallpaperImage:)])
        [_delegate didSelectWallpaperImage:resultImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onBrightness:(id)sender {
    sliderType = 1;
    
    _slider.minimumValue = -1.0f;
    _slider.maximumValue = 1.0f;
    
    [self showSlider:brightness.brightness];
}

- (IBAction)onTransparency:(id)sender {
    sliderType = 2;
    
    _slider.minimumValue = 0.0f;
    _slider.maximumValue = 1.0f;
    
    [self showSlider:_imageCropperView.imageView.alpha];
}

- (IBAction)onSliderChange:(id)sender {
    if (sliderType == 1) {
        brightness.brightness = _slider.value;
        [filter useNextFrameForImageCapture];
        
        [picture processImageWithCompletionHandler:^{
            UIImage *image = [filter imageFromCurrentFramebuffer];
            dispatch_async(dispatch_get_main_queue(), ^{
//                [_imageCropperView setOriginalImage:image withCropFrame:_imageCropperView.cropFrame];
                _imageCropperView.imageView.image = image;
            });
        }];
    } else {
        _imageCropperView.imageView.alpha = _slider.value;
    }
}

- (void)showSlider:(CGFloat)value;
{
    _slider.value = value;
    [UIView animateWithDuration:0.3f animations:^{
        _slider.alpha = 1.0f;
    }];
}

#pragma mark - FilterViewDelegate
- (void)didSelectFilter:(NSNumber *)index {
    FilterType filterType = [index integerValue];
    
    [picture removeAllTargets];
    [filter removeAllTargets];
    
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
    
    [picture addTarget:filter];
    [filter useNextFrameForImageCapture];
    
    [picture processImageWithCompletionHandler:^{
        UIImage *image = [filter imageFromCurrentFramebuffer];
        dispatch_async(dispatch_get_main_queue(), ^{
//            [_imageCropperView setOriginalImage:image withCropFrame:_imageCropperView.cropFrame];
            _imageCropperView.imageView.image = image;
        });
    }];
}

@end
