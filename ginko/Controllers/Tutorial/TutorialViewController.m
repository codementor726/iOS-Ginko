//
//  TutorialViewController.m
//  ginko
//
//  Created by ccom on 10/16/15.
//  Copyright © 2015 com.xchangewithme. All rights reserved.
//

#import "TutorialViewController.h"

@interface TutorialViewController ()

@end

@implementation TutorialViewController {
    NSInteger dotSize;
    NSInteger space;
    UIColor *purple;
    UIColor *green;
    NSMutableArray *pDots;
    NSMutableArray *gDots;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUI {
    dotSize = 8;
    space = 2;
    purple  = [UIColor colorWithRed:126/255.0 green:87/255.0 blue:133/255.0 alpha:1.0];
    green  = [UIColor colorWithRed:118/255.0 green:185/255.0 blue:115/255.0 alpha:1.0];
    pDots = [NSMutableArray array];
    gDots = [NSMutableArray array];
    CGPoint centerP = CGPointMake(CGRectGetWidth(self.dotsView.frame)/2, CGRectGetHeight(self.dotsView.frame)/2);
    for (int i=0; i<4; i++) {
        UIView *pDot = [self dotView:purple];
        NSInteger pOffset = (4-i) * (dotSize + space);
        CGPoint pDotCenter = centerP;
        pDotCenter.x -= pOffset;
        pDot.center = pDotCenter;
        [pDots addObject:pDot];
        [self.dotsView addSubview:pDot];
        
        UIView *gDot = [self dotView:green];
        NSInteger gOffset = (i+1) * (dotSize + space);
        CGPoint gDotCenter = centerP;
        gDotCenter.x += gOffset;
        gDot.center = gDotCenter;
        [gDots addObject:gDot];
        [self.dotsView addSubview:gDot];
    }
    
    CGFloat imageScale = 480.0f / 984.0f;
    //CGSize size = self.scrollView.frame.size;
    CGSize size = [[UIScreen mainScreen] bounds].size;
    CGSize dotSize = self.dotsView.frame.size;
    CGFloat headHeight = 64.0f;
    
    CGFloat vImageSizeHeight = size.height - dotSize.height - headHeight - 20.0f;
    CGFloat vImageSizeWidth = vImageSizeHeight * imageScale;
    
    [self.scrollView setContentSize:CGSizeMake(8*size.width, size.height - headHeight)];
    for (int i=0; i<8; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"Page%d", i+1]]];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        imageView.frame = CGRectMake(i*size.width + (size.width - vImageSizeWidth) / 2, 10, vImageSizeWidth, vImageSizeHeight);
        [self.scrollView addSubview:imageView];
    }
    [self setCurrentPage:0];
}

- (void)setCurrentPage:(NSInteger)page {
    for (int i =0; i<4; i++) {
        UIView *view = pDots[i];
        view.backgroundColor = [UIColor whiteColor];
        view = gDots[i];
        view.backgroundColor = [UIColor whiteColor];
    }
    if (page < 4) {
        UIView *view = pDots[page];
        [view setBackgroundColor:purple];
    }
    else {
        UIView *view = gDots[page-4];
        [view setBackgroundColor:green];
    }
}

- (IBAction)onClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIView*)dotView:(UIColor*)color {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dotSize, dotSize)];
//    view.backgroundColor = [UIColor blackColor];
    [view.layer setCornerRadius:dotSize/2];
    view.layer.masksToBounds = YES;
    [view.layer setBorderWidth:0.6];
    [view.layer setBorderColor:color.CGColor];
    return view;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = self.scrollView.frame.size.width;
    float fractionalPage = self.scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    [self setCurrentPage:page];
}
@end
