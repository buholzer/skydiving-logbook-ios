//
//  ImportTask.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 5/4/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "ImportTask.h"
#import "DatabaseImporter.h"
#import "URLAlertView.h"
#import "CommonAppDelegate.h"
#import "UIUtility.h"
#import "ImportExportConstants.h"

@interface ImportTask(Private)
- (void)downloadFile:(NSString *)source;
- (void)runDatabaseImport;
- (void)handleImageDownloaded:(NSString *)fileName data:(NSData *)imageData;
- (void)importComplete;
- (void)showSuccess;
- (void)showError;
- (void)showMessage:(NSString *)message;
- (void)showProgress:(NSString *)title;
- (void)dismissProgress;
@end

@implementation ImportTask

- (void)beginImport:(ImportSource)src
{
    // set source
    source = src;
    
    // create importers
    dbImporter = [[DatabaseImporter alloc] initWithDelegate:self];
    // create list
    imagesImportInfo = [NSMutableArray arrayWithCapacity:0];
    
    // get dropbox client
    if (source == ImportFromDropBox && !dropBoxClient)
    {
        dropBoxClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        dropBoxClient.delegate = self;
    }
    
    // if src is url, prompt for url
    if (src == ImportFromUrl)
    {
        URLAlertView *alertView = [[URLAlertView alloc] initWithDelegate:self];
        [alertView show];
    }
    else if (src == ImportFromDropBox)
    {
        // show progress
        [self showProgress:NSLocalizedString(@"DownloadFileTitle", @"")];

        // download from dropbox
        [self downloadFile:XmlFileName];
    }
}

- (void)downloadFile:(NSString *)sourceFile
{
    if (source == ImportFromUrl)
    {
        // downnload file
        FileDownloader *fileDownloader = [[FileDownloader alloc] initWithUrl:downloadUrl fileName:sourceFile delegate:self];
        [fileDownloader beginDownload];
    }
    else if (source == ImportFromDropBox)
    {
        // get download destination
        NSString *downloadDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *downloadDest = [downloadDir stringByAppendingPathComponent:sourceFile];
        
        // get dropbox source
        NSString *downloadSrc = [DropBoxFolderName stringByAppendingPathComponent:sourceFile];
                
        // start download
        [dropBoxClient loadFile:downloadSrc intoPath:downloadDest];
    }
}

- (void)runDatabaseImport:(NSData *)xmlFileData
{
    BOOL success = NO;
    @autoreleasepool
    {
        // update progress
        progressHud.progress = 0;
        progressHud.labelText = NSLocalizedString(@"ImportDataTitle", @"");
        progressHud.detailsLabelText = [UIUtility formatProgress:progressHud.progress];
        	
        // run db importer
        success = [dbImporter beginImport:xmlFileData];
    }
    
    // if not successfull, show error
    if (!success)
    {
        [self performSelectorOnMainThread:@selector(showError) withObject:nil waitUntilDone:NO];
        return;
    }
    
    // otherwise, start image import
    [self performSelectorOnMainThread:@selector(beginImageImport) withObject:nil waitUntilDone:NO];
}

- (void)beginImageImport
{
    // if no images, show success
    if ([imagesImportInfo count] <= 0)
    {
        [self importComplete];
        return;
    }
    
    // update progress
    downloadedImageFileCount = 0;
    imageFileCount = [imagesImportInfo count];
    progressHud.progress = 0;
    progressHud.labelText = NSLocalizedString(@"DownloadImagesTitle", @"");
    progressHud.detailsLabelText = [UIUtility formatProgress:progressHud.progress];
    
    // start downloading images
    for (ImageImportInfo *importInfo in imagesImportInfo)
    {
        [self downloadFile:importInfo.imageFileName];
    }
}

- (void)handleImageDownloaded:(NSString *)fileName data:(NSData *)imageData;
{
    // increment file count
    downloadedImageFileCount++;
        
    // process image import info
    BOOL allImagesReady = YES;
    for (ImageImportInfo *importInfo in imagesImportInfo)
    {
        // update corresponding image import info
        if ([importInfo.imageFileName isEqualToString:fileName])
        {
            importInfo.image = [UIImage imageWithData:imageData];
        }
        
        // check if images ready
        if (!importInfo.image)
            allImagesReady = NO;
    }
    
    // if all images ready
    if (allImagesReady)
    {
        // import images
        [dbImporter importImages:imagesImportInfo];
        
        // import complete
        [self importComplete];
    }
}

