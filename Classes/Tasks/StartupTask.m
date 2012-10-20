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

- (id)init
{
    if (self = [super init])
	{
        needsToRun = TRUE;
        running = FALSE;
	}
	
	return self;
}

- (void)setImportUrl:(NSURL *)url
{
	importUrl = url;
    needsToRun = TRUE;
}

- (void)addDelegate:(id<StartupTaskDelegate>)delegate
{
    if (!delegates)
    {
        delegates = [[NSMutableArray alloc] initWithCapacity:1];
    }
    [delegates addObject:delegate];
}

- (void)removeDelegate:(id<StartupTaskDelegate>)delegate
{
    if (!delegates)
        return;
    [delegates removeObject:delegate];
}

- (BOOL)isCompleted
{
    return !running && !needsToRun;
}

- (void)startup
{	
	// don't run if running or doesn't need to
	if (running || !needsToRun)
	{
		// notify delegates, exit
        [self notifyDelegates];
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
	[self performSelectorInBackground:@selector(doStartup) withObject:nil];
}

- (void)updateProgressText:(NSString *)title detail:(NSString *)detail
{
	// if no progress hud, exit
	if (!progressHud)
		return;
	
	progressHud.labelText = title;
	progressHud.detailsLabelText = detail;
}

- (void)doStartup
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
	[self performSelectorOnMainThread:@selector(doCompleteStartup) withObject:nil waitUntilDone:NO];
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

- (void)doCompleteStartup
{
	// set task flags
    needsToRun = FALSE;
	running = FALSE;

	// cleanup hud
	[progressHud hide:YES];
	[progressHud removeFromSuperview];
	progressHud = nil;
	
	// clean up import url
	importUrl = nil;
	
	// notify delegates
    [self notifyDelegates];
}

- (void)notifyDelegates
{
    if (!delegates)
        return;
    
    for (id<StartupTaskDelegate> delegate in delegates)
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
