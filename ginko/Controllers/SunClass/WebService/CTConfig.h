//
//  CTConfig.h
//  ReactChat
//
//  Created by mobidev on 5/16/14.
//  Copyright (c) 2014 iDevelopers. All rights reserved.
//

#pragma once

// Contact Builder Section;
#define WEBAPI_GETCBEMAILS					@"/ContactBuilder/getCBemails"
#define WEBAPI_UPDATECBEMAIL				@"/ContactBuilder/updateEmailSetting"
#define WEBAPI_DELETECBEMAIL				@"/ContactBuilder/deleteEmail"
#define WEBAPI_GETCBEMAILBYEMAILID          @"/ContactBuilder/getCBEmail"

#define WEBAPIP_GETCONTACTS                 @"/User/getContacts"
#define WEBAPIP_ADDGREYCONTACT              @"/grey/contact/add"
#define WEBAPIP_UPDATECONTACT               @"/sync/contact/updateDetail"
#define WEBAPIP_UPLOADPHOTO                 @"/grey/contact/setPhoto"
#define WEBAPIP_DELETEPHOTO                 @"/grey/contact/removePhoto"
#define WEBAPI_REMOVEGREYCONTACT            @"/sync/contact/greyContact/remove"

#define WEBAPIP_GETINFO                     @"/UserInfo/getInfo"

//importer class
#define WEBAPI_GETOAUTHURL                 @"/sync/contact/fetch_redirect"
#define WEBAPI_SYNCCONTACTBYOAUTH          @"/sync/contact/import"
#define WEBAPI_GETSYNCHISTORY              @"/sync/contact/getHistory"
#define WEBAPI_DELETESYNCCONTACT           @"/sync/contact/delete"
#define WEBAPI_UPDATESYNCCONTACT           @"/sync/contact/greyContact/save"
#define WEBAPI_DISCOVEROWASERVER           @"/sync/contact/server/discover"
#define WEBAPI_SYNCCONTACTBYOWA            @"/sync/contact/import/owa"
#define WEBAPI_SYNCMULTIPLECONTACTS        @"/sync/contact/multiple/add"

//profile photo
#define WEBAPI_UPLOADPROFILEPHOTO           @"/tradecard/profile/image/upload"
#define WEBAPI_UPLOADENTITYPHOTO            @"/entity/profile/image/upload"
#define WEBAPI_REMOVEENTITYPHOTO            @"/entity/profile/image/remove"
#define WEBAPI_DELETEPROFILEPHOTO           @"/tradecard/profile/image/remove"

//contact builder importer
#define WEBAPI_CBGETOAUTHURL                @"/ContactBuilder/fetch_redirect"


