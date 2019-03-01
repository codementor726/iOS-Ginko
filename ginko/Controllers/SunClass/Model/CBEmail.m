//
//  CBEmail.m
//  GINKO
//
//  Created by mobidev on 5/17/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import "CBEmail.h"

@implementation CBEmail

- (id)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    
    if (self) {
        self.cbID = [dict objectForKey:@"id"];
        self.email = [dict objectForKey:@"email"];
        self.last_update = [dict objectForKey:@"last_update"];
        self.valid = [[dict objectForKey:@"valid"] isEqualToString:@"yes"] ? YES : NO;
        self.active = [[dict objectForKey:@"active"] isEqualToString:@"yes"] ? YES : NO;
        self.sharing_status = [[dict objectForKey:@"sharing_status"] intValue];
        self.shareHomeFields = ([dict objectForKey:@"shared_home_fids"] == [NSNull null]) ? @"" : [dict objectForKey:@"shared_home_fids"];
        self.shareWorkFields = ([dict objectForKey:@"shared_work_fids"] == [NSNull null]) ? @"" : [dict objectForKey:@"shared_work_fids"];
        self.authType = [dict objectForKey:@"auth_type"];
        if ([self.authType isEqualToString:@"oauth"]) {
            self.provider = [dict objectForKey:@"provider"];
        }
    }
    
    return self;
}

@end
