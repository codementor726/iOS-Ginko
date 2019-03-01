//
//  SearchedContact.h
//  ginko
//
//  Created by stepanekdavid on 6/6/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contact;

NS_ASSUME_NONNULL_BEGIN

@interface SearchedContact : NSManagedObject

+ (NSArray*)insertContactRecords:(NSArray*)dics;
+ (void)insertPurpleContacts:(NSArray*)dics;
+ (NSFetchedResultsController*)frcForContacts;
- (NSDictionary*)getDataDictionary;

@end

NS_ASSUME_NONNULL_END

#import "SearchedContact+CoreDataProperties.h"
