//
//  ContactBuilderClient.h
//  GINKO
//
//  Created by mobidev on 5/16/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBEmail.h"

@interface ContactBuilderClient : NSObject

+ (ContactBuilderClient *)sharedClient;

- (void)getAllCBEmails:(NSString *)sessionID
             successed:(void (^)(id responseObject)) success
               failure:(void (^)(NSError* error)) failure;

- (void)addOrUpdateCBEmail:(NSString *)sessionID
                      cbID:(NSString *)cbID
                     email:(NSString *)email
                  password:(NSString *)password
                   sharing:(int)sharing
        sharedHomeFieldIds:(NSString *)_sharedHomeFieldIds
        sharedWorkFieldIds:(NSString *)_sharedWorkFieldIds
                    active:(BOOL)active
                  authType:(NSString *)authType
                  provider:(NSString *)provider
                oauthToken:(NSString *)oauthToken
                  username:(NSString *)username
                  inserver:(NSString *)serverName
              inserverType:(NSString *)inserverType
              inserverPort:(NSString *)inserverPort
                 successed:(void (^)(id responseObject)) success
                   failure:(void (^)(NSError* error)) failure;


- (void)deleteCBEmail:(NSString *)sessionID
                 cbID:(NSString *)cbID
            successed:(void (^)(id responseObject)) success
              failure:(void (^)(NSError* error)) failure;

- (void)getInfo:(NSString *)sessionID
      successed:(void (^)(id responseObject)) success
        failure:(void (^)(NSError* error)) failure;

- (void)getCBEmailByEmailID:(NSString *)sessionID
                    emailID:(NSString *)emailID
                  successed:(void (^)(id responseObject)) success
                    failure:(void (^)(NSError* error)) failure;

- (void)addGreyContact:(NSString *)sessionID
             successed:(void (^)(id responseObject)) success
               failure:(void (^)(NSError* error)) failure;

@end
