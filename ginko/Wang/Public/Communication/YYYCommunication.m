//
//  YYYCommunication.m
//  CruiseShip
//
//  Created by Yang Dandan on 25/10/13.
//  Copyright (c) 2013 Yang. All rights reserved.
//

#import "YYYCommunication.h"
#import "AppDelegate.h"
#import "NetAPIClient.h"

#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"
#import <AVFoundation/AVFoundation.h>

#define WEBAPI_CREATCHATBOARD				@"/im/board/create"
#define WEBAPI_SENDMESSAGE					@"/im/send"
#define WEBAPI_CHECKNEW						@"/im/checkNew"
#define WEBAPI_ADDNEWMEMBER					@"/im/board/addmember"
#define WEBAPI_SENDFILE						@"/im/file/send"
#define WEBAPI_GETCHATBOARD					@"/im/board/list"
#define WEBAPI_GETMESSAGE					@"/im/message/history/"
#define WEBAPI_USERLOGIN					@"/User/login"
#define WEBAPI_CHECKSESSION                 @"/User/checkSession"
#define WEBAPI_GETFRIEND					@"/User/getfriends"
#define WEBAPI_LEAVEBOARD					@"/im/boards/leave"
#define WEBAPI_CLEARMESSAGE					@"/im/message/clear/"
#define WEBAPI_DELETEMESSAGES				@"/im/delete/messages/"
#define WEBAPI_GETCONTACTINFO				@"/UserInfo/getContactInfo"
#define WEBAPI_READMESSAGE					@"/im/read/messages/"
#define WEBAPI_FORGOTPASSWORD				@"/User/sendpassword"
#define WEBAPI_SIGNUP						@"/User/register"
#define WEBAPI_SENDVALIDATION				@"/User/sendValidationLink"
#define WEBAPI_ACTIVATEEMAIL				@"/User/acceptLogin"
#define WEBAPI_GETMYUSERINFO				@"/UserInfo/getInfo"
#define WEBAPI_LOGINBYOPENID				@"/User/loginByOpenId"
#define WEBAPI_TRADECARD					@"/tradecard/image/put"
#define WEBAPI_MULTIPLEUPLOAD				@"/tradecard/image/multipleUpload"
#define WEBAPI_SETINFO						@"/UserInfo/setInfo"
#define WEBAPI_UPLOADVIDEO					@"/tradecard/video/upload"
#define WEBAPI_GETINFO						@"/UserInfo/getInfo"
#define WEBAPI_UPDATEUSERPRIVILEGE			@"/UserInfo/updatePrivilege"
//wang class ae
#define WEBAPI_UPLOADVIDEO					@"/tradecard/video/upload"
#define WEBAPI_GETINFO						@"/UserInfo/getInfo"
#define WEBAPI_UPLOADENTITYVIDEO			@"/entity/video/upload"
#define WEBAPI_CREATEUPDATEENTITY			@"/entity/save"
#define WEBAPI_DELETEENTITY					@"/entity/delete"
#define WEBAPI_SETENTITYINFO				@"/entity/info/save"
#define WEBAPI_DELETEENTITYINFO				@"/entity/info/delete"
#define WEBAPI_ENTITYPOWEFULCREATE			@"/entity/create"
#define WEBAPI_MULTIPLEUPLOADENTITY			@"/entity/image/multiple/upload"
#define WEBAPI_REMOVEENTITYIMAGE			@"/entity/image/remove"
#define WEBAPI_REMOVEENTITYVIDEO			@"/entity/video/remove"

//ee class
#define WEBAPI_GETCATEGORYENTITY			@"/entity/category/get/"
#define WEBAPI_GETENTITYDEAIL				@"/entity/get"
#define WEBAPI_LISTENTITY                   @"/entity/list"

//Entity Messenger
#define WEBAPI_GETENTITYFOLLOWERVIEW		@"/entity/follower/view"
#define WEBAPI_GETENTITYFOLLOWERVIEWNEW     @"/entity/follower/view_new"
#define WEBAPI_ENTITYFOLLOW                 @"/entity/follower/follow"
#define WEBAPI_ENTITYUNFOLLOW               @"/entity/follower/unfollow"
#define WEBAPI_FOLLOWERSETNOTES             @"/entity/follower/notes/update"
#define WEBAPI_LISTMESSAGES                 @"/entity/message/list"
#define WEBAPI_CLEARMESSAGES                @"/entity/message/clear"
#define WEBAPI_LISTMESSAGEBOARD             @"/entity/message/board/list"
#define WEBAPI_LISTENTITYMESSAGEHISTORY     @"/entity/follower/messagewall"
#define WEBAPI_SENDENTITYMESSAGE            @"/entity/message/formsend"
#define WEBAPI_SENDENTITYFILE               @"/entity/message/sendfile"
#define WEBAPI_DELETEENTITYMESSAGE          @"/entity/message/delete"
#define WEBAPI_INVITEENTITYFRIENDS          @"/entity/invite"
#define WEBAPI_DELETEFOLLOWERS              @"/entity/follower/delete"
#define WEBAPI_GETENTITYCONTACTS            @"/entity/listContacts"

//Group
#define WEBAPI_ADDGROUP                     @"/contact/group/add"
#define WEBAPI_DELETEGROUP                  @"/contact/group/delete"
#define WEBAPI_RENAMEGROUP                  @"/contact/group/rename"
#define WEBAPI_ADDUSER                      @"/contact/group/addUser"
#define WEBAPI_REMOVEUSER                   @"/contact/group/removeUser"
#define WEBAPI_LISTGROUP                    @"/contact/group/list"
#define WEBAPI_GETUSERS                     @"/contact/group/getusers"
#define WEBAPI_GETREMAININGCONTACTS         @"/contact/group/getDontAddedContacts"
#define WEBAPI_MOVEGROUP                    @"/contact/group/order/move"
#define WEBAPI_MOVEBATCHGROUP               @"/contact/group/order/batch/move"
//Search
#define WEBAPI_GETSEARCHCONTACTS            @"/User/contact/search"

#define WEBAPI_REMOVEPROFILE                @"/UserInfo/removeProfile"

#define WEBAPI_SETWIZARDPAGE                @"/User/setWizardpage"

//Archive
#define WEBAPI_GETPROFILEIMAGEHISTORY       @"/tradecard/image/history/list"
#define WEBAPI_GETPROFILEVIDEOHISTORY       @"/tradecard/video/history/list"
#define WEBAPI_DELETEPROFILEIMAGEHISTORY    @"/tradecard/image/history/delete"
#define WEBAPI_DELETEPROFILEVIDEOHISTORY    @"/tradecard/video/history/delete"
#define WEBAPI_GETENTITYIMAGEHISTORY        @"/entity/image/history/list"
#define WEBAPI_GETENTITYVIDEOHISTORY        @"/entity/video/history/list"
#define WEBAPI_DELETEENTITYIMAGEHISTORY     @"/entity/image/history/delete"
#define WEBAPI_DELETEENTITYVIDEOHISTORY     @"/entity/video/history/delete"

#define WEBAPI_GETPROFILEIMAGEARCHIVE       @"/tradecard/image/archive/list"
#define WEBAPI_DELETEPROFILEIMAGEARCHIVE    @"/tradecard/image/archive/delete"
#define WEBAPI_PICKUPPROFILEIMAGEARCHIVE    @"/tradecard/image/archive/pickup"

#define WEBAPI_GETENTITYIMAGEARCHIVE       @"/entity/image/archive/list"
#define WEBAPI_DELETEENTITYIMAGEARCHIVE    @"/entity/image/archive/delete"
#define WEBAPI_PICKUENTITYIMAGEARCHIVE     @"/entity/image/archive/pickup"

#define WEBAPI_DELETEPROFILEVIDEO           @"/tradecard/video/delete"
#define WEBAPI_DELETEPHOTO                  @"/tradecard/image/remove"

// Verify SMS
#define WEBAPI_GETVERIFYCODE                @"/User/phone/get_verify_code"
#define WEBAPI_VERIFYSMSCODE                @"/User/phone/verify"

#define WEBAPI_CHECKUSERS                   @"/ContactBuilder/checkUsers"
#define WEBAPI_INVITEUSERS                   @"/ContactBuilder/invite"
#define WEBAPI_GETEXCHANGEINVITES           @"/ContactBuilder/getExchangeInvites"
#define WEBAPI_INVITESEND                   @"/ContactBuilder/invite/send"

//Favorite
#define WEBAPI_ADDFAVORITECONTACT           @"/User/favorite/contact"
#define WEBAPI_REMOVEFAVORITECONTACT        @"/User/unfavorite/contact"

//directory
#define WEBAPI_GETLISTDIRECTORY                         @"/directory/list"
#define WEBAPI_GETDIRECTORYDETAILS                      @"/directory/get"
#define WEBAPI_GETCHECKAVAIL                            @"/directory/checkAvail"
#define WEBAPI_CREATEDIRECTORY                          @"/directory/create"
#define WEBAPI_UPDATEDIRECTORY                          @"/directory/update"
#define WEBAPI_DELETEDIRECTORY                          @"/directory/delete"
#define WEBAPI_INVITEDIRECTORY                          @"/directory/invite"
#define WEBAPI_REMOVEINVITEDIRECTORY                    @"/directory/removeInvite"
#define WEBAPI_GETLISTINVITEDIRECTORY                   @"/directory/listInvite"
#define WEBAPI_GETCONFIRMEDANDREQEUSTEDIDSIRECTORY      @"/directory/getConfirmedAndRequestedIds"
#define WEBAPI_GETLISTCONFIRMEDDIRECTORY                @"/directory/listConfirmed"
#define WEBAPI_GETLISTREQUESTDIRECTORY                  @"/directory/listRequest"
#define WEBAPI_REQUESTAPPROVEDIRECTORY                  @"/directory/request/approve"
#define WEBAPI_REQUESTDELETEDIRECTORY                   @"/directory/request/remove"
#define WEBAPI_REMOVEMEMBERDIRECTORY                    @"/directory/removeMember"
#define WEBAPI_CHECKEDEXISEMEMBERDIRECTORY              @"/directory/member/checkExisted"
#define WEBAPI_JOINMEMBERDIRECTORY                      @"/directory/member/join"
#define WEBAPI_GETPERMISSIONMEMBERDIRECTORY             @"/directory/member/getPermission"
#define WEBAPI_UPDATEPERMISSIONMEMBERDIRECTORY          @"/directory/member/updatePermission"
#define WEBAPI_GETLISTJOINEDMEMBERDIRECTORY             @"/directory/member/listJoined"
#define WEBAPI_GETLISTRECEIVEDINVITEMEMBERDIRECTORY     @"/directory/member/listReceivedInvite"
#define WEBAPI_GETLISTSENTREQUESTMEMBERDIRECTORY        @"/directory/member/listSentRequest"
#define WEBAPI_UPLOADDIRECTORYPROFILEIMAGE              @"/directory/profile/image/upload"
#define WEBAPI_REMOVEDIRECTORYPROFILEIMAGE              @"/directory/profile/image/remove"
#define WEBAPI_GETALLMEMBERSOFDIRECTORY                 @"/directory/member/list"
#define WEBAPI_DIRECTORYMEMBERQUIT                      @"/directory/member/quit"
#define WEBAPI_DIRECTORYMEMBERINFO                      @"/directory/member/detail"
#define WEBAPI_DIRECTORYVALIDATEEMAIL                   @"/directory/member/validateEmail"
#define WEBAPI_DIRECTORYMEMBERCANCELJOINREQUEST         @"/directory/member/cancelJoinRequest"
#define WEBAPI_DIRECTORYMEMBERREMOVEJOININVITE          @"/directory/member/removeJoinInvite"

#define WEBAPI_DIRECTORYCHATCREATEBOARD                 @"/im/board/directory/create"
#define WEBAPI_DIRECTORYMEMBERSINFOFORCHAT              @"/im/getMemberInfo/"


//video/voice conference
#define WEBAPI_VIDEOSTARTFORCONFERENCE                  @"/im/video/start/"
#define WEBAPI_VOIDOACCEPTFORCONFERENCE                 @"/im/video/accept/"
#define WEBAPI_VIDEOCANCELFORCONFERENCE                 @"/im/video/cancel/"
#define WEBAPI_VIDEOHANGUPFORCONFERENCE                 @"/im/video/hangup/"
#define WEBAPI_VIDEODADASEND                            @"/im/video/data/"
#define WEBAPI_VIDEODATAGET                             @"/im/video/data/get/"
#define WEBAPI_INVITEMEMBERONCONFERENCE                 @"/im/video/addmember/"
#define WEBAPI_TURNSTATUSOFVIDEOCONFERENCE              @"/im/video/turnvideo/"
#define WEBAPI_TURNSTATUSOFAUDIOCONFERENCE              @"/im/video/turnaudio/"
#define WEBAPI_REJECTINGOTHERCALLING                    @"/im/video/reject"


@implementation YYYCommunication

// Functions ;
#pragma mark - Shared Functions
+ ( YYYCommunication*)sharedManager
{
    __strong static YYYCommunication* sharedObject = nil ;
	static dispatch_once_t onceToken ;
    
	dispatch_once( &onceToken, ^{
        sharedObject = [[YYYCommunication alloc]init];
	});
    
    return sharedObject ;
}

#pragma mark - SocialCommunication
- (id)init
{
    self = [super init];
    
    if( self )
    {
        
    }
    
    return self ;
}

