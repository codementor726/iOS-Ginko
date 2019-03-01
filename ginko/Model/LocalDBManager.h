//
//  LocalDBManager.h
//  ginko
//
//  Created by STAR on 11/13/15.
//  Copyright © 2015 com.xchangewithme. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Users.h"
#import "Message.h"

#define kUsersEntity    @"Users"
#define kMessageEntity  @"Message"

@class NSBubbleData;

@interface LocalDBManager : NSObject {
    Users *_userObject;
}

// Helper method for getting shared instance
+ (LocalDBManager *)sharedManager;

// Used to save the messages from api response to local db
- (void)saveMessagesToLocalDB:(NSArray *)messageDics boardId:(NSNumber *)boardId;

// Get messages earlier than specific date from local db
- (NSArray *)getMessagesEarlierThan:(NSDate *)date boardId:(NSNumber *)boardId count:(int)messageCount;

// Used when sending message to save to local db
- (void)addBubbleData:(NSBubbleData *)bubbleData boardId:(NSNumber *)boardId;

// Delete selected messages with given message ids
- (void)deleteSelectedMessages:(NSArray *)messageIds;

// Delete all messages for chat board
- (void)deleteAllMessagesForBoard:(NSNumber *)boardId;

// Get target cached file name for given server file path
+ (NSString *)getCachedFileNameFromRemotePath:(NSString *)url;

// Return the path of cached file from given server file path, nil if not saved
+ (NSString *)checkCachedFileExist:(NSString *)url;

+ (void)saveImage:(UIImage *)image forRemotePath:(NSString *)url;

+ (void)saveData:(NSData *)data forRemotePath:(NSString *)url;

// Current user entity object
@property (nonatomic, strong) Users *userObject;


@end
