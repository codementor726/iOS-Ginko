//
//  YYYCommunication.h
//  CruiseShip
//
//  Created by Yang Dandan on 25/10/13.
//  Copyright (c) 2013 Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

//#define SERVER_URL               @"http://www.xchangewith.me/api/v2/api"

@interface YYYCommunication:AFHTTPSessionManager<NSURLConnectionDelegate>
{
	NSMutableData *_responseData;
}

+ ( YYYCommunication*)sharedManager ;
// Web Service ;76

- (void)download:(NSString *)url
        fileName:(NSString *)fileName
        success:(void (^)(NSString * str))_success
        failure:(void (^)(NSError* _error))_failure;

- (void)sendToService:(NSDictionary*)_params
                  action:(NSString*)_action
                 success:(void (^)(id _responseObject))_success
                 failure:(void (^)(NSError* _error))_failure ;

- (void)sendToServiceGet:(NSDictionary*)_params
					 action:(NSString*)_action
					success:(void (^)(id _responseObject))_success
					failure:(void (^)(NSError* _error))_failure;

- (void)sendToService:(NSDictionary*)_params
                  action:(NSString*)_action
					data:(NSData*)_data
			   thumbnail:(NSData*)_thumbnail
					name:(NSString*)_name
				mimetype:(NSString*)_mimetype
                 success:(void (^)(id _responseObject))_success
                 failure:(void (^)(NSError* _error))_failure;

//---------------IM------------------
- (void)CreateChatBoard:(NSString*)_sessionid
				   userids:(NSString*)_userids
				 successed:(void (^)(id _responseObject))_success
				   failure:(void (^)(NSError* _error))_failure;

- (void)SendMessage:(NSString*)_sessionid
			  board_id:(NSNumber*)_boardid
			   message:(NSString*)_message
			 successed:(void (^)(id _responseObject))_success
			   failure:(void (^)(NSError* _error))_failure;

- (void)CheckNewMessage:(NSString*)_sessionid
				 successed:(void (^)(id _responseObject))_success
				   failure:(void (^)(NSError* _error))_failure;

- (void)AddNewMember:(NSString*)_sessionid
				boardid:(NSNumber*)_boardid
				userids:(NSString*)_userids
				 successed:(void (^)(id _responseObject))_success
				   failure:(void (^)(NSError* _error))_failure;

- (void)LeaveBoard:(NSString*)_sessionid
			 boardids:(NSString*)_boardids
			successed:(void (^)(id _responseObject))_success
			  failure:(void (^)(NSError* _error))_failure;

- (void)SendFile:(NSString*)_sessionid
			   data:(NSData*)_data
		  thumbnail:(NSData*)_thumbnail
			   name:(NSString*)_name
		   mimetype:(NSString*)_mimetype
			boardid:(NSNumber*)_boardid
		  successed:(void (^)(id _responseObject))_success
			failure:(void (^)(NSError* _error))_failure;

- (void)GetChatBoards:(NSString*)_sessionid
			   successed:(void (^)(id _responseObject))_success
				 failure:(void (^)(NSError* _error))_failure;

- (void)GetMessageHistory:(NSString*)_sessionid
                  boardid:(NSNumber*)_boardid
                   number:(NSString*)_number
                 lastdays:(NSString*)_lastdays
              earlierThan:(NSDate *)earlierThan
                laterThan:(NSDate *)laterThan
                successed:(void (^)(id _responseObject))_success
                  failure:(void (^)(NSError* _error))_failure;

- (void)GetFriend:(NSString*)_sessionid
		   successed:(void (^)(id _responseObject))_success
			 failure:(void (^)(NSError* _error))_failure;

- (void)ClearMessage:(NSString*)_sessionid
				boardid:(NSNumber*)_boardid
			  successed:(void (^)(id _responseObject))_success
				failure:(void (^)(NSError* _error))_failure;

- (void)ClearEntityMessage:(NSString*)_sessionid
                     entityId:(NSString*)_entityId
                    successed:(void (^)(id _responseObject))_success
                      failure:(void (^)(NSError* _error))_failure;

- (void)DeleteMessages:(NSString*)_sessionid
				  boardid:(NSNumber*)_boardid
			   messageids:(NSString*)_messageids
				successed:(void (^)(id _responseObject))_success
				  failure:(void (^)(NSError* _error))_failure;

- (void)GetContactInfo:(NSString*)_sessionid
				contactid:(NSString*)_contactid
				successed:(void (^)(id _responseObject))_success
				  failure:(void (^)(NSError* _error))_failure;

