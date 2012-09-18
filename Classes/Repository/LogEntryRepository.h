//
//  LogEntryRepository.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/26/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogEntry.h"
#import "LogEntryImage.h"
#import "LogEntrySearchCriteria.h"
#import "BaseEntityRepository.h"

extern NSString * const LogEntryPhotoImageType;
extern NSString * const LogEntryDiagramImageType;

@interface LogEntryRepository : BaseEntityRepository
{
}

- (id)initWithContext:(NSManagedObjectContext *)ctx;
- (NSArray *)loadLogEntries:(NSInteger)startIndex maxRows:(NSInteger)maxRows;
- (LogEntry *)getPreviousLogEntry:(NSInteger)jumpNumber;
- (LogEntry *)getNextLogEntry:(NSInteger)jumpNumber;
- (NSArray *)findLogEntries:(LogEntrySearchCriteria *)searchCriteria;
- (NSArray *)loadAllSignatures;
- (LogEntry *)createWithDefaults;
- (LogEntry *)createFromLast;
- (void)decrementJumpNumbersAbove:(NSInteger)jumpNumber;
- (Signature *)createNewSignature;
- (LogEntryImage *)createNewPhotoForLogEntry:(LogEntry *)logEntry;
- (LogEntryImage *)createNewDiagramForLogEntry:(LogEntry *)logEntry;
- (void)deleteLogEntry:(LogEntry *)logEntry;
- (void)deleteLogEntryImage:(LogEntryImage *)image;

@end
