//
//  CBImportItemViewController.m
//  GINKO
//
//  Created by mobidev on 8/7/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import "CBImportItemViewController.h"
#import "ContactImporterClient.h"
#import "CBDetailViewController.h"

@interface CBImportItemViewController ()
{
    NSString *oAuthURL;
    NSString *provider;
    CGRect frmOrigin;
}
@end

@implementation CBImportItemViewController
@synthesize navView;
@synthesize type;
@synthesize btnBack, btnDone, btnDoneFake, imgIcon, lblInstruction;
@synthesize txtEmail, txtPassword, txtUsername, txtWebmailLink, viewBottom, viewDescription;

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
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    if (_globalData.cbIsFromMenu) {
        [self layoutMenuLink];
    }
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
	[self.view addGestureRecognizer:gesture];
}

-(void)handleTap
{
	[self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar addSubview:navView];
    [self configureUI];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    frmOrigin = self.view.frame;
    if (IS_IPHONE_5) {
        return;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    if (type == 104) {
        [self.view setFrame:CGRectMake(0, -10, self.view.frame.size.width, self.view.frame.size.height)];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    if (type == 104) {
        [self.view setFrame:frmOrigin];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [navView removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - configure UI
- (void)configureUI
{
    CGPoint pt;
    
    switch (type) {
        case 100:
            pt = imgIcon.center;
            [imgIcon setImage:[UIImage imageNamed:@"ImportMail"]];
            [imgIcon setFrame:CGRectMake(0, 0, 54, 39)];
            [imgIcon setCenter:pt];
            
            [lblInstruction setText:@"Setup your Builder account with Gmail"];
//            txtEmail.text = @"jimmyw1003@gmail.com";//deleted
            provider = @"google";
            break;
        case 101:
            pt = imgIcon.center;
            [imgIcon setImage:[UIImage imageNamed:@"ImportYahoo"]];
            [imgIcon setFrame:CGRectMake(0, 0, 52, 44)];
            [imgIcon setCenter:pt];
            
            [lblInstruction setText:@"Setup your Builder account with Yahoo!"];
//            txtEmail.text = @"mobidev9041@yahoo.com";
            provider = @"yahoo";
            break;
        case 102:
            pt = imgIcon.center;
            [imgIcon setImage:[UIImage imageNamed:@"ImportMsn"]];
            [imgIcon setFrame:CGRectMake(0, 0, 47, 48)];
            [imgIcon setCenter:pt];
            
            [lblInstruction setText:@"Setup your Builder account with Hotmail, MSN & Live"];
//            txtEmail.text = @"mobidev9041@hotmail.com";
            provider = @"hotmail";
            break;
        case 103:
            [imgIcon setImage:[UIImage imageNamed:@"btn_facebook"]];
            [lblInstruction setText:@"Setup your Builder account with Facebook"];
//            txtEmail.text = @"xianri41@gmail.com";
            provider = @"facebook";
            break;
        case 104:
            pt = imgIcon.center;
            [imgIcon setImage:[UIImage imageNamed:@"ImportOutlook"]];
            [imgIcon setFrame:CGRectMake(0, 0, 78, 45)];
            [imgIcon setCenter:pt];
            
            [lblInstruction setText:@"Setup your Builder account with Outlook"];
//            txtEmail.text = @"ron@worktyme.onmicrosoft.com";//deleted
//            txtPassword.text = @"Pentagon1";
            txtPassword.hidden = NO;
            txtUsername.hidden = NO;
            txtWebmailLink.hidden = NO;
            txtEmail.returnKeyType = UIReturnKeyNext;
            break;
        default:
            break;
    }
}

- (void)layoutMenuLink
{
    viewBottom.hidden = YES;
    CGRect frame = viewDescription.frame;
    frame.origin.y += 48;
    [viewDescription setFrame:frame];
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (type != 104) {
        [textField resignFirstResponder];
    } else {
        if (textField == txtEmail) {
            [txtPassword becomeFirstResponder];
        } else if (textField == txtPassword) {
            [txtUsername becomeFirstResponder];
        } else if (textField == txtUsername) {
            [txtWebmailLink becomeFirstResponder];
        } else if (textField == txtWebmailLink) {
            [textField resignFirstResponder];
        }
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (!_globalData.cbIsFromMenu) {
        return YES;
    }
    if (type == 104) {
        btnDone.hidden = NO;
        btnDoneFake.hidden = NO;
        return YES;
    }
    NSString *chagedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([chagedString length]) {
        btnDoneFake.hidden = NO;
        btnDone.hidden = NO;
    } else {
        btnDoneFake.hidden = YES;
        btnDone.hidden = YES;
    }
    return YES;
}

#pragma mark - WebAPI integration
- (void)getCBOAuthURL:(NSString *)email
{
    void (^successed)(id responseObject) = ^(id responseObject) {
        NSDictionary *result = responseObject;
        
        NSLog(@"oauth url result = %@", result);
        
        if ([[result objectForKey:@"success"] boolValue]) {
            
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:@"Successed"];
            
            oAuthURL = [(NSDictionary *)[result objectForKey:@"data"] objectForKey:@"requestUrl"];
            //https://login.live.com/oauth20_authorize.srf?client_id=00000000440D4270&redirect_uri=http%3A%2F%2Fdev.xchangewith.me%2Fredirect%2Fsync%2Fcontact%2Foauth&response_type=token&scope=wl.basic%20wl.emails%20wl.contacts_emails
            //https://login.live.com/oauth20_authorize.srf?client_id=00000000440D4270&scope=wl.basic wl.emails wl.contacts_emails&response_type=code&redirect_uri=http://dev.xchangewith.me/redirect/cb/oauth
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:oAuthURL]];
            
        } else {
            NSDictionary *dictError = [result objectForKey:@"err"];
            if (dictError) {
                [SVProgressHUD showErrorWithStatus:[dictError objectForKey:@"errMsg"]];
            } else {
                [SVProgressHUD showErrorWithStatus:@"Failed to connect to server!"];
            }
        }
    };
    
    void (^failure)(NSError* error) = ^(NSError* error) {
        [SVProgressHUD showErrorWithStatus:@"Failed to connect to server!"];
    };
    
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeClear];
    [[ContactImporterClient sharedClient] getCBOAuthURL:[AppDelegate sharedDelegate].sessionId email:email provider:provider successed:successed failure:failure];
}

- (void)discoverOWA
{
    void (^successed)(id responseObject) = ^(id responseObject) {
        NSDictionary *result = responseObject;
        
        NSLog(@"discover OWA result = %@", result);
        
        if ([[result objectForKey:@"success"] boolValue]) {
            if ([[result objectForKey:@"data"] objectForKey:@"webmail_link"]) {
                NSString *webmailLink = [[result objectForKey:@"data"] objectForKey:@"webmail_link"];
                txtWebmailLink.text = webmailLink;
                [self goToCBDetailFromOWA:webmailLink];
            } else {
                txtWebmailLink.enabled = YES;
                txtEmail.enabled = NO;
                txtPassword.enabled = NO;
                [CommonMethods showAlertUsingTitle:APP_TITLE andMessage:@"Input the Webmail_link."];
            }
            
        } else {
            NSDictionary *dictError = [result objectForKey:@"err"];
            if (dictError) {
                [SVProgressHUD showErrorWithStatus:[dictError objectForKey:@"errMsg"]];
            } else {
                [SVProgressHUD showErrorWithStatus:@"Failed to connect to server!"];
            }
        }
    };
    
    void (^failure)(NSError* error) = ^(NSError* error) {
        [SVProgressHUD showErrorWithStatus:@"Failed to connect to server!"];
    };
    
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeClear];
    [[ContactImporterClient sharedClient] discoverOWAServer:[AppDelegate sharedDelegate].sessionId email:txtEmail.text password:txtPassword.text username:![txtUsername.text isEqualToString:@""] ? txtUsername.text : nil successed:successed failure:failure];
}

- (void)goToCBDetail:(NSString *)redirectURL
{
    CBEmail *curCBEmail = [[CBEmail alloc] init];
    curCBEmail.email = txtEmail.text;
    curCBEmail.authType = @"oauth";
    NSString *cbProvider;
    switch (type) {
        case 100:
            cbProvider = @"google";
            break;
        case 101:
            cbProvider = @"yahoo";
            break;
        case 102:
            cbProvider = @"hotmail";
            break;
        default:
            break;
    }
    curCBEmail.provider = cbProvider;
    CBDetailViewController *vc = [[CBDetailViewController alloc] initWithNibName:@"CBDetailViewController" bundle:nil];
    [vc setCurCBEmail:curCBEmail];
    
    //com.ginko.app://cb/redirect?code=4/RNBgR7vYwBKsU4CjL43TzmaBHRHB.kvWuTh16ROcWgrKXntQAax36cmFYjwI
    NSRange range;
    range = [redirectURL rangeOfString:@"redirect?"];
    
    NSString *code = @"";
    
    if (!(range.location == NSNotFound)) {
        code = [redirectURL substringFromIndex:range.location + range.length];
        NSLog(@"code = %@", code);
    }
    
    vc.oauth_token = code;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToCBDetailFromOWA:(NSString *)webmailLink
{
    CBEmail *curCBEmail = [[CBEmail alloc] init];
    curCBEmail.email = txtEmail.text;
    curCBEmail.authType = @"password";
    curCBEmail.username = txtUsername.text;
    curCBEmail.inserver = webmailLink;
    curCBEmail.inservertype = @"OWA";
    curCBEmail.password = txtPassword.text;
    CBDetailViewController *vc = [[CBDetailViewController alloc] initWithNibName:@"CBDetailViewController" bundle:nil];
    [vc setCurCBEmail:curCBEmail];
    
    vc.oauth_token = @"other";
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Actions
- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onDone:(id)sender
{
    [self.view endEditing:YES];
    
    if (![CommonMethods checkBlankField:[NSArray arrayWithObjects:txtEmail, nil] titles:[NSArray arrayWithObjects:@"Email Adress", nil]]) {
        return;
    }
    if (![CommonMethods checkEmail:txtEmail]) {
        return;
    }
    
    if (type == 104) {
        if (![CommonMethods checkBlankField:[NSArray arrayWithObjects:txtPassword, nil] titles:[NSArray arrayWithObjects:@"Password", nil]]) {
            return;
        }
        if (txtWebmailLink.enabled) {
            if (![CommonMethods checkBlankField:[NSArray arrayWithObjects:txtWebmailLink, nil] titles:[NSArray arrayWithObjects:@"Webmail_link", nil]]) {
                return;
            }
            [self goToCBDetailFromOWA:txtWebmailLink.text];
        }
    }
    
    if (type == 104) {
        [self discoverOWA];
    } else {
        [self getCBOAuthURL:txtEmail.text];
    }
}

- (IBAction)onNext:(id)sender
{
    [self onDone:nil];
}

- (IBAction)onSkip:(id)sender
{
    [[AppDelegate sharedDelegate] setWizardPage:@"2"];
}

@end
