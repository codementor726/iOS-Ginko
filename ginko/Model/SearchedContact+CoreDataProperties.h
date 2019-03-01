//
//  SearchedContact+CoreDataProperties.h
//  ginko
//
//  Created by stepanekdavid on 6/6/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SearchedContact.h"

NS_ASSUME_NONNULL_BEGIN

@interface SearchedContact (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *contact_id;
@property (nullable, nonatomic, retain) NSNumber *contact_type;
@property (nullable, nonatomic, retain) NSString *data;
@property (nullable, nonatomic, retain) NSNumber *distance;
@property (nullable, nonatomic, retain) NSNumber *exchanged;
@property (nullable, nonatomic, retain) NSString *first_name;
@property (nullable, nonatomic, retain) NSDate *found_time;
@property (nullable, nonatomic, retain) NSNumber *is_pending;
@property (nullable, nonatomic, retain) NSString *last_name;
@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSNumber *longitude;
@property (nullable, nonatomic, retain) NSString *middle_name;
@property (nullable, nonatomic, retain) NSString *profile_image;
@property (nullable, nonatomic, retain) NSNumber *sharing_status;
@property (nullable, nonatomic, retain) NSNumber *timestamp;
@property (nullable, nonatomic, retain) NSNumber *type;
@property (nullable, nonatomic, retain) NSNumber *multi_Entity;
@property (nullable, nonatomic, retain) Contact *contact;

@end

NS_ASSUME_NONNULL_END
