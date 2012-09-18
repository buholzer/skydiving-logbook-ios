//
//  DefaultData.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/23/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "DefaultData.h"
#import "Aircraft.h"
#import "SkydiveType.h"
#import "FreefallProfile.h"
#import "DataUtil.h"

@interface DefaultData(Private)
+(void)addDefaultAircraft:(NSManagedObjectContext *)context;
+(void)addDefaultSkydiveTypes:(NSManagedObjectContext *)context;
+(void)addAircraft:(NSString *)name context:(NSManagedObjectContext *)context;
+(void)addSkydiveType:(NSString *)name profileType:(enum FreefallProfileType)profileType context:(NSManagedObjectContext *)context;
@end

@implementation DefaultData

+(void)addDefaultData:(NSPersistentStoreCoordinator *)coordinator
{
	// create managed context
	NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
	[context setPersistentStoreCoordinator:coordinator];
	
	// add data
	[DefaultData addDefaultAircraft:context];
	[DefaultData addDefaultSkydiveTypes:context];
	
	// save
	NSError *error;
	if (![context save:&error])
	{
		NSLog(0, @"Could not save context with message '%s'.", [error localizedDescription]);
	}
}

+(void)addDefaultAircraft:(NSManagedObjectContext *)context
{
	// add aircraft
	[DefaultData addAircraft:@"Twin Otter" context:context];
	[DefaultData addAircraft:@"Caravan" context:context];
	[DefaultData addAircraft:@"Grand Caravan" context:context];
	[DefaultData addAircraft:@"Skylane" context:context];
	[DefaultData addAircraft:@"Stationair" context:context];
	[DefaultData addAircraft:@"Skyhawk" context:context];
	[DefaultData addAircraft:@"Pac750" context:context];	
	[DefaultData addAircraft:@"Shorts 330" context:context];
	[DefaultData addAircraft:@"Pilatus PC-6 Porter" context:context];
	[DefaultData addAircraft:@"Skyvan" context:context];
	[DefaultData addAircraft:@"King Air" context:context];
	[DefaultData addAircraft:@"Casa C-212 Aviocar" context:context];
	[DefaultData addAircraft:@"DC3" context:context];	
	[DefaultData addAircraft:@"Hercules (C-130)" context:context];
	[DefaultData addAircraft:@"Robinson R22 Beta" context:context];
	[DefaultData addAircraft:@"Robinson R44 Raven" context:context];
	[DefaultData addAircraft:@"Hot Air Balloon" context:context];
	
}

+(void)addDefaultSkydiveTypes:(NSManagedObjectContext *)context
{
	[DefaultData addSkydiveType:@"Belly/RW" profileType:Horizontal context:context];
	[DefaultData addSkydiveType:@"Freefly" profileType:Vertical context:context];
	[DefaultData addSkydiveType:@"Tracking" profileType:Tracking context:context];
	[DefaultData addSkydiveType:@"Wingsuit" profileType:Wingsuit context:context];
	[DefaultData addSkydiveType:@"Hybrid" profileType:Horizontal context:context];
	[DefaultData addSkydiveType:@"Tandem" profileType:Horizontal context:context];
	[DefaultData addSkydiveType:@"Hop and Pop" profileType:Horizontal context:context];
	[DefaultData addSkydiveType:@"BASE" profileType:Horizontal context:context];
	[DefaultData addSkydiveType:@"Skysurfing" profileType:Skysurfing context:context];
	[DefaultData addSkydiveType:@"Other" profileType:Horizontal context:context];
}
	 
+(void)addAircraft:(NSString *)name context:(NSManagedObjectContext *)context
{
	// create aircraft, set name
	Aircraft *aircraft = (Aircraft*)[NSEntityDescription insertNewObjectForEntityForName:@"Aircraft" inManagedObjectContext:context];
	aircraft.Name = name;
    aircraft.Default = [NSNumber numberWithBool:NO];
    // set unique id and last modified date/time
    aircraft.UniqueID = [DataUtil newUUID];
    aircraft.LastModifiedUTC = [DataUtil currentDate];
}

+(void)addSkydiveType:(NSString *)name profileType:(enum FreefallProfileType)profileType context:(NSManagedObjectContext *)context
{
	// create aircraft, set name
	SkydiveType *skydiveType = (SkydiveType*)[NSEntityDescription insertNewObjectForEntityForName:@"SkydiveType" inManagedObjectContext:context];
	skydiveType.Name = name;
    skydiveType.Default = [NSNumber numberWithBool:NO];
	skydiveType.FreefallProfileType = [FreefallProfileUtil typeToString:profileType];
    // set unique id and last modified date/time
    skydiveType.UniqueID = [DataUtil newUUID];
    skydiveType.LastModifiedUTC = [DataUtil currentDate];
}

@end