- (void)ReadMessage:(NSString*)_sessionid
			  board_id:(NSNumber*)_board_id
			   msg_ids:(NSString*)_msg_ids
			 successed:(void (^)(id _responseObject))_success
			   failure:(void (^)(NSError* _error))_failure;



//---------------LOGIN REGISTER------------------

- (void)GetMyUserInfo:(NSString*)_sessionid
			   successed:(void (^)(id _responseObject))_success
				 failure:(void (^)(NSError* _error))_failure;

- (void)UserLogin:(NSString*)_email
			password:(NSString*)_password
				udid:(NSString*)_udid
            token:(NSString*)_token
        voipToken:(NSString *)_voipToken
		   successed:(void (^)(id _responseObject))_success
			 failure:(void (^)(NSError* _error))_failure;

- (void)UserLoginOpenID:(NSString*)_email
                       code: (NSString *)_code
				clienttype:(NSString*)_clienttype
					  udid:(NSString*)_udid
					 token:(NSString*)_token
				 successed:(void (^)(id _responseObject))_success
				   failure:(void (^)(NSError* _error))_failure;

- (void)ForgotPassword:(NSString*)_email
				successed:(void (^)(id _responseObject))_success
				  failure:(void (^)(NSError* _error))_failure;

- (void)SignUP:(NSString*)_email
		firstname:(NSString*)_name
		 lastname:(NSString*)_lastname
		 password:(NSString*)_password
             udid:(NSString*)_udid
         token:(NSString*)_token
     voipToken:(NSString *)_voipToken
		successed:(void (^)(id _responseObject))_success
		  failure:(void (^)(NSError* _error))_failure;

- (void)SendValidationEmail:(NSString*)_email
					 successed:(void (^)(id _responseObject))_success
					   failure:(void (^)(NSError* _error))_failure;

- (void)AcceptLogin:(NSString*)_key
          voipToken:(NSString *)_voipToken
			 successed:(void (^)(id _responseObject))_success
			   failure:(void (^)(NSError* _error))_failure;

- (void)UploadMultipleImages:(NSString*)_sessionId
						   type:(NSString*)_type
					 background:(NSData*)_background
					 foreground:(NSData*)_foreground
					  successed:(void (^)(id _responseObject))_success
						failure:(void (^)(NSError* _error))_failure;

- (void)SetInfo1:(NSString*)_sessionId
              group:(NSString*)_group
             fields:(NSArray*)_field
             images:(NSArray*)_images
          successed:(void (^)(id _responseObject))_success
            failure:(void (^)(NSError* _error))_failure;

- (void)SetInfo:(NSString*)_sessionId
			 group:(NSString*)_group
			fields:(NSArray*)_field
		 successed:(void (^)(id _responseObject))_success
		   failure:(void (^)(NSError* _error))_failure;

- (void)deleteWorkProfile:(NSString*)_sessionId
                       group:(NSString*)_group
                   successed:(void (^)(id _responseObject))_success
                     failure:(void (^)(NSError* _error))_failure;

- (void)UploadVideo:(NSString*)_sessionId
				  type:(NSString*)_type
				 video:(NSData*)_video
			 thumbnail:(NSData*)_thumb
			 successed:(void (^)(id _responseObject))_success
			   failure:(void (^)(NSError* _error))_failure;

- (void)GetInfo:(NSString*)_sessionId
		 successed:(void (^)(id _responseObject))_success
		   failure:(void (^)(NSError* _error))_failure;

//Wang class AE
//Entity
- (void)UploadMultipleImagesForEntity:(NSString*)_sessionId
								entityid:(NSString*)_entityId
							  background:(NSData*)_background
							  foreground:(NSData*)_foreground
							   successed:(void (^)(id _responseObject))_success
								 failure:(void (^)(NSError* _error))_failure;

- (void)UploadEntityVideo:(NSString*)_sessionId
					entityid:(NSString*)_entityId
					   video:(NSData*)_video
				   thumbnail:(NSData*)_thumb
				   successed:(void (^)(id _responseObject))_success
					 failure:(void (^)(NSError* _error))_failure;

- (void)SaveEntity:(NSString*)_sessionId
		   categoryid:(NSString*)_categoryid
				 name:(NSString*)_name
			keysearch:(NSString*)_keysearch
			successed:(void (^)(id _responseObject))_success
			  failure:(void (^)(NSError* _error))_failure;

- (void)SaveEntityPowerful:(NSString*)_sessionId
				   categoryid:(NSString*)_categoryid
						 name:(NSString*)_name
               description:(NSString *)description
					keysearch:(NSString*)_keysearch
				   background:(NSData*)_background
				   foreground:(NSData*)_foreground
					successed:(void (^)(id _responseObject))_success
					  failure:(void (^)(NSError* _error))_failure;

