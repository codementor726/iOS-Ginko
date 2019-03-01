//
//  EntityFollowerViewController.m
//  GINKO
//
//  Created by mobidev on 7/23/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import "EntityFollowerViewController.h"
#import "AppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>
#import "YYYCommunication.h"
#import "SVGeocoder.h"
#import "SearchAddNotesController.h"

#import "CustomTitleView.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"
#import "UIColor+HexColors.h"

#import "EntityInviteContactsViewController.h"
#import "EntityChatWallViewController.h"

#import "UIImage+Tint.h"

@interface EntityFollowerViewController ()

@end

@implementation EntityFollowerViewController

@synthesize dictEntity, isFollowing, entityID;
@synthesize isFromRequest;
@synthesize strNotes;

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
    
	[self setupUI];
    
	[self showField];
	
	// Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [scvContent setContentSize:CGSizeMake(320 * [[dictEntity objectForKey:@"Info"] count], scvContent.frame.size.height)];
}

-(void)showField
{
    btFollow.selected = isFollowing;
    btNotes.hidden = !isFollowing;
	for (UIView *view in scvContent.subviews)
	{
		if ( [view isKindOfClass:[UIView class]])
		{
			[view removeFromSuperview];
		}
	}
	
	if ([[dictEntity objectForKey:@"Video"] isEqualToString:@""])
		[btPlay setHidden:YES];
	else
		[btPlay setHidden:NO];
	
	int nYPos;
	
	if ([[dictEntity objectForKey:@"Private"] isEqualToString:@"1"])
		btInvite.hidden = NO;
	else if ([[dictEntity objectForKey:@"Private"] isEqualToString:@"0"])
		btInvite.hidden = YES;
	
    [imvBackground setImage:nil];
    NSDictionary *dictBack = [(NSDictionary *)[dictEntity objectForKey:@"images"] objectForKey:@"Background"];
    if (dictBack) {
        [imvBackground setImageWithURL:[NSURL URLWithString:[dictBack objectForKey:@"image_url"]]];
    }
	
	for (int j = 0; j < [[dictEntity objectForKey:@"Info"] count]; j++)
	{
		NSDictionary *dictInfo = [[dictEntity objectForKey:@"Info"] objectAtIndex:j];
		UIView *vwField = [[UIView alloc] initWithFrame:CGRectMake(320*j, 0, scvContent.frame.size.width, scvContent.frame.size.height)];
		UIScrollView *scvField = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, vwField.frame.size.width, vwField.frame.size.height)];
        
        vwField.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        scvField.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		
		int nMaxHeight = 0;
		
        nYPos = 20;
        
        UIImageView *imvPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(10,10, 0, 0)];
        NSDictionary *dictFore = [(NSDictionary *)[dictEntity objectForKey:@"images"] objectForKey:@"Foreground"];
        if (dictFore) {
            [imvPhoto setImageWithURL:[NSURL URLWithString:[dictFore objectForKey:@"image_url"]]];
            if ([dictFore objectForKey:@"top"] != [NSNull null] && [dictFore objectForKey:@"left"] != [NSNull null] && [dictFore objectForKey:@"width"] != [NSNull null] && [dictFore objectForKey:@"height"] != [NSNull null]) {
                [imvPhoto setFrame:CGRectMake([[dictFore objectForKey:@"left"] floatValue], [[dictFore objectForKey:@"top"] floatValue], [[dictFore objectForKey:@"width"] floatValue], [[dictFore objectForKey:@"height"] floatValue])];
            }
        }
        imvPhoto.userInteractionEnabled = YES;
        imvPhoto.tag = j * 1000 + 200;
        
        [scvField addSubview:imvPhoto];
        
        nMaxHeight = imvPhoto.frame.origin.y + imvPhoto.frame.size.height;
		
		NSMutableArray *lstField = [self sortArray:[dictInfo allKeys]];
		for (int i = 0 ; i < [lstField count]; i++)
		{
            UIButton *btnInfo = [UIButton buttonWithType:UIButtonTypeCustom];
            [btnInfo setFrame:CGRectFromString([[[dictEntity objectForKey:@"Rect"] objectAtIndex:j] objectForKey:[lstField objectAtIndex:i]])];
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, btnInfo.frame.size.width, btnInfo.frame.size.height)];
//            [btnInfo setTitleColor:[UIColor colorWithHexString:[[[dictEntity objectForKey:@"Color"] objectAtIndex:j] objectForKey:[lstField objectAtIndex:i]]] forState:UIControlStateNormal];
            [titleLabel setTextColor:[UIColor colorWithHexString:[[[dictEntity objectForKey:@"Color"] objectAtIndex:j] objectForKey:[lstField objectAtIndex:i]]]];
            NSString *font = [[[dictEntity objectForKey:@"Font"] objectAtIndex:j] objectForKey:[lstField objectAtIndex:i]];
