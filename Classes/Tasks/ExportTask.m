//
//  ExportTask.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 4/20/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "ExportTask.h"
#import "CommonAppDelegate.h"
#import "UIUtility.h"
#import "ImportExportConstants.h"
#import "ZipFile.h"
#import "ZipWriteStream.h"

@interface ExportTask(Private)
- (void)startDBExport;
- (void)startFileExport;
- (void)startDropBoxExport;
- (void)continueDropBoxExport:(DBMetadata *)folderMetadata;
- (void)uploadFileToDropBox:(NSString *)filePath folderMetadata:(DBMetadata *)folderMetadata;
- (DBMetadata *)getDropBoxMetadata:(DBMetadata *)folderMetadata fileName:(NSString *)fileName;
- (void)doEmailExport;
- (void)cleanupFiles;
- (void)exportComplete;
- (void)showMessage:(NSString *)message;
- (void)showProgress:(NSString *)title;
- (void)dismissProgress;
@end

@implementation ExportTask

- (id)initWithDelegate:(id<ExportTaskDelegate>)theDelegate
{
	if (self = [super init])
	{
		delegate = theDelegate;
        exportedImagePaths = [NSMutableArray arrayWithCapacity:0];
	}
	return self;
}

- (void)beginExport:(ExportDestination)dest
{
    // set destination
    destination = dest;
    
    // init dropbox client
    if (dest == ExportToDropBox && !dropBoxClient)
    {
        dropBoxClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        dropBoxClient.delegate = self;
    }
    
	// execute db export on background thread
	[self performSelectorInBackground:@selector(startDBExport) withObject:nil];
	
    // show progress
    [self showProgress:NSLocalizedString(@"ExportDataTitle", @"")];
}

- (void)startDBExport
{	
    @autoreleasepool
    {
        // get export dir
        NSString *exportDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        
        // create db export task
        DatabaseExporter *task = [[DatabaseExporter alloc] initWithOptions:exportDir delegate:self];
        // run db export task
        [task beginExport];
    }
    
    // continue on main thread
    [self performSelectorOnMainThread:@selector(startFileExport) withObject:nil waitUntilDone:NO];
}

- (void)startFileExport
{
    // dismiss progress
    [self dismissProgress];

    // start file exports
    if (destination == ExportToDropBox)
    {
        [self startDropBoxExport];
    }
    else if (destination == ExportToEmail)
    {
        [self doEmailExport];
    }
}

- (void)startDropBoxExport
{
    // show progress
    [self showProgress:NSLocalizedString(@"UploadFileTitle", @"")];

    // get folder metadata to see what image files already exist
    [dropBoxClient loadMetadata:DropBoxFolderName];
}

- (void)continueDropBoxExport:(DBMetadata *)folderMetadata
{
    // reset file counts
    exportedFileCount = [exportedImagePaths count] + 2;
    uploadedFileCount = 0;
    
    // export xml/csv
    [self uploadFileToDropBox:exportedXmlPath folderMetadata:folderMetadata];
    [self uploadFileToDropBox:exportedCsvPath folderMetadata:folderMetadata];
    
    // do image uploads
    for (NSString *filePath in exportedImagePaths)
    {
        [self uploadFileToDropBox:filePath folderMetadata:folderMetadata];
    }
}

- (void)uploadFileToDropBox:(NSString *)filePath folderMetadata:(DBMetadata *)folderMetadata
{
    // get file name
    NSString *fileName = [filePath lastPathComponent];
    
    // get DBMetadata
    DBMetadata *fileMetadata = [self getDropBoxMetadata:folderMetadata fileName:fileName];
        
    // if not Xml/Csv file (i.e. image), file exists and not deleted, skip this step
    if (![fileName isEqualToString:XmlFileName] &&
        ![fileName isEqualToString:CsvFileName] &&
        fileMetadata &&
        !fileMetadata.isDeleted)
    {
        // increment count
        uploadedFileCount += 1;
        
        // if done, complete
        if (uploadedFileCount >= exportedFileCount)
        {
            [self exportComplete];
        }
        
        return;
    }

    // parent rev
    NSString *parentRev = nil;
    if (fileMetadata)
        parentRev = fileMetadata.rev;
    
    // upload
    [dropBoxClient uploadFile:fileName toPath:DropBoxFolderName withParentRev:parentRev fromPath:filePath];    
}

- (DBMetadata *)getDropBoxMetadata:(DBMetadata *)folderMetadata fileName:(NSString *)fileName
{
    for (DBMetadata *fileMetadata in folderMetadata.contents)
    {
        if ([fileMetadata.filename isEqualToString:fileName])
        {
            return fileMetadata;
        }
    }
    
    return nil;
}

