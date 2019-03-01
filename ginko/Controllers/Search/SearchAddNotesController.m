//
//  GreyAddNotesController.m
//  GINKO
//
//  Created by mobidev on 5/24/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import "SearchAddNotesController.h"
#import "YYYCommunication.h"

@interface SearchAddNotesController ()
{
    BOOL _keyboardShown;
}
@end

@implementation SearchAddNotesController
@synthesize btnDone, txtNotes, contactInfo, parentController;
@synthesize strNotes, entityID;

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
    //[self dismissViewControllerAnimated:YES  completion:nil];
    /*if ([parentController isKindOfClass:[PurpleDetailViewController class]]) {
        [self UpdateNotes];
    } else */if ([parentController isKindOfClass:[EntityViewController class]] || [parentController isKindOfClass:[MainEntityViewController class]]) {
        [self followerSetNotes];
    }
}

- (IBAction)onCancl:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//- (void)UpdateNotes
//{
//    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
//    
//	void ( ^successed )( id _responseObject ) = ^( id _responseObject ) {
//        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
//        
//        NSLog(@"%@",_responseObject);
//		if ([[_responseObject objectForKey:@"success"] boolValue])
//            [(PurpleDetailViewController *)parentController setStrNotes:txtNotes.text];
//            [self dismissViewControllerAnimated:YES completion:nil];
//    } ;
//    
//    void ( ^failure )( NSError* _error ) = ^( NSError* _error ) {
//        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
//        
//        NSLog(@"Connection failed - %@", _error);
//    } ;
//    [[Communication sharedManager] UpdateNote:[AppDelegate sharedDelegate].sessionId  contactIds:[[contactInfo objectForKey:@"contact_id"] stringValue] notes:txtNotes.text successed:successed failure:failure];
//}

-(void)followerSetNotes
{
	void ( ^successed )( id _responseObject ) = ^( id _responseObject )
	{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary *result = _responseObject;
        if ([[result objectForKey:@"success"] boolValue]) {
            if (_isMain) {
                [(MainEntityViewController *)parentController setNotes:txtNotes.text];
            }else{
                [(EntityViewController *)parentController setNotes:txtNotes.text];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            NSDictionary *dictError = [result objectForKey:@"err"];
            if (dictError) {
                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:[dictError objectForKey:@"errMsg"]];
            } else {
                [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Failed to connect to server!"];
            }
        }
	};
	
	void ( ^failure )( NSError* _error ) = ^( NSError* _error )
	{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
		[CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Internet Connection Error!"];
	};
	
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
//    [[YYYCommunication sharedManager] FollowEntity:[AppDelegate sharedDelegate].sessionId entityid:entityID successed:successed failure:failure];
    [[YYYCommunication sharedManager] FollowerSetNotes:[AppDelegate sharedDelegate].sessionId entityid:entityID notes:txtNotes.text successed:successed failure:failure];
}

@end
