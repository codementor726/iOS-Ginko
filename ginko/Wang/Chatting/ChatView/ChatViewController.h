//
//  ChatViewController.h
//  Ginko
//
//  Created by Mobile on 4/6/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "YYYCustomInboxCell.h"
#import <MediaPlayer/MediaPlayer.h>

#import "EntityChatCell.h"

@interface ChatViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,CustomInboxDelegate,UIAlertViewDelegate, EntityChatCellDelegate>
{
	IBOutlet UITableView *tbl_chat;
	IBOutlet UISearchBar *srb_chat;
	
	NSMutableArray *lst_searched;
	NSMutableArray *lst_board;
	
	UIBarButtonItem *btHome;
	UIBarButtonItem *btChat;
	UIBarButtonItem *btClear;
	UIBarButtonItem *btClose;
	
	IBOutlet UIButton *btEdit;
	IBOutlet UIView *vwEmpty;
	
	NSMutableArray *lst_delete;
	
	IBOutlet UIView *vwDelete;
	
	//Temp
	UIView		*vwLogin;
	UITextField *txtUsername;
	UITextField *txtPassword;
    
    //wall
    UIBarButtonItem *btEmpty;
    IBOutlet UILabel *lblDescription;
    IBOutlet UIButton *btnChatHistory;
    IBOutlet UIButton *btnWall;
    
    UIView *vwPhoto;
	UIImageView *imvPhoto;
}
-(IBAction)btEditClick:(id)sender;
-(IBAction)btTrachClick:(id)sender;

@property BOOL bGoToChat;
@property (nonatomic,retain) NSString *strIds;
@property (nonatomic,retain) NSNumber *boardid;
@property (nonatomic,retain) NSMutableArray *lstBoardUser;

@property (nonatomic, retain) MPMoviePlayerViewController *playerVC;

//wall
@property (nonatomic, readwrite) BOOL isWall;

- (IBAction)onChatHistory:(id)sender;
- (IBAction)onWall:(id)sender;
- (void)getChatBoards;
- (void)newMessage : (NSNotification*) _notification;

- (void)moveWallHistory;
@end
