 //
//  YYYCommunication.m
//  Ginko
//
//  Created by Qi Song on 27/03/14.
//  Copyright (c) 2014 Qi Song. All rights reserved.
//

#import "Communication.h"

//#import "AFHTTPClient.h"
//#import "AFHTTPRequestOperation.h"

#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"
#import <AVFoundation/AVFoundation.h>

#define WEBAPI_FRIENDS_FOUND                @"/gps/friend/found"
#define WEBAPI_MYINFO                       @"/User/myinfo"
#define WEBAPI_USERINFO                     @"/UserInfo/getInfo"

#define WEBAPI_REQUESTSEND                  @"/ContactBuilder/request/send"
#define WEBAPI_REQUESTCANCEL                @"/ContactBuilder/request/cancel"
#define WEBAPI_GETREQUESTS                  @"/ContactBuilder/getRequests"

// Created by Zhun L.
#define WEBAPI_GETINVITATIONS               @"/ContactBuilder/getInvitations"
#define WEBAPI_DELETEINVITATION             @"/ContactBuilder/deleteInvitation"
#define WEBAPI_DELETEREQUEST                @"/ContactBuilder/deleteRequest"
#define WEBAPI_DELETESENTINVITATION         @"/ContactBuilder/cancelRequest"
#define WEBAPI_GETSENTINVITATIONS           @"/ContactBuilder/getSentInvitations"
#define WEBAPI_ANSWERREQUEST                @"/ContactBuilder/confirmRequest"
#define WEBAPI_ADDINVITATION                @"/ContactBuilder/addInvitation"
#define WEBAPI_GETCONTACTS                  @"/User/getContacts"
#define WEBAPI_GETMYPHOTO                   @"/UserInfo/getMyPhoto"
#define WEBAPI_GETSUGGESTIONS               @"/ContactBuilder/list/suggestion"
#define WEBAPI_SETNOTIFICATIONS             @"/User/notifications/update"
#define WEBAPI_LOGOUT                       @"/User/logout"
#define WEBAPI_CHANGEPWD                    @"/User/changePassword"
#define WEBAPI_GETDEACTIVATEREASON          @"/User/list/deactivatedreason"
#define WEBAPI_DEACTIVATE                   @"/User/deactivate"
#define WEBAPI_GETLOGINSETTINGS             @"/User/getLoginSettings"
#define WEBAPI_SENDVALIDLINK                @"/User/sendValidationLink"
#define WEBAPI_ADDLOGIN                     @"/User/addLogin"
#define WEBAPI_REMOVELOGIN                  @"/User/removeLogin"
#define WEBAPI_UPDATENOTE                   @"/ContactBuilder/contact/notes/update"
#define WEBAPI_GETNOTIFICATIONSETTING       @"/User/notifications/get"
#define WEBAPI_UPDATEISREAD                 @"/User/read/contact"
#define WEBAPI_GETPENDING                   @"/User/list/pending"
#define WEBAPI_GETCBEMAILVALID              @"/User/contact/summary"
#define WEBAPI_UPDATEPERMISSION             @"/ContactBuilder/permission/update"
#define WEBAPI_REMOVECONTACT                @"/ContactBuilder/removeFriend"
#define WEBAPI_GETCONTACTDETAIL             @"/User/getContactDetail"
#define WEBAPI_REMOVECONTACTSELECTED        @"/ContactBuilder/removeFriends"

// -----------------

#define WEBAPI_GPSON_OFF                    @"/gps/location/status"
#define WEBAPI_REMOVEFRIENDS                @"/gps/friends/remove"
#define WEBAPI_REMOVECONTACTS               @"/gps/detected/remove"

#define WEBAPI_UPDATE_LOCATION              @"/gps/location/update"
#define WEBAPI_CREATCHATBOARD				@"/im/board/create"
#define WEBAPI_SENDMESSAGE					@"/im/send"
#define WEBAPI_CHECKNEW						@"/im/checkNew"
#define WEBAPI_ADDNEWMEMBER					@"/im/board/addmember"
#define WEBAPI_LEAVEBOARD					@"/im/board/leave"
#define WEBAPI_SENDFILE						@"/im/file/send"
#define WEBAPI_GETCHATBOARD					@"/im/board/list"
#define WEBAPI_GETMESSAGE					@"/im/message/history/"
#define WEBAPI_GETBOARDINFORMATION          @"/im/board/"
#define WEBAPI_USERLOGIN					@"/User/login"
#define WEBAPI_GETFRIEND					@"/User/getfriends"

#define WEBAPI_SYNCUPDATEDCONTACTS          @"/User/syncUpdatedContacts"
#define WEBAPI_RECEIVEDUPDATEDCONTACTS		@"/User/receivedUpdatedContacts"

#define WEBAPI_ENTITYFOLLOW                 @"/entity/follower/follow"

#define WEBAPI_ENTITYSYNCUPDATED            @"/entity/sync_updated"
#define WEBAPI_ENTITYFETCHALL               @"/entity/fetch_all"

#define WEBAPI_ENTITYSYNCUPDATED_NEW            @"/entity/sync_updated_new"
#define WEBAPI_ENTITYFETCHALL_NEW               @"/entity/fetch_all_new"

#define WEBAPI_SELECTEDENTITYSUMMARY            @"/entity/follower/view/summary"

#define WEBAPI_GETALLCONTACTS               @"/gps/contact/list"
#define WEBAPI_GETDETECTEDCONTACTS          @"/gps/unexchanged/list"
#define WEBAPI_FILTERCONTACTS               @"/gps/contact/filter"
#define WEBAPI_GETFILTEREDCONTACTS          @"/gps/contact/filter/get"




@implementation Communication

@synthesize lstFavourite;

// Functions ;
#pragma mark - Shared Functions
+ ( Communication*)sharedManager
{
    __strong static Communication* sharedObject = nil ;
	static dispatch_once_t onceToken ;
    
	dispatch_once( &onceToken, ^{
        sharedObject = [[Communication alloc ] init ] ;
	});
    
    return sharedObject ;
}

#pragma mark - SocialCommunication
- (id)init
{
    self = [super init ] ;
    
    if( self )
    {
        // Location ;
		[self setLstFavourite:nil];
    }
    
    return self ;
}

#pragma mark - Web Service 2.0

- (void)sendToService:(NSDictionary*)_params
                  action:(NSString*)_action
                 success:(void (^)(id _responseObject))_success
                 failure:(void (^)(NSError* _error))_failure
{
	NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,_action ] ;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.responseSerializer = [AFJSONResponseSerializer serializer];
	manager.securityPolicy.allowInvalidCertificates = YES;
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
	[manager setRequestSerializer:requestSerializer];
	
	[manager POST:strUrl parameters:_params success:^(AFHTTPRequestOperation *operation, id _responseObject){
		
        if( _success )
        {
            _success( _responseObject);
        }
		
    } failure:^(AFHTTPRequestOperation *operation, NSError *_error) {
        if( _failure )
        {
            NSLog(@"%@",_error.description);
            _failure( _error);
            
        }
    }];
}

