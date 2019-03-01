//
//  Contact.h
//  ginko
//
//  Created by stepanekdavid on 6/6/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Contact : NSManagedObject

- (NSDictionary*)getDataDictionary;
- (NSString*)getContactName;
+ (NSArray*)getPurpleContacts;

@end

NS_ASSUME_NONNULL_END

#import "Contact+CoreDataProperties.h"
