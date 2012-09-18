//
//  RigReminder.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/26/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Rig;

@interface RigReminder :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDate * LastCompletedDate;
@property (nonatomic, retain) NSString * Name;
@property (nonatomic, retain) NSNumber * Interval;
@property (nonatomic, retain) NSString * IntervalUnit;
@property (nonatomic, retain) Rig * Rig;

@end



