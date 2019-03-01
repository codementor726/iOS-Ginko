//
//  IMPhotoEditController.h
//  Xchangewithme
//
//  Created by Xin YingTai on 21/5/14.
//  Copyright (c) 2014 Xin YingTai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HIPImageCropperView.h"
@class TouchView;

@interface IMPhotoEditController : UIViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>
{
    IBOutlet UIButton *btnForDelete;
    IBOutlet UIButton *btnForApply;
    
    IBOutlet UIView *viewForPhoto;
    IBOutlet TouchView *backgroundView;
    IBOutlet TouchView *foregroundView;
    IBOutlet UISlider *slider;
    IBOutlet UIView *viewForFilter;
    
    IBOutlet UIButton *btnForLayer;
}

@property (strong, nonatomic) HIPImageCropperView *imageCropperView;
@property (nonatomic, strong) UIImage *sourceImage;

@property (nonatomic, retain) UIImage *backgroundImage;
@property (nonatomic, retain) UIImage *foregroundImage;
- (void)movePushNotificationChatViewController:(NSNumber *)boardID isDeletedFriend:(BOOL)isDetetedFriend users:(NSMutableArray *)lstUsers isDirectory:(NSDictionary *)directoryInfo;
- (void)movePushNotificationConferenceViewController:(NSDictionary *)dic;
@end
