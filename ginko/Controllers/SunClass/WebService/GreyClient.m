//
//  GreyClient.m
//  GINKO
//
//  Created by mobidev on 5/21/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import "GreyClient.h"
#import "NetAPIClient.h"
#import "Communication.h"

@implementation GreyClient

+ (GreyClient *)sharedClient
{
    static GreyClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] init];
    });
    return _sharedClient;
}

- (void)getContacts:(NSString *)sessionID
          successed:(void (^)(id responseObject)) success
            failure:(void (^)(NSError* error)) failure
{
    //set Parameters
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    [params setObject:sessionID     forKey:@"sessionId"];
    
    [[NetAPIClient sharedClient] sendToServiceByGET:[NSString stringWithFormat:@"%@%@", SERVER_URL, WEBAPIP_GETCONTACTS] params:params success:success failure:failure];
}

- (void)uploadPhoto:(NSString *)sessionID
          contactID:(NSString *)contactID
//imgData:(NSData *)imgData
          successed:(void (^)(id responseObject)) success
            failure:(void (^)(NSError* error)) failure
{/*
//    NSString *action = [NSString stringWithFormat:@"%@%@?sessionId=%@", SERVER_URL, WEBAPIP_UPLOADPHOTO, sessionID];
    NSString *action = [NSString stringWithFormat:@"%@?sessionId=%@", WEBAPIP_UPLOADPHOTO, sessionID];
    //set Parameters
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    [params setObject:sessionID     forKey:@"sessionId"];
    if (contactID) {
        [params setObject:contactID forKey:@"contact_id"];
        action = [NSString stringWithFormat:@"%@&contact_id=%@", action, contactID];
    }
    
//    NSData *photoData;
//    photoData = [[NSFileManager defaultManager] contentsAtPath:TEMP_IMAGE_PATH];
    
//    [[NetAPIClient sharedClient] sendToServiceByPOST:action params:params media:imgData mediaType:0 success:success failure:failure];
    
    [[Communication sharedManager] sendToService:params action:action data:imgData name:@"photo" mimetype:@"image/jpeg" success:success failure:failure];*/
    NSString *action = [NSString stringWithFormat:@"%@%@?sessionId=%@", SERVER_URL, WEBAPIP_UPLOADPHOTO, sessionID];
    //set Parameters
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    [params setObject:sessionID     forKey:@"sessionId"];
    if (contactID) {
        [params setObject:contactID forKey:@"contact_id"];
        action = [NSString stringWithFormat:@"%@&contact_id=%@", action, contactID];
    }
    
    NSData *photoData;
    photoData = [[NSFileManager defaultManager] contentsAtPath:TEMP_IMAGE_PATH];
    
    [[NetAPIClient sharedClient] sendToServiceByPOST:action params:params media:photoData mediaType:0 success:success failure:failure];
}

- (void)deletePhoto:(NSString *)sessionID
          contactID:(NSString *)contactID
//imgData:(NSData *)imgData
          successed:(void (^)(id responseObject)) success
            failure:(void (^)(NSError* error)) failure
{
    NSString *action = [NSString stringWithFormat:@"%@%@?sessionId=%@", SERVER_URL, WEBAPIP_DELETEPHOTO, sessionID];
    //set Parameters
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    [params setObject:sessionID     forKey:@"sessionId"];
    if (contactID) {
        [params setObject:contactID forKey:@"contact_id"];
        action = [NSString stringWithFormat:@"%@&contact_id=%@", action, contactID];
    }
    
    [[NetAPIClient sharedClient] sendToServiceByPOST:action params:params success:success failure:failure];
}

- (void)uploadProfilePhoto:(NSString *)sessionID
                      type:(NSString *)type
                   imgData:(NSData *)imgData
          successed:(void (^)(id responseObject)) success
            failure:(void (^)(NSError* error)) failure
{
    NSString *action = [NSString stringWithFormat:@"%@%@?sessionId=%@&type=%@", SERVER_URL, WEBAPI_UPLOADPROFILEPHOTO, sessionID, type];
    
    //set Parameters
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:sessionID     forKey:@"sessionId"];
    [params setObject:type          forKey:@"type"];
    
    [[NetAPIClient sharedClient] sendToServiceByPOST:action params:params media:imgData mediaType:0 name:@"image" success:success failure:failure];
}

- (void)uploadEntityPhoto:(NSString *)sessionID
                 entityID:(NSString *)entityID
                  imgData:(NSData *)imgData
                successed:(void (^)(id responseObject)) success
                  failure:(void (^)(NSError* error)) failure
{
    NSString *action = [NSString stringWithFormat:@"%@%@?sessionId=%@&entity_id=%@", SERVER_URL, WEBAPI_UPLOADENTITYPHOTO, sessionID, entityID];
    
    //set Parameters
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:sessionID     forKey:@"sessionId"];
    [params setObject:entityID      forKey:@"entity_id"];
    
    [[NetAPIClient sharedClient] sendToServiceByPOST:action params:params media:imgData mediaType:0 name:@"image" success:success failure:failure];
}

