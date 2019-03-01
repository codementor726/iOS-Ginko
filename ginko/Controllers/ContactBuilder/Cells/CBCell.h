//
//  CBCell.h
//  GINKO
//
//  Created by mobidev on 5/17/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBEmail.h"

@interface CBCell : UITableViewCell

@property (nonatomic, assign) IBOutlet UIImageView *imgValid;
@property (nonatomic, assign) IBOutlet UILabel *lblEmail;

@property (nonatomic, strong) CBEmail *curCBEmail;

@property (nonatomic, strong) id delegate;

+ (CBCell *)sharedCell;

@end
