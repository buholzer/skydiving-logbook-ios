//
//  Signature.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/9/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <CoreData/CoreData.h>

@class LogEntry;

@interface Signature :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * License;
@property (nonatomic, retain) id Image;
@property (nonatomic, retain) NSSet* LogEntry;

@end


@interface Signature (CoreDataGeneratedAccessors)
- (void)addLogEntryObject:(LogEntry *)value;
- (void)removeLogEntryObject:(LogEntry *)value;
- (void)addLogEntry:(NSSet *)value;
- (void)removeLogEntry:(NSSet *)value;

@end

