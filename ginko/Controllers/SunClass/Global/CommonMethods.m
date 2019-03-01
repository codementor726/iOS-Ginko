
//  CommonMethods.m
//  ReactChat
//
//  Created by mobidev on 5/16/14.
//

#import "CommonMethods.h"
#import <QuartzCore/QuartzCore.h>
#import "Global.h"
#import "LocalDBManager.h"
#import "UIImageView+AFNetworking.h"
@implementation CommonMethods

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    return self;
}

+ (void)showAlertUsingTitle:(NSString *)titleString andMessage:(NSString *)messageString {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:titleString message:messageString delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
    [alert release];
}
+ (void) showLoadingView:(UIView *) toView title:(NSString *) title andDescription:(NSString *)desc {
  dispatch_async(dispatch_get_main_queue(), ^{
    //some UI methods ej
     UIView *tempView = [CommonMethods addLoadingViewWithTitle:title andDescription:desc];
    [toView addSubview:tempView];
  });
}

+ (void) removeLoadingView:(UIView *) myView {
  
  NSArray *tempArray = [[myView subviews] copy];
  for (UIView*tempView in tempArray) {
    if (tempView.tag == 2000) {
      
      dispatch_async(dispatch_get_main_queue(), ^{
        [tempView removeFromSuperview];
      });
    }
  }
  [tempArray release];
}

+ (UIView *) addLoadingViewWithTitle:(NSString *)title
					 andDescription:(NSString *)description
{
	UIView *backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	backGroundView.backgroundColor = [UIColor clearColor];
	backGroundView.tag = 2000;
	backGroundView.alpha = 0.9;
  
	UIView *loadingView = [[UIView alloc] initWithFrame:CGRectMake(40, 145, 240, 110)];
	loadingView.backgroundColor = [UIColor blackColor];
	[loadingView.layer setCornerRadius:6.0];
	[loadingView.layer setBorderWidth:2.0];
	[loadingView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
	
	UILabel  *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 7, 200, 30)];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.text = [NSString stringWithFormat:@"%@",title];
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.font = [UIFont boldSystemFontOfSize:16];
	
	UILabel  *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 37, 240, 1)];
	lineLabel.backgroundColor = [UIColor lightGrayColor];
  
	UILabel  *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(34, 30, 200, 60)];
	descriptionLabel.backgroundColor = [UIColor clearColor];
	descriptionLabel.numberOfLines = 3;
	descriptionLabel.text = [NSString stringWithFormat:@"%@",description];
	descriptionLabel.textColor = [UIColor whiteColor];
  
	if ([description length] < 50) {
		descriptionLabel.font = [UIFont systemFontOfSize:15];
		loadingView.frame = CGRectMake(40, 145, 240, 90);
	}
	else {
		descriptionLabel.font = [UIFont systemFontOfSize:13];
		loadingView.frame = CGRectMake(40, 145, 240, 95);
	}
	UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc]
													  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	
	activityIndicatorView.center = CGPointMake(15, 62);
	[activityIndicatorView startAnimating];
  
  [loadingView addSubview:titleLabel];
  [loadingView addSubview:lineLabel];
  [loadingView addSubview:descriptionLabel];
  [loadingView addSubview:activityIndicatorView];
  [backGroundView addSubview:loadingView];
  

  [titleLabel release];
	[lineLabel release];
	[loadingView release];
	[descriptionLabel release];
	[activityIndicatorView release];
  
 	return [backGroundView autorelease];
}

+ (NSNumber *)getCurrentUserID {
 // DEBUGLog(@"Current UserID %d",[[[NSUserDefaults standardUserDefaults] objectForKey:@"ID"] intValue]);
    int userId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ID"] intValue];
    NSNumber *userIDNumber = [NSNumber numberWithInt:userId];
    return userIDNumber;
    
}