- (void)UpdateEntity:(NSString*)_sessionId
			   entityid:(NSString*)_entityId
				   name:(NSString*)_name
			  keysearch:(NSString*)_keysearch
			 categoryid:(NSString*)_categoryid
			  privilege:(NSString*)_privilege
				  infos:(NSArray*)_infos
			  successed:(void (^)(id _responseObject))_success
				failure:(void (^)(NSError* _error))_failure;

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
               successed:(void (^)(id _responseObject))_success
                 failure:(void (^)(NSError* _error))_failure;

- (void)updatePrivilege:(NSString*)_sessionId
                  entityid:(NSString*)_entityId
                 privilege:(NSString*)_privilege
                 successed:(void (^)(id _responseObject))_success
                   failure:(void (^)(NSError* _error))_failure;

- (void)updateUserPrivilege:(NSString*)_sessionId
                 homePrivilege:(NSString*)_homePrivilege
                 workPrivilege:(NSString*)_workPrivilege
                     successed:(void (^)(id _responseObject))_success
                       failure:(void (^)(NSError* _error))_failure;

- (void)DeleteEntity:(NSString*)_sessionId
			   entityid:(NSString*)_entityId
			  successed:(void (^)(id _responseObject))_success
				failure:(void (^)(NSError* _error))_failure;

- (void)DeleteLocation:(NSString*)_sessionId
				 entityid:(NSString*)_entityId
				   infoid:(NSString*)_infoId
				successed:(void (^)(id _responseObject))_success
				  failure:(void (^)(NSError* _error))_failure;

- (void)ListAll:(NSString*)_sessionId
		 successed:(void (^)(id _responseObject))_success
		   failure:(void (^)(NSError* _error))_failure;

- (void)RmoveEntityPhoto:(NSString*)_sessionId
				   entityid:(NSString*)_entityId
					imageid:(NSString*)_imageid
				  successed:(void (^)(id _responseObject))_success
					failure:(void (^)(NSError* _error))_failure;

- (void)RmoveEntityVideo:(NSString*)_sessionId
                   entityid:(NSString*)_entityId
                  successed:(void (^)(id _responseObject))_success
                    failure:(void (^)(NSError* _error))_failure;

//ee class
- (void)GetEntityCategory:(NSString*)_sessionId
				  categoryid:(NSString*)_categoryId
				   successed:(void (^)(id _responseObject))_success
					 failure:(void (^)(NSError* _error))_failure;

- (void)GetEntityDetail:(NSString*)_sessionId
				  entityid:(NSString*)_entityid
				 successed:(void (^)(id _responseObject))_success
				   failure:(void (^)(NSError* _error))_failure;

- (void)ListEntity:(NSString*)_sessionId
            successed:(void (^)(id _responseObject))_success
              failure:(void (^)(NSError* _error))_failure;

//Entity Messenger
- (void)GetEntityByFollowr:(NSString*)_sessionId
                     entityid:(NSString*)_entityid
                    successed:(void (^)(id _responseObject))_success
                      failure:(void (^)(NSError* _error))_failure;
- (void)GetEntityByFollowrNew:(NSString*)_sessionId
                     entityid:(NSString*)_entityid
                     infoFrom:(NSString*)_infoFrom
                    infoCount:(NSString*)_infoCount
                     latitude:(float)_latitude
                    longitude:(float)_longitude
                    successed:(void (^)( id _responseObject))_success
                      failure:(void (^)( NSError* _error))_failure;
- (void)FollowEntity:(NSString*)_sessionId
               entityid:(NSString*)_entityid
              successed:(void (^)(id _responseObject))_success
                failure:(void (^)(NSError* _error))_failure;

- (void)UnFollowEntity:(NSString*)_sessionId
                 entityid:(NSString*)_entityid
                successed:(void (^)(id _responseObject))_success
                  failure:(void (^)(NSError* _error))_failure;

- (void)FollowerSetNotes:(NSString*)_sessionId
                   entityid:(NSString*)_entityid
                       notes: ( NSString*)_notes
                  successed:(void (^)(id _responseObject))_success
                    failure:(void (^)(NSError* _error))_failure;

- (void)getAllEntityMessages:(NSString*)_sessionId
                       entityid:(NSString*)_entityid
                         pageNum: ( NSString*)_pageNum
                    countPerPage: ( NSString*)_countPerPage
                      successed:(void (^)(id _responseObject))_success
                        failure:(void (^)(NSError* _error))_failure;