#pragma mark - Web Service 2.0

- (void)download:(NSString *)url
        fileName:(NSString *)fileName
        success:(void (^)( NSString * str))_success
        failure:(void (^)( NSError* _error))_failure
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Successfully downloaded file to %@", path);
        _success(path);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    [operation start];
}

- (void)sendToService:(NSDictionary*)_params
                  action:(NSString*)_action
                 success:(void (^)( id _responseObject))_success
                 failure:(void (^)( NSError* _error))_failure
{
	NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,_action];
	
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.responseSerializer = [AFJSONResponseSerializer serializer];
	manager.securityPolicy.allowInvalidCertificates = YES;
	
	AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
	[requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[manager setRequestSerializer:requestSerializer];
	
	[manager.requestSerializer setTimeoutInterval:180];
	
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
					success:(void (^)( id _responseObject))_success
					failure:(void (^)( NSError* _error))_failure
{
	NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,_action];
	
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.responseSerializer = [AFJSONResponseSerializer serializer];
	manager.securityPolicy.allowInvalidCertificates = YES;
	
	AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
	[requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[manager setRequestSerializer:requestSerializer];
	
	[manager GET:strUrl parameters:_params success:^(AFHTTPRequestOperation *operation, id _responseObject){
		
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

- (void)sendToMultipleUploadService:(NSDictionary*)_params
								action:(NSString*)_action
							background:(NSData*)_background
							foreground:(NSData*)_foreground
							   success:(void (^)( id _responseObject))_success
							   failure:(void (^)( NSError* _error))_failure
{
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,_action];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.responseSerializer = [AFJSONResponseSerializer serializer];
	manager.securityPolicy.allowInvalidCertificates = YES;
	
	AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
	[requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[manager setRequestSerializer:requestSerializer];
	
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-dd-hh-mm-ss"];
	
	NSString *strFileName = [NSString stringWithFormat:@"%@%@.jpg",[formatter stringFromDate:[NSDate date]],[AppDelegate sharedDelegate].userId];
	
	//post
	[manager POST:strUrl parameters:_params constructingBodyWithBlock:^(id<AFMultipartFormData> _formData) {
        
        if( _background )
        {
			[_formData appendPartWithFileData:_background
                                          name:@"background"
                                      fileName:strFileName
                                      mimeType:@"image/jpeg"];
		}
		
		if (_foreground)
		{
			[_formData appendPartWithFileData:_foreground
                                          name:@"frontground"
                                      fileName:strFileName
                                      mimeType:@"image/jpeg"];
		}
        
    } success:^(AFHTTPRequestOperation *operation, id _responseObject) {
        
        if( _success )
        {
            _success( _responseObject);
        }
//        NSString *str = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
//        NSLog(@"succeed response: %@", str);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *_error) {
        
        if( _failure )
        {
            _failure( _error);
        }
//        NSString *str = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
//        NSLog(@"failure response: %@", str);
//        NSLog( @"Error:%@", _error.description);
    }];
}

- (void)sendToService:(NSDictionary*)_params
                  action:(NSString*)_action
					data:(NSData*)_data
			   thumbnail:(NSData*)_thumbnail
					name:(NSString*)_name
				mimetype:(NSString*)_mimetype
                 success:(void (^)( id _responseObject))_success
                 failure:(void (^)( NSError* _error))_failure
{
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,_action];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.responseSerializer = [AFJSONResponseSerializer serializer];
	manager.securityPolicy.allowInvalidCertificates = YES;
	
	AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
	[requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-dd-hh-mm-ss"];
	
	NSString *strFileName = @"";
	
	if ([_mimetype isEqualToString:@"image/jpeg"])
	{
		strFileName = [NSString stringWithFormat:@"%@%@.jpg",[formatter stringFromDate:[NSDate date]], [AppDelegate sharedDelegate].userId];
	}
	else if ([_mimetype isEqualToString:@"audio/aac"])
	{
		strFileName = [NSString stringWithFormat:@"%@%@.aac",[formatter stringFromDate:[NSDate date]], [AppDelegate sharedDelegate].userId];
	}
	else if ([_mimetype isEqualToString:@"video/quicktime"])
	{
//		strFileName = [NSString stringWithFormat:@"%@%@.mov",[formatter stringFromDate:[NSDate date]],[[YYYCommunication sharedManager].me objectForKey:@"user_id"]];
        strFileName = [NSString stringWithFormat:@"%@%@.mp4",[formatter stringFromDate:[NSDate date]], [AppDelegate sharedDelegate].userId];
	}

	//post
	[manager POST:strUrl parameters:_params constructingBodyWithBlock:^(id<AFMultipartFormData> _formData) {
        
        if( _data )
        {
			[_formData appendPartWithFileData:_data
                                          name:_name
                                      fileName:strFileName
                                      mimeType:_mimetype];
			
			if (_thumbnail)
			{
//				[_formData appendPartWithFileData:_thumbnail
//											  name:@"thumbnail"
//										  fileName:[strFileName stringByReplacingOccurrencesOfString:@".mov" withString:@".jpg"]
//										  mimeType:@"image/jpeg"];
                [_formData appendPartWithFileData:_thumbnail
                                              name:@"thumbnail"
                                          fileName:[strFileName stringByReplacingOccurrencesOfString:@".mp4" withString:@".jpg"]
                                          mimeType:@"image/jpeg"];
			}
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

- (void)sendToServiceJSON:(NSString *)action
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
    
	manager.requestSerializer = requestSerializer;
	
	[manager POST:action parameters:_params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Success ;
        if (_success)
		{
            _success(responseObject);
        }
		
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog( @"Error:%@", error.description);
        
        // Failture ;
        if (_failure)
		{
            _failure(error);
        }
    }];
}

//Wang class AE
- (void)sendToServiceCreateEntity:(NSDictionary*)_params
							  action:(NSString*)_action
						  background:(NSData*)_background
						  foreground:(NSData*)_foreground
							 success:(void (^)( id _responseObject))_success
							 failure:(void (^)( NSError* _error))_failure
{
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",SERVER_URL,_action];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.responseSerializer = [AFJSONResponseSerializer serializer];
	manager.securityPolicy.allowInvalidCertificates = YES;
	
    //	AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    //	[requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    //	[requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    //	[manager setRequestSerializer:requestSerializer];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-dd-hh-mm-ss"];
	
	NSString *strFileName = [NSString stringWithFormat:@"%@%@.jpg",[formatter stringFromDate:[NSDate date]],[AppDelegate sharedDelegate].userId];
	
	//post
	[manager POST:strUrl parameters:_params constructingBodyWithBlock:^(id<AFMultipartFormData> _formData) {
        
        if( _background )
        {
			[_formData appendPartWithFileData:_background
                                          name:@"background"
                                      fileName:strFileName
                                      mimeType:@"image/jpeg"];
		}
		
		if (_foreground)
		{
			[_formData appendPartWithFileData:_foreground
                                          name:@"frontground"
                                      fileName:strFileName
                                      mimeType:@"image/jpeg"];
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
				 successed:(void (^)( id _responseObject))_success
				   failure:(void (^)( NSError* _error))_failure
{
	[self sendToService:nil action:[NSString stringWithFormat:@"%@?sessionId=%@&user_ids=%@",WEBAPI_CREATCHATBOARD,_sessionid,_userids] success:_success failure:_failure ];
}

- (void)SendMessage:(NSString*)_sessionid
			  board_id:(NSNumber*)_boardid
			   message:(NSString*)_message
			 successed:(void (^)( id _responseObject))_success
			   failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	[params setObject:_message				forKey:@"content"];
	
	
	[self sendToService:params action:[NSString stringWithFormat:@"%@/%@?sessionId=%@",WEBAPI_SENDMESSAGE,[_boardid stringValue],_sessionid] success:_success failure:_failure ];
}

- (void)CheckNewMessage:(NSString*)_sessionid
				 successed:(void (^)( id _responseObject))_success
				   failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	
    [params setObject:_sessionid				forKey:@"sessionId"];
	
	[self sendToServiceGet:params action:WEBAPI_CHECKNEW success:_success failure:_failure ];
}

- (void)AddNewMember:(NSString*)_sessionid
				boardid:(NSNumber*)_boardid
				userids:(NSString*)_userids
			  successed:(void (^)( id _responseObject))_success
				failure:(void (^)( NSError* _error))_failure
{
	[self sendToService:nil action:[NSString stringWithFormat:@"%@/%@?sessionId=%@&user_ids=%@",WEBAPI_ADDNEWMEMBER,_boardid,_sessionid,_userids] success:_success failure:_failure ];
}

- (void)LeaveBoard:(NSString*)_sessionid
			 boardids:(NSString*)_boardids
			successed:(void (^)( id _responseObject))_success
			  failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	
    [params setObject:_sessionid				forKey:@"sessionId"];
	[params setObject:_boardids				forKey:@"board_ids"];
	
	[self sendToService:nil action:[NSString stringWithFormat:@"%@?sessionId=%@&board_ids=%@",WEBAPI_LEAVEBOARD,_sessionid,_boardids] success:_success failure:_failure ];
}


- (void)SendFile:(NSString*)_sessionid
			   data:(NSData*)_data
		  thumbnail:(NSData*)_thumbnail
			   name:(NSString*)_name
		   mimetype:(NSString*)_mimetype
			boardid:(NSNumber*)_boardid
		  successed:(void (^)( id _responseObject))_success
			failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	
    [params setObject:_sessionid				forKey:@"sessionId"];
	
	if ([_mimetype isEqualToString:@"image/jpeg"])
	{
		[self sendToService:nil action:[NSString stringWithFormat:@"%@/%@?sessionId=%@&file_type=%@",WEBAPI_SENDFILE,_boardid,_sessionid,@"photo"] data:_data thumbnail:nil name:_name mimetype:_mimetype success:_success failure:_failure ];
	}
	else if ([_mimetype isEqualToString:@"audio/aac"])
	{
		[self sendToService:nil action:[NSString stringWithFormat:@"%@/%@?sessionId=%@&file_type=%@",WEBAPI_SENDFILE,_boardid,_sessionid,@"voice"] data:_data thumbnail:nil name:_name mimetype:_mimetype success:_success failure:_failure ];
	}
	else if ([_mimetype isEqualToString:@"video/quicktime"])
	{
		[self sendToService:nil action:[NSString stringWithFormat:@"%@/%@?sessionId=%@&file_type=%@",WEBAPI_SENDFILE,_boardid,_sessionid,@"video"] data:_data thumbnail:_thumbnail name:_name mimetype:_mimetype success:_success failure:_failure ];
	}
}

- (void)GetChatBoards:(NSString*)_sessionid
			   successed:(void (^)( id _responseObject))_success
				 failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	
    [params setObject:_sessionid				forKey:@"sessionId"];
	[params setObject:@"json"				forKey:@"format"];
	
	[self sendToServiceGet:params action:WEBAPI_GETCHATBOARD success:_success failure:_failure ];
}

- (void)GetMessageHistory:(NSString*)_sessionid
                  boardid:(NSNumber*)_boardid
                   number:(NSString*)_number
                 lastdays:(NSString*)_lastdays
              earlierThan:(NSDate *)earlierThan
                laterThan:(NSDate *)laterThan
                successed:(void (^)( id _responseObject))_success
                  failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	
    [params setObject:_sessionid				forKey:@"sessionId"];
	[params setObject:_boardid				forKey:@"board_id"];
	[params setObject:_number				forKey:@"number"];
	[params setObject:_lastdays				forKey:@"lastDays"];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    if (earlierThan)
        params[@"earlier_than"] = [formatter stringFromDate:earlierThan];
    
    if (laterThan)
        params[@"later_than"] = [formatter stringFromDate:laterThan];
	
	[self sendToServiceGet:params action:[NSString stringWithFormat:@"%@/%@",WEBAPI_GETMESSAGE,_boardid] success:_success failure:_failure ];
}

- (void)UserLogin:(NSString*)_email
			password:(NSString*)_password
				udid:(NSString*)_udid
			   token:(NSString*)_token
        voipToken:(NSString *)_voipToken
		   successed:(void (^)( id _responseObject))_success
			 failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_email    forKey:@"email"];
    NSString *str = [_password stringByReplacingOccurrencesOfString:@" " withString:@"0x20H"];
    [params setObject:str   forKey:@"password"];
    NSString *actionsStr = [NSString stringWithFormat:@"%@?email=%@&password=%@", WEBAPI_USERLOGIN, _email, str];
    [params setObject:_udid    forKey:@"device_uid"];
    if (_udid) {
        actionsStr = [NSString stringWithFormat:@"%@&device_uid=%@", actionsStr, _udid];
    }
    [params setObject:_token    forKey:@"device_token"];
    if (_token) {
        actionsStr = [NSString stringWithFormat:@"%@&device_token=%@", actionsStr, _token];
    }
    if (_voipToken) {
        actionsStr = [NSString stringWithFormat:@"%@&voip_token=%@", actionsStr, _voipToken];
        [params setObject:_voipToken    forKey:@"voip_token"];
    }
    [params setObject:@"2"    forKey:@"client_type"];
    actionsStr = [NSString stringWithFormat:@"%@&client_type=%@", actionsStr, @"2"];
#ifdef DEVENV
    actionsStr = [NSString stringWithFormat:@"%@&dev_mode=true", actionsStr];
    [params setObject:@(YES) forKey:@"dev_mode"];
#endif
    actionsStr = [NSString stringWithFormat:@"%@&os_version=iOS%@", actionsStr, [[UIDevice currentDevice] systemVersion]];
    [params setObject:[NSString stringWithFormat:@"iOS %@",[[UIDevice currentDevice] systemVersion]] forKey:@"os_version"];
    
    NSLog(@"params---%@----%@",params,actionsStr);
    [self sendToService:params action:actionsStr success:_success failure:_failure ];
}

- (void)UserLoginOpenID:(NSString*)_email
                       code: (NSString *)_code
				clienttype:(NSString*)_clienttype
					  udid:(NSString*)_udid
					 token:(NSString*)_token
				 successed:(void (^)( id _responseObject))_success
				   failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	
	[params setObject:_email				forKey:@"email"];
    [params setObject:_code			forKey:@"access_token"];
    NSString *actionsStr = [NSString stringWithFormat:@"%@?email=%@&access_token=%@&", WEBAPI_LOGINBYOPENID, _email, _code];
	[params setObject:@"2"				forKey:@"client_type"];
    actionsStr = [NSString stringWithFormat:@"%@&client_type=%@", actionsStr, @"2"];
	[params setObject:_udid				forKey:@"device_uid"];
    if (_udid) {
        actionsStr = [NSString stringWithFormat:@"%@&device_uid=%@", actionsStr, _udid];
    }
	[params setObject:_token				forKey:@"device_token"];
    if (_token) {
        actionsStr = [NSString stringWithFormat:@"%@&device_token=%@", actionsStr, _token];
    }

	[self sendToService:params action:actionsStr success:_success failure:_failure ];
}

- (void)GetFriend:(NSString*)_sessionid
		   successed:(void (^)( id _responseObject))_success
			 failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	
    [params setObject:_sessionid				forKey:@"sessionId"];
	[params setObject:@"json"				forKey:@"format"];
	
	[self sendToServiceGet:params action:WEBAPI_GETFRIEND success:_success failure:_failure ];
}

