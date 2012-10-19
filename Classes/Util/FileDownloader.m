//
//  FileDownloader.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FileDownloader.h"

@implementation FileDownloader

- (id)initWithUrl:(NSURL *)url fileName:(NSString *)file delegate:(id<FileDownloaderDelegate>)theDelegate
{
    if (self = [super init])
	{
        downloadUrl = url;
        fileName = file;
        delegate = theDelegate;
	}
	return self;
}

- (void)beginDownload
{
    // downnload file (connection released when finished)
    NSURL *url = [downloadUrl URLByAppendingPathComponent:fileName];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    // start download
    [connection start];
}

#pragma mark -
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // error
    [delegate fileDowloadFailed];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	// init download info
	totalFileSize = [response expectedContentLength];
	downloadData = [[NSMutableData alloc] initWithCapacity:totalFileSize];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	// update data
	[downloadData appendData:data];
	
	// update progress
	float progress = (totalFileSize <= 0) ? 0 : [data length]/totalFileSize;
    [delegate addFileDownloadProgress:progress fileName:fileName];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{	
	// download complete
    [delegate fileDownloadComplete:fileName data:downloadData];
}
@end
