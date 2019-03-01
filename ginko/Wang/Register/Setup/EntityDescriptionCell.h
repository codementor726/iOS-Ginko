//
//  EntityDescriptionCell.h
//  ginko
//
//  Created by Harry on 1/15/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <SAMTextView.h>

@protocol EntityDescriptionCellDelegate <NSObject>

- (void)didChangeEntityDescription:(NSString *)description;

@end

@interface EntityDescriptionCell : UITableViewCell<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet SAMTextView *descTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *borderHeight;

@property (weak, nonatomic) id<EntityDescriptionCellDelegate> delegate;
@end
