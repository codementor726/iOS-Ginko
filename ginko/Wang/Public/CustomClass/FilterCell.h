//
//  FilterCell.h
//  Xchangewithme
//
//  Created by Xin YingTai on 21/5/14.
//  Copyright (c) 2014 Xin YingTai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterCell : UICollectionViewCell
{
    IBOutlet UIImageView *imgForFilter;
    IBOutlet UILabel *lblForFilter;
}

- (void)setNameOfFilter:(NSString *)name;

@end
