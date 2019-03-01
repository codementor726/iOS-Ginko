//
//  EntityChatWallViewController.h
//  GINKO
//
//  Created by mobidev on 7/31/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EntityChatCell.h"
#import "MNMBottomPullToRefreshManager.h"

@interface EntityChatWallViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, EntityChatCellDelegate, UIScrollViewDelegate, MNMBottomPullToRefreshManagerClient>
{
    MNMBottomPullToRefreshManager *pullToRefreshManager_;
    NSUInteger reloads_;
}
@property (nonatomic, retain) IBOutlet UIView *navView;

@property (nonatomic, assign) IBOutlet UITableView *tblWall;
@property (nonatomic, assign) IBOutlet UILabel *lblTitle;

@property (nonatomic, retain) NSString *entityID;
@property (nonatomic, retain) NSString *entityName;
@property (nonatomic, retain) NSString *entityImageURL;
@property BOOL isFromProfile;//should prevent going to profile again from tapping avatar

@property (nonatomic, retain) IBOutlet UILabel *lblComment;

- (IBAction)onBack:(id)sender;

@end
