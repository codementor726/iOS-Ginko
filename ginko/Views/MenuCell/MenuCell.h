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

@protocol MenuCellDelegate

@end

@interface MenuCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView * imgViewIcon;
@property (nonatomic, retain) IBOutlet UILabel * lblCaption;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImage;

@property (nonatomic, retain) NSString * sessionId;
@property (nonatomic, retain) NSString * contactId;

@property (nonatomic, retain) id<MenuCellDelegate> delegate;

@end
