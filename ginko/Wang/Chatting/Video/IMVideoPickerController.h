//
//  IMVideoPickerController.h
//  XChangeWithMe
//
//  Created by Xin YingTai on 25/5/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IMVideoPickerController;

@protocol IMVideoPickerControllerDelegate <NSObject>
@optional

- (void)videoPickerController:(IMVideoPickerController *)pickerController didSelectVideo:(NSURL *)videoURL;
- (void)videoPickerControllerDidCancel:(IMVideoPickerController *)pickerController;

@end

@interface IMVideoPickerController : UINavigationController

@property (nonatomic, assign) BOOL navBarColor;
@property (nonatomic, weak) id <IMVideoPickerControllerDelegate> pickerDelegate;

- (id)initWithType;

@end
