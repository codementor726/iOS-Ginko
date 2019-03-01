//
//  RecordingProgressBarView.m
//  Sharecord
//
//  Created by Gabi Purcaru on 10/2/13.
//  Copyright (c) 2013 Sharecord. All rights reserved.
//

#import "RecordingProgressBarView.h"

@implementation RecordingProgressBarView

@synthesize tickOn;
@synthesize context;
@synthesize shots;

int maximumTime = 0;
BOOL lastShotIsHihghlighted = NO;
BOOL isRecording = NO;


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(tick) userInfo:Nil repeats:YES];
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(tick) userInfo:Nil repeats:YES];
    return self;
}

- (void)tick {
    tickOn = !tickOn;
    [self redraw];
}

- (void)drawRect:(CGRect)_rect {
    CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    CGRect innerRect = CGRectMake(0, 1, self.frame.size.width - 2, self.frame.size.height - 2);
    context = UIGraphicsGetCurrentContext();
    [self drawInnerRect:rect withColor:[UIColor colorWithRed:0.11 green:0.11 blue:0.11 alpha:0.5]];
    
    __block double offsetX = 0;
    double shotSpacing = 1;
    __block double totalDuration = 0;
    
    [shots enumerateObjectsUsingBlock:^(NSNumber *time, NSUInteger idx, BOOL *stop) {
        double width = MAX(shotSpacing, [time floatValue] / maximumTime * innerRect.size.width);
        totalDuration += [time floatValue];
        UIColor *color;
        if(idx + 1 == [shots count] && lastShotIsHihghlighted) {
            color = [UIColor colorWithRed:0.7098 green:0.008 blue:0.008 alpha:0.5];
        } else {
            color = [UIColor colorWithRed:0.008 green:0.729 blue:0.6588 alpha:0.5];
        }
        
        if(idx + 1 == [shots count]) {
            [self drawInnerRect:CGRectMake(offsetX + shotSpacing, 1, MIN(width - shotSpacing, innerRect.size.width - offsetX), innerRect.size.height) withColor:color];
            offsetX += width;
        } else {
            double w = ceil(width) - shotSpacing;
            if(w < 1) {
                w = 1;
            }
            [self drawInnerRect:CGRectMake(offsetX + shotSpacing, 1, w, innerRect.size.height) withColor:color];
            offsetX += w + shotSpacing;
        }
//        NSLog(@"Time: %f, Duration: %f, Width: %f, Offset: %f",[time floatValue],totalDuration,width,offsetX);
    }];
    
    if (!self.normal) {
        if((isRecording || tickOn) && !lastShotIsHihghlighted) {
            if(isRecording || (innerRect.size.width - offsetX >= 2 && offsetX > 0 )) {
                if (isRecording) {
                    [self drawInnerRect:CGRectMake(offsetX, 1, MIN(2, innerRect.size.width - offsetX), innerRect.size.height) withColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
                } else {
                    [self drawInnerRect:CGRectMake(offsetX + 1, 1, MIN(2, innerRect.size.width - offsetX), innerRect.size.height) withColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
                }
            }
        }
    }
    
    offsetX += 3;
    
    context = nil;
}

-(void)drawInnerRect:(CGRect)rect withColor:(UIColor *)color {
    if(!context) {
        return;
    }
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    const float red = components[0];
    const float green = components[1];
    const float blue = components[2];
    const float alpha = components[3];
    CGContextSetRGBFillColor(context, red, green, blue, alpha);
    CGContextFillRect(context, rect);
}

-(void)redraw {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setContentMode:UIViewContentModeRedraw];
        [self setNeedsDisplay];
    });
}

-(void)setMaximumTime:(int)seconds {
    maximumTime = seconds;
    [self redraw];
}

-(void)addShot {
    if(shots == nil) {
        shots = [[NSMutableArray alloc] init];
    }
    [shots addObject:[NSNumber numberWithInt:0]];
    [self redraw];
}

-(void)finishShot {
    if(shots == nil) {
        shots = [[NSMutableArray alloc] init];
    }
//  [shots addObject:[NSNumber numberWithInt:0]];
    [self performSelector:@selector(redraw) withObject:nil afterDelay:0.3f];
}

-(void)updateShot:(double)seconds {
    [shots removeLastObject];
    [shots addObject:[NSNumber numberWithDouble:seconds]];
    [self redraw];
}

-(void)highightLastShotForRemoval:(BOOL)highlight {
    lastShotIsHihghlighted = highlight;
    [self redraw];
}

-(void)removeLastShot {
    lastShotIsHihghlighted = NO;
    [shots removeLastObject];
    [self redraw];
}

-(void)setIsRecording:(BOOL)_isRecording {
    isRecording = _isRecording;
    [self redraw];
}

-(void)clear {
    [shots removeAllObjects];
    lastShotIsHihghlighted = NO;
    isRecording = NO;
    [self redraw];
}

@end
