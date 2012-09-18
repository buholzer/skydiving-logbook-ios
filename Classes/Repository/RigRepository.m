//
//  RigRepository.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/25/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "RigRepository.h"
#import "Units.h"
#import "DataUtil.h"

@implementation RigRepository

- (id)initWithContext:(NSManagedObjectContext *)ctx
{
	return [super initWithContext:ctx entityName:@"Rig" sortAttribute:@"Name"];
}

- (NSArray *)loadRigs
{
	// filters
	NSPredicate *activeFilter = [NSPredicate predicateWithFormat:@"Active == %@", [NSNumber numberWithBool:YES]];
	NSPredicate *archivedFilter = [NSPredicate predicateWithFormat:@"Archived == %@", [NSNumber numberWithBool:NO]];
	NSPredicate *filter = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:activeFilter, archivedFilter, nil]];
	
	return [super loadEntitiesWithFilter:filter];
}

- (NSArray *)loadArchivedRigs
{
	// filters
	NSPredicate *activeFilter = [NSPredicate predicateWithFormat:@"Active == %@", [NSNumber numberWithBool:YES]];
	NSPredicate *archivedFilter = [NSPredicate predicateWithFormat:@"Archived == %@", [NSNumber numberWithBool:YES]];
	NSPredicate *filter = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:activeFilter, archivedFilter, nil]];

	return [super loadEntitiesWithFilter:filter];
}

- (NSArray *)primaryRigs
{
	// primary filter
	NSPredicate *filter = [NSPredicate predicateWithFormat:@"Primary == %@", [NSNumber numberWithBool:YES]];

	// get results
	NSArray *results = [super loadEntitiesWithFilter:filter];
	return results;
}

- (Rig *)createNewRig
{
	Rig* rig = (Rig *)[super createNewEntity];
    rig.UniqueID = [DataUtil newUUID];
    rig.LastModifiedUTC = [DataUtil currentDate];
    return rig;
}

- (RigComponent *)createNewComponentForRig:(Rig *)rig
{
	RigComponent *component = (RigComponent *)[super createNewEntityForName:@"RigComponent"];
	// add to rig
	[rig addComponentsObject:component];
	return component;
}

- (RigReminder *)createNewReminderForRig:(Rig *)rig
{
	RigReminder *reminder = (RigReminder *)[super createNewEntityForName:@"RigReminder"];
	// init fields
	reminder.Interval = [NSNumber numberWithInt:0];
	reminder.IntervalUnit = [Units timeIntervalToString:Days];
	reminder.LastCompletedDate = [NSDate date];
	// add to rig
	[rig addRemindersObject:reminder];
	return reminder;
}

- (void)deleteRig:(Rig *)rig
{
	// update active flag
	rig.Active = [NSNumber numberWithBool:NO];
	// disable primary flag
	rig.Primary = [NSNumber numberWithBool:NO];
    // update last modified
    rig.LastModifiedUTC = [DataUtil currentDate];
	// save
	[super save];
}

- (void)deleteComponent:(RigComponent *)component
{
	// remove from rig/context
	[component.Rig removeComponentsObject:component];
	[context deleteObject:component];
}

- (void)deleteReminder:(RigReminder *)reminder
{
	// remove from rig/context
	[reminder.Rig removeRemindersObject:reminder];
	[context deleteObject:reminder];
}

@end
