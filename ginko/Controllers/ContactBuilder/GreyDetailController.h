//
//  GreyDetailController.h
//  GINKO
//
//  Created by mobidev on 5/20/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface GreyDetailController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate,UIScrollViewDelegate>
{
    
    IBOutlet UIButton *btnAddInfo;
    __weak IBOutlet UILabel *lblContacttype;
    __weak IBOutlet UIView *profilelogoPreView;
    __weak IBOutlet UIImageView *profileLogoImageView;
    __weak IBOutlet UIView *profileLogoContainerView;
}
@property (weak, nonatomic) IBOutlet UIScrollView *greyDetailsScrollView;

@property (nonatomic, retain) IBOutlet UIView *navView;
@property (nonatomic, assign) IBOutlet UIButton *btnBack;
@property (nonatomic, assign) IBOutlet UIButton *btnDone;
@property (nonatomic, assign) IBOutlet UIButton *btnClose;
@property (assign, nonatomic) IBOutlet UIButton *btnDoneReal;

@property (nonatomic, assign) IBOutlet UIButton *btnAvatar;
@property (nonatomic, assign) IBOutlet UIImageView *imgAvatar;
@property (nonatomic, assign) IBOutlet UIButton *btnEdit;
@property (nonatomic, assign) IBOutlet UIButton *btnEntity;
@property (nonatomic, assign) IBOutlet UIButton *btnWork;
@property (nonatomic, assign) IBOutlet UIButton *btnHome;
@property (nonatomic, assign) IBOutlet UIButton *btnDel;
@property (nonatomic, assign) IBOutlet UIButton *btnInfo;
@property (nonatomic, assign) IBOutlet UIButton *btnNotes;
@property (nonatomic, assign) IBOutlet UIButton *btnEditInfo;
@property (nonatomic, assign) IBOutlet UIButton *btnRemove;
@property (nonatomic, assign) IBOutlet UILabel *label;
@property (nonatomic, assign) IBOutlet UITextField *txtName;
@property (nonatomic, assign) IBOutlet UITextField *txtFirstName;
@property (nonatomic, assign) IBOutlet UITextField *txtLastName;

@property (nonatomic, retain) IBOutlet UIView *viewFirstCell;
@property (nonatomic, assign) IBOutlet UIView *viewTap;

@property (weak, nonatomic) IBOutlet UIButton *btGreyFavorite;

@property (nonatomic, strong) NSDictionary *curContactDict;
@property (nonatomic, strong) NSString *strNotes;

@property (nonatomic, assign) BOOL isEditing;

@property BOOL isContactFromBackup;

//- (void)addDataSource:(NSString *)strAddItems;
@property (nonatomic, retain) NSMutableArray *arrDataSource;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpacing;


@property (weak, nonatomic) IBOutlet UIButton *addFieldButton2;

@property (weak, nonatomic) IBOutlet UIView *addFieldView;

@property (weak, nonatomic) IBOutlet UITableView *addFieldTable;

- (IBAction)hideAddFieldView:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

- (void)updateNotes;
- (void)reloadGreyDetails;

- (IBAction)onAvatar:(id)sender;
- (IBAction)onEdit:(id)sender;
- (IBAction)onType:(id)sender;
- (IBAction)onDel:(id)sender;
- (IBAction)onInfo:(id)sender;
- (IBAction)onNotes:(id)sender;
- (IBAction)onRemove:(id)sender;

- (IBAction)onBack:(id)sender;
- (IBAction)onDone:(id)sender;
- (IBAction)onClose:(id)sender;
- (IBAction)onFavorite:(id)sender;

- (IBAction)onCloseProfilelogoPreview:(id)sender;
- (IBAction)onOpenProfilelogoPreview:(id)sender;
@end
