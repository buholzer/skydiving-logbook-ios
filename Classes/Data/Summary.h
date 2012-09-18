//
//  Summary.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/17/10.
//  Copyright 2010 NA. All rights reserved.
//

@interface Summary : NSObject
{
	NSNumber *totalJumps;
	NSNumber *totalFreefallTime;
	NSNumber *totalFreefallDistance;
	NSNumber *maxFreefallTime;
	NSNumber *maxExitAltitude;
	NSNumber *minDeploymentAltitude;
	NSString *altitudeUnit;
	NSNumber *totalCutaways;
	NSDate *lastJump;
	NSNumber *jumpsInLastYear;
	NSNumber *jumpsInLastMonth;
}

@property (nonatomic, retain) NSNumber *totalJumps;
@property (nonatomic, retain) NSNumber *totalFreefallTime;
@property (nonatomic, retain) NSNumber *totalFreefallDistance;
@property (nonatomic, retain) NSNumber *totalCutaways;
@property (nonatomic, retain) NSNumber *maxFreefallTime;
@property (nonatomic, retain) NSNumber *maxExitAltitude;
@property (nonatomic, retain) NSNumber *minDeploymentAltitude;
@property (nonatomic, retain) NSString *altitudeUnit;
@property (nonatomic, retain) NSDate *lastJump;
@property (nonatomic, retain) NSNumber *jumpsInLastYear;
@property (nonatomic, retain) NSNumber *jumpsInLastMonth;

@end
