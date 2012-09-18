//
//  LocationRepository.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/25/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "LocationRepository.h"
#import "DataUtil.h"

@implementation LocationRepository

- (id)initWithContext:(NSManagedObjectContext *)ctx
{
	return [super initWithContext:ctx entityName:@"Location" sortAttribute:@"Name"];
}

- (Location *)homeLocation
{
	// home filter
	NSPredicate *filter = [NSPredicate predicateWithFormat:@"Home == %@", [NSNumber numberWithBool:YES]];
	
	// get results
	NSArray *results = [self loadEntitiesWithFilter:filter];
	
	if ([results count] == 0)
	{
		return nil;
	}
	
	return [results objectAtIndex:0];
}

- (Location *)createNewLocation
{
	Location* location = (Location*)[super createNewEntity];
    // set uuid and default last modified date
    location.UniqueID = [DataUtil newUUID];
    location.LastModifiedUTC = [DataUtil currentDate];
    return location;
}

- (void)deleteLocation:(Location *)location
{
	// update active flag
	location.Active = [NSNumber numberWithBool:NO];
	// disable home setting
	location.Home = [NSNumber numberWithBool:NO];
    // update last modified date/time
    location.LastModifiedUTC = [DataUtil currentDate];
	// save
	[super save];
}

- (void)clearHomeLocations
{
	// clear all home locations
	for (Location *location in [self loadAllEntities])
	{
        location.Home = [NSNumber numberWithBool:NO];
        location.LastModifiedUTC = [DataUtil currentDate];
	}
}

@end
