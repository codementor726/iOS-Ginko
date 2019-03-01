//
//  NetAPIClient.h
//
//  Created by mobidev on 5/16/14.
//  Copyright (c) 2014 iDevelopers. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFNetworking.h"
#import "CTConfig.h"

@interface NetAPIClient : AFHTTPSessionManager

+ (NetAPIClient *)sharedClient;

// send text data
- (void)sendToServiceByPOST:(NSString *)serviceAPIURL
               params:(NSDictionary*)_params
              success:(void (^)(id _responseObject))_success
              failure:(void (^)(NSError* _error))_failure;

// send json data
- (void)sendToServiceByJSONPOST:(NSString *)serviceAPIURL
                         params:(NSDictionary *)_params
                        success:(void (^)(id _responseObject))_success
                        failure:(void (^)(NSError *_error))_failure;

//send photo/video data
- (void)sendToServiceByPOST:(NSString *)serviceAPIURL
                     params:(NSDictionary *)_params
                      media:(NSData* )_media
                  mediaType:(NSInteger)_mediaType // 0: photo, 1: video
                    success:(void (^)(id _responseObject))_success
                    failure:(void (^)(NSError* _error))_failure;
// get text data
- (void)sendToServiceByGET:(NSString *)serviceAPIURL
                    params:(NSDictionary* )_params
                   success:(void (^)(id _responseObject))_success
                   failure:(void (^)(NSError* _error))_failure;

//----for upload profile photo----
- (void)sendToServiceByPOST:(NSString *)serviceAPIURL
                     params:(NSDictionary *)_params
                      media:(NSData* )_media
                  mediaType:(NSInteger)_mediaType // 0: photo, 1: video
                       name:(NSString *)name
                    success:(void (^)(id _responseObject))_success
                    failure:(void (^)(NSError* _error))_failure;


@end
