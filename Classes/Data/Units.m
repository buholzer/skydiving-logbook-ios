//
//  Units.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/24/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "Units.h"

// conversion ratios
static CGFloat KgToLbs = 2.20462262;
static CGFloat FtToMeters = 0.3048;
static NSInteger FeetToMiles = 5280;
static NSInteger MetersToKiloMeters = 1000;

// uom
static NSString *UnitOfMeasureUS = @"US";
static NSString *UnitOfMeasureMetric = @"Metric";
// weight units
static NSString *WeightUnitPounds = @"Pounds";
static NSString *WeightUnitKilograms = @"Kilograms";
// time interval units
static NSString *TimeIntervalUnitDays = @"Days";
static NSString *TimeIntervalUnitMonths = @"Months";
static NSString *TimeIntervalUnitYears = @"Years";
// altitude units
static NSString *AltitudeUnitFeet = @"Feet";
static NSString *AltitudeUnitMeters = @"Meters";
// distance units
static NSString *DistanceUnitMiles = @"Miles";
static NSString *DistanceUnitKilometers = @"Kilometers";

@implementation Units

+ (CGFloat)convertWeight:(CGFloat)weight
				fromUnit:(WeightUnit)fromUnit
				  toUnit:(WeightUnit)toUnit
{
	CGFloat result = weight;
	
	if (fromUnit == Kilograms && toUnit == Pounds)
	{
		// kg to lbs
		result = weight * KgToLbs;
	}
	else if (fromUnit == Pounds && toUnit == Kilograms)
	{
		// lbs to kg
		result = weight / KgToLbs;
	}
	
	return result;
}

+ (NSString *)uomToString:(enum UnitOfMeasure)uom
{
	switch(uom)
	{
		case Metric:
			return UnitOfMeasureMetric;
		default:
			return UnitOfMeasureUS;
	}
}

+ (enum UnitOfMeasure)stringToUOM:(NSString *)string
{
	if ([string isEqualToString:UnitOfMeasureMetric])
	{
		return Metric;
	}
	else
	{
		return US;
	}
}

+ (NSString *)weightToString:(enum WeightUnit)unit
{
	switch(unit)
	{
		case Pounds:
			return WeightUnitPounds;
		case Kilograms:
			return WeightUnitKilograms;
	}
	return nil;
}

+ (enum WeightUnit)stringToWeight:(NSString *)string
{
	if ([string isEqualToString:WeightUnitPounds])
	{
		return Pounds;
	}
	else
	{
		return Kilograms;
	}

}

+ (NSString *)timeIntervalToString:(enum TimeIntervalUnit)unit
{
	switch(unit)
	{
		case Days:
			return TimeIntervalUnitDays;
		case Months:
			return TimeIntervalUnitMonths;
		case Years:
			return TimeIntervalUnitYears;
	}
	return nil;
}

+ (enum TimeIntervalUnit)stringToTimeIntervalUnit:(NSString *)string
{
	if ([string isEqualToString:TimeIntervalUnitDays])
	{
		return Days;
	}
	else if ([string isEqualToString:TimeIntervalUnitMonths])
	{
		return Months;
	}
	else
	{
		return Years;
	}
}

+ (CGFloat)convertAltitude:(NSInteger)altitude fromUnit:(AltitudeUnit)fromUnit toUnit:(AltitudeUnit)toUnit
{
	CGFloat result = altitude;
	
	if (fromUnit == Meters && toUnit == Feet)
	{
		// meters to feet
		result = altitude / FtToMeters;
	}
	else if (fromUnit == Feet && toUnit == Meters)
	{
		// feet to meters
		result = altitude * FtToMeters;
	}
	
	return result;
}

+ (NSInteger)addAltitudes:(NSInteger)alt1 unit1:(enum AltitudeUnit)unit1 alt2:(NSInteger)alt2 unit2:(enum AltitudeUnit)unit2 resultUnit:(enum AltitudeUnit)resultUnit
{
	NSInteger alt2Converted = [self convertAltitude:alt2 fromUnit:unit2 toUnit:unit1];
	int total = alt1 + alt2Converted;
	return [self convertAltitude:total fromUnit:unit1 toUnit:resultUnit];
}

+ (NSInteger)largestAltitude:(NSInteger)alt1 unit1:(enum AltitudeUnit)unit1 alt2:(NSInteger)alt2 unit2:(enum AltitudeUnit)unit2 resultUnit:(enum AltitudeUnit)resultUnit
{
	NSInteger alt2Converted = [self convertAltitude:alt2 fromUnit:unit2 toUnit:unit1];
	NSInteger largestAltitude = (alt1 > alt2Converted) ? alt1 : alt2Converted;
	return [self convertAltitude:largestAltitude fromUnit:unit1 toUnit:resultUnit];
}

+ (NSInteger)smallestAltitude:(NSInteger)alt1 unit1:(enum AltitudeUnit)unit1 alt2:(NSInteger)alt2 unit2:(enum AltitudeUnit)unit2 resultUnit:(enum AltitudeUnit)resultUnit
{
	NSInteger alt2Converted = [self convertAltitude:alt2 fromUnit:unit2 toUnit:unit1];
	NSInteger smallestAltitude;
	// get non-zero altitude
	if (alt1 == 0)
		smallestAltitude = alt2Converted;
	else if (alt2Converted == 0)
		smallestAltitude = alt1;
	else if (alt1 < alt2Converted)
		smallestAltitude = alt1;
	else
		smallestAltitude = alt2Converted;

	return [self convertAltitude:smallestAltitude fromUnit:unit1 toUnit:resultUnit];	
}

+ (NSString *)altitudeToString:(enum AltitudeUnit)unit
{
	switch(unit)
	{
		case Feet:
			return AltitudeUnitFeet;
		case Meters:
			return AltitudeUnitMeters;
	}
	return nil;
}

+ (enum AltitudeUnit)stringToAltitudeUnit:(NSString *)string
{
	if ([string isEqualToString:AltitudeUnitFeet])
	{
		return Feet;
	}
	else
	{
		return Meters;
	}
}

+ (CGFloat)convertAltitudeToDistance:(NSInteger)altitude unit:(enum AltitudeUnit)unit
{
	if (unit == Feet)
	{
		return ((CGFloat)altitude) / FeetToMiles; 
	}
	else
	{
		return ((CGFloat)altitude) / MetersToKiloMeters;
	}

}

+ (NSString *)distanceToString:(enum DistanceUnit)unit
{
	switch(unit)
	{
		case Miles:
			return DistanceUnitMiles;
		case Kilometers:
			return DistanceUnitKilometers;
	}
	return nil;
}

+ (enum DistanceUnit)stringToDistanceUnit:(NSString *)string
{
	if ([string isEqualToString:DistanceUnitMiles])
	{
		return Miles;
	}
	else
	{
		return Kilometers;
	}
}

@end
