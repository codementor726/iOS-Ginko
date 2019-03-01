//
//  CBEmail.h
//  GINKO
//
//  Created by mobidev on 5/17/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBEmail : NSObject

@property (nonatomic, strong) NSString *cbID;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *csync;
@property (nonatomic, strong) NSString *inserver;
@property (nonatomic, strong) NSString *inserverport;
@property (nonatomic, strong) NSString *inservertype;
@property (nonatomic, strong) NSString *inserverauthreq;
@property (nonatomic) int sharing_status;
@property (nonatomic) int share_limit;
@property (nonatomic) BOOL active;
@property (nonatomic, strong) NSString *shareHomeFields;
@property (nonatomic, strong) NSString *shareWorkFields;
@property (nonatomic, strong) NSString *domain;
@property (nonatomic, strong) NSString *username;
@property (nonatomic) BOOL valid;
@property (nonatomic, strong) NSString *last_update;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *authType;
@property (nonatomic, strong) NSString *provider;

- (id)initWithDict:(NSDictionary *)dict;

@end
