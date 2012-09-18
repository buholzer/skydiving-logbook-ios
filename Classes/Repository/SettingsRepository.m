//
//  SettingsRepository.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/1/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "SettingsRepository.h"
#import "Units.h"

static NSString *unitOfMeasureKey = @"unitOfMeasureKey";
static NSString *exitAltitudeKey = @"defaultExitAltitudeKey";
static NSString *deploymentAltitudeKey = @"defaultDeploymentAltitudeKey";

@implementation SettingsRepository

+ (enum UnitOfMeasure)unitOfMeasure
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *uom = [defaults stringForKey:unitOfMeasureKey];
	
	if (uom == nil)
		return US;
	else
		return [Units stringToUOM:uom];
}

+ (void)setUnitOfMeasure:(enum UnitOfMeasure)uom
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:[Units uomToString:uom] forKey:unitOfMeasureKey];
}

+ (enum WeightUnit)weightUnit
{
	if ([self unitOfMeasure] == Metric)
		return Kilograms;
	else
		return Pounds;
}

+ (enum AltitudeUnit)altitudeUnit
{
	if ([self unitOfMeasure] == Metric)
		return Meters;
	else
		return Feet;
}

+ (NSNumber *)defaultExitAltitude
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	int altitude = [defaults integerForKey:exitAltitudeKey];
	
	if (altitude > 0)
		return [NSNumber numberWithInt:altitude];
	else if ([SettingsRepository altitudeUnit] == Feet)
		return [NSNumber numberWithInt:13000];
	else
		return [NSNumber numberWithInt:4000];
}

+ (void)setDefaultExitAltitude:(NSNumber *)alt
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:[alt intValue] forKey:exitAltitudeKey];
}

+ (NSNumber *)defaultDeploymentAltitude
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	int altitude = [defaults integerForKey:deploymentAltitudeKey];
	
	if (altitude > 0)
		return [NSNumber numberWithInt:altitude];
	else if ([SettingsRepository altitudeUnit] == Feet)
		return [NSNumber numberWithInt:3500];
	else
		return [NSNumber numberWithInt:1000];
}

+ (void)setDefaultDeploymentAltitude:(NSNumber *)alt
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:[alt intValue] forKey:deploymentAltitudeKey];
}

@end
