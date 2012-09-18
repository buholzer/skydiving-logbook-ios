//
//  LogEntryImage.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LogEntry;

@interface LogEntryImage : NSManagedObject

@property (nonatomic, retain) id Image;
@property (nonatomic, retain) NSString * ImageType;
@property (nonatomic, retain) NSString * MD5;
@property (nonatomic, retain) LogEntry *LogEntry;

@end
