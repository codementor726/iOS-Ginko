//
//  AddLocationCell.h
//  ginko
//
//  Created by stepanekdavid on 4/17/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddLocationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *locationOfSubEntity;
@property (weak, nonatomic) IBOutlet UILabel *isCompleted;
@property (weak, nonatomic) IBOutlet UIImageView *imgArrow;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomHeight;
@end
