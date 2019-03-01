//
//  Communication.h
//  Ginko
//
//  Created by Qi Song on 27/03/14.
//  Copyright (c) 2014 Qi Song. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

@interface Communication:AFHTTPSessionManager<NSURLConnectionDelegate>
{
	NSMutableData *_responseData;
}
@property ( strong, nonatomic)NSDictionary		*me1 ;
@property ( strong, nonatomic)NSMutableArray		*lstFavourite;

+ ( Communication*)sharedManager ;
// Web Service ;

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
					name:(NSString*)_name
				mimetype:(NSString*)_mimetype
                 success:(void (^)(id _responseObject))_success
                 failure:(void (^)(NSError* _error))_failure ;

- (void)CreateChatBoard:(NSString*)_sessionid
				   userids:(NSString*)_userids
				 successed:(void (^)(id _responseObject))_success
				   failure:(void (^)(NSError* _error))_failure;

- (void)SendMessage:(NSString*)_sessionid
			  board_id:(NSString*)_boardid
			   message:(NSString*)_message
			 successed:(void (^)(id _responseObject))_success
			   failure:(void (^)(NSError* _error))_failure;

- (void)UserLogin:(NSString*)_email
			password:(NSString*)_password
          clientType:(NSString*)_clientType
           deviceUID:(NSString*)_deviceUID
         deviceToken:(NSString*)_deviceToken
        voipToken:(NSString*)_voipToken
		   successed:(void (^)(id _responseObject))_success
			 failure:(void (^)(NSError* _error))_failure;

- (void)CheckNewMessage:(NSString*)_sessionid
				 successed:(void (^)(id _responseObject))_success
				   failure:(void (^)(NSError* _error))_failure;

- (void)AddNewMember:(NSString*)_sessionid
				boardid:(NSString*)_boardid
				userids:(NSString*)_userids
				 successed:(void (^)(id _responseObject))_success
				   failure:(void (^)(NSError* _error))_failure;

- (void)LeaveBoard:(NSString*)_sessionid
			  boardid:(NSString*)_boardid
			successed:(void (^)(id _responseObject))_success
			  failure:(void (^)(NSError* _error))_failure;

- (void)SendFile:(NSString*)_sessionid
			   data:(NSData*)_data
			   name:(NSString*)_name
		   mimetype:(NSString*)_mimetype
			boardid:(NSString*)_boardid
		  successed:(void (^)(id _responseObject))_success
			failure:(void (^)(NSError* _error))_failure;

- (void)GetChatBoards:(NSString*)_sessionid
			   successed:(void (^)(id _responseObject))_success
				 failure:(void (^)(NSError* _error))_failure;

- (void)GetMessageHistory:(NSString*)_sessionid
					 boardid:(NSString*)_boardid
					  number:(NSString*)_number
					lastdays:(NSString*)_lastdays
				   successed:(void (^)(id _responseObject))_success
					 failure:(void (^)(NSError* _error))_failure;

- (void)GetBoardInformation:(NSString*)_sessionid
                    boardid:(NSString*)_boardid
                  successed:(void (^)(id _responseObject))_success
                    failure:(void (^)(NSError* _error))_failure;

- (void)GetFriend:(NSString*)_sessionid
		   successed:(void (^)(id _responseObject))_success
			 failure:(void (^)(NSError* _error))_failure;

- (void) GetFriendsFound:(NSString *) _sessionid
                    type:(NSString *) _type
                 pageNum:(NSString *) _pageNum
            countPerPage:(NSString *) _countPerPage
               successed:(void (^)(id _responseObject))_success
                 failure:(void (^)(NSError * _error))_failure;

- (void)GetRequests:(NSString*)_sessionid
             successed:(void (^)(id _responseObject))_success
               failure:(void (^)(NSError* _error))_failure;

- (void)GetInvitations:(NSString*)_sessionid
             successed:(void (^)(id _responseObject))_success
               failure:(void (^)(NSError* _error))_failure;

