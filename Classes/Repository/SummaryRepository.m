//
//  SummaryRepository.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 8/31/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "SummaryRepository.h"
#import "SettingsRepository.h"
#import "Units.h"

static NSTimeInterval SecondsInAYear = 31556926;
static NSTimeInterval SecondsInAMonth = 2629744;

@interface SummaryRepository(Private)
- (NSExpressionDescription *)expression:(NSString *)function
								  field:(NSString *)field
							 resultName:(NSString *)resultName
							 resultType:(NSAttributeType)resultType;
@end

@implementation SummaryRepository

- (id)initWithContext:(NSManagedObjectContext *)ctx
{
	if (self = [self init])
	{
		context = ctx;
	}
	return self;
}

- (Summary *)summary
{
	// ----- query expressions -------
	// max jump number
	NSExpressionDescription *maxNumber = [self expression:@"max:"
													field:@"JumpNumber"
											   resultName:@"MaxJumpNumber"
											   resultType:NSDecimalAttributeType];
	// max date
	NSExpressionDescription *maxDate = [self expression:@"max:"
												  field:@"Date"
											 resultName:@"MaxDate"
											 resultType:NSDateAttributeType];
	// total freefall time
	NSExpressionDescription *totalFreefallTime = [self expression:@"sum:"
															field:@"FreefallTime"
													   resultName:@"TotalFreefallTime"
													   resultType:NSDecimalAttributeType];
	// total cutaways
	NSExpressionDescription *totalCutaways = [self expression:@"sum:"
														field:@"Cutaway"
												   resultName:@"TotalCutaways"
												   resultType:NSDecimalAttributeType];
	// max freefall time
	NSExpressionDescription *maxFreefallTime = [self expression:@"max:"
														  field:@"FreefallTime"
													 resultName:@"MaxFreefallTime"
													 resultType:NSDecimalAttributeType];
	// total exit altitude
	NSExpressionDescription *totalExitAltitude = [self expression:@"sum:"
															field:@"ExitAltitude"
													   resultName:@"TotalExitAltitude"
													   resultType:NSDecimalAttributeType];
	// max exit altitude
	NSExpressionDescription *maxExitAltitude = [self expression:@"max:"
														  field:@"ExitAltitude"
													 resultName:@"MaxExitAltitude"
													 resultType:NSDecimalAttributeType];
	// total deployment altitude
	NSExpressionDescription *totalDeploymentAltitude = [self expression:@"sum:"
																  field:@"DeploymentAltitude"
															 resultName:@"TotalDeploymentAltitude"
															 resultType:NSDecimalAttributeType];
	// min deployment altitude
	NSExpressionDescription *minDeploymentAltitude = [self expression:@"min:"
																field:@"DeploymentAltitude"
														   resultName:@"MinDeploymentAltitude"
														   resultType:NSDecimalAttributeType];
	
	
	// ------ predicates ------------
	// altitude predicate
	NSPredicate *feetPredicate = [NSPredicate predicateWithFormat:@"AltitudeUnit == %@", 
								  [Units altitudeToString:Feet]];
	// meters predicate
	NSPredicate *metersPredicate = [NSPredicate predicateWithFormat:@"AltitudeUnit == %@", 
									[Units altitudeToString:Meters]];
	// one year predicate
	NSDate *lastYear = [[NSDate date] addTimeInterval:(-1 * SecondsInAYear)];
	NSPredicate *oneYearFilter = [NSPredicate predicateWithFormat:@"Date > %@", lastYear];
	// one month predicate
	NSDate *lastMonth = [[NSDate date] addTimeInterval:(-1 * SecondsInAMonth)];
	NSPredicate *oneMonthFilter = [NSPredicate predicateWithFormat:@"Date > %@", lastMonth];
	
	
	// -------- fetch requests -------- 
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"LogEntry" inManagedObjectContext:context];
	// totals request (max jumps, total ff time, etc)
	NSFetchRequest *totalsRequest = [[NSFetchRequest alloc] init];
	[totalsRequest setEntity:entity];
	[totalsRequest setResultType:NSDictionaryResultType];
	[totalsRequest setPropertiesToFetch:[NSArray arrayWithObjects:
										 maxNumber,
										 maxDate,
										 totalFreefallTime,
										 totalCutaways,
										 maxFreefallTime,
										 nil]];
	// totals request for feet predicate (total/min/max exit/depl alt)
	NSFetchRequest *totalsFeetRequest = [[NSFetchRequest alloc] init];
	[totalsFeetRequest setEntity:entity];
	[totalsFeetRequest setPredicate:feetPredicate];
	[totalsFeetRequest setResultType:NSDictionaryResultType];
	[totalsFeetRequest setPropertiesToFetch:[NSArray arrayWithObjects:
											 totalExitAltitude,
											 maxExitAltitude,
											 totalDeploymentAltitude,
											 minDeploymentAltitude,
											 nil]];
	// totals request for meters predicate (total/min/max exit/depl alt)
	NSFetchRequest *totalsMetersRequest = [[NSFetchRequest alloc] init];
	[totalsMetersRequest setEntity:entity];
	[totalsMetersRequest setPredicate:metersPredicate];
	[totalsMetersRequest setResultType:NSDictionaryResultType];
	[totalsMetersRequest setPropertiesToFetch:[NSArray arrayWithObjects:
											   totalExitAltitude,
											   maxExitAltitude,
											   totalDeploymentAltitude,
											   minDeploymentAltitude,
											   nil]];
	// last year request
	NSFetchRequest *lastYearRequest = [[NSFetchRequest alloc] init];
	[lastYearRequest setEntity:entity];
	[lastYearRequest setPredicate:oneYearFilter];
	// last month request
	NSFetchRequest *lastMonthRequest = [[NSFetchRequest alloc] init];
	[lastMonthRequest setEntity:entity];
	[lastMonthRequest setPredicate:oneMonthFilter];
	
	// ----- execute requests, get results ---------
	NSError *error;
	NSArray *totalsResults = [context executeFetchRequest:totalsRequest error:&error];
	NSArray *totalsFeetResults = [context executeFetchRequest:totalsFeetRequest error:&error];
	NSArray *totalsMetersResults = [context executeFetchRequest:totalsMetersRequest error:&error];
	int jumpsInLastYear = [context countForFetchRequest:lastYearRequest error:&error];
	int jumpsInLastMonth = [context countForFetchRequest:lastMonthRequest error:&error];
	
	
	// ---- check for errors --------
	if (totalsResults == nil || totalsFeetResults == nil || totalsMetersResults == nil)
	{
		NSAssert1(0, @"Failed to load log entry data with message '%@'.", [error localizedDescription]);
	}
	
	
	// ----- analyze results ------
	AltitudeUnit altitudeUnit = [SettingsRepository altitudeUnit];
	// total distance
	int totalExitAltFeet = [[[totalsFeetResults objectAtIndex:0] valueForKey:@"TotalExitAltitude"] intValue];
	int totalDeplAltFeet = [[[totalsFeetResults objectAtIndex:0] valueForKey:@"TotalDeploymentAltitude"] intValue];
	int totalExitAltMeters = [[[totalsMetersResults objectAtIndex:0] valueForKey:@"TotalExitAltitude"] intValue];
	int totalDeplAltMeters = [[[totalsMetersResults objectAtIndex:0] valueForKey:@"TotalDeploymentAltitude"] intValue];
	// convert/add results
	int totalExitAlt = [Units addAltitudes:totalExitAltFeet unit1:Feet alt2:totalExitAltMeters unit2:Meters resultUnit:altitudeUnit];
	int totalDeplAlt = [Units addAltitudes:totalDeplAltFeet unit1:Feet alt2:totalDeplAltMeters unit2:Meters resultUnit:altitudeUnit];
	int totalDistance = totalExitAlt - totalDeplAlt;
	// min/max altitudes
	int maxExitAltFeet = [[[totalsFeetResults objectAtIndex:0] valueForKey:@"MaxExitAltitude"] intValue];
	int maxExitAltMeters = [[[totalsMetersResults objectAtIndex:0] valueForKey:@"MaxExitAltitude"] intValue];
	int maxExitAlt = [Units largestAltitude:maxExitAltFeet unit1:Feet alt2:maxExitAltMeters unit2:Meters resultUnit:altitudeUnit];
	int minDeplAltFeet = [[[totalsFeetResults objectAtIndex:0] valueForKey:@"MinDeploymentAltitude"] intValue];
	int minDeplAltMeters = [[[totalsMetersResults objectAtIndex:0] valueForKey:@"MinDeploymentAltitude"] intValue];
	int minDeplAlt = [Units smallestAltitude:minDeplAltFeet unit1:Feet alt2:minDeplAltMeters unit2:Meters resultUnit:altitudeUnit];
	
	// ----- create summary ------
	Summary *summary = [[Summary alloc] init];
	summary.totalJumps = [[totalsResults objectAtIndex:0] valueForKey:@"MaxJumpNumber"];
	summary.totalFreefallTime = [[totalsResults objectAtIndex:0] valueForKey:@"TotalFreefallTime"];
	summary.maxFreefallTime = [[totalsResults objectAtIndex:0] valueForKey:@"MaxFreefallTime"];
	summary.totalCutaways = [[totalsResults objectAtIndex:0] valueForKey:@"TotalCutaways"];
	summary.lastJump = [[totalsResults objectAtIndex:0] valueForKey:@"MaxDate"];
	summary.jumpsInLastYear = [NSNumber numberWithInt:jumpsInLastYear];
	summary.jumpsInLastMonth = [NSNumber numberWithInt:jumpsInLastMonth];
	summary.totalFreefallDistance = [NSNumber numberWithInt:totalDistance];
	summary.altitudeUnit = [Units altitudeToString:altitudeUnit];
	summary.maxExitAltitude = [NSNumber numberWithInt:maxExitAlt];
	summary.minDeploymentAltitude = [NSNumber numberWithInt:minDeplAlt];
	
	return summary;
}

