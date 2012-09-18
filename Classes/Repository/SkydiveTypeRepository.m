//
//  SkydiveTypeRepository.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 8/26/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "SkydiveTypeRepository.h"
#import "DataUtil.h"

@implementation SkydiveTypeRepository

- (id)initWithContext:(NSManagedObjectContext *)ctx
{
	return [super initWithContext:ctx entityName:@"SkydiveType" sortAttribute:@"Name"];
}

- (SkydiveType *)defaultSkydiveType
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

- (SkydiveType *)createNewSkydiveType
{
	SkydiveType* skydiveType = (SkydiveType *)[super createNewEntity];
    skydiveType.UniqueID = [DataUtil newUUID];
    skydiveType.LastModifiedUTC = [DataUtil currentDate];
    return skydiveType;
}

- (void)deleteSkydiveType:(SkydiveType *)skydiveType
{
	// update active flag
	skydiveType.Active = [NSNumber numberWithBool:NO];
    // disable default setting
	skydiveType.Default = [NSNumber numberWithBool:NO];
    // update last modified
    skydiveType.LastModifiedUTC = [DataUtil currentDate];
	// save
	[super save];
}

- (void)clearDefaultSkydiveTypes
{
	// clear all defaults
	for (SkydiveType *skydiveType in [self loadAllEntities])
	{
        skydiveType.Default = [NSNumber numberWithBool:NO];
        skydiveType.LastModifiedUTC = [DataUtil currentDate];
	}
}


@end
