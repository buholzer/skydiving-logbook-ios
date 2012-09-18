//
//  Location.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 9/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LogEntry;

@interface Location : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * Active;
@property (nonatomic, retain) NSString * Name;
@property (nonatomic, retain) NSString * Notes;
@property (nonatomic, retain) NSNumber * Home;
@property (nonatomic, retain) NSString * UniqueID;
@property (nonatomic, retain) NSDate * LastModifiedUTC;
@property (nonatomic, retain) NSSet *LogEntries;
@end

@interface Location (CoreDataGeneratedAccessors)

- (void)addLogEntriesObject:(LogEntry *)value;
- (void)removeLogEntriesObject:(LogEntry *)value;
- (void)addLogEntries:(NSSet *)values;
- (void)removeLogEntries:(NSSet *)values;
@end
