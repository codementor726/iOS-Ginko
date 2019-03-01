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

@protocol NotExchangedInfoCellDelegate <NSObject>

@optional;
- (void)shareInfo:(NSDictionary*)contactInfo;

@end

@interface NotExchangedInfoCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView * profileImageView;
@property (nonatomic, retain) IBOutlet UILabel * username;
@property (nonatomic, retain) IBOutlet UILabel * lastDate;
@property (nonatomic, retain) IBOutlet UILabel * pingArea;
@property (nonatomic, retain) IBOutlet UIButton * shareBut;
@property (nonatomic, retain) NSDictionary * contactInfo;

@property (nonatomic, retain) id<NotExchangedInfoCellDelegate> delegate;

- (IBAction)onShareInfo:(id)sender;
- (void)setPingLocation:(CGFloat)pingLatitude pingLongitude:(CGFloat)pingLongitude;

- (void)setPhoto:(NSString *)photo;
- (void)populateCellWithContact:(SearchedContact*)contact;
@end
