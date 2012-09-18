//
//  LogEntryImageImportInfo.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogEntry.h"

@interface ImageImportInfo : NSObject

@property (strong) NSString *logEntryUniqueId;
@property (strong) NSString *imageType;
@property (strong) NSString *imageMD5;
@property (strong) NSString *imageFileName;
@property (strong) UIImage *image;
@end
