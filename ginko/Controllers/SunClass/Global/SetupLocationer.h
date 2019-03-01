//
//  SetupLocationer.h
//  GINKO
//
//  Created by mobidev on 7/2/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface SetupLocationer : NSObject <CLLocationManagerDelegate>
{

}

+ (SetupLocationer *)sharedLocationer;
- (void)configAfterSignIn:(NSDictionary *)_responseObject;

@end
