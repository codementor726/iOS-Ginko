//
//  FilterView.m
//  Xchangewithme
//
//  Created by Xin YingTai on 21/5/14.
//  Copyright (c) 2014 Xin YingTai. All rights reserved.
//

#import "FilterView.h"
#import "FilterCell.h"

@implementation FilterView

+ (FilterView *)sharedView
{
    FilterView *_sharedView = [[[NSBundle mainBundle] loadNibNamed:@"FilterView" owner:nil options:nil] objectAtIndex:0];
    return _sharedView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib
{
    [viewForFilter registerNib:[UINib nibWithNibName:@"FilterCell" bundle:nil] forCellWithReuseIdentifier:@"FilterCell"];
    [viewForFilter selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionLeft];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 13;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *filters = [NSArray arrayWithObjects:@"Origin", @"BookStore", @"City", @"Country", @"Film", @"Forest", @"Lake", @"Moment", @"NYC", @"Tea", @"Vintage", @"1Q84", @"B&W", nil];
    static NSString *filterCellIdentifier = @"FilterCell";
    FilterCell *cell = [viewForFilter dequeueReusableCellWithReuseIdentifier:filterCellIdentifier forIndexPath:indexPath];
    
    [cell setNameOfFilter:filters[indexPath.row]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(didSelectFilter:)]) {
        [self.delegate performSelector:@selector(didSelectFilter:) withObject:[NSNumber numberWithInteger:indexPath.row]];
    }
}

@end
