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
    
    // delegates
    NSMutableArray *delegates;
	
	BOOL running;
    BOOL needsToRun;
}

+ (StartupTask *)instance;

- (void)startup;
- (BOOL)isCompleted;
- (void)setImportUrl:(NSURL *)importUrl;
- (void)addDelegate:(id<StartupTaskDelegate>)delegate;
- (void)removeDelegate:(id<StartupTaskDelegate>)delegate;
- (void)updateProgressText:(NSString *)title detail:(NSString *)detail;

@end
