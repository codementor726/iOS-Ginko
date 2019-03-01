//
//  IMVideoCameraController.m
//  Xchangewithme
//
//  Created by Xin YingTai on 21/5/14.
//  Copyright (c) 2014 Xin YingTai. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "IMVideoPickerController.h"
#import "IMVideoCameraController.h"

#import "CustomTitleView.h"
#import "RecordingProgressBarView.h"
#import "FilterView.h"

#import "GPUImage.h"

#import "EZAudioFile.h"
#import "EZAudioPlot.h"

#import "MBProgressHUD.h"

#import "VideoVoiceConferenceViewController.h"
static NSString * const kNotificationDidChangeOrientation = @"didChangeOrientation";

@interface IMVideoSegment : NSObject

@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) NSURL *audioURL;
@property (nonatomic, assign) BOOL audio;

@end

@implementation IMVideoSegment

@end

@interface IMVideoCameraController () <FilterViewDelegate, MPMediaPickerControllerDelegate, GPUImageMovieDelegate, UIScrollViewDelegate,UIAlertViewDelegate, GPUImageMovieWriterDelegate>
{
    GPUImageMovie *movie;
    GPUImageMovieWriter *movieWriter;
    GPUImageStillCamera *camera;
    GPUImageRotationMode rotationMode;
    GPUImageCropFilter *cropFilter;
    GPUImageOutput<GPUImageInput> *filter;
    
    NSMutableArray *segments;
    bool recording;
    double progress;

    AVAudioRecorder *recorder;
    NSMutableDictionary *recordSetting;

    BOOL applied;
    CMTime totalDuration;

    NSInteger current;
    BOOL playing;
    BOOL playingSegment;

    AVAudioPlayer *player;
    NSURL *audio;
    EZAudioFile *audioFile;
    
    NSMutableSet *buttons;
    
    BOOL isSelectedCutBtn;
    
    UITapGestureRecognizer *tapGestureOne;
    
    BOOL isCreate;
}

@end

@implementation IMVideoCameraController
@synthesize imageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        segments = [[NSMutableArray alloc] init];
        
        recordSetting = [[NSMutableDictionary alloc] init];
        
        [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
        [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
        [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
        
        [recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
        [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.navigationItem.title = @"Take Video";

    UIBarButtonItem *itemForBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackArrow"] style:UIBarButtonItemStylePlain target:self action:@selector(onBtnBack:)];
    self.navigationItem.leftBarButtonItem = itemForBack;
    
    UIBarButtonItem *itemForApply = [[UIBarButtonItem alloc] initWithCustomView:btnForApply];
    self.navigationItem.rightBarButtonItem = itemForApply;
    
    isSelectedCutBtn = NO;
    
    // Progress Bar;
    [viewForProgress setTickOn:NO];
    [viewForProgress setMaximumTime:30];
    
    // Audio;
    viewForWave.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f];
    viewForWave.color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];

    // Filter View;
    FilterView *filterView = [FilterView sharedView];
    filterView.delegate = self;
    filterView.frame = viewForFilter.bounds;
    [viewForFilter addSubview:filterView];

    // Tools;
    buttons = [[NSMutableSet alloc] init];
    
    [buttons addObject:btnForGrid];
    [buttons addObject:btnForFlip];
    [buttons addObject:btnForFlash];
    [buttons addObject:btnForMicrophone];
    [buttons addObject:btnForFocus];
    [buttons addObject:btnForGhost];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    tapGestureOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGesture:)];
    [viewForVideo addGestureRecognizer:tapGestureOne];

    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressGesture:)];
    [viewForVideo addGestureRecognizer:longGesture];
    
    imageView = [[GPUImageView alloc] initWithFrame:viewForVideo.bounds];
    [viewForVideo addSubview:imageView];
    [viewForVideo sendSubviewToBack:imageView];
    
    cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0.0f, 0.0f, 1.0f, 0.75f)];
    filter = [[GPUImageGammaFilter alloc] init];
    
    camera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
    camera.horizontallyMirrorFrontFacingCamera = YES;
    camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    btnForApply.hidden = YES;
    btnForCut.enabled = NO;
    [self startCamera];
    isCreate=NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeOrientation:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted){
        if (granted) {
            NSLog(@"granted");
        }else {
            NSLog(@"denied");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Micorphone Access Denied" message:@"You must allow microphone access in Setting > Privacy > Microphone" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidChangeOrientation object:nil];
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidChangeOrientation object:nil];
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
	return UIInterfaceOrientationPortrait;
}

