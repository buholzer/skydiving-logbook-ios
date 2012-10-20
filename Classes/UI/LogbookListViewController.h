//
//  LogbookListViewController.h
//  SkydiveLogbook
//
//  Created by Tom Cain on 2/19/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StartupTask.h"
#import "LogbookEntryViewController.h"

@interface LogbookListViewController : UITableViewController<StartupTaskDelegate,
                                                            LogEntryViewControllerDelegate,
                                                            UIPageViewControllerDataSource,
                                                            UIPageViewControllerDelegate,
															UIActionSheetDelegate>
{
	NSInteger currentOffset;
	BOOL showLoadMore;
    
    UIPageViewController *currentPageController;
    LogbookEntryViewController *currentLogEntryController;
}

@property (strong) NSMutableArray *logEntries;

@end
