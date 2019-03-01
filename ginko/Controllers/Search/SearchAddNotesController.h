//
//  GreyAddNotesController.h
//  GINKO
//
//  Created by mobidev on 5/24/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPlaceholderTextView.h"
#import "EntityViewController.h"
#import "MainEntityViewController.h"
@interface SearchAddNotesController : UIViewController <UITextViewDelegate>

@property (nonatomic, assign) IBOutlet UIButton *btnDone;
@property (nonatomic, assign) IBOutlet LPlaceholderTextView *txtNotes;

@property (nonatomic, retain) UIViewController *parentController;

@property (nonatomic, retain) NSString *strNotes;
@property (nonatomic, retain) NSString *entityID;
@property (nonatomic, retain) NSDictionary * contactInfo;
@property (nonatomic, assign) BOOL isMain;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomSpace;

- (IBAction)onDone:(id)sender;
- (IBAction)onCancl:(id)sender;

@end
