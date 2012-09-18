//
//  SummaryViewController.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/19/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "SummaryViewController.h"
#import "Summary.h"
#import "LogbookHistory.h"
#import "RepositoryManager.h"
#import "UIUtility.h"
#import "Units.h"
#import "TotalJumpCountViewController.h"

@interface SummaryViewController(Private)
- (void)loadData;
- (NSString *)hoursMinutesSecondsString:(int)totalSeconds;
- (NSString *)formatTotalFreefallDistance:(int)totalAltitude unit:(NSString *)unit;
@end

@implementation SummaryViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// set back button
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BackButton", @"") style:UIBarButtonItemStylePlain target:nil action:nil];
	self.navigationItem.backBarButtonItem = backButton;
	
	tableModel = [[TableModel alloc] init];
	[tableModel addSection:@""];
	[tableModel addRowWithSelectMethod:0 cell:totalJumpsCell methodName:@"showTotalJumpsController"];
	[tableModel addRow:0 cell:totalFreefallTimeCell];
	[tableModel addRow:0 cell:totalFreefallDistanceCell];
	[tableModel addRow:0 cell:totalCutawaysCell];
	[tableModel addSection:@""];
	[tableModel addRow:1 cell:maxFreefallTimeCell];
	[tableModel addRow:1 cell:maxExitAltitudeCell];
	[tableModel addRow:1 cell:minDeploymentAltitudeCell];
	[tableModel addSection:@""];
	[tableModel addRow:2 cell:lastJumpCell];
	[tableModel addRow:2 cell:jumpsInYearCell];
	[tableModel addRow:2 cell:jumpsInMonthCell];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	// load data
	[self loadData];
}

- (void)loadData
{
	// get summary & history
    SummaryRepository *summaryRepository = [[RepositoryManager instance] summaryRepository];
	Summary *summary = [summaryRepository summary];
    LogbookHistoryRepository *historyRepository = [[RepositoryManager instance] logbookHistoryRepository];
	LogbookHistory *history = [historyRepository history];
	
	// add up freefall time
	int totalFreefallTime = [summary.totalFreefallTime intValue] + [history.FreefallTime intValue];
	// add up cutaways
	int totalCutaways = [summary.totalCutaways intValue] + [history.Cutaways intValue];
	
	// update UI
	totalJumpsField.text = [UIUtility formatNumber:summary.totalJumps];
	totalFreefallTimeField.text = [self hoursMinutesSecondsString:totalFreefallTime];
	totalFreefallDistanceField.text = [self formatTotalFreefallDistance:[summary.totalFreefallDistance intValue] unit:summary.altitudeUnit];
	totalCutawaysField.text = [UIUtility formatNumber:[NSNumber numberWithInt:totalCutaways]];
	maxFreefallTimeField.text = [UIUtility formatDelay:[summary.maxFreefallTime intValue] estimated:NO];
	maxExitAltitudeField.text = [UIUtility formatAltitude:summary.maxExitAltitude unit:summary.altitudeUnit];
	minDeploymentAltitudeField.text = [UIUtility formatAltitude:summary.minDeploymentAltitude unit:summary.altitudeUnit];
	lastJumpField.text = [UIUtility formatDate:summary.lastJump];
	jumpsInYearField.text = [UIUtility formatNumber:summary.jumpsInLastYear];
	jumpsInMonthField.text = [UIUtility formatNumber:summary.jumpsInLastMonth];
}

- (NSString *)hoursMinutesSecondsString:(int)totalSeconds
{
	int hours = totalSeconds / 3600;
	int secondsLeftFromHours = totalSeconds % 3600;
	int minutes = secondsLeftFromHours / 60;
	int seconds = secondsLeftFromHours % 60;
	
	return [NSString stringWithFormat:NSLocalizedString(@"FreefallTimeFormat", @""), hours, minutes, seconds];
}

- (NSString *)formatTotalFreefallDistance:(int)totalAltitude unit:(NSString *)unit
{
	AltitudeUnit altUnit = [Units stringToAltitudeUnit:unit];
	float totalDistance = [Units convertAltitudeToDistance:totalAltitude unit:altUnit];
	DistanceUnit distUnit = (altUnit == Feet) ? Miles : Kilometers;
	return [UIUtility formatDistance:[NSNumber numberWithFloat:totalDistance] unit:[Units distanceToString:distUnit]];
}

- (void)showTotalJumpsController
{
	TotalJumpCountViewController *controller = [[TotalJumpCountViewController alloc] initController];
	[self.navigationController pushViewController:controller animated:YES];
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [tableModel sectionCount];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [tableModel sectionTitle:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [tableModel rowCount:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [tableModel rowCell:indexPath.section rowIndex:indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// deselect
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	// get method
	NSString *methodName = [tableModel rowMethodName:indexPath.section rowIndex:indexPath.row];
	
	// check if empty
	if ([methodName length] > 0)
	{
		SEL methodSelector = NSSelectorFromString(methodName);
		[self performSelector:methodSelector];
	}
}

@end