- (void)listMessageBoard:(NSString*)_sessionId
                            pageNum: ( NSString*)_pageNum
                       countPerPage: ( NSString*)_countPerPage
                         successed:(void (^)(id _responseObject))_success
                           failure:(void (^)(NSError* _error))_failure;

- (void)getEntityMessageHistory:(NSString*)_sessionId
                            pageNum: ( NSString*)_pageNum
                       countPerPage: ( NSString*)_countPerPage
                         successed:(void (^)(id _responseObject))_success
                           failure:(void (^)(NSError* _error))_failure;

- (void)SendEntityMessage:(NSString*)_sessionid
                    entityid:(NSString*)_entityid
                     content:(NSString*)_message
                   successed:(void (^)(id _responseObject))_success
                     failure:(void (^)(NSError* _error))_failure;

- (void)SendEntityFile:(NSString*)_sessionid
                 entityid:(NSString*)_entityid
                     data:(NSData*)_data
                thumbnail:(NSData*)_thumbnail
                     name:(NSString*)_name
                 mimetype:(NSString*)_mimetype
                successed:(void (^)(id _responseObject))_success
                  failure:(void (^)(NSError* _error))_failure;

- (void)DeleteEntityMessages:(NSString*)_sessionid
                       entityid:(NSString*)_entityid
                     messageids:(NSString*)_messageids
                      successed:(void (^)(id _responseObject))_success
                        failure:(void (^)(NSError* _error))_failure;

- (void)InviteEntityFriends:(NSString*)_sessionid
                      entityid:(NSString*)_entityid
                      contacts:(NSString*)_contact_uids
                     successed:(void (^)(id _responseObject))_success
                       failure:(void (^)(NSError* _error))_failure;

- (void)deleteFollowers:(NSString*)_sessionid
                  entityid:(NSString*)_entityid
                  contacts:(NSString*)_contact_uids
                 successed:(void (^)(id _responseObject))_success
                   failure:(void (^)(NSError* _error))_failure;

- (void)getEntityContacts:(NSString*)_sessionId
                    entityid:(NSString*)_entityid
                     invited:(NSString*)_isInvited
                   successed:(void (^)(id _responseObject))_success
                     failure:(void (^)(NSError* _error))_failure;

//Groups
- (void)addGroup:(NSString*)_sessionid
               name:(NSString*)_name
          successed:(void (^)(id _responseObject))_success
            failure:(void (^)(NSError* _error))_failure;

- (void)deleteGroup:(NSString*)_sessionid
               groupID:(NSString*)_groupID
             successed:(void (^)(id _responseObject))_success
               failure:(void (^)(NSError* _error))_failure;

- (void)renameGroup:(NSString*)_sessionid
               groupID:(NSString*)_groupID
                  name:(NSString*)_name
             successed:(void (^)(id _responseObject))_success
               failure:(void (^)(NSError* _error))_failure;

- (void)addUserToGroup:(NSString*)_sessionid
                  groupID:(NSString*)_groupID
              contactKeys:(NSString*)_contactKeys
                successed:(void (^)(id _responseObject))_success
                  failure:(void (^)(NSError* _error))_failure;

- (void)removeUserFromGroup:(NSString*)_sessionid
                       groupID:(NSString*)_groupID
                   contactKeys:(NSString*)_contactKeys
                     successed:(void (^)(id _responseObject))_success
                       failure:(void (^)(NSError* _error))_failure;

- (void)getGroupList:(NSString*)_sessionId
              successed:(void (^)(id _responseObject))_success
                failure:(void (^)(NSError* _error))_failure;

- (void)getUsersForGroup:(NSString*)_sessionId
                    groupID:(NSString*)_groupID
                  successed:(void (^)(id _responseObject))_success
                    failure:(void (^)(NSError* _error))_failure;


- (void)getRemainingContacts:(NSString*)_sessionId
                        groupID:(NSString*)_groupID
                      successed:(void (^)(id _responseObject))_success
                        failure:(void (^)(NSError* _error))_failure;
- (void)SaveAllPositionOfGroups:(NSString*)_sessionId
                      fields:(NSArray*)_field
                   successed:(void (^)( id _responseObject))_success
                     failure:(void (^)( NSError* _error))_failure;
- (void)SavePositionGroup:(NSString *)_sessionId
                  groupID:(NSString *)_groupID
                 orderNum:(NSString *)_orderNum
              oldOrderNum:(NSString *)_oldOrderNum
                successed:(void (^)( id _responseObject))_success
                  failure:(void (^)( NSError* _error))_failure;
//search
- (void)listSearchContacts:(NSString*)_sessionId
                    searchKey:(NSString*)_searchKey
                    successed:(void (^)(id _responseObject))_success
                      failure:(void (^)(NSError* _error))_failure
