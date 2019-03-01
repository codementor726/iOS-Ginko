//
//  GreyAddNotesController.h
//  GINKO
//
//  Created by mobidev on 5/24/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CISyncDetailController.h" //importer class
#import "GreyDetailController.h"
#import "PreviewProfileViewController.h"
#import "LPlaceholderTextView.h"

@interface GreyAddNotesController : UIViewController <UITextViewDelegate>

@property (nonatomic, assign) IBOutlet UIButton *btnDone;
@property (nonatomic, assign) IBOutlet LPlaceholderTextView *txtNotes;

@property (nonatomic, retain) UIViewController *parentController; //importer class
@property (nonatomic, strong) NSString *strNotes;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomSpace;

- (IBAction)onDone:(id)sender;
- (IBAction)onCancl:(id)sender;

@end
