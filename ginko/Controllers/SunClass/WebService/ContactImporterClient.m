//
//  ContactImporterClient.m
//  ContactImporter
//
//  Created by mobidev on 6/12/14.
//  Copyright (c) 2014 Ron. All rights reserved.
//

#import "ContactImporterClient.h"
#import "NetAPIClient.h"

@implementation ContactImporterClient

+ (ContactImporterClient *)sharedClient
{
    static ContactImporterClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] init];
    });
    return _sharedClient;
}

- (void)getOAuthURL:(NSString *)sessionID
              email:(NSString *)email
           provider:(NSString *)provider
          successed:(void (^)(id responseObject)) success
            failure:(void (^)(NSError* error)) failure
{
    //set Parameters
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    [params setObject:sessionID     forKey:@"sessionId"];
    [params setObject:email         forKey:@"email"];
    [params setObject:provider      forKey:@"provider"];
    
    [[NetAPIClient sharedClient] sendToServiceByGET:/*[NSString stringWithFormat:@"%@%@?sessionId=%@&email=%@", SERVER_URL, WEBAPIP_GETOAUTHURL, sessionID, email]*/[NSString stringWithFormat:@"%@%@", SERVER_URL, WEBAPI_GETOAUTHURL] params:params success:success failure:failure];
}

- (void)discoverOWAServer:(NSString *)sessionID
                    email:(NSString *)email
                 password:(NSString *)password
                 username:(NSString *)username
          successed:(void (^)(id responseObject)) success
            failure:(void (^)(NSError* error)) failure
{
    //set Parameters
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    [params setObject:sessionID     forKey:@"sessionId"];
    [params setObject:email         forKey:@"email"];
    [params setObject:password      forKey:@"password"];
    if (username) {
        [params setObject:username forKey:@"username"];
    }
    
    //    [params setObject :@"json"		forKey:@"format"];
    
    [[NetAPIClient sharedClient] sendToServiceByGET:[NSString stringWithFormat:@"%@%@", SERVER_URL, WEBAPI_DISCOVEROWASERVER] params:params success:success failure:failure];
}

- (void)syncContactByOAuth:(NSString *)sessionID
                     email:(NSString *)email
                  provider:(NSString *)provider
                      code:(NSString *)code
            successed:(void (^)(id responseObject)) success
              failure:(void (^)(NSError* error)) failure
{
    //set Parameters
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    [params setObject:sessionID     forKey:@"sessionId"];
    [params setObject:email         forKey:@"email"];
    [params setObject:code          forKey:@"code"];
    [params setObject:provider      forKey:@"provider"];
    
    [[NetAPIClient sharedClient] sendToServiceByPOST:[NSString stringWithFormat:@"%@%@?sessionId=%@&email=%@&provider=%@&%@", SERVER_URL, WEBAPI_SYNCCONTACTBYOAUTH, sessionID, email, provider, code] params:params success:success failure:failure];
}

- (void)syncContactByOWA:(NSString *)sessionID
                   email:(NSString *)email
                password:(NSString *)password
                username:(NSString *)username
              webMailLin:(NSString *)webMailLink
                 successed:(void (^)(id responseObject)) success
                   failure:(void (^)(NSError* error)) failure
{
    //set Parameters
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    [params setObject:sessionID     forKey:@"sessionId"];
    [params setObject:email         forKey:@"email"];
    [params setObject:password      forKey:@"password"];
    if (username) {
        [params setObject:username forKey:@"username"];
    }
    if (webMailLink) {
        [params setObject:webMailLink forKey:@"webmail_link"];
    }
    
    NSString *action = [NSString stringWithFormat:@"%@%@?sessionId=%@&email=%@&password=%@", SERVER_URL, WEBAPI_SYNCCONTACTBYOWA, sessionID, email, password];
    if (username) {
        action = [NSString stringWithFormat:@"%@&username=%@", action, username];
    }
    if (webMailLink) {
        action = [NSString stringWithFormat:@"%@&webmail_link=%@", action, webMailLink];
    }
    
    [[NetAPIClient sharedClient] sendToServiceByPOST:action params:params success:success failure:failure];
}

- (void)removeSyncContact:(NSString *)sessionID
            syncContacts:(NSString *)syncContacts
            successed:(void (^)(id responseObject)) success
              failure:(void (^)(NSError* error)) failure
{
    //set Parameters
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    [params setObject:sessionID     forKey:@"sessionId"];
    [params setObject:syncContacts  forKey:@"sync_contact_ids"];
    
    [[NetAPIClient sharedClient] sendToServiceByPOST:[NSString stringWithFormat:@"%@%@?sessionId=%@&sync_contact_ids=%@", SERVER_URL, WEBAPI_DELETESYNCCONTACT, sessionID, syncContacts] params:params success:success failure:failure];
}

- (void)addUpdateSyncContact:(NSString *)sessionID
                      fields:(NSArray *)data
                   successed:(void (^)(id responseObject)) success
                     failure:(void (^)(NSError* error)) failure
{
    //set Parameters
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    [params setObject:sessionID     forKey:@"sessionId"];
    if ([data count]) {
        [params setObject:data      forKey:@"data"];
    }
    
    [[NetAPIClient sharedClient] sendToServiceByJSONPOST:[NSString stringWithFormat:@"%@%@?sessionId=%@", SERVER_URL, WEBAPI_UPDATESYNCCONTACT, sessionID] params:params success:success failure:failure];
}

- (void)syncMultipleContacts:(NSString *)sessionID
                        data:(NSArray *)data
                   successed:(void (^)(id responseObject)) success
                     failure:(void (^)(NSError* error)) failure
{
    //set Parameters
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    [params setObject:sessionID     forKey:@"sessionId"];
    if ([data count]) {
        [params setObject:data      forKey:@"data"];
    }
    
    [[NetAPIClient sharedClient] sendToServiceByJSONPOST:[NSString stringWithFormat:@"%@%@?sessionId=%@", SERVER_URL, WEBAPI_SYNCMULTIPLECONTACTS, sessionID] params:params success:success failure:failure];
}

//CBImporter
- (void)getCBOAuthURL:(NSString *)sessionID
                email:(NSString *)email
             provider:(NSString *)provider
            successed:(void (^)(id responseObject)) success
              failure:(void (^)(NSError* error)) failure
{
    //set Parameters
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    [params setObject:sessionID     forKey:@"sessionId"];
    [params setObject:email         forKey:@"email"];
    [params setObject:provider      forKey:@"provider"];
    
    [[NetAPIClient sharedClient] sendToServiceByGET:[NSString stringWithFormat:@"%@%@", SERVER_URL, WEBAPI_CBGETOAUTHURL] params:params success:success failure:failure];
}

//unuseful
- (void)importContactsByOauth:(NSString *)urlString
                    successed:(void (^)(id responseObject)) success
                      failure:(void (^)(NSError* error)) failure
{
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    [[NetAPIClient sharedClient] sendToServiceByGET:urlString params:params success:success
                                            failure:failure];
}

//unuserful
- (void)getSyncHistory:(NSString *)sessionID
          successed:(void (^)(id responseObject)) success
            failure:(void (^)(NSError* error)) failure
{
    //set Parameters
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    [params setObject:sessionID     forKey:@"sessionId"];
    //    [params setObject :@"json"		forKey:@"format"];
    
    [[NetAPIClient sharedClient] sendToServiceByGET:[NSString stringWithFormat:@"%@%@", SERVER_URL, WEBAPI_GETSYNCHISTORY] params:params success:success failure:failure];
}


@end
