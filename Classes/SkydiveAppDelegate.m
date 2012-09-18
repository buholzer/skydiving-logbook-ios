//
//  skydiveapp_4_iphoneAppDelegate.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/19/10.
//  Copyright NA 2010. All rights reserved.
//

#import "SkydiveAppDelegate.h"
#import "RepositoryManager.h"
#import "RigReminderUtil.h"
#import "UIUtility.h"
#import "StartupTask.h"
#import "ImportExportViewController.h"

static NSInteger GearTabIndex = 2;

@interface SkydiveAppDelegate(Private)
- (void)registerDropBoxSession;
@end

@implementation SkydiveAppDelegate

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)options
{
	// Override point for customization after app launch 
    
	// update startup task to import url
	NSURL *importUrl = (NSURL *)[options valueForKey:UIApplicationLaunchOptionsURLKey];
	[[StartupTask instance] setImportUrl:importUrl];
    
    // register dropbox session
    [self registerDropBoxSession];
	
	// add the tab bar controller's current view
	[window addSubview:tabBarController.view];
	
	// set more nav bar style
	tabBarController.moreNavigationController.navigationBar.barStyle = UIBarStyleBlack;
	tabBarController.customizableViewControllers = nil;
	
	[window makeKeyAndVisible];
	
	return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;
{
	if ([[DBSession sharedSession] handleOpenURL:url])
    {
        // post authentication notification
        [[NSNotificationCenter defaultCenter] postNotificationName:DropBoxAuthenticationNotification object:nil];
		return YES;
	}
	
	return NO;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

- (UIWindow *)mainWindow
{
	return window;
}

- (void)updateGearBadgeCount:(int)count
{
    // set badges
	UITabBarItem *gearTab = [tabBarController.tabBar.items objectAtIndex:GearTabIndex];
	gearTab.badgeValue = count == 0 ? nil : [UIUtility formatNumber:[NSNumber numberWithInt:count]];
}

- (void)registerDropBoxSession
{
    // Set these variables before launching the app
    NSString* consumerKey = @"fcumyczh0enwngw";
	NSString* consumerSecret = @"qth1zfxdfqwr3tw";
	
    DBSession* session = [[DBSession alloc] initWithAppKey:consumerKey appSecret:consumerSecret root:kDBRootDropbox];
	[DBSession setSharedSession:session];
}

@end

