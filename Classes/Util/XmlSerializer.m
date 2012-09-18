//
//  XmlUtility.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/19/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "XmlSerializer.h"
#import "Base64Util.h"

static NSDateFormatter *dateFormat = nil;
static NSDateFormatter *utcDateTimeFormat= nil;

@interface XmlSerializer(Private)
- (NSMutableString *)indent;
- (NSString *)escapeString:(NSString *)string;
- (void)writeString:(NSString *)str;
@end

@implementation XmlSerializer

- (id)initWithFilePath:(NSString *)filePath
{
	if ([self init] != nil)
	{
		// create/overwrite file
		NSFileManager *fileManager = [NSFileManager defaultManager];
		[fileManager createFileAtPath:filePath contents:nil attributes:nil];
		// open file
		fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
		// init indent
		indentCount = 0;
	}
	return self;
}

- (void)closeFile
{
	[fileHandle closeFile];
}

- (void)startDocument
{
	NSString *str = @"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n";
	// write string to file
	[self writeString:str];
}


- (void)startTagWithAttribute:(NSString *)tag attribute:(NSString *)attribute value:(NSString *)value
{
	// get indent
	NSMutableString *str = [self indent];
	// add tag
	[str appendFormat:@"<%@ %@=\"%@\">\n", tag, attribute, value];
	// write string to file
	[self writeString:str];
	// increase indent
	indentCount++;
}

- (void)startTagWithAttributes:(NSString *)tag attribute1:(NSString *)attribute1 value1:(NSString *)value1
                    attribute2:(NSString *)attribute2 value2:(NSString *)value2
{
	// get indent
	NSMutableString *str = [self indent];
	// add tag
	[str appendFormat:@"<%@ %@=\"%@\" %@=\"%@\">\n", tag, attribute1, value1, attribute2, value2];
	// write string to file
	[self writeString:str];
	// increase indent
	indentCount++;
}

- (void)startTag:(NSString *)tag
{
	// get indent
	NSMutableString *str = [self indent];
	// add tag
	[str appendFormat:@"<%@>\n", tag];
	// write string to file
	[self writeString:str];
	// increase indent
	indentCount++;
}

- (void)tagWithString:(NSString *)tag string:(NSString *)string
{
	if (string)
	{
		// escape string
		NSString *escapedStr = [self escapeString:string];
		// get indent
		NSMutableString *str = [self indent];
		// add tag
		[str appendFormat:@"<%@>%@</%@>\n", tag, escapedStr, tag];
		// write string to file
		[self writeString:str];
	}
}

- (void)tagWithImage:(NSString *)tag image:(UIImage *)image
{
	NSData *data = UIImagePNGRepresentation(image);
    [self tagWithString:tag string:[data base64Encoding]];
}

- (void)tagWithNumber:(NSString *)tag number:(NSNumber *)number
{
	[self tagWithString:tag string:[number stringValue]];
}

- (void)tagWithDate:(NSString *)tag date:(NSDate *)date
{
	if (dateFormat == nil)
	{
		dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"yyyy-MM-dd"];
	}
	[self tagWithString:tag string:[dateFormat stringFromDate:date]];
}

- (void)tagWithUTCDateTime:(NSString *)tag date:(NSDate *)date
{
    if (utcDateTimeFormat == nil)
    {
        utcDateTimeFormat = [[NSDateFormatter alloc] init];
        [utcDateTimeFormat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [utcDateTimeFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    }
    [self tagWithString:tag string:[utcDateTimeFormat stringFromDate:date]];
}

- (void)tagWithID:(NSString *)tag object:(NSManagedObject *)object
{
	NSString *idStr = [[[object objectID] URIRepresentation] absoluteString];
	[self tagWithString:tag string:idStr];
}

- (void)endTag:(NSString *)tag
{
	// decrease indent
	indentCount--;
	// get indent
	NSMutableString *str = [self indent];
	// add tag
	[str appendFormat:@"</%@>\n", tag];
	// write string to file
	[self writeString:str];
}

- (NSMutableString *)indent
{
	NSMutableString *indent = [NSMutableString stringWithCapacity:0];
	[indent appendString:@""];
	for (int i = 0; i < indentCount; i++)
	{
		[indent appendString:@"\t"];
	}
	return indent;
}

- (NSString *)escapeString:(NSString *)string
{
	// escape string
	NSMutableString *escapedStr = [NSMutableString stringWithString:string];
	[escapedStr replaceOccurrencesOfString:@"&"  withString:@"&amp;"  options:NSLiteralSearch range:NSMakeRange(0, [escapedStr length])];
	[escapedStr replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:NSMakeRange(0, [escapedStr length])];
	[escapedStr replaceOccurrencesOfString:@"'"  withString:@"&#x27;" options:NSLiteralSearch range:NSMakeRange(0, [escapedStr length])];
	[escapedStr replaceOccurrencesOfString:@">"  withString:@"&gt;"   options:NSLiteralSearch range:NSMakeRange(0, [escapedStr length])];
	[escapedStr replaceOccurrencesOfString:@"<"  withString:@"&lt;"   options:NSLiteralSearch range:NSMakeRange(0, [escapedStr length])];
	return escapedStr;
}

- (void)writeString:(NSString *)str
{
	[fileHandle writeData:[str dataUsingEncoding:NSUTF8StringEncoding]];
}
@end
