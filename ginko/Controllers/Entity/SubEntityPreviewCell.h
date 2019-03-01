//
//  SubEntityPreviewCell.h
//  ginko
//
//  Created by stepanekdavid on 4/18/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubEntityPreviewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *subEntityImg;
@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblDistance;

@end
