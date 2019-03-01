//
//  SelectUserForConferenceViewController.h
//  ginko
//
//  Created by stepanekdavid on 6/7/17.
//  Copyright © 2017 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectUserForConferenceViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
{
    IBOutlet UITableView		*tbl_chat;
    IBOutlet UISearchBar		*srb_chat;
    IBOutlet UIButton			*btAccept;
    
    NSMutableArray *lst_searched;
    NSMutableArray *lst_user;
    NSMutableArray *lst_selected;
    NSMutableArray *arraySelectedUsers;
    __weak IBOutlet UILabel *lblSelectUp;
}

-(IBAction)btAcceptClick:(id)sender;
-(IBAction)btBackClick:(id)sender;

@property (nonatomic,retain) UIViewController *viewcontroller;
@property (nonatomic, retain) NSMutableArray *arrayUsers;
@property BOOL isReturnFromGruopView;
@property BOOL isDirectory;
@property BOOL isReturnFromMenu;

@property BOOL isReturnFromConference;
@property BOOL isReturnFromGroupChat;
@property NSInteger conferenceType;
@property (nonatomic,retain) NSNumber *boardid;


- (void)movePushNotificationConferenceViewController:(NSDictionary *)dic;
@end
