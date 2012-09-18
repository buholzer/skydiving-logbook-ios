//
//  LocationRepository.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/25/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"
#import "BaseEntityRepository.h"

@interface LocationRepository : BaseEntityRepository
{
}

- (id)initWithContext:(NSManagedObjectContext *)ctx;
- (Location *)homeLocation;
- (Location *)createNewLocation;
- (void)clearHomeLocations;
- (void)deleteLocation:(Location *)location;

@end
