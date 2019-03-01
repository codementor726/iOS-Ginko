//
//  TitleEntityCell.h
//  GINKO
//
//  Created by mobidev on 7/25/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TitleEntityCellDelegate

@optional;
- (void)didWall:(NSDictionary *)entityDict;
- (void)didPhone:(NSDictionary *)entityDict;
@end

@interface TitleEntityCell : UITableViewCell <UIActionSheetDelegate>

@property (nonatomic, retain) IBOutlet UIImageView * imgProfile;
@property (nonatomic, retain) IBOutlet UILabel *lblName;

@property (nonatomic, retain) NSDictionary *curDict;

@property (nonatomic, retain) id<TitleEntityCellDelegate> delegate;

+ (TitleEntityCell *)sharedCell;

- (IBAction)onPhone:(id)sender;
- (IBAction)onWall:(id)sender;

@end
