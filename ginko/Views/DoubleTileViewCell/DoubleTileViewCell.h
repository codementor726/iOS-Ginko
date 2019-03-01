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

@protocol DoubleTileViewCellDelegate

@optional;
- (void)viewChat:(NSString*)sessionId contactId:(NSString*)contactId;

@end

@interface DoubleTileViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView * profileImageView;
@property (nonatomic, retain) IBOutlet UILabel * firstName;
@property (nonatomic, retain) IBOutlet UILabel * lastName;
@property (nonatomic, retain) IBOutlet UIButton * contactBut;
@property (nonatomic, retain) IBOutlet UIButton * phoneBut;

@property (nonatomic, retain) NSString * sessionId;
@property (nonatomic, retain) NSString * contactId;

@property (nonatomic, retain) id<DoubleTileViewCellDelegate> delegate;

- (IBAction)onChat:(id)sender;

@end
