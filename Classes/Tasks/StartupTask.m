//
//  StartupTask.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 9/24/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "CommonAppDelegate.h"
#import "NotificationManager.h"
#import "StartupTask.h"
#import "RepositoryManager.h"
#import "DatabaseImporter.h"
#import "UIUtility.h"

@interface StartupTask(Private)
- (void)updateReminders:(RigRepository *)repository;
- (void)importData;
@end

@implementation StartupTask

static StartupTask *instance = NULL;

+ (StartupTask *)instance
{
	@synchronized(self)
    {
		if (instance == NULL)
			instance = [[self alloc] init];
	}
	
	return instance;
}

- (void)setImportUrl:(NSURL *)url
{
	importUrl = url;
}

- (void)startup:(id<StartupTaskDelegate>)delegate
{	
	// don't run again if already running or completed
	if (running || completed)
	{
		// notify delegate, exit
		if (delegate)
			[delegate startupCompleted];
		return;
	}
	// set running
	running = YES;
	
	// create/init progress hud
	if (!progressHud)
	{
		CommonAppDelegate *appDelegate = (CommonAppDelegate *)[[UIApplication sharedApplication] delegate];
		UIWindow *mainWindow = [appDelegate mainWindow];
		progressHud = [[MBProgressHUD alloc] initWithView:mainWindow];
		[mainWindow addSubview:progressHud];
	}
	
	// set title and show
	progressHud.labelText = NSLocalizedString(@"Loading", @"");
	[progressHud show:YES];
	
	// execute startup tasks in background thread
	[self performSelectorInBackground:@selector(doStartup:) withObject:delegate];
}

- (void)updateProgressText:(NSString *)title detail:(NSString *)detail
{
	// if no progress hud, exit
	if (!progressHud)
		return;
	
	progressHud.labelText = title;
	progressHud.detailsLabelText = detail;
}

- (void)doStartup:(id<StartupTaskDelegate>)delegate
{
    @autoreleasepool
    {
        // init database (getting a repository will init DB
        // and perform necessary migration)
        [[RepositoryManager instance] logEntryRepository];
	
        // import data (if launched via url)
        [self importData];
    }
	
	// do update reminders on main thread
	[self performSelectorOnMainThread:@selector(doUpdateReminders) withObject:nil waitUntilDone:YES];
	
	// notify delegate on main thread, wait for finish
	[self performSelectorOnMainThread:@selector(doCompleteStartup:) withObject:delegate waitUntilDone:NO];
}

- (void)importData
{
	// skip if no import or not a file
	if (importUrl == nil)
		return;
	if ([importUrl isFileURL] == NO)
		return;
	
	// update progress
	progressHud.mode = MBProgressHUDModeDeterminate;
	progressHud.progress = 0;
	progressHud.labelText = NSLocalizedString(@"ImportDataTitle", @"");
	
	// start db import
	NSData *data = [NSData dataWithContentsOfURL:importUrl];
	DatabaseImporter *importer = [[DatabaseImporter alloc]
								  initWithDelegate:self];
	[importer beginImport:data];
}

- (void)doUpdateReminders
{
	// get app delegate
    [[NotificationManager instance] updateRigReminderBadges];
}

- (void)doCompleteStartup:(id<StartupTaskDelegate>)delegate
{
	// set task flags
	completed = YES;
	running = NO;

	// cleanup hud
	[progressHud hide:YES];
	[progressHud removeFromSuperview];
	progressHud = nil;
	
	// clean up import url
	importUrl = nil;
	
	// notify delegate
	if (delegate)
	{
		[delegate startupCompleted];
	}
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
    // TODO:
}

@end
