//
//  PhotoPickerController.h
//  XChangeWithMe
//
//  Created by Xin YingTai on 25/5/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoPickerController;

@protocol PhotoPickerControllerDelegate <NSObject>
@optional

- (void)photoPickerController:(PhotoPickerController *)pickerController didSelectBackground:(UIImage *)background avatar:(UIImage *)avatar;
- (void)photoPickerController:(PhotoPickerController *)pickerController didSelectImage:(UIImage *)background avatar:(UIImage *)avatar frame:(CGRect)frame; 
- (void)photoPickerControllerDidEdit:(PhotoPickerController *)pickerController;
- (void)photoPickerControllerDidCancel:(PhotoPickerController *)pickerController;

- (void)photoPickerController:(PhotoPickerController *)pickerController didPickupImage:(NSDictionary *)pickDict;

@end

@interface PhotoPickerController : UINavigationController

@property (nonatomic, weak) id <PhotoPickerControllerDelegate> pickerDelegate;
@property (nonatomic, assign) BOOL showBackButton;
@property (nonatomic, assign) BOOL showEditButton;
@property (nonatomic, assign) BOOL close;
@property (nonatomic, assign) NSInteger type;

- (id)initWithType:(NSInteger)type entityID:(NSString *)entityID;

@end
