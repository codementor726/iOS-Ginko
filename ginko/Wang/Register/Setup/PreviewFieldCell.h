//
//  PreviewFieldCell.h
//  ginko
//
//  Created by Harry on 1/8/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <TTTAttributedLabel.h>

@interface PreviewFieldCell : UITableViewCell

@property (weak, nonatomic) IBOutlet TTTAttributedLabel *fieldLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@end
