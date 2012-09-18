//
//  SummaryRepository.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 8/31/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Summary.h"

@interface SummaryRepository : NSObject
{
	NSManagedObjectContext *context;
}

- (id)initWithContext:(NSManagedObjectContext *)ctx;
- (Summary *)summary;
- (NSDictionary *)yearlyJumpCount:(int)fromYear toYear:(int)toYear;

@end