- (void)doEmailExport
{
    // get zip file path
    NSString *exportDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *zipFilePath = [exportDir stringByAppendingPathComponent:ZipFileName];

    // create zip file
    ZipFile *zipFile = [[ZipFile alloc] initWithFileName:zipFilePath mode:ZipFileModeCreate];
    
    NSDate *date = [NSDate date];
    
    // add Xml file
    ZipWriteStream *xmlZipStream = [zipFile writeFileInZipWithName:XmlFileName fileDate:date compressionLevel:ZipCompressionLevelBest];
	[xmlZipStream writeData:[NSData dataWithContentsOfFile:exportedXmlPath]];
	[xmlZipStream finishedWriting];
    
    // add Csv file
    ZipWriteStream *csvZipStream = [zipFile writeFileInZipWithName:CsvFileName fileDate:date compressionLevel:ZipCompressionLevelBest];
	[csvZipStream writeData:[NSData dataWithContentsOfFile:exportedCsvPath]];
	[csvZipStream finishedWriting];
    
    // add images
    for (NSString *imagePath in exportedImagePaths)
    {
        NSString *imageFileName = [imagePath lastPathComponent];
        ZipWriteStream *imgZipStream = [zipFile writeFileInZipWithName:imageFileName fileDate:date compressionLevel:ZipCompressionLevelBest];
        [imgZipStream writeData:[NSData dataWithContentsOfFile:imagePath]];
        [imgZipStream finishedWriting];
    }
    
    // close zip
    [zipFile close];
    
    // do email
    [delegate sendEmail:zipFilePath];
    
    // cleanup files
    [self cleanupFiles];
}

- (void)cleanupFiles
{
    // cleanup all exported files
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    // xml/csv
    [fileManager removeItemAtPath:exportedXmlPath error:&error];
    [fileManager removeItemAtPath:exportedCsvPath error:&error];
    // images
    for (NSString *exportedFile in exportedImagePaths)
    {
        [fileManager removeItemAtPath:exportedFile error:&error];
    }
    // zip
    NSString *exportDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *zipFilePath = [exportDir stringByAppendingPathComponent:ZipFileName];
    if ([fileManager fileExistsAtPath:zipFilePath])
        [fileManager removeItemAtPath:zipFilePath error:&error];
    
    // reset list
    [exportedImagePaths removeAllObjects];

}

- (void)exportComplete
{
    // show success
    [self showMessage:NSLocalizedString(@"ExportSuccessMessage", @"")];
    
    // cleanup files
    [self cleanupFiles];
}

- (void)showMessage:(NSString *)message
{
    // dismiss progress
    [self dismissProgress];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)showProgress:(NSString *)title
{
    // create/init progress hud
	if (!progressHud)
	{
		CommonAppDelegate *appDelegate = (CommonAppDelegate *)[[UIApplication sharedApplication] delegate];
		UIWindow *mainWindow = [appDelegate mainWindow];
		progressHud = [[MBProgressHUD alloc] initWithView:mainWindow];
		progressHud.mode = MBProgressHUDModeDeterminate;
		[mainWindow addSubview:progressHud];
	}
	
	// set title and show
	progressHud.progress = 0;
	progressHud.labelText = title;
	[progressHud show:YES];
}

- (void)dismissProgress
{
    if (!progressHud)
        return;

    // cleanup hud
	[progressHud hide:YES];
	[progressHud removeFromSuperview];
	progressHud = nil;
}

#pragma mark -
#pragma mark DatabaseExportDelegate

- (void)addDatabaseExportProgress:(float)progress
{
	progressHud.progress += progress;
	progressHud.detailsLabelText = [UIUtility formatProgress:progressHud.progress];
}

- (void)databaseImageExported:(NSString *)filePath
{
    // add file to list
    [exportedImagePaths addObject:filePath];
}

- (void)databaseExportComplete:(NSString *)xmlPath csvPath:(NSString *)csvPath
{
    // set paths
    exportedXmlPath = xmlPath;
    exportedCsvPath = csvPath;
}

#pragma mark -
#pragma mark DBRestClientDelegate

- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)folderMetadata
{
    // continue with dropbox export
    [self continueDropBoxExport:folderMetadata];
}

- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error
{
    // folder doesn't exist, create it
    [dropBoxClient createFolder:DropBoxFolderName];
}

- (void)restClient:(DBRestClient*)client createdFolder:(DBMetadata*)folder
{
    // continue with dropbox export
    [self continueDropBoxExport:folder];
}

- (void)restClient:(DBRestClient*)client createFolderFailedWithError:(NSError*)error
{
    // show error
    [self showMessage:NSLocalizedString(@"ExportErrorMessage", @"")];
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath 
          metadata:(DBMetadata*)metadata
{
    // increment count
    uploadedFileCount += 1;
    
    // if done, complete
    if (uploadedFileCount >= exportedFileCount)
        [self exportComplete];
}

- (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path
{
    // increment count
    uploadedFileCount += 1;
    
    // if done, complete
    if (uploadedFileCount >= exportedFileCount)
        [self exportComplete];
}

- (void)restClient:(DBRestClient*)client uploadProgress:(CGFloat)progress 
           forFile:(NSString*)destPath from:(NSString*)srcPath
{
    // progress based on file count
    progressHud.progress = (progress + uploadedFileCount) / exportedFileCount;
	progressHud.detailsLabelText = [UIUtility formatProgress:progressHud.progress];
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
    // show error
    [self showMessage:NSLocalizedString(@"ExportErrorMessage", @"")];
}

@end
