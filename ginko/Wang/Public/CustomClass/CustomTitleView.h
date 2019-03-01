//
//  HomeInfoView.h
//  Xchangewithme
//
//  Created by Xin YingTai on 20/5/14.
//  Copyright (c) 2014 Xin YingTai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTitleView : UIView

+ (CustomTitleView *)homeInfoView;
+ (CustomTitleView *)homeaddInfoView;
+ (CustomTitleView *)homePreviewView;
+ (CustomTitleView *)homeEditView;

+ (CustomTitleView *)workInfoView;
+ (CustomTitleView *)workaddInfoView;
+ (CustomTitleView *)workPreviewView;
+ (CustomTitleView *)workEditView;

+ (CustomTitleView *)entityView :(NSString*)title;

@end