- (void)didChangeOrientation:(NSNotification *)notification
{
    UIInterfaceOrientation deviceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    camera.outputImageOrientation = deviceOrientation;

    if (!buttons || [buttons count] <= 0) {
        return;
    }
    
    [buttons enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        UIButton *button = [obj isKindOfClass:[UIButton class]]?obj:nil;
        
        if (!button) {
            *stop = YES;
            return;
        }
        
        button.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
        CGAffineTransform transform = CGAffineTransformMakeRotation(0);
        
        switch ([UIDevice currentDevice].orientation) {
            case UIDeviceOrientationPortrait:
                transform = CGAffineTransformMakeRotation(0);
                break;
                
            case UIDeviceOrientationPortraitUpsideDown:
                transform = CGAffineTransformMakeRotation(M_PI);
                break;
                
            case UIDeviceOrientationLandscapeLeft:
                transform = CGAffineTransformMakeRotation(M_PI_2);
                break;
                
            case UIDeviceOrientationLandscapeRight:
                transform = CGAffineTransformMakeRotation(-M_PI_2);
                break;
                
            default:
                break;
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            button.transform = transform;
        }];
    }];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(play) object:nil];
    [self stop];
    [viewForVideo removeGestureRecognizer:tapGestureOne];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self performSelector:@selector(play) withObject:nil afterDelay:0.5f];
}

- (void)didSelectFilter:(NSNumber *)index
{
    if (recording) {
        if (!applied) {
            [self stopRecording];
        }
    }
    FilterType filterType = [index integerValue];
    
    [self removeAllTargets];
    
    [self setFilterType:filterType];
    [self applyFilter];
//    if (recording) {
//        if (!applied) {
//            [self performSelector:@selector(startRecording) withObject:nil afterDelay:0.1];
//        }
//    }
}

