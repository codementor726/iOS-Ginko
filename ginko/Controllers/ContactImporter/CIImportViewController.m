//
//  CIImportViewController.m
//  ContactImporter
//
//  Created by mobidev on 6/12/14.
//  Copyright (c) 2014 Ron. All rights reserved.
//

#import "CIImportViewController.h"
#import "ContactImporterClient.h"
#import "CISyncContactsViewController.h"

@interface CIImportViewController ()
{
    NSString *oAuthURL;
    NSString *provider;
    CGRect frmOrigin;
}
@end

@implementation CIImportViewController
@synthesize navView;
@synthesize type;
@synthesize imgIcon, lblInstruction, txtEmail, txtPassword, txtUsername, txtWebmailLink;
@synthesize viewBottom, viewDescription, btnImport;

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
    oAuthURL = @"";
    
//    if (_globalData.isFromMenu) {
        [self layoutMainLink];
//    }
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    [self.view addGestureRecognizer:gesture];
    
#ifdef DEVENV
    txtEmail.text = @"billtest73@gmail.com";
#endif
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [navView removeFromSuperview];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - configure UI
- (void)layoutMainLink
{
    viewBottom.hidden = YES;
    
    CGRect frame = viewDescription.frame;
    frame.origin.y += 50;
    viewDescription.frame = frame;
    
    btnImport.hidden = NO;
    
    if (type == 104) {
        frame = btnImport.frame;
        frame.origin.y += 130;
        btnImport.frame = frame;
    }
}

