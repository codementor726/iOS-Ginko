//
//  ProfileImageEditViewController.m
//  ginko
//
//  Created by Harry on 1/8/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "ProfileImageEditViewController.h"

@interface ProfileImageEditViewController ()

@end

@implementation ProfileImageEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;

    _imageCropperView = [[HIPImageCropperView alloc]
                         initWithFrame:self.view.bounds
                         cropAreaSize:CGSizeMake(200, 200)
                         position:HIPImageCropperViewPositionCenter
                         borderVisible:NO];
    if (!_isEntity) { // square
        _imageCropperView.isOval = YES;
    }
    
    _imageCropperView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_imageCropperView];
    
    NSDictionary *viewsDictionary = @{@"cropperView":_imageCropperView};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[cropperView]|" options:0 metrics:0 views:viewsDictionary]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_imageCropperView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_imageCropperView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_toolbar attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    
    [_imageCropperView setOriginalImage:_sourceImage];
    
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
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectProfileImage:)])
        [_delegate didSelectProfileImage:resultImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
