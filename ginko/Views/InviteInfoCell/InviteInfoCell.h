//
//  NotExchangedInfoCell.h
//  Ginko
//
//  Created by Qi Song on 29/3/14.
//  Copyright (c) 2014 Qi Song. All rights reserved.
//
// --- Headers ---;
#import <UIKit/UIKit.h>

// --- Defines ---;
// NotExchangedInfoCell Class;

@protocol InviteInfoCellDelegate

@optional;
- (void)shareInfo:(NSDictionary*)contactInfo;

@end

@interface InviteInfoCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView * profileImageView;
@property (nonatomic, retain) IBOutlet UILabel * username;
@property (nonatomic, retain) IBOutlet UILabel * lastDate;
@property (nonatomic, retain) IBOutlet UIButton * shareBut;
@property (nonatomic, retain) NSDictionary * contactInfo;

@property (nonatomic, retain) id<InviteInfoCellDelegate> delegate;

- (IBAction)onShareInfo:(id)sender;

- (void)setPhoto:(NSString *)photo;

@end
