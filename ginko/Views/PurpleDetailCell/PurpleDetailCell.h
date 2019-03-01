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
// ContactCell Class;

@protocol PurpleDetailCellDelegate

@optional;
- (void)viewChat:(NSString*)sessionId contactId:(NSString*)contactId;
- (void)sendMail:(NSString *)_email;
@end

@interface PurpleDetailCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *imgIcon;
@property (nonatomic, retain) IBOutlet UILabel * lblContent;

@property (nonatomic, retain) id<PurpleDetailCellDelegate> delegate;

@property (nonatomic, retain) NSString *type;

- (void)setIcons;

@end
