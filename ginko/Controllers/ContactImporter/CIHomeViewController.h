//
//  CIHomeViewController.h
//  ContactImporter
//
//  Created by mobidev on 6/12/14.
//  Copyright (c) 2014 Ron. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CIHomeViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIView *navView;

@property (nonatomic, assign) IBOutlet UIButton *btnBack;
@property (nonatomic, assign) IBOutlet UIButton *btnSkip;
@property (nonatomic, assign) IBOutlet UIButton *btnFormer;
@property (nonatomic, assign) IBOutlet UIButton *btnImportHistory;


- (IBAction)onImportItem:(id)sender;
- (IBAction)onAddressBook:(id)sender;

- (IBAction)onFormer:(id)sender;
- (IBAction)onSkip:(id)sender;

- (IBAction)onBack:(id)sender;
- (IBAction)onImportHistory:(id)sender;

@end
