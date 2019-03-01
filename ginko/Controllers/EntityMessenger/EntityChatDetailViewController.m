//
//  EntityChatDetailViewController.m
//  GINKO
//
//  Created by mobidev on 7/25/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import "EntityChatDetailViewController.h"
#import "UIImageView+AFNetworking.h"

@interface EntityChatDetailViewController ()

@end

@implementation EntityChatDetailViewController
@synthesize txtMessage, imgEntity, lblTitle, lblEntityName, lblSentTime;
@synthesize strMessage, strEntityName, strSentTime;
@synthesize strProfileImageURL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [txtMessage addGestureRecognizer:pinchGesture];
    
    [txtMessage setEditable:NO];
    [txtMessage setDataDetectorTypes:UIDataDetectorTypeLink];
}

-(void)handlePinch:(UIPinchGestureRecognizer *)recognizer
{
    CGFloat scale = recognizer.scale;
    CGFloat currentFontSize = txtMessage.font.pointSize;
    if (scale > 1) {
        if (currentFontSize <= 24) {
            currentFontSize += 0.4;
        }
    } else if (scale <1) {
        if (currentFontSize >= 8) {
            currentFontSize -= 0.4;
        }
    }
//    CGFloat newFontSize = currentFontSize * scale; //or anything you wish
    txtMessage.font = [txtMessage.font fontWithSize:currentFontSize];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!strProfileImageURL) {
        [imgEntity setImage:[UIImage imageNamed:@"entity-dummy"]];
    } else {
        [imgEntity setImageWithURL:[NSURL URLWithString:strProfileImageURL] placeholderImage:[UIImage imageNamed:@"entity-dummy"]];
    }
    [txtMessage setText:strMessage];

    lblTitle.text = strEntityName;
    lblEntityName.text = strEntityName;
//    NSDate *date = [CommonMethods str2date:strSentTime withFormat:@"yyyy-MM-dd HH:mm:ss"];
    lblSentTime.text = [CommonMethods date2localtimestr:strSentTime];
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear: animated];
    
    [AppDelegate sharedDelegate].isWallScreen = NO;
}
- (void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [AppDelegate sharedDelegate].isWallScreen = YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (IBAction)onClose:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
