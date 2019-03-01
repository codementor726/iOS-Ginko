//
//  LocalDBManager.m
//  ginko
//
//  Created by STAR on 11/13/15.
//  Copyright © 2015 com.xchangewithme. All rights reserved.
//

#import "LocalDBManager.h"
#import "AppDelegate.h"
#import "NSBubbleData.h"

@implementation LocalDBManager {
    NSManagedObjectContext *managedObjectContext;
}

@synthesize userObject = _userObject;

+ (LocalDBManager *)sharedManager {
    static LocalDBManager *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        managedObjectContext = [AppDelegate sharedDelegate].managedObjectContext;
    }
    
    return self;
}

- (Users *)userObject {
    if (_userObject) {
        return _userObject;
    }
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:kUsersEntity
                                        inManagedObjectContext:managedObjectContext]];
    [fetchRequest setFetchLimit:1];
    
    // check whether the entity exists or not
    // set predicate as you want, here just use |companyName| as an example
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"userId = %@", [AppDelegate sharedDelegate].userId]];
    
    // if get a entity, that means exists, so fetch it.
    if ([managedObjectContext countForFetchRequest:fetchRequest error:&error])
        _userObject = [[managedObjectContext executeFetchRequest:fetchRequest error:&error] lastObject];
    // if not exists, just insert a new entity
    else
        _userObject = [NSEntityDescription insertNewObjectForEntityForName:kUsersEntity
                                                inManagedObjectContext:managedObjectContext];
    
    // No matter it is new or not, just update data for |entity|
    _userObject.userId = [AppDelegate sharedDelegate].userId;
    // ...
    
    // save
    if (![managedObjectContext save:&error])
        NSLog(@"Couldn't save data to %@, error: %@", NSStringFromClass([self class]), error);
    
    return _userObject;
}

- (NSArray *)getMessagesEarlierThan:(NSDate *)date boardId:(NSNumber *)boardId count:(int)messageCount {
    // create a query
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kMessageEntity];
    
    if (date) { // if date is specified
        request.predicate = [NSPredicate predicateWithFormat:@"userId.userId = %@ AND datetime <= %@ AND boardId = %@", [AppDelegate sharedDelegate].userId, date, boardId];
    } else {
        request.predicate = [NSPredicate predicateWithFormat:@"userId.userId = %@ AND boardId = %@", [AppDelegate sharedDelegate].userId, boardId];
    }
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"datetime" ascending:NO];
    request.sortDescriptors = @[sortDescriptor];
    
    request.fetchLimit = messageCount;
    
    return [managedObjectContext executeFetchRequest:request error:nil];
}

- (void)saveMessagesToLocalDB:(NSArray *)messageDics boardId:(NSNumber *)boardId {
    Users *user = self.userObject;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        
    for(NSDictionary *messageDic in messageDics) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:kMessageEntity
                                            inManagedObjectContext:managedObjectContext]];
        [fetchRequest setFetchLimit:1];
        
        // check whether the entity exists or not
        // set predicate as you want, here just use |companyName| as an example
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"messageId == %@", messageDic[@"msg_id"]]];
        
        // if get a entity, that means exists, so fetch it.
        if ([managedObjectContext countForFetchRequest:fetchRequest error:nil])
            continue;
        
        Message *message = [NSEntityDescription insertNewObjectForEntityForName:kMessageEntity inManagedObjectContext:managedObjectContext];
        message.boardId = boardId;
        message.content = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:messageDic options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
        message.datetime = [dateFormatter dateFromString:messageDic[@"send_time"]];
        message.messageId = messageDic[@"msg_id"];
        message.userId = user;
        if ([messageDic[@"msgType"] intValue] == 0) { // this is media: photo, video
            message.mediaFilePath = messageDic[@"content"][@"url"];
        }
    }
    
    NSError *error;
    
    // save
    if (![managedObjectContext save:&error])
        NSLog(@"Couldn't save data to %@", NSStringFromClass([self class]));
}

