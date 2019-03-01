//
//  CommonMethods.h
//  ReactChat
//
//  Created by mobidev on 5/16/14.
//

#import <Foundation/Foundation.h>

@interface CommonMethods : NSObject {

}

+ (void)showAlertUsingTitle:(NSString *)titleString andMessage:(NSString *)messageString;
+ (UIView *) addLoadingViewWithTitle:(NSString *)title
					 andDescription:(NSString *)description;
+ (NSNumber *)getCurrentUserID;
+ (NSString *)getVersionNumber;
+ (void) changeUserImage:(NSDictionary *)responseDictionary;
+ (NSString *)getUserImage;
+ (void) showLoadingView:(UIView *) toView title:(NSString *) title andDescription:(NSString *)desc;
+ (void) removeLoadingView:(UIView *) myView;
+ (NSString *)convertToXMLEntities:(NSString *)myString;
+ (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding strValue:(NSString *)strValue;

+ (BOOL)checkEmail:(UITextField *)checkText;
+ (BOOL)checkEmailAddress:(NSString *)email;
+ (BOOL)checkBlankField:(NSArray *)txtArray titles:(NSArray *)titleArray;

+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;

+ (NSString *)date2str:(NSDate *)convertDate withFormat:(NSString *)formatString;
+ (NSString*)date2localtimestr:(NSString*)str;
+ (NSDate *)str2date:(NSString *)dateString withFormat:(NSString *)formatString;
+ (NSDate*)str2UTCDate:(NSString*)string;
+ (BOOL)isToday:(NSString *)compareDateString;

+ (void)fitViewFrame:(UIView *)view offset:(CGFloat)offset;

+ (NSString *)removeNanString:(NSString *)origString;
+ (NSString *)encodedURLString:(NSString *)str;
+ (void)loadDetectedContacts;
+ (void)loadAvaiableEntity;
+ (void)loadFetchAllEntity;

+ (void)loadAvaiableEntityNew;
+ (void)loadFetchAllEntityNew;
@end
