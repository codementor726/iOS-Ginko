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

@protocol TileViewCellDelegate

@optional;
- (void)viewChat:(NSString*)sessionId contactId:(NSString*)contactId;
- (void)sendMail:(NSString *)_email;
- (void)didChat:(NSDictionary *)contactDict;
- (void)didEdit:(NSDictionary *)contactDict;
- (void)didCallVoice:(NSDictionary *)contactDict;
- (void)didCallVideo:(NSDictionary *)contactDict;
@end

@interface TileViewCell : UITableViewCell < UIActionSheetDelegate >

@property (nonatomic, retain) IBOutlet UIImageView * profileImageView;
@property (nonatomic, retain) IBOutlet UILabel * firstName;
@property (nonatomic, retain) IBOutlet UILabel * lastName;
@property (nonatomic, retain) IBOutlet UIButton * contactBut;
@property (nonatomic, retain) IBOutlet UIButton * phoneBut;
// Created by Zhun L.
@property (nonatomic, retain) IBOutlet UIView *backgroundView;
@property (nonatomic, retain) IBOutlet UIImageView * statusImageView;
@property (nonatomic, nonatomic) int type;
@property (nonatomic, retain) NSMutableArray *arrPhone;
@property (nonatomic, retain) NSMutableArray *arrEmail;
@property (nonatomic, retain) IBOutlet UIImageView *imgViewNew;
@property (nonatomic, retain) IBOutlet UIImageView *imgViewBg;
//------------------

@property (nonatomic, retain) NSString * sessionId;
@property (nonatomic, retain) NSString * contactId;
@property (nonatomic, retain) NSDictionary *curContact;

@property (nonatomic, retain) id<TileViewCellDelegate> delegate;

- (IBAction)onPhone:(id)sender;
- (IBAction)onContact:(id)sender;

- (void)setPhoto:(NSString *)photo;
- (void)setBorder;

@end
