//
//  Rig.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 9/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LogEntry, RigComponent, RigReminder;

@interface Rig : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * Active;
@property (nonatomic, retain) NSNumber * Primary;
@property (nonatomic, retain) NSString * Notes;
@property (nonatomic, retain) NSString * Name;
@property (nonatomic, retain) NSNumber * Archived;
@property (nonatomic, retain) NSDate * LastModifiedUTC;
@property (nonatomic, retain) NSString * UniqueID;
@property (nonatomic, retain) NSSet *LogEntries;
@property (nonatomic, retain) NSSet *Reminders;
@property (nonatomic, retain) NSSet *Components;
@end

@interface Rig (CoreDataGeneratedAccessors)

- (void)addLogEntriesObject:(LogEntry *)value;
- (void)removeLogEntriesObject:(LogEntry *)value;
- (void)addLogEntries:(NSSet *)values;
- (void)removeLogEntries:(NSSet *)values;
- (void)addRemindersObject:(RigReminder *)value;
- (void)removeRemindersObject:(RigReminder *)value;
- (void)addReminders:(NSSet *)values;
- (void)removeReminders:(NSSet *)values;
- (void)addComponentsObject:(RigComponent *)value;
- (void)removeComponentsObject:(RigComponent *)value;
- (void)addComponents:(NSSet *)values;
- (void)removeComponents:(NSSet *)values;
@end
