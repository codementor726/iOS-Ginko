//
//  ContactBuilderClient.m
//  GINKO
//
//  Created by mobidev on 5/16/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import "ContactBuilderClient.h"
#import "NetAPIClient.h"
#import "GTMNSString+HTML.h"

@implementation ContactBuilderClient

+ (ContactBuilderClient *)sharedClient
{
    static ContactBuilderClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] init];
    });
    return _sharedClient;
}

- (void)getAllCBEmails:(NSString *)sessionID
             successed:(void (^)(id responseObject)) success
               failure:(void (^)(NSError* error)) failure
{
    //set Parameters
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    [params setObject:sessionID     forKey:@"sessionId"];
    [params setObject :@"json"		forKey:@"format"];
    
    [[NetAPIClient sharedClient] sendToServiceByGET:[NSString stringWithFormat:@"%@%@", SERVER_URL, WEBAPI_GETCBEMAILS] params:params success:success failure:failure];
}

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
               failure:(void (^)(NSError* error)) failure
{
    //set Parameters
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    NSString *paramString = @"";
    
    [params setObject:sessionID     forKey:@"sessionId"];
    
    [params setObject:email forKey:@"email"];
    paramString = [NSString stringWithFormat:@"&email=%@", email];
    
    if (cbID) {
        [params setObject:cbID forKey:@"id"];
        paramString = [NSString stringWithFormat:@"%@&id=%@", paramString, cbID];
    }
    if (password) {
        [params setObject:password forKey:@"password"];
        paramString = [NSString stringWithFormat:@"%@&password=%@", paramString, password];
    }
    if (active) {
        [params setObject:[NSString stringWithFormat:@"%d", sharing] forKey:@"sharing"];
        paramString = [NSString stringWithFormat:@"%@&sharing=%@", paramString, [NSString stringWithFormat:@"%d", sharing]];
        
        [params setObject:_sharedHomeFieldIds forKey:@"shared_home_fids"];
        paramString = [NSString stringWithFormat:@"%@&shared_home_fids=%@", paramString, _sharedHomeFieldIds];
        
        [params setObject:_sharedWorkFieldIds forKey:@"shared_work_fids"];
        paramString = [NSString stringWithFormat:@"%@&shared_work_fids=%@", paramString, _sharedHomeFieldIds];
        
        [params setObject:@"yes" forKey:@"active"];
        paramString = [NSString stringWithFormat:@"%@&active=%@", paramString, @"yes"];
    } else {
        [params setObject:@"no" forKey:@"active"];
        paramString = [NSString stringWithFormat:@"%@&active=%@", paramString, @"no"];
    }
    
    if (authType) {
        [params setObject:authType forKey:@"auth_type"];
        paramString = [NSString stringWithFormat:@"%@&auth_type=%@", paramString, authType];
    }
    if (provider) {
        [params setObject:provider forKey:@"provider"];
        paramString = [NSString stringWithFormat:@"%@&provider=%@", paramString, provider];
    }
    if (oauthToken) {
        oauthToken = [CommonMethods urlEncodeUsingEncoding:NSUTF8StringEncoding strValue:oauthToken];
        [params setObject:oauthToken forKey:@"oauth_token"];
        paramString = [NSString stringWithFormat:@"%@&oauth_token=%@", paramString, oauthToken];
    }
    if (username) {
        [params setObject:username forKey:@"username"];
        paramString = [NSString stringWithFormat:@"%@&username=%@", paramString, username];
    }
    if (serverName) {
        [params setObject:serverName forKey:@"inserver"];
        paramString = [NSString stringWithFormat:@"%@&inserver=%@", paramString, serverName];
    }
    if (inserverType) {
        [params setObject:inserverType forKey:@"inservertype"];
        paramString = [NSString stringWithFormat:@"%@&inservertype=%@", paramString, inserverType];
    }
    if (inserverPort) {
        [params setObject:inserverPort forKey:@"inserverport"];
        paramString = [NSString stringWithFormat:@"%@&inserverport=%@", paramString, inserverPort];
    }
    
    [params setObject :@"json"	forKey:@"format"];
    
//    [params setObject:@"POP3 or IMAP" forKey:@"inservertype"];
    
    [[NetAPIClient sharedClient] sendToServiceByPOST:[NSString stringWithFormat:@"%@%@?sessionId=%@%@", SERVER_URL, WEBAPI_UPDATECBEMAIL, sessionID, paramString] params:params success:success failure:failure];
}

- (void)getInfo:(NSString *)sessionID
      successed:(void (^)(id responseObject)) success
        failure:(void (^)(NSError* error)) failure
{
    //set Parameters
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    [params setObject:sessionID     forKey:@"sessionId"];
    [params setObject :@"json"		forKey:@"format"];
    
    [[NetAPIClient sharedClient] sendToServiceByGET:[NSString stringWithFormat:@"%@%@", SERVER_URL, WEBAPIP_GETINFO] params:params success:success failure:failure];
}

- (void)getCBEmailByEmailID:(NSString *)sessionID
                    emailID:(NSString *)emailID
                  successed:(void (^)(id responseObject)) success
                    failure:(void (^)(NSError* error)) failure
{
    //set Parameters
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    [params setObject:sessionID     forKey:@"sessionId"];
    [params setObject:emailID       forKey:@"emailId"];
    [params setObject :@"json"		forKey:@"format"];
    
    [[NetAPIClient sharedClient] sendToServiceByGET:[NSString stringWithFormat:@"%@%@", SERVER_URL, WEBAPI_GETCBEMAILBYEMAILID] params:params success:success failure:failure];
}

- (void)deleteCBEmail:(NSString *)sessionID
                 cbID:(NSString *)cbID
             successed:(void (^)(id responseObject)) success
               failure:(void (^)(NSError* error)) failure
{
    //set Parameters
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    [params setObject:sessionID     forKey:@"sessionId"];
    [params setObject:cbID          forKey:@"emailId"];
    [params setObject :@"json"		forKey:@"format"];
    
    [[NetAPIClient sharedClient] sendToServiceByPOST:[NSString stringWithFormat:@"%@%@?sessionId=%@&emailId=%@", SERVER_URL, WEBAPI_DELETECBEMAIL, sessionID, cbID] params:params success:success failure:failure];
}

- (void)addGreyContact:(NSString *)sessionID
                 successed:(void (^)(id responseObject)) success
                   failure:(void (^)(NSError* error)) failure
{
    //set Parameters
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    [params setObject:sessionID     forKey:@"sessionId"];
    [params setObject:@"Mobi"        forKey:@"first_name"];
    [params setObject:@"Dev"        forKey:@"last_name"];
    [params setObject:@"lisun9041@gmail.com"        forKey:@"email"];
//    [params setObject:@"fields" forKey:@"[{field_name:phone,field_value:1952026499,field_type:phone},{field_name:address,field_value:china,field_type:address}]"];
    
    //    [params setObject:@"POP3 or IMAP" forKey:@"inservertype"];
    
    [[NetAPIClient sharedClient] sendToServiceByJSONPOST:[NSString stringWithFormat:@"%@%@?sessionId=%@", SERVER_URL, WEBAPIP_ADDGREYCONTACT, sessionID] params:params success:success failure:failure];
}

@end