- (void)setFilterType:(FilterType)filterType
{
    [AppDelegate sharedDelegate].bFiltered = YES;
    switch (filterType) {
        case FilterTypeBookStore:
        {
            filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageToneCurveFilter *tone = [[GPUImageToneCurveFilter alloc] initWithACV:@"BookStore"];
            GPUImageSaturationFilter *saturation = [[GPUImageSaturationFilter alloc] init];
            
            [(GPUImageFilterGroup *)filter addFilter:saturation];
            [tone addTarget:saturation];
            
            [(GPUImageFilterGroup *)filter setInitialFilters:[NSArray arrayWithObject:tone]];
            [(GPUImageFilterGroup *)filter setTerminalFilter:saturation];
            break;
        }
            
        case FilterTypeCity:
        {
            filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageToneCurveFilter *tone = [[GPUImageToneCurveFilter alloc] initWithACV:@"City"];
            GPUImageSaturationFilter *saturation = [[GPUImageSaturationFilter alloc] init];
            
            [(GPUImageFilterGroup *)filter addFilter:saturation];
            [tone addTarget:saturation];
            
            [(GPUImageFilterGroup *)filter setInitialFilters:[NSArray arrayWithObject:tone]];
            [(GPUImageFilterGroup *)filter setTerminalFilter:saturation];
            break;
        }
            
        case FilterTypeCountry:
        {
            filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageToneCurveFilter *tone = [[GPUImageToneCurveFilter alloc] initWithACV:@"Country"];
            GPUImageSaturationFilter *saturation = [[GPUImageSaturationFilter alloc] init];
            
            [(GPUImageFilterGroup *)filter addFilter:saturation];
            [tone addTarget:saturation];
            
            [(GPUImageFilterGroup *)filter setInitialFilters:[NSArray arrayWithObject:tone]];
            [(GPUImageFilterGroup *)filter setTerminalFilter:saturation];
            break;
        }
            
        case FilterTypeFilm:
        {
            filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageToneCurveFilter *tone = [[GPUImageToneCurveFilter alloc] initWithACV:@"Film"];
            GPUImageSaturationFilter *saturation = [[GPUImageSaturationFilter alloc] init];
            
            [(GPUImageFilterGroup *)filter addFilter:saturation];
            [tone addTarget:saturation];
            
            [(GPUImageFilterGroup *)filter setInitialFilters:[NSArray arrayWithObject:tone]];
            [(GPUImageFilterGroup *)filter setTerminalFilter:saturation];
            break;
        }
            
        case FilterTypeForest:
        {
            filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageToneCurveFilter *tone = [[GPUImageToneCurveFilter alloc] initWithACV:@"Forest"];
            GPUImageSaturationFilter *saturation = [[GPUImageSaturationFilter alloc] init];
            
            [(GPUImageFilterGroup *)filter addFilter:saturation];
            [tone addTarget:saturation];
            
            [(GPUImageFilterGroup *)filter setInitialFilters:[NSArray arrayWithObject:tone]];
            [(GPUImageFilterGroup *)filter setTerminalFilter:saturation];
            break;
        }
            
        case FilterTypeLake:
        {
            filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageToneCurveFilter *tone = [[GPUImageToneCurveFilter alloc] initWithACV:@"Lake"];
            GPUImageSaturationFilter *saturation = [[GPUImageSaturationFilter alloc] init];
            
            [(GPUImageFilterGroup *)filter addFilter:saturation];
            [tone addTarget:saturation];
            
            [(GPUImageFilterGroup *)filter setInitialFilters:[NSArray arrayWithObject:tone]];
            [(GPUImageFilterGroup *)filter setTerminalFilter:saturation];
            break;
        }
            
        case FilterTypeMoment:
        {
            filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageToneCurveFilter *tone = [[GPUImageToneCurveFilter alloc] initWithACV:@"Moment"];
            GPUImageSaturationFilter *saturation = [[GPUImageSaturationFilter alloc] init];
            
            [(GPUImageFilterGroup *)filter addFilter:saturation];
            [tone addTarget:saturation];
            
            [(GPUImageFilterGroup *)filter setInitialFilters:[NSArray arrayWithObject:tone]];
            [(GPUImageFilterGroup *)filter setTerminalFilter:saturation];
            break;
        }
            
        case FilterTypeNYC:
        {
            filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageToneCurveFilter *tone = [[GPUImageToneCurveFilter alloc] initWithACV:@"NYC"];
            GPUImageSaturationFilter *saturation = [[GPUImageSaturationFilter alloc] init];
            
            [(GPUImageFilterGroup *)filter addFilter:saturation];
            [tone addTarget:saturation];
            
            [(GPUImageFilterGroup *)filter setInitialFilters:[NSArray arrayWithObject:tone]];
            [(GPUImageFilterGroup *)filter setTerminalFilter:saturation];
            break;
        }
            
        case FilterTypeTea:
        {
            filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageToneCurveFilter *tone = [[GPUImageToneCurveFilter alloc] initWithACV:@"Tea"];
            GPUImageSaturationFilter *saturation = [[GPUImageSaturationFilter alloc] init];
            
            [(GPUImageFilterGroup *)filter addFilter:saturation];
            [tone addTarget:saturation];
            
            [(GPUImageFilterGroup *)filter setInitialFilters:[NSArray arrayWithObject:tone]];
            [(GPUImageFilterGroup *)filter setTerminalFilter:saturation];
            break;
        }
            
        case FilterTypeVintage:
        {
            filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageToneCurveFilter *tone = [[GPUImageToneCurveFilter alloc] initWithACV:@"Vintage"];
            GPUImageVignetteFilter *vintage = [[GPUImageVignetteFilter alloc] init];
            
            [(GPUImageFilterGroup *)filter addFilter:vintage];
            [tone addTarget:vintage];
            
            [(GPUImageFilterGroup *)filter setInitialFilters:[NSArray arrayWithObject:tone]];
            [(GPUImageFilterGroup *)filter setTerminalFilter:vintage];
            break;
        }
            
        case FilterType1Q84:
        {
            filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageToneCurveFilter *tone = [[GPUImageToneCurveFilter alloc] initWithACV:@"1Q84"];
            GPUImageSaturationFilter *saturation = [[GPUImageSaturationFilter alloc] init];
            
            [(GPUImageFilterGroup *)filter addFilter:saturation];
            [tone addTarget:saturation];
            
            [(GPUImageFilterGroup *)filter setInitialFilters:[NSArray arrayWithObject:tone]];
            [(GPUImageFilterGroup *)filter setTerminalFilter:saturation];
            break;
        }
            
        case FilterTypeBW:
        {
            filter = [[GPUImageFilterGroup alloc] init];
            
            // Tone Curve ;
            GPUImageToneCurveFilter *tone = [[GPUImageToneCurveFilter alloc] initWithACV:@"B&W"];
            GPUImageGrayscaleFilter *gray = [[GPUImageGrayscaleFilter alloc] init];
            
            [(GPUImageFilterGroup *)filter addFilter:gray];
            [tone addTarget:gray];
            
            [(GPUImageFilterGroup *)filter setInitialFilters:[NSArray arrayWithObject:tone]];
            [(GPUImageFilterGroup *)filter setTerminalFilter:gray];
            break;
        }
            
        default:
        {
            filter = [[GPUImageGammaFilter alloc] init];
            [AppDelegate sharedDelegate].bFiltered = NO;
            break;
        }
    }
}