- (void)GetSentInvitations:(NSString*)_sessionid
             successed:(void (^)(id _responseObject))_success
               failure:(void (^)(NSError* _error))_failure;

- (void)AddInvitations:(NSString*)_sessionid
                 email:(NSString*)_email
                 phone:(NSString *)phone
                    successed:(void (^)(id _responseObject))_success
                      failure:(void (^)(NSError* _error))_failure;

- (void) AnswerRequest:(NSString *)_sessionid
             contactId:(NSString *)_contactId
           sharingInfo:(NSString *)_sharingInfo
    sharedHomeFieldIds:(NSString *)_sharedHomeFieldIds
    sharedWorkFieldIds:(NSString *)_sharedWorkFieldIds
             phoneOnly:(BOOL)_phoneOnly
             emailOnly:(BOOL)_emailOnly
             successed:(void (^)(id _responseObject))_success
               failure:(void (^)(NSError *))_failure;

- (void) SetUpdateLocation:(NSString *)_sessionid
                 longitude:(NSString*)_longitude
                  latitude:(NSString*)_latitude
				 successed:(void (^)(id _responseObject))_success
				   failure:(void (^)(NSError* _error))_failure;

- (void)GetMyInfo:(NSString *)_sessionid
      contact_uid:(NSString *)_contactId
        successed:(void (^)(id _responseObject))_success
          failure:(void (^)(NSError *))_failure;

- (void) RequestSend:(NSString *)_sessionid
           contactId:(NSString *)_contactId
         sharingInfo:(NSString *)_sharingInfo
  sharedHomeFieldIds:(NSString *)_sharedHomeFieldIds
  sharedWorkFieldIds:(NSString *)_sharedWorkFieldIds
           phoneOnly:(BOOL)_phoneOnly
           emailOnly:(BOOL)_emailOnly
           successed:(void (^)(id _responseObject))_success
             failure:(void (^)(NSError *))_failure;

// Created by Zhun L.
- (void)GetMyPhoto:(NSString *)_sessionid
         successed:(void (^)(id _responseObject))_success
          failure:(void (^)(NSError *))_failure;

- (void) SendInvitation:(NSString *)_sessionid
            sharingInfo:(NSString *)_sharingInfo
                  email:(NSString *)_email
     sharedHomeFieldIds:(NSString *)_sharedHomeFieldIds
     sharedWorkFieldIds:(NSString *)_sharedWorkFieldIds
              phoneOnly:(BOOL)_phoneOnly
              emailOnly:(BOOL)_emailOnly
              successed:(void (^)(id _responseObject))_success
                failure:(void (^)(NSError *))_failure;

- (void) DeleteInvitation:(NSString *)_sessionid
                   emails:(NSString *)_emails
                successed:(void (^)(id _responseObject))_success
                  failure:(void (^)(NSError *))_failure;

- (void) DeleteRequest:(NSString *)_sessionid
               contactIds:(NSString *)_contactIds
                entityIds:(NSString *)_entityIds
                successed:(void (^)(id _responseObject))_success
                  failure:(void (^)(NSError *))_failure;

- (void) DeleteSentInvitation:(NSString *)_sessionid
                   emails:(NSString *)_emails
                successed:(void (^)(id _responseObject))_success
                  failure:(void (^)(NSError *))_failure;

- (void) RemoveContact:(NSString *)_sessionid
            contactIds:(NSString *)_contactIds
             successed:(void (^)(id _responseObject))_success
               failure:(void (^)(NSError *))_failure;
- (void) RemoveContactSelected:(NSString *)_sessionid
                    contactIds:(NSString *)_contactIds
                     successed:(void (^)(id _responseObject))_success
                       failure:(void (^)(NSError *))_failure;
- (void)GetContacts:(NSString *)_sessionid
             sortby:(NSString *)_sortBy
             search:(NSString *)_search
           category:(NSString *)_category
        contactType:(NSString *)_contactType
        successed:(void (^)(id _responseObject))_success
          failure:(void (^)(NSError *))_failure;

