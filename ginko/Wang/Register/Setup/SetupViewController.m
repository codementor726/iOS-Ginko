//
//  SetupViewController.m
//  Xchangewithme
//
//  Created by Xin YingTai on 20/5/14.
//  Copyright (c) 2014 Xin YingTai. All rights reserved.
//

#import "SetupViewController.h"
#import "PhotoPickerController.h"
#import "VideoPickerController.h"
#import "AppDelegate.h"
#import "YYYCommunication.h"
#import "MBProgressHUD.h"
#import "UIView+Borders.h"
#import "WelcomeViewController.h"
#import "ManageProfileViewController.h"

@interface SetupViewController ()

@end

@implementation SetupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // make three buttons to top image and bottom text
    [self makeImageTopTextBottomButton:_homeButton];
    [self makeImageTopTextBottomButton:_workButton];
    [self makeImageTopTextBottomButton:_bothButton];
    
    // set highlighted color
    _homeButton.bgColor = _workButton.bgColor = _bothButton.bgColor = [UIColor whiteColor];
    
    // reset global appearance
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBarTintColor:COLOR_PURPLE_THEME];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    WelcomeViewController *vc = [[WelcomeViewController alloc] initWithNibName:@"WelcomeViewController" bundle:nil];
    [vc presentWindow];
}

- (void)removeAllSublayers:(UIView *)view {
//    for (CALayer *layer in [view.layer.sublayers copy]) {
//        [layer removeFromSuperlayer];
//    }
}

