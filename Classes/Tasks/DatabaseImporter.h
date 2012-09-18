//
//  DatabaseImporter.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 5/4/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "DDXML.h"
#import "ImageImportInfo.h"

@protocol DatabaseImportDelegate<NSObject>
- (void)addDatabaseImportProgress:(float)progress;
- (void)addImageImport:(ImageImportInfo *)imageImportInfo;
@end

@interface DatabaseImporter : NSObject
{
	id<DatabaseImportDelegate> delegate;
    
    // error message
    NSString *errorMessage;
	
	// maps/lists for import info
	NSMutableDictionary *skydiveTypeMap;
	NSMutableDictionary *locationMap;
	NSMutableDictionary *aircraftMap;
	NSMutableDictionary *rigMap;
}

- (id)initWithDelegate:(id<DatabaseImportDelegate>)delegate;
- (BOOL)beginImport:(NSData *)xmlData;
- (void)importImages:(NSArray *)imagesImportInfo;

@end
