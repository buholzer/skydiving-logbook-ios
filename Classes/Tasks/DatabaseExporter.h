//
//  DatabaseSerializer.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/22/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XmlSerializer.h"
#import "CsvSerializer.h"

@protocol DatabaseExportDelegate<NSObject>
- (void)addDatabaseExportProgress:(float)progress;
- (void)databaseImageExported:(NSString *)filePath;
- (void)databaseExportComplete:(NSString *)xmlPath csvPath:(NSString *)csvPath;
@end

@interface DatabaseExporter : NSObject
{
    NSString *outputDirectory;
	XmlSerializer *serializer;
	CsvSerializer *csvSerializer;
	id<DatabaseExportDelegate> delegate;
}

- (id)initWithOptions:(NSString *)outputDir delegate:(id<DatabaseExportDelegate>)delegate;
- (void)beginExport;

@end
