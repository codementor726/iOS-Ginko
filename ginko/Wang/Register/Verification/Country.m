//
//  Country.m
//  ginko
//
//  Created by STAR on 1/3/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "Country.h"
#import "Countries.h"

@implementation Country

+ (Country *)emptyCountry {
    return [[Country alloc] initWithCountryCode:@"" phoneExtension:@"" isMain:YES];
}

+ (Country *)currentCountry {
    NSString *countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    if (countryCode)
        return [Countries countryFromCountryCode:countryCode];
    return [Country emptyCountry];
    
}

- (instancetype)initWithCountryCode:(NSString *)countryCode phoneExtension:(NSString *)phoneExtension isMain:(BOOL)isMain {
    if (self = [super init]) {
        self.countryCode = countryCode;
        self.phoneExtension = phoneExtension;
        self.isMain = isMain;
    }
    return self;
}

- (NSString *)name {
    return [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:_countryCode];
}

@end