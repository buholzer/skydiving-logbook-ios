//
//  StartupTask.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 9/24/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
#import "DatabaseImporter.h"

@protocol StartupTaskDelegate<NSObject>
- (void)startupCompleted;
@end

@interface StartupTask : NSObject<DatabaseImportDelegate>
{
	MBProgressHUD *progressHud;

	// startup data
	NSURL *importUrl;
	
	BOOL running;
	BOOL completed;
}

+ (StartupTask *)instance;

- (void)startup:(id<StartupTaskDelegate>)delegate;
- (void)setImportUrl:(NSURL *)importUrl;
- (void)updateProgressText:(NSString *)title detail:(NSString *)detail;

@end
