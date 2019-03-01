//
//  ManageDirectoryViewController.m
//  ginko
//
//  Created by stepanekdavid on 12/26/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "ManageDirectoryViewController.h"
#import "PreDirectoryViewController.h"
#import "DomainCell.h"

#import "UIImage+Resize.h"
#import "UIImageView+AFNetworking.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+Tint.h"
#import "UIButton+AFNetworking.h"

#import "YYYCommunication.h"
#import "ProfileImageEditViewController.h"
#import "LocalDBManager.h"

#import "TabRequestController.h"
@interface ManageDirectoryViewController ()<UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, DomainCellDelegate, UIActionSheetDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, ProfileImageEditViewControllerDelegate, UITextFieldDelegate>
{
    NSMutableArray *arrDomain;
    NSMutableArray *tmpArrayDomain;

    BOOL removedImage;
    // logo image
    UIImage *_logoImage;
    UIImageView *_tempLogoImageView;
}
@end

@implementation ManageDirectoryViewController
@synthesize directoryInfo;
@synthesize isJoinOwn;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Create";
    
    // reset global appearance
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    if (directoryInfo) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    }else{
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackArrow"] style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"OK" style:UIBarButtonItemStyleDone target:self action:@selector(onDone:)];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    // tapGestureRecognizer.cancelsTouchesInView = NO;
    tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    
    btnPrivate.selected = YES;
    btnAuto.selected = YES;
    
    arrDomain = [[NSMutableArray alloc] init];
    tmpArrayDomain = [[NSMutableArray alloc] init];
    
    if (directoryInfo) {
        lblDirectoryName.hidden = YES;
        nameView.hidden = NO;
        txtName.text = [directoryInfo objectForKey:@"name"];
        self.title = @"Edit";
        if (![[directoryInfo objectForKey:@"privilege"] boolValue]) {
            btnPrivate.selected = YES;
            btnPublic.selected = NO;
            if ([[directoryInfo objectForKey:@"approve_mode"] boolValue]) {
                btnAuto.selected = YES;
                btnManual.selected = NO;
                
                if ([directoryInfo objectForKey:@"domain"] && ![[directoryInfo objectForKey:@"domain"] isEqualToString:@""]) {
                    NSArray *arr = [[directoryInfo objectForKey:@"domain"] componentsSeparatedByString:@","];
                    arrDomain = [arr mutableCopy];
                    tmpArrayDomain = [arr mutableCopy];
                }
            }else{
                btnAuto.selected = NO;
                btnManual.selected = YES;
                domainView.hidden = YES;
            }
        }else{
            btnPrivate.selected = NO;
            btnPublic.selected = YES;
            viewPrivateOrPublic.hidden = YES;
            domainView.hidden = YES;
        }
        
        
        [domainTableview reloadData];
        [btnDirectoryLogo setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:[directoryInfo objectForKey:@"profile_image"]]];
        
    }else{
        lblDirectoryName.hidden = NO;
        nameView.hidden = YES;
        lblDirectoryName.text = _directoryName;
        directoryInfo = [[NSMutableDictionary alloc] init];
        [directoryInfo setObject:_directoryName forKey:@"name"];
        [directoryInfo setObject:@(0) forKey:@"privilege"];
        [directoryInfo setObject:@(1) forKey:@"approve_mode"];
    }
}

