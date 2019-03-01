//
//  ContactImporterClient.h
//  ContactImporter
//
//  Created by mobidev on 6/12/14.
//  Copyright (c) 2014 Ron. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactImporterClient : NSObject

+ (ContactImporterClient *)sharedClient;

- (void)getOAuthURL:(NSString *)sessionID
              email:(NSString *)email
           provider:(NSString *)provider
          successed:(void (^)(id responseObject)) success
            failure:(void (^)(NSError* error)) failure;

- (void)discoverOWAServer:(NSString *)sessionID
                    email:(NSString *)email
                 password:(NSString *)password
                 username:(NSString *)username
                successed:(void (^)(id responseObject)) success
                  failure:(void (^)(NSError* error)) failure;

- (void)syncContactByOAuth:(NSString *)sessionID
                     email:(NSString *)email
                  provider:(NSString *)provider
                      code:(NSString *)code
                 successed:(void (^)(id responseObject)) success
                   failure:(void (^)(NSError* error)) failure;

- (void)syncContactByOWA:(NSString *)sessionID
                   email:(NSString *)email
                password:(NSString *)password
                username:(NSString *)username
              webMailLin:(NSString *)webMailLink
               successed:(void (^)(id responseObject)) success
                 failure:(void (^)(NSError* error)) failure;

- (void)getSyncHistory:(NSString *)sessionID
             successed:(void (^)(id responseObject)) success
               failure:(void (^)(NSError* error)) failure;

- (void)removeSyncContact:(NSString *)sessionID
             syncContacts:(NSString *)syncContacts
                successed:(void (^)(id responseObject)) success
                  failure:(void (^)(NSError* error)) failure;

- (void)addUpdateSyncContact:(NSString *)sessionID
                      fields:(NSArray *)data
                   successed:(void (^)(id responseObject)) success
                     failure:(void (^)(NSError* error)) failure;

- (void)syncMultipleContacts:(NSString *)sessionID
                        data:(NSArray *)data
                   successed:(void (^)(id responseObject)) success
                     failure:(void (^)(NSError* error)) failure;

//CBImporter
- (void)getCBOAuthURL:(NSString *)sessionID
                email:(NSString *)email
             provider:(NSString *)provider
            successed:(void (^)(id responseObject)) success
              failure:(void (^)(NSError* error)) failure;

//unuseful
- (void)importContactsByOauth:(NSString *)urlString
                    successed:(void (^)(id responseObject)) success
                      failure:(void (^)(NSError* error)) failure;

@end