- (void)sendToServiceGet:(NSDictionary*)_params
					 action:(NSString*)_action
					success:(void (^)(id _responseObject))_success
					failure:(void (^)(NSError* _error))_failure
{
	NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,_action ] ;
	
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.responseSerializer = [AFJSONResponseSerializer serializer];
	manager.securityPolicy.allowInvalidCertificates = YES;
	
	AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
	[requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[manager setRequestSerializer:requestSerializer];
	[manager GET:strUrl parameters:_params success:^(AFHTTPRequestOperation *operation, id _responseObject)
    {
        if( _success )
        {
            _success( _responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *_error) {
        if( _failure )
        {
            NSLog(@"%@",_error.description);
            _failure( _error);
        }
    }];
}

- (void)sendToService:(NSDictionary*)_params
                  action:(NSString*)_action
					data:(NSData*)_data
					name:(NSString*)_name
				mimetype:(NSString*)_mimetype
                 success:(void (^)(id _responseObject))_success
                 failure:(void (^)(NSError* _error))_failure
{
    NSString *strUrl = [NSString stringWithFormat:@"%@%@", SERVER_URL, _action ] ;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.responseSerializer = [AFJSONResponseSerializer serializer];
	manager.securityPolicy.allowInvalidCertificates = YES;
	
	AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
	[requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[manager setRequestSerializer:requestSerializer];

	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-dd-hh-mm-ss"];
	
	NSString *strFileName = [NSString stringWithFormat:@"%@%@.jpg",[formatter stringFromDate:[NSDate date]], [AppDelegate sharedDelegate].userId];
	
    //post
	[manager POST:strUrl parameters:_params constructingBodyWithBlock:^(id<AFMultipartFormData> _formData) {
        
        if( _data )
        {
			[_formData appendPartWithFileData:_data
                                          name:_name
                                      fileName:strFileName
                                      mimeType:_mimetype ] ;
        }
        
    } success:^(AFHTTPRequestOperation *operation, id _responseObject) {
        
        if( _success )
        {
            _success( _responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *_error) {
        
        if( _failure )
        {
            _failure( _error);
        }
        
    }];
}

- (void)CreateChatBoard:(NSString*)_sessionid
				   userids:(NSString*)_userids
				 successed:(void (^)(id _responseObject))_success
				   failure:(void (^)(NSError* _error))_failure
{
	[self sendToService:nil action:[NSString stringWithFormat:@"%@?sessionId=%@&user_ids=%@",WEBAPI_CREATCHATBOARD,_sessionid,_userids] success:_success failure:_failure];
}

- (void)SendMessage:(NSString*)_sessionid
			  board_id:(NSString*)_boardid
			   message:(NSString*)_message
			 successed:(void (^)(id _responseObject))_success
			   failure:(void (^)(NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary ] ;
	[params setObject:_message				forKey:@"content" ] ;
	
	
	[self sendToService:params action:[NSString stringWithFormat:@"%@/%@?sessionId=%@",WEBAPI_SENDMESSAGE,_boardid,_sessionid] success:_success failure:_failure];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
	NSString* newStr = [NSString stringWithUTF8String:[_responseData bytes]];
	NSLog(@"%@",newStr);
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}

- (void)CheckNewMessage:(NSString*)_sessionid
				 successed:(void (^)(id _responseObject))_success
				   failure:(void (^)(NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary ] ;
	
    [params setObject:_sessionid				forKey:@"sessionId" ] ;
	
	[self sendToServiceGet:params action:WEBAPI_CHECKNEW success:_success failure:_failure];
}

- (void)AddNewMember:(NSString*)_sessionid
				boardid:(NSString*)_boardid
				userids:(NSString*)_userids
			  successed:(void (^)(id _responseObject))_success
				failure:(void (^)(NSError* _error))_failure
{
	[self sendToService:nil action:[NSString stringWithFormat:@"%@/%@?sessionId=%@&user_ids=%@",WEBAPI_ADDNEWMEMBER,_boardid,_sessionid,_userids] success:_success failure:_failure];
}

- (void)LeaveBoard:(NSString*)_sessionid
			  boardid:(NSString*)_boardid
			successed:(void (^)(id _responseObject))_success
			  failure:(void (^)(NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary ] ;
	
    [params setObject:_sessionid				forKey:@"sessionId" ] ;
	[params setObject:_boardid				forKey:@"board_id " ] ;
	
	[self sendToService:params action:WEBAPI_CHECKNEW success:_success failure:_failure];
}


- (void)SendFile:(NSString*)_sessionid
			   data:(NSData*)_data
			   name:(NSString*)_name
		   mimetype:(NSString*)_mimetype
			boardid:(NSString*)_boardid
		  successed:(void (^)(id _responseObject))_success
			failure:(void (^)(NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary ] ;
	
    [params setObject:_sessionid				forKey:@"sessionId" ] ;
	
	[self sendToService:nil action:[NSString stringWithFormat:@"%@/%@?sessionId=%@&file_type=%@",WEBAPI_SENDFILE,_boardid,_sessionid,@"photo"] data:_data name:_name mimetype:_mimetype success:_success failure:_failure];
}


- (void)GetChatBoards:(NSString*)_sessionid
			   successed:(void (^)(id _responseObject))_success
				 failure:(void (^)(NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary ] ;
	
    [params setObject:_sessionid				forKey:@"sessionId" ] ;
	[params setObject:@"json"				forKey:@"format" ] ;
	
	[self sendToServiceGet:params action:WEBAPI_GETCHATBOARD success:_success failure:_failure];
}

- (void)GetMessageHistory:(NSString*)_sessionid
					 boardid:(NSString*)_boardid
					  number:(NSString*)_number
					lastdays:(NSString*)_lastdays
				   successed:(void (^)(id _responseObject))_success
					 failure:(void (^)(NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary ] ;
	
    [params setObject:_sessionid				forKey:@"sessionId" ] ;
	[params setObject:_boardid				forKey:@"board_id" ] ;
	[params setObject:_number				forKey:@"number" ] ;
	[params setObject:_lastdays				forKey:@"lastDays" ] ;
	
	[self sendToServiceGet:params action:[NSString stringWithFormat:@"%@/%@",WEBAPI_GETMESSAGE,_boardid] success:_success failure:_failure];
}
- (void)GetBoardInformation:(NSString*)_sessionid
                  boardid:(NSString*)_boardid
                successed:(void (^)(id _responseObject))_success
                  failure:(void (^)(NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary ] ;
    
    [params setObject:_sessionid				forKey:@"sessionId" ] ;
    [params setObject:_boardid				forKey:@"board_id" ] ;
    
    [self sendToServiceGet:params action:[NSString stringWithFormat:@"%@%@",WEBAPI_GETBOARDINFORMATION,_boardid] success:_success failure:_failure];
}
- (void)UserLogin:(NSString*)_email
			password:(NSString*)_password
          clientType:(NSString*)_clientType
           deviceUID:(NSString*)_deviceUID
      deviceToken:(NSString*)_deviceToken
      voipToken:(NSString*)_voipToken
		   successed:(void (^)(id _responseObject))_success
			 failure:(void (^)(NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary ] ;
    NSString *url = @"";
    
    url = [NSString stringWithFormat:@"%@?email=%@&password=%@", WEBAPI_USERLOGIN, _email, _password];
	
    [params setObject:_email				forKey:@"email" ] ;
	[params setObject:_password			forKey:@"password" ] ;
    
    if (_clientType)
    {
        [params setObject:_clientType forKey:@"client_type"];
        url = [NSString stringWithFormat:@"%@&client_type=%@", url, _clientType];
    }
    
    if (_deviceUID)
    {
        [params setObject:_deviceUID forKey:@"device_uid"];
        url = [NSString stringWithFormat:@"%@&device_uid=%@", url, _deviceUID];
    }
    
    if (_deviceToken)
    {
        [params setObject:_deviceToken forKey:@"device_token"];
        url = [NSString stringWithFormat:@"%@&device_token=%@", url, _deviceToken];
    }
    if (_voipToken)
    {
        [params setObject:_voipToken forKey:@"voip_token"];
        url = [NSString stringWithFormat:@"%@&voip_token=%@", url, _voipToken];
    }
    

	[self sendToService:params action:url success:_success failure:_failure];
}

- (void)GetFriend:(NSString*)_sessionid
		   successed:(void (^)(id _responseObject))_success
			 failure:(void (^)(NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary ] ;
    [params setObject:_sessionid				forKey:@"sessionId" ] ;
	[params setObject:@"json"				forKey:@"format" ] ;
	[self sendToServiceGet:params action:WEBAPI_GETFRIEND success:_success failure:_failure];
}

- (void)GetRequests:(NSString*)_sessionid
		   successed:(void (^)(id _responseObject))_success
			 failure:(void (^)(NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary ] ;
    [params setObject:_sessionid				forKey:@"sessionId" ] ;
	[params setObject:@"json"				forKey:@"format" ] ;
	[self sendToServiceGet:params action:WEBAPI_GETREQUESTS success:_success failure:_failure];
}

- (void)GetInvitations:(NSString*)_sessionid
             successed:(void (^)(id _responseObject))_success
               failure:(void (^)(NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary ] ;
    [params setObject:_sessionid				forKey:@"sessionId" ] ;
	[params setObject:@"json"				forKey:@"format" ] ;
	[self sendToServiceGet:params action:WEBAPI_GETINVITATIONS success:_success failure:_failure];
}

- (void)GetSentInvitations:(NSString*)_sessionid
             successed:(void (^)(id _responseObject))_success
               failure:(void (^)(NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary ] ;
    [params setObject:_sessionid				forKey:@"sessionId" ] ;
	[params setObject:@"json"				forKey:@"format" ] ;
	[self sendToServiceGet:params action:WEBAPI_GETSENTINVITATIONS success:_success failure:_failure];
}

- (void)AddInvitations:(NSString *)_sessionid email:(NSString *)_email phone:(NSString *)phone successed:(void (^)(id))_success failure:(void (^)(NSError *))_failure {
    NSString *url = @"";
    if (_email)
        url = [NSString stringWithFormat:@"%@?sessionId=%@&email=%@", WEBAPI_ADDINVITATION, _sessionid, _email];
    else
        url = [NSString stringWithFormat:@"%@?sessionId=%@&phone=%@", WEBAPI_ADDINVITATION, _sessionid, phone];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSMutableDictionary *params = [NSMutableDictionary new];
//    params[@"sessionId"] = _sessionid;
//    if (_email)
//        params[@"email"] = _email;
//    if (phone)
//        params[@"phone"] = phone;
//    [params setObject:@"json" forKey:@"format"];
    [self sendToService:nil action:url success:_success failure:_failure];
}

- (void)GetFriendsFound:(NSString *)_sessionid
                   type:(NSString *)_type
                pageNum:(NSString *)_pageNum
           countPerPage:(NSString *)_countPerPage
              successed:(void (^)(id _responseObject))_success
                failure:(void (^)(NSError *))_failure
{
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params setObject:_sessionid forKey:@"sessionId"];
    [params setObject:_type forKey:@"type"];
    [params setObject:_pageNum forKey:@"pageNum"];
    [params setObject:_countPerPage forKey:@"countPerPage"];
    [params setObject:@"json" forKey:@"format"];
	[self sendToServiceGet:nil action:[NSString stringWithFormat:@"%@?sessionId=%@&type=%@&pageNum=%@&countPerPage=%@", WEBAPI_FRIENDS_FOUND, _sessionid, _type, _pageNum, _countPerPage] success:_success failure:_failure];
}

- (void) SetUpdateLocation:(NSString *)_sessionid
                 longitude:(NSString *)_longitude
                  latitude:(NSString *)_latitude
                 successed:(void (^)(id _responseObject))_success
                   failure:(void (^)(NSError *))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary ] ;
    [params setObject:_sessionid         forKey:@"sessionId"] ;
//    _latitude = @"42.342793";
//    _longitude = @"124.405383";
    [params setObject:_latitude          forKey:@"latitude"] ;
	[params setObject:_longitude			forKey:@"longitude"] ;
    [params setObject:@"json" forKey:@"format"];
	[self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&latitude=%@&longitude=%@", WEBAPI_UPDATE_LOCATION, _sessionid, _latitude, _longitude] success:_success failure:_failure];
}

- (void)GetMyInfo:(NSString *)_sessionid
      contact_uid:(NSString *)_contactId
        successed:(void (^)(id _responseObject))_success
          failure:(void (^)(NSError *))_failure
{
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params setObject:_sessionid forKey:@"sessionId"];
    [params setObject:@"json" forKey:@"format"];
    
    if (_contactId)
        [self sendToServiceGet:nil action:[NSString stringWithFormat:@"%@?sessionId=%@&contact_uid=%@", WEBAPI_USERINFO, _sessionid,_contactId] success:_success failure:_failure];
    else
        [self sendToServiceGet:nil action:[NSString stringWithFormat:@"%@?sessionId=%@", WEBAPI_USERINFO, _sessionid] success:_success failure:_failure];
}

- (void)getContactDetail:(NSString *)_sessionid
               contactId:(NSString *)_contactId
             contactType:(NSString *)_contactType
               successed:(void (^)(id _responseObject))_success
               failure:(void (^)(NSError *))_failure
{
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params setObject:_sessionid forKey:@"sessionId"];
    [params setObject:@"json" forKey:@"format"];
    
    if (_contactId)
    {
        [params setObject:_contactId forKey:@"contact_id"];
        [params setObject:_contactType forKey:@"contact_type"];
        [self sendToServiceGet:nil action:[NSString stringWithFormat:@"%@?sessionId=%@&contact_id=%@&contact_type=%@", WEBAPI_GETCONTACTDETAIL, _sessionid,_contactId, _contactType] success:_success failure:_failure];
    }
}

// Created by Zhun L.

- (void)GetContacts:(NSString *)_sessionid
             sortby:(NSString *)_sortBy
             search:(NSString *)_search
           category:(NSString *)_category
        contactType:(NSString *)_contactType
          successed:(void (^)(id _responseObject))_success
            failure:(void (^)(NSError *))_failure
{
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    NSString *strURL = [NSString stringWithFormat:@"%@?sessionId=%@", WEBAPI_GETCONTACTS, _sessionid];
    
    [params setObject:_sessionid forKey:@"sessionId"];

    if (_sortBy)
    {
        [params setObject:_sortBy forKey:@"sortby"];
        strURL = [NSString stringWithFormat:@"%@&sortby=%@",strURL,_sortBy];
    }
    
    if (_search)
    {
        [params setObject:_search forKey:@"search"];
        strURL = [NSString stringWithFormat:@"%@&search=%@",strURL,_search];
    }
    
    if (_category)
    {
        [params setObject:_category forKey:@"category"];
        strURL = [NSString stringWithFormat:@"%@&category=%@",strURL,_category];
    }
    
    if (_contactType)
    {
        [params setObject:_contactType forKey:@"contact_type"];
        strURL = [NSString stringWithFormat:@"%@&contact_type=%@",strURL,_contactType];
    }
    
    [params setObject:@"json" forKey:@"format"];
	[self sendToServiceGet:nil action:strURL success:_success failure:_failure];
}

- (void)GetContactsSync:(NSString *)_sessionid
             sortby:(NSString *)_sortBy
             search:(NSString *)_search
           category:(NSString *)_category
        contactType:(NSString *)_contactType
          successed:(void (^)(id _responseObject))_success
            failure:(void (^)(NSError *))_failure
{
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    NSString *strURL = [NSString stringWithFormat:@"%@?sessionId=%@", WEBAPI_GETCONTACTS, _sessionid];
    
    [params setObject:_sessionid forKey:@"sessionId"];
    
    if (_sortBy)
    {
        [params setObject:_sortBy forKey:@"sortby"];
        strURL = [NSString stringWithFormat:@"%@&sortby=%@",strURL,_sortBy];
    }
    
    if (_search)
    {
        [params setObject:_search forKey:@"search"];
        strURL = [NSString stringWithFormat:@"%@&search=%@",strURL,_search];
    }
    
    if (_category)
    {
        [params setObject:_category forKey:@"category"];
        strURL = [NSString stringWithFormat:@"%@&category=%@",strURL,_category];
    }
    
    if (_contactType)
    {
        [params setObject:_contactType forKey:@"contact_type"];
        strURL = [NSString stringWithFormat:@"%@&contact_type=%@",strURL,_contactType];
    }
    
    [params setObject:@"true" forKey:@"for_detail"];
    strURL = [NSString stringWithFormat:@"%@&for_detail=%@",strURL,@"true"];
    
    [params setObject:@"json" forKey:@"format"];
    [self sendToServiceGet:nil action:strURL success:_success failure:_failure];
}

- (void)GetSuggestions:(NSString *)_sessionid
                sortby:(NSString *)_sortBy
                search:(NSString *)_search
             successed:(void (^)(id _responseObject))_success
               failure:(void (^)(NSError *))_failure
{
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    NSString *strURL = [NSString stringWithFormat:@"%@?sessionId=%@", WEBAPI_GETSUGGESTIONS, _sessionid];
    
    [params setObject:_sessionid forKey:@"sessionId"];
    
//    if (_sortBy)
//    {
//        [params setObject:_sortBy forKey:@"sortby"];
//        strURL = [NSString stringWithFormat:@"%@&sortby=%@",strURL,_sortBy];
//    }
    if (_search)
    {
        [params setObject:_search forKey:@"q"];
        strURL = [NSString stringWithFormat:@"%@&q=%@",strURL,_search];
    }
    
    [params setObject:@"json" forKey:@"format"];
	[self sendToServiceGet:nil action:strURL success:_success failure:_failure];
}

- (void)GetPending:(NSString *)_sessionid
             successed:(void (^)(id _responseObject))_success
               failure:(void (^)(NSError *))_failure
{
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    NSString *strURL = [NSString stringWithFormat:@"%@?sessionId=%@", WEBAPI_GETPENDING, _sessionid];
    
    [params setObject:_sessionid forKey:@"sessionId"];
    [params setObject:@"json" forKey:@"format"];
    
	[self sendToServiceGet:nil action:strURL success:_success failure:_failure];
}

- (void) RequestSend:(NSString *)_sessionid
           contactId:(NSString *)_contactId
         sharingInfo:(NSString *)_sharingInfo
  sharedHomeFieldIds:(NSString *)_sharedHomeFieldIds
  sharedWorkFieldIds:(NSString *)_sharedWorkFieldIds
           phoneOnly:(BOOL)_phoneOnly
           emailOnly:(BOOL)_emailOnly
           successed:(void (^)(id _responseObject))_success
             failure:(void (^)(NSError *))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary ] ;
    
    [params setObject:_sessionid    forKey:@"sessionId"];
    [params setObject:_sharingInfo  forKey:@"sharing"];
    
    NSString * url = @"";
    
    [params setObject:_contactId    forKey:@"contact_uid"];
    url = [NSString stringWithFormat:@"%@?sessionId=%@&contact_uid=%@&sharing=%@", WEBAPI_REQUESTSEND, _sessionid, _contactId, _sharingInfo];
    
    if (![_sharedHomeFieldIds isEqualToString:@""])
    {
        url = [NSString stringWithFormat:@"%@&shared_home_fids=%@", url, _sharedHomeFieldIds];
    }
    if (![_sharedWorkFieldIds isEqualToString:@""])
    {
        url = [NSString stringWithFormat:@"%@&shared_work_fids=%@", url, _sharedWorkFieldIds];
    }
    if (_phoneOnly)
    {
        url = [NSString stringWithFormat:@"%@&phone_only=true", url];
        [params setObject:@"false"    forKey:@"phone_only"];
    }
    if (_emailOnly)
    {
        url = [NSString stringWithFormat:@"%@&email_only=true", url];
        [params setObject:@"false"    forKey:@"email_only"];
    }
    [params setObject:@"json" forKey:@"format"];
	[self sendToService:params action:url success:_success failure:_failure];
}

