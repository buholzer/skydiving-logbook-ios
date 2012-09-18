//
//  ImportTask.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 5/4/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "DatabaseImporter.h"
#import "FileDownloader.h"
#import "MBProgressHUD.h"
#import "URLAlertView.h"
#import <DropBoxSDK/DropboxSDK.h>

typedef enum ImportSource
{
	ImportFromUrl,
	ImportFromDropBox
} ImportSource;

@interface ImportTask : NSObject<DatabaseImportDelegate,
									URLAlertViewDelegate,
                                    FileDownloaderDelegate,
                                    DBRestClientDelegate>
{
    // import source
    ImportSource source;
    
    // importer and image import info
    DatabaseImporter *dbImporter;
    NSMutableArray *imagesImportInfo;
    
    // progress trackers
    int imageFileCount;
    int downloadedImageFileCount;
	MBProgressHUD *progressHud;
    
    // dropbox client
    DBRestClient *dropBoxClient;
    
    // download source url (if importing via URL)
    NSURL *downloadUrl;
}

- (void)beginImport:(ImportSource)src;

@end