- (void)GetContactsSync:(NSString *)_sessionid
                 sortby:(NSString *)_sortBy
                 search:(NSString *)_search
               category:(NSString *)_category
            contactType:(NSString *)_contactType
              successed:(void (^)(id _responseObject))_success
                failure:(void (^)(NSError *))_failure;

- (void)GetSuggestions:(NSString *)_sessionid
                sortby:(NSString *)_sortBy
                search:(NSString *)_search
             successed:(void (^)(id _responseObject))_success
               failure:(void (^)(NSError *))_failure;

- (void)GetPending:(NSString *)_sessionid
             successed:(void (^)(id _responseObject))_success
               failure:(void (^)(NSError *))_failure;

- (void)SetNotification:(NSString *)_sessionid
              deviceUID:(NSString *)_deviceUID
               exchange:(NSString *)_exchange
                   chat:(NSString *)_chat
                 sprout:(NSString *)_sprout
                profile:(NSString *)_profile
                 entity:(NSString *)_entity
              successed:(void (^)(id _responseObject))_success
                failure:(void (^)(NSError *))_failure;

- (void)Logout:(NSString *)_sessionid
              deviceUID:(NSString *)_deviceUID
              successed:(void (^)(id _responseObject))_success
                failure:(void (^)(NSError *))_failure;

- (void)ChangePwd:(NSString *)_sessionid
        curPwd:(NSString *)_curPwd
        newPwd:(NSString *)_newPwd
     successed:(void (^)(id _responseObject))_success
       failure:(void (^)(NSError *))_failure;

- (void)GetDeactivateReason:(NSString *)_sessionid
         successed:(void (^)(id _responseObject))_success
           failure:(void (^)(NSError *))_failure;

- (void)Deactivate:(NSString *)_sessionid
            curPwd:(NSString *)_curPwd
        reasonCode:(NSString *)_reasonCode
       otherReason:(NSString *)_otherReason
         successed:(void (^)(id _responseObject))_success
           failure:(void (^)(NSError *))_failure;

- (void)GetLoginSettings:(NSString *)_sessionid
             successed:(void (^)(id _responseObject))_success
               failure:(void (^)(NSError *))_failure;

- (void)AddLogin:(NSString *)_sessionid
           email:(NSString *)_email
       successed:(void (^)(id _responseObject))_success
         failure:(void (^)(NSError *))_failure;

- (void)DeleteLogin:(NSString *)_sessionid
              email:(NSString *)_email
       successed:(void (^)(id _responseObject))_success
         failure:(void (^)(NSError *))_failure;

- (void)SendValidLink:(NSString *)_email
            successed:(void (^)(id _responseObject))_success
              failure:(void (^)(NSError *))_failure;

- (void)UpdateNote:(NSString *)_sessionid
        contactIds:(NSString *)_contactIds
            notes:(NSString *)_notes
        successed:(void (^)(id _responseObject))_success
          failure:(void (^)(NSError *))_failure;

- (void)GetNotificationSetting:(NSString *)_sessionid
                     successed:(void (^)(id _responseObject))_success
                       failure:(void (^)(NSError *))_failure;

- (void)UpdateIsRead:(NSString *)_sessionid
        contactIds:(NSString *)_contactIds
         contactType:(NSString *)_contactType
             isRead:(NSString *)_isRead
         successed:(void (^)(id _responseObject))_success
           failure:(void (^)(NSError *))_failure;

- (void)GetCBEmailValid:(NSString *)_sessionid
             successed:(void (^)(id _responseObject))_success
               failure:(void (^)(NSError *))_failure;

- (void)UpdateExchangePermission:(NSString *)_sessionid
                       contactId:(NSString *)_contactId
                     sharingInfo:(NSString *)_sharingInfo
              sharedHomeFieldIds:(NSString *)_sharedHomeFieldIds
              sharedWorkFieldIds:(NSString *)_sharedWorkFieldIds
                       phoneOnly:(BOOL)_phoneOnly
                       emailOnly:(BOOL)_emailOnly
                       successed:(void (^)(id _responseObject))_success
                         failure:(void (^)(NSError *))_failure;

