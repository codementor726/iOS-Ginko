//
//  VideoViewController.h
//  Xchangewithme
//
//  Created by Xin YingTai on 21/5/14.
//  Copyright (c) 2014 Xin YingTai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoViewController : UIViewController <UIAlertViewDelegate>
{
    IBOutlet UIBarButtonItem *itemForSkip;
    IBOutlet UIView *viewArchive;
    IBOutlet UIScrollView *scvArchive;
}

@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) NSString *entityID;

@property (nonatomic, assign) BOOL isSetup;
@property (weak, nonatomic) IBOutlet UIImageView *leafImageView;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *pictureButton;
@property (weak, nonatomic) IBOutlet UIImageView *videoArchiveImage;
@property (weak, nonatomic) IBOutlet UILabel *videoArchiveLabel;


@end
