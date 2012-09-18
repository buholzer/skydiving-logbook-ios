//
//  RigReminderUtil.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/1/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RigReminder.h"
#import "Units.h"
#import "Rig.h"

enum DueStatus
{
	NotDue = 0,
	DueSoon = 1,
	PastDue = 2
} DueStatus;


@interface RigReminderUtil : NSObject
{

}

+ (NSDate *)dueDate:(NSDate *)lastDate interval:(NSInteger)interval intervalUnit:(enum TimeIntervalUnit)intervalUnit;
+ (NSDate *)noticeDate:(NSDate *)lastDate interval:(NSInteger)interval intervalUnit:(enum TimeIntervalUnit)intervalUnit;
+ (enum DueStatus)dueStatus:(NSDate *)lastDate interval:(NSInteger)interval intervalUnit:(enum TimeIntervalUnit)intervalUnit;
+ (NSDate *)dueDateForReminder:(RigReminder *)reminder;
+ (NSDate *)noticeDateForReminder:(RigReminder *)reminder;
+ (enum DueStatus)dueStatusForReminder:(RigReminder *)reminder;
+ (enum DueStatus)dueStatusForRig:(Rig *)rig;
@end
