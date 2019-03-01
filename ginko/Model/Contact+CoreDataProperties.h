//
//  Contact+CoreDataProperties.h
//  ginko
//
//  Created by stepanekdavid on 6/6/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Contact.h"

NS_ASSUME_NONNULL_BEGIN

@interface Contact (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *contact_id;
@property (nullable, nonatomic, retain) NSNumber *contact_type;
@property (nullable, nonatomic, retain) NSString *data;

@end

NS_ASSUME_NONNULL_END