- (void) hideKeyboard{
    [self.view endEditing:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - UITextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}
- (void)onDone:(id)sender {
    if (!nameView.hidden && txtName.text.length == 0) {
        UIAlertView *alertViewforError = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Please input Directory name." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
        [alertViewforError show];
        return;
    }
    if ([arrDomain count] == 0 && btnPrivate.selected && btnAuto.selected) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Need to add at least one email domain."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    [self.view endEditing:NO];
    NSLog(@"%@", directoryInfo);
    if ([directoryInfo objectForKey:@"id"]) {
        if (isJoinOwn) {
            [self updateDirectoryWithFromRequest];
        }else{
            [self checkDirectoryName];
        }
    }else{
        [self createDirectory];
    }
    
}
- (void)createDirectory{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([[_responseObject objectForKey:@"success"] boolValue]) {            
            PreDirectoryViewController *viewController = [[PreDirectoryViewController alloc] initWithNibName:@"PreDirectoryViewController" bundle:nil];
            viewController.isCreate = _isCreate;
            viewController.isJoinOwn = YES;
            [directoryInfo setObject:[[_responseObject objectForKey:@"data"] objectForKey:@"id"] forKey:@"id"];
            viewController.directoryInfoForPreview = directoryInfo;
            [self.navigationController pushViewController:viewController animated:YES];
        }else{
            [CommonMethods showAlertUsingTitle:@"Oops!" andMessage:[[_responseObject objectForKey:@"err"] objectForKey:@"errMsg"]];
        }
    };
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Internet Connection Error!"];
    };
    
    NSString *strDomain = @"";
    for (NSString *domainStr in arrDomain) {
        if ([strDomain isEqualToString:@""]) {
            strDomain = domainStr;
        }else{
            strDomain = [NSString stringWithFormat:@"%@,%@",strDomain, domainStr];
        }
    }
    [[YYYCommunication sharedManager] CreateDirectory:APPDELEGATE.sessionId name:_directoryName privilege:[[directoryInfo objectForKey:@"privilege"] boolValue] approveMode:[[directoryInfo objectForKey:@"approve_mode"] boolValue] domain:strDomain profileImage:[directoryInfo objectForKey:@"profile_image_name"] successed:successed failure:failure];
}
- (void)checkDirectoryName{
    if (directoryInfo) {
        if ([[directoryInfo objectForKey:@"name"] isEqualToString:txtName.text]) {
            [self updateDirectory];
        }else{
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            void ( ^successed )( id _responseObject ) = ^( id _responseObject )
            {
                if ([[_responseObject objectForKey:@"success"] boolValue]) {
                    if ([[_responseObject objectForKey:@"data"] integerValue] == 1) {
                        [self updateDirectory];
                    }else{
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        NSString *errMsg = [NSString stringWithFormat:@"Sorry %@ is already taken,\n please enter another name.", txtName.text];
                        [CommonMethods showAlertUsingTitle:@"Oops!" andMessage:errMsg];
                    }
                }else{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                }
            };
            
            void ( ^failure )( NSError* _error ) = ^( NSError* _error )
            {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Internet Connection Error!"];
            };
            
            //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
            NSString *dirName = [txtName.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [[YYYCommunication sharedManager] GetDirCheckingAvail:APPDELEGATE.sessionId name:dirName successed:successed failure:failure];
        }
    }
}
- (void)updateDirectoryWithFromRequest{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([[_responseObject objectForKey:@"success"] boolValue]) {
            PreDirectoryViewController *viewController = [[PreDirectoryViewController alloc] initWithNibName:@"PreDirectoryViewController" bundle:nil];
            viewController.isCreate = _isCreate;
            viewController.isJoinOwn = YES;
            viewController.directoryInfoForPreview = directoryInfo;
            [self.navigationController pushViewController:viewController animated:YES];
        }else{
            [CommonMethods showAlertUsingTitle:@"Oops!" andMessage:[[_responseObject objectForKey:@"err"] objectForKey:@"errMsg"]];
        }
    };
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Internet Connection Error!"];
    };
    
    [[YYYCommunication sharedManager] UpdateDirectory:APPDELEGATE.sessionId directoryId:[directoryInfo objectForKey:@"id"] name:[directoryInfo objectForKey:@"name"] privilege:[[directoryInfo objectForKey:@"privilege"] boolValue] approveMode:[[directoryInfo objectForKey:@"approve_mode"] boolValue] domain:[directoryInfo objectForKey:@"domain"] successed:successed failure:failure];
}
- (void)updateDirectory{
    if ([[directoryInfo objectForKey:@"name"] isEqualToString:txtName.text]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([[_responseObject objectForKey:@"success"] boolValue]) {
            PreDirectoryViewController *viewController = [[PreDirectoryViewController alloc] initWithNibName:@"PreDirectoryViewController" bundle:nil];
            viewController.isCreate = _isCreate;
            viewController.directoryInfoForPreview = directoryInfo;
            viewController.isJoinOwn = NO;
            [self.navigationController pushViewController:viewController animated:YES];
        }else{
            [CommonMethods showAlertUsingTitle:@"Oops!" andMessage:[[_responseObject objectForKey:@"err"] objectForKey:@"errMsg"]];
        }
    };
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Internet Connection Error!"];
    };
    
    [directoryInfo setObject:txtName.text forKey:@"name"];
    [[YYYCommunication sharedManager] UpdateDirectory:APPDELEGATE.sessionId directoryId:[directoryInfo objectForKey:@"id"] name:[directoryInfo objectForKey:@"name"] privilege:[[directoryInfo objectForKey:@"privilege"] boolValue] approveMode:[[directoryInfo objectForKey:@"approve_mode"] boolValue] domain:[directoryInfo objectForKey:@"domain"] successed:successed failure:failure];
}
- (IBAction)onPrivate:(id)sender {
    [self.view endEditing:NO];
    btnPrivate.selected = YES;
    btnPublic.selected = NO;
    viewPrivateOrPublic.hidden = NO;
    if (btnManual.selected) {
        domainView.hidden = YES;
    }else{
        domainView.hidden = NO;
    }
    [directoryInfo setObject:@(0) forKey:@"privilege"];
}

