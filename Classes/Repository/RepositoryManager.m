//
//  RepositoryManager.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RepositoryManager.h"
#import "DefaultData.h"

@interface RepositoryManager(Private)
- (NSString *)applicationDocumentsDirectory;
- (NSManagedObjectModel *)managedObjectModel;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
@end

@implementation RepositoryManager

static RepositoryManager *instance = nil;

+ (RepositoryManager *)instance
{
	@synchronized(self)
    {
		if (instance == nil)
			instance = [[self alloc] init];
	}
	
	return instance;
}


- (NSManagedObjectContext *)managedObjectContext
{
	if (managedObjectContext == nil)
	{
		managedObjectContext = [[NSManagedObjectContext alloc] init];
		[managedObjectContext setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
	}
	return managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel == nil)
	{
		managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];    
    }
	return managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator != nil)
	{
        return persistentStoreCoordinator;
    }
	
	// create coordinator
	persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	
	// create store url
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"SkydiveApp.sqlite"]];
	
	// get file manager
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// check to see if store already exists
	BOOL storeExists = [fileManager fileExistsAtPath:storeUrl.path];
	
	// create migration options
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
							 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
	
	// create it
	NSError *error = nil;
	if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error])
	{
		// log error/abort
		NSLog(@"Could not create persistent store %@, %@", error, [error userInfo]);
		// TODO: something other than abort
		abort();
	}
	
	// if it didn't exist
	if (storeExists == NO)
	{
		// add default data
		[DefaultData addDefaultData:persistentStoreCoordinator];
	}
	
    return persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


- (LogbookHistoryRepository *)logbookHistoryRepository
{
	if (logbookHistoryRepository == nil)
	{
		logbookHistoryRepository = [[LogbookHistoryRepository alloc] initWithContext:[self managedObjectContext]];
	}
	return logbookHistoryRepository;
}

- (LogEntryRepository *)logEntryRepository
{
	if (logEntryRepository == nil)
	{
		logEntryRepository = [[LogEntryRepository alloc] initWithContext:[self managedObjectContext]];
	}
	return logEntryRepository;
}

- (AircraftRepository *)aircraftRepository
{
	if (aircraftRepository == nil)
	{
		aircraftRepository = [[AircraftRepository alloc] initWithContext:[self managedObjectContext]];
	}
	return aircraftRepository;
}

- (LocationRepository *)locationRepository
{
	if (locationRepository == nil)
	{
		locationRepository = [[LocationRepository alloc] initWithContext:[self managedObjectContext]];
	}
	return locationRepository;
}

- (RigRepository *)rigRepository
{
	if (rigRepository == nil)
	{
		rigRepository = [[RigRepository alloc] initWithContext:[self managedObjectContext]];
	}
	return rigRepository;
}

- (SkydiveTypeRepository *)skydiveTypeRepository
{
	if (skydiveTypeRepository == nil)
	{
		skydiveTypeRepository = [[SkydiveTypeRepository alloc] initWithContext:[self managedObjectContext]];
	}
	return skydiveTypeRepository;
}

- (SummaryRepository *)summaryRepository
{
	if (summaryRepository == nil)
	{
		summaryRepository = [[SummaryRepository alloc] initWithContext:[self managedObjectContext]];
	}
	return summaryRepository;
}

@end