- (void) SendInvitation:(NSString *)_sessionid
            sharingInfo:(NSString *)_sharingInfo
                  email:(NSString *)_email
     sharedHomeFieldIds:(NSString *)_sharedHomeFieldIds
     sharedWorkFieldIds:(NSString *)_sharedWorkFieldIds
              phoneOnly:(BOOL)_phoneOnly
              emailOnly:(BOOL)_emailOnly
              successed:(void (^)(id _responseObject))_success
                failure:(void (^)(NSError *))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary ] ;
    
    [params setObject:_sessionid    forKey:@"sessionId"];
    [params setObject:_sharingInfo  forKey:@"sharing"];
    
    NSString * url = @"";
 
    [params setObject:_email    forKey:@"email"];
    url = [NSString stringWithFormat:@"%@?sessionId=%@&email=%@&sharing=%@", WEBAPI_REQUESTSEND, _sessionid, _email, _sharingInfo];

    if (![_sharedHomeFieldIds isEqualToString:@""])
    {
        url = [NSString stringWithFormat:@"%@&shared_home_fids=%@", url, _sharedHomeFieldIds];
    }
    if (![_sharedWorkFieldIds isEqualToString:@""])
    {
        url = [NSString stringWithFormat:@"%@&shared_work_fids=%@", url, _sharedWorkFieldIds];
    }
    if (_phoneOnly)
    {
        url = [NSString stringWithFormat:@"%@&phone_only=true", url];
        [params setObject:@"false"    forKey:@"phone_only"];
    }
    if (_emailOnly)
    {
        url = [NSString stringWithFormat:@"%@&email_only=true", url];
        [params setObject:@"false"    forKey:@"email_only"];
    }
    [params setObject:@"json" forKey:@"format"];
	[self sendToService:params action:url success:_success failure:_failure];
}

