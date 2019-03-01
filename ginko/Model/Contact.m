//
//  Contact.m
//  ginko
//
//  Created by stepanekdavid on 6/6/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "Contact.h"

@implementation Contact

- (NSDictionary*)getDataDictionary {
    NSString *contactDic = self.data;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[contactDic dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    return dic;
}

- (NSString*)getContactName {
    NSDictionary *dict = [self getDataDictionary];
    NSString *name = [NSString stringWithFormat:@"%@ %@", dict[@"first_name"], dict[@"last_name"]];
    return name;
}

+ (NSArray*)getPurpleContacts {
    NSFetchRequest *allContacts = [[NSFetchRequest alloc] init];
    [allContacts setEntity:[NSEntityDescription entityForName:@"Contact" inManagedObjectContext:MOC]];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(contact_type == 1)"];
    [allContacts setPredicate:pred];
    NSError *error = nil;
    NSArray *contacts = [MOC executeFetchRequest:allContacts error:&error];
    return contacts;
}

@end
