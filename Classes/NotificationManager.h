//
//  NotificationManager.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 1/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationManager : NSObject

+ (NotificationManager *)instance;
- (void)updateRigReminderBadges;

@end
