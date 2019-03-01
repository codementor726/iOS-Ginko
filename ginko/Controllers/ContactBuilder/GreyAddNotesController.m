//
//  GreyAddNotesController.m
//  GINKO
//
//  Created by mobidev on 5/24/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import "GreyAddNotesController.h"
#import "GreyClient.h"

@interface GreyAddNotesController ()<UITextFieldDelegate, UITextViewDelegate>
{
    BOOL _keyboardShown;
}
@end

@implementation GreyAddNotesController
@synthesize btnDone, txtNotes;
@synthesize parentController, strNotes;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    txtNotes.placeholderColor = [UIColor lightGrayColor];
    txtNotes.placeholderText = @"Enter Notes";
    if (![strNotes isEqualToString:@""])
    {
        txtNotes.text = strNotes;
    }
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [txtNotes becomeFirstResponder];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextView Delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    int newLength = (int)[textView.text length] - (int)range.length + (int)text.length;
    if (newLength != 0) {
        btnDone.hidden = NO;
    }
    return YES;
}
#pragma mark - Keyboard Notifications
- (void)keyboardWillShow:(NSNotification*)aNotification {
    NSDictionary* userInfo = [aNotification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    if(!_keyboardShown)
    {
        CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:duration];
        [UIView setAnimationCurve:[userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    }
    
    _bottomSpace.constant = kbSize.height;
    [self.view layoutIfNeeded];
    
    if(!_keyboardShown)
        [UIView commitAnimations];
    
    _keyboardShown = YES;
}

- (void)keyboardWillHide:(NSNotification*)aNotification {
    NSDictionary *userInfo = [aNotification userInfo];
    CGFloat duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:[userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    
    _bottomSpace.constant = 0;
    [self.view layoutIfNeeded];
    
    [UIView commitAnimations];
    
    _keyboardShown = NO;
}
#pragma mark - Actions
- (IBAction)onDone:(id)sender
{
    [self.view endEditing:NO];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //importer class
    if ([parentController isKindOfClass:[CISyncDetailController class]]) {
        /*
        [SVProgressHUD showWithStatus:@"Updating..." maskType:SVProgressHUDMaskTypeClear];
        [[GreyClient sharedClient] addUpdateGreyContact:[AppDelegate sharedDelegate].sessionId contactID:curDict[@"contact_id"] firstName:curDict[@"contact_id"] middleName:curDict[@"middle_name"] lastName:curDict[@"last_name"] email:curDict[@"email"] photoName:@"" notes:txtNotes.text type:curDict[@"type"] fields:curDict[@"fields"] successed:^(id responseObject) {
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:@"Successed"];
         
            curDict[@"notes"] = txtNotes.text;
        } failure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Failed to connect to server!"];
        }];*/
         CISyncDetailController *vc = (CISyncDetailController *)parentController;
         vc.strNotes = txtNotes.text;
    } else if ([parentController isKindOfClass:[GreyDetailController class]]) {
       GreyDetailController *vc = (GreyDetailController *)parentController;
       vc.strNotes = txtNotes.text;
    } else if ([parentController isKindOfClass:[PreviewProfileViewController class]]) {
        PreviewProfileViewController *vc = (PreviewProfileViewController *)parentController;
        vc.strNotes = txtNotes.text;
    }
    
    [self dismissViewControllerAnimated:YES  completion:^{
        if ([parentController isKindOfClass:[CISyncDetailController class]]) {
            [(CISyncDetailController *)parentController updateNotes];
        } else if ([parentController isKindOfClass:[GreyDetailController class]]) {
            GreyDetailController *vc = (GreyDetailController *)parentController;
            [vc updateNotes];
        } else if ([parentController isKindOfClass:[PreviewProfileViewController class]]) {
            PreviewProfileViewController *vc = (PreviewProfileViewController *)parentController;
            [vc updateNotes];
        }
    }];
}

- (IBAction)onCancl:(id)sender
{
    [self.view endEditing:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
