//
//  YYYCustomInboxCell.h
//  InstantMessenger
//
//  Created by Wang MeiHua on 3/31/14.
//  Copyright (c) 2014 Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomInboxDelegate <NSObject>

-(void)selectAction:(int)index :(int)status;

@end

@interface YYYCustomInboxCell : UITableViewCell
{
	int index;
}

+ (YYYCustomInboxCell *)sharedCell;

-(void)initWithData:(int)index;
-(IBAction)btSelectClick:(id)sender;

@property (nonatomic,retain) id<CustomInboxDelegate> delegate;

@end
