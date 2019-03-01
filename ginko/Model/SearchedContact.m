//
//  SearchedContact.m
//  ginko
//
//  Created by stepanekdavid on 6/6/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "SearchedContact.h"
#import "Contact.h"

@implementation SearchedContact

+ (SearchedContact*)insertContactRecord:(NSDictionary *)dic {
    NSManagedObjectContext *moc = [AppDelegate sharedDelegate].managedObjectContext;
    id contactId;
    if([dic[@"contact_type"] isEqualToNumber:@(3)]){
        contactId = dic[@"entity_id"];
    }else {
        contactId = dic[@"contact_id"];
    }
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(contact_id == %@)", contactId];
    NSFetchRequest *request = [self fetchRequest:pred inMoc:moc];
    NSArray *results = [moc executeFetchRequest:request error:nil];
    
    SearchedContact *contact;
    if ([results count] > 0) {
        contact = [results firstObject];
    } else {
        contact = (SearchedContact *)[NSEntityDescription insertNewObjectForEntityForName:@"SearchedContact" inManagedObjectContext:moc];
    }
    contact = [self fillRecord:contact withDic:dic];
    return contact;
}

+ (NSArray*)insertContactRecords:(NSArray*)dics {
    NSMutableArray *users = [NSMutableArray array];
    NSInteger timestamp = [[NSDate date] timeIntervalSince1970];
    //NSLog(@"naga---%@",dics);
    for (NSDictionary *dic in dics) {
        if ([dic objectForKey:@"infos"]) {
            if ([[dic objectForKey:@"infos"] count] > 0) {
                SearchedContact *user = [self insertContactRecord:dic];
                [user setTimestamp:@(timestamp)];
                [users addObject:user];
            }
        }else{
            SearchedContact *user = [self insertContactRecord:dic];
            [user setTimestamp:@(timestamp)];
            [users addObject:user];
        }
        
    }
    [self clearOldSearchedContacts:timestamp];
    return users;
}

+ (void)insertPurpleContacts:(NSArray*)dics {
    NSInteger timestamp = [[NSDate date] timeIntervalSince1970];
    for (NSDictionary *dic in dics) {
        if (![dic[@"contact_type"] isEqualToNumber:@(3)]) {
            Contact *contact = [self fetchContactById:dic[@"contact_id"]];
            if (contact) {
                NSDictionary *dict = [contact getDataDictionary];
                SearchedContact *user = [self insertContactRecord:dict];
                [user setTimestamp:@(timestamp)];
                [user setExchanged:[NSNumber numberWithBool:YES]];
                [user setLongitude:dic[@"longitude"]];
                [user setLatitude:dic[@"latitude"]];
                NSDate *foundTime = [CommonMethods str2UTCDate:dic[@"found_time"]];
                [user setFound_time:foundTime];
                [user setContact:contact];
            }
        }
    }
    [self clearOldPurpleContacts:timestamp];
}

+ (Contact*)fetchContactById:(NSNumber*)contactId {
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:[NSEntityDescription entityForName:@"Contact" inManagedObjectContext:MOC]];
    [req setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(contact_id == %@)", contactId];
    [req setPredicate:pred];
    NSArray *results = [MOC executeFetchRequest:req error:nil];
    if (results.count) {
        return results.firstObject;
    }
    else {
        return nil;
    }
}

+ (NSFetchRequest*)fetchRequest:(NSPredicate*)pred inMoc:(NSManagedObjectContext*)moc {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SearchedContact" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    if (pred) [request setPredicate:pred];
    return request;
}

+ (SearchedContact*)fillRecord:(SearchedContact*)new_entry withDic:(NSDictionary*)dic {
    [new_entry setType:dic[@"contact_type"]];
    [new_entry setDistance:dic[@"distance"]];
    [new_entry setExchanged:dic[@"exchanged"]];
    [new_entry setFirst_name:dic[@"first_name"]];
    [new_entry setLast_name:dic[@"last_name"]];
    [new_entry setLatitude:@([dic[@"latitude"] floatValue])];
    [new_entry setLongitude:@([dic[@"longitude"] floatValue])];
    [new_entry setMiddle_name:dic[@"middle_name"]];
    [new_entry setProfile_image:dic[@"profile_image"]];
    [new_entry setSharing_status:dic[@"sharing_status"]];
    [new_entry setIs_pending:dic[@"is_pending"]];
    [new_entry setContact_type:dic[@"contact_type"]];
    if ([dic[@"contact_type"] isEqualToNumber:@(3)]) {
        [new_entry setContact_id:dic[@"entity_id"]];
        [new_entry setFirst_name:dic[@"name"]];
    }else {
        [new_entry setContact_id:dic[@"contact_id"]];
    }


        
    NSDate *foundTime = [CommonMethods str2UTCDate:dic[@"found_time"]];
    [new_entry setFound_time:foundTime];
    
    new_entry.data = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    
    
    return new_entry;
}

+ (void)clearOldSearchedContacts:(NSTimeInterval)timestamp {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SearchedContact" inManagedObjectContext:MOC];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(timestamp != %@) AND (exchanged == NO OR exchanged == nil)", @(timestamp)];
    NSFetchRequest *request = [self fetchRequest:pred inMoc:MOC];
    [request setEntity:entity];
    NSArray *results = [MOC executeFetchRequest:request error:nil];
    for (SearchedContact *contact in results) {
        [MOC deleteObject:contact];
    }
}

+ (void)clearOldPurpleContacts:(NSTimeInterval)timestamp {
//    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(timestamp != %@) AND (exchanged == YES) AND (contact_type == 1)", @(timestamp)];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(timestamp != %@) AND (exchanged == YES)", @(timestamp)];
    NSFetchRequest *request = [self fetchRequest:pred inMoc:MOC];
    NSArray *results = [MOC executeFetchRequest:request error:nil];
    for (SearchedContact *contact in results) {
        [MOC deleteObject:contact];
    }
}

+ (NSFetchedResultsController*)frcForContacts {
    //    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(unread == YES)"];
    NSFetchRequest *fetchRequest = [self fetchRequest:nil inMoc:MOC];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
    NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"found_time" ascending:YES];
    [fetchRequest setSortDescriptors:@[sort, sort1]];
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:MOC sectionNameKeyPath:nil cacheName:nil];
    return theFetchedResultsController;
}

- (NSDictionary*)getDataDictionary {
    NSString *contactDic = self.data;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[contactDic dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    return dic;
}

@end