- (void)UpdateExchangePermission:(NSString *)_sessionid
                       contactId:(NSString *)_contactId
                     sharingInfo:(NSString *)_sharingInfo
              sharedHomeFieldIds:(NSString *)_sharedHomeFieldIds
              sharedWorkFieldIds:(NSString *)_sharedWorkFieldIds
                       phoneOnly:(BOOL)_phoneOnly
                       emailOnly:(BOOL)_emailOnly
                       successed:(void (^)(id _responseObject))_success
                         failure:(void (^)(NSError *))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary ] ;
    
    [params setObject:_sessionid    forKey:@"sessionId"];
    [params setObject:_sharingInfo  forKey:@"sharing"];
    [params setObject:_contactId forKey:@"contact_uid"];
    
    NSString * url = @"";
    
    url = [NSString stringWithFormat:@"%@?sessionId=%@&contact_uid=%@&sharing=%@", WEBAPI_UPDATEPERMISSION, _sessionid, _contactId, _sharingInfo];
    
    if (![_sharedHomeFieldIds isEqualToString:@""])
    {
        url = [NSString stringWithFormat:@"%@&shared_home_fids=%@", url, _sharedHomeFieldIds];
    }
    if (![_sharedWorkFieldIds isEqualToString:@""])
    {
        url = [NSString stringWithFormat:@"%@&shared_work_fids=%@", url, _sharedWorkFieldIds];
    }
    if (_phoneOnly)
    {
        url = [NSString stringWithFormat:@"%@&phone_only=true", url];
        [params setObject:@"false"    forKey:@"phone_only"];
    }
    if (_emailOnly)
    {
        url = [NSString stringWithFormat:@"%@&email_only=true", url];
        [params setObject:@"false"    forKey:@"email_only"];
    }
    [params setObject:@"json" forKey:@"format"];
	[self sendToService:params action:url success:_success failure:_failure];
}

