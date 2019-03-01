//
//  WallpaperVideoCell.h
//  ginko
//
//  Created by STAR on 15/12/23.
//  Copyright © 2015年 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WallpaperVideoCell;

@protocol WallpaperVideoCellDelegate <NSObject>

- (void)tapWallpaper:(WallpaperVideoCell *)sender;
- (void)tapProfileVideo:(WallpaperVideoCell *)sender;

@end

@interface WallpaperVideoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *wallpaperButton;
@property (weak, nonatomic) IBOutlet UIButton *videoButton;
- (IBAction)addWallpaper:(id)sender;
- (IBAction)addVideo:(id)sender;

// setter from outside
@property (weak, nonatomic) id<WallpaperVideoCellDelegate> delegate;
- (void)setWallpaper:(UIImage *)image;
- (void)setVideoSnapshot:(UIImage *)image;

@end