;

- (void)setWizardPage:(NSString*)_sessionid
               setupPage:(NSString*)_setupPage
               successed:(void (^)(id _responseObject))_success
                 failure:(void (^)(NSError* _error))_failure;

//archive
- (void)getProfileImageHistory:(NSString *)_sessionId
                          type:(NSString *)_type
                       pageNum:(NSString *)_pageNum
                  countPerPage:(NSString *)_countPerPage
                     successed:(void (^)(id _responseObject))_success
                       failure:(void (^)(NSError* _error))_failure;

- (void)getProfileImageArchive:(NSString *)_sessionId
                          type:(NSString *)_type
                       pageNum:(NSString *)_pageNum
                  countPerPage:(NSString *)_countPerPage
                     successed:(void (^)(id _responseObject))_success
                       failure:(void (^)(NSError* _error))_failure;

- (void)getProfileVideoHistory:(NSString *)_sessionId
                          type:(NSString *)_type
                       pageNum:(NSString *)_pageNum
                  countPerPage:(NSString *)_countPerPage
                     successed:(void (^)(id _responseObject))_success
                       failure:(void (^)(NSError* _error))_failure;

- (void)deleteProfileImageHistory:(NSString *)_sessionid
                            image:(NSString *)_imageid
                             type:(NSString *)_type
                       successed:(void (^)(id _responseObject))_success
                         failure:(void (^)(NSError* _error))_failure;

- (void)deleteProfileImageArchive:(NSString *)_sessionid
                        archiveid:(NSString *)_archiveid
                             type:(NSString *)_type
                       successed:(void (^)(id _responseObject))_success
                         failure:(void (^)(NSError* _error))_failure;

- (void)pickupProfileImageArchive:(NSString *)_sessionid
                        archiveid:(NSString *)_archiveid
                             type:(NSString *)_type
                       successed:(void (^)(id _responseObject))_success
                         failure:(void (^)(NSError* _error))_failure;

- (void)deleteProfileVideoHistory:(NSString *)_sessionid
                            video:(NSString *)_videoid
                             type:(NSString *)_type
                       successed:(void (^)(id _responseObject))_success
                         failure:(void (^)(NSError* _error))_failure;

- (void)removeProfileVideo:(NSString *)_sessionid
                     video:(NSString *)_videoid
                      type:(NSString *)_type
                successed:(void (^)(id _responseObject))_success
                  failure:(void (^)(NSError* _error))_failure;

- (void)removePhoto:(NSString *)_sessionid
              image:(NSString *)_imageid
               type:(NSString *)_type
         successed:(void (^)(id _responseObject))_success
           failure:(void (^)(NSError* _error))_failure;

- (void)getEntityImageHistory:(NSString *)_sessionId
                    entity_id:(NSString *)_entityid
                      pageNum:(NSString *)_pageNum
                 countPerPage:(NSString *)_countPerPage
                    successed:(void (^)(id _responseObject))_success
                      failure:(void (^)(NSError* _error))_failure;

- (void)getEntityImageArchive:(NSString *)_sessionId
                    entity_id:(NSString *)_entityid
                      pageNum:(NSString *)_pageNum
                 countPerPage:(NSString *)_countPerPage
                    successed:(void (^)(id _responseObject))_success
                      failure:(void (^)(NSError* _error))_failure;

- (void)getEntityVideoHistory:(NSString *)_sessionId
                    entity_id:(NSString *)_entityid
                      pageNum:(NSString *)_pageNum
                 countPerPage:(NSString *)_countPerPage
                    successed:(void (^)(id _responseObject))_success
                      failure:(void (^)(NSError* _error))_failure;

- (void)deleteEntityImageHistory:(NSString *)_sessionid
                           image:(NSString *)_imageid
                       entity_id:(NSString *)_entityid
                       successed:(void (^)(id _responseObject))_success
                         failure:(void (^)(NSError* _error))_failure;

- (void)deleteEntityImageArchive:(NSString *)_sessionid
                         archive:(NSString *)_archiveid
                       entity_id:(NSString *)_entityid
                       successed:(void (^)(id _responseObject))_success
                         failure:(void (^)(NSError* _error))_failure;

- (void)pickupEntityImageArchive:(NSString *)_sessionid
                       archiveid:(NSString *)_archiveid
                       entity_id:(NSString *)_entityid
                      successed:(void (^)(id _responseObject))_success
                        failure:(void (^)(NSError* _error))_failure;

- (void)deleteEntityVideoHistory:(NSString *)_sessionid
                           video:(NSString *)_videoid
                       entity_id:(NSString *)_entityid
                       successed:(void (^)(id _responseObject))_success
                         failure:(void (^)(NSError* _error))_failure;
