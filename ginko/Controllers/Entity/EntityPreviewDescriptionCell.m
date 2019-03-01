//
//  EntityPreviewDescriptionCell.m
//  ginko
//
//  Created by Harry on 1/16/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "EntityPreviewDescriptionCell.h"

@implementation EntityPreviewDescriptionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
//    _descLabel.attributedTruncationToken = [[NSAttributedString alloc] initWithString:@"... show more" attributes:@{NSForegroundColorAttributeName: COLOR_PURPLE_THEME, NSFontAttributeName: _descLabel.font, NSLinkAttributeName: [NSURL URLWithString:@"More"]}];
//    _descLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
//    _descLabel.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url
{
    if([url.absoluteString isEqualToString:@"More"])
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:_descLabel.text delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil] show];
    }
}

@end
