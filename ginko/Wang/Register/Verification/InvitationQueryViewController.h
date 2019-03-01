//
//  InvitationQueryViewController.h
//  ginko
//
//  Created by STAR on 1/4/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InvitationQueryViewController : UIViewController

@property (nonatomic, assign) BOOL isFromContacts;

- (IBAction)selectYes:(id)sender;
- (IBAction)selectNo:(id)sender;
@end
