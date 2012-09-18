//
//  AircraftRepository.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/25/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "AircraftRepository.h"
#import "DataUtil.h"

@implementation AircraftRepository

- (id)initWithContext:(NSManagedObjectContext *)ctx
{
	return [super initWithContext:ctx entityName:@"Aircraft" sortAttribute:@"Name"];
}

- (Aircraft *)defaultAircraft
{
	// default filter
	NSPredicate *filter = [NSPredicate predicateWithFormat:@"Default == %@", [NSNumber numberWithBool:YES]];
	
	// get results
	NSArray *results = [self loadEntitiesWithFilter:filter];
	
	if ([results count] == 0)
	{
		return nil;
	}
	
	return [results objectAtIndex:0];
}

- (Aircraft *)createNewAircraft
{
	Aircraft* aircraft = (Aircraft *)[super createNewEntity];
    // set uuid and default last modified
    aircraft.UniqueID = [DataUtil newUUID];
    aircraft.LastModifiedUTC = [DataUtil currentDate];
    return aircraft;
}

- (void)deleteAircraft:(Aircraft *)aircraft
{
	// update active flag
	aircraft.Active = [NSNumber numberWithBool:NO];
    // disable default setting
	aircraft.Default = [NSNumber numberWithBool:NO];
    // update last modified
    aircraft.LastModifiedUTC = [DataUtil currentDate];
	// save
	[super save];
}

- (void)clearDefaultAircrafts
{
	// clear all default aircrafts
	for (Aircraft *aircraft in [self loadAllEntities])
	{
        aircraft.Default = [NSNumber numberWithBool:NO];
        aircraft.LastModifiedUTC = [DataUtil currentDate];
	}
}

@end
