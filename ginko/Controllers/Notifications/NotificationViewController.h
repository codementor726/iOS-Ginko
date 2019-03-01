//
//  NotificationViewController.h
//  GINKO
//
//  Created by Forever on 6/3/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationViewController : UIViewController
{
    IBOutlet UIView *navView;
    IBOutlet UISwitch *switchExchange;
    IBOutlet UISwitch *switchChat;
    IBOutlet UISwitch *switchSprout;
    IBOutlet UISwitch *switchProfileUpdates;
    IBOutlet UISwitch *switchEntity;

}

- (IBAction)onBack:(id)sender;
- (IBAction)onValueChanged:(id)sender;

@end
