//
//  ExchangedInfoCell.h
//  Ginko
//
//  Created by Qi Song on 29/3/14.
//  Copyright (c) 2014 Qi Song. All rights reserved.
//
// --- Headers ---;
#import <UIKit/UIKit.h>

// --- Defines ---;
// ExchangedInfoCell Class;

@protocol ExchangedInfoCellDelegate

@optional;
- (void)didChat:(NSDictionary *)contactDict;
- (void)didEdit:(NSDictionary *)contactDict;
- (void)hideKeyBoard;
- (void)didCallVoice:(NSDictionary *)contactDict;
- (void)didCallVideo:(NSDictionary *)contactDict;
- (void)didPhone:(UIActionSheet *)actionSheet;
@end

@interface ExchangedInfoCell : UITableViewCell <UIActionSheetDelegate>

@property (nonatomic, retain) IBOutlet UIImageView * profileImageView;
@property (nonatomic, retain) IBOutlet UILabel * username;
@property (nonatomic, retain) IBOutlet UILabel * lastDate;
@property (nonatomic, retain) IBOutlet UILabel * pingArea;
@property (nonatomic, retain) IBOutlet UIButton * btnPhone;
@property (nonatomic, retain) IBOutlet UIButton * btnContact;

@property (nonatomic, retain) NSMutableArray *arrPhone;

@property (nonatomic, retain) NSString * sessionId;
@property (nonatomic, retain) NSString * contactId;
@property (nonatomic, retain) NSDictionary * contactInfo;

@property (nonatomic, retain) id<ExchangedInfoCellDelegate> delegate;

- (IBAction)onPhone:(id)sender;
- (IBAction)onContact:(id)sender;

- (void)setPhoto:(NSString *)photo;
- (void)setPingLocation:(CGFloat)pingLatitude pingLongitude:(CGFloat)pingLongitude;
- (void)populateCellWithContact:(SearchedContact*)contact;
@end
