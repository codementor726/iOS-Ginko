//
//  CBImportHomeViewController.h
//  GINKO
//
//  Created by mobidev on 8/7/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CBImportHomeViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIView *navView;

@property (nonatomic, assign) IBOutlet UIButton *btnBack;
@property (nonatomic, assign) IBOutlet UIButton *btnSkip;
@property (nonatomic, assign) IBOutlet UIView *viewBottom;
@property (nonatomic, assign) IBOutlet UIView *viewDescription;

- (IBAction)onImportItem:(id)sender;
- (IBAction)onOther:(id)sender;

- (IBAction)onSkip:(id)sender;
- (IBAction)onBack:(id)sender;

@end
