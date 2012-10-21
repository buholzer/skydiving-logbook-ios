//
//  LogEntryRepository.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/26/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "LogEntryRepository.h"
#import "SettingsRepository.h"
#import "Units.h"
#import "DataUtil.h"

// log entry image types
NSString * const LogEntryPhotoImageType = @"LogEntryPhotoImageType";
NSString * const LogEntryDiagramImageType = @"LogEntryDiagramImageType";

@interface LogEntryRepository(Private)
- (NSExpressionDescription *)expression:(NSString *)function
								  field:(NSString *)field
							 resultName:(NSString *)resultName
							 resultType:(NSAttributeType)resultType;
@end


@implementation LogEntryRepository

- (id)initWithContext:(NSManagedObjectContext *)ctx
{
	return [super initWithContext:ctx entityName:@"LogEntry" sortAttribute:@"JumpNumber"];
}

- (NSArray *)loadLogEntries
{
	// create fetch request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
	[request setEntity:entity];
	
    // set batch size
    [request setFetchBatchSize:100];
	
	// set sort
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortAttribute ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	
	// get results
	NSError *error;
	NSArray *results = [context executeFetchRequest:request error:&error];
	if (results == nil)
	{
		NSAssert1(0, @"Failed to load entities data with message '%@'.", [error localizedDescription]);
	}
	
	return results;
}

- (LogEntry *)getPreviousLogEntry:(NSInteger)jumpNumber
{
    // create fetch request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
	[request setEntity:entity];
	
	// get 1 result
	[request setFetchLimit:1];
    
    // set sort
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortAttribute ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
    
    // get first log entry less than jumpNumber
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"JumpNumber < %@", [NSNumber numberWithInt:jumpNumber]];
    [request setPredicate:filter];
	
	// get results
	NSError *error;
	NSArray *results = [context executeFetchRequest:request error:&error];
	if (results == nil)
	{
		NSAssert1(0, @"Failed to get log entry '%@'.", [error localizedDescription]);
	}
    
    if (results.count >= 1)
        return [results objectAtIndex:0];
	
	return nil;
}

- (LogEntry *)getNextLogEntry:(NSInteger)jumpNumber
{
    // create fetch request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
	[request setEntity:entity];
	
	// get 1 result
	[request setFetchLimit:1];
    
    // set sort
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortAttribute ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
    
    // get first log entry less than jumpNumber
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"JumpNumber > %@", [NSNumber numberWithInt:jumpNumber]];
    [request setPredicate:filter];
	
	// get results
	NSError *error;
	NSArray *results = [context executeFetchRequest:request error:&error];
	if (results == nil)
	{
		NSAssert1(0, @"Failed to get log entry '%@'.", [error localizedDescription]);
	}
    
    if (results.count >= 1)
        return [results objectAtIndex:0];
	
	return nil;
}

- (NSArray *)findLogEntries:(LogEntrySearchCriteria *)searchCriteria
{
    // create fetch request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
	[request setEntity:entity];
    
    // set sort
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortAttribute ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
    
    // predicates
    
    
    if (searchCriteria.aircrafts)
    {
    }
}

- (NSArray *)loadAllSignatures
{
	return [super loadAllEntitiesForName:@"Signature"];
}

- (LogEntry *)createWithDefaults;
{
	LogEntry *logEntry = (LogEntry *)[super createNewEntity];
    logEntry.UniqueID = [DataUtil newUUID];
    logEntry.LastModifiedUTC = [DataUtil currentDate];
	logEntry.Date = [NSDate date];
	
	// get expressions for max number/date
	NSExpressionDescription *maxNumber = [self expression:@"max:"
													field:@"JumpNumber"
											   resultName:@"MaxJumpNumber"
											   resultType:NSDecimalAttributeType];
	
	// create fetch request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"LogEntry" inManagedObjectContext:context];
	[request setEntity:entity];
	[request setResultType:NSDictionaryResultType];
	[request setPropertiesToFetch:[NSArray arrayWithObjects:maxNumber, nil]];
	 
	// execute query
	NSError *error;
	NSArray *results = [context executeFetchRequest:request error:&error];
	if (results == nil)
	{
		NSAssert1(0, @"Failed to load log entry data with message '%@'.", [error localizedDescription]);
	}
	else
	{
		NSNumber *maxNumber = [[results objectAtIndex:0] valueForKey:@"MaxJumpNumber"];
		NSInteger maxNumberInt = maxNumber == nil ? 1 : [maxNumber intValue] + 1;
		logEntry.JumpNumber = [NSNumber numberWithInt:maxNumberInt];
	}
	logEntry.AltitudeUnit = [Units altitudeToString:[SettingsRepository altitudeUnit]];
	
	// set defaults
	logEntry.ExitAltitude = [SettingsRepository defaultExitAltitude];
	logEntry.DeploymentAltitude = [SettingsRepository defaultDeploymentAltitude];
	
	return logEntry;
}