- (void)ClearMessage:(NSString*)_sessionid
				boardid:(NSNumber*)_boardid
			  successed:(void (^)( id _responseObject))_success
				failure:(void (^)( NSError* _error))_failure
{
	[self sendToService:nil action:[NSString stringWithFormat:@"%@%@?sessionId=%@",WEBAPI_CLEARMESSAGE,[_boardid stringValue],_sessionid] success:_success failure:_failure ];
}

- (void)ClearEntityMessage:(NSString*)_sessionid
                entityId:(NSString*)_entityId
              successed:(void (^)( id _responseObject))_success
                failure:(void (^)( NSError* _error))_failure {
    [self sendToService:nil action:[NSString stringWithFormat:@"%@?sessionId=%@&entity_id=%@",WEBAPI_CLEARMESSAGES,_sessionid,_entityId] success:_success failure:_failure];
}

- (void)DeleteMessages:(NSString*)_sessionid
				  boardid:(NSNumber*)_boardid
			   messageids:(NSString*)_messageids
				successed:(void (^)( id _responseObject))_success
				  failure:(void (^)( NSError* _error))_failure
{
	[self sendToService:nil action:[NSString stringWithFormat:@"%@%@?sessionId=%@&msg_ids=%@",WEBAPI_DELETEMESSAGES,[_boardid stringValue],_sessionid,_messageids] success:_success failure:_failure ];
}

- (void)GetContactInfo:(NSString*)_sessionid
				contactid:(NSString*)_contactid
				successed:(void (^)( id _responseObject))_success
				  failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	
    [params setObject:_contactid				forKey:@"contact_id"];
	[params setObject:@"json"				forKey:@"format"];
	
	[self sendToServiceGet:params action:[NSString stringWithFormat:@"%@?sessionId=%@",WEBAPI_GETCONTACTINFO,_sessionid] success:_success failure:_failure ];
}

- (void)GetMyUserInfo:(NSString*)_sessionid
			   successed:(void (^)( id _responseObject))_success
				 failure:(void (^)( NSError* _error))_failure
{
	[self sendToServiceGet:nil action:[NSString stringWithFormat:@"%@?sessionId=%@",WEBAPI_GETMYUSERINFO,_sessionid] success:_success failure:_failure ];
}

- (void)ReadMessage:(NSString*)_sessionid
			  board_id:(NSNumber*)_board_id
			   msg_ids:(NSString*)_msg_ids
			 successed:(void (^)( id _responseObject))_success
			   failure:(void (^)( NSError* _error))_failure
{
	[self sendToService:nil action:[NSString stringWithFormat:@"%@%@?sessionId=%@&msg_ids=%@",WEBAPI_READMESSAGE,[_board_id stringValue],_sessionid,_msg_ids] success:_success failure:_failure ];
}

- (void)ForgotPassword:(NSString*)_email
				successed:(void (^)( id _responseObject))_success
				  failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	
    [params setObject:_email				forKey:@"email"];
	
	[self sendToService:params action:[NSString stringWithFormat:@"%@?email=%@",WEBAPI_FORGOTPASSWORD,_email] success:_success failure:_failure ];
}

- (void)SignUP:(NSString*)_email
		firstname:(NSString*)_name
		 lastname:(NSString*)_lastname
		 password:(NSString*)_password
             udid:(NSString*)_udid
            token:(NSString*)_token
     voipToken:(NSString *)_voipToken
		successed:(void (^)( id _responseObject))_success
		  failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	
    [params setObject:_name				forKey:@"first_name"];
    NSString *str = [_password stringByReplacingOccurrencesOfString:@" " withString:@"0x20H"];
	[params setObject:str			forKey:@"password"];
	[params setObject:_email				forKey:@"email"];
    NSString *actionsStr = [NSString stringWithFormat:@"%@?email=%@&password=%@&first_name=%@", WEBAPI_SIGNUP, _email, str, _name];
    
    [params setObject:_lastname			forKey:@"last_name"];
    if (_lastname) {
        actionsStr = [NSString stringWithFormat:@"%@&last_name=%@", actionsStr, _lastname];
    }
    
    [params setObject:_udid    forKey:@"device_uid"];
    if (_udid) {
        actionsStr = [NSString stringWithFormat:@"%@&device_uid=%@", actionsStr, _udid];
    }
    [params setObject:_token    forKey:@"device_token"];
    if (_token) {
        actionsStr = [NSString stringWithFormat:@"%@&device_token=%@", actionsStr, _token];
    }
    if (_voipToken) {
        actionsStr = [NSString stringWithFormat:@"%@&voip_token=%@", actionsStr, _voipToken];
        [params setObject:_voipToken    forKey:@"voip_token"];
    }
    
    [params setObject:@"2"    forKey:@"client_type"];
    actionsStr = [NSString stringWithFormat:@"%@&client_type=%@", actionsStr, @"2"];
    actionsStr = [NSString stringWithFormat:@"%@&os_version=iOS%@", actionsStr, [[UIDevice currentDevice] systemVersion]];
    [params setObject:[NSString stringWithFormat:@"iOS %@",[[UIDevice currentDevice] systemVersion]] forKey:@"os_version"];
	[self sendToService:params action:actionsStr success:_success failure:_failure ];
}

- (void)SendValidationEmail:(NSString*)_email
					 successed:(void (^)( id _responseObject))_success
					   failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	
    [params setObject:_email				forKey:@"email"];
	
	[self sendToService:params action:[NSString stringWithFormat:@"%@?email=%@",WEBAPI_SENDVALIDATION,_email]  success:_success failure:_failure ];
}

- (void)AcceptLogin:(NSString*)_key
          voipToken:(NSString *)_voipToken
			 successed:(void (^)( id _responseObject))_success
			   failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	
    [params setObject:_key				forKey:@"key"];
	[params setObject:@"json"			forKey:@"format"];
    if (_voipToken) {
        [params setObject:_voipToken			forKey:@"voip_token"];
    }
    [params setObject:[NSString stringWithFormat:@"iOS %@",[[UIDevice currentDevice] systemVersion]] forKey:@"os_version"];
    if (_voipToken) {
        [self sendToServiceGet:params action:[NSString stringWithFormat:@"%@?key=%@&voip_token=%@",WEBAPI_ACTIVATEEMAIL,_key, _voipToken]  success:_success failure:_failure ];
    }else{
        [self sendToServiceGet:params action:[NSString stringWithFormat:@"%@?key=%@",WEBAPI_ACTIVATEEMAIL,_key]  success:_success failure:_failure ];
    }
}

- (void)UploadMultipleImages:(NSString*)_sessionId
						   type:(NSString*)_type
					 background:(NSData*)_background
					 foreground:(NSData*)_foreground
					  successed:(void (^)( id _responseObject))_success
						failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	[params setObject:_sessionId				forKey:@"sessionId"];
	[params setObject:_type					forKey:@"type"];

    NSString *actionString = [NSString stringWithFormat:@"%@?sessionId=%@&type=%@",WEBAPI_MULTIPLEUPLOAD,_sessionId,_type];
    
	[self sendToMultipleUploadService:params action:actionString background:_background foreground:_foreground success:_success failure:_failure ];
}

//wang class AE
- (void)UploadMultipleImagesForEntity:(NSString*)_sessionId
								entityid:(NSString*)_entityId
							  background:(NSData*)_background
							  foreground:(NSData*)_foreground
							   successed:(void (^)( id _responseObject))_success
								 failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	[params setObject:_sessionId				forKey:@"sessionId"];
	[params setObject:_entityId				forKey:@"entity_id"];
	
    NSString *actionString = [NSString stringWithFormat:@"%@?sessionId=%@&entity_id=%@",WEBAPI_MULTIPLEUPLOADENTITY,_sessionId,_entityId];
    
	[self sendToMultipleUploadService:params action:actionString background:_background foreground:_foreground success:_success failure:_failure ];
}

- (void)SetInfo1:(NSString*)_sessionId
             group:(NSString*)_group
            fields:(NSArray*)_field
            images:(NSArray*)_images
         successed:(void (^)( id _responseObject))_success
           failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    [params setObject:_group				forKey:@"group"];
    [params setObject:_field				forKey:@"fields"];
    [params setObject:_images			forKey:@"images"];
    
    [self sendToServiceJSON:[NSString stringWithFormat:@"%@%@?sessionId=%@",SERVER_URL,WEBAPI_SETINFO,_sessionId] params:params success:_success failure:_failure ];
}

- (void)SetInfo:(NSString*)_sessionId
			 group:(NSString*)_group
			fields:(NSArray*)_field
		 successed:(void (^)( id _responseObject))_success
		   failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	[params setObject:_group				forKey:@"group"];
	[params setObject:_field				forKey:@"fields"];
	
	[self sendToServiceJSON:[NSString stringWithFormat:@"%@%@?sessionId=%@",SERVER_URL,WEBAPI_SETINFO,_sessionId] params:params success:_success failure:_failure ];
}

- (void)deleteWorkProfile:(NSString*)_sessionId
                       group:(NSString*)_group
		 successed:(void (^)( id _responseObject))_success
		   failure:(void (^)( NSError* _error))_failure
{
//	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
//    if (_group) {
//        [params setObject:_group				forKey:@"group"];
//    }
	
	[self sendToService:nil action:[NSString stringWithFormat:@"%@?sessionId=%@&group=%@",WEBAPI_REMOVEPROFILE,_sessionId, _group] success:_success failure:_failure ];
}

- (void)UploadVideo:(NSString*)_sessionId
				  type:(NSString*)_type
				 video:(NSData*)_video
			 thumbnail:(NSData*)_thumb
			 successed:(void (^)( id _responseObject))_success
			   failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	[params setObject:_sessionId				forKey:@"sessionId"];
	[params setObject:_type					forKey:@"type"];
    
    NSString *actionString = [NSString stringWithFormat:@"%@?sessionId=%@&type=%@",WEBAPI_UPLOADVIDEO,_sessionId,_type];
    
    if (![[AppDelegate sharedDelegate].videoID isEqualToString:@""]) {
        [params setObject:[AppDelegate sharedDelegate].videoID forKey:@"video_id"];
        actionString = [NSString stringWithFormat:@"%@&video_id=%@", actionString, [AppDelegate sharedDelegate].videoID];
    }
	
	[self sendToService:nil action:actionString data:_video thumbnail:_thumb name:@"video" mimetype:@"video/quicktime" success:_success failure:_failure ];
}

- (void)GetInfo:(NSString*)_sessionId
		 successed:(void (^)( id _responseObject))_success
		   failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	
    [params setObject:_sessionId				forKey:@"sessionId"];
	
	[self sendToServiceGet:params action:WEBAPI_GETINFO success:_success failure:_failure ];
}

//wang class ae
//entity
- (void)UploadEntityVideo:(NSString*)_sessionId
					entityid:(NSString*)_entityId
					   video:(NSData*)_video
				   thumbnail:(NSData*)_thumb
				   successed:(void (^)( id _responseObject))_success
					 failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	[params setObject:_sessionId				forKey:@"sessionId"];
	[params setObject:_entityId				forKey:@"entity_id"];
    
    NSString *actionString = [NSString stringWithFormat:@"%@?sessionId=%@&entity_id=%@",WEBAPI_UPLOADENTITYVIDEO,_sessionId,_entityId];
    
    if (![[AppDelegate sharedDelegate].videoEntityID isEqualToString:@""]) {
        [params setObject:[AppDelegate sharedDelegate].videoEntityID forKey:@"video_id"];
        actionString = [NSString stringWithFormat:@"%@&video_id=%@", actionString, [AppDelegate sharedDelegate].videoEntityID];
    }
	
	[self sendToService:nil action:actionString data:_video thumbnail:_thumb name:@"video" mimetype:@"video/quicktime" success:_success failure:_failure ];
}