//            [btnInfo.titleLabel setFont:[UIFont fontWithName:[font substringToIndex:[font rangeOfString:@":"].location] size:[[font substringFromIndex:[font rangeOfString:@":"].location + 1] floatValue]]];
            NSArray *components = [font componentsSeparatedByString:@":"];
            [titleLabel setFont:[UIFont fontWithName:components[0] size:[components[1] floatValue]]];
//            [btnInfo setTitle:[dictInfo objectForKey:[lstField objectAtIndex:i]] forState:UIControlStateNormal];
            [titleLabel setText:[dictInfo objectForKey:[lstField objectAtIndex:i]]];
//            btnInfo.titleLabel.numberOfLines = 1;
            titleLabel.numberOfLines = 1;
            
//            if ([[lstField objectAtIndex:i] isEqualToString:@"Address"] || [[lstField objectAtIndex:i] isEqualToString:@"Address#2"] || [[lstField objectAtIndex:i] isEqualToString:@"Hours"])
//			{
				titleLabel.numberOfLines = 0;
				
				NSAttributedString *atrText = [[NSAttributedString alloc] initWithString:titleLabel.text attributes:@{NSFontAttributeName:titleLabel.font}];
				CGRect labelRect = [atrText boundingRectWithSize:CGSizeMake(280, 10000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
            
                [titleLabel setFrame:CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y, labelRect.size.width, labelRect.size.height)];
            
            [titleLabel sizeToFit];
//			}
            
            [scvField addSubview:btnInfo];
            
            if ((btnInfo.frame.origin.y + btnInfo.frame.size.height) > nMaxHeight)
				nMaxHeight = btnInfo.frame.origin.y + btnInfo.frame.size.height;
            
            if ([[dictEntity objectForKey:@"Abbr"] isEqualToString:@"1"])
			{
				if (![@[@"Name",@"Keysearch",@"Hours",@"Address",@"Address#2",@"Custom",@"Custom#2",@"Custom#3"] containsObject:[lstField objectAtIndex:i]])
				{
                    [titleLabel setText:[NSString stringWithFormat:@"%@. %@",[[[lstField objectAtIndex:i] substringToIndex:1] lowercaseString],titleLabel.text]];
					[titleLabel sizeToFit];
				}
			}
            
            titleLabel.tag = 300;
            [btnInfo addSubview:titleLabel];
            
            if ([[lstField objectAtIndex:i] isEqualToString:@"Email"] || [[lstField objectAtIndex:i] isEqualToString:@"Email#2"])
            {
                btnInfo.tag = 101; //Email
            } else if ([[lstField objectAtIndex:i] isEqualToString:@"Mobile"] || [[lstField objectAtIndex:i] isEqualToString:@"Mobile#2"] || [[lstField objectAtIndex:i] isEqualToString:@"Phone"]|| [[lstField objectAtIndex:i] isEqualToString:@"Phone#2"]|| [[lstField objectAtIndex:i] isEqualToString:@"Phone#3"])
            {
                btnInfo.tag = 102; //Phone
            } else if ([[lstField objectAtIndex:i] isEqualToString:@"Address"] || [[lstField objectAtIndex:i] isEqualToString:@"Address#2"])
            {
                btnInfo.tag = 103; //Address
            } else if ([[lstField objectAtIndex:i] isEqualToString:@"Website"])
            {
                btnInfo.tag = 104; //Website
            } else {
                btnInfo.tag = 100; //Normal
            }
            
            if (btnInfo.tag > 100) {
                [btnInfo addTarget:self action:@selector(onBtnDetail:) forControlEvents:UIControlEventTouchUpInside];
            }            
            
//			UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectFromString([[[dictEntity objectForKey:@"Rect"] objectAtIndex:j] objectForKey:[lstField objectAtIndex:i]])];
//			[lbl setTextColor:[UIColor colorWithHexString:[[[dictEntity objectForKey:@"Color"] objectAtIndex:j] objectForKey:[lstField objectAtIndex:i]]]];
//			NSString *font = [[[dictEntity objectForKey:@"Font"] objectAtIndex:j] objectForKey:[lstField objectAtIndex:i]];
//			[lbl setFont:[UIFont fontWithName:[font substringToIndex:[font rangeOfString:@":"].location] size:[[font substringFromIndex:[font rangeOfString:@":"].location + 1] floatValue]]];
			
//			[lbl setText:[dictInfo objectForKey:[lstField objectAtIndex:i]]];
//			[lbl setTag:j * 1000 + 100 + i];
//			lbl.numberOfLines = 1;
//			lbl.userInteractionEnabled = YES;
            
//			if ([[lstField objectAtIndex:i] isEqualToString:@"Address"] || [[lstField objectAtIndex:i] isEqualToString:@"Address#2"] || [[lstField objectAtIndex:i] isEqualToString:@"Hours"])
//			{
//				lbl.numberOfLines = 0;
//				
//				NSAttributedString *atrText = [[NSAttributedString alloc] initWithString:lbl.text attributes:@{NSFontAttributeName:lbl.font}];
//				CGRect labelRect = [atrText boundingRectWithSize:CGSizeMake(280, 10000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
//
//				if (labelRect.size.height < lbl.frame.size.height)
//				{
//					CGRect rt = lbl.frame;
//					rt.size.height = labelRect.size.height;
//					[lbl setFrame:rt];
//				}
//			}
			
//			[scvField addSubview:lbl];
			
//			if ((lbl.frame.origin.y + lbl.frame.size.height) > nMaxHeight)
//				nMaxHeight = lbl.frame.origin.y + lbl.frame.size.height;
			
//			if ([[dictEntity objectForKey:@"Abbr"] isEqualToString:@"1"])
//			{
//				if (![@[@"Name",@"Keysearch",@"Hours",@"Address",@"Address#2",@"Custom",@"Custom#2",@"Custom3"] containsObject:[lstField objectAtIndex:i]])
//				{
//					[lbl setText:[NSString stringWithFormat:@"%@. %@",[[[lstField objectAtIndex:i] substringToIndex:1] lowercaseString],lbl.text]];
//					[lbl sizeToFit];
//				}
//			}
		}
		
		[scvField setContentSize:CGSizeMake(320, nMaxHeight + 30)];
		[vwField addSubview:scvField];
		[scvContent addSubview:vwField];
	}
	
	[scvContent setContentSize:CGSizeMake(320 * [[dictEntity objectForKey:@"Info"] count], scvContent.frame.size.height)];
	
	NSString *title = @"Location";
	if ([[dictEntity objectForKey:@"Info"] count] > 1)
		title = [NSString stringWithFormat:@"%d Locations",(int)[[dictEntity objectForKey:@"Info"] count]];
	
	CustomTitleView *titleView = [CustomTitleView entityView:title];
	[self.navigationItem setTitleView:titleView];
}

