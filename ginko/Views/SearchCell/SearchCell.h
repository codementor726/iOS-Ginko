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

@protocol SearchCellDelegate

@end

@interface SearchCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView * profileImageView;
@property (nonatomic, retain) IBOutlet UILabel * firstName;
@property (nonatomic, retain) IBOutlet UILabel * lastName;
@property (nonatomic, retain) IBOutlet UIView *backgroundView;
@property (nonatomic, retain) IBOutlet UIButton *actionBtn;
@property (nonatomic, retain) IBOutlet UIButton *phoneBtn;
@property (nonatomic, retain) IBOutlet UIButton *chatOrEmailBtn;
@property (nonatomic, retain) IBOutlet UILabel *lblCaption;

@property (nonatomic, retain) NSString * sessionId;
@property (nonatomic, retain) NSString * contactId;

@property (nonatomic, retain) id<SearchCellDelegate> delegate;

- (void)setPhoto:(NSString *)photo;

@end
