//
//  XmlUtility.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/19/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface XmlSerializer : NSObject
{
	NSFileHandle *fileHandle;
	NSInteger indentCount;
}

- (id)initWithFilePath:(NSString *)filePath;

- (void)startDocument;
- (void)startTag:(NSString *)tag;
- (void)startTagWithAttribute:(NSString *)tag attribute:(NSString *)attribute value:(NSString *)value;
- (void)startTagWithAttributes:(NSString *)tag attribute1:(NSString *)attribute1 value1:(NSString *)value1
                    attribute2:(NSString *)attribute2 value2:(NSString *)value2;
- (void)tagWithString:(NSString *)tag string:(NSString *)string;
- (void)tagWithNumber:(NSString *)tag number:(NSNumber *)number;
- (void)tagWithDate:(NSString *)tag date:(NSDate *)date;
- (void)tagWithUTCDateTime:(NSString *)tag date:(NSDate *)date;
- (void)tagWithImage:(NSString *)tag image:(UIImage *)image;
- (void)tagWithID:(NSString *)tag object:(NSManagedObject *)object;
- (void)endTag:(NSString *)tag;
- (void)closeFile;

@end
