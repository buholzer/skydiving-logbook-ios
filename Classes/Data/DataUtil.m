//
//  DataUtil.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DataUtil.h"

@implementation DataUtil

+ (NSDate*)currentDate
{
    return [NSDate date];
}

+ (NSString*)newUUID
{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    
    NSString *uuidStr = CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuid));
    
    CFRelease(uuid);
    
    return uuidStr;
}

@end
