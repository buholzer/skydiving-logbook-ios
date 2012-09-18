//
//  LogEntrySkydiveTypeMappingPolicy.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 8/28/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "LogEntrySkydiveTypeMappingPolicy.h"
#import "SkydiveType.h"
#import "FreefallProfile.h"
#import "StartupTask.h"

@interface LogEntrySkydiveTypeMappingPolicy(Private)
- (NSDictionary *)userInfo:(NSMigrationManager *)manager;
- (NSDictionary *)skydiveTypesDictionary:(NSMigrationManager *)manager;
- (NSManagedObject *)createSkydiveType:(NSString *)name profileType:(enum FreefallProfileType)profileType context:(NSManagedObjectContext *)context;
@end

@implementation LogEntrySkydiveTypeMappingPolicy

int jumpCount = 0;

- (BOOL)beginEntityMapping:(NSEntityMapping *)mapping manager:(NSMigrationManager *)manager error:(NSError **)error
{
	// init migrated jump count
	jumpCount = 0;
	
	// update startup progress
	[[StartupTask instance] updateProgressText:NSLocalizedString(@"StartingMigration", @"")
										detail:NSLocalizedString(@"DoNotExit", @"")];

	// get/create skydive types by enum
	[self skydiveTypesDictionary:manager];
	
	return [super beginEntityMapping:mapping manager:manager error:error];
}

- (NSManagedObject *)skydiveType:(NSMigrationManager *)manager name:(NSString *)name
{
	// get migration progress title
	NSString *title = [NSString stringWithFormat:NSLocalizedString(@"MigratingJumps", @""), 
					   [NSNumber numberWithInt:jumpCount++]];
	
	// update startup progress
	[[StartupTask instance] updateProgressText:title detail:NSLocalizedString(@"DoNotExit", @"")];
	
	// lookup skydive type for name
	NSDictionary *skydiveTypesDict = [self skydiveTypesDictionary:manager];
	return [skydiveTypesDict valueForKey:name];
}

- (NSDictionary *)userInfo:(NSMigrationManager *)manager
{
	// get/create user info
	NSDictionary *userInfo = [manager userInfo];
	if (!userInfo)
	{
		userInfo = [NSMutableDictionary dictionary];
		[manager setUserInfo:userInfo];
	}
	return userInfo;
}

- (NSDictionary *)skydiveTypesDictionary:(NSMigrationManager *)manager 
{
	// get user info
	NSDictionary *userInfo = [self userInfo:manager];
	
	// get/create skydive types by src enum
	NSMutableDictionary *skydiveTypesDict = [userInfo valueForKey:@"skydiveTypesDict"];
	if (!skydiveTypesDict)
	{
		// get context
		NSManagedObjectContext *context = [manager destinationContext];
		
		// create skydive types
		skydiveTypesDict = [NSMutableDictionary dictionary];
		// popuplate skydive types
		[skydiveTypesDict setValue:[self createSkydiveType:@"Belly/RW" profileType:Horizontal context:context]
					  forKey:@"RelativeWork"];
		[skydiveTypesDict setValue:[self createSkydiveType:@"Freefly" profileType:Vertical context:context]
					  forKey:@"Freefly"];
		[skydiveTypesDict setValue:[self createSkydiveType:@"Tracking" profileType:Tracking context:context]
					  forKey:@"Tracking"];
		[skydiveTypesDict setValue:[self createSkydiveType:@"Wingsuit" profileType:Wingsuit context:context]
					  forKey:@"Wingsuit"];
		[skydiveTypesDict setValue:[self createSkydiveType:@"Hybrid" profileType:Horizontal context:context]
					  forKey:@"Hybrid"];
		[skydiveTypesDict setValue:[self createSkydiveType:@"Tandem" profileType:Horizontal context:context]
					  forKey:@"Tandem"];
		[skydiveTypesDict setValue:[self createSkydiveType:@"Hop and Pop" profileType:Horizontal context:context]
					  forKey:@"HopAndPop"];
		[skydiveTypesDict setValue:[self createSkydiveType:@"BASE" profileType:Horizontal context:context]
					  forKey:@"BASE"];
		[skydiveTypesDict setValue:[self createSkydiveType:@"Skysurfing" profileType:Skysurfing context:context]
					  forKey:@"Skysurfing"];
		[skydiveTypesDict setValue:[self createSkydiveType:@"Other" profileType:Horizontal context:context]
					  forKey:@"Other"];
		
		// store in userInfo
		[userInfo setValue:skydiveTypesDict forKey:@"skydiveTypesDict"];
	}
	
	return skydiveTypesDict;
}

- (NSManagedObject *)createSkydiveType:(NSString *)name profileType:(enum FreefallProfileType)profileType context:(NSManagedObjectContext *)context
{
	// create type, set name, profile
	SkydiveType *skydiveType = (SkydiveType*)[NSEntityDescription insertNewObjectForEntityForName:@"SkydiveType" inManagedObjectContext:context];
	skydiveType.Name = name;
	skydiveType.FreefallProfileType = [FreefallProfileUtil typeToString:profileType];
	return skydiveType;
}

@end
