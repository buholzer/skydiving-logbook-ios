//
//  SettingsRepository.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/1/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SettingsRepository : NSObject
{

}

+ (enum UnitOfMeasure)unitOfMeasure;
+ (void)setUnitOfMeasure:(enum UnitOfMeasure)uom;

+ (enum WeightUnit)weightUnit;
+ (enum AltitudeUnit)altitudeUnit;

+ (NSNumber *)defaultExitAltitude;
+ (void)setDefaultExitAltitude:(NSNumber *)alt;

+ (NSNumber *)defaultDeploymentAltitude;
+ (void)setDefaultDeploymentAltitude:(NSNumber *)alt;

@end