- (void)configureUI
{
    CGPoint pt;
    
    switch (type) {
        case 100:
            pt = imgIcon.center;
            [imgIcon setImage:[UIImage imageNamed:@"ImportMail"]];
            [imgIcon setFrame:CGRectMake(0, 0, 54, 39)];
            [imgIcon setCenter:pt];
            
            [lblInstruction setText:@"Import your Gmail contacts."];
//            txtEmail.text = @"jimmyw1003@gmail.com";
            provider = @"google";
            break;
        case 101:
            pt = imgIcon.center;
            [imgIcon setImage:[UIImage imageNamed:@"ImportYahoo"]];
            [imgIcon setFrame:CGRectMake(0, 0, 52, 44)];
            [imgIcon setCenter:pt];
            
            [lblInstruction setText:@"Import your Yahoo! contacts."];
//            txtEmail.text = @"mobidev9041@yahoo.com";
            provider = @"yahoo";
            break;
        case 102:
            pt = imgIcon.center;
            [imgIcon setImage:[UIImage imageNamed:@"ImportMsn"]];
            [imgIcon setFrame:CGRectMake(0, 0, 47, 48)];
            [imgIcon setCenter:pt];
            
            [lblInstruction setText:@"Import your Hotmail, MSN & Live contacts."];
//            txtEmail.text = @"mobidev9041@hotmail.com";
            provider = @"hotmail";
            break;
        case 103:
            [imgIcon setImage:[UIImage imageNamed:@"btn_facebook"]];
            [lblInstruction setText:@"Import your Facebook contacts."];
//            txtEmail.text = @"xianri41@gmail.com";
            provider = @"facebook";
            break;
        case 104:
            pt = imgIcon.center;
            [imgIcon setImage:[UIImage imageNamed:@"ImportOutlook"]];
            [imgIcon setFrame:CGRectMake(0, 0, 78, 45)];
            [imgIcon setCenter:pt];
            
            [lblInstruction setText:@"Import your Outlook contacts."];
//            txtEmail.text = @"ron@worktyme.onmicrosoft.com";
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

#pragma mark - WebAPI integration
- (void)getOAuthURL:(NSString *)email
{
    void (^successed)(id responseObject) = ^(id responseObject) {
        NSDictionary *result = responseObject;
        
        NSLog(@"oauth url result = %@", result);
        
        if ([[result objectForKey:@"success"] boolValue]) {
            
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:@"Successed"];
            
            oAuthURL = [(NSDictionary *)[result objectForKey:@"data"] objectForKey:@"requestUrl"];
            
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
    [[ContactImporterClient sharedClient] getOAuthURL:[AppDelegate sharedDelegate].sessionId email:email provider:provider successed:successed failure:failure];
}

- (void)discoverOWA
{
    void (^successed)(id responseObject) = ^(id responseObject) {
        NSDictionary *result = responseObject;
        
        NSLog(@"discover OWA result = %@", result);
        
        if ([[result objectForKey:@"success"] boolValue]) {
            
//            [SVProgressHUD dismiss];
//            [SVProgressHUD showSuccessWithStatus:@"Successed"];
            
            [self syncContactByOWA];
            
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

- (void)syncContactByOWA
{
    void (^successed)(id responseObject) = ^(id responseObject) {
        NSDictionary *result = responseObject;
        
        NSLog(@"sync OWA result = %@", result);
        
        if ([[result objectForKey:@"success"] boolValue]) {
            
            NSMutableArray *arrContacts = [[NSMutableArray alloc] init];
            NSArray *contactsArray = [result objectForKey:@"data"];
            //            NSArray *contactsArray = [[result objectForKey:@"data"] objectForKey:@"contacts"];
            for (NSDictionary *dict in contactsArray) {
                [arrContacts addObject:[[NSMutableDictionary alloc] initWithDictionary:dict]];
            }
            
            [self addToGlobalArray:arrContacts];
            
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:@"Successed"];
            
            CISyncContactsViewController *vc = [[CISyncContactsViewController alloc] initWithNibName:@"CISyncContactsViewController" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
            
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
    
//    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeClear];
    [[ContactImporterClient sharedClient] syncContactByOWA:[AppDelegate sharedDelegate].sessionId email:txtEmail.text password:txtPassword.text username:![txtUsername.text isEqualToString:@""] ? txtUsername.text : nil webMailLin:![txtWebmailLink.text isEqualToString:@""] ? txtWebmailLink.text : nil successed:successed failure:failure];
}

//unuseful
- (void)importContacts:(NSString *)redirectURL
{
    NSRange range;
    range = [redirectURL rangeOfString:@"oauth_token"];
    NSString *url = [redirectURL substringFromIndex:range.location];
    url = [NSString stringWithFormat:@"%@%@%@", SERVER_URL, @"/sync/contact/oauth?", url];
    void (^successed)(id responseObject) = ^(id responseObject) {
        NSDictionary *result = responseObject;
        
        NSLog(@"import contact result = %@", result);
        
        if ([[result objectForKey:@"success"] boolValue]) {
            
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:@"Successed"];
            
        } else {
            NSDictionary *dictError = [result objectForKey:@"err"];
            if (dictError) {
                [SVProgressHUD showErrorWithStatus:[dictError objectForKey:@"errMsg"]];
            } else {
                [SVProgressHUD showErrorWithStatus:@"Failed to connect to server!"];
            }
        }
        [self syncContactByOauth:redirectURL];
    };
    
    void (^failure)(NSError* error) = ^(NSError* error) {
        [SVProgressHUD showErrorWithStatus:@"Failed to connect to server!"];
    };
    
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeClear];
    [[ContactImporterClient sharedClient] importContactsByOauth:url successed:successed failure:failure];
}

- (void)syncContactByOauth:(NSString *)redirectURL
{
    //com.ginko.app://sync/redirect?code=4/t2LkZQb2CqtGggbUzwYL6Zi3zjio.4g5M6ypzggIWgrKXntQAax1-HNgXjwI
    NSRange range;
//    switch (type) {
//        case 100:
//        case 101:
//            range = [redirectURL rangeOfString:@"oauth_verifier"];
//            break;
//        case 102:
//            range = [redirectURL rangeOfString:@"access_token"];
//            break;
//        case 103:
//            range = [redirectURL rangeOfString:@"code"];
//            break;
//        default:
//            break;
//    }
    range = [redirectURL rangeOfString:@"redirect?"];
    
    NSString *code = @"";
    
    if (!(range.location == NSNotFound)) {
        code = [redirectURL substringFromIndex:range.location + range.length];
        NSLog(@"code = %@", code);
    }
    
    void (^successed)(id responseObject) = ^(id responseObject) {
        NSDictionary *result = responseObject;
        
        NSLog(@"sync contact result = %@", result);
        
        if ([[result objectForKey:@"success"] boolValue]) {
            
            NSMutableArray *arrContacts = [[NSMutableArray alloc] init];
            NSArray *contactsArray = [result objectForKey:@"data"];

            for (NSDictionary *dict in contactsArray) {
                [arrContacts addObject:[[NSMutableDictionary alloc] initWithDictionary:dict]];
            }
            
            [self addToGlobalArray:arrContacts];
            
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:@"Successed"];
            
            CISyncContactsViewController *vc = [[CISyncContactsViewController alloc] initWithNibName:@"CISyncContactsViewController" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
            
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
    
    if (![code isEqualToString:@""]) {
        [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeClear];
        [[ContactImporterClient sharedClient] syncContactByOAuth:[AppDelegate sharedDelegate].sessionId email:txtEmail.text provider:provider code:code successed:successed failure:failure];
    }
}

#pragma mark - Custom
- (void)addToGlobalArray:(NSMutableArray *)addContactArray
{
//    [_globalData.arrSyncContacts removeAllObjects];
    for (NSMutableDictionary *dict in addContactArray) {
        int k=0;
        for (NSMutableDictionary *g_dict in _globalData.arrSyncContacts) {
            if ([[dict objectForKey:@"contact_id"] intValue] == [[g_dict objectForKey:@"contact_id"] intValue]) {
                k++;
            }
        }
        if (k==0) {
            [_globalData.arrSyncContacts addObject:[NSMutableDictionary dictionaryWithDictionary:dict]];
        }
    }
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

#pragma mark - Actions
- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onNext:(id)sender
{
    [self.view findAndResignFirstResponder];

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
    }
    
    if (type == 104) {
        [self discoverOWA];
    } else {
        [self getOAuthURL:txtEmail.text];
    }
}


- (IBAction)onSkip:(id)sender
{
//    [[AppDelegate sharedDelegate] setWizardPage:@"2"];
}

- (IBAction)onImport:(id)sender
{
    [self onNext:nil];
}

@end
