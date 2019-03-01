//
//  EntityChatDetailViewController.h
//  GINKO
//
//  Created by mobidev on 7/25/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EntityChatDetailViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIImageView *imgEntity;
@property (nonatomic, retain) IBOutlet UITextView *txtMessage;
@property (nonatomic, retain) IBOutlet UILabel *lblTitle;
@property (nonatomic, retain) IBOutlet UILabel *lblEntityName;
@property (nonatomic, retain) IBOutlet UILabel *lblSentTime;

@property (nonatomic, retain) NSString *strMessage;
@property (nonatomic, retain) NSString *strEntityName;
@property (nonatomic, retain) NSString *strProfileImageURL;
@property (nonatomic, retain) NSString *strSentTime;

- (IBAction)onClose:(id)sender;

@end
