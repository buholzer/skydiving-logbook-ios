//
//  LogEntrySearchCriteria.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogEntrySearchCriteria : NSObject

@property(strong) NSArray *aircrafts;
@property(strong) NSArray *locations;
@property(strong) NSArray *rigs;
@property(strong) NSArray *skydiveTypes;

@property(strong) NSDate *startDateRange;
@property(strong) NSDate *endDateRange;

@property(strong) NSNumber *maxExitAltitude;
@property(strong) NSNumber *minExitAltitude;

@property(strong) NSNumber *maxDeploymentAltitude;
@property(strong) NSNumber *minDeploymentAltitude;

@property(strong) NSNumber *cutaway;

@property(strong) NSString *notesSearchText;


@end
