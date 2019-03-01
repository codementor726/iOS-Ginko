//
//  ContactCell.h
//  Ginko
//
//  Created by Qi Song on 29/3/14.
//  Copyright (c) 2014 Qi Song. All rights reserved.
//
// --- Headers ---;
#import <UIKit/UIKit.h>

// --- Defines ---;
// SearchCell Class;

@protocol LoginSettingCellDelegate

@end

@interface LoginSettingCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel * lblEmail;
@property (nonatomic, retain) IBOutlet UILabel * lblStatus;
@property (nonatomic, retain) IBOutlet UIButton * btnCheck;

@property (nonatomic, retain) NSString * sessionId;
@property (nonatomic, retain) NSString * contactId;

@property (nonatomic, retain) id<LoginSettingCellDelegate> delegate;

- (void)setPhoto:(NSString *)photo;

@end
