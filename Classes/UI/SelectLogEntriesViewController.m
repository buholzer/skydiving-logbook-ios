//
//  SelectLogEntriesViewController.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/11/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "SelectLogEntriesViewController.h"
#import "LogbookListViewController.h"
#import "SignatureViewController.h"
#import "LogEntry.h"
#import "UIUtility.h"

@interface SelectLogEntriesViewController(Private)
- (void)cancel;
- (void)next;
- (void)updateNextButton;
@end

@implementation SelectLogEntriesViewController

- (id)initWithLogEntries:(NSArray *)theLogEntries
{
	if (self = [super init])
	{
		logEntries = theLogEntries;
		selectedLogEntries = [NSMutableArray arrayWithCapacity:0];
		
		self.hidesBottomBarWhenPushed = YES;
	}
	return self;
}

- (void)viewDidLoad
{
	self.title = NSLocalizedString(@"SelectJumpsTitle", @"");
		
	// add cancel button
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
	self.navigationItem.leftBarButtonItem = cancelButton;
		
	// add next button
	UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"NextButton", @"") style:UIBarButtonItemStyleDone target:self action:@selector(next)];
	self.navigationItem.rightBarButtonItem = nextButton;
	
	// set back button
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BackButton", @"") style:UIBarButtonItemStylePlain target:nil action:nil];
	self.navigationItem.backBarButtonItem = backButton;
	
	// update next button
	[self updateNextButton];
}

- (void)updateNextButton
{
	self.navigationItem.rightBarButtonItem.enabled = [selectedLogEntries count] > 0;
}

- (void)cancel
{
	// return to prev view
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)next
{
	// create/show signature controller
	SignatureViewController *controller = [[SignatureViewController alloc] initWithLogEntries:selectedLogEntries];
	[self.navigationController pushViewController:controller animated:YES];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [logEntries count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// get cell
    static NSString *CellIdentifier = @"LogbookEntryTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
		NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
		cell = [nibs objectAtIndex:0];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
    // get log entry info
	LogEntry *logEntry = [logEntries objectAtIndex:indexPath.row];
	
	// init cell
	[UIUtility initCellWithLogEntry:cell logEntry:logEntry];
	
	// update selection
	cell.accessoryType = [selectedLogEntries containsObject:logEntry] ?
		UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	LogEntry *logEntry = [logEntries objectAtIndex:indexPath.row];
	// select/deselect
	if ([selectedLogEntries containsObject:logEntry])
		[selectedLogEntries removeObject:logEntry];
	else
		[selectedLogEntries addObject:logEntry];
	
	// update next button
	[self updateNextButton];

	// reload table
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return LogEntryCellHeight;
}

@end

