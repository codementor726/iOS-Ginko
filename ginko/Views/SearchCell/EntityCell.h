//
//  EntityCell.h
//  GINKO
//
//  Created by mobidev on 7/23/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EntityCellDelegate

@end

@interface EntityCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView * imgProfile;
@property (nonatomic, retain) IBOutlet UILabel *lblName;
@property (nonatomic, retain) IBOutlet UIImageView *imgStatus;
@property (nonatomic, retain) IBOutlet UILabel *lblFollowers;

@property (nonatomic, retain) NSDictionary *curDict;
@property (nonatomic, readwrite) BOOL isFollowing;

@property (nonatomic, retain) id<EntityCellDelegate> delegate;

+ (EntityCell *)sharedCell;

@end
