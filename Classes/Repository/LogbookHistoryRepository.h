//
//  LogbookHistoryRepository.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 4/22/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "LogbookHistory.h"

@interface LogbookHistoryRepository : NSObject
{
	NSManagedObjectContext *context;
}

- (id)initWithContext:(NSManagedObjectContext *)ctx;
- (LogbookHistory *)history;
- (void)save;

@end
