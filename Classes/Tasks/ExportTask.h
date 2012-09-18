//
//  ExportTask.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 4/20/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "DatabaseExporter.h"
#import "MBProgressHUD.h"
#import <DropBoxSDK/DropboxSDK.h>

typedef enum ExportDestination
{
	ExportToEmail,
	ExportToDropBox
} ExportDestination;

@protocol ExportTaskDelegate<NSObject>
- (void)sendEmail:(NSString *)zipFilePath;
@end

@interface ExportTask : NSObject<DatabaseExportDelegate, DBRestClientDelegate>
{
	id<ExportTaskDelegate> delegate;
    ExportDestination destination;
	
	UIViewController *controller;
	MBProgressHUD *progressHud;
    
    // exported file paths
    NSString *exportedXmlPath;
    NSString *exportedCsvPath;
    NSMutableArray *exportedImagePaths;
    
    // progress trackers
    int exportedFileCount;
    int uploadedFileCount;
    
    // dropbox client
    DBRestClient *dropBoxClient;
}

- (id)initWithDelegate:(id<ExportTaskDelegate>)delegate;
- (void)beginExport:(ExportDestination)dest;

@end