- (void)addBubbleData:(NSBubbleData *)bubbleData boardId:(NSNumber *)boardId {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:kMessageEntity
                                        inManagedObjectContext:managedObjectContext]];
    [fetchRequest setFetchLimit:1];
    
    // check whether the entity exists or not
    // set predicate as you want, here just use |companyName| as an example
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"messageId == %@", bubbleData.msg_id]];
    
    // if get a entity, that means exists, so fetch it.
    if ([managedObjectContext countForFetchRequest:fetchRequest error:nil])
        return;
    
    Message *message = [NSEntityDescription insertNewObjectForEntityForName:kMessageEntity inManagedObjectContext:managedObjectContext];
    message.boardId = boardId;
    
    NSMutableDictionary *messageDic = [NSMutableDictionary new];
    
    if (bubbleData.contentType == NSBubbleContentTypeText) {
        messageDic[@"msgType"] = @1;
        messageDic[@"content"] = bubbleData.contentText;
    } else {
        messageDic[@"msgType"] = @2;
        if (bubbleData.contentType == NSBubbleContentTypePhoto) {
            messageDic[@"content"] = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:@{@"file_type": @"photo", @"url": bubbleData.mediaFilePath} options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
        } else if (bubbleData.contentType == NSBubbleContentTypeVideo) {
            messageDic[@"content"] = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:@{@"file_type": @"video", @"url": bubbleData.mediaFilePath,@"thumnail_url":bubbleData.videoThumbPath} options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
        } else if (bubbleData.contentType == NSBubbleContentTypeVoice) {
            messageDic[@"content"] = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:@{@"file_type": @"voice", @"url": bubbleData.mediaFilePath} options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
        }
    }
    messageDic[@"msg_id"] = @([bubbleData.msg_id integerValue]);
    messageDic[@"send_from"] = @([bubbleData.msg_userid integerValue]);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    messageDic[@"send_time"] = [dateFormatter stringFromDate:bubbleData.date];
    messageDic[@"is_read"] = @YES;
    messageDic[@"is_new"] = @NO;
    message.content = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:messageDic options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    
    message.datetime = bubbleData.date;
    
    message.messageId = @([bubbleData.msg_id integerValue]);
    
    message.userId = self.userObject;
    
    if (bubbleData.contentType == NSBubbleContentTypePhoto || bubbleData.contentType == NSBubbleContentTypeVideo || bubbleData.contentType == NSBubbleContentTypeVoice) {
        message.mediaFilePath = bubbleData.mediaFilePath;
    }
    
    NSError *error;
    
    // save
    if (![managedObjectContext save:&error])
        NSLog(@"Couldn't save data to %@", NSStringFromClass([self class]));
}

- (void)deleteSelectedMessages:(NSArray *)messageIds {
    // create a query
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kMessageEntity];
    
    // make a query
    request.predicate = [NSPredicate predicateWithFormat:@"userId.userId = %@ AND messageId IN %@", [AppDelegate sharedDelegate].userId, messageIds];
    
    NSArray *foundMessages = [managedObjectContext executeFetchRequest:request error:nil];
    
    for (Message *message in foundMessages) {
        [managedObjectContext deleteObject:message];
    }
    
    NSError *error = nil;
    
    // save
    if (![managedObjectContext save:&error])
        NSLog(@"Couldn't save data to %@", NSStringFromClass([self class]));
}

- (void)deleteAllMessagesForBoard:(NSNumber *)boardId {
    // create a query
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kMessageEntity];
    
    // make a query
    request.predicate = [NSPredicate predicateWithFormat:@"userId.userId = %@ AND boardId = %@", [AppDelegate sharedDelegate].userId, boardId];
    
    NSArray *foundMessages = [managedObjectContext executeFetchRequest:request error:nil];
    
    for (Message *message in foundMessages) {
        [managedObjectContext deleteObject:message];
    }
    
    NSError *error = nil;
    
    // save
    if (![managedObjectContext save:&error])
        NSLog(@"Couldn't save data to %@", NSStringFromClass([self class]));
}

+ (NSString *)getCachedFileNameFromRemotePath:(NSString *)url {
    NSString *localFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[url lastPathComponent]];
    
    return localFilePath;
}

+ (NSString *)checkCachedFileExist:(NSString *)url {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *localFilePath = [LocalDBManager getCachedFileNameFromRemotePath:url];
    
    if ([fileManager fileExistsAtPath:localFilePath])
        return localFilePath;
    
    return nil;
}

+ (void)saveImage:(UIImage *)image forRemotePath:(NSString *)url {
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    [LocalDBManager saveData:data forRemotePath:url];
}

+ (void)saveData:(NSData *)data forRemotePath:(NSString *)url {
    [data writeToFile:[LocalDBManager getCachedFileNameFromRemotePath:url] atomically:YES];
}

@end