- (void)DeleteEntity:(NSString*)_sessionId
			   entityid:(NSString*)_entityId
			  successed:(void (^)( id _responseObject))_success
				failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	
    [params setObject:_sessionId				forKey:@"sessionId"];
	[params setObject:_entityId				forKey:@"entity_id"];
	
	[self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&entity_id=%@",WEBAPI_DELETEENTITY,_sessionId,_entityId] success:_success failure:_failure ];
}

- (void)DeleteLocation:(NSString*)_sessionId
				 entityid:(NSString*)_entityId
				   infoid:(NSString*)_infoId
				successed:(void (^)( id _responseObject))_success
				  failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	
    [params setObject:_sessionId				forKey:@"sessionId"];
	[params setObject:_entityId				forKey:@"entity_id"];
	[params setObject:_infoId				forKey:@"info_id"];
	
	[self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&entity_id=%@&info_id=%@",WEBAPI_DELETEENTITYINFO,_sessionId,_entityId,_infoId] success:_success failure:_failure ];
}

- (void)SaveEntity:(NSString*)_sessionId
		   categoryid:(NSString*)_categoryid
				 name:(NSString*)_name
			keysearch:(NSString*)_keysearch
			successed:(void (^)( id _responseObject))_success
			  failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
	[params setObject:_sessionId				forKey:@"sessionId"];
	[params setObject:_categoryid			forKey:@"category_id"];
	[params setObject:_name					forKey:@"name"];
    _keysearch = [_keysearch stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	[params setObject:_keysearch				forKey:@"search_words"];
	
	[self sendToServiceJSON:[NSString stringWithFormat:@"%@%@?sessionId=%@",SERVER_URL,WEBAPI_CREATEUPDATEENTITY,_sessionId] params:params success:_success failure:_failure ];
}

- (void)SaveEntityPowerful:(NSString*)_sessionId
				   categoryid:(NSString*)_categoryid
						 name:(NSString*)_name
               description:(NSString *)description
					keysearch:(NSString*)_keysearch
				   background:(NSData*)_background
				   foreground:(NSData*)_foreground
					successed:(void (^)( id _responseObject))_success
					  failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	[params setObject:_sessionId				forKey:@"sessionId"];
	[params setObject:_categoryid			forKey:@"category_id"];
//    _name = [_name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    _name = [CommonMethods encodedURLString:_name];
	[params setObject:_name					forKey:@"name"];
    params[@"description"] = description;
    _keysearch = [CommonMethods encodedURLString:_keysearch];
	[params setObject:_keysearch				forKey:@"search_words"];
	[params setObject:@"0"					forKey:@"privilege"];
	
	[self sendToServiceCreateEntity:params action:[NSString stringWithFormat:@"%@?sessionId=%@&category_id=%@&name=%@&search_words=%@&privilege=0",WEBAPI_ENTITYPOWEFULCREATE,_sessionId,_categoryid,_name,_keysearch] background:_background foreground:_foreground success:_success failure:_failure ];
}

- (void)UpdateEntity:(NSString*)_sessionId
			   entityid:(NSString*)_entityId
				   name:(NSString*)_name
			  keysearch:(NSString*)_keysearch
			 categoryid:(NSString*)_categoryid
			  privilege:(NSString*)_privilege
				  infos:(NSArray*)_infos
			  successed:(void (^)( id _responseObject))_success
				failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	
	[params setObject:_entityId				forKey:@"entity_id"];
	[params setObject:_name					forKey:@"name"];
    _keysearch = [_keysearch stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	[params setObject:_keysearch				forKey:@"search_words"];
	[params setObject:_privilege				forKey:@"privilege"];
	[params setObject:_infos					forKey:@"infos"];
	
	[self sendToServiceJSON:[NSString stringWithFormat:@"%@%@?sessionId=%@",SERVER_URL,WEBAPI_CREATEUPDATEENTITY,_sessionId] params:params success:_success failure:_failure ];
}

- (void)UpdateEntity1:(NSString*)_sessionId
               entityid:(NSString*)_entityId
                   name:(NSString*)_name
          deleteInfos:(NSString*)_deleteIds
          description:(NSString *)description
              keysearch:(NSString*)_keysearch
             categoryid:(NSString*)_categoryid
              privilege:(NSString*)_privilege
                  infos:(NSArray*)_infos
                  images:(NSArray *)_images
              successed:(void (^)( id _responseObject))_success
                failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_entityId				forKey:@"entity_id"];
    [params setObject:_name					forKey:@"name"];
    [params setObject:_deleteIds            forKey:@"delete_info_ids"];
    params[@"description"] = description;
    _keysearch = [_keysearch stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [params setObject:_keysearch				forKey:@"search_words"];
    [params setObject:_privilege				forKey:@"privilege"];
    [params setObject:_infos					forKey:@"infos"];
    if (_images)
        [params setObject:_images				forKey:@"images"];
    
    [self sendToServiceJSON:[NSString stringWithFormat:@"%@%@?sessionId=%@",SERVER_URL,WEBAPI_CREATEUPDATEENTITY,_sessionId] params:params success:_success failure:_failure ];
}

- (void)updatePrivilege:(NSString*)_sessionId
                  entityid:(NSString*)_entityId
                 privilege:(NSString*)_privilege
                 successed:(void (^)( id _responseObject))_success
                   failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	
    [params setObject:_entityId				forKey:@"entity_id"];
	[params setObject:_privilege				forKey:@"privilege"];
	
	[self sendToServiceJSON:[NSString stringWithFormat:@"%@%@?sessionId=%@",SERVER_URL,WEBAPI_CREATEUPDATEENTITY,_sessionId] params:params success:_success failure:_failure ];
}

- (void)updateUserPrivilege:(NSString*)_sessionId
                 homePrivilege:(NSString*)_homePrivilege
                 workPrivilege:(NSString*)_workPrivilege
                     successed:(void (^)( id _responseObject))_success
                       failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	
    [params setObject:_homePrivilege             forKey:@"home_privilege"];
    NSString *url = [NSString stringWithFormat:@"%@?sessionId=%@&home_privilege=%@", WEBAPI_UPDATEUSERPRIVILEGE,_sessionId,_homePrivilege];
    
	if (_workPrivilege) {
        [params setObject:_workPrivilege				forKey:@"work_privilege"];
        url = [NSString stringWithFormat:@"%@&work_privilege=%@", url, _workPrivilege];
    }
	
	[self sendToService:params action:url success:_success failure:_failure ];
}

- (void)ListAll:(NSString*)_sessionId
		 successed:(void (^)( id _responseObject))_success
		   failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	
    [params setObject:_sessionId				forKey:@"sessionId"];
	
	[self sendToServiceGet:params action:@"/entity/category/listall" success:_success failure:_failure ];
}

- (void)RmoveEntityPhoto:(NSString*)_sessionId
				   entityid:(NSString*)_entityId
					imageid:(NSString*)_imageid
				  successed:(void (^)( id _responseObject))_success
					failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	
	[params setObject:_sessionId			forKey:@"sessionId"];
	[params setObject:_entityId			forKey:@"entity_id"];
	[params setObject:_imageid			forKey:@"image_id"];
	
	[self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&entity_id=%@&image_id=%@",WEBAPI_REMOVEENTITYIMAGE,_sessionId,_entityId,_imageid] success:_success failure:_failure ];
}

- (void)RmoveEntityVideo:(NSString*)_sessionId
                   entityid:(NSString*)_entityId
                  successed:(void (^)( id _responseObject))_success
                    failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId			forKey:@"sessionId"];
    [params setObject:_entityId			forKey:@"entity_id"];
    
    [self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&entity_id=%@",WEBAPI_REMOVEENTITYVIDEO,_sessionId,_entityId] success:_success failure:_failure ];
}

//ee class
- (void)GetEntityCategory:(NSString*)_sessionId
				  categoryid:(NSString*)_categoryId
				   successed:(void (^)( id _responseObject))_success
					 failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	
    [params setObject:_sessionId				forKey:@"sessionId"];
	
	[self sendToServiceGet:params action:[NSString stringWithFormat:@"%@%@",WEBAPI_GETCATEGORYENTITY,_categoryId] success:_success failure:_failure ];
}

- (void)GetEntityDetail:(NSString*)_sessionId
				  entityid:(NSString*)_entityid
				 successed:(void (^)( id _responseObject))_success
				   failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	
    [params setObject:_sessionId				forKey:@"sessionId"];
	[params setObject:_entityid				forKey:@"entity_id"];
	
	[self sendToServiceGet:params action:[NSString stringWithFormat:@"%@",WEBAPI_GETENTITYDEAIL] success:_success failure:_failure ];
}

- (void)ListEntity:(NSString*)_sessionId
            successed:(void (^)( id _responseObject))_success
              failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	
    [params setObject:_sessionId				forKey:@"sessionId"];
	
//	[self sendToServiceGet:params action:[NSString stringWithFormat:@"%@",WEBAPI_LISTENTITY] success:_success failure:_failure ];
    [self sendToServiceGet:params action:[NSString stringWithFormat:@"%@", WEBAPI_LISTENTITY] success:_success failure:_failure];
}

//Entity Messenger
- (void)GetEntityByFollowr:(NSString*)_sessionId
                  entityid:(NSString*)_entityid
                    successed:(void (^)( id _responseObject))_success
                      failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	
    [params setObject:_sessionId				forKey:@"sessionId"];
	[params setObject:_entityid				forKey:@"entity_id"];
	
	[self sendToServiceGet:params action:[NSString stringWithFormat:@"%@",WEBAPI_GETENTITYFOLLOWERVIEW] success:_success failure:_failure ];
}
- (void)GetEntityByFollowrNew:(NSString*)_sessionId
                     entityid:(NSString*)_entityid
                     infoFrom:(NSString*)_infoFrom
                    infoCount:(NSString*)_infoCount
                     latitude:(float)_latitude
                    longitude:(float)_longitude
                 successed:(void (^)( id _responseObject))_success
                   failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId				forKey:@"sessionId"];
    [params setObject:_entityid				forKey:@"entity_id"];
    [params setObject:_infoFrom				forKey:@"info_from"];
    [params setObject:_infoCount				forKey:@"info_count"];
    [params setObject:@(_latitude)				forKey:@"latitude"];
    [params setObject:@(_longitude)				forKey:@"longitude"];
    
    [self sendToServiceGet:params action:[NSString stringWithFormat:@"%@",WEBAPI_GETENTITYFOLLOWERVIEWNEW] success:_success failure:_failure ];
}
- (void)FollowEntity:(NSString*)_sessionId
               entityid:(NSString*)_entityid
              successed:(void (^)( id _responseObject))_success
                failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	
    [params setObject:_sessionId				forKey:@"sessionId"];
	[params setObject:_entityid				forKey:@"entity_id"];
	
    [self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&entity_id=%@",WEBAPI_ENTITYFOLLOW,_sessionId,_entityid] success:_success failure:_failure ];
}

- (void)UnFollowEntity:(NSString*)_sessionId
                 entityid:(NSString*)_entityid
                successed:(void (^)( id _responseObject))_success
                  failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	
    [params setObject:_sessionId				forKey:@"sessionId"];
	[params setObject:_entityid				forKey:@"entity_id"];
	
    [self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&entity_id=%@",WEBAPI_ENTITYUNFOLLOW,_sessionId,_entityid] success:_success failure:_failure ];
}

- (void)FollowerSetNotes:(NSString*)_sessionId
                   entityid:(NSString*)_entityid
                       notes: ( NSString*)_notes
                  successed:(void (^)( id _responseObject))_success
                    failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	
    [params setObject:_sessionId				forKey:@"sessionId"];
	[params setObject:_entityid				forKey:@"entity_id"];
    _notes = [_notes stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [params setObject:_notes                 forKey:@"notes"];
	
    [self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&entity_id=%@&notes=%@",WEBAPI_FOLLOWERSETNOTES,_sessionId,_entityid,_notes] success:_success failure:_failure ];
}

- (void)getAllEntityMessages:(NSString*)_sessionId
                       entityid:(NSString*)_entityid
                         pageNum: ( NSString*)_pageNum
                    countPerPage: ( NSString*)_countPerPage
                      successed:(void (^)( id _responseObject))_success
                        failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	
    [params setObject:_sessionId				forKey:@"sessionId"];
	[params setObject:_entityid				forKey:@"entity_id"];
    if (_pageNum) {
        [params setObject:_pageNum				forKey:@"pageNum"];
    }
    
    if (_countPerPage) {
        [params setObject:_countPerPage			forKey:@"countPerPage"];
    }
	
	[self sendToServiceGet:params action:[NSString stringWithFormat:@"%@",WEBAPI_LISTMESSAGES] success:_success failure:_failure ];
}