- (void)checkSession:(NSString *)_sessionId
                udid:(NSString *)_udid
               token:(NSString *) _token
           voipToken:(NSString *)_voipToken
           successed:(void (^)(id _responseObject))_success
             failure:(void (^)(NSError* _error))_failure;

- (void)getVerifyCodeBySMS:(NSString *)sessionId
                           phone_num:(NSString *)phoneNumber
                       successed:(void (^)(id _responseObject))success
                         failure:(void (^)(NSError* error))failure;

- (void)verifySMSCode:(NSString *)sessionId
             phoneNum:(NSString *)phoneNumber
           verifyCode:(NSString *)verifyCode
            successed:(void (^)(id _responseObject))success
              failure:(void (^)(NSError* error))failure;

- (void)checkUsers:(NSString *)sessionId
             data:(NSArray *)data
            successed:(void (^)(id _responseObject))success
              failure:(void (^)(NSError* error))failure;

- (void)inviteUsers:(NSString *)sessionId
              emails:(NSArray *)emails
            phones:(NSArray *)phones
         successed:(void (^)(id _responseObject))success
           failure:(void (^)(NSError* error))failure;

- (void)getExchangeInvites:(NSString *)sessionId keyword:(NSString *)keyword pageNum:(int)pageNum countPerPage:(int)countPerPage successed:(void (^)(id))success failure:(void (^)(NSError *))failure;

- (void)didSentInvite:(NSString *)sessionId
                email:(NSString *)email
                phone:(NSString *)phone
            fromLocal:(BOOL)fromLocal
            successed:(void (^)(id))success
              failure:(void (^)(NSError *))failure;

//Favorite contact
- (void)AddFavoriteContact:(NSString *)sessionId
                 contactID:(NSString *)contactID
               contactType:(NSString *)type
                 successed:(void (^)(id))success
                   failure:(void (^)(NSError *))failure;
- (void)RemoveFavoriteContact:(NSString *)sessionId
                 contactID:(NSString *)contactID
               contactType:(NSString *)type
                 successed:(void (^)(id))success
                   failure:(void (^)(NSError *))failure;

//directory
- (void)GetDirectoryList:(NSString*)_sessionId
               successed:(void (^)( id _responseObject))_success
                 failure:(void (^)( NSError* _error))_failure;

- (void)GetDirectoryDetails:(NSString*)_sessionId
                directoryId:(NSString *)_directoryId
                  successed:(void (^)( id _responseObject))_success
                    failure:(void (^)( NSError* _error))_failure;

- (void)GetDirCheckingAvail:(NSString*)_sessionId
                       name:(NSString *)_name
                  successed:(void (^)( id _responseObject))_success
                    failure:(void (^)( NSError* _error))_failure;

- (void)CreateDirectory:(NSString*)_sessionId
                   name:(NSString *)_name
              privilege:(BOOL)_privilege
            approveMode:(BOOL)_approveMode
                 domain:(NSString *)_domain
           profileImage:(NSString *)_profileImage
              successed:(void (^)( id _responseObject))_success
                failure:(void (^)( NSError* _error))_failure;

- (void)UpdateDirectory:(NSString*)_sessionId
            directoryId:(NSString *)_directoryId
                   name:(NSString *)_name
              privilege:(BOOL)_privilege
            approveMode:(BOOL)_approveMode
                 domain:(NSString *)_domain
              successed:(void (^)( id _responseObject))_success
                failure:(void (^)( NSError* _error))_failure;

- (void)DeleteDirectory:(NSString*)_sessionId
            directoryId:(NSString *)_directoryId
              successed:(void (^)( id _responseObject))_success
                failure:(void (^)( NSError* _error))_failure;

- (void)InviteDirectoryMember:(NSString*)_sessionId
                  directoryId:(NSString *)_directoryId
                        mUids:(NSString *)_mUids
                    successed:(void (^)( id _responseObject))_success
                      failure:(void (^)( NSError* _error))_failure;

- (void)RemoveInviteDrectoryMember:(NSString*)_sessionId
                       directoryId:(NSString *)_directoryId
                             mUids:(NSString *)_mUids
                         successed:(void (^)( id _responseObject))_success
                           failure:(void (^)( NSError* _error))_failure;

- (void)GetListInviteDirectory:(NSString*)_sessionId
                   directoryId:(NSString *)_directoryId
                       pageNum:(NSString *)_pageNum
                  countPerPage:(NSString *)_countPerPage
                     successed:(void (^)( id _responseObject))_success
                       failure:(void (^)( NSError* _error))_failure;

