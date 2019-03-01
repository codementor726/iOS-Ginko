//
//  WallpaperEditViewController.h
//  ginko
//
//  Created by STAR on 1/5/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HIPImageCropperView.h"

@protocol WallpaperEditViewControllerDelegate <NSObject>

- (void)didSelectWallpaperImage:(UIImage *)image;

@end

@interface WallpaperEditViewController : UIViewController

@property (strong, nonatomic) HIPImageCropperView *imageCropperView;
@property (weak, nonatomic) IBOutlet UIView *filterView;
@property (weak, nonatomic) IBOutlet UISlider *slider;
- (IBAction)cancel:(id)sender;
- (IBAction)choose:(id)sender;
- (IBAction)onBrightness:(id)sender;
- (IBAction)onTransparency:(id)sender;
- (IBAction)onSliderChange:(id)sender;

// set from outside
@property (nonatomic, strong) UIImage *sourceImage;
@property (weak, nonatomic) id <WallpaperEditViewControllerDelegate> delegate;
@end