- (void)listMessageBoard:(NSString*)_sessionId
                         pageNum: ( NSString*)_pageNum
                    countPerPage: ( NSString*)_countPerPage
                      successed:(void (^)( id _responseObject))_success
                        failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	
    [params setObject:_sessionId				forKey:@"sessionId"];
    if (_pageNum) {
        [params setObject:_pageNum				forKey:@"pageNum"];
    }
    if (_countPerPage) {
        [params setObject:_countPerPage			forKey:@"countPerPage"];
    }
	
	[self sendToServiceGet:params action:[NSString stringWithFormat:@"%@",WEBAPI_LISTMESSAGEBOARD] success:_success failure:_failure ];
}

- (void)getEntityMessageHistory:(NSString*)_sessionId
                            pageNum: ( NSString*)_pageNum
                       countPerPage: ( NSString*)_countPerPage
                         successed:(void (^)( id _responseObject))_success
                           failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	
    [params setObject:_sessionId				forKey:@"sessionId"];
    if (_pageNum) {
        [params setObject:_pageNum				forKey:@"pageNum"];
    }
    if (_countPerPage) {
        [params setObject:_countPerPage			forKey:@"countPerPage"];
    }
	
	[self sendToServiceGet:params action:[NSString stringWithFormat:@"%@",WEBAPI_LISTENTITYMESSAGEHISTORY] success:_success failure:_failure ];
}
- (void)SendEntityMessage:(NSString*)_sessionid
                    entityid:(NSString*)_entityid
                     content:(NSString*)_message
                   successed:(void (^)( id _responseObject))_success
                     failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	[params setObject:_message				forKey:@"content"];
	
	
	[self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&entity_id=%@",WEBAPI_SENDENTITYMESSAGE,_sessionid,_entityid] success:_success failure:_failure ];
}

- (void)SendEntityFile:(NSString*)_sessionid
                 entityid:(NSString*)_entityid
                     data:(NSData*)_data
                thumbnail:(NSData*)_thumbnail
                     name:(NSString*)_name
                 mimetype:(NSString*)_mimetype
                successed:(void (^)( id _responseObject))_success
                  failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	
    [params setObject:_sessionid				forKey:@"sessionId"];
    [params setObject:_entityid				forKey:@"entity_id"];
	
	if ([_mimetype isEqualToString:@"image/jpeg"])
	{
		[self sendToService:nil action:[NSString stringWithFormat:@"%@?sessionId=%@&entity_id=%@&file_type=%@",WEBAPI_SENDENTITYFILE,_sessionid,_entityid,@"photo"] data:_data thumbnail:nil name:_name mimetype:_mimetype success:_success failure:_failure ];
	}
	else if ([_mimetype isEqualToString:@"audio/aac"])
	{
        [self sendToService:nil action:[NSString stringWithFormat:@"%@?sessionId=%@&entity_id=%@&file_type=%@",WEBAPI_SENDENTITYFILE,_sessionid,_entityid,@"voice"] data:_data thumbnail:nil name:_name mimetype:_mimetype success:_success failure:_failure ];
	}
	else if ([_mimetype isEqualToString:@"video/quicktime"])
	{
        [self sendToService:nil action:[NSString stringWithFormat:@"%@?sessionId=%@&entity_id=%@&file_type=%@",WEBAPI_SENDENTITYFILE,_sessionid,_entityid,@"video"] data:_data thumbnail:_thumbnail name:_name mimetype:_mimetype success:_success failure:_failure ];
	}
}

- (void)DeleteEntityMessages:(NSString*)_sessionid
                       entityid:(NSString*)_entityid
                     messageids:(NSString*)_messageids
                      successed:(void (^)( id _responseObject))_success
                        failure:(void (^)( NSError* _error))_failure
{
	[self sendToService:nil action:[NSString stringWithFormat:@"%@?sessionId=%@&entity_id=%@&msg_ids=%@",WEBAPI_DELETEENTITYMESSAGE,_sessionid,_entityid,_messageids] success:_success failure:_failure ];
}

- (void)InviteEntityFriends:(NSString*)_sessionid
                      entityid:(NSString*)_entityid
                      contacts:(NSString*)_contact_uids
                   successed:(void (^)( id _responseObject))_success
                     failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	[params setObject:_contact_uids				forKey:@"contact_uids"];
	
	
	[self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&entity_id=%@&contact_uids=%@",WEBAPI_INVITEENTITYFRIENDS,_sessionid,_entityid,_contact_uids] success:_success failure:_failure ];
}

- (void)deleteFollowers:(NSString*)_sessionid
                  entityid:(NSString*)_entityid
                  contacts:(NSString*)_contact_uids
                 successed:(void (^)( id _responseObject))_success
                   failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	[params setObject:_contact_uids				forKey:@"contact_uids"];
	
	
	[self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&entity_id=%@&contact_uids=%@",WEBAPI_DELETEFOLLOWERS,_sessionid,_entityid,_contact_uids] success:_success failure:_failure ];
}

- (void)getEntityContacts:(NSString*)_sessionId
                    entityid:(NSString*)_entityid
                     invited:(NSString*)_isInvited
                  successed:(void (^)( id _responseObject))_success
                    failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	
    [params setObject:_sessionId				forKey:@"sessionId"];
    [params setObject:_entityid				forKey:@"entity_id"];
	[params setObject:_isInvited				forKey:@"only_invited"];
	[self sendToServiceGet:params action:[NSString stringWithFormat:@"%@",WEBAPI_GETENTITYCONTACTS] success:_success failure:_failure ];
}

//Group
- (void)addGroup:(NSString*)_sessionid
               name:(NSString*)_name
          successed:(void (^)( id _responseObject))_success
            failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    _name = [_name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	[params setObject:_name				forKey:@"name"];
	
	[self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&name=%@",WEBAPI_ADDGROUP,_sessionid,_name] success:_success failure:_failure ];
}

- (void)deleteGroup:(NSString*)_sessionid
               groupID:(NSString*)_groupID
             successed:(void (^)( id _responseObject))_success
               failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	[params setObject:_groupID				forKey:@"group_id"];
	
	[self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&group_id=%@",WEBAPI_DELETEGROUP,_sessionid,_groupID] success:_success failure:_failure ];
}

- (void)renameGroup:(NSString*)_sessionid
               groupID:(NSString*)_groupID
                  name:(NSString*)_name
             successed:(void (^)( id _responseObject))_success
               failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	[params setObject:_groupID				forKey:@"group_id"];
    [params setObject:_name                  forKey:@"name"];
	
	[self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&group_id=%@&name=%@",WEBAPI_RENAMEGROUP,_sessionid,_groupID,_name] success:_success failure:_failure ];
}

- (void)addUserToGroup:(NSString*)_sessionid
                  groupID:(NSString*)_groupID
              contactKeys:(NSString*)_contactKeys
                successed:(void (^)( id _responseObject))_success
                  failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	[params setObject:_groupID				forKey:@"group_id"];
    [params setObject:_contactKeys           forKey:@"contact_keys"];
	
	[self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&group_id=%@&contact_keys=%@",WEBAPI_ADDUSER,_sessionid,_groupID,_contactKeys] success:_success failure:_failure ];
}

- (void)removeUserFromGroup:(NSString*)_sessionid
                       groupID:(NSString*)_groupID
                   contactKeys:(NSString*)_contactKeys
                     successed:(void (^)( id _responseObject))_success
                       failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	[params setObject:_groupID				forKey:@"group_id"];
    [params setObject:_contactKeys           forKey:@"contact_keys"];
	
	[self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&group_id=%@&contact_keys=%@",WEBAPI_REMOVEUSER,_sessionid,_groupID,_contactKeys] success:_success failure:_failure ];
}

- (void)getGroupList:(NSString*)_sessionId
              successed:(void (^)( id _responseObject))_success
                failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	
    [params setObject:_sessionId				forKey:@"sessionId"];
	
	[self sendToServiceGet:params action:[NSString stringWithFormat:@"%@",WEBAPI_LISTGROUP] success:_success failure:_failure ];
}

- (void)getUsersForGroup:(NSString*)_sessionId
                    groupID:(NSString*)_groupID
                  successed:(void (^)( id _responseObject))_success
                    failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	
    [params setObject:_sessionId				forKey:@"sessionId"];
	[params setObject:_groupID				forKey:@"group_id"];
	[self sendToServiceGet:params action:[NSString stringWithFormat:@"%@",WEBAPI_GETUSERS] success:_success failure:_failure ];
}

- (void)SavePositionGroup:(NSString *)_sessionId
                  groupID:(NSString *)_groupID
                 orderNum:(NSString *)_orderNum
              oldOrderNum:(NSString *)_oldOrderNum
                successed:(void (^)( id _responseObject))_success
                  failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:_sessionId forKey:@"sessionId"];
    [params setObject:_groupID forKey:@"id"];
    [params setObject:_orderNum forKey:@"order_num"];
    [params setObject:_oldOrderNum forKey:@"old_order_num"];
    
    [self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&id=%@&order_num=%@&old_order_num=%@",WEBAPI_MOVEGROUP,_sessionId,_groupID,_orderNum,_oldOrderNum] success:_success failure:_failure ];
}
- (void)SaveAllPositionOfGroups:(NSString*)_sessionId
                      fields:(NSArray*)_field
                   successed:(void (^)( id _responseObject))_success
                     failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:_field forKey:@"data"];
        
    [self sendToServiceJSON:[NSString stringWithFormat:@"%@%@?sessionId=%@",SERVER_URL, WEBAPI_MOVEBATCHGROUP,_sessionId] params:params success:_success failure:_failure];
}
- (void)getRemainingContacts:(NSString*)_sessionId
                        groupID:(NSString*)_groupID
                      successed:(void (^)( id _responseObject))_success
                        failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	
    [params setObject:_sessionId				forKey:@"sessionId"];
    [params setObject:_groupID				forKey:@"group_id"];
	
	[self sendToServiceGet:params action:[NSString stringWithFormat:@"%@",WEBAPI_GETREMAININGCONTACTS] success:_success failure:_failure ];
}

//search
- (void)listSearchContacts:(NSString*)_sessionId
                    searchKey:(NSString*)_searchKey
                    successed:(void (^)( id _responseObject))_success
                      failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	
    [params setObject:_sessionId				forKey:@"sessionId"];
	[params setObject:_searchKey				forKey:@"q"];
	[self sendToServiceGet:params action:[NSString stringWithFormat:@"%@",WEBAPI_GETSEARCHCONTACTS] success:_success failure:_failure ];
}

- (void)setWizardPage:(NSString*)_sessionid
               setupPage:(NSString*)_setupPage
               successed:(void (^)( id _responseObject))_success
                 failure:(void (^)( NSError* _error))_failure
{
	NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
	[params setObject:_setupPage				forKey:@"setup_page"];
	
	[self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&setup_page=%@",WEBAPI_SETWIZARDPAGE,_sessionid,_setupPage] success:_success failure:_failure ];
}

//archive - profile
- (void)getProfileImageHistory:(NSString *)_sessionId
                          type:(NSString *)_type
                       pageNum:(NSString *)_pageNum
                  countPerPage:(NSString *)_countPerPage
                     successed:(void (^)( id _responseObject))_success
                       failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId				forKey:@"sessionId"];
    [params setObject:_type                  forKey:@"type"];
    
    if (_pageNum) {
        [params setObject:_pageNum				forKey:@"pageNum"];
    }
    
    if (_countPerPage) {
        [params setObject:_countPerPage			forKey:@"countPerPage"];
    }
    [self sendToServiceGet:params action:[NSString stringWithFormat:@"%@",WEBAPI_GETPROFILEIMAGEHISTORY] success:_success failure:_failure ];
}

- (void)getProfileImageArchive:(NSString *)_sessionId
                          type:(NSString *)_type
                       pageNum:(NSString *)_pageNum
                  countPerPage:(NSString *)_countPerPage
                     successed:(void (^)( id _responseObject))_success
                       failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId				forKey:@"sessionId"];
    [params setObject:_type                  forKey:@"type"];
    
    if (_pageNum) {
        [params setObject:_pageNum				forKey:@"pageNum"];
    }
    
    if (_countPerPage) {
        [params setObject:_countPerPage			forKey:@"countPerPage"];
    }
    [self sendToServiceGet:params action:[NSString stringWithFormat:@"%@",WEBAPI_GETPROFILEIMAGEARCHIVE] success:_success failure:_failure ];
}

- (void)getProfileVideoHistory:(NSString *)_sessionId
                          type:(NSString *)_type
                       pageNum:(NSString *)_pageNum
                  countPerPage:(NSString *)_countPerPage
                     successed:(void (^)( id _responseObject))_success
                       failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId				forKey:@"sessionId"];
    [params setObject:_type                  forKey:@"type"];
    
    if (_pageNum) {
        [params setObject:_pageNum				forKey:@"pageNum"];
    }
    
    if (_countPerPage) {
        [params setObject:_countPerPage			forKey:@"countPerPage"];
    }
    [self sendToServiceGet:params action:[NSString stringWithFormat:@"%@",WEBAPI_GETPROFILEVIDEOHISTORY] success:_success failure:_failure ];
}

- (void)deleteProfileImageHistory:(NSString *)_sessionid
                            image:(NSString *)_imageid
                             type:(NSString *)_type
               successed:(void (^)( id _responseObject))_success
                 failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:_type forKey:@"type"];
    
    [self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&image_id=%@&type=%@",WEBAPI_DELETEPROFILEIMAGEHISTORY, _sessionid, _imageid, _type] success:_success failure:_failure];
}

