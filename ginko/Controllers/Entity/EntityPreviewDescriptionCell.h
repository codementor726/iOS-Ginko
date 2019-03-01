//
//  EntityPreviewDescriptionCell.h
//  ginko
//
//  Created by Harry on 1/16/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <TTTAttributedLabel.h>

@interface EntityPreviewDescriptionCell : UITableViewCell <TTTAttributedLabelDelegate>
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@end
