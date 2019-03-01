//
//  Message+CoreDataProperties.h
//  ginko
//
//  Created by STAR on 11/13/15.
//  Copyright © 2015 com.xchangewithme. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Message.h"

NS_ASSUME_NONNULL_BEGIN

@interface Message (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *boardId;
@property (nullable, nonatomic, retain) NSString *content;
@property (nullable, nonatomic, retain) NSDate *datetime;
@property (nullable, nonatomic, retain) NSString *mediaFilePath;
@property (nullable, nonatomic, retain) NSNumber *messageId;
@property (nullable, nonatomic, retain) Users *userId;

@end

NS_ASSUME_NONNULL_END