- (void) AnswerRequest:(NSString *)_sessionid
           contactId:(NSString *)_contactId
         sharingInfo:(NSString *)_sharingInfo
    sharedHomeFieldIds:(NSString *)_sharedHomeFieldIds
    sharedWorkFieldIds:(NSString *)_sharedWorkFieldIds
           phoneOnly:(BOOL)_phoneOnly
           emailOnly:(BOOL)_emailOnly
           successed:(void (^)(id _responseObject))_success
             failure:(void (^)(NSError *))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary ] ;
    [params setObject:_sessionid    forKey:@"sessionId"];
    [params setObject:_contactId    forKey:@"contact_id"];
    [params setObject:_sharingInfo  forKey:@"answer"];
    NSString * url = [NSString stringWithFormat:@"%@?sessionId=%@&contact_id=%@&answer=%@", WEBAPI_ANSWERREQUEST, _sessionid, _contactId, _sharingInfo];
    if (![_sharedHomeFieldIds isEqualToString:@""])
    {
        url = [NSString stringWithFormat:@"%@&shared_home_fids=%@", url, _sharedHomeFieldIds];
    }
    if (![_sharedWorkFieldIds isEqualToString:@""])
    {
        url = [NSString stringWithFormat:@"%@&shared_work_fids=%@", url, _sharedWorkFieldIds];
    }
    if (_phoneOnly)
    {
        url = [NSString stringWithFormat:@"%@&phone_only=true", url];
        [params setObject:@"false"    forKey:@"phone_only"];
    }
    if (_emailOnly)
    {
        url = [NSString stringWithFormat:@"%@&email_only=true", url];
        [params setObject:@"false"    forKey:@"email_only"];
    }
    [params setObject:@"json" forKey:@"format"];
	[self sendToService:params action:url success:_success failure:_failure];
}

- (void) RequestCancel:(NSString *)_sessionid
            contactIds:(NSString *)_contactIds
             successed:(void (^)(id _responseObject))_success
               failure:(void (^)(NSError *))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary ] ;
    [params setObject:_sessionid    forKey:@"sessionId"];
    [params setObject:_contactIds    forKey:@"contact_uids"];
    NSString * url = [NSString stringWithFormat:@"%@?sessionId=%@&contact_uids=%@", WEBAPI_REQUESTCANCEL, _sessionid, _contactIds];
    [params setObject:@"json" forKey:@"format"];
	[self sendToService:params action:url success:_success failure:_failure];
}

- (void) DeleteInvitation:(NSString *)_sessionid
                   emails:(NSString *)_emails
                successed:(void (^)(id _responseObject))_success
                  failure:(void (^)(NSError *))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary ] ;
    [params setObject:_sessionid    forKey:@"sessionId"];
    [params setObject:_emails    forKey:@"emails"];
    NSString * url = [NSString stringWithFormat:@"%@?sessionId=%@&emails=%@", WEBAPI_DELETEINVITATION, _sessionid, _emails];
    [params setObject:@"json" forKey:@"format"];
	[self sendToService:params action:url success:_success failure:_failure];
}

- (void) DeleteRequest:(NSString *)_sessionid
            contactIds:(NSString *)_contactIds
             entityIds:(NSString *)_entityIds
             successed:(void (^)(id _responseObject))_success
               failure:(void (^)(NSError *))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary ] ;
    [params setObject:_sessionid    forKey:@"sessionId"];
    [params setObject:_contactIds    forKey:@"contact_ids"];
    [params setObject:_entityIds    forKey:@"entity_ids"];
    
    NSString * url = [NSString stringWithFormat:@"%@?sessionId=%@&contact_ids=%@&entity_ids=%@", WEBAPI_DELETEREQUEST, _sessionid, _contactIds, _entityIds];
//    [params setObject:@"json" forKey:@"format"];
	[self sendToService:params action:url success:_success failure:_failure];
}

