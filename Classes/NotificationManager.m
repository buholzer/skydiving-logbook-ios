//
//  NotificationManager.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 1/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NotificationManager.h"
#import "RepositoryManager.h"
#import "RigReminderUtil.h"
#import "CommonAppDelegate.h"

@implementation NotificationManager

static NotificationManager *instance = NULL;

+ (NotificationManager *)instance
{
	@synchronized(self)
    {
		if (instance == NULL)
			instance = [[self alloc] init];
	}
	
	return instance;
}

- (void)updateRigReminderBadges
{
	// clear all local notifications
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
	
	// get rigs
    RigRepository *repository = [[RepositoryManager instance] rigRepository];
	NSArray *rigs = [repository loadRigs];
	
	// get due count
	int dueCount = 0;
	for (Rig *rig in rigs)
	{
		for (RigReminder *reminder in rig.Reminders)
		{
			// create due now notification
			NSDate *dueDate = [RigReminderUtil dueDateForReminder:reminder];
			UILocalNotification *dueNotification = [[UILocalNotification alloc] init];
			dueNotification.fireDate = dueDate;
			dueNotification.timeZone = [NSTimeZone defaultTimeZone];
			dueNotification.alertBody = [NSString stringWithFormat:
										 NSLocalizedString(@"DueNowNotification", @""), reminder.Name];
			[[UIApplication sharedApplication] scheduleLocalNotification:dueNotification];
			
			// create due soon notification
			NSDate *dueSoonDate = [RigReminderUtil noticeDateForReminder:reminder];
			UILocalNotification *dueSoonNotification = [[UILocalNotification alloc] init];
			dueSoonNotification.fireDate = dueSoonDate;
			dueSoonNotification.timeZone = [NSTimeZone defaultTimeZone];
			dueSoonNotification.alertBody = [NSString stringWithFormat:
											 NSLocalizedString(@"DueSoonNotification", @""), reminder.Name];
			[[UIApplication sharedApplication] scheduleLocalNotification:dueSoonNotification];
			
			// get due status
			enum DueStatus dueStatus = [RigReminderUtil dueStatusForReminder:reminder];
			if (dueStatus == DueSoon || dueStatus == PastDue)
			{
				dueCount++;
			}
		}
	}
	
	// set app badges
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:dueCount];
    // update badges for gear tab bar item
    CommonAppDelegate *appDelegate = (CommonAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate updateGearBadgeCount:dueCount];
}

@end
