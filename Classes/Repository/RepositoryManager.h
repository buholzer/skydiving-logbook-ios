//
//  RepositoryManager.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogbookHistoryRepository.h"
#import "LogEntryRepository.h"
#import "AircraftRepository.h"
#import "LocationRepository.h"
#import "RigRepository.h"
#import "SkydiveTypeRepository.h"
#import "SummaryRepository.h"

@interface RepositoryManager : NSObject
{
    NSManagedObjectContext *managedObjectContext;
	NSManagedObjectModel *managedObjectModel;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
	
	// repositories
	LogbookHistoryRepository *logbookHistoryRepository;
	LogEntryRepository *logEntryRepository;
	AircraftRepository *aircraftRepository;
	LocationRepository *locationRepository;
	RigRepository *rigRepository;
	SkydiveTypeRepository *skydiveTypeRepository;
	SummaryRepository *summaryRepository;
}

+ (RepositoryManager *)instance;

- (LogbookHistoryRepository *)logbookHistoryRepository;
- (LogEntryRepository *)logEntryRepository;
- (AircraftRepository *)aircraftRepository;
- (LocationRepository *)locationRepository;
- (RigRepository *)rigRepository;
- (SkydiveTypeRepository *)skydiveTypeRepository;
- (SummaryRepository *)summaryRepository;

@end
