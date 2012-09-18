//
//  LogEntryImageMappingPolicy.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LogEntryImageMappingPolicy.h"
#import "LogEntryRepository.h"
#import "LogEntry.h"
#import "LogEntryImage.h"
#import "NSData_MD5.h"

@implementation LogEntryImageMappingPolicy

- (BOOL)createDestinationInstancesForSourceInstance:(NSManagedObject *)sInstance entityMapping:(NSEntityMapping *)mapping manager:(NSMigrationManager *)manager error:(NSError **)error
{
    // create destination instance
    BOOL created = [super createDestinationInstancesForSourceInstance:sInstance entityMapping:mapping manager:manager error:error];
    
    // get diagram from source instance
    id diagram = [sInstance valueForKey:@"Diagram"];
    
    // if created succesfully, and source has a diagrm
    if (created && diagram)
    {
        // create repository if necessary
        if (!repository)
        {
            NSManagedObjectContext *context = [manager destinationContext];
            repository = [[LogEntryRepository alloc] initWithContext:context];
        }
        
        // get unique id from source
        NSString *uniqueId = [sInstance valueForKey:@"UniqueID"];
        
        // get destination instance
        NSPredicate *uniqueIdFilter = [NSPredicate predicateWithFormat:@"UniqueID == %@", uniqueId];
        NSArray *logEntries = [repository loadEntitiesWithFilter:uniqueIdFilter];
        LogEntry *logEntry = nil;
        if ([logEntries count] == 1)
            logEntry = [logEntries objectAtIndex:0];
        
        // create new image for destination instance
        if (logEntry)
        {
            LogEntryImage *logEntryImage = [repository createNewDiagramForLogEntry:logEntry];
            logEntryImage.Image = diagram;
            logEntryImage.ImageType = LogEntryDiagramImageType;
            NSData *imageData = UIImagePNGRepresentation(logEntryImage.Image);
            logEntryImage.MD5 = [imageData md5];
        }
    }
    
    // return super result
    return created;
}
@end
