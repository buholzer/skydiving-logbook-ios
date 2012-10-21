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

extern CGFloat const LogEntryCellHeight;

@interface LogbookListViewController : UITableViewController<StartupTaskDelegate,
                                                            LogEntryViewControllerDelegate,
                                                            UIPageViewControllerDataSource,
                                                            UIPageViewControllerDelegate,
															UIActionSheetDelegate>
{
    UIPageViewController *currentPageController;
    LogbookEntryViewController *currentLogEntryController;
}

@property (strong) NSArray *logEntries;

@end
