//
//  ContactAnnotation.h
//  ginko
//
//  Created by ccom on 1/13/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "QTreeInsertable.h"

@interface ContactAnnotation : MKPointAnnotation <QTreeInsertable>


@property NSInteger type;//0:contact 1:grey
@property NSArray *contacts;
@property NSNumber *contactId;
@property NSString *profileImg;
@end