- (void) DeleteSentInvitation:(NSString *)_sessionid
                       emails:(NSString *)_emails
                    successed:(void (^)(id _responseObject))_success
                      failure:(void (^)(NSError *))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary ] ;
    [params setObject:_sessionid    forKey:@"sessionId"];
    [params setObject:_emails    forKey:@"emails"];
    NSString * url = [NSString stringWithFormat:@"%@?sessionId=%@&emails=%@", WEBAPI_DELETESENTINVITATION, _sessionid, _emails];
    [params setObject:@"json" forKey:@"format"];
	[self sendToService:params action:url success:_success failure:_failure];
}

- (void)GetContacts:(NSString *)_sessionid
          successed:(void (^)(id _responseObject))_success
            failure:(void (^)(NSError *))_failure
{
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params setObject:_sessionid forKey:@"sessionId"];
    [params setObject:@"json" forKey:@"format"];
	[self sendToServiceGet:nil action:[NSString stringWithFormat:@"%@?sessionId=%@", WEBAPI_GETCONTACTS, _sessionid] success:_success failure:_failure];
}

- (void)GetMyPhoto:(NSString *)_sessionid
         successed:(void (^)(id _responseObject))_success
           failure:(void (^)(NSError *))_failure
{
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params setObject:_sessionid forKey:@"sessionId"];
    [params setObject:@"json" forKey:@"format"];
	[self sendToServiceGet:nil action:[NSString stringWithFormat:@"%@?sessionId=%@", WEBAPI_GETMYPHOTO, _sessionid] success:_success failure:_failure];
}

- (void)SetNotification:(NSString *)_sessionid
              deviceUID:(NSString *)_deviceUID
               exchange:(NSString *)_exchange
                   chat:(NSString *)_chat
                 sprout:(NSString *)_sprout
                profile:(NSString *)_profile
                 entity:(NSString *)_entity
              successed:(void (^)(id _responseObject))_success
                failure:(void (^)(NSError *))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary ] ;
    [params setObject:_sessionid    forKey:@"sessionId"];
    [params setObject:_exchange    forKey:@"exchange_request"];
    [params setObject:_chat    forKey:@"chat_msg"];
    [params setObject:_sprout    forKey:@"sprout"];
    [params setObject:_profile    forKey:@"profile_change"];
    [params setObject:_entity    forKey:@"entity"];
    
    NSString * url = @"";
    
    if (_deviceUID)
    {
        url = [NSString stringWithFormat:@"%@?sessionId=%@&device_uid=%@&exchange_request=%@&chat_msg=%@&sprout=%@&profile_change=%@&entity=%@", WEBAPI_SETNOTIFICATIONS, _sessionid, _deviceUID, _exchange, _chat, _sprout, _profile, _entity];
        [params setObject:_deviceUID forKey:@"device_uid"];
    }
    else
        url = [NSString stringWithFormat:@"%@?sessionId=%@&exchange_request=%@&chat_msg=%@&sprout=%@&profile_change=%@&entity=%@", WEBAPI_SETNOTIFICATIONS, _sessionid, _exchange, _chat, _sprout, _profile, _entity];
    
    [params setObject:@"json" forKey:@"format"];
	[self sendToService:params action:url success:_success failure:_failure];
}

- (void)Logout:(NSString *)_sessionid
     deviceUID:(NSString *)_deviceUID
     successed:(void (^)(id _responseObject))_success
       failure:(void (^)(NSError *))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary ] ;
    NSString * url = [NSString stringWithFormat:@"%@?sessionId=%@", WEBAPI_LOGOUT, _sessionid];
    
    [params setObject:_sessionid    forKey:@"sessionId"];
    
    if (_deviceUID)
    {
        [params setObject:_deviceUID    forKey:@"device_uid"];
        url = [NSString stringWithFormat:@"%@&device_uid=%@", url, _deviceUID];
    }
    
    [params setObject:@"json" forKey:@"format"];
	[self sendToService:params action:url success:_success failure:_failure];
}

- (void)ChangePwd:(NSString *)_sessionid
        curPwd:(NSString *)_curPwd
        newPwd:(NSString *)_newPwd
     successed:(void (^)(id _responseObject))_success
       failure:(void (^)(NSError *))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary ] ;
    NSString * url = [NSString stringWithFormat:@"%@?sessionId=%@&curpwd=%@&newpwd=%@", WEBAPI_CHANGEPWD, _sessionid, _curPwd, _newPwd];
    
    [params setObject:_sessionid    forKey:@"sessionId"];
    [params setObject:_curPwd forKey:@"curpwd"];
    [params setObject:_newPwd forKey:@"newpwd"];
    [params setObject:@"json" forKey:@"format"];
	[self sendToService:params action:url success:_success failure:_failure];
}

- (void)GetDeactivateReason:(NSString *)_sessionid
                  successed:(void (^)(id _responseObject))_success
                    failure:(void (^)(NSError *))_failure
{
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    NSString *strURL = [NSString stringWithFormat:@"%@?sessionId=%@", WEBAPI_GETDEACTIVATEREASON, _sessionid];
    
    [params setObject:_sessionid forKey:@"sessionId"];
    [params setObject:@"json" forKey:@"format"];
    
	[self sendToServiceGet:nil action:strURL success:_success failure:_failure];
}

- (void)Deactivate:(NSString *)_sessionid
            curPwd:(NSString *)_curPwd
        reasonCode:(NSString *)_reasonCode
       otherReason:(NSString *)_otherReason
         successed:(void (^)(id _responseObject))_success
           failure:(void (^)(NSError *))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary ] ;
    
    [params setObject:_sessionid    forKey:@"sessionId"];
    [params setObject:_curPwd forKey:@"password"];
    NSString * url = [NSString stringWithFormat:@"%@?sessionId=%@&password=%@", WEBAPI_DEACTIVATE, _sessionid, _curPwd];
    if (_reasonCode) {
        [params setObject:_reasonCode forKey:@"reason_code"];
        url = [NSString stringWithFormat:@"%@&reason_code=%@", url, _reasonCode];
    }
    if (_otherReason) {
        [params setObject:_otherReason forKey:@"other_reason"];
        url = [NSString stringWithFormat:@"%@&other_reason=%@", url, _otherReason];
    }
    [params setObject:@"json" forKey:@"format"];
	[self sendToService:params action:url success:_success failure:_failure];
}

- (void)GetLoginSettings:(NSString *)_sessionid
               successed:(void (^)(id _responseObject))_success
                 failure:(void (^)(NSError *))_failure
{
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    NSString *strURL = [NSString stringWithFormat:@"%@?sessionId=%@", WEBAPI_GETLOGINSETTINGS, _sessionid];
    
    [params setObject:_sessionid forKey:@"sessionId"];
    [params setObject:@"json" forKey:@"format"];
    
	[self sendToServiceGet:nil action:strURL success:_success failure:_failure];
}

