//
//  BaseEntityRepository.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 8/26/10.
//  Copyright 2010 NA. All rights reserved.
//

@interface BaseEntityRepository : NSObject
{
	NSManagedObjectContext *context;
	NSString *entityName;
	NSString *sortAttribute;
}

- (id)initWithContext:(NSManagedObjectContext *)ctx
		   entityName:(NSString*)name
		sortAttribute:(NSString *)sort;
- (NSArray *)loadEntities;
- (NSArray *)loadEntitiesWithFilter:(NSPredicate *)filter;
- (NSArray *)loadAllEntities;
- (NSArray *)loadAllEntitiesForName:(NSString *)name;
- (NSManagedObject *)createNewEntity;
- (NSManagedObject *)createNewEntityForName:(NSString *)name;
- (void)save;
- (void)rollback;

@end