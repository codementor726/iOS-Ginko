//
//  PhotoPickerController.h
//  XChangeWithMe
//
//  Created by Xin YingTai on 25/5/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IMPhotoPickerController;

@protocol IMPhotoPickerControllerDelegate <NSObject>
@optional

- (void)IMphotoPickerController:(IMPhotoPickerController *)pickerController didSelectBackground:(UIImage *)background avatar:(UIImage *)avatar;
- (void)IMphotoPickerControllerDidEdit:(IMPhotoPickerController *)pickerController;
- (void)IMphotoPickerControllerDidCancel:(IMPhotoPickerController *)pickerController;

@end

@interface IMPhotoPickerController : UINavigationController
@property (nonatomic, weak) id <IMPhotoPickerControllerDelegate> pickerDelegate;

- (id)initWithType;
@end
