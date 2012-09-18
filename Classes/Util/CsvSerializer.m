//
//  CsvSerializer.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 4/20/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "CsvSerializer.h"

static NSDateFormatter *dateFormat = nil;

@interface CsvSerializer(Private)
- (NSString *)commaSeparated:(NSArray *)stringArr;
- (NSString *)escapeString:(NSString *)string;
- (void)writeString:(NSString *)str;
@end

@implementation CsvSerializer

- (id)initWithFilePath:(NSString *)filePath
{
	if ([self init] != nil)
	{
		// create/overwrite file
		NSFileManager *fileManager = [NSFileManager defaultManager];
		[fileManager createFileAtPath:filePath contents:nil attributes:nil];
		// open file
		fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
	}
	return self;
}

- (void)closeFile
{
	[fileHandle closeFile];
}

- (void)addRow:(NSArray *)rowStrings
{
	[self writeString:[self commaSeparated:rowStrings]];
	[self writeString:@"\n"];
}

- (NSString *)formatString:(NSString *)string
{
	return [self escapeString:string];
}

- (NSString *)formatNumber:(NSNumber *)number
{
	return [number stringValue];
}

- (NSString *)formatNumberAsBoolean:(NSNumber *)number
{
	if ([number boolValue])
		return NSLocalizedString(@"Yes", @"");
	else
		return NSLocalizedString(@"No", @"");
}

- (NSString *)formatDate:(NSDate *)date
{
	if (dateFormat == nil)
	{
		dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"yyyy-MM-dd"];
	}
	return [dateFormat stringFromDate:date];
}

- (NSString *)commaSeparated:(NSArray *)stringArr
{
	NSMutableString *string = [NSMutableString stringWithCapacity:0];
	for (int i = 0; i < [stringArr count]; i++)
	{
		[string appendString:[stringArr objectAtIndex:i]];
		if (i < [stringArr count] - 1)
		{
			[string appendString:@","];
		}
	}
	return string;
}

- (NSString *)escapeString:(NSString *)string
{
	NSMutableString *result = [NSMutableString stringWithString:string];
	// replace " with ""
	[result replaceOccurrencesOfString:@"\"" withString:@"\"\"" options:NSLiteralSearch range:NSMakeRange(0, [result length])];
	// if , or newline, surround with ""
	NSRange commaRange = [result rangeOfString:@","];
	NSRange newlineRange = [result rangeOfString:@"\n"];
	if (commaRange.location != NSNotFound || newlineRange.location != NSNotFound)
	{
		[result insertString:@"\"" atIndex:0];
		[result appendString:@"\""];
	}
	return result;
}

- (void)writeString:(NSString *)str
{
	[fileHandle writeData:[str dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
