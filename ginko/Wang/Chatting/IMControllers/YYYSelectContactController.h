//
//  YYYViewController.h
//  InstantMessenger
//
//  Created by Wang MeiHua on 2/27/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYYChatViewController.h"
//#import "YYYViewController.h"

@interface YYYSelectContactController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
{
	IBOutlet UITableView		*tbl_chat;
	IBOutlet UISearchBar		*srb_chat;
	IBOutlet UIButton			*btSelectAll;
	IBOutlet UIView				*vwBottom;
	IBOutlet UIButton			*btAccept;
	
	IBOutlet UIButton			*btChatContact;
	IBOutlet UIButton			*btAllContact;
	IBOutlet UILabel			*lblSelectAll;
	IBOutlet UILabel			*lblTitle;
	
	NSMutableArray *lst_searched;
	NSMutableArray *lst_user;
	NSMutableArray *lst_selected;
    
    NSMutableArray *lst_chatContactSelected;
}
-(IBAction)btAcceptClick:(id)sender;
-(IBAction)btChatClick:(id)sender;
-(IBAction)btContactClick:(id)sender;
-(IBAction)btSelectAllClick:(id)sender;
-(IBAction)btBackClick:(id)sender;

@property (nonatomic,retain) UIViewController *viewcontroller;
@property (nonatomic,retain) NSNumber *boardid;
@property (nonatomic,retain) NSMutableArray *lstCurrentUserIds;
@property NSInteger conferenceType;
@property BOOL bContact;
@property BOOL isReturnFromConference;

- (void)movePushNotificationConferenceViewController:(NSDictionary *)dic;
@end
