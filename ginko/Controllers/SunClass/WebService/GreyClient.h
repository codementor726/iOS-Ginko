//
//  GreyClient.h
//  GINKO
//
//  Created by mobidev on 5/21/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GreyClient : NSObject

+ (GreyClient *)sharedClient;

- (void)getContacts:(NSString *)sessionID
          successed:(void (^)(id responseObject)) success
            failure:(void (^)(NSError* error)) failure;

- (void)uploadPhoto:(NSString *)sessionID
          contactID:(NSString *)contactID
//            imgData:(NSData *)imgData
          successed:(void (^)(id responseObject)) success
            failure:(void (^)(NSError* error)) failure;

- (void)deletePhoto:(NSString *)sessionID
          contactID:(NSString *)contactID
//            imgData:(NSData *)imgData
          successed:(void (^)(id responseObject)) success
            failure:(void (^)(NSError* error)) failure;

- (void)uploadProfilePhoto:(NSString *)sessionID
                      type:(NSString *)type
                   imgData:(NSData *)imgData
                 successed:(void (^)(id responseObject)) success
                   failure:(void (^)(NSError* error)) failure;

- (void)uploadEntityPhoto:(NSString *)sessionID
                 entityID:(NSString *)entityID
                  imgData:(NSData *)imgData
                successed:(void (^)(id responseObject)) success
                  failure:(void (^)(NSError* error)) failure;

- (void)removeEntityPhoto:(NSString *)sessionID
                 entityID:(NSString *)entityID
                successed:(void (^)(id responseObject)) success
                  failure:(void (^)(NSError* error)) failure;

- (void)deleteProfilePhoto:(NSString *)sessionID
                      type:(NSString *)type
                 successed:(void (^)(id responseObject)) success
                   failure:(void (^)(NSError* error)) failure;

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
                     failure:(void (^)(NSError* error)) failure;

- (void)updateNotes:(NSString *)sessionID
          contactID:(NSString *)contactID
              notes:(NSString *)notes
          successed:(void (^)(id responseObject)) success
            failure:(void (^)(NSError* error)) failure;

- (void)removeContact:(NSString *)sessionID
            contactID:(NSString *)contactID
            successed:(void (^)(id responseObject)) success
              failure:(void (^)(NSError* error)) failure;

@end
