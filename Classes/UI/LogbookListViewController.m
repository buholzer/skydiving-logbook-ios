//
//  LogbookListViewController.m
//  SkydiveLogbook
//
//  Created by Tom Cain on 2/19/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "LogbookListViewController.h"
#import "RepositoryManager.h"
#import "LogbookEntryViewController.h"
#import "SelectLogEntriesViewController.h"
#import "LogEntry.h"
#import "UIUtility.h"

// constants
static NSInteger MaxRows = 500;
static NSInteger LoadMoreCellHeight = 54;
static NSInteger SignIndex = 0;
static NSInteger CopyLastIndex = 1;

// private interface
@interface LogbookListViewController(Private)
- (void)addLogEntry;
- (void)resetData;
- (void)loadDataPage;
- (void)showMoreActions;
- (void)signLogbook;
- (void)copyLast;
- (UIViewController *)getPreviousLogEntryController;
- (UIViewController *)getNextLogEntryController;
- (UIBarButtonItem *)createPreviousNextControl;
- (UIPageViewController *)createPageViewController;
- (void)logEntryPageChanged;
- (void)showLogEntryViewController:(LogEntry *)logEntry isNew:(BOOL)isNew;
@end

@implementation LogbookListViewController

@synthesize logEntries;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// add add button
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addLogEntry)];
	self.navigationItem.rightBarButtonItem = addButton;
	
	// add more button
	UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"MoreButton", @"") style:UIBarButtonItemStylePlain target:self action:@selector(showMoreActions)];
	self.navigationItem.leftBarButtonItem = moreButton;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	// reset data
	[self resetData];
	
	// run startup task
	[[StartupTask instance] startup:self];
}

- (void)resetData
{
	self.logEntries = nil;
	currentOffset = 0;
}

- (void)loadDataPage
{	
	// create array if necessary
	if (logEntries == nil)
	{
		self.logEntries = [NSMutableArray arrayWithCapacity:0];
		currentOffset  = 0;
	}
	
	// get data
    LogEntryRepository *repository = [[RepositoryManager instance] logEntryRepository];
	NSArray *entries = [repository loadLogEntries:currentOffset maxRows:MaxRows];
	currentOffset += [entries count];
	showLoadMore = ([entries count] == MaxRows);
	
	// add to array
	[logEntries addObjectsFromArray:entries];

	// reload table
	[self.tableView reloadData];
}

- (void)addLogEntry
{
	// create new 
    LogEntryRepository *repository = [[RepositoryManager instance] logEntryRepository];
	LogEntry *logEntry = [repository createWithDefaults];
	
	// set default location
    LocationRepository *locationRepository = [[RepositoryManager instance] locationRepository];
	logEntry.Location = [locationRepository homeLocation];
    // set default aircraft
    AircraftRepository *aircraftRepository = [[RepositoryManager instance] aircraftRepository];
    logEntry.Aircraft = [aircraftRepository defaultAircraft];
    // set default skydive type
    SkydiveTypeRepository *skydiveTypeRepository = [[RepositoryManager instance] skydiveTypeRepository];
    logEntry.SkydiveType = [skydiveTypeRepository defaultSkydiveType];
    // set default rigs
    RigRepository *rigRepository = [[RepositoryManager instance] rigRepository];
	NSArray *rigs = [rigRepository primaryRigs];
    for (Rig *rig in rigs)
    {
        [logEntry addRigsObject:rig]; 
    }
	
	[self showLogEntryViewController:logEntry isNew:YES];
}

- (void)showMoreActions
{
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"CancelButton", @"")
										 destructiveButtonTitle:nil
											  otherButtonTitles:NSLocalizedString(@"SignButton", @""),
																NSLocalizedString(@"CopyLastButton", @""),
																nil];
	sheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [sheet showInView:self.parentViewController.tabBarController.view];
}

- (void)signLogbook
{
	// create/show controller
	SelectLogEntriesViewController *controller = [[SelectLogEntriesViewController alloc] initWithLogEntries:logEntries];
	[self.navigationController pushViewController:controller animated:YES];
}

- (void)copyLast
{
	// create new 
    LogEntryRepository *repository = [[RepositoryManager instance] logEntryRepository];
	LogEntry *logEntry = [repository createFromLast];
	
	[self showLogEntryViewController:logEntry isNew:YES];
}

