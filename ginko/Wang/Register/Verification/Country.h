//
//  Country.h
//  ginko
//
//  Created by STAR on 1/3/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Country : NSObject

@property (nonatomic, strong) NSString *countryCode;
@property (nonatomic, strong) NSString *phoneExtension;
@property (nonatomic, assign) BOOL isMain;
@property (nonatomic, strong, readonly, getter=name) NSString *name;
- (instancetype)initWithCountryCode:(NSString *)countryCode phoneExtension:(NSString *)phoneExtension isMain:(BOOL)isMain;
+ (Country *)emptyCountry;
+ (Country *)currentCountry;

@end