- (void)removeAllTargets;
{
    [camera removeAllTargets];
    [cropFilter removeAllTargets];
	[filter removeAllTargets];
}

- (void)applyFilter
{
    [camera addTarget:cropFilter];
    [cropFilter addTarget:filter];
    [filter addTarget:imageView];
}

- (void)onTapGesture:(UITapGestureRecognizer *)tapGesture
{
    switch (tapGesture.state) {
        case UIGestureRecognizerStateRecognized:
        {
            if (!applied) {
                if (btnForFocus.selected) {
                    CGPoint point = [tapGesture locationInView:imageView];
                    
                    imgForFocus.center = point;
                    imgForFocus.transform = CGAffineTransformMakeScale(2.0, 2.0);
                    
                    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
                        imgForFocus.alpha = 1.0f;
                        imgForFocus.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                    } completion:^(BOOL finished) {
                        [UIView animateWithDuration:0.5f delay:0.5f options:UIViewAnimationOptionAllowUserInteraction animations:^{
                            imgForFocus.alpha = 0.0f;
                        } completion:^(BOOL finished) {
                            
                        }];
                    }];
                    
                    [self focusAtPoint:point];
                }
            } else {
                if (!playing && !playingSegment) {
                    [self play];
                } else {
                    [self stop];
                }
            }
            break;
        }
            
        default:
            break;
    }
}
- (void)onLongPressGesture:(UILongPressGestureRecognizer *)longGesture
{
    switch (longGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            if (!applied) {
//                if (btnForFocus.selected) {
//                    CGPoint point = [longGesture locationInView:imageView];
//                    
//                    imgForFocus.center = point;
//                    imgForFocus.transform = CGAffineTransformMakeScale(2.0, 2.0);
//                    
//                    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
//                        imgForFocus.alpha = 1.0f;
//                        imgForFocus.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
//                    } completion:^(BOOL finished) {
//                        
//                    }];
//                    
//                    [self focusAtPoint:point];
//                } else {
                    [self startRecording];
                btnForApply.enabled = NO;
                btnForCut.enabled = NO;
//                }
            }
            break;
        }
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            if (!applied) {
//                if (btnForFocus.selected) {
//                    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
//                        imgForFocus.alpha = 0.0f;
//                        imgForFocus.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
//                    } completion:^(BOOL finished) {
//                        //btnForFocus.selected = NO;
//                    }];
//                } else {
                    [self stopRecording];
                btnForApply.enabled = YES;
                btnForCut.enabled = YES;
//                }
            }
            break;
        }
            
        default:
            break;
    }
}

- (void)focusAtPoint:(CGPoint)point
{
    CGPoint location = point;
    CGPoint interest = CGPointZero;
    CGSize frameSize = [imageView frame].size;
    
    // Device;
    if ([camera cameraPosition] == AVCaptureDevicePositionFront) {
        location.x = frameSize.width - location.x;
    }
    
    interest = CGPointMake(location.y / frameSize.height, 1.f - (location.x / frameSize.width));
    
    if ([camera.inputCamera lockForConfiguration:nil]) {
        if ([camera.inputCamera isFocusPointOfInterestSupported] && [camera.inputCamera isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [camera.inputCamera setFocusPointOfInterest:interest];
            [camera.inputCamera setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        
        if ([camera.inputCamera isExposurePointOfInterestSupported] && [camera.inputCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            [camera.inputCamera setExposurePointOfInterest:interest];
            [camera.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        
        [camera.inputCamera unlockForConfiguration];
    }
}

- (void)startCamera
{
    [camera addTarget:cropFilter];
    [cropFilter addTarget:filter];
    [filter addTarget:imageView];
    [camera startCameraCapture];
}

- (void)stopCamera
{
    [camera stopCameraCapture];
}

- (void)startRecording
{
    if ([self checkIfRecLimitReached]) {
        return;
    }
    IMVideoSegment *segment = [[IMVideoSegment alloc] init];
    NSInteger recordingTime = time(NULL);
    
    [segments addObject:segment];
    
    recording = YES;
    progress = 0;
    
    // Video;
    NSString *videoPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"tmp/movie_%ld.mp4", (long)recordingTime]];
    unlink([videoPath UTF8String]);
    segment.videoURL = [NSURL fileURLWithPath:videoPath];
    
    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:segment.videoURL size:CGSizeMake(640.0f, 640.0f)];
    movieWriter.shouldPassthroughAudio = YES;
    movieWriter.encodingLiveVideo = YES;
    [filter addTarget:movieWriter];
    movieWriter.delegate = self;
    [movieWriter startRecording];
    
    // Audio;
    NSString *audioPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"tmp/audio_%ld.caf", (long)recordingTime]];
    segment.audioURL = [NSURL fileURLWithPath:audioPath];
    
    segment.audio = !btnForMicrophone.selected;
    
    recorder = [[AVAudioRecorder alloc] initWithURL:segment.audioURL settings:recordSetting error:nil];
    [recorder prepareToRecord];
    [recorder record];
    
    // UI;
    [viewForProgress addShot];
    [viewForProgress setIsRecording:YES];
    [viewForProgress highightLastShotForRemoval:NO];
    [btnForCut setSelected:NO];

    [self performSelector:@selector(updateRecording) withObject:nil afterDelay:0.1f];
}
#pragma mark 
- (void)movieRecordingFailedWithError:(NSError*)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopRecording];
    });
}