- (void)showLogEntryViewController:(LogEntry *)logEntry isNew:(BOOL)isNew
{
    // create/init current log entry controller
    currentLogEntryController = [[LogbookEntryViewController alloc] initWithLogEntry:logEntry isNew:isNew delegate:self];
    
    // create/init current page controller
    currentPageController = [self createPageViewController];
    // set title
    currentPageController.title = [NSString stringWithFormat:NSLocalizedString(@"LogEntryInfoTitle", @""), 
                            [UIUtility formatNumber:logEntry.JumpNumber]];
    
    // set done button on page controller
    UIBarButtonItem *logEntryDoneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(logEntryDone)];
    currentPageController.navigationItem.leftBarButtonItem = logEntryDoneButton;
    
    if (isNew)
    {
        // if new, create Cancel button
        currentPageController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(logEntryCancelled)];
    }
    else
    {
        // otherwise, create prev/next buttons
        currentPageController.navigationItem.rightBarButtonItem = [self createPreviousNextControl];
    }
    
    // initialize page controller with log entry controller
    [currentPageController setViewControllers:[NSArray arrayWithObject:currentLogEntryController] direction:UIPageViewControllerNavigationOrientationHorizontal animated:YES completion:^(BOOL finished) {}];
    
	// show page controller
    [self.navigationController pushViewController:currentPageController animated:YES];
}

- (void)logEntryDone
{
    // save current
    [currentLogEntryController save];
    
    // reset current
    currentPageController = nil;
    currentLogEntryController = nil;
    
    // pop page controller
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)logEntryCancelled
{
    // rollback any changes
    LogEntryRepository *repository = [[RepositoryManager instance] logEntryRepository];
	[repository rollback];
    
	// pop page controller
	[self.navigationController popViewControllerAnimated:YES];
}

- (UIViewController *)getPreviousLogEntryController
{
    // get current jump number
    LogEntry *logEntry = [currentLogEntryController getLogEntry];
    NSInteger jumpNumber = [logEntry.JumpNumber intValue];
    
    // get previous log entry
    LogEntryRepository *repository = [[RepositoryManager instance] logEntryRepository];
    LogEntry *prevLogEntry = [repository getPreviousLogEntry:jumpNumber];
    
    // if previous exists
    if (prevLogEntry)
    {
        // return new log entry controller
        return [[LogbookEntryViewController alloc] initWithLogEntry:prevLogEntry isNew:FALSE delegate:self];
    }
    
    return nil;
}

- (UIViewController *)getNextLogEntryController
{
    // get jump number
    LogEntry *logEntry = [currentLogEntryController getLogEntry];
    NSInteger jumpNumber = [logEntry.JumpNumber intValue];
    
    // get next log entry
    LogEntryRepository *repository = [[RepositoryManager instance] logEntryRepository];
    LogEntry *nextLogEntry = [repository getNextLogEntry:jumpNumber];
    
    // if next exists
    if (nextLogEntry)
    {
        // return new log entry controller
        return [[LogbookEntryViewController alloc] initWithLogEntry:nextLogEntry isNew:FALSE delegate:self];
    }
    
    return nil;
}

- (void)logEntryPageChanged
{
    // set current log entry controller
    currentLogEntryController = [currentPageController.viewControllers objectAtIndex:0];
    LogEntry *logEntry = [currentLogEntryController getLogEntry];
    
    // update title
    currentPageController.title = [NSString stringWithFormat:NSLocalizedString(@"LogEntryInfoTitle", @""), 
                                [UIUtility formatNumber:logEntry.JumpNumber]];
    
    // set previous/next buttons
    currentPageController.navigationItem.rightBarButtonItem = [self createPreviousNextControl];
}

