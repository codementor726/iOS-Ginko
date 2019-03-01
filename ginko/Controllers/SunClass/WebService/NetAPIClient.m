//
//  NetAPIClient.m
//
//  Created by mobidev on 5/16/14.
//  Copyright (c) 2014 iDevelopers. All rights reserved.
//

#import "NetAPIClient.h"

//static NSString * const kNetAPIBaseURLString = @"http://...";

@implementation NetAPIClient

static NetAPIClient* _sharedClient = nil;

+ (NetAPIClient *)sharedClient
{
    if ( _sharedClient == nil ) {
        
        _sharedClient = [[NetAPIClient alloc] init];
        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    }

    return _sharedClient;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        
    }
    
    return self ;
}

#pragma mark - Web Service

// send text data
- (void)sendToServiceByPOST:(NSString *)serviceAPIURL
                     params:(NSDictionary *)_params
                    success:(void (^)(id _responseObject))_success
                    failure:(void (^)(NSError *_error))_failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
	[requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[manager setRequestSerializer:requestSerializer];
    
    NSDictionary *parameters = _params;
    [manager POST:serviceAPIURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Success ;
        if (_success) {
            _success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog( @"Error : %@", error.description ) ;
        
        // Failture ;
        if (_failure) {
            _failure(error);
        }
    }];
}

// get text data
- ( void ) sendToServiceByGET : (NSString *) serviceAPIURL
                      params  : ( NSDictionary* ) _params
                      success : ( void (^)( id _responseObject ) ) _success
                      failure : ( void (^)( NSError* _error ) ) _failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
	[requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[manager setRequestSerializer:requestSerializer];
    
    [manager GET:serviceAPIURL parameters:_params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Success ;
        if (_success) {
            _success(responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog( @"Error : %@", error.description ) ;
        
        // Failture ;
        if (_failure) {
            _failure(error);
        }
    }];
}

// send json data
- (void)sendToServiceByJSONPOST:(NSString *)serviceAPIURL
                         params:(NSDictionary *)_params
                        success:(void (^)(id _responseObject))_success
                        failure:(void (^)(NSError *_error))_failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	
	[manager setRequestSerializer:requestSerializer];
    
    NSDictionary *parameters = _params;
    [manager POST:serviceAPIURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Success ;
        if (_success) {
            _success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog( @"Error : %@", error.description ) ;
        
        // Failture ;
        if (_failure) {
            _failure(error);
        }
    }];
}

//send photo/video data

- (void)sendToServiceByPOST:(NSString *)serviceAPIURL
                     params:(NSDictionary *)_params
                      media:(NSData* )_media
                  mediaType:(NSInteger)_mediaType // 0: photo, 1: video
                    success:(void (^)(id _responseObject))_success
                    failure:(void (^)(NSError* _error))_failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
	manager.securityPolicy.allowInvalidCertificates = YES;
    
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
	[requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[manager setRequestSerializer:requestSerializer];
    
    NSDictionary *parameters = _params;
    [manager POST:serviceAPIURL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        if (_media) {
            if (_mediaType == 0) {
                
                [formData appendPartWithFileData:_media
                                            name:@"photo"
                                        fileName:@"photo"
                                        mimeType:@"image/jpeg"];
            } else {
                [formData appendPartWithFileData:_media
                                            name:@"videfile"
                                        fileName:@"videfile"
                                        mimeType:@"video/quicktime"];
            }
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Success ;
        if (_success) {
            _success(responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // Failture ;
        if (_failure) {
            _failure(error);
        }
        
    }];
}

//----for upload profile photo----
- (void)sendToServiceByPOST:(NSString *)serviceAPIURL
                     params:(NSDictionary *)_params
                      media:(NSData* )_media
                  mediaType:(NSInteger)_mediaType // 0: photo, 1: video
                       name:(NSString *)name
                    success:(void (^)(id _responseObject))_success
                    failure:(void (^)(NSError* _error))_failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
	manager.securityPolicy.allowInvalidCertificates = YES;
    
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
	[requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[manager setRequestSerializer:requestSerializer];
	
    
    NSDictionary *parameters = _params;
    [manager POST:serviceAPIURL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        if (_media) {
            if (_mediaType == 0) {
                
                [formData appendPartWithFileData:_media
                                            name:name
                                        fileName:name
                                        mimeType:@"image/jpeg"];
            } else {
                [formData appendPartWithFileData:_media
                                            name:name
                                        fileName:name
                                        mimeType:@"video/quicktime"];
            }
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Success ;
        if (_success) {
            _success(responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // Failture ;
        if (_failure) {
            _failure(error);
        }
        
    }];
}


@end