- (void)deleteProfileImageArchive:(NSString *)_sessionid
                        archiveid:(NSString *)_archiveid
                             type:(NSString *)_type
                       successed:(void (^)( id _responseObject))_success
                         failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:_type forKey:@"type"];
    
    [self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&archive_id=%@&type=%@",WEBAPI_DELETEPROFILEIMAGEARCHIVE, _sessionid, _archiveid, _type] success:_success failure:_failure];
}

- (void)pickupProfileImageArchive:(NSString *)_sessionid
                        archiveid:(NSString *)_archiveid
                             type:(NSString *)_type
                       successed:(void (^)( id _responseObject))_success
                         failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:_type forKey:@"type"];
    
    [self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&archive_id=%@&type=%@",WEBAPI_PICKUPPROFILEIMAGEARCHIVE, _sessionid, _archiveid, _type] success:_success failure:_failure];
}

- (void)deleteProfileVideoHistory:(NSString *)_sessionid
                            video:(NSString *)_videoid
                             type:(NSString *)_type
                       successed:(void (^)( id _responseObject))_success
                         failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:_type forKey:@"type"];
    
    [self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&video_id=%@&type=%@",WEBAPI_DELETEPROFILEVIDEOHISTORY, _sessionid, _videoid, _type] success:_success failure:_failure];
}

- (void)removeProfileVideo:(NSString *)_sessionid
                            video:(NSString *)_videoid
                             type:(NSString *)_type
                       successed:(void (^)( id _responseObject))_success
                         failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:_type forKey:@"type"];
    
    [self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&video_id=%@&type=%@",WEBAPI_DELETEPROFILEVIDEO, _sessionid, _videoid, _type] success:_success failure:_failure];
}

- (void)removePhoto:(NSString *)_sessionid
              image:(NSString *)_imageid
               type:(NSString *)_type
         successed:(void (^)( id _responseObject))_success
           failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:_type forKey:@"type"];
    [params setObject:_imageid forKey:@"image_id"];
    
    [self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&image_id=%@&type=%@",WEBAPI_DELETEPHOTO, _sessionid, _imageid, _type] success:_success failure:_failure];
}


//archive - entity
- (void)getEntityImageHistory:(NSString *)_sessionId
                    entity_id:(NSString *)_entityid
                      pageNum:(NSString *)_pageNum
                 countPerPage:(NSString *)_countPerPage
                    successed:(void (^)( id _responseObject))_success
                      failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId				forKey:@"sessionId"];
    [params setObject:_entityid              forKey:@"entity_id"];
    
    if (_pageNum) {
        [params setObject:_pageNum				forKey:@"pageNum"];
    }
    
    if (_countPerPage) {
        [params setObject:_countPerPage			forKey:@"countPerPage"];
    }
    [self sendToServiceGet:params action:[NSString stringWithFormat:@"%@",WEBAPI_GETENTITYIMAGEHISTORY] success:_success failure:_failure ];
}

- (void)getEntityImageArchive:(NSString *)_sessionId
                    entity_id:(NSString *)_entityid
                      pageNum:(NSString *)_pageNum
                 countPerPage:(NSString *)_countPerPage
                    successed:(void (^)( id _responseObject))_success
                      failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId				forKey:@"sessionId"];
    [params setObject:_entityid              forKey:@"entity_id"];
    
    if (_pageNum) {
        [params setObject:_pageNum				forKey:@"pageNum"];
    }
    
    if (_countPerPage) {
        [params setObject:_countPerPage			forKey:@"countPerPage"];
    }
    [self sendToServiceGet:params action:[NSString stringWithFormat:@"%@",WEBAPI_GETENTITYIMAGEARCHIVE] success:_success failure:_failure ];
}

- (void)getEntityVideoHistory:(NSString *)_sessionId
                    entity_id:(NSString *)_entityid
                      pageNum:(NSString *)_pageNum
                 countPerPage:(NSString *)_countPerPage
                    successed:(void (^)( id _responseObject))_success
                      failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId				forKey:@"sessionId"];
    [params setObject:_entityid              forKey:@"entity_id"];
    
    if (_pageNum) {
        [params setObject:_pageNum				forKey:@"pageNum"];
    }
    
    if (_countPerPage) {
        [params setObject:_countPerPage			forKey:@"countPerPage"];
    }
    [self sendToServiceGet:params action:[NSString stringWithFormat:@"%@",WEBAPI_GETENTITYVIDEOHISTORY] success:_success failure:_failure ];
}

- (void)deleteEntityImageHistory:(NSString *)_sessionid
                           image:(NSString *)_imageid
                       entity_id:(NSString *)_entityid
                       successed:(void (^)( id _responseObject))_success
                         failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:_entityid forKey:@"entity_id"];
    
    [self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&image_id=%@&entity_id=%@",WEBAPI_DELETEENTITYIMAGEHISTORY, _sessionid, _imageid, _entityid] success:_success failure:_failure];
}

- (void)deleteEntityImageArchive:(NSString *)_sessionid
                         archive:(NSString *)_archiveid
                       entity_id:(NSString *)_entityid
                       successed:(void (^)( id _responseObject))_success
                         failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:_entityid forKey:@"entity_id"];
    
    [self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&archive_id=%@&entity_id=%@",WEBAPI_DELETEENTITYIMAGEARCHIVE, _sessionid, _archiveid, _entityid] success:_success failure:_failure];
}

- (void)pickupEntityImageArchive:(NSString *)_sessionid
                        archiveid:(NSString *)_archiveid
                        entity_id:(NSString *)_entityid
                       successed:(void (^)( id _responseObject))_success
                         failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:_entityid forKey:@"entity_id"];
    
    [self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&archive_id=%@&entity_id=%@",WEBAPI_PICKUENTITYIMAGEARCHIVE, _sessionid, _archiveid, _entityid] success:_success failure:_failure];
}

- (void)deleteEntityVideoHistory:(NSString *)_sessionid
                           video:(NSString *)_videoid
                       entity_id:(NSString *)_entityid
                       successed:(void (^)( id _responseObject))_success
                         failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:_entityid forKey:@"entity_id"];
    
    [self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&video_id=%@&entity_id=%@",WEBAPI_DELETEENTITYVIDEOHISTORY, _sessionid, _videoid, _entityid] success:_success failure:_failure];
}

- (void)checkSession:(NSString *)_sessionId
                udid:(NSString *)_udid
            token:(NSString *) _token
           voipToken:(NSString *)_voipToken
           successed:(void (^)( id _responseObject))_success
             failure:(void (^)( NSError* _error))_failure {
    
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId forKey:@"sessionId"];
    
    NSString *actionsStr = [NSString stringWithFormat:@"%@?sessionId=%@", WEBAPI_CHECKSESSION, _sessionId];
    if (_udid) {
        actionsStr = [NSString stringWithFormat:@"%@&device_uid=%@", actionsStr, _udid];
    }
    if (_token) {
        actionsStr = [NSString stringWithFormat:@"%@&device_token=%@", actionsStr, _token];
        
        [params setObject:_udid    forKey:@"device_uid"];
        [params setObject:_token    forKey:@"device_token"];
        [params setObject:@"2"    forKey:@"client_type"];
    }
    if (_voipToken) {
        actionsStr = [NSString stringWithFormat:@"%@&voip_token=%@", actionsStr, _voipToken];
        [params setObject:_voipToken    forKey:@"voip_token"];
    }
    
    actionsStr = [NSString stringWithFormat:@"%@&client_type=%@", actionsStr, @"2"];
    actionsStr = [NSString stringWithFormat:@"%@&os_version=iOS%@", actionsStr, [[UIDevice currentDevice] systemVersion]];
    [params setObject:[NSString stringWithFormat:@"iOS %@",[[UIDevice currentDevice] systemVersion]] forKey:@"os_version"];
    [self sendToServiceGet:nil action:actionsStr success:_success failure:_failure];
}