- (IBAction)onPublic:(id)sender {
    [self.view endEditing:NO];
    btnPrivate.selected = NO;
    btnPublic.selected = YES;
    viewPrivateOrPublic.hidden = YES;
    domainView.hidden = YES;
    [directoryInfo setObject:@(1) forKey:@"privilege"];
}

- (IBAction)onAuto:(id)sender {
    [self.view endEditing:NO];
    btnAuto.selected = YES;
    btnManual.selected = NO;
    domainView.hidden = NO;
    [directoryInfo setObject:@(1) forKey:@"approve_mode"];
}

- (IBAction)onManual:(id)sender {
    [self.view endEditing:NO];
    btnAuto.selected = NO;
    btnManual.selected = YES;
    domainView.hidden = YES;
    [directoryInfo setObject:@(0) forKey:@"approve_mode"];
}

- (IBAction)onAddDomain:(id)sender {
    [self.view endEditing:NO];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Enter an email domain for auto mode."
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[alertView textFieldAtIndex:0] setTextAlignment:NSTextAlignmentCenter];
    [alertView setTag:100];
    UITextField *textField = [alertView textFieldAtIndex:0];
    [textField setKeyboardType:UIKeyboardTypeEmailAddress];
    textField.placeholder = @"Enter Domain [i.e email.com]";
    [alertView show];
}