- (void)importComplete
{
    // show success
    [self showSuccess];
    
    // get download dir
    NSString *downloadDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    // cleanup all exported files
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    // xml/csv
    [fileManager removeItemAtPath:[downloadDir stringByAppendingPathComponent:XmlFileName] error:&error];
    // images
    for (ImageImportInfo *imageImportInfo in imagesImportInfo)
    {
        [fileManager removeItemAtPath:[downloadDir stringByAppendingPathComponent:imageImportInfo.imageFileName] error:&error];
    }
}

- (void)showSuccess
{
    // cleanup hud
    [self dismissProgress];
    // show success
    [self showMessage:NSLocalizedString(@"ImportSuccessMessage", @"")];
}

- (void)showError
{
    // cleanup hud
    [self dismissProgress];
    // show error
    [self showMessage:NSLocalizedString(@"ImportErrorMessage", @"")];
}

- (void)showMessage:(NSString *)message
{
    // dismiss progress
    [self dismissProgress];
    // show message
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
#pragma mark - URLAlertViewDelegate

- (void)urlSelected:(NSURL *)url
{
    // show progress
    [self showProgress:NSLocalizedString(@"DownloadFileTitle", @"")];
    
    // set url
    downloadUrl = url;
    
    // download Xml file
    [self downloadFile:XmlFileName];
}

#pragma mark -
#pragma mark FileDownloaderDelegate
- (void)fileDownloadComplete:(NSString *)fileName data:(NSData *)data;
{
    if ([fileName isEqualToString:XmlFileName])
    {
        // if XML file, start import
        [self performSelectorInBackground:@selector(runDatabaseImport) withObject:data];
    }
    else
    {
        // must be an image file, process it
        [self handleImageDownloaded:fileName data:data];
    }
}

- (void)addFileDownloadProgress:(float)progress fileName:(NSString *)fileName;
{
    // update progress
    if ([fileName isEqualToString:XmlFileName])
    {
        // first download is just for XML
        progressHud.progress += progress;
    }
    else
    {
        // must be image, update progress
        progressHud.progress = (progress + downloadedImageFileCount) / imageFileCount;
    }
    
    // update details label
    progressHud.detailsLabelText = [UIUtility formatProgress:progressHud.progress];
}

- (void)fileDowloadFailed
{
    // show error
    [self showError];
}

#pragma mark -
#pragma mark DBRestClientDelegate
- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error
{
    // show error
    [self showError];
}

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)destPath
{
    // get file name
    NSString *fileName = [destPath lastPathComponent];
    
    // get file data
    NSString *downloadDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [downloadDir stringByAppendingPathComponent:XmlFileName];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    
    if ([fileName isEqualToString:XmlFileName])
    {
        // if XML file, start import
        [self performSelectorInBackground:@selector(runDatabaseImport:) withObject:fileData];
    }
    else
    {
        // must be an image file, process it
        [self handleImageDownloaded:fileName data:fileData];
    }
}

- (void)restClient:(DBRestClient*)client loadProgress:(CGFloat)progress forFile:(NSString*)destPath
{
    // get file name
    NSString *fileName = [destPath lastPathComponent];

    // update progress
    if ([fileName isEqualToString:XmlFileName])
    {
        // first download is just for XML
        progressHud.progress += progress;
    }
    else
    {
        // must be image, update progress
        progressHud.progress = (progress + downloadedImageFileCount) / imageFileCount;
    }
    
    // update details label
    progressHud.detailsLabelText = [UIUtility formatProgress:progressHud.progress];
}

#pragma mark -
#pragma mark DatabaseImportDelegate

- (void)addDatabaseImportProgress:(float)progress
{
	progressHud.progress += progress;
	progressHud.detailsLabelText = [UIUtility formatProgress:progressHud.progress];
}

- (void)addImageImport:(ImageImportInfo *)imageImportInfo
{
    // add to list
    [imagesImportInfo addObject:imageImportInfo];
}

@end