- (void)stopRecording
{
    recording = NO;
    
    // UI;
    [viewForProgress setIsRecording:NO];
    [viewForProgress finishShot];
    
    // Video;
    [movieWriter finishRecording];
    [filter removeTarget:movieWriter];
    
    // Audio;
    [recorder stop];
    
    if ([segments count]) {
        btnForApply.hidden = NO;
        btnForCut.enabled = YES;
    }
}

- (void)updateRecording
{
    progress += 0.1;
    [viewForProgress updateShot:progress];
    if (progress - (int)progress < 0.11) {
        if ([self checkIfRecLimitReached]) {
            return;
        }
    }
//    if (progress <= 30.0f) {
        if (recording) {
            [self performSelector:@selector(updateRecording) withObject:nil afterDelay:0.1f];
        }
//    }
}

- (void)deleteRecording
{
    IMVideoSegment *segment = [segments lastObject];
    
    unlink([segment.videoURL.absoluteString UTF8String]);
    unlink([segment.videoURL.absoluteString UTF8String]);
    
    [segments removeLastObject];
    
    if (![segments count]) {
        btnForApply.hidden = YES;
        btnForCut.enabled = NO;
    }
}

- (void)play
{
    [viewForVideo addGestureRecognizer:tapGestureOne];
    playing = YES;
    current = 0;
    
    // Segment;
    [self playSegment];
    
    // Audio;
    if (audio && !isCreate) {
        CGFloat sec = viewForScroll.contentOffset.x * ( totalDuration.value / totalDuration.timescale ) / 320.0f;
        
        // Audio;
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:audio error:nil];
        [player setCurrentTime:sec];
        [player setVolume:1.0f];
        [player prepareToPlay];
        [player play];
        
        // Animation;
        CGRect frame = imgForTicker.frame;
        
        frame.origin.x = 0;
        imgForTicker.frame = frame;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:totalDuration.value / totalDuration.timescale];
        frame.origin.x = 320.0f;
        imgForTicker.frame = frame;
        [UIView commitAnimations];
    }
}

- (void)stop
{
    playing = NO;
    
    // Video;
    [movie cancelProcessing];
}

- (void)playSegment
{
    IMVideoSegment *segment = [segments objectAtIndex:current];
    
    if (!playingSegment) {
        playingSegment = YES;
        
        // Video;
        movie = [[GPUImageMovie alloc] initWithURL:segment.videoURL];
        movie.delegate = self;
        movie.playAtActualSpeed = YES;
        
        [movie addTarget:filter];
        [filter addTarget:imageView];
        
        [movie startProcessing];
        
        // Audio;
        if (!audio && segment.audio && !isCreate) {
            player = [[AVAudioPlayer alloc] initWithContentsOfURL:segment.audioURL error:nil];
            [player prepareToPlay];
            [player play];
        }
    }
}

- (void)didCompletePlayingMovie
{
    dispatch_async(dispatch_get_main_queue(), ^{
        playingSegment = NO;
        
        if (playing && (current < [segments count ] - 1 )) {
            current ++;
            
            // Segment;
            [self playSegment];
        } else {
            playing = NO;
            
            // Audio;
            [player stop];
            
            // Animation;
            [imgForTicker.layer removeAllAnimations];
        }
    });
}