- (void)getContactDetail:(NSString *)_sessionid
               contactId:(NSString *)_contactId
             contactType:(NSString *)_contactType
               successed:(void (^)(id _responseObject))_success
                 failure:(void (^)(NSError *))_failure;
// -----------------

- (void) RequestCancel:(NSString *)_sessionid
            contactIds:(NSString *)_contactIds
             successed:(void (^)(id _responseObject))_success
               failure:(void (^)(NSError *))_failure;

- (void) DeleteDetectedFriends:(NSString *)_sessionid
                    contactIds:(NSString *)_contactIds
                   remove_type:(NSString *)_remove_type
                     successed:(void (^)(id _responseObject))_success
                       failure:(void (^)(NSError *))_failure;

- (void) DeleteDetectedContacts:(NSString *)_sessionid
                        userIDs:(NSString *)_userids
                      entityIDs:(NSString *)_entityids
                    remove_type:(NSString *)_remove_type
                      successed:(void (^)(id _responseObject))_success
                        failure:(void (^)(NSError *))_failure;

- (void) ChangeGPSStatus:(NSString *)_sessionid
                 trun_on:(NSString *)_turn_on
               successed:(void (^)(id _responseObject))_success
                 failure:(void (^)(NSError *))_failure;

- (void)updatedContactsSynced:(NSString *)sessionId
                    timeStamp:(NSString*)timeStamp
                    successed:(void (^)(id))_success
                      failure:(void (^)(NSError *))_failure;

- (void)syncUpdatedContacts:(NSString *)sessionId
                  timeStamp:(NSString *)timestamp
                  successed:(void (^)(id))_success
                    failure:(void (^)(NSError *))_failure;

- (void)followEntity:(NSString *)_sessionId
           entity_id:(NSString*)_entityId
           successed:(void (^)(id))_success
             failure:(void (^)(NSError *))_failure;

- (void)getPurpleContacts:(NSString *)_sessionId
                  pageNum:(NSInteger)pageNum
             countPerPage:(NSInteger)countPerPage
                  keyword:(NSString*)keyword
                successed:(void (^)(id))_success
                  failure:(void (^)(NSError *err))_failure;

- (void)getDetectedContacts:(NSString *)_sessionId
                    pageNum:(NSInteger)pageNum
               countPerPage:(NSInteger)countPerPage
                    keyword:(NSString*)keyword
                  successed:(void (^)(id))_success
                    failure:(void (^)(NSError *err))_failure;

- (void)setFilter:(NSString *)_sessionId
             type:(NSInteger)type
         user_ids:(NSString*)user_ids
   remove_existed:(BOOL)remove_existed
        successed:(void (^)(id))_success
          failure:(void (^)(NSError *err))_failure;

- (void)getFilteredContacts:(NSString *)_sessionId
                  successed:(void (^)(id))_success
                    failure:(void (^)(NSError *err))_failure;
- (void)SyncUpdatedOfEntity:(NSString*)_sessionId
                  successed:(void (^)( id _responseObject))_success
                    failure:(void (^)( NSError* _error))_failure;
- (void)FetchAllOfEntity:(NSString*)_sessionId
               successed:(void (^)( id _responseObject))_success
                 failure:(void (^)( NSError* _error))_failure;
- (void)SyncUpdatedOfEntityNew:(NSString*)_sessionId
                  successed:(void (^)( id _responseObject))_success
                    failure:(void (^)( NSError* _error))_failure;
- (void)FetchAllOfEntityNew:(NSString*)_sessionId
               successed:(void (^)( id _responseObject))_success
                 failure:(void (^)( NSError* _error))_failure;
- (void)SelectedEntitySummary:(NSString*)_sessionId
                     entityId:(NSString*)_entityId
                    successed:(void (^)( id _responseObject))_success
                      failure:(void (^)( NSError* _error))_failure;



@end
