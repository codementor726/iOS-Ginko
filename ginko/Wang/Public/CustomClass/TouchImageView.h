//
//  TouchImageView.h
//  XChangeWithMe
//
//  Created by Wang MeiHua on 5/22/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TouchImageViewDelegate <NSObject>

-(void)tappedTouchImage;

@end

@interface TouchImageView : UIImageView
{
	
}

-(void)initData;
@property (nonatomic,retain) id<TouchImageViewDelegate> delegate;

@end