- (void)AddLogin:(NSString *)_sessionid
           email:(NSString *)_email
       successed:(void (^)(id _responseObject))_success
         failure:(void (^)(NSError *))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary ] ;
    NSString * url = [NSString stringWithFormat:@"%@?sessionId=%@&email=%@", WEBAPI_ADDLOGIN, _sessionid, _email];
    
    [params setObject:_sessionid    forKey:@"sessionId"];
    [params setObject:_email forKey:@"email"];
    [params setObject:@"json" forKey:@"format"];
    
	[self sendToService:params action:url success:_success failure:_failure];
}

- (void)DeleteLogin:(NSString *)_sessionid
              email:(NSString *)_email
          successed:(void (^)(id _responseObject))_success
            failure:(void (^)(NSError *))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary ] ;
    NSString * url = [NSString stringWithFormat:@"%@?sessionId=%@&email=%@", WEBAPI_REMOVELOGIN, _sessionid, _email];
    
    [params setObject:_sessionid    forKey:@"sessionId"];
    [params setObject:_email forKey:@"email"];
    [params setObject:@"json" forKey:@"format"];
    
	[self sendToService:params action:url success:_success failure:_failure];
}

- (void)SendValidLink:(NSString *)_email
            successed:(void (^)(id _responseObject))_success
              failure:(void (^)(NSError *))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary ] ;
    NSString * url = [NSString stringWithFormat:@"%@?email=%@", WEBAPI_SENDVALIDLINK, _email];
    
    [params setObject:_email forKey:@"email"];
    [params setObject:@"json" forKey:@"format"];
    
	[self sendToService:params action:url success:_success failure:_failure];
}

- (void)UpdateNote:(NSString *)_sessionid
        contactIds:(NSString *)_contactIds
             notes:(NSString *)_notes
         successed:(void (^)(id _responseObject))_success
           failure:(void (^)(NSError *))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary ] ;
    
    [params setObject:_notes forKey:@"notes"];
    [params setObject:_sessionid    forKey:@"sessionId"];
    [params setObject:_contactIds forKey:@"contact_uid"];
    
    [params setObject:@"json" forKey:@"format"];

    _notes = [_notes stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString * url = [NSString stringWithFormat:@"%@?sessionId=%@&contact_uid=%@&notes=%@", WEBAPI_UPDATENOTE, _sessionid, _contactIds, _notes];
    
	[self sendToService:params action:url success:_success failure:_failure];
}

- (void)GetNotificationSetting:(NSString *)_sessionid
                     successed:(void (^)(id _responseObject))_success
                       failure:(void (^)(NSError *))_failure
{
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    NSString *strURL = [NSString stringWithFormat:@"%@?sessionId=%@", WEBAPI_GETNOTIFICATIONSETTING, _sessionid];
    
    [params setObject:_sessionid forKey:@"sessionId"];
    [params setObject:@"json" forKey:@"format"];
    
	[self sendToServiceGet:nil action:strURL success:_success failure:_failure];
}

- (void)UpdateIsRead:(NSString *)_sessionid
          contactIds:(NSString *)_contactIds
         contactType:(NSString *)_contactType
              isRead:(NSString *)_isRead
           successed:(void (^)(id _responseObject))_success
             failure:(void (^)(NSError *))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary ] ;
    
    [params setObject:_isRead forKey:@"is_read"];
    [params setObject:_sessionid    forKey:@"sessionId"];
    [params setObject:_contactIds forKey:@"contact_id"];
    [params setObject:_contactType forKey:@"contact_type"];
    
    [params setObject:@"json" forKey:@"format"];
    
    NSString * url = [NSString stringWithFormat:@"%@?sessionId=%@&contact_id=%@&contact_type=%@&is_read=%@", WEBAPI_UPDATEISREAD, _sessionid, _contactIds,_contactType, _isRead];
    
	[self sendToService:params action:url success:_success failure:_failure];
}

- (void)GetCBEmailValid:(NSString *)_sessionid
             successed:(void (^)(id _responseObject))_success
               failure:(void (^)(NSError *))_failure
{
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    NSString *strURL = [NSString stringWithFormat:@"%@?sessionId=%@", WEBAPI_GETCBEMAILVALID, _sessionid];
    
    [params setObject:_sessionid forKey:@"sessionId"];
    [params setObject:@"json" forKey:@"format"];
    
	[self sendToServiceGet:nil action:strURL success:_success failure:_failure];
}

- (void) RemoveContact:(NSString *)_sessionid
            contactIds:(NSString *)_contactIds
             successed:(void (^)(id _responseObject))_success
               failure:(void (^)(NSError *))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary ] ;
    [params setObject:_sessionid    forKey:@"sessionId"];
    [params setObject:_contactIds    forKey:@"contact_id"];
    NSString * url = [NSString stringWithFormat:@"%@?sessionId=%@&contact_id=%@", WEBAPI_REMOVECONTACT, _sessionid, _contactIds];
    [params setObject:@"json" forKey:@"format"];
	[self sendToService:params action:url success:_success failure:_failure];
}
- (void) RemoveContactSelected:(NSString *)_sessionid
            contactIds:(NSString *)_contactIds
             successed:(void (^)(id _responseObject))_success
               failure:(void (^)(NSError *))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary ] ;
    [params setObject:_sessionid    forKey:@"sessionId"];
    [params setObject:_contactIds    forKey:@"contact_ids"];
    NSString * url = [NSString stringWithFormat:@"%@?sessionId=%@&contact_ids=%@", WEBAPI_REMOVECONTACTSELECTED, _sessionid, _contactIds];
    [params setObject:@"json" forKey:@"format"];
    [self sendToService:params action:url success:_success failure:_failure];
}
// -----------------

- (void) DeleteDetectedFriends:(NSString *)_sessionid
                    contactIds:(NSString *)_contactIds
                   remove_type:(NSString *)_remove_type
                     successed:(void (^)(id _responseObject))_success
                       failure:(void (^)(NSError *))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary ] ;
    [params setObject:_sessionid    forKey:@"sessionId"];
    [params setObject:_contactIds    forKey:@"contact_uids"];
    NSString * url = [NSString stringWithFormat:@"%@?sessionId=%@&user_ids=%@&remove_type=%@", WEBAPI_REMOVEFRIENDS, _sessionid, _contactIds, _remove_type];
    [params setObject:@"json" forKey:@"format"];
	[self sendToService:params action:url success:_success failure:_failure];
}

- (void) DeleteDetectedContacts:(NSString *)_sessionid
                        userIDs:(NSString *)_userids
                      entityIDs:(NSString *)_entityids
                    remove_type:(NSString *)_remove_type
                      successed:(void (^)(id _responseObject))_success
                        failure:(void (^)(NSError *))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary ] ;
    [params setObject:_sessionid    forKey:@"sessionId"];
    [params setObject:_userids    forKey:@"user_ids"];
    [params setObject:_entityids    forKey:@"entity_ids"];
    NSString * url = [NSString stringWithFormat:@"%@?sessionId=%@&user_ids=%@&entity_ids=%@&remove_type=%@", WEBAPI_REMOVECONTACTS, _sessionid, _userids, _entityids, _remove_type];
    [params setObject:@"json" forKey:@"format"];
    [self sendToService:params action:url success:_success failure:_failure];
}

