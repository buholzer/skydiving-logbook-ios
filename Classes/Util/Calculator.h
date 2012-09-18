//
//  Calculator.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/24/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Units.h"
#import "FreefallProfile.h"

typedef enum CalculatorType
{
	WingLoadingCalculator,
	CanopySizeCalculator,
	ExtraWeightCalculator
} CalculatorType;

@interface Calculator : NSObject
{

}

+ (CGFloat)calculate:(enum CalculatorType)calcType
		  yourWeight:(CGFloat)yourWeight
		 equipWeight:(CGFloat)equipWeight
		  weightUnit:(WeightUnit)weightUnit
		  canopySize:(CGFloat)canopySize
			wingLoad:(CGFloat)wingLoad;

+ (NSInteger)calculateFreefallTime:(enum FreefallProfileType)profileType
					  exitAltitude:(NSInteger)exitAltitude
				deploymentAltitude:(NSInteger)deploymentAltitude
					  altitudeUnit:(enum AltitudeUnit)altitudeUnit;

@end
