//
//  FilterView.h
//  Xchangewithme
//
//  Created by Xin YingTai on 21/5/14.
//  Copyright (c) 2014 Xin YingTai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, FilterType)
{
    FilterTypeOriginal,
    FilterTypeBookStore,
    FilterTypeCity,
    FilterTypeCountry,
    FilterTypeFilm,
    FilterTypeForest,
    FilterTypeLake,
    FilterTypeMoment,
    FilterTypeNYC,
    FilterTypeTea,
    FilterTypeVintage,
    FilterType1Q84,
    FilterTypeBW,
};

@protocol FilterViewDelegate <NSObject>
@optional

- (void)didSelectFilter:(NSNumber *)index;

@end

@interface FilterView : UIView <UICollectionViewDataSource, UICollectionViewDelegate>
{
    IBOutlet UICollectionView *viewForFilter;
}

@property (nonatomic, weak) id<FilterViewDelegate> delegate;

+ (FilterView *)sharedView;

@end