- (void)removeEntityPhoto:(NSString *)sessionID
                 entityID:(NSString *)entityID
                successed:(void (^)(id responseObject)) success
                  failure:(void (^)(NSError* error)) failure
{
    NSString *action = [NSString stringWithFormat:@"%@%@?sessionId=%@&entity_id=%@", SERVER_URL, WEBAPI_REMOVEENTITYPHOTO, sessionID, entityID];
    
    //set Parameters
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:sessionID     forKey:@"sessionId"];
    [params setObject:entityID      forKey:@"entity_id"];
    
    [[NetAPIClient sharedClient] sendToServiceByPOST:action params:params success:success failure:failure];
}


- (void)deleteProfilePhoto:(NSString *)sessionID
                      type:(NSString *)type
                 successed:(void (^)(id responseObject)) success
                   failure:(void (^)(NSError* error)) failure
{
    NSString *action = [NSString stringWithFormat:@"%@%@?sessionId=%@&type=%@", SERVER_URL, WEBAPI_DELETEPROFILEPHOTO, sessionID, type];
    
    //set Parameters
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:sessionID     forKey:@"sessionId"];
    [params setObject:type          forKey:@"type"];
    
    [[NetAPIClient sharedClient] sendToServiceByPOST:action params:params success:success failure:failure];
}

- (void)addUpdateGreyContact:(NSString *)sessionID
             contactID:(NSString *)contactID
             firstName:(NSString *)firstName
              middleName:(NSString *)middleName
              lastName:(NSString *)lastName
                 email:(NSString *)email
             photoName:(NSString *)photoName
                 notes:(NSString *)notes
                  type:(NSString *)type
              favorite:(BOOL)favorite
                fields:(NSArray *)fields
             successed:(void (^)(id responseObject)) success
               failure:(void (^)(NSError* error)) failure
{
    //set Parameters
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    NSString *action = contactID ? WEBAPIP_UPDATECONTACT : WEBAPIP_ADDGREYCONTACT;
    
    [params setObject:sessionID     forKey:@"sessionId"];
    if (contactID) {
        [params setObject:contactID forKey:@"contact_id"];
    }
    [params setObject:firstName        forKey:@"first_name"];
    if (lastName) {
        [params setObject:lastName        forKey:@"last_name"];
    }
    if (middleName) {
        [params setObject:middleName        forKey:@"middle_name"];
    }
    if (email) {
        [params setObject:email        forKey:@"email"];
    }
    if (photoName) {
        [params setObject:photoName        forKey:@"photo_name"];
    }
    if (notes) {
        [params setObject:notes forKey:@"notes"];
    }
    [params setObject:type forKey:@"type"];
    if (favorite) {
        [params setObject:[NSString stringWithFormat:@"true"] forKey:@"is_favorite"];
    }else{
        [params setObject:[NSString stringWithFormat:@"false"] forKey:@"is_favorite"];
    }
        
    if (fields) {
        [params setObject:fields forKey:@"fields"];
    }
    
    [[NetAPIClient sharedClient] sendToServiceByJSONPOST:[NSString stringWithFormat:@"%@%@?sessionId=%@", SERVER_URL, action, sessionID] params:params success:success failure:failure];
}

- (void)updateNotes:(NSString *)sessionID
          contactID:(NSString *)contactID
              notes:(NSString *)notes
          successed:(void (^)(id responseObject)) success
            failure:(void (^)(NSError* error)) failure
{
    //set Parameters
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    [params setObject:sessionID     forKey:@"sessionId"];
    [params setObject:contactID     forKey:@"contact_id"];
    [params setObject:notes         forKey:@"notes"];
    
    [[NetAPIClient sharedClient] sendToServiceByJSONPOST:[NSString stringWithFormat:@"%@%@?sessionId=%@", SERVER_URL, WEBAPIP_UPDATECONTACT, sessionID] params:params success:success failure:failure];
}

- (void)removeContact:(NSString *)sessionID
            contactID:(NSString *)contactID
            successed:(void (^)(id responseObject)) success
              failure:(void (^)(NSError* error)) failure
{
    //set Parameters
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    [params setObject:sessionID     forKey:@"sessionId"];
    [params setObject:contactID     forKey:@"sync_contact_ids"];
    
    [[NetAPIClient sharedClient] sendToServiceByPOST:[NSString stringWithFormat:@"%@%@?sessionId=%@&sync_contact_ids=%@", SERVER_URL, WEBAPI_REMOVEGREYCONTACT, sessionID, contactID] params:params success:success failure:failure];
}

@end
