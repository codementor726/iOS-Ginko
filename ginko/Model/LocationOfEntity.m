//
//  LocationOfEntity.m
//  ginko
//
//  Created by stepanekdavid on 6/6/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "LocationOfEntity.h"

@implementation LocationOfEntity

- (NSDictionary*)getDataDictionary {
    NSString *contactDic = self.data;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[contactDic dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    return dic;
}
@end