- (void)viewDidLayoutSubviews {
    // remove old borders
    [self removeAllSublayers:_homeButton];
    [self removeAllSublayers:_workButton];
    [self removeAllSublayers:_bothButton];
    
    // add borders
    [_homeButton addTopBorderWithHeight:0.5 andColor:[UIColor colorWithWhite:229.f/255 alpha:1]];
    [_homeButton addBottomBorderWithHeight:0.5 andColor:[UIColor colorWithWhite:229.f/255 alpha:1]];
    [_workButton addBottomBorderWithHeight:0.5 andColor:[UIColor colorWithWhite:229.f/255 alpha:1]];
    [_bothButton addBottomBorderWithHeight:0.5 andColor:[UIColor colorWithWhite:229.f/255 alpha:1]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//- (void)photoPickerController:(PhotoPickerController *)pickerController didSelectImage:(UIImage *)background avatar:(UIImage *)avatar frame:(CGRect)frame {
//	[MBProgressHUD showHUDAddedTo:[AppDelegate sharedDelegate].window animated:YES];
//	
//	void ( ^successed )( id _responseObject ) = ^( id _responseObject )
//	{
//		[MBProgressHUD hideAllHUDsForView:[AppDelegate sharedDelegate].window animated:YES];
//		
//		NSLog(@"Home Photo Uploaded Successfully");
//		
//		NSMutableArray *response = [_responseObject objectForKey:@"data"];
//		
//		[pickerController dismissViewControllerAnimated:NO completion:^{
//			
//			[[AppDelegate sharedDelegate].dictInfoHome setObject:[UIImage imageNamed:@"img_userphoto"]		forKey:@"Photo"];
//			[[AppDelegate sharedDelegate].dictInfoHome setObject:[UIImage imageNamed:@"img_profilebackground"] forKey:@"Background"];
//			
//			YYYHomeInfoInputViewController *viewcontroller = [[YYYHomeInfoInputViewController alloc] initWithNibName:@"YYYHomeInfoInputViewController" bundle:nil];
//            
//			if (avatar)
//			{
//				[[AppDelegate sharedDelegate].dictInfoHome setObject:avatar		forKey:@"Photo"];
//			}
//			if (background)
//			{
//				[[AppDelegate sharedDelegate].dictInfoHome setObject:background		forKey:@"Background"];
//			}
//            
//            NSMutableDictionary *dictImage = [[NSMutableDictionary alloc] init];
//            
//            if ([response count]) {
//                NSDictionary *dict = [response objectAtIndex:0];
//                [dictImage setObject:dict forKey:@"Background"];
//            }
//            if ([response count] > 1) {
//                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[response objectAtIndex:1]];
//                [dict setObject:[NSString stringWithFormat:@"%f", frame.origin.x] forKey:@"left"];
//                [dict setObject:[NSString stringWithFormat:@"%f", frame.origin.y] forKey:@"top"];
//                [dict setObject:[NSString stringWithFormat:@"%f", frame.size.width] forKey:@"width"];
//                [dict setObject:[NSString stringWithFormat:@"%f", frame.size.height] forKey:@"height"];
//                [dictImage setObject:dict forKey:@"Foreground"];
//            }
//            
//            [[AppDelegate sharedDelegate].dictInfoHome setObject:dictImage forKey:@"Images"];
//			
//			[self.navigationController pushViewController:viewcontroller animated:NO];
//		}];
//	} ;
//    
//    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
//	{
//		[MBProgressHUD hideAllHUDsForView:[AppDelegate sharedDelegate].window animated:YES];
//		
//		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oh no!" message:@"Failed to upload photos. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//		[alert show];
//		return;
//    } ;
//	
//	
//	[[YYYCommunication sharedManager] UploadMultipleImages:[AppDelegate sharedDelegate].sessionId type:@"1" background:UIImageJPEGRepresentation(background, 0.2) foreground:UIImageJPEGRepresentation(avatar, 0.2) successed:successed failure:failure];
//}
//
//- (void)photoPickerControllerDidCancel:(PhotoPickerController *)pickerController
//{
//    [pickerController dismissViewControllerAnimated:NO completion:^{
//		
//		[[AppDelegate sharedDelegate].dictInfoHome setObject:[UIImage imageNamed:@"img_userphoto"]		forKey:@"Photo"];
//		[[AppDelegate sharedDelegate].dictInfoHome setObject:[UIImage imageNamed:@"img_profilebackground"] forKey:@"Background"];
//		
//        YYYHomeInfoInputViewController *viewcontroller = [[YYYHomeInfoInputViewController alloc] initWithNibName:@"YYYHomeInfoInputViewController" bundle:nil];
//		[self.navigationController pushViewController:viewcontroller animated:NO];
//    }];
//}
//
//- (IBAction)onBtnGetStarted:(id)sender
//{
//    PhotoPickerController *viewController = [[PhotoPickerController alloc] initWithType:4 entityID:nil];
//    viewController.pickerDelegate = self;
//    [self presentViewController:viewController animated:NO completion:^{
//        
//    }];
//}

#pragma mark - Make UIButton top image and bottom text
- (void)makeImageTopTextBottomButton:(UIButton *)button

{
    // the space between the image and text
    CGFloat spacing = 6.0;
    
    // lower the text and push it left so it appears centered
    //  below the image
    CGSize imageSize = button.imageView.image.size;
    button.titleEdgeInsets = UIEdgeInsetsMake(0.0, -imageSize.width, -(imageSize.height + spacing), 0.0);
    
    // raise the image and push it right so it appears centered
    //  above the text
    CGSize titleSize = [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: button.titleLabel.font}];
    button.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
    
}

- (IBAction)createPersonal:(id)sender {
    ManageProfileViewController *vc = [[ManageProfileViewController alloc] initWithNibName:@"ManageProfileViewController" bundle:nil];
    vc.isCreate = YES;
    vc.isWork = NO;
    vc.isSecond = NO;
    vc.mode = ProfileModePersonal;
    vc.userData = nil;
    vc.isSetup = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)createWork:(id)sender {
    ManageProfileViewController *vc = [[ManageProfileViewController alloc] initWithNibName:@"ManageProfileViewController" bundle:nil];
    vc.isCreate = YES;
    vc.isWork = YES;
    vc.isSecond = NO;
    vc.mode = ProfileModeWork;
    vc.userData = nil;
    vc.isSetup = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)createBoth:(id)sender {
    ManageProfileViewController *vc = [[ManageProfileViewController alloc] initWithNibName:@"ManageProfileViewController" bundle:nil];
    vc.isCreate = YES;
    vc.isWork = NO;
    vc.isSecond = NO;
    vc.mode = ProfileModeBoth;
    vc.userData = nil;
    vc.isSetup = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
