//
//  MobileVerificationViewController.h
//  ginko
//
//  Created by STAR on 1/1/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MobileVerificationViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *countryCodeLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UIButton *countryButton;
@property (assign, nonatomic) BOOL isFromContacts;
- (IBAction)selectCountry:(id)sender;
@end