- (void)GetConfirmedAndResquestedIdsDirectory:(NSString*)_sessionId
                                  directoryId:(NSString *)_directoryId
                                    successed:(void (^)( id _responseObject))_success
                                      failure:(void (^)( NSError* _error))_failure;

- (void)GetListConfirmedDirectory:(NSString*)_sessionId
                      directoryId:(NSString *)_directoryId
                          pageNum:(NSString *)_pageNum
                     countPerPage:(NSString *)_countPerPage
                        successed:(void (^)( id _responseObject))_success
                          failure:(void (^)( NSError* _error))_failure;

- (void)GetListRequestDirectory:(NSString*)_sessionId
                    directoryId:(NSString *)_directoryId
                        pageNum:(NSString *)_pageNum
                   countPerPage:(NSString *)_countPerPage
                      successed:(void (^)( id _responseObject))_success
                        failure:(void (^)( NSError* _error))_failure;

- (void)ApproveRequestDirectory:(NSString*)_sessionId
                    directoryId:(NSString *)_directoryId
                          mUids:(NSString *)_mUids
                      successed:(void (^)( id _responseObject))_success
                        failure:(void (^)( NSError* _error))_failure;

- (void)DeleteRequestDirectory:(NSString*)_sessionId
                   directoryId:(NSString *)_directoryId
                         mUids:(NSString *)_mUids
                     successed:(void (^)( id _responseObject))_success
                       failure:(void (^)( NSError* _error))_failure;

- (void)RemoveMemberDirectory:(NSString*)_sessionId
                  directoryId:(NSString *)_directoryId
                        mUids:(NSString *)_mUids
                    successed:(void (^)( id _responseObject))_success
                      failure:(void (^)( NSError* _error))_failure;

- (void)CheckExisedDirectory:(NSString*)_sessionId
                        name:(NSString *)_name
                   successed:(void (^)( id _responseObject))_success
                     failure:(void (^)( NSError* _error))_failure;

- (void)JoinMemberDirectory:(NSString*)_sessionId
                directoryId:(NSString *)_directoryId
                    sharing:(NSString *)_sharing
             sharedHomeFids:(NSString *)_sharedHomeFids
              shareWorkFids:(NSString *)_sharedWorkFids
                  successed:(void (^)( id _responseObject))_success
                    failure:(void (^)( NSError* _error))_failure;

- (void)GetPermissionMemberDirectory:(NSString*)_sessionId
                         directoryId:(NSString *)_directoryId
                           successed:(void (^)( id _responseObject))_success
                             failure:(void (^)( NSError* _error))_failure;

- (void)UpdatePermissionMemberDirectory:(NSString*)_sessionId
                            directoryId:(NSString *)_directoryId
                                sharing:(NSString *)_sharing
                         sharedHomeFids:(NSString *)_sharedHomeFids
                          shareWorkFids:(NSString *)_sharedWorkFids
                              successed:(void (^)( id _responseObject))_success
                                failure:(void (^)( NSError* _error))_failure;

- (void)GetListJoinedMemberDirectory:(NSString*)_sessionId
                             pageNum:(NSString *)_pageNum
                        countPerPage:(NSString *)_countPerPage
                           successed:(void (^)( id _responseObject))_success
                             failure:(void (^)( NSError* _error))_failure;

- (void)GetListReceivedInviteMemberDirectory:(NSString*)_sessionId
                                     pageNum:(NSString *)_pageNum
                                countPerPage:(NSString *)_countPerPage
                                   successed:(void (^)( id _responseObject))_success
                                     failure:(void (^)( NSError* _error))_failure;

- (void)GetListSentRequestMemberDirectory:(NSString*)_sessionId
                                  pageNum:(NSString *)_pageNum
                             countPerPage:(NSString *)_countPerPage
                                successed:(void (^)( id _responseObject))_success
                                  failure:(void (^)( NSError* _error))_failure;
- (void)uploadDirectoryPhoto:(NSString *)sessionID
                 directoryId:(NSString *)_directoryId
                     imgData:(NSData *)imgData
                   successed:(void (^)(id responseObject)) success
                     failure:(void (^)(NSError* error)) failure;
- (void)removeDirectoryPhoto:(NSString *)sessionID
                 directoryId:(NSString *)_directoryId
                   successed:(void (^)(id responseObject)) success
                     failure:(void (^)(NSError* error)) failure;
- (void)GetMembersDirectory:(NSString*)_sessionId
                directoryId:(NSString *)_directoryId
                    pageNum:(NSString *)_pageNum
               countPerPage:(NSString *)_countPerPage
                  successed:(void (^)( id _responseObject))_success
                    failure:(void (^)( NSError* _error))_failure;
