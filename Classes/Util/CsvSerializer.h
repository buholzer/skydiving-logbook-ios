//
//  CsvSerializer.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 4/20/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CsvSerializer : NSObject
{
	NSFileHandle *fileHandle;
}

- (id)initWithFilePath:(NSString *)filePath;

- (void)addRow:(NSArray *)fieldStrings;
- (NSString *)formatString:(NSString *)string;
- (NSString *)formatNumber:(NSNumber *)number;
- (NSString *)formatNumberAsBoolean:(NSNumber *)number;
- (NSString *)formatDate:(NSDate *)date;
- (void)closeFile;

@end
