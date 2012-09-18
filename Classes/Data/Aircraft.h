//
//  Aircraft.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LogEntry;

@interface Aircraft : NSManagedObject

@property (nonatomic, retain) NSDate * LastModifiedUTC;
@property (nonatomic, retain) NSNumber * Active;
@property (nonatomic, retain) NSString * Name;
@property (nonatomic, retain) NSString * UniqueID;
@property (nonatomic, retain) NSString * Notes;
@property (nonatomic, retain) NSNumber * Default;
@property (nonatomic, retain) NSSet *LogEntries;
@end

@interface Aircraft (CoreDataGeneratedAccessors)

- (void)addLogEntriesObject:(LogEntry *)value;
- (void)removeLogEntriesObject:(LogEntry *)value;
- (void)addLogEntries:(NSSet *)values;
- (void)removeLogEntries:(NSSet *)values;
@end