- (void)getVerifyCodeBySMS:(NSString *)sessionId
                 phone_num:(NSString *)phoneNumber
                 successed:(void (^)(id _responseObject))success
                   failure:(void (^)(NSError* error))failure {
    
    [self sendToServiceJSON:[NSString stringWithFormat:@"%@%@?sessionId=%@&phone_num=%@", SERVER_URL, WEBAPI_GETVERIFYCODE, sessionId, [phoneNumber stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"]] params:nil success:success failure:failure];
}

- (void)verifySMSCode:(NSString *)sessionId
             phoneNum:(NSString *)phoneNumber
           verifyCode:(NSString *)verifyCode
            successed:(void (^)(id _responseObject))success
              failure:(void (^)(NSError* error))failure {
    
    [self sendToServiceJSON:[NSString stringWithFormat:@"%@%@?sessionId=%@&phone_num=%@&verify_code=%@", SERVER_URL, WEBAPI_VERIFYSMSCODE, sessionId, [phoneNumber stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"], verifyCode] params:nil success:success failure:failure];
}

- (void)checkUsers:(NSString *)sessionId data:(NSArray *)data successed:(void (^)(id))success failure:(void (^)(NSError *))failure {
    NSDictionary *params = @{@"data": data};
    
    [self sendToServiceJSON:[NSString stringWithFormat:@"%@%@?sessionId=%@", SERVER_URL, WEBAPI_CHECKUSERS, sessionId] params:params success:success failure:failure];
}

- (void)inviteUsers:(NSString *)sessionId
             emails:(NSArray *)emails
             phones:(NSArray *)phones
          successed:(void (^)(id _responseObject))success
            failure:(void (^)(NSError* error))failure {
    NSMutableDictionary *params = [NSMutableDictionary new];
    if (emails && emails.count > 0) {
        params[@"emails"] = [emails componentsJoinedByString:@","];
    }
    
    if (phones && phones.count > 0) {
        params[@"phones"] = [phones componentsJoinedByString:@","];
    }
    
    [self sendToServiceJSON:[NSString stringWithFormat:@"%@%@?sessionId=%@", SERVER_URL, WEBAPI_INVITEUSERS, sessionId] params:params success:success failure:failure];
}

- (void)getExchangeInvites:(NSString *)sessionId keyword:(NSString *)keyword pageNum:(int)pageNum countPerPage:(int)countPerPage successed:(void (^)(id))success failure:(void (^)(NSError *))failure {
    if (keyword)
        [self sendToServiceGet:@{@"sessionId": sessionId, @"q": keyword} action:WEBAPI_GETEXCHANGEINVITES success:success failure:failure];
    else
        [self sendToServiceGet:@{@"sessionId": sessionId, @"pageNum": @(pageNum), @"countPerPage": @(countPerPage)} action:WEBAPI_GETEXCHANGEINVITES success:success failure:failure];
}

- (void)didSentInvite:(NSString *)sessionId email:(NSString *)email phone:(NSString *)phone fromLocal:(BOOL)fromLocal successed:(void (^)(id))success failure:(void (^)(NSError *))failure {
    NSString *params = @"";
    if (email)
        params = [params stringByAppendingString:[NSString stringWithFormat:@"&email=%@", email]];
    if (phone)
        params = [params stringByAppendingString:[NSString stringWithFormat:@"&phone=%@", phone]];
    if (fromLocal)
        params = [params stringByAppendingString:[NSString stringWithFormat:@"&from_local_address_book=true"]];
    [self sendToServiceJSON:[NSString stringWithFormat:@"%@%@?sessionId=%@%@", SERVER_URL, WEBAPI_INVITESEND, sessionId, params] params:nil success:success failure:failure];
}
- (void)AddFavoriteContact:(NSString *)sessionId
                 contactID:(NSString *)contactID
               contactType:(NSString *)type
                 successed:(void (^)(id))success
                   failure:(void (^)(NSError *))failure{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:contactID forKey:@"contact_id"];
    [params setObject:type forKey:@"contact_type"];
    
    [self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&contact_id=%@&contact_type=%@",WEBAPI_ADDFAVORITECONTACT, sessionId, contactID, type] success:success failure:failure];
}

- (void)RemoveFavoriteContact:(NSString *)sessionId
                 contactID:(NSString *)contactID
               contactType:(NSString *)type
                 successed:(void (^)(id))success
                   failure:(void (^)(NSError *))failure{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:contactID forKey:@"contact_id"];
    [params setObject:type forKey:@"contact_type"];
    
    [self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&contact_id=%@&contact_type=%@",WEBAPI_REMOVEFAVORITECONTACT, sessionId, contactID, type] success:success failure:failure];
}

//directory
//directory
- (void)GetDirectoryList:(NSString*)_sessionId
               successed:(void (^)( id _responseObject))_success
                 failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId				forKey:@"sessionId"];
    
    [self sendToServiceGet:params action:[NSString stringWithFormat:@"%@?sessionId=%@",WEBAPI_GETLISTDIRECTORY, _sessionId] success:_success failure:_failure ];
}
- (void)GetDirectoryDetails:(NSString*)_sessionId
                directoryId:(NSString *)_directoryId
                  successed:(void (^)( id _responseObject))_success
                    failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId				forKey:@"sessionId"];
    [params setObject:_directoryId              forKey:@"id"];
    
    [self sendToServiceGet:params action:[NSString stringWithFormat:@"%@?sessionId=%@",WEBAPI_GETDIRECTORYDETAILS,_sessionId] success:_success failure:_failure ];
}
- (void)GetDirCheckingAvail:(NSString*)_sessionId
                       name:(NSString *)_name
                  successed:(void (^)( id _responseObject))_success
                    failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId				forKey:@"sessionId"];
    [params setObject:_name				forKey:@"name"];
    
    [self sendToServiceGet:params action:[NSString stringWithFormat:@"%@?sessionId=%@&name=%@",WEBAPI_GETCHECKAVAIL, _sessionId, _name] success:_success failure:_failure ];
}
- (void)CreateDirectory:(NSString*)_sessionId
                   name:(NSString *)_name
              privilege:(BOOL)_privilege
            approveMode:(BOOL)_approveMode
                 domain:(NSString *)_domain
           profileImage:(NSString *)_profileImage
              successed:(void (^)( id _responseObject))_success
                failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    //[params setObject:_sessionId			forKey:@"sessionId"];
    [params setObject:_name                 forKey:@"name"];
    [params setObject:_privilege?@"1":@"0"			forKey:@"privilege"];
    [params setObject:_approveMode?@"1":@"0"		forKey:@"approve_mode"];
    [params setObject:_domain				forKey:@"domain"];
    if (_profileImage) {
        [params setObject:_profileImage				forKey:@"profile_image"];
    }
    
    [self sendToServiceJSON:[NSString stringWithFormat:@"%@%@?sessionId=%@",SERVER_URL,WEBAPI_CREATEDIRECTORY,_sessionId] params:params success:_success failure:_failure ];
}
- (void)UpdateDirectory:(NSString*)_sessionId
            directoryId:(NSString *)_directoryId
                   name:(NSString *)_name
              privilege:(BOOL)_privilege
            approveMode:(BOOL)_approveMode
                 domain:(NSString *)_domain
              successed:(void (^)( id _responseObject))_success
                failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_directoryId			forKey:@"id"];
    [params setObject:_name                 forKey:@"name"];
    [params setObject:_privilege?@"1":@"0"			forKey:@"privilege"];
    [params setObject:_approveMode?@"1":@"0"		forKey:@"approve_mode"];
    if (_domain) {
        [params setObject:_domain				forKey:@"domain"];
    }
    [self sendToServiceJSON:[NSString stringWithFormat:@"%@%@?sessionId=%@",SERVER_URL,WEBAPI_UPDATEDIRECTORY,_sessionId] params:params success:_success failure:_failure ];
}
- (void)DeleteDirectory:(NSString*)_sessionId
            directoryId:(NSString *)_directoryId
              successed:(void (^)( id _responseObject))_success
                failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId			forKey:@"sessionId"];
    [params setObject:_directoryId			forKey:@"id"];
    
    [self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&id=%@",WEBAPI_DELETEDIRECTORY, _sessionId, _directoryId] success:_success failure:_failure ];
}
- (void)InviteDirectoryMember:(NSString*)_sessionId
                  directoryId:(NSString *)_directoryId
                        mUids:(NSString *)_mUids
                    successed:(void (^)( id _responseObject))_success
                      failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId			forKey:@"sessionId"];
    [params setObject:_directoryId			forKey:@"id"];
    [params setObject:_mUids			forKey:@"m_uids"];
    
    [self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&id=%@&m_uids=%@",WEBAPI_INVITEDIRECTORY, _sessionId, _directoryId, _mUids] success:_success failure:_failure ];
}
- (void)RemoveInviteDrectoryMember:(NSString*)_sessionId
                       directoryId:(NSString *)_directoryId
                             mUids:(NSString *)_mUids
                         successed:(void (^)( id _responseObject))_success
                           failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId			forKey:@"sessionId"];
    [params setObject:_directoryId			forKey:@"id"];
    [params setObject:_mUids			forKey:@"m_uids"];
    
    [self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&id=%@&m_uids=%@",WEBAPI_REMOVEINVITEDIRECTORY, _sessionId, _directoryId, _mUids] success:_success failure:_failure ];
}
- (void)GetListInviteDirectory:(NSString*)_sessionId
                   directoryId:(NSString *)_directoryId
                       pageNum:(NSString *)_pageNum
                  countPerPage:(NSString *)_countPerPage
                     successed:(void (^)( id _responseObject))_success
                       failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId				forKey:@"sessionId"];
    [params setObject:_directoryId				forKey:@"id"];
    [params setObject:_pageNum				forKey:@"pageNum"];
    [params setObject:_countPerPage				forKey:@"countPerPage"];
    
    [self sendToServiceGet:params action:[NSString stringWithFormat:@"%@?sessionId=%@&id=%@&pageNum=%@&countPerPage=%@",WEBAPI_GETLISTINVITEDIRECTORY, _sessionId, _directoryId, _pageNum, _countPerPage] success:_success failure:_failure ];
}
- (void)GetConfirmedAndResquestedIdsDirectory:(NSString*)_sessionId
                   directoryId:(NSString *)_directoryId
                     successed:(void (^)( id _responseObject))_success
                       failure:(void (^)( NSError* _error))_failure
{
    [self sendToServiceGet:nil action:[NSString stringWithFormat:@"%@?sessionId=%@&id=%@",WEBAPI_GETCONFIRMEDANDREQEUSTEDIDSIRECTORY, _sessionId, _directoryId] success:_success failure:_failure ];
}
- (void)GetListConfirmedDirectory:(NSString*)_sessionId
                      directoryId:(NSString *)_directoryId
                          pageNum:(NSString *)_pageNum
                     countPerPage:(NSString *)_countPerPage
                        successed:(void (^)( id _responseObject))_success
                          failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId				forKey:@"sessionId"];
    [params setObject:_directoryId				forKey:@"id"];
    [params setObject:_pageNum				forKey:@"pageNum"];
    [params setObject:_countPerPage				forKey:@"countPerPage"];
    
    [self sendToServiceGet:params action:[NSString stringWithFormat:@"%@?sessionId=%@&id=%@&pageNum=%@&countPerPage=%@",WEBAPI_GETLISTCONFIRMEDDIRECTORY, _sessionId, _directoryId, _pageNum, _countPerPage] success:_success failure:_failure ];
}
- (void)GetListRequestDirectory:(NSString*)_sessionId
                    directoryId:(NSString *)_directoryId
                        pageNum:(NSString *)_pageNum
                   countPerPage:(NSString *)_countPerPage
                      successed:(void (^)( id _responseObject))_success
                        failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId				forKey:@"sessionId"];
    [params setObject:_directoryId				forKey:@"id"];
    [params setObject:_pageNum				forKey:@"pageNum"];
    [params setObject:_countPerPage				forKey:@"countPerPage"];
    
    [self sendToServiceGet:params action:[NSString stringWithFormat:@"%@?sessionId=%@&id=%@&pageNum=%@&countPerPage=%@",WEBAPI_GETLISTREQUESTDIRECTORY, _sessionId, _directoryId, _pageNum, _countPerPage] success:_success failure:_failure ];
}
- (void)ApproveRequestDirectory:(NSString*)_sessionId
                    directoryId:(NSString *)_directoryId
                          mUids:(NSString *)_mUids
                      successed:(void (^)( id _responseObject))_success
                        failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId			forKey:@"sessionId"];
    [params setObject:_directoryId			forKey:@"id"];
    [params setObject:_mUids			forKey:@"m_uids"];
    
    [self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&id=%@&m_uids=%@",WEBAPI_REQUESTAPPROVEDIRECTORY, _sessionId, _directoryId, _mUids] success:_success failure:_failure ];
}
- (void)DeleteRequestDirectory:(NSString*)_sessionId
                   directoryId:(NSString *)_directoryId
                         mUids:(NSString *)_mUids
                     successed:(void (^)( id _responseObject))_success
                       failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId			forKey:@"sessionId"];
    [params setObject:_directoryId			forKey:@"id"];
    [params setObject:_mUids			forKey:@"m_uids"];
    
    [self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&id=%@&m_uids=%@",WEBAPI_REQUESTDELETEDIRECTORY, _sessionId, _directoryId, _mUids] success:_success failure:_failure ];
}
- (void)RemoveMemberDirectory:(NSString*)_sessionId
                  directoryId:(NSString *)_directoryId
                        mUids:(NSString *)_mUids
                    successed:(void (^)( id _responseObject))_success
                      failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId			forKey:@"sessionId"];
    [params setObject:_directoryId			forKey:@"id"];
    [params setObject:_mUids			forKey:@"m_uids"];
    
    [self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&id=%@&m_uids=%@",WEBAPI_REMOVEMEMBERDIRECTORY, _sessionId, _directoryId, _mUids] success:_success failure:_failure ];
}
- (void)CheckExisedDirectory:(NSString*)_sessionId
                        name:(NSString *)_name
                   successed:(void (^)( id _responseObject))_success
                     failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId				forKey:@"sessionId"];
    [params setObject:_name				forKey:@"name"];
    
    [self sendToServiceGet:params action:[NSString stringWithFormat:@"%@?sessionId=%@&name=%@",WEBAPI_CHECKEDEXISEMEMBERDIRECTORY, _sessionId, _name] success:_success failure:_failure ];
}
- (void)JoinMemberDirectory:(NSString*)_sessionId
                directoryId:(NSString *)_directoryId
                    sharing:(NSString *)_sharing
             sharedHomeFids:(NSString *)_sharedHomeFids
              shareWorkFids:(NSString *)_sharedWorkFids
                  successed:(void (^)( id _responseObject))_success
                    failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId			forKey:@"sessionId"];
    [params setObject:_directoryId			forKey:@"id"];
    [params setObject:_sharing			forKey:@"sharing"];
    [params setObject:_sharedHomeFids			forKey:@"shared_home_fids"];
    [params setObject:_sharedWorkFids			forKey:@"shared_work_fids"];
    
    [self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&id=%@&sharing=%@&shared_home_fids=%@&shared_work_fids=%@",WEBAPI_JOINMEMBERDIRECTORY, _sessionId, _directoryId, _sharing, _sharedHomeFids, _sharedWorkFids] success:_success failure:_failure ];
}
- (void)GetPermissionMemberDirectory:(NSString*)_sessionId
                         directoryId:(NSString *)_directoryId
                           successed:(void (^)( id _responseObject))_success
                             failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId				forKey:@"sessionId"];
    [params setObject:_directoryId				forKey:@"id"];
    
    [self sendToServiceGet:params action:[NSString stringWithFormat:@"%@?sessionId=%@&id=%@",WEBAPI_GETPERMISSIONMEMBERDIRECTORY, _sessionId, _directoryId] success:_success failure:_failure ];
}
- (void)UpdatePermissionMemberDirectory:(NSString*)_sessionId
                            directoryId:(NSString *)_directoryId
                                sharing:(NSString *)_sharing
                         sharedHomeFids:(NSString *)_sharedHomeFids
                          shareWorkFids:(NSString *)_sharedWorkFids
                              successed:(void (^)( id _responseObject))_success
                                failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId			forKey:@"sessionId"];
    [params setObject:_directoryId			forKey:@"id"];
    [params setObject:_sharing			forKey:@"sharing"];
    [params setObject:_sharedHomeFids			forKey:@"shared_home_fids"];
    [params setObject:_sharedWorkFids			forKey:@"shared_work_fids"];
    
    [self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&id=%@&sharing=%@&shared_home_fids=%@&shared_work_fids=%@",WEBAPI_UPDATEPERMISSIONMEMBERDIRECTORY, _sessionId, _directoryId, _sharing, _sharedHomeFids, _sharedWorkFids] success:_success failure:_failure ];
}
- (void)GetListJoinedMemberDirectory:(NSString*)_sessionId
                             pageNum:(NSString *)_pageNum
                        countPerPage:(NSString *)_countPerPage
                           successed:(void (^)( id _responseObject))_success
                             failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId				forKey:@"sessionId"];
    [params setObject:_pageNum				forKey:@"pageNum"];
    [params setObject:_countPerPage				forKey:@"countPerPage"];
    
    [self sendToServiceGet:params action:[NSString stringWithFormat:@"%@?sessionId=%@&pageNum=%@&countPerPage=%@",WEBAPI_GETLISTJOINEDMEMBERDIRECTORY, _sessionId, _pageNum, _countPerPage] success:_success failure:_failure ];
}
- (void)GetListReceivedInviteMemberDirectory:(NSString*)_sessionId
                                     pageNum:(NSString *)_pageNum
                                countPerPage:(NSString *)_countPerPage
                                   successed:(void (^)( id _responseObject))_success
                                     failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId				forKey:@"sessionId"];
    [params setObject:_pageNum				forKey:@"pageNum"];
    [params setObject:_countPerPage				forKey:@"countPerPage"];
    
    [self sendToServiceGet:params action:[NSString stringWithFormat:@"%@?sessionId=%@&pageNum=%@&countPerPage=%@",WEBAPI_GETLISTRECEIVEDINVITEMEMBERDIRECTORY, _sessionId, _pageNum, _countPerPage] success:_success failure:_failure ];
}
- (void)GetListSentRequestMemberDirectory:(NSString*)_sessionId
                                  pageNum:(NSString *)_pageNum
                             countPerPage:(NSString *)_countPerPage
                                successed:(void (^)( id _responseObject))_success
                                  failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId				forKey:@"sessionId"];
    [params setObject:_pageNum				forKey:@"pageNum"];
    [params setObject:_countPerPage				forKey:@"countPerPage"];
    
    [self sendToServiceGet:params action:[NSString stringWithFormat:@"%@?sessionId=%@&pageNum=%@&countPerPage=%@",WEBAPI_GETLISTSENTREQUESTMEMBERDIRECTORY, _sessionId, _pageNum, _countPerPage] success:_success failure:_failure ];
}

- (void)uploadDirectoryPhoto:(NSString *)sessionID
                 directoryId:(NSString *)_directoryId
                  imgData:(NSData *)imgData
                successed:(void (^)(id responseObject)) success
                  failure:(void (^)(NSError* error)) failure
{
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    NSString *action = @"";
    if (_directoryId) {
        action = [NSString stringWithFormat:@"%@%@?sessionId=%@&id=%@", SERVER_URL, WEBAPI_UPLOADDIRECTORYPROFILEIMAGE, sessionID, _directoryId];
        
        [params setObject:sessionID     forKey:@"sessionId"];
        [params setObject:_directoryId      forKey:@"id"];
    }else{
        action = [NSString stringWithFormat:@"%@%@?sessionId=%@", SERVER_URL, WEBAPI_UPLOADDIRECTORYPROFILEIMAGE, sessionID];
        
        [params setObject:sessionID     forKey:@"sessionId"];
    }
    
    //set Parameters
    
    [[NetAPIClient sharedClient] sendToServiceByPOST:action params:params media:imgData mediaType:0 name:@"image" success:success failure:failure];
}

- (void)removeDirectoryPhoto:(NSString *)sessionID
                 directoryId:(NSString *)_directoryId
                successed:(void (^)(id responseObject)) success
                  failure:(void (^)(NSError* error)) failure
{
    NSString *action = [NSString stringWithFormat:@"%@%@?sessionId=%@&id=%@", SERVER_URL, WEBAPI_REMOVEDIRECTORYPROFILEIMAGE, sessionID, _directoryId];
    
    //set Parameters
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:sessionID     forKey:@"sessionId"];
    [params setObject:_directoryId      forKey:@"id"];
    
    [[NetAPIClient sharedClient] sendToServiceByPOST:action params:params success:success failure:failure];
}
- (void)GetMembersDirectory:(NSString*)_sessionId
                    directoryId:(NSString *)_directoryId
                        pageNum:(NSString *)_pageNum
                   countPerPage:(NSString *)_countPerPage
                      successed:(void (^)( id _responseObject))_success
                        failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId				forKey:@"sessionId"];
    [params setObject:_directoryId				forKey:@"id"];
    [params setObject:_pageNum				forKey:@"pageNum"];
    [params setObject:_countPerPage				forKey:@"countPerPage"];
    
    [self sendToServiceGet:params action:[NSString stringWithFormat:@"%@?sessionId=%@&id=%@&pageNum=%@&countPerPage=%@",WEBAPI_GETALLMEMBERSOFDIRECTORY, _sessionId, _directoryId, _pageNum, _countPerPage] success:_success failure:_failure ];
}
- (void)QuitMemberDirectory:(NSString*)_sessionId
                       directoryId:(NSString *)_directoryId
                         successed:(void (^)( id _responseObject))_success
                           failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId			forKey:@"sessionId"];
    [params setObject:_directoryId			forKey:@"id"];
    
    [self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&id=%@",WEBAPI_DIRECTORYMEMBERQUIT, _sessionId, _directoryId] success:_success failure:_failure ];
}
- (void)GetMemberInfo:(NSString*)_sessionId
                directoryId:(NSString *)_directoryId
                    userId:(NSString *)_userId
                  successed:(void (^)( id _responseObject))_success
                    failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId				forKey:@"sessionId"];
    [params setObject:_directoryId				forKey:@"id"];
    [params setObject:_userId				forKey:@"userId"];
    
    [self sendToServiceGet:params action:[NSString stringWithFormat:@"%@?sessionId=%@&id=%@&uid=%@",WEBAPI_DIRECTORYMEMBERINFO, _sessionId, _directoryId, _userId] success:_success failure:_failure ];
}
- (void)ValidateEmail:(NSString*)_sessionId
                  key:(NSString*)_key
          successed:(void (^)( id _responseObject))_success
            failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_key				forKey:@"key"];
    [params setObject:@"json"			forKey:@"format"];
    
    [self sendToServiceGet:params action:[NSString stringWithFormat:@"%@?key=%@&sessionId=%@",WEBAPI_DIRECTORYVALIDATEEMAIL,_key, _sessionId]  success:_success failure:_failure ];
}

- (void)CreateBoardDirectory:(NSString*)_sessionId
                directoryId:(NSString *)_directoryId
                  successed:(void (^)( id _responseObject))_success
                    failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId			forKey:@"sessionId"];
    [params setObject:_directoryId			forKey:@"group_id"];
    
    [self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&group_id=%@",WEBAPI_DIRECTORYCHATCREATEBOARD, _sessionId, _directoryId] success:_success failure:_failure ];
}
- (void)GetMemberInfosForChat:(NSString*)_sessionId
                      boardId:(NSNumber*)_boardId
                      userids:(NSString*)_userIds
            successed:(void (^)( id _responseObject))_success
              failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_boardId				forKey:@"board_id"];
    [params setObject:_userIds			forKey:@"user_ids"];
    
    [self sendToServiceGet:nil action:[NSString stringWithFormat:@"%@%@?sessionId=%@&user_ids=%@",WEBAPI_DIRECTORYMEMBERSINFOFORCHAT,_boardId, _sessionId, _userIds]  success:_success failure:_failure ];
}

- (void)RemoveJoinInviteDirectory:(NSString*)_sessionId
                 directoryIds:(NSString *)_directoryIds
                   successed:(void (^)( id _responseObject))_success
                     failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId			forKey:@"sessionId"];
    [params setObject:_directoryIds			forKey:@"ids"];
    
    [self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&ids=%@",WEBAPI_DIRECTORYMEMBERREMOVEJOININVITE, _sessionId, _directoryIds] success:_success failure:_failure ];
}

- (void)CancelJoinRequestDirectory:(NSString*)_sessionId
                 directoryIds:(NSString *)_directoryIds
                   successed:(void (^)( id _responseObject))_success
                     failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId			forKey:@"sessionId"];
    [params setObject:_directoryIds			forKey:@"ids"];
    
    [self sendToService:params action:[NSString stringWithFormat:@"%@?sessionId=%@&ids=%@",WEBAPI_DIRECTORYMEMBERCANCELJOINREQUEST, _sessionId, _directoryIds] success:_success failure:_failure ];
}

//video/voice conference
- (void)OpenVideoConference:(NSString*)_sessionId
                    boardId:(NSString *)_boardId
                       type:(NSInteger)_type
                  successed:(void (^)( id _responseObject))_success
                    failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId		forKey:@"sessionId"];
    [params setObject:_boardId			forKey:@"board_id"];
    [params setObject:@(_type)          forKey:@"callType"];
    
    [self sendToService:params action:[NSString stringWithFormat:@"%@%@?sessionId=%@&callType=%ld",WEBAPI_VIDEOSTARTFORCONFERENCE,_boardId, _sessionId, (long)_type] success:_success failure:_failure ];
}
- (void)AcceptVideoConference:(NSString*)_sessionId
                     boardId:(NSString *)_boardId
                   successed:(void (^)( id _responseObject))_success
                     failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId			forKey:@"sessionId"];
    [params setObject:_boardId			forKey:@"board_id"];
    
    [self sendToService:params action:[NSString stringWithFormat:@"%@%@?sessionId=%@",WEBAPI_VOIDOACCEPTFORCONFERENCE,_boardId, _sessionId] success:_success failure:_failure ];
}
- (void)CancelVideoConference:(NSString*)_sessionId
                     boardId:(NSString *)_boardId
                   successed:(void (^)( id _responseObject))_success
                     failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId			forKey:@"sessionId"];
    [params setObject:_boardId			forKey:@"board_id"];
    
    [self sendToService:params action:[NSString stringWithFormat:@"%@%@?sessionId=%@",WEBAPI_VIDEOCANCELFORCONFERENCE,_boardId, _sessionId] success:_success failure:_failure ];
}
- (void)HangupVideoConference:(NSString*)_sessionId
                     boardId:(NSString *)_boardId
                      endType:(NSInteger)_endType
                   successed:(void (^)( id _responseObject))_success
                     failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId			forKey:@"sessionId"];
    [params setObject:_boardId			forKey:@"board_id"];
    [params setObject:@(_endType)          forKey:@"endType"];
    
    [self sendToService:params action:[NSString stringWithFormat:@"%@%@?sessionId=%@&endType=%ld",WEBAPI_VIDEOHANGUPFORCONFERENCE,_boardId, _sessionId, (long)_endType] success:_success failure:_failure ];
}
- (void)SendVideoDataForSDPConference:(NSString*)_sessionId
                        boardId:(NSString *)_boardId
                                  sdp:(NSString *)_sdp
                                  toUser:(NSString *)_toUser
                     successed:(void (^)( id _responseObject))_success
                       failure:(void (^)( NSError* _error))_failure
{
    
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    //[params setObject:_sessionId			forKey:@"sessionId"];
    [params setObject:[NSString stringWithFormat:@"%@", _sdp]                  forKey:@"sdp"];
    [params setObject:[NSString stringWithFormat:@"%@", _toUser]                  forKey:@"to"];
    
    [self sendToServiceJSON:[NSString stringWithFormat:@"%@%@%@?sessionId=%@",SERVER_URL,WEBAPI_VIDEODADASEND, _boardId ,_sessionId] params:params success:_success failure:_failure ];
}
- (void)SendVideoDataForCandidateConference:(NSString*)_sessionId
                              boardId:(NSString *)_boardId
                                  candidate:(NSMutableArray *)_candidate
                                     toUser:(NSString *)_toUser
                            successed:(void (^)( id _responseObject))_success
                              failure:(void (^)( NSError* _error))_failure
{
    
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    //[params setObject:_sessionId			forKey:@"sessionId"];
    [params setObject:_candidate                forKey:@"candidates"];
    [params setObject:[NSString stringWithFormat:@"%@", _toUser]                  forKey:@"to"];
    
    [self sendToServiceJSON:[NSString stringWithFormat:@"%@%@%@?sessionId=%@",SERVER_URL,WEBAPI_VIDEODADASEND, _boardId ,_sessionId] params:params success:_success failure:_failure ];
}

- (void)GetVideoDataConference:(NSString*)_sessionId
                        boardId:(NSString *)_boardId
                      dataType:(NSString *)_dataType
                            userId:(NSString *)_userId
                      successed:(void (^)( id _responseObject))_success
                        failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_boardId				forKey:@"board_id"];
    if (_dataType) {
        [params setObject:_dataType         forKey:@"dataType"];
    }
    if (![[NSString stringWithFormat:@"%@", _userId] isEqualToString:@""]) {
        [params setObject:_userId		forKey:@"from"];
    }
    
    [self sendToServiceGet:nil action:[NSString stringWithFormat:@"%@%@?sessionId=%@&dataType=%@&from=%@",WEBAPI_VIDEODATAGET,_boardId, _sessionId, _dataType, _userId]  success:_success failure:_failure ];
}
- (void)InviteNewMembersOnConference:(NSString*)_sessionId
                             boardId:(NSString *)_boardId
                             userIds:(NSString *)_userIds
                           successed:(void (^)( id _responseObject))_success
                             failure:(void (^)( NSError* _error))_failure
{
    NSMutableDictionary*    params  = [NSMutableDictionary dictionary];
    
    [params setObject:_sessionId		forKey:@"sessionId"];
    [params setObject:_boardId			forKey:@"board_id"];
    [params setObject:_userIds          forKey:@"user_ids"];
    
    [self sendToService:params action:[NSString stringWithFormat:@"%@%@?sessionId=%@&user_ids=%@",WEBAPI_INVITEMEMBERONCONFERENCE,_boardId, _sessionId, _userIds] success:_success failure:_failure ];
}
- (void)TurnStatusOfVideoConference:(NSString*)_sessionId
                             boardId:(NSString *)_boardId
                             status:(NSString *)_status
                           successed:(void (^)( id _responseObject))_success
                             failure:(void (^)( NSError* _error))_failure
{
    [self sendToService:nil action:[NSString stringWithFormat:@"%@%@/%@?sessionId=%@",WEBAPI_TURNSTATUSOFVIDEOCONFERENCE, _status, _boardId, _sessionId] success:_success failure:_failure ];
}

- (void)TurnStatusOfAudioConference:(NSString*)_sessionId
                            boardId:(NSString *)_boardId
                             status:(NSString *)_status
                          successed:(void (^)( id _responseObject))_success
                            failure:(void (^)( NSError* _error))_failure
{
    [self sendToService:nil action:[NSString stringWithFormat:@"%@%@/%@?sessionId=%@",WEBAPI_TURNSTATUSOFAUDIOCONFERENCE, _status, _boardId, _sessionId] success:_success failure:_failure ];
}

- (void)RejectingOtherCalling:(NSString *)_sessionId
                    successed:(void (^)( id _responseObject))_success
                      failure:(void (^)( NSError* _error))_failure{
    [self sendToService:nil action:[NSString stringWithFormat:@"%@?sessionId=%@",WEBAPI_REJECTINGOTHERCALLING, _sessionId] success:_success failure:_failure ];
}

@end