+ (NSString *)getVersionNumber {
    NSString * appVersionString = [[NSBundle mainBundle] 
                                   objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSLog(@"app version no. is:%@",appVersionString);
    return appVersionString;
}


+ (void) changeUserImage:(NSDictionary *)responseDictionary{
     
    [[NSUserDefaults standardUserDefaults]setObject:[responseDictionary objectForKey:@"pimage"] forKey:@"userProfileImage"];
}

+ (NSString *)getUserImage{
  NSString *imageString = [[[[NSUserDefaults standardUserDefaults]objectForKey:@"userProfileImage"] retain] autorelease];
    return imageString;
    
}

+ (NSString *)convertToXMLEntities:(NSString *)myString {
    NSMutableString * temp = [myString mutableCopy];
    
    [temp replaceOccurrencesOfString:@"&"
                          withString:@"&amp;"
                             options:0
                               range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"<"
                          withString:@"&lt;"
                             options:0
                               range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@">"
                          withString:@"&gt;"
                             options:0
                               range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"\""
                          withString:@"&quot;"
                             options:0
                               range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"'"
                          withString:@"&apos;"
                             options:0
                               range:NSMakeRange(0, [temp length])];
    
    return temp;
}

+ (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding strValue:(NSString *)strValue {
	return (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                               (CFStringRef)strValue,
                                                               NULL,
                                                               (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                               CFStringConvertNSStringEncodingToEncoding(encoding));
}

+ (BOOL)checkEmail:(UITextField *)checkText
{
    /*
    BOOL filter = YES ;
    NSString *filterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = filter ? filterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    if([emailTest evaluateWithObject:checkText.text] == NO)
    {
        [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Please input a valid email address."];
        return NO ;
    }
    
    return YES ;*/
    
    return [CommonMethods checkEmailAddress:checkText.text];
}

+ (BOOL)checkEmailAddress:(NSString *)email
{
    BOOL filter = YES ;
    NSString *filterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,99}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = filter ? filterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    if([emailTest evaluateWithObject:email] == NO)
    {
        [CommonMethods showAlertUsingTitle:@"Error" andMessage:@"Please input a valid email address."];
        return NO ;
    }
    
    return YES ;
}

+ (BOOL)checkBlankField:(NSArray *)txtArray titles:(NSArray *)titleArray
{   
    UITextField *textField = nil;
    NSString *textTitle = nil;
    
    NSInteger nInx = 0;
    NSInteger nCnt = 0;
    
    for(nInx = 0, nCnt = [txtArray count]; nInx<nCnt; nInx++ )
    {
        textField = [txtArray objectAtIndex:nInx];
        textTitle = [titleArray objectAtIndex:nInx];
        
        if([textField.text isEqualToString:@""])
        {
            [CommonMethods showAlertUsingTitle:@"Error" andMessage:[NSString stringWithFormat:@"%@ can not be blank. Please try again.", textTitle]];
            return NO ;
        }
    }
    
    return YES ;
}

+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size
{
    UIImage *img = nil;

    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);//
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,
                                   color.CGColor);
    CGContextFillRect(context, rect);

    img = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return img;
}

+ (NSDate *)str2date:(NSString *)dateString withFormat:(NSString *)formatString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatString];
    return [dateFormatter dateFromString:dateString];
}

+ (NSString *)date2str:(NSDate *)convertDate withFormat:(NSString *)formatString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatString];
    
    return [dateFormatter stringFromDate:convertDate];
}

+ (NSString*)date2localtimestr:(NSString*)str {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [formatter setTimeZone :[NSTimeZone timeZoneForSecondsFromGMT: 0]];
    NSDate *utcdate = [formatter dateFromString:[NSString stringWithFormat:@"%@",str]];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    NSDate *date = [formatter dateFromString:[formatter stringFromDate:utcdate]];
    return [self date2str:date withFormat:@"MMM dd, yyyy,  hh:mm a"];
}

+ (NSDate*)str2UTCDate:(NSString*)string {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    return [dateFormatter dateFromString:string];
}

+ (BOOL)isToday:(NSString *)compareDateString
{
    NSDate *compareDate = [CommonMethods str2date:compareDateString withFormat:@"YYYY-MM-DD"];
    NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:compareDate];
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    if([today day] == [otherDay day] &&
       [today month] == [otherDay month] &&
       [today year] == [otherDay year] &&
       [today era] == [otherDay era]) {
        return YES;
    }
    return NO;
}

+ (void)fitViewFrame:(UIView *)view offset:(CGFloat)offset
{
    [UIView animateWithDuration:0.15f animations:^(void){
        CGRect frame = view.frame;
        frame.origin.y = 0;
        frame.origin.y -= offset;
        [view setFrame:frame];
    }];
}