- (void)QuitMemberDirectory:(NSString*)_sessionId
                directoryId:(NSString *)_directoryId
                  successed:(void (^)( id _responseObject))_success
                    failure:(void (^)( NSError* _error))_failure;
- (void)GetMemberInfo:(NSString*)_sessionId
          directoryId:(NSString *)_directoryId
               userId:(NSString *)_userId
            successed:(void (^)( id _responseObject))_success
              failure:(void (^)( NSError* _error))_failure;
- (void)ValidateEmail:(NSString*)_sessionId
                  key:(NSString*)_key
            successed:(void (^)( id _responseObject))_success
              failure:(void (^)( NSError* _error))_failure;

- (void)CreateBoardDirectory:(NSString*)_sessionId
                 directoryId:(NSString *)_directoryId
                   successed:(void (^)( id _responseObject))_success
                     failure:(void (^)( NSError* _error))_failure;
- (void)GetMemberInfosForChat:(NSString*)_sessionId
                      boardId:(NSNumber*)_boardId
                      userids:(NSString*)_userIds
                    successed:(void (^)( id _responseObject))_success
                      failure:(void (^)( NSError* _error))_failure;
- (void)RemoveJoinInviteDirectory:(NSString*)_sessionId
                     directoryIds:(NSString *)_directoryIds
                        successed:(void (^)( id _responseObject))_success
                          failure:(void (^)( NSError* _error))_failure;

- (void)CancelJoinRequestDirectory:(NSString*)_sessionId
                      directoryIds:(NSString *)_directoryIds
                         successed:(void (^)( id _responseObject))_success
                           failure:(void (^)( NSError* _error))_failure;

//video/voice conference
- (void)OpenVideoConference:(NSString*)_sessionId
                    boardId:(NSString *)_boardId
                       type:(NSInteger)_type
                  successed:(void (^)( id _responseObject))_success
                    failure:(void (^)( NSError* _error))_failure;

- (void)AcceptVideoConference:(NSString*)_sessionId
                      boardId:(NSString *)_boardId
                    successed:(void (^)( id _responseObject))_success
                      failure:(void (^)( NSError* _error))_failure;

- (void)CancelVideoConference:(NSString*)_sessionId
                      boardId:(NSString *)_boardId
                    successed:(void (^)( id _responseObject))_success
                      failure:(void (^)( NSError* _error))_failure;

- (void)HangupVideoConference:(NSString*)_sessionId
                      boardId:(NSString *)_boardId
                      endType:(NSInteger)_endType
                    successed:(void (^)( id _responseObject))_success
                      failure:(void (^)( NSError* _error))_failure;

- (void)SendVideoDataForSDPConference:(NSString*)_sessionId
                              boardId:(NSString *)_boardId
                                  sdp:(NSString *)_sdp
                               toUser:(NSString *)_toUser
                            successed:(void (^)( id _responseObject))_success
                              failure:(void (^)( NSError* _error))_failure;

- (void)SendVideoDataForCandidateConference:(NSString*)_sessionId
                                    boardId:(NSString *)_boardId
                                  candidate:(NSMutableArray *)_candidate
                                     toUser:(NSString *)_toUser
                                  successed:(void (^)( id _responseObject))_success
                                    failure:(void (^)( NSError* _error))_failure;

- (void)GetVideoDataConference:(NSString *)_sessionId
                       boardId:(NSString *)_boardId
                      dataType:(NSString *)_dataType
                        userId:(NSString *)_userId
                     successed:(void (^)( id _responseObject))_success
                       failure:(void (^)( NSError* _error))_failure;

- (void)InviteNewMembersOnConference:(NSString*)_sessionId
                             boardId:(NSString *)_boardId
                             userIds:(NSString *)_userIds
                           successed:(void (^)( id _responseObject))_success
                             failure:(void (^)( NSError* _error))_failure;

- (void)TurnStatusOfVideoConference:(NSString*)_sessionId
                            boardId:(NSString *)_boardId
                             status:(NSString *)_status
                          successed:(void (^)( id _responseObject))_success
                            failure:(void (^)( NSError* _error))_failure;
- (void)TurnStatusOfAudioConference:(NSString*)_sessionId
                            boardId:(NSString *)_boardId
                             status:(NSString *)_status
                          successed:(void (^)( id _responseObject))_success
                            failure:(void (^)( NSError* _error))_failure;
- (void)RejectingOtherCalling:(NSString *)_sessionId
                    successed:(void (^)( id _responseObject))_success
                      failure:(void (^)( NSError* _error))_failure;
@end
