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

@interface SkydiveAppDelegate(Private) <DBSessionDelegate, DBNetworkRequestDelegate>
- (void)registerDropBoxSession;
@end

@implementation SkydiveAppDelegate

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)options
{
	// Override point for customization after app launch 
    
    // register dropbox session
    [self registerDropBoxSession];
	
	// add the tab bar controller's current view
    [window setRootViewController:tabBarController];
	
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
    else
    {
        // update startup task to import url
        [[StartupTask instance] setImportUrl:url];
    }
	
	return NO;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // start startup task
    [[StartupTask instance] startup];
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
    NSString* consumerKey = @"5ilrzrio0u324cq";
	NSString* consumerSecret = @"vngzqzterkjmh63";
	
	DBSession* session = [[DBSession alloc] initWithAppKey:consumerKey appSecret:consumerSecret root:kDBRootAppFolder];
	session.delegate = self; // DBSessionDelegate methods allow you to handle re-authenticating
	[DBSession setSharedSession:session];
	
	[DBRequest setNetworkRequestDelegate:self];
    
    if ([[DBSession sharedSession] isLinked]) {
        NSLog(@"Dropbox session linked.");
    } else {
        NSLog(@"Dropbox session not linked.");
    }
    
}

- (void)sessionDidReceiveAuthorizationFailure:(DBSession *)session userId:(NSString *)userId {
    
    [[[UIAlertView alloc]
      initWithTitle:@"Dropbox" message:@"Authorization failure, reauthorize."
      delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)networkRequestStarted {
    NSLog(@"Dropbox network request started.");
}

- (void)networkRequestStopped {
    NSLog(@"Dropbox network request stopped.");
}

@end