- (void)mergeVideos
{
    CMTime duration = kCMTimeZero;
    CMTime temp = kCMTimeZero;
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVURLAsset *videoAsset;
    AVAssetExportSession *exportSession;
    for (IMVideoSegment *segment in segments) {
        // Video;
        {
            videoAsset = [[AVURLAsset alloc] initWithURL:segment.videoURL options:nil];
            AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
            
            [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:videoAssetTrack atTime:kCMTimeInvalid error:nil];
            
            temp = videoAsset.duration;
        }

        // Audio;
        if (!audio) {
            if (segment.audio) {
                AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:segment.audioURL options:nil];
                AVAssetTrack *audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
                
				CMTime temp = audioAsset.duration;
				if (temp.value) {
					[audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, temp) ofTrack:audioAssetTrack atTime:duration error:nil];
				}
            }
        }
        
        // Duration;
        duration = CMTimeAdd(duration, temp);
    }
    
    // Audio;
    if (audio) {
        CGFloat sec = viewForScroll.contentOffset.x * (totalDuration.value / totalDuration.timescale) / 320.0f;
        
        AVAsset *audioAsset = [[AVURLAsset alloc] initWithURL:audio options:nil];
        AVAssetTrack *audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        
        CMTime start = CMTimeMake(sec * audioAsset.duration.timescale, audioAsset.duration.timescale);
        
        [audioTrack insertTimeRange:CMTimeRangeMake(start, duration) ofTrack:audioAssetTrack atTime:kCMTimeInvalid error:nil];
    }
    
    // Exporting;
    NSString *filename = [NSString stringWithFormat:@"tmp/movie%ld.mp4", time(nil)];
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:filename];
    unlink([path UTF8String]);
    NSURL *url = [NSURL fileURLWithPath:path];

    if ([segments count] == 1 && !((IMVideoSegment *)[segments objectAtIndex:0]).audio) {
        exportSession = [[AVAssetExportSession alloc] initWithAsset:videoAsset presetName:AVAssetExportPresetMediumQuality];
    }else{
        exportSession = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetMediumQuality];
    }
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.outputURL = url;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch (exportSession.status) {
            case AVAssetExportSessionStatusFailed:
            case AVAssetExportSessionStatusCancelled:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self failedMerge];
                });
                break;
            }
                
            default:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self completedMerge:url];
                });
                break;
            }
        }
    }];
}

- (void)onBtnBack:(id)sender
{
	if (playing) {
		[self stop];
	}
    
    if (applied) {
        if (isSelectedCutBtn) {
            [viewForProgress highightLastShotForRemoval:YES];
        }
        applied = NO;
        lblWayForRecording.hidden = NO;
        [camera addTarget:cropFilter];
        [cropFilter addTarget:filter];
        [filter addTarget:imageView];
        [camera startCameraCapture];
        
        [viewForProgress setNormal:NO];
        
        audio = nil;
        btnForCut.hidden = NO;
        viewForTool.hidden = NO;
        viewForFilter.hidden = NO;
        viewForAudio.hidden = YES;
        btnForMusic.selected = NO;
        viewForMusic.hidden = YES;
        
        if (!btnForGrid.selected) {
            imgForGrid.hidden = YES;
        } else {
            imgForGrid.hidden = NO;
        }
        if ([camera.inputCamera hasFlash] && [camera.inputCamera hasTorch]) {
            if ([camera.inputCamera lockForConfiguration:nil]) {
                camera.inputCamera.torchMode = btnForFlash.selected ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
                [camera.inputCamera unlockForConfiguration];
            }
        } else {
            
        }
    } else {
        [camera stopCameraCapture];
        [camera removeAllTargets];
        [cropFilter removeAllTargets];
        [filter removeAllTargets];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)onBtnApply:(id)sender
{
    
    if (applied == NO) {
        if (isSelectedCutBtn) {
            [viewForProgress highightLastShotForRemoval:NO];
        }
        [self stopRecording];
        
        [camera stopCameraCapture];
		[camera removeAllTargets];
		[cropFilter removeAllTargets];
		[filter removeAllTargets];
		
		filter = [[GPUImageGammaFilter alloc] init];

        [viewForProgress setNormal:YES];
        
        btnForCut.hidden = YES;
        viewForTool.hidden = YES;
        viewForFilter.hidden = YES;
        imgForGrid.hidden = YES;
        viewForMusic.hidden = NO;
        
        totalDuration = kCMTimeZero;

        for (IMVideoSegment *segment in segments) {
            AVAsset *asset = [[AVURLAsset alloc] initWithURL:segment.videoURL options:nil];
            CMTime temp = asset.duration;
            totalDuration = CMTimeAdd(totalDuration, temp);
        }
        
        applied = YES;
        lblWayForRecording.hidden = YES;
        isCreate = YES;
        [self play];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self stop];
            isCreate = NO;
        });
        
    } else {
//      viewForTool.hidden = NO;
//      viewForMusic.hidden = YES;
        [self stop];
        [self mergeVideos];
        btnForApply.enabled = NO;
    }
}

