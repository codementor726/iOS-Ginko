//
//  Countries.h
//  ginko
//
//  Created by STAR on 1/3/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Country.h"

@interface Countries : NSObject
+ (NSArray *)countries;
+ (Country *)countryFromPhoneExtension:(NSString *)phoneExtension;
+ (Country *)countryFromCountryCode:(NSString *)countryCode;
+ (NSArray *)countriesFromCountryCodes:(NSArray *)countryCodes;
@end
