//
//  PhotoViewController.h
//  Xchangewithme
//
//  Created by Xin YingTai on 20/5/14.
//  Copyright (c) 2014 Xin YingTai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoViewController : UIViewController <UIAlertViewDelegate>
{
    IBOutlet UIButton *btnForBack;
    IBOutlet UIButton *btnForEdit;
    IBOutlet UIButton *btnForClose;    
    IBOutlet UIBarButtonItem *itemForSkip;
//    __weak IBOutlet UIButton *btnForSkip;
	
	IBOutlet UILabel *lblForHidden;
	IBOutlet UIImageView *imgForHidden;
    
    __weak IBOutlet UILabel *EditTitleLabel;
    __weak IBOutlet UILabel *CreateTitleLabel;
    __weak IBOutlet UILabel *createWorkLabel;
    IBOutlet UILabel *lblSkip;
    IBOutlet UILabel *lblArchive;
    IBOutlet UIScrollView *scvArchive;
}

@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) NSString *entityID;
@property BOOL isCreate;//create flag that will be used in signup process

- (void)didSelectBackgroundColor:(int)index;

@end
