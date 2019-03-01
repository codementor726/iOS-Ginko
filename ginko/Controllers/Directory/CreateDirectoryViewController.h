//
//  CreateDirectoryViewController.h
//  ginko
//
//  Created by stepanekdavid on 12/14/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateDirectoryViewController : UIViewController{

    __weak IBOutlet UITextField *txtDirectoryName;
    __weak IBOutlet UILabel *lblErrorForDuplicate;
}
- (void)movePushNotificationViewController;
- (void)movePushNotificationConferenceViewController:(NSDictionary *)dic;
@end