+ (NSString *)removeNanString:(NSString *)origString
{
    return [[origString componentsSeparatedByCharactersInSet:
                            [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                           componentsJoinedByString:@""];
}

+ (NSString *)encodedURLString:(NSString *)str
{
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[str UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}
+ (void)loadAvaiableEntity{
    [[Communication sharedManager] SyncUpdatedOfEntity:SESSIONID successed:^(id _responseObject) {
        
        NSLog(@"response---%@",_responseObject);
        NSDictionary *data = [_responseObject objectForKey:@"data"];
        
        NSManagedObjectContext *context = [AppDelegate sharedDelegate].managedObjectContext;
        
        NSFetchRequest *allContacts = [[NSFetchRequest alloc] init];
        [allContacts setEntity:[NSEntityDescription entityForName:@"LocationOfEntity" inManagedObjectContext:context]];
        
        NSError *error = nil;
        NSArray *contacts = [context executeFetchRequest:allContacts error:&error];
        NSInteger timestamp = [[NSDate date] timeIntervalSince1970];
        
        // remove contacts
        NSMutableArray *removedEntities = [data objectForKey:@"removed_entities"];
        for (int i = 0; i < [removedEntities count]; i++) {
            id entityIdForRemove;
            entityIdForRemove = [removedEntities objectAtIndex:i];
            NSArray *foundLocations = [contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"entity_Id == %@", entityIdForRemove]];
            if (foundLocations.count > 0) {
                for (LocationOfEntity *deleteLocation in foundLocations) {
                    [context deleteObject:deleteLocation];
                }
                NSError *saveError = nil;
                [context save:&saveError];
                if (saveError) {
                    NSLog(@"Error when saving managed object context : %@", saveError);
                }
            }
            
        }
        
        
        // add or edit contacts
        for (NSDictionary * entityDict in data[@"entities"]) {
            id entityId;
            entityId = entityDict[@"entity_id"];
            
            // remove contacts
            NSArray *foundLocations = [contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"entity_Id == %@", entityId]];
            if (foundLocations.count > 0) {
                for (LocationOfEntity *deleteLocation in foundLocations) {
                    [context deleteObject:deleteLocation];
                }
            }
            NSError *saveError = nil;
            [context save:&saveError];
            if (saveError) {
                NSLog(@"Error when saving managed object context : %@", saveError);
            }
            
            if (entityDict[@"infos"] && [entityDict[@"infos"] count] > 0) {
                for (NSDictionary * locationInfo in entityDict[@"infos"]) {
                    LocationOfEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:@"LocationOfEntity" inManagedObjectContext:context];
                    entity.entity_Id = entityId;
                    entity.first_name = entityDict[@"name"];
                    entity.profile_image = entityDict[@"profile_image"];
                    
                    NSString *profileImageUrl = entityDict[@"profile_image"];
                    
                    if (profileImageUrl && ![profileImageUrl isEqualToString:@""] && [profileImageUrl rangeOfString:@"no-face"].location == NSNotFound) {
                        NSString *localFilePath = [LocalDBManager checkCachedFileExist:profileImageUrl];
                        UIImageView * _tempProfileImageView;
                        if (!localFilePath) {
                            _tempProfileImageView = [UIImageView new];
                            [_tempProfileImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:profileImageUrl]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                [LocalDBManager saveImage:image forRemotePath:profileImageUrl];
                            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                NSLog(@"Failed to load profile image");
                            }];
                        }
                    }
                    
                    if (locationInfo[@"address_confirmed"] && [locationInfo[@"address_confirmed"] boolValue]) {
                        if (locationInfo[@"latitude"] && locationInfo[@"longitude"] && ![[NSString stringWithFormat:@"%@",locationInfo[@"latitude"]]isEqualToString:@"<null>"] && ![[NSString stringWithFormat:@"%@",locationInfo[@"longitude"]] isEqualToString:@"<null>"]) {
                            entity.latitude = @([locationInfo[@"latitude"] floatValue]);
                            entity.longitude = @([locationInfo[@"longitude"] floatValue]);
                        }else{
                            entity.latitude = @0;
                            entity.longitude = @0;
                        }
                    }
                    
                    entity.timestamp = @(timestamp);
                    NSMutableDictionary *dictData = [[NSMutableDictionary alloc] init];
                    
                    [dictData setValue:entityDict[@"entity_id"] forKey:@"entity_id"];
                    [dictData setValue:entityDict[@"profile_image"] forKey:@"profile_image"];
                    [dictData setValue:entityDict[@"name"] forKey:@"name"];
                    [dictData setValue:entityDict[@"follower_total"] forKey:@"follower_total"];
                    if ([self checkEntityExistedOnLocal:entityDict[@"entity_id"]]) {
                        entity.is_follow = @1;
                        [dictData setValue:@1 forKey:@"is_follow"];
                    }else{
                        entity.is_follow = @0;
                        [dictData setValue:@0 forKey:@"is_follow"];
                    }
                    
                    entity.data = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dictData options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
                    NSError *saveError = nil;
                    [context save:&saveError];
                    if (saveError) {
                        NSLog(@"Error when saving managed object context : %@", saveError);
                    }
                }
            }
            
        }

        
    } failure:^(NSError *err) { }];
}
+ (void)loadFetchAllEntity{
    [[Communication sharedManager] FetchAllOfEntity:SESSIONID successed:^(id _responseObject) {
        
        NSDictionary *mainEntityDict = [_responseObject objectForKey:@"data"];
        
        NSManagedObjectContext *context = [AppDelegate sharedDelegate].managedObjectContext;
        
        NSFetchRequest *allContacts = [[NSFetchRequest alloc] init];
        [allContacts setEntity:[NSEntityDescription entityForName:@"LocationOfEntity" inManagedObjectContext:context]];
        
        NSError *error = nil;
        NSArray *contacts = [context executeFetchRequest:allContacts error:&error];
        NSInteger timestamp = [[NSDate date] timeIntervalSince1970];
        
        // remove contacts
        NSArray *foundLocations = [contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"timestamp != %@", @(timestamp)]];
        if (foundLocations.count > 0) {
            for (LocationOfEntity *deleteLocation in foundLocations) {
                [context deleteObject:deleteLocation];
            }
        }
        NSError *saveError = nil;
        [context save:&saveError];
        if (saveError) {
            NSLog(@"Error when saving managed object context : %@", saveError);
        }
        
        // add or edit contacts
        for (NSDictionary * entityDict in mainEntityDict) {
            id entityId;
            entityId = entityDict[@"entity_id"];
            if (entityDict[@"infos"] && [entityDict[@"infos"] count] > 0) {
                for (NSDictionary * locationInfo in entityDict[@"infos"]) {
                    LocationOfEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:@"LocationOfEntity" inManagedObjectContext:context];
                    entity.entity_Id = entityId;
                    entity.first_name = entityDict[@"name"];
                    entity.profile_image = entityDict[@"profile_image"];
                    
                    NSString *profileImageUrl = entityDict[@"profile_image"];
                    
                    if (profileImageUrl && ![profileImageUrl isEqualToString:@""] && [profileImageUrl rangeOfString:@"no-face"].location == NSNotFound) {
                        NSString *localFilePath = [LocalDBManager checkCachedFileExist:profileImageUrl];
                        UIImageView * _tempProfileImageView;
                        if (!localFilePath) {
                            _tempProfileImageView = [UIImageView new];
                            [_tempProfileImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:profileImageUrl]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                [LocalDBManager saveImage:image forRemotePath:profileImageUrl];
                            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                NSLog(@"Failed to load profile image");
                            }];
                        }
                    }
                    
                    if (locationInfo[@"address_confirmed"] && [locationInfo[@"address_confirmed"] boolValue]) {
                        if (locationInfo[@"latitude"] && locationInfo[@"longitude"] && ![[NSString stringWithFormat:@"%@",locationInfo[@"latitude"]]isEqualToString:@"<null>"] && ![[NSString stringWithFormat:@"%@",locationInfo[@"longitude"]] isEqualToString:@"<null>"]) {
                            entity.latitude = @([locationInfo[@"latitude"] floatValue]);
                            entity.longitude = @([locationInfo[@"longitude"] floatValue]);
                        }else{
                            entity.latitude = @0;
                            entity.longitude = @0;
                        }
                    }
                    
                    entity.timestamp = @(timestamp);
                    NSMutableDictionary *dictData = [[NSMutableDictionary alloc] init];
                    
                    [dictData setValue:entityDict[@"entity_id"] forKey:@"entity_id"];
                    [dictData setValue:entityDict[@"profile_image"] forKey:@"profile_image"];
                    [dictData setValue:entityDict[@"name"] forKey:@"name"];
                    [dictData setValue:entityDict[@"follower_total"] forKey:@"follower_total"];
                    //if ([self checkEntityExistedOnLocal:entityDict[@"entity_id"]]) {
                    //    entity.is_follow = @1;
                    //    [dictData setValue:@1 forKey:@"is_follow"];
                    //}else{
                        entity.is_follow = @0;
                        [dictData setValue:@0 forKey:@"is_follow"];
                    //}
                    entity.data = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dictData options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
                    NSError *saveError = nil;
                    [context save:&saveError];
                    if (saveError) {
                        NSLog(@"Error when saving managed object context : %@", saveError);
                    }
                }
            }
            
        }
        
    } failure:^(NSError *err) {
    
    }];
}
+ (void)loadFetchAllEntityNew{
    [[Communication sharedManager] FetchAllOfEntityNew:SESSIONID successed:^(id _responseObject) {
        
        NSDictionary *mainEntityDict = [_responseObject objectForKey:@"data"];
        
        NSManagedObjectContext *context = [AppDelegate sharedDelegate].managedObjectContext;
        
        NSFetchRequest *allContacts = [[NSFetchRequest alloc] init];
        [allContacts setEntity:[NSEntityDescription entityForName:@"LocationOfEntity" inManagedObjectContext:context]];
        
        NSError *error = nil;
        NSArray *contacts = [context executeFetchRequest:allContacts error:&error];
        NSInteger timestamp = [[NSDate date] timeIntervalSince1970];
        
        // remove contacts
        NSArray *foundLocations = [contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"timestamp != %@", @(timestamp)]];
        if (foundLocations.count > 0) {
            for (LocationOfEntity *deleteLocation in foundLocations) {
                [context deleteObject:deleteLocation];
            }
        }
        NSError *saveError = nil;
        [context save:&saveError];
        if (saveError) {
            NSLog(@"Error when saving managed object context : %@", saveError);
        }
        
        NSInteger timestampAfter = [[NSDate date] timeIntervalSince1970];
        //NSLog(@"Time 1 for deleting : %ld", timestampAfter - timestamp);
        
        // add or edit contacts
        id entityId;
        NSString *profileImageUrl = @"";
        @autoreleasepool {
            for (NSDictionary * entityDict in mainEntityDict) {
                
                entityId = entityDict[@"entity_id"];
                profileImageUrl = entityDict[@"profile_image"];
                
                if (profileImageUrl && ![profileImageUrl isEqualToString:@""] && [profileImageUrl rangeOfString:@"no-face"].location == NSNotFound) {
                    NSString *localFilePath = [LocalDBManager checkCachedFileExist:profileImageUrl];
                    UIImageView * _tempProfileImageView;
                    if (!localFilePath) {
                        _tempProfileImageView = [UIImageView new];
                        [_tempProfileImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:profileImageUrl]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                            [LocalDBManager saveImage:image forRemotePath:profileImageUrl];
                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                            NSLog(@"Failed to load profile image");
                        }];
                    }
                }
                NSNumber *isFollow = @0;
                if ([self checkEntityExistedOnLocal:entityDict[@"entity_id"]]) {
                    isFollow = @1;
                }else{
                    isFollow = @0;
                }
                    
                if (entityDict[@"locations"] && [entityDict[@"locations"] count] > 0) {
                    @autoreleasepool {
                    for (NSDictionary * locationInfo in entityDict[@"locations"]) {
                        LocationOfEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:@"LocationOfEntity" inManagedObjectContext:context];
                        entity.entity_Id = entityId;
                        entity.first_name = entityDict[@"name"];
                        entity.profile_image = entityDict[@"profile_image"];
                        
                        
                        if (locationInfo[@"latitude"] && locationInfo[@"longitude"] && ![[NSString stringWithFormat:@"%@",locationInfo[@"latitude"]]isEqualToString:@"<null>"] && ![[NSString stringWithFormat:@"%@",locationInfo[@"longitude"]] isEqualToString:@"<null>"]) {
                            entity.latitude = @([locationInfo[@"latitude"] floatValue]);
                            entity.longitude = @([locationInfo[@"longitude"] floatValue]);
                        }else{
                            entity.latitude = @0;
                            entity.longitude = @0;
                        }
                        
                        entity.timestamp = @(timestamp);
                        NSMutableDictionary *dictData = [[NSMutableDictionary alloc] init];
                        
                        [dictData setValue:entityDict[@"entity_id"] forKey:@"entity_id"];
                        [dictData setValue:entityDict[@"profile_image"] forKey:@"profile_image"];
                        [dictData setValue:entityDict[@"name"] forKey:@"name"];
                        
                        if (entityDict[@"follower_total"]) {
                            [dictData setValue:entityDict[@"follower_total"] forKey:@"follower_total"];
                        }else{
                            [dictData setValue:@"0" forKey:@"follower_total"];
                        }
                        
                        entity.is_follow = isFollow;
                        [dictData setValue:isFollow forKey:@"is_follow"];
                        
                        entity.data = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dictData options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
                        
                    }
                    }
                    timestampAfter = [[NSDate date] timeIntervalSince1970];
                    //NSLog(@"Time for everyone : %ld", timestampAfter - timestamp);
                }
                
            }
        }
        timestampAfter = [[NSDate date] timeIntervalSince1970];
        //NSLog(@"Time for all : %ld", timestampAfter - timestamp);
        [context save:&saveError];
        if (saveError) {
            NSLog(@"Error when saving managed object context : %@", saveError);
        }
        
    } failure:^(NSError *err) {
        
    }];
}
+ (void)loadAvaiableEntityNew{
    //[MBProgressHUD showHUDAddedTo:APPDELEGATE.window animated:YES];
    [[Communication sharedManager] SyncUpdatedOfEntityNew:SESSIONID successed:^(id _responseObject) {
        NSDictionary *data = [_responseObject objectForKey:@"data"];
        
        NSManagedObjectContext *context = [AppDelegate sharedDelegate].managedObjectContext;
        
        NSFetchRequest *allContacts = [[NSFetchRequest alloc] init];
        [allContacts setEntity:[NSEntityDescription entityForName:@"LocationOfEntity" inManagedObjectContext:context]];
        
        NSError *error = nil;
        NSArray *contacts = [context executeFetchRequest:allContacts error:&error];
        NSInteger timestamp = [[NSDate date] timeIntervalSince1970];
        
        // remove contacts
        NSMutableArray *removedEntities = [data objectForKey:@"removed_entities"];
        for (int i = 0; i < [removedEntities count]; i++) {
            id entityIdForRemove;
            entityIdForRemove = [removedEntities objectAtIndex:i];
            NSArray *foundLocations = [contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"entity_Id == %@", entityIdForRemove]];
            if (foundLocations.count > 0) {
                for (LocationOfEntity *deleteLocation in foundLocations) {
                    [context deleteObject:deleteLocation];
                }
                NSError *saveError = nil;
                [context save:&saveError];
                if (saveError) {
                    NSLog(@"Error when saving managed object context : %@", saveError);
                }
            }
            
        }
        
        // add or edit contacts
        id entityId;
        NSString *profileImageUrl = @"";
        @autoreleasepool {
            for (NSDictionary * entityDict in data[@"entities"]) {
                
                entityId = entityDict[@"entity_id"];
                profileImageUrl = entityDict[@"profile_image"];
                
                if (profileImageUrl && ![profileImageUrl isEqualToString:@""] && [profileImageUrl rangeOfString:@"no-face"].location == NSNotFound) {
                    NSString *localFilePath = [LocalDBManager checkCachedFileExist:profileImageUrl];
                    UIImageView * _tempProfileImageView;
                    if (!localFilePath) {
                        _tempProfileImageView = [UIImageView new];
                        [_tempProfileImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:profileImageUrl]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                            [LocalDBManager saveImage:image forRemotePath:profileImageUrl];
                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                            NSLog(@"Failed to load profile image");
                        }];
                    }
                }
                NSNumber *isFollow = @0;
                if ([self checkEntityExistedOnLocal:entityDict[@"entity_id"]]) {
                    isFollow = @1;
                }else{
                    isFollow = @0;
                }
                
                if (entityDict[@"locations"] && [entityDict[@"locations"] count] > 0) {
                    @autoreleasepool {
                        for (NSDictionary * locationInfo in entityDict[@"locations"]) {
                            LocationOfEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:@"LocationOfEntity" inManagedObjectContext:context];
                            entity.entity_Id = entityId;
                            entity.first_name = entityDict[@"name"];
                            entity.profile_image = entityDict[@"profile_image"];
                            
                            
                            if (locationInfo[@"latitude"] && locationInfo[@"longitude"] && ![[NSString stringWithFormat:@"%@",locationInfo[@"latitude"]]isEqualToString:@"<null>"] && ![[NSString stringWithFormat:@"%@",locationInfo[@"longitude"]] isEqualToString:@"<null>"]) {
                                entity.latitude = @([locationInfo[@"latitude"] floatValue]);
                                entity.longitude = @([locationInfo[@"longitude"] floatValue]);
                            }else{
                                entity.latitude = @0;
                                entity.longitude = @0;
                            }
                            
                            entity.timestamp = @(timestamp);
                            NSMutableDictionary *dictData = [[NSMutableDictionary alloc] init];
                            
                            [dictData setValue:entityDict[@"entity_id"] forKey:@"entity_id"];
                            [dictData setValue:entityDict[@"profile_image"] forKey:@"profile_image"];
                            [dictData setValue:entityDict[@"name"] forKey:@"name"];
                            
                            if (entityDict[@"follower_total"]) {
                                [dictData setValue:entityDict[@"follower_total"] forKey:@"follower_total"];
                            }else{
                                [dictData setValue:@"0" forKey:@"follower_total"];
                            }
                            
                            entity.is_follow = isFollow;
                            [dictData setValue:isFollow forKey:@"is_follow"];
                            
                            entity.data = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dictData options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
                            
                        }
                    }
                }
                
            }
        }

        NSError *saveError = nil;
        [context save:&saveError];
        if (saveError) {
            NSLog(@"Error when saving managed object context : %@", saveError);
        }
        [MBProgressHUD hideHUDForView:APPDELEGATE.window animated:YES];
        
    } failure:^(NSError *err) {
        [MBProgressHUD hideHUDForView:APPDELEGATE.window animated:YES];
    }];
}
+ (BOOL)checkEntityExistedOnLocal:entityid{
    NSManagedObjectContext *context = [AppDelegate sharedDelegate].managedObjectContext;
    
    NSFetchRequest *allContacts = [[NSFetchRequest alloc] init];
    [allContacts setEntity:[NSEntityDescription entityForName:@"Contact" inManagedObjectContext:context]];
    
    NSError *error = nil;
    NSArray *contacts = [context executeFetchRequest:allContacts error:&error];
    
    // remove contacts
    NSArray *foundLocations = [contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(contact_id == %@) AND (contact_type == 3)", [NSString stringWithFormat:@"%@", entityid]]];
    if (foundLocations.count > 0) {
        return YES;
    }
    return NO;
}
+ (void)loadDetectedContacts {
    [[Communication sharedManager] getPurpleContacts:SESSIONID pageNum:1 countPerPage:50 keyword:@"" successed:^(id _responseObject) {
        NSDictionary * contactsDic = [_responseObject objectForKey:@"data"];
        NSArray *contacts = contactsDic[@"data"];
        [SearchedContact insertPurpleContacts:contacts];
        [[AppDelegate sharedDelegate] saveContext];
    } failure:^(NSError *err) { }];
    
    [[Communication sharedManager] getDetectedContacts:SESSIONID pageNum:1 countPerPage:50 keyword:@"" successed:^(id _responseObject) {
        NSDictionary * contacts = [_responseObject objectForKey:@"data"];
        NSArray * friends = [contacts objectForKey:@"data"];
        [SearchedContact insertContactRecords:friends];
        [[AppDelegate sharedDelegate] saveContext];
    } failure:^(NSError *err) { }];
}

@end
