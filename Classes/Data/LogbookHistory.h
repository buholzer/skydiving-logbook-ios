//
//  LogbookHistory.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 4/22/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface LogbookHistory :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * FreefallTime;
@property (nonatomic, retain) NSNumber * Cutaways;

@end



