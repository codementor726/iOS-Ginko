//
//  TutorialViewController.h
//  ginko
//
//  Created by ccom on 10/16/15.
//  Copyright © 2015 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialViewController : UIViewController<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *dotsView;
@end