- (void)ChangeGPSStatus:(NSString *)_sessionid
                trun_on:(NSString *)_turn_on
              successed:(void (^)(id))_success
                failure:(void (^)(NSError *))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary ] ;
    //if (_sessionid) {
        [params setObject:_sessionid    forKey:@"sessionId"];
    //}else{
    //    [params setObject:@""    forKey:@"sessionId"];
    //}
    [params setObject:_turn_on    forKey:@"turn_on"];
    NSString * url = [NSString stringWithFormat:@"%@?sessionId=%@&turn_on=%@", WEBAPI_GPSON_OFF, _sessionid, _turn_on];
    [params setObject:@"json" forKey:@"format"];
	[self sendToService:params action:url success:_success failure:_failure];
}

- (void)updatedContactsSynced:(NSString *)sessionId
                    timeStamp:(NSString*)timeStamp
                    successed:(void (^)(id))_success
                      failure:(void (^)(NSError *))_failure
{
    NSString * url = [NSString stringWithFormat:@"%@?sessionId=%@&sync_timestamp=%@", WEBAPI_RECEIVEDUPDATEDCONTACTS, sessionId, timeStamp];
    [self sendToServiceGet:nil action:url success:_success failure:_failure];
}

- (void)syncUpdatedContacts:(NSString *)sessionId timeStamp:(NSString *)timestamp successed:(void (^)(id))_success failure:(void (^)(NSError *))_failure {
    NSString * url = [NSString stringWithFormat:@"%@?sessionId=%@&sync_timestamp=%@", WEBAPI_SYNCUPDATEDCONTACTS, sessionId, timestamp];
    [self sendToServiceGet:nil action:url success:_success failure:_failure];
}

- (void)followEntity:(NSString *)_sessionId
           entity_id:(NSString*)_entityId
           successed:(void (^)(id))_success
             failure:(void (^)(NSError *))_failure
{
    NSDictionary *params = @{@"sessionId":_sessionId, @"entity_id":_entityId};
    NSString *url = [NSString stringWithFormat:@"%@?sessionId=%@&entity_id=%@", WEBAPI_ENTITYFOLLOW, _sessionId, _entityId];
    [self sendToService:params action:url success:_success failure:_failure];
}

- (void)getPurpleContacts:(NSString *)_sessionId
                  pageNum:(NSInteger)pageNum
             countPerPage:(NSInteger)countPerPage
                  keyword:(NSString*)keyword
                successed:(void (^)(id))_success
                  failure:(void (^)(NSError *err))_failure {
    NSString *url = [NSString stringWithFormat:@"%@?sessionId=%@&pageNum=%@&countPerPage=%@", WEBAPI_GETALLCONTACTS, _sessionId, [NSString stringWithFormat:@"%ld",(long)pageNum],[NSString stringWithFormat:@"%ld",(long)countPerPage]];
    [self sendToServiceGet:nil action:url success:_success failure:_failure];
}

- (void)getDetectedContacts:(NSString *)_sessionId
                  pageNum:(NSInteger)pageNum
             countPerPage:(NSInteger)countPerPage
                  keyword:(NSString*)keyword
                successed:(void (^)(id))_success
                  failure:(void (^)(NSError *err))_failure {
    NSString *url = [NSString stringWithFormat:@"%@?sessionId=%@&pageNum=%@&countPerPage=%@", WEBAPI_GETDETECTEDCONTACTS, _sessionId, [NSString stringWithFormat:@"%ld",(long)pageNum],[NSString stringWithFormat:@"%ld",(long)countPerPage]];
    [self sendToServiceGet:nil action:url success:_success failure:_failure];
}

- (void)setFilter:(NSString *)_sessionId
             type:(NSInteger)type
         user_ids:(NSString*)user_ids
   remove_existed:(BOOL)remove_existed
        successed:(void (^)(id))_success
          failure:(void (^)(NSError *err))_failure {
    NSString *remove = (remove_existed) ? @"true":@"false";
    NSDictionary *params = @{@"sessionId":_sessionId, @"type":@(type), @"user_ids":user_ids, @"remove_existed":remove};
    NSString *url = [NSString stringWithFormat:@"%@?sessionId=%@&type=%@&user_ids=%@&remove_existed=%@", WEBAPI_FILTERCONTACTS, _sessionId, @(type), user_ids, remove];
    [self sendToService:params action:url success:_success failure:_failure];
}

- (void)getFilteredContacts:(NSString *)_sessionId
                  successed:(void (^)(id))_success
                    failure:(void (^)(NSError *err))_failure {
    NSString *url = [NSString stringWithFormat:@"%@?sessionId=%@", WEBAPI_GETFILTEREDCONTACTS, _sessionId];
    [self sendToServiceGet:nil action:url success:_success failure:_failure];
}
- (void)SyncUpdatedOfEntity:(NSString*)_sessionId
                  successed:(void (^)( id _responseObject))_success
                    failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId				forKey:@"sessionId"];
    
    [self sendToServiceGet:params action:[NSString stringWithFormat:@"%@",WEBAPI_ENTITYSYNCUPDATED] success:_success failure:_failure ];
}
- (void)FetchAllOfEntity:(NSString*)_sessionId
               successed:(void (^)( id _responseObject))_success
                 failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId				forKey:@"sessionId"];
    
    [self sendToServiceGet:params action:[NSString stringWithFormat:@"%@",WEBAPI_ENTITYFETCHALL] success:_success failure:_failure ];
}
- (void)SyncUpdatedOfEntityNew:(NSString*)_sessionId
                  successed:(void (^)( id _responseObject))_success
                    failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId				forKey:@"sessionId"];
    
    [self sendToServiceGet:params action:[NSString stringWithFormat:@"%@",WEBAPI_ENTITYSYNCUPDATED_NEW] success:_success failure:_failure ];
}
- (void)FetchAllOfEntityNew:(NSString*)_sessionId
               successed:(void (^)( id _responseObject))_success
                 failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId				forKey:@"sessionId"];
    
    [self sendToServiceGet:params action:[NSString stringWithFormat:@"%@",WEBAPI_ENTITYFETCHALL_NEW] success:_success failure:_failure ];
}
- (void)SelectedEntitySummary:(NSString*)_sessionId
                     entityId:(NSString*)_entityId
                  successed:(void (^)( id _responseObject))_success
                    failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId			forKey:@"sessionId"];
    [params setObject:_entityId				forKey:@"entity_id"];
    
    [self sendToServiceGet:params action:[NSString stringWithFormat:@"%@",WEBAPI_SELECTEDENTITYSUMMARY] success:_success failure:_failure ];
}


@end