- (NSDictionary *)yearlyJumpCount:(int)fromYear toYear:(int)toYear
{
	// the entity
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"LogEntry" inManagedObjectContext:context];
	
	// the dictionary
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:0];
	
	// get jump counts per year
	NSFetchRequest *request;
	NSPredicate *filter;
	NSError *error;
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
	NSDate *startDate;
	NSDate *endDate;
	for (int year = fromYear; year <= toYear; year++)
	{
		// create request
		request = [[NSFetchRequest alloc] init];
		[request setEntity:entity];
		
		// create start date
		[dateComponents setYear:year];
		[dateComponents setMonth:1];
		[dateComponents setDay:1];
		startDate = [calendar dateFromComponents:dateComponents];
		// create end date
		[dateComponents setYear:(year+1)];
		[dateComponents setMonth:1];
		[dateComponents setDay:1];
		endDate = [calendar dateFromComponents:dateComponents];
		
		// create filter
		NSPredicate *startFilter = [NSPredicate predicateWithFormat:@"Date >= %@", startDate];
		NSPredicate *endFilter = [NSPredicate predicateWithFormat:@"Date < %@", endDate];
		filter = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:startFilter, endFilter, nil]];
		[request setPredicate:filter];
		
		// get count
		int count = [context countForFetchRequest:request error:&error];
		NSString *yearKey = [[NSNumber numberWithInt:year] stringValue];
		[dictionary setValue:[NSNumber numberWithInt:count] forKey:yearKey];
	}
	
	return dictionary;
	
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
