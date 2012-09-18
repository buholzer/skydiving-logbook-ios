//
//  BaseEntityRepository.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 8/26/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "BaseEntityRepository.h"

@implementation BaseEntityRepository

- (id)initWithContext:(NSManagedObjectContext *)ctx
		   entityName:(NSString*)name
		sortAttribute:(NSString *)sort
{
	if (self = [self init])
	{
		context = ctx;
		entityName = name;
		sortAttribute = sort;
	}
	return self;
}

- (NSArray *)loadEntities
{
	// active filter
	NSPredicate *filter = [NSPredicate predicateWithFormat:@"Active == %@", [NSNumber numberWithBool:YES]];
	return [self loadEntitiesWithFilter:filter];
}

- (NSArray *)loadAllEntities
{
	return [self loadEntitiesWithFilter:nil];
}

- (NSArray *)loadEntitiesWithFilter:(NSPredicate *)filter
{
	// create fetch request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
	[request setEntity:entity];
	
	// set filter
	if (filter)
	{
		[request setPredicate:filter];
	}
	
	// set sort
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortAttribute ascending:YES];
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

- (NSArray *)loadAllEntitiesForName:(NSString *)name
{
	// create fetch request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:name inManagedObjectContext:context];
	[request setEntity:entity];
	
	// get results
	NSError *error;
	NSArray *results = [context executeFetchRequest:request error:&error];
	if (results == nil)
	{
		NSAssert1(0, @"Failed to load entities data with message '%@'.", [error localizedDescription]);
	}
	
	return results;
}

- (NSManagedObject *)createNewEntity
{
	return [self createNewEntityForName:entityName];
}

- (NSManagedObject *)createNewEntityForName:(NSString *)name
{
	NSManagedObject *entity = [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:context];
	return entity;	
}

- (void)save
{
	// save
	NSError *error;
	if (![context save:&error])
	{
		NSAssert1(0, @"Could not save context with message '%@'.", [error localizedDescription]);
	}
}

- (void)rollback
{
	[context rollback];
}

@end
