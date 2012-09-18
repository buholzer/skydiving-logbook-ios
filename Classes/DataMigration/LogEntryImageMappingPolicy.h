//
//  LogEntryImageMappingPolicy.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogEntryRepository.h"

@interface LogEntryImageMappingPolicy : NSEntityMigrationPolicy
{
    LogEntryRepository *repository;
}

@end