-(NSMutableArray*)sortArray:(NSArray*)lstKey
{
	NSMutableArray *lstOrder = [[NSMutableArray alloc] initWithObjects:@"Name",@"Address",@"Address#2",@"Hours",@"Mobile",@"Mobile#2",@"Phone",@"Phone#2",@"Phone#3",@"Fax",@"Email",@"Email#2",@"Birthday",@"Facebook",@"Twitter",@"Website",@"Custom",@"Custom#2",@"Custom#3", nil];
	
	NSMutableArray *lstSelected = [[NSMutableArray alloc] init];
	
	for (int i = 0; i < [lstOrder count]; i++)
	{
		if (![lstKey containsObject:[lstOrder objectAtIndex:i]])
		{
			[lstSelected addObject:[lstOrder objectAtIndex:i]];
		}
	}
	
	for (int i = 0; i < [lstSelected count]; i++)
	{
		[lstOrder removeObject:[lstSelected objectAtIndex:i]];
	}
	
	return lstOrder;
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:NO];
}

-(void)setupUI
{
	UIButton *btBack = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImageView *imvBackBtn = [[UIImageView alloc] initWithFrame:CGRectMake(0, 7, 13, 21)];
    imvBackBtn.image = [UIImage imageNamed:@"BackArrow"];
	[btBack setFrame:CGRectMake(0, 0, 35, 35)];
    [btBack addSubview:imvBackBtn];
	[btBack addTarget:self action:@selector(btHomeClick:) forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *btBarBack = [[UIBarButtonItem alloc] initWithCustomView:btBack];
	[self.navigationItem setLeftBarButtonItem:btBarBack];
    
//    if (!self.isFromOwnWall) {
        UIButton *btWall = [UIButton buttonWithType:UIButtonTypeCustom];
        [btWall setImage:[UIImage imageNamed:@"btn_wall"] forState:UIControlStateNormal];
        [btWall setFrame:CGRectMake(0, 0, 35, 29)];
        [btWall addTarget:self action:@selector(btWallClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *btBarWall = [[UIBarButtonItem alloc] initWithCustomView:btWall];
        [self.navigationItem setRightBarButtonItem:btBarWall];
//    }
    [btInvite setImage:[[UIImage imageNamed:@"Invite"] tintImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
}

#pragma mark - Web API integration
-(void)followEntity
{
	void ( ^successed )( id _responseObject ) = ^( id _responseObject )
	{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary *result = _responseObject;
        if ([[result objectForKey:@"success"] boolValue]) {
            isFollowing = YES;
            btFollow.selected = isFollowing;
            btNotes.hidden = !isFollowing;
            
        } else {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
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
    
    [[YYYCommunication sharedManager] FollowEntity:[AppDelegate sharedDelegate].sessionId entityid:entityID successed:successed failure:failure];
}

-(void)unFollowEntity
{
	void ( ^successed )( id _responseObject ) = ^( id _responseObject )
	{
        NSDictionary *result = _responseObject;
        if ([[result objectForKey:@"success"] boolValue]) {
            isFollowing = NO;
            btFollow.selected = isFollowing;
            btNotes.hidden = !isFollowing;
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
        } else {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
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
		[CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Internet Connection Error!"];
	};
	
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[YYYCommunication sharedManager] UnFollowEntity:[AppDelegate sharedDelegate].sessionId entityid:entityID successed:successed failure:failure];
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        if (alertView.tag == 1) {
            [self followEntity];
        } else if (alertView.tag == 2) {
            [self unFollowEntity];
        }
    }
}

#pragma mark - Actions
-(IBAction)btHomeClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
//    if (isFromRequest) {
//        [self.navigationController popViewControllerAnimated:YES];
//    } else {
//        [self.navigationController popToRootViewControllerAnimated:YES];
//    }
}

-(IBAction)btWallClick:(id)sender
{
    EntityChatWallViewController *vc = [[EntityChatWallViewController alloc] initWithNibName:@"EntityChatWallViewController" bundle:nil];
    vc.entityID = entityID;
    vc.entityName = [dictEntity objectForKey:@"Name"];
    vc.entityImageURL = [dictEntity objectForKey:@"profile_image"];
    vc.isFromProfile = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

-(IBAction)btFollowClick:(id)sender;
{
    NSString *msg;
    msg = [NSString stringWithFormat:@"Do you want to %@ this entity?", isFollowing ? @"unfollow" : @"follow"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.tag = isFollowing ? 2 : 1;
    [alert show];
}


-(IBAction)btInviteClick:(id)sender
{
    EntityInviteContactsViewController *vc = [[EntityInviteContactsViewController alloc] initWithNibName:@"EntityInviteContactsViewController" bundle:nil];
    vc.entityID = entityID;
    [self.navigationController pushViewController:vc animated:YES];
}

-(IBAction)btPlayClick:(id)sender
{
    MPMoviePlayerViewController *movieController = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[dictEntity objectForKey:@"Video"]]];
	[self presentMoviePlayerViewControllerAnimated:movieController];
	[movieController.moviePlayer play];
}

-(IBAction)btNotesClick:(id)sender
{
    SearchAddNotesController *controller = [[SearchAddNotesController alloc] initWithNibName:@"SearchAddNotesController" bundle:nil];
    controller.parentController = self;
    controller.strNotes = strNotes;
    controller.entityID = entityID;
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)onBtnDetail:(id)sender
{
    NSString *str = @"";
    
    str = [(UILabel *)[(UIButton *)sender viewWithTag:300] text];
    
    if ([[dictEntity objectForKey:@"Abbr"] intValue]) {
        str = [str substringFromIndex:3];
    }
    
    if ([sender tag] == 101)    // Email
    {
        [self sendMail:str];
    }
    else if ([sender tag] == 102)   // Phone
    {
        NSLog(@"Action Phone!!");
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [CommonMethods removeNanString:str]]]];
    }
    else if ([sender tag] == 103)   // Address
    {
        NSLog(@"Action Address!!");
        [self navigateToMap:str];
    } else if ([sender tag] == 104)  // Website
    {
        if (![[str substringToIndex:4] isEqualToString:@"http"]) {
            str = [NSString stringWithFormat:@"http://%@", str];
        }
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }
}

#pragma mark - Detail Functions
- (void)sendMail:(NSString *)_email
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    
    if ([mailClass canSendMail])
        [self displayComposerSheet: _email];
}

-(void)displayComposerSheet : (NSString *)email
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:@""];
    
	// Set up recipients
	NSArray *toRecipients = [NSArray arrayWithObjects:email, nil];
	NSArray *ccRecipients = [NSArray arrayWithObject:@""];
	NSArray *bccRecipients = [NSArray arrayWithObject:@""];
	
	[picker setToRecipients:toRecipients];
	[picker setCcRecipients:ccRecipients];
	[picker setBccRecipients:bccRecipients];
    
	[picker setMessageBody:@"" isHTML:YES];
	
	[self presentViewController:picker animated:YES completion:nil];
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    NSString * messageResult ;
	switch (result)
	{
		case MFMailComposeResultCancelled:
			messageResult = @"Mail cancelled.";
			break;
		case MFMailComposeResultSaved:
			messageResult = @"Mail saved.";
			break;
		case MFMailComposeResultSent:
            messageResult = @"Mail successfully sent";
            [[[UIAlertView alloc] initWithTitle: nil message:messageResult delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
			break;
		case MFMailComposeResultFailed:
			messageResult = @"Mail failed.";
			break;
		default:
			messageResult = @"Mail don't send.";
			break;
	}
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)navigateToMap:(NSString *)address
{
    //    NSString *str = @"213 Main Street Ann Arbor, MI 48105";
    //    str = @"7617 Brookview Drive Brighton, MI 48116";
    //    address = str;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [ MBProgressHUD showHUDAddedTo:self.view animated:YES] ;
    [geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
        [ MBProgressHUD hideHUDForView : self.view animated : YES ] ;
        if (error) {
            NSLog(@"%@", error);
            [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Oh no!  Cannot find the location from the address!"];
        } else {
            
            CLPlacemark *placeMark = [placemarks lastObject];
            
            [self openAppleMap:placeMark.location.coordinate.latitude :placeMark.location.coordinate.longitude];
            
            /*CLLocationCoordinate2D pingLocation;
             pingLocation.latitude = placeMark.location.coordinate.latitude; //40.7127; //42.342793;//[[contactInfo objectForKey:@"latitude"] floatValue];
             pingLocation.longitude =placeMark.location.coordinate.longitude; //74.0509; //124.405383;//[[contactInfo objectForKey:@"longitude"] floatValue];
             MapViewController * controller = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
             controller.pingLocation = pingLocation;
             controller.locationName = address;
             [self.navigationController pushViewController:controller animated:YES];*/
        }
    }];
}

- (void)openAppleMap:(float)latitude :(float)longitude
{
    [SVGeocoder reverseGeocode:CLLocationCoordinate2DMake(latitude, longitude)
                    completion:^(NSArray *placemarks, NSHTTPURLResponse *urlResponse, NSError *error)
     {
         if (!error)
         {
             MKPlacemark *place = [[MKPlacemark alloc]
                                   initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude)
                                   addressDictionary:nil];
             
             MKMapItem *mapItem = [[MKMapItem alloc]initWithPlacemark:place];
             [mapItem setName:[NSString stringWithFormat:@"%@",[(SVPlacemark*)[placemarks objectAtIndex:0] formattedAddress]]];
             [mapItem openInMapsWithLaunchOptions:nil];
         } else {
             [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Internet Connection Error!"];
         }
         
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
