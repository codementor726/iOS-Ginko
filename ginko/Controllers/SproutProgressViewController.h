//
//  SproutProgressViewController.h
//  ginko
//
//  Created by STAR on 8/25/15.
//  Copyright (c) 2015 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SproutProgressViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *progressImageView;
- (void)presentWindow;
- (void)hideWindow;
@end