- (LogEntry *)createFromLast
{
	// get last log entry list
	NSArray *lastList = [self loadLogEntries];
	
	// if none, use defaults
	if ([lastList count] <= 0)
	{
		return [self createWithDefaults];
	}
	
	// get last log entry
	LogEntry *lastLogEntry = (LogEntry *)[lastList objectAtIndex:0];
	
	// get new jump #
	NSInteger jumpNumber = [lastLogEntry.JumpNumber intValue] + 1;
	
	// create new
	LogEntry *logEntry = (LogEntry *)[super createNewEntity];
    // set unique id
    logEntry.UniqueID = [DataUtil newUUID];
    // set default last modified
    logEntry.LastModifiedUTC = [DataUtil currentDate];
	// copy values
	logEntry.JumpNumber = [NSNumber numberWithInt:jumpNumber];
	logEntry.Date = lastLogEntry.Date;
	logEntry.Aircraft = lastLogEntry.Aircraft;
	logEntry.SkydiveType = lastLogEntry.SkydiveType;
	logEntry.Location = lastLogEntry.Location;
	logEntry.Rigs = lastLogEntry.Rigs;
	logEntry.AltitudeUnit = lastLogEntry.AltitudeUnit;
	logEntry.ExitAltitude = lastLogEntry.ExitAltitude;
	logEntry.DeploymentAltitude = lastLogEntry.DeploymentAltitude;
	logEntry.Cutaway = lastLogEntry.Cutaway;
	logEntry.Notes = lastLogEntry.Notes;
	
	return logEntry;	
}

- (void)decrementJumpNumbersAbove:(NSInteger)jumpNumber
{
    // get log entries with numbers greater than this
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"JumpNumber > %@", [NSNumber numberWithInt:jumpNumber]];
    NSArray *logEntries = [super loadEntitiesWithFilter:filter];
    
    // update all jump numbers
    for (LogEntry *logEntry in logEntries)
    {
        NSInteger newJumpNumber = [logEntry.JumpNumber intValue] - 1;
        logEntry.JumpNumber = [NSNumber numberWithInt:newJumpNumber];
    }
    
    // save
	[super save];
}

- (Signature *)createNewSignature
{
	return (Signature *)[super createNewEntityForName:@"Signature"];
}

- (LogEntryImage *)createNewPhotoForLogEntry:(LogEntry *)logEntry
{
    LogEntryImage *image = (LogEntryImage *)[super createNewEntityForName:@"LogEntryImage"];
    image.ImageType = LogEntryPhotoImageType;
	// add to log entry
    [logEntry addImagesObject:image];
    return image;
}

- (LogEntryImage *)createNewDiagramForLogEntry:(LogEntry *)logEntry
{
    LogEntryImage *image = (LogEntryImage *)[super createNewEntityForName:@"LogEntryImage"];
    image.ImageType = LogEntryDiagramImageType;
	// add to log entry
    [logEntry addImagesObject:image];
    return image;
}

- (void)deleteLogEntry:(LogEntry *)logEntry
{
	// delete
	[context deleteObject:logEntry];
	// save
	[super save];
}

- (void)deleteLogEntryImage:(LogEntryImage *)image
{
	// remove from logentry/context
    [image.LogEntry removeImagesObject:image];
	[context deleteObject:image];
}

- (NSExpressionDescription *)expression:(NSString *)function
								  field:(NSString *)field
							 resultName:(NSString *)resultName
							 resultType:(NSAttributeType)resultType
{
	NSArray *exprFields = [NSArray arrayWithObject:[NSExpression expressionForKeyPath:field]];
	NSExpression *expressionFunc = [NSExpression expressionForFunction:function arguments:exprFields];
	NSExpressionDescription *description = [[NSExpressionDescription alloc] init];
	[description setName:resultName];
	[description setExpression:expressionFunc];
	[description setExpressionResultType:resultType];
	return description;
}

@end
