//
//  UUID_UtcMappingPolicy.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UUID_UtcMappingPolicy.h"
#import "DataUtil.h"

@implementation UUID_UtcMappingPolicy

- (NSDate*)defaultLastModifiedDate
{
    return [DataUtil currentDate];
}

- (NSDate*)defaultLastSignatureDate:(Signature*)signature
{
    if (!signature)
        return nil;
    
    return [DataUtil currentDate];
}

- (NSString*)newUUID
{
    return [DataUtil newUUID];
}

@end
