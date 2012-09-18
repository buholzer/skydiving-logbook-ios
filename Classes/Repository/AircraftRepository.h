//
//  AircraftRepository.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/25/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Aircraft.h"
#import "BaseEntityRepository.h"

@interface AircraftRepository : BaseEntityRepository
{
}

- (id)initWithContext:(NSManagedObjectContext *)ctx;
- (Aircraft *)defaultAircraft;
- (Aircraft *)createNewAircraft;
- (void)clearDefaultAircrafts;
- (void)deleteAircraft:(Aircraft *)aircraft;

@end