- (void)previousNextSegmentHandler:(id)sender
{
	// The segmented control was clicked, handle it here 
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    UIViewController *logEntryController = nil;
    NSInteger direction = UIPageViewControllerNavigationDirectionForward;
    
    // save current
    [currentLogEntryController save];
    
    if (segmentedControl.selectedSegmentIndex == 0)
    {
        // get previous
        logEntryController = [self getPreviousLogEntryController];
        direction = UIPageViewControllerNavigationDirectionReverse;
    }
    else
    {
        // get next
        logEntryController = [self getNextLogEntryController];
        direction = UIPageViewControllerNavigationDirectionForward;
    }
    
    // if log entry
    if (logEntryController)
    {
        // move to log entry controller
        __block LogbookListViewController *blocksafeSelf = self;
        [currentPageController setViewControllers:[NSArray arrayWithObject:logEntryController] direction:direction animated:YES completion:^(BOOL finished)
         {
             [blocksafeSelf logEntryPageChanged];
         }];
    }
}

- (UIPageViewController *)createPageViewController
{
    // create/init current page controller
    UIPageViewController *controller = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    controller.hidesBottomBarWhenPushed = YES;
    controller.dataSource = self;
    controller.delegate = self;
    
    // set self as gesture delegate to intercept/cancel "tap" gesture
    NSArray *gestures = controller.gestureRecognizers;
    for (UIGestureRecognizer *gesture in gestures)
    {
        gesture.delegate = self;
    }
    
    return controller;
}

- (UIBarButtonItem *)createPreviousNextControl
{
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
                                            [NSArray arrayWithObjects:
                                             [UIImage imageNamed:@"previous.png"],
                                             [UIImage imageNamed:@"next.png"],
                                             nil]];
    segmentedControl.frame = CGRectMake(0, 0, 90, 30.0);
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.momentary = YES;
    segmentedControl.tintColor = [UIColor darkGrayColor];
    [segmentedControl addTarget:self action:@selector(previousNextSegmentHandler:) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    
    return segmentBarItem;
}

#pragma mark -
#pragma mark StartupTaskDelegate

- (void)startupCompleted
{
	[self loadDataPage];
}

#pragma mark -
#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == SignIndex)
		[self signLogbook];
	else if (buttonIndex == CopyLastIndex)
		[self copyLast];
}

#pragma mark -
#pragma mark UIGestureRecognizerDelegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // intercept tap gesture of UIPageViewController
    // since it interferes with the toolbar buttons
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
    {
        return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark LogEntryViewControllerDelegate

- (void)jumpNumberChanged:(NSNumber *)jumpNumber
{
    // update page controller's title
    currentPageController.title = [NSString stringWithFormat:NSLocalizedString(@"LogEntryInfoTitle", @""), 
                                [UIUtility formatNumber:jumpNumber]];
}
- (void)logEntryDeleted
{
    // pop page conroller
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    // save current
    [currentLogEntryController save];
    
    return [self getPreviousLogEntryController];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    // save current
    [currentLogEntryController save];
    
    return [self getNextLogEntryController];
}

#pragma mark -
#pragma mark UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    [self logEntryPageChanged];
}

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    // not really used
    return UIPageViewControllerSpineLocationMid;
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (showLoadMore)
		return [logEntries count] + 1;
	else
		return [logEntries count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (showLoadMore && [logEntries count] == indexPath.row)
	{
		// get cell
		static NSString *LoadMoreCellId = @"LoadMoreTableCell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellId];
		if (cell == nil)
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellId];
			cell.textLabel.text = NSLocalizedString(@"LoadMore", @"");
			cell.textLabel.textColor = [UIColor blueColor];
		}
		return cell;
	}
	else
	{
		// get cell
		static NSString *EntryCellId = @"LogbookEntryTableCell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:EntryCellId];
		if (cell == nil)
		{
			NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:EntryCellId owner:self options:nil];
			cell = [nibs objectAtIndex:0];
		}
	
		// get entry, init cell
		LogEntry *logEntry = [logEntries objectAtIndex:indexPath.row];
		[UIUtility initCellWithLogEntry:cell logEntry:logEntry];

		return cell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (showLoadMore && [logEntries count] == indexPath.row)
	{
		[self loadDataPage];
	}
	else
	{
		// get log entry, show controller
		LogEntry *logEntry = [logEntries objectAtIndex:indexPath.row];
		[self showLogEntryViewController:logEntry isNew:NO];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (showLoadMore && [logEntries count] == indexPath.row)
	{
		return LoadMoreCellHeight;
	}
	else
	{
		// get cell
		UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
		return [UIUtility logEntryCellHeight:cell];
	}
}

@end

