//
//  WallpaperVideoCell.m
//  ginko
//
//  Created by STAR on 15/12/23.
//  Copyright © 2015年 com.xchangewithme. All rights reserved.
//

#import "WallpaperVideoCell.h"

@implementation WallpaperVideoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _wallpaperButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    _videoButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)addWallpaper:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(tapWallpaper:)])
        [_delegate tapWallpaper:self];
}

- (IBAction)addVideo:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(tapProfileVideo:)])
        [_delegate tapProfileVideo:self];
}

- (void)setWallpaper:(UIImage *)image {
    if (image)
        [_wallpaperButton setImage:image forState:UIControlStateNormal];
    else
        [_wallpaperButton setImage:[UIImage imageNamed:@"add_wallpaper"] forState:UIControlStateNormal];
}

- (void)setVideoSnapshot:(UIImage *)image {
    if (image)
        [_videoButton setImage:image forState:UIControlStateNormal];
    else
        [_videoButton setImage:[UIImage imageNamed:@"add_profile_video"] forState:UIControlStateNormal];
}

@end
