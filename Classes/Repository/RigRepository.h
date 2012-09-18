//
//  RigRepository.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/25/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Rig.h"
#import "RigComponent.h"
#import "RigReminder.h"
#import "BaseEntityRepository.h"

@interface RigRepository : BaseEntityRepository
{
}

- (id)initWithContext:(NSManagedObjectContext *)ctx;
- (NSArray *)loadRigs;
- (NSArray *)loadArchivedRigs;
- (NSArray *)primaryRigs;
- (Rig *)createNewRig;
- (RigComponent *)createNewComponentForRig:(Rig *)rig;
- (RigReminder *)createNewReminderForRig:(Rig *)rig;
- (void)deleteRig:(Rig *)rig;
- (void)deleteComponent:(RigComponent *)component;
- (void)deleteReminder:(RigReminder *)reminder;

@end
