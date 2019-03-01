//
//  Users+CoreDataProperties.h
//  ginko
//
//  Created by STAR on 11/13/15.
//  Copyright © 2015 com.xchangewithme. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Users.h"

NS_ASSUME_NONNULL_BEGIN

@interface Users (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *userId;
@property (nullable, nonatomic, retain) NSSet<NSManagedObject *> *messages;

@end

@interface Users (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(NSManagedObject *)value;
- (void)removeMessagesObject:(NSManagedObject *)value;
- (void)addMessages:(NSSet<NSManagedObject *> *)values;
- (void)removeMessages:(NSSet<NSManagedObject *> *)values;

@end

NS_ASSUME_NONNULL_END