- (IBAction)onBtnCut:(id)sender
{
    if (!btnForCut.selected) {
        [viewForProgress highightLastShotForRemoval:YES];
        isSelectedCutBtn = YES;
    } else {
        [viewForProgress removeLastShot];
        [self deleteRecording];
        isSelectedCutBtn = NO;
    }
    
    btnForCut.selected = !btnForCut.selected;
}

- (IBAction)onBtnGrid:(id)sender
{
    btnForGrid.selected = !btnForGrid.selected;
    
    if (!btnForGrid.selected) {
        imgForGrid.hidden = YES;
    } else {
        imgForGrid.hidden = NO;
    }
}

- (IBAction)onBtnFlash:(id)sender
{
    if ([camera.inputCamera hasFlash] && [camera.inputCamera hasTorch]) {
        if ([camera.inputCamera lockForConfiguration:nil]) {
            btnForFlash.selected = !btnForFlash.selected;
            camera.inputCamera.torchMode = btnForFlash.selected ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
            [camera.inputCamera unlockForConfiguration];
        }
    } else {
        
    }
}

- (IBAction)onBtnFlip:(id)sender
{
    btnForFlip.selected = !btnForFlip.selected;
    btnForFlip.enabled = NO;
    [camera rotateCamera];
    btnForFlip.enabled = YES;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        if (!camera) {
            return;
        }
        
        if ([camera.inputCamera hasFlash] && [camera.inputCamera hasTorch]) {
            btnForFlash.enabled = YES;
            if (btnForFlash.selected == YES){
                if ([camera.inputCamera lockForConfiguration:nil]) {
                    camera.inputCamera.torchMode = btnForFlash.selected ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
                    [camera.inputCamera unlockForConfiguration];
                }
            }
        } else {
            btnForFlash.enabled = NO;
        }
    }
}

- (IBAction)onBtnMicrophone:(id)sender
{
    btnForMicrophone.selected = !btnForMicrophone.selected;
}

- (IBAction)onBtnFocus:(id)sender
{
    btnForFocus.selected = !btnForFocus.selected;
}

- (IBAction)onBtnGhost:(id)sender
{
    btnForGhost.selected = !btnForGhost.selected;
    imgForGhost.hidden = !btnForGhost.selected;
    
    if (btnForGhost.selected) {
        btnForGhost.enabled = NO;
        
        [camera capturePhotoAsImageProcessedUpToFilter:cropFilter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
            runOnMainQueueWithoutDeadlocking(^{
                btnForGhost.enabled = YES;
                imgForGhost.image = processedImage;
            });
        }];
    }
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    MPMediaItem *item = [[mediaItemCollection items] objectAtIndex:0];
    NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
	
    [mediaPicker dismissViewControllerAnimated:YES completion:^{
        if (url) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [hud setLabelText:@"Loading Music..."];
            
            audio = url;
            
            AVAsset * asset = [[AVURLAsset alloc] initWithURL:audio options:nil];
            CMTime duration = asset.duration;
            CGFloat sec = duration.value / duration.timescale;
            CGFloat scale = sec / ( totalDuration.value / totalDuration.timescale ) ;
            
            CGRect frame = viewForAudio.bounds;
            frame.size.width = scale * 320.0f;

            viewForAudio.hidden = NO;

            viewForScroll.contentSize = frame.size;
            viewForScroll.contentOffset = CGPointZero;
            viewForScroll.decelerationRate = 0.0f;
            
            audioFile = [EZAudioFile audioFileWithURL:audio];
            
            viewForWave.frame = frame;
            viewForWave.plotType = EZPlotTypeBuffer;
            viewForWave.shouldFill = NO;
            viewForWave.shouldMirror = YES;
            [audioFile getWaveformDataWithCompletionBlock:^(float *waveformData, UInt32 length) {
                [viewForWave updateBuffer:waveformData withBufferSize:length];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }];
            
            btnForMusic.selected = YES;
        }
        
    }];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [mediaPicker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)completedMerge:(NSURL *)url
{
    IMVideoPickerController *viewController = (IMVideoPickerController *)self.navigationController;
    
    if ([viewController.pickerDelegate respondsToSelector:@selector(videoPickerController:didSelectVideo:)]) {
        [viewController.pickerDelegate videoPickerController:viewController didSelectVideo:url];
    }
}

- (void)failedMerge
{
    IMVideoPickerController *viewController = (IMVideoPickerController *)self.navigationController;
    
    if ([viewController.pickerDelegate respondsToSelector:@selector(videoPickerControllerDidCancel:)]) {
        [viewController.pickerDelegate videoPickerControllerDidCancel:viewController];
    }
}

- (IBAction)onBtnMusic:(id)sender
{
    if (playing) {
        [self stop];
    }
    
    if (!audio) {
        MPMediaPickerController *viewController = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
        
        viewController.delegate = self;
        viewController.prompt = NSLocalizedString (@"Add songs to play", "Prompt in media item picker");
        viewController.showsCloudItems = NO;
		
        [self presentViewController:viewController animated:TRUE completion:NULL];
    } else {
        audio = nil;
        viewForAudio.hidden = YES;
        btnForMusic.selected = NO;
    }
}

- (CMTime)getTotalDuration {
    CMTime total;
    total = kCMTimeZero;
    for (IMVideoSegment *segment in segments) {
        AVAsset *asset = [[AVURLAsset alloc] initWithURL:segment.videoURL options:nil];
        CMTime temp = asset.duration;
        total = CMTimeAdd(total, temp);
    }
    return total;
}

- (BOOL)checkIfRecLimitReached {
    CMTime total = [self getTotalDuration];
    NSLog(@"%f", CMTimeGetSeconds(total));
    if (CMTimeGetSeconds(total) > 30) {
        [CommonMethods showAlertUsingTitle:@"Oops!" andMessage:MESSAGE_RECLIMIT_REACHED];
        //        [self stopRecording];
        return YES;
    }
    return NO;
}
- (void)pauseVideoWhenSleepMode{
    if (!playing && !playingSegment) {
        
    } else {
        [self stop];
    }
}

- (void)movePushNotificationChatViewController:(NSNumber *)boardID isDeletedFriend:(BOOL)isDetetedFriend users:(NSMutableArray *)lstUsers isDirectory:(NSDictionary *)directoryInfo{
    
    YYYChatViewController *viewcontroller = [[YYYChatViewController alloc] initWithNibName:@"YYYChatViewController" bundle:nil];
    viewcontroller.isDeletedFriend = isDetetedFriend;
    viewcontroller.boardid = boardID;
    viewcontroller.lstUsers = lstUsers;
    BOOL isMembersSameDirectory = NO;
    if ([[directoryInfo objectForKey:@"is_group"] boolValue]) {//directory chat for members
        viewcontroller.isDeletedFriend = NO;
        viewcontroller.groupName = [directoryInfo objectForKey:@"board_name"];
        viewcontroller.isMemberForDiectory = YES;
        viewcontroller.isDirectory = YES;
    }else{
        viewcontroller.lstUsers = lstUsers;
        
        viewcontroller.isDeletedFriend = YES;
        for (NSDictionary *memberDic in directoryInfo[@"members"]) {
            if ([memberDic[@"in_same_directory"] boolValue]) {
                isMembersSameDirectory = YES;
            }
        }
        if (isMembersSameDirectory) {
            viewcontroller.isDeletedFriend = NO;
            viewcontroller.groupName = [directoryInfo objectForKey:@"board_name"];
            viewcontroller.isMemberForDiectory = YES;
            viewcontroller.isDirectory = NO;
        }
    }
    [self.navigationController  pushViewController:viewcontroller animated:YES];
}
- (void)movePushNotificationConferenceViewController:(NSDictionary *)dic{
    VideoVoiceConferenceViewController *vc = [[VideoVoiceConferenceViewController alloc] initWithNibName:@"VideoVoiceConferenceViewController" bundle:nil];
    vc.infoCalling = dic;
    vc.boardId = [dic objectForKey:@"board_id"];
    if ([[dic objectForKey:@"callType"] integerValue] == 1) {
        vc.conferenceType = 1;
    }else{
        vc.conferenceType = 2;
    }
    vc.conferenceName = [dic objectForKey:@"uname"];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
