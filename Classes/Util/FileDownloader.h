//
//  FileDownloader.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FileDownloaderDelegate<NSObject>
- (void)fileDownloadComplete:(NSString *)fileName;
- (void)addFileDownloadProgress:(float)progress fileName:(NSString *)fileName;
- (void)fileDowloadFailed;
@end

@interface FileDownloader : NSObject<NSURLConnectionDelegate>
{
    // download info
    NSURL *downloadUrl;
    NSString *fileName;

    // download data
    NSMutableData *downloadData;
	float totalFileSize;
    
    // delegate
    id<FileDownloaderDelegate> delegate;
}

- (id)initWithUrl:(NSURL *)url fileName:(NSString *)file delegate:(id<FileDownloaderDelegate>)theDelegate;
- (void)beginDownload;

@end
