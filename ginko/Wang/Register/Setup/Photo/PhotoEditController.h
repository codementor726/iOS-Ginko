//
//  PhotoEditController.h
//  Xchangewithme
//
//  Created by Xin YingTai on 21/5/14.
//  Copyright (c) 2014 Xin YingTai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TouchView;

@interface PhotoEditController : UIViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>
{
    IBOutlet UIButton *btnForDelete;
    IBOutlet UIButton *btnForApply;
    
    IBOutlet UIView *viewForPhoto;
    IBOutlet TouchView *backgroundView;
    IBOutlet TouchView *foregroundView;
    IBOutlet UISlider *slider;
    IBOutlet UIView *viewForFilter;
    
    IBOutlet UIButton *btnForLayer;
	
	BOOL bPinch;
	
	CGRect rtBackgroundView;
}

@property (nonatomic, retain) UIImage *backgroundImage;
@property (nonatomic, retain) UIImage *foregroundImage;

@end
