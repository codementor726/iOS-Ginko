//
//  LocationOfEntity.h
//  ginko
//
//  Created by stepanekdavid on 6/6/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocationOfEntity : NSManagedObject
- (NSDictionary*)getDataDictionary;

@end

NS_ASSUME_NONNULL_END

#import "LocationOfEntity+CoreDataProperties.h"
