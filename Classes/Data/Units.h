//
//  Units.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/24/10.
//  Copyright 2010 NA. All rights reserved.
//

typedef enum UnitOfMeasure
{
	US,
	Metric
} UnitOfMeasure;

typedef enum WeightUnit
{
	Pounds,
	Kilograms
} WeightUnit;

typedef enum TimeIntervalUnit
{
	Days,
	Months,
	Years
} TimeIntervalUnit;

typedef enum AltitudeUnit
{
	Feet,
	Meters
} AltitudeUnit;

typedef enum DistanceUnit
{
	Miles,
	Kilometers
} DistanceUnit;

@interface Units : NSObject
{
	
}

+ (CGFloat)convertWeight:(CGFloat)weight fromUnit:(WeightUnit)fromUnit toUnit:(WeightUnit)toUnit;
+ (NSString *)uomToString:(enum UnitOfMeasure)uom;
+ (enum UnitOfMeasure)stringToUOM:(NSString *)string;
+ (NSString *)weightToString:(enum WeightUnit)unit;
+ (enum WeightUnit)stringToWeight:(NSString *)string;
+ (NSString *)timeIntervalToString:(enum TimeIntervalUnit)unit;
+ (enum TimeIntervalUnit)stringToTimeIntervalUnit:(NSString *)string;
+ (CGFloat)convertAltitude:(NSInteger)altitude fromUnit:(AltitudeUnit)fromUnit toUnit:(AltitudeUnit)toUnit;
+ (NSInteger)addAltitudes:(NSInteger)alt1 unit1:(enum AltitudeUnit)unit1 alt2:(NSInteger)alt2 unit2:(enum AltitudeUnit)unit2 resultUnit:(enum AltitudeUnit)resultUnit;
+ (NSInteger)largestAltitude:(NSInteger)alt1 unit1:(enum AltitudeUnit)unit1 alt2:(NSInteger)alt2 unit2:(enum AltitudeUnit)unit2 resultUnit:(enum AltitudeUnit)resultUnit;
+ (NSInteger)smallestAltitude:(NSInteger)alt1 unit1:(enum AltitudeUnit)unit1 alt2:(NSInteger)alt2 unit2:(enum AltitudeUnit)unit2 resultUnit:(enum AltitudeUnit)resultUnit;
+ (NSString *)altitudeToString:(enum AltitudeUnit)unit;
+ (enum AltitudeUnit)stringToAltitudeUnit:(NSString *)string;
+ (CGFloat)convertAltitudeToDistance:(NSInteger)altitude unit:(enum AltitudeUnit)unit;
+ (NSString *)distanceToString:(enum DistanceUnit)unit;
+ (enum DistanceUnit)stringToDistanceUnit:(NSString *)string;
@end