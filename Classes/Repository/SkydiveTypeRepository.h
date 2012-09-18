//
//  SkydiveTypeRepository.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 8/26/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SkydiveType.h"
#import "BaseEntityRepository.h"

@interface SkydiveTypeRepository : BaseEntityRepository
{
}

- (id)initWithContext:(NSManagedObjectContext *)ctx;
- (SkydiveType *)defaultSkydiveType;
- (SkydiveType *)createNewSkydiveType;
- (void)clearDefaultSkydiveTypes;
- (void)deleteSkydiveType:(SkydiveType *)skydiveType;

@end
