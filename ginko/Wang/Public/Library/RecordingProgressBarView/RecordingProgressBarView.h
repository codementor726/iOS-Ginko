//
//  RecordingProgressBarView.h
//  Sharecord
//
//  Created by Gabi Purcaru on 10/2/13.
//  Copyright (c) 2013 Sharecord. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordingProgressBarView : UIView

@property BOOL tickOn;
@property BOOL normal;

-(void)redraw;
-(void)setMaximumTime:(int)seconds;
-(void)addShot;
-(void)finishShot;
-(void)updateShot:(double)seconds;
-(void)highightLastShotForRemoval:(BOOL)highlight;
-(void)removeLastShot;
-(void)setIsRecording:(BOOL)_isRecording;
-(void)clear;

@property CGContextRef context;
@property (retain) NSMutableArray *shots;

@end
