//
//  Groups+CoreDataProperties.h
//  ginko
//
//  Created by stepanekdavid on 6/21/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Groups.h"

NS_ASSUME_NONNULL_BEGIN

@interface Groups (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *contact_id;
@property (nullable, nonatomic, retain) NSString *group_id;
@property (nullable, nonatomic, retain) NSString *group_name;
@property (nullable, nonatomic, retain) NSNumber *contact_type;

@end

NS_ASSUME_NONNULL_END
