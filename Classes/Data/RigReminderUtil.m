//
//  RigReminderUtil.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/1/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "RigReminderUtil.h"

static NSTimeInterval SecondsInADay = 86400;
static NSTimeInterval SecondsInAWeek = 604800;
static NSTimeInterval SecondsInAMonth = 2592000;
static NSTimeInterval SecondsInAYear = 31536000;

@implementation RigReminderUtil

+ (NSDate *)dueDate:(NSDate *)lastDate interval:(NSInteger)interval intervalUnit:(enum TimeIntervalUnit)intervalUnit
{
	NSTimeInterval seconds = 0;
	switch (intervalUnit)
	{
		case Days:
			seconds = interval * SecondsInADay;
			break;
		case Months:
			seconds = interval * SecondsInAMonth;
			break;
		case Years:
			seconds = interval * SecondsInAYear;
			break;
	}
	
	// convert to 8am, stuff is always due at 8am
	NSDate *dueDate = [lastDate dateByAddingTimeInterval:seconds];
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
												fromDate:dueDate];
	
	[components setHour:8];
	[components setMinute:0];
	[components setSecond:0];
	
	return [calendar dateFromComponents:components];
}

+ (NSDate *)noticeDate:(NSDate *)lastDate interval:(NSInteger)interval intervalUnit:(enum TimeIntervalUnit)intervalUnit
{
	NSDate *dueDate = [self dueDate:lastDate interval:interval intervalUnit:intervalUnit];
	return [dueDate dateByAddingTimeInterval:-1 * SecondsInAWeek];
}

+ (NSDate *)dueDateForReminder:(RigReminder *)reminder
{
	return [self dueDate:reminder.LastCompletedDate
				interval:[reminder.Interval intValue]
			intervalUnit:[Units stringToTimeIntervalUnit:reminder.IntervalUnit]];
}

+ (NSDate *)noticeDateForReminder:(RigReminder *)reminder
{
	return [self noticeDate:reminder.LastCompletedDate
				   interval:[reminder.Interval intValue]
			   intervalUnit:[Units stringToTimeIntervalUnit:reminder.IntervalUnit]];
}

+ (enum DueStatus)dueStatus:(NSDate *)lastDate interval:(NSInteger)interval intervalUnit:(enum TimeIntervalUnit)intervalUnit
{
	NSDate *dueDate = [self dueDate:lastDate interval:interval intervalUnit:intervalUnit];
	NSDate *noticeDate = [self noticeDate:lastDate interval:interval intervalUnit:intervalUnit];
	NSDate *now = [NSDate date];
	
	NSComparisonResult noticeResult = [now compare:noticeDate];
	NSComparisonResult dueResult = [now compare:dueDate];
	
	if (noticeResult < 0)
	{
		return NotDue;
	}
	else if (noticeResult >= 0 && dueResult < 0)
	{
		return DueSoon;
	}
	else
	{
		return PastDue;
	}
}

+ (enum DueStatus)dueStatusForReminder:(RigReminder *)reminder
{
	return [self dueStatus:reminder.LastCompletedDate
				  interval:[reminder.Interval intValue]
			  intervalUnit:[Units stringToTimeIntervalUnit:reminder.IntervalUnit]];
}

+ (enum DueStatus)dueStatusForRig:(Rig *)rig
{
	enum DueStatus dueStatus = NotDue;
	enum DueStatus reminderStatus = NotDue;
	for (RigReminder *reminder in rig.Reminders)
	{
		reminderStatus = [self dueStatusForReminder:reminder];
		if (dueStatus < reminderStatus)
		{
			dueStatus = reminderStatus;
		}
	}
	return dueStatus;
}

@end
