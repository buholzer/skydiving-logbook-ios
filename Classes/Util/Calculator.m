//
//  Calculator.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/24/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "Calculator.h"

// constants for freefall time estimation
static float VerticalTerminalVelocity = 235; // ft/sec
static float HorizontalTerminalVelocity = 176; // ft/sec
static float TrackingTerminalVelocity = 144; // ft/sec
static float WingsuitTerminalVelocity = 73; // ft/sec
static float SkysurfingTerminalVelocity = 158; // ft/sec
static float Gravity = 32.174; // ft/sec

@interface Calculator(Private)
+ (float)calculateWingLoading:(float)yourWeight
					equipWeight:(float)equipWeight
					 weightUnit:(WeightUnit)weightUnit
					 canopySize:(float)canopySize;

+ (float)calculateCanopySize:(float)yourWeight
				   equipWeight:(float)equipWeight
					weightUnit:(WeightUnit)weightUnit
					  wingLoad:(float)wingLoad;

+ (float) calculateExtraWeight:(float)yourWeight
					 equipWeight:(float)equipWeight
					  weightUnit:(WeightUnit)weightUnit
					  canopySize:(float)canopySize
						wingLoad:(float)wingLoad;
+ (float) getTerminalVelocity:(enum FreefallProfileType)profileType;
@end

@implementation Calculator

+ (CGFloat)calculateWingLoading:(float)yourWeight
					equipWeight:(float)equipWeight
					 weightUnit:(WeightUnit)weightUnit
					 canopySize:(float)canopySize
{
	// protected against div by 0
	if (canopySize == 0)
	{
		return 0;
	}
	
	// get total weight in lbs
	float totalWeightLbs = [Units convertWeight:yourWeight + equipWeight fromUnit:weightUnit toUnit:Pounds];
	
	return totalWeightLbs/canopySize;
}

+ (float)calculateCanopySize:(float)yourWeight
				   equipWeight:(float)equipWeight
					weightUnit:(WeightUnit)weightUnit
					  wingLoad:(float)wingLoad
{
	// protect against div by 0
	if (wingLoad == 0)
	{
		return 0;
	}
	
	// get total weight in lbs
	float totalWeightLbs = [Units convertWeight:yourWeight + equipWeight fromUnit:weightUnit toUnit:Pounds];
	
	return totalWeightLbs/wingLoad;
}

+ (float) calculateExtraWeight:(float)yourWeight
					 equipWeight:(float)equipWeight
					  weightUnit:(WeightUnit)weightUnit
					  canopySize:(float)canopySize
						wingLoad:(float)wingLoad
{
	// get total weight in lbs
	float totalWeightLbs = [Units convertWeight:yourWeight + equipWeight fromUnit:weightUnit toUnit:Pounds];
	
	// get extra weight in lbs
	float extraWeightLbs = (wingLoad * canopySize) - totalWeightLbs;
	
	// convert to weight unit
	return [Units convertWeight:extraWeightLbs fromUnit:Pounds toUnit:weightUnit];
}

+ (float)calculate:(enum CalculatorType)calcType
		  yourWeight:(float)yourWeight
		 equipWeight:(float)equipWeight
		  weightUnit:(WeightUnit)weightUnit
		  canopySize:(float)canopySize
			wingLoad:(float)wingLoad
{
	float result = 0;
	
	if (calcType == WingLoadingCalculator)
	{
		result = [self calculateWingLoading:yourWeight equipWeight:equipWeight weightUnit:weightUnit canopySize:canopySize];
	}
	else if (calcType == CanopySizeCalculator)
	{
		result = [self calculateCanopySize:yourWeight equipWeight:equipWeight weightUnit:weightUnit wingLoad:wingLoad];
	}
	else if (calcType == ExtraWeightCalculator)
	{
		result = [self calculateExtraWeight:yourWeight equipWeight:equipWeight weightUnit:weightUnit canopySize:canopySize wingLoad:wingLoad];
	}
	
	return result;
}

+ (NSInteger)calculateFreefallTime:(enum FreefallProfileType)profileType
					  exitAltitude:(NSInteger)exitAltitude
				deploymentAltitude:(NSInteger)deploymentAltitude
					  altitudeUnit:(enum AltitudeUnit)altitudeUnit
{
	// invalid
	if (deploymentAltitude >= exitAltitude)
	{
		return 0;
	}
	
	// get terminal velocify (ft/sec)
	float tv = [self getTerminalVelocity:profileType];
	
	// get time and distance to tv
	float timeToTv = tv / Gravity;
	float distToTv = 0.5 * Gravity * timeToTv * timeToTv;
	
	// get total distance in feet
	float distanceFt = [Units convertAltitude:(exitAltitude - deploymentAltitude) fromUnit:altitudeUnit toUnit:Feet];
	
	if (distanceFt > distToTv)
	{
		float remainingTime = (distanceFt - distToTv) / tv;
		return round(remainingTime + timeToTv);
	}
	else
	{
		return round(sqrt(2 * distanceFt / Gravity));
	}
}

+ (float) getTerminalVelocity:(enum FreefallProfileType)profileType
{
	float tv = 0;
	switch (profileType)
	{
		// vertical disciplines
		case Vertical:
			tv = VerticalTerminalVelocity;
			break;
		// horizontal disciplines
		case Horizontal:
			tv = HorizontalTerminalVelocity;
			break;
		// tracking
		case Tracking:
			tv = TrackingTerminalVelocity;
			break;
		// wingsuit
		case Wingsuit:
			tv = WingsuitTerminalVelocity;
			break;
		// skysurfing
		case Skysurfing:
			tv = SkysurfingTerminalVelocity;
			break;
	}
	
	return tv;
}

@end