- (IBAction)onUpdateDirectoryLogo:(id)sender {
    [self.view endEditing:NO];
    [self.view endEditing:NO];
    //[self fitToScroll];
    
    UIActionSheet *actionSheet;
    if (_logoImage || ([directoryInfo objectForKey:@"profile_image"] && ![[directoryInfo objectForKey:@"profile_image"] isEqualToString:@""])) { // photo exists
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"Add your photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Take a Photo" otherButtonTitles:@"Photo From Gallery", @"Remove photo", nil];
        actionSheet.destructiveButtonIndex = 2;
    } else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"Add your photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a Photo", @"Photo From Gallery", nil];
    }
    
    [actionSheet showInView:self.view];
}
#pragma mark - UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES ];
    
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(640, 640) interpolationQuality:kCGInterpolationDefault];
    image = [image fixOrientation];
    
    if (![UIImageJPEGRepresentation(image, 1) writeToFile:TEMP_IMAGE_PATH atomically:YES]) {
        [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Failed to save information. Please try again."];
        return;
    }
    
    ProfileImageEditViewController *vc = [[ProfileImageEditViewController alloc] initWithNibName:@"ProfileImageEditViewController" bundle:nil];
    vc.isEntity = YES;
    vc.sourceImage = image;
    vc.delegate = self;
    [picker pushViewController:vc animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - UIActionSheet Delegate


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
        return;
    } else if(buttonIndex == 2) { // delete photo
        [self deletePhoto];
        return;
    }
    
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.delegate = self;
    
    if (buttonIndex) {// photo library
        imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imgPicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
        [self presentViewController:imgPicker animated:YES completion:nil];
    }
    else {
        if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!granted) {
                        [CommonMethods showAlertUsingTitle:@"" andMessage:MESSAGE_CAMERA_DISABLED];
                    }
                    else {
                        imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                        imgPicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
                        [self presentViewController:imgPicker animated:YES completion:nil];
                    }
                });
            }];
        }
    }
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([alertView tag] == 100 && buttonIndex == 1)
    {
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSString *text = textField.text;
        if (text.length == 0) {
            UIAlertView *alertViewforError = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"The input field is empty." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
            alertViewforError.tag = 1001;
            [alertViewforError show];
            return;
        }
        if (![self checkDomain:text]) {
            UIAlertView *alertViewforError = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Please enter a valid Domain." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
            alertViewforError.tag = 1001;
            [alertViewforError show];
            return;
        }
        if ([arrDomain containsObject:text]) {
            UIAlertView *alertViewforError = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"This email already exists in the 'Email domain list'." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
            alertViewforError.tag = 1001;
            [alertViewforError show];
            return;
        }
        [arrDomain addObject:text];
        NSString *strDomain = @"";
        NSMutableArray *domainsForSorting = [[NSMutableArray alloc] init];
        for (NSString *domainStr in arrDomain) {
            if ([strDomain isEqualToString:@""]) {
                strDomain = domainStr;
            }else{
                strDomain = [NSString stringWithFormat:@"%@,%@",strDomain, domainStr];
            }
            
            NSMutableDictionary *oneDomain = [[NSMutableDictionary alloc] init];
            [oneDomain setObject:domainStr forKey:@"domain"];
            [domainsForSorting addObject:oneDomain];
            
        }
        
        [directoryInfo setObject:strDomain forKey:@"domain"];
        
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"domain" ascending:YES selector:@selector(localizedStandardCompare:)];
        NSMutableArray * sortDescriptors = [NSMutableArray arrayWithObject:sortDescriptor];
        [domainsForSorting sortUsingDescriptors:sortDescriptors];
        [arrDomain removeAllObjects];
        for (NSDictionary *dic in domainsForSorting) {
            [arrDomain addObject:[dic objectForKey:@"domain"]];
        }
        tmpArrayDomain = [arrDomain mutableCopy];
        [domainTableview reloadData];
        
    }else if ([alertView tag] == 101 && buttonIndex == 1)
    {
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSString *text = textField.text;
        if (text.length == 0) {
            UIAlertView *alertViewforError = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"The input field is empty." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
            alertViewforError.tag = 1001;
            [alertViewforError show];
            [tmpArrayDomain removeAllObjects];
            tmpArrayDomain = [arrDomain mutableCopy];
            return;
        }
        if (![self checkDomain:text]) {
            UIAlertView *alertViewforError = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Please enter a valid Domain." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
            alertViewforError.tag = 1001;
            [alertViewforError show];
            [tmpArrayDomain removeAllObjects];
            tmpArrayDomain = [arrDomain mutableCopy];
            return;
        }
        if ([tmpArrayDomain containsObject:text]) {
            UIAlertView *alertViewforError = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"This email already exists in the 'Email domain list'." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
            alertViewforError.tag = 1001;
            [alertViewforError show];
            [tmpArrayDomain removeAllObjects];
            tmpArrayDomain = [arrDomain mutableCopy];
            return;
        }
        [tmpArrayDomain addObject:text];
        [arrDomain removeAllObjects];
        arrDomain = [tmpArrayDomain mutableCopy];
        NSString *strDomain = @"";
        NSMutableArray *domainsForSorting = [[NSMutableArray alloc] init];
        for (NSString *domainStr in arrDomain) {
            if ([strDomain isEqualToString:@""]) {
                strDomain = domainStr;
            }else{
                strDomain = [NSString stringWithFormat:@"%@,%@",strDomain, domainStr];
            }
            
            NSMutableDictionary *oneDomain = [[NSMutableDictionary alloc] init];
            [oneDomain setObject:domainStr forKey:@"domain"];
            [domainsForSorting addObject:oneDomain];
            
        }
        
        [directoryInfo setObject:strDomain forKey:@"domain"];
        
        
        
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"domain" ascending:YES selector:@selector(localizedStandardCompare:)];
        NSMutableArray * sortDescriptors = [NSMutableArray arrayWithObject:sortDescriptor];
        [domainsForSorting sortUsingDescriptors:sortDescriptors];
        [arrDomain removeAllObjects];
        for (NSDictionary *dic in domainsForSorting) {
            [arrDomain addObject:[dic objectForKey:@"domain"]];
        }
        
        [domainTableview reloadData];
    }else if ([alertView tag] == 101 && buttonIndex == 0){
        [tmpArrayDomain removeAllObjects];
        tmpArrayDomain = [arrDomain mutableCopy];
    }else if ([alertView tag] == 1001){
        //[self onAddDomain:nil];
    }
}

- (BOOL)checkDomain:(NSString *)checkText
{
    BOOL filter = YES ;
    NSString *filterString = @"[A-Z0-9a-z._%+-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = filter ? filterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    if([emailTest evaluateWithObject:checkText] == NO)
    {
        return NO ;
    }
    
    return YES ;
}

#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [arrDomain count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 35.0f;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *simpleTableIdentifier = @"DomainItem";
    DomainCell *cell = (DomainCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [DomainCell sharedCell];
    }
    cell.delegate = self;
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setCurDomain:[arrDomain objectAtIndex:indexPath.row]];
    cell.subDomainName.text = [arrDomain objectAtIndex:indexPath.row];
        return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:NO];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:NO];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *currentDomain = [tmpArrayDomain objectAtIndex:indexPath.row];
    [tmpArrayDomain removeObjectAtIndex:indexPath.row];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Enter an email domain for auto mode."
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[alertView textFieldAtIndex:0] setTextAlignment:NSTextAlignmentCenter];
    [alertView setTag:101];
    UITextField *textField = [alertView textFieldAtIndex:0];
    [textField setKeyboardType:UIKeyboardTypeEmailAddress];
    textField.text = currentDomain;
    [alertView show];
    
}

#pragma mark DomainCellDelegate
- (void)onRemoveDomain:(DomainCell *)cell curDomain:(NSString *)domain{
    NSIndexPath *indexPath = [domainTableview indexPathForCell:cell];
    for (int i = 0; i < [arrDomain count]; i ++) {
        NSString *dict = [arrDomain objectAtIndex:i];
        if ([dict isEqualToString:domain]) {
            [arrDomain removeObjectAtIndex:i];
            [domainTableview deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
            NSString *strDomain = @"";
            for (NSString *domainStr in arrDomain) {
                if ([strDomain isEqualToString:@""]) {
                    strDomain = domainStr;
                }else{
                    strDomain = [NSString stringWithFormat:@"%@,%@",strDomain, domainStr];
                }
            }
            [directoryInfo setObject:strDomain forKey:@"domain"];
            
            [domainTableview reloadData];
            return;
        }
    }
}
- (void)uploadPhoto:(UIImage *)img {
    _logoImage = img;
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [self uploadPhoto:img directoryId:[directoryInfo objectForKey:@"id"] completionHandler:^(BOOL success) {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            if (success) {
                [btnDirectoryLogo setBackgroundImage:_logoImage forState:UIControlStateNormal];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to upload photo, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }];
}
- (void)uploadPhoto:(UIImage *)img directoryId:(NSString *)_directoryId completionHandler:(void(^)(BOOL success))completion {
    void (^successed)(id responseObject) = ^(id responseObject) {
        NSDictionary *result = responseObject;
        
        if ([[result objectForKey:@"success"] boolValue]) {
            // save to local cache
            _logoImage = img;
            if ([directoryInfo objectForKey:@"id"]) {
                [directoryInfo setObject:[[result objectForKey:@"data"] objectForKey:@"image_url"] forKey:@"profile_image"];
            }else{
                [directoryInfo setObject:[[result objectForKey:@"data"] objectForKey:@"image_name"] forKey:@"profile_image_name"];
                [directoryInfo setObject:[[result objectForKey:@"data"] objectForKey:@"image_url"] forKey:@"profile_image"];
            }
            completion(YES);
        } else {
            completion(NO);
        }
    };
    
    void (^failure)(NSError* error) = ^(NSError* error) {
        completion(NO);
    };
    
    [[YYYCommunication sharedManager]  uploadDirectoryPhoto:APPDELEGATE.sessionId directoryId:_directoryId imgData:UIImageJPEGRepresentation(img, 1) successed:successed failure:failure];
}
#pragma mark - ProfileImageEditViewControllerDelegate
- (void)didSelectProfileImage:(UIImage *)image {
    image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(image.size.width/2, image.size.height/2) interpolationQuality:kCGInterpolationMedium];
    [self uploadPhoto:image];
}

- (void)deletePhoto{
    if ([directoryInfo objectForKey:@"id"]) {
        void (^successed)(id responseObject) = ^(id responseObject) {
            NSDictionary *result = responseObject;
            
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            
            if ([[result objectForKey:@"success"] boolValue]) {
                _logoImage = nil;
                removedImage = YES;
                [btnDirectoryLogo setBackgroundImage:[UIImage imageNamed:@"directory_bk_image.png"] forState:UIControlStateNormal];
                [directoryInfo setObject:@"" forKey:@"profile_image"];
            } else {
                NSDictionary *dictError = [result objectForKey:@"err"];
                if (dictError) {
                    [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:[dictError objectForKey:@"errMsg"]];
                } else {
                    [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Failed to connect to server!"];
                }
            }
        };
        
        void (^failure)(NSError* error) = ^(NSError* error) {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            
            [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Failed to connect to server!"];
        };
        
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [[YYYCommunication sharedManager] removeDirectoryPhoto:APPDELEGATE.sessionId directoryId:[directoryInfo objectForKey:@"id"] successed:successed failure:failure];
    } else {
        _logoImage = nil;
        removedImage = YES;
        [btnDirectoryLogo setBackgroundImage:[UIImage imageNamed:@"directory_bk_image.png"] forState:UIControlStateNormal];
    }

}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isKindOfClass:[UIScrollView class]]) {
        return YES;
    }
    if([touch.view isKindOfClass:[UITableViewCell class]]) {
        return NO;
    }
    // UITableViewCellContentView => UITableViewCell
    if([touch.view.superview isKindOfClass:[UITableViewCell class]]) {
        return NO;
    }
    // UITableViewCellContentView => UITableViewCellScrollView => UITableViewCell
    if([touch.view.superview.superview isKindOfClass:[UITableViewCell class]]) {
        return NO;
    }
    return YES;
}
- (void)movePushNotificationViewController{
    TabRequestController *tabRequestController = [TabRequestController sharedController];
    tabRequestController.selectedIndex = 1;
    [self.navigationController pushViewController:tabRequestController animated:YES];
}
@end


