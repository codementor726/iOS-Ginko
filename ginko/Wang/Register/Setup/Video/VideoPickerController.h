//
//  VideoPickerController.h
//  XChangeWithMe
//
//  Created by Xin YingTai on 25/5/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VideoPickerController;

@protocol VideoPickerControllerDelegate <NSObject>
@optional

- (void)videoPickerController:(VideoPickerController *)pickerController didSelectVideo:(NSURL *)videoURL;
- (void)videoPickerControllerDidCancel:(VideoPickerController *)pickerController;

@end

@interface VideoPickerController : UINavigationController

@property (nonatomic, weak) id <VideoPickerControllerDelegate> pickerDelegate;
@property (nonatomic, assign) BOOL showBackButton;
@property (nonatomic, assign) BOOL close;
@property (nonatomic, assign) NSInteger type;

- (id)initWithType:(NSInteger)type entityID:(NSString *)entityID isSetup:(BOOL)isSetup;

@end
