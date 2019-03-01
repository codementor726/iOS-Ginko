//
//  ProfileNamePictureCell.h
//  ginko
//
//  Created by STAR on 15/12/23.
//  Copyright © 2015年 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SAMTextView.h>

@class ProfileNamePictureCell;

@protocol ProfileNamePictureCellDelegate <NSObject>

- (void)tapProfileImage:(ProfileNamePictureCell *)sender;
- (void)profileNameDidChange:(NSString *)text;
- (void)profileNameDidReturn;

@end

@interface ProfileNamePictureCell : UITableViewCell<UITextViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *profileImageButton;
- (IBAction)tapProfileImage:(id)sender;

@property (weak, nonatomic) IBOutlet SAMTextView *nameTextView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *borderHeight;

// setter from outside
@property (weak, nonatomic) id<ProfileNamePictureCellDelegate> delegate;
@property (assign, nonatomic) BOOL roundCornerImage;

- (void)setProfileImage:(UIImage *)image placeholderImage:(UIImage *)placeholder;
@end
