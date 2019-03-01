//
//  TouchTextField.h
//  XChangeWithMe
//
//  Created by Wang MeiHua on 5/22/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TouchLabelDelegate <NSObject>

-(void)tappedLabel:(id)view;

@end

@interface TouchLabel : UILabel

-(void)initData;

@property (nonatomic,retain) id<TouchLabelDelegate> delegate;
@end
