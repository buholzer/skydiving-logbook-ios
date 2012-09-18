//
//  SelectLogEntriesViewController.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/11/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectLogEntriesViewController : UITableViewController
{
	NSArray *logEntries;
	NSMutableArray *selectedLogEntries;
}

- (id)initWithLogEntries:(NSArray *)theLogEntries;

@end
