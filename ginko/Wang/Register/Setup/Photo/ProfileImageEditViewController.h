//
//  ProfileImageEditViewController.h
//  ginko
//
//  Created by Harry on 1/8/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HIPImageCropperView.h"

@protocol ProfileImageEditViewControllerDelegate <NSObject>

- (void)didSelectProfileImage:(UIImage *)image;

@end

@interface ProfileImageEditViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) HIPImageCropperView *imageCropperView;
- (IBAction)cancel:(id)sender;
- (IBAction)choose:(id)sender;

// set from outside
@property (nonatomic, assign) BOOL isEntity;
@property (nonatomic, strong) UIImage *sourceImage;
@property (weak, nonatomic) id <ProfileImageEditViewControllerDelegate> delegate;
@end
