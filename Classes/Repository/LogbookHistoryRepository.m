//
//  LogbookHistoryRepository.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 4/22/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "LogbookHistoryRepository.h"

@implementation LogbookHistoryRepository

- (id)initWithContext:(NSManagedObjectContext *)ctx
{
	if (self = [self init])
	{
		context = ctx;
	}
	return self;
}

- (LogbookHistory *)history
{
	// create fetch request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"LogbookHistory" inManagedObjectContext:context];
	[request setEntity:entity];
	
	// get results
	NSError *error;
	NSArray *results = [context executeFetchRequest:request error:&error];
	if (results == nil)
	{
		NSAssert1(0, @"Failed to load logbook history data with message '%@'.", [error localizedDescription]);
	}
	
	LogbookHistory *history;
	// if no history,
	if ([results count] == 0)
	{
		// create
		history = (LogbookHistory*)[NSEntityDescription insertNewObjectForEntityForName:@"LogbookHistory" inManagedObjectContext:context];
		history.FreefallTime = [NSNumber numberWithInt:0];
		history.Cutaways = [NSNumber numberWithInt:0];
		// save
		[self save];
	}
	else
	{
		// get history
		history = [results objectAtIndex:0];
	}
	
	return history;
}

- (void)save
{
	// save
	NSError *error;
	if (![context save:&error])
	{
		NSLog(0, @"Could not save context with message '%s'.", [error localizedDescription]);
	}
}

@end
