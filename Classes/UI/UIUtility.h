//
//  UIUtility.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/23/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RigReminderUtil.h"
#import "Units.h"
#import "LogEntry.h"
#import "Location.h"
#import "Aircraft.h"
#import "SkydiveType.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface UIUtility : NSObject
{
}

+(BOOL)isiPad;
+(NSString *)formatDate:(NSDate *)date;
+(NSString *)formatNumber:(NSNumber *)number;
+(NSString *)formatAltitude:(NSNumber *)altitude unit:(NSString *)unit;
+(NSString *)formatDistance:(NSNumber *)distance unit:(NSString *)unit;
+(NSString *)formatProgress:(float)progress;
+(NSString *)formatDelay:(int)delay estimated:(BOOL)estimated;
+(BOOL)numbersAreEqual:(NSNumber *)num1 num2:(NSNumber *)num2;
+(BOOL)stringsAreEqual:(NSString *)str1 str2:(NSString *)str2;
+(UIColor *)colorForDueStatus:(enum DueStatus)status;
+(UIImage *)imageForDueStatus:(enum DueStatus)status;
+(void)initCellWithLogEntry:(UITableViewCell *)cell logEntry:(LogEntry *)logEntry;
@end
