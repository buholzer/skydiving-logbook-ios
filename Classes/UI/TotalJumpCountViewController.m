//
//  TotalsViewController.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 4/28/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "TotalJumpCountViewController.h"
#import "RepositoryManager.h"
#import "UIUtility.h"
#import "SkydiveType.h"
#import "NameValueCell.h"

@implementation KeyValuePair
@synthesize key, value;
+ (KeyValuePair *)pairWithKey:(NSString *)theKey andValue:(NSString *)theValue
{
	KeyValuePair *pair = [[KeyValuePair alloc] init];
	pair.key = theKey;
	pair.value = theValue;
	return pair;
}
@end

@implementation KeyValueArray
@synthesize name, keyValues;
+ (KeyValueArray *)arrayWithName:(NSString *)theName
{
	KeyValueArray *kvArray = [[KeyValueArray alloc] init];
	kvArray.name = theName;
	kvArray.keyValues = [NSMutableArray arrayWithCapacity:0];
	return kvArray;
}
@end

@implementation TotalJumpCountViewController

- (id)initController
{
	if (self = [super init])
	{
		self.hidesBottomBarWhenPushed = YES;
	}
	return self;
}

- (void)viewDidLoad
{
	self.title = NSLocalizedString(@"TotalJumpCountTitle", @"");
	
	// set table style
	self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
	
	// create data array
	data = [NSMutableArray arrayWithCapacity:0];
		
	// get locations
	NSArray *locations = [[[RepositoryManager instance] locationRepository] loadEntities];
	KeyValueArray *locationData = [KeyValueArray arrayWithName:NSLocalizedString(@"PerLocation", @"")];
	for (Location *location in locations)
	{
		int count = [location.LogEntries count];
		if (count > 0)
		{
			NSString *countStr = [UIUtility formatNumber:[NSNumber numberWithInt:count]];
			KeyValuePair *pair = [KeyValuePair pairWithKey:location.Name andValue:countStr];
			[locationData.keyValues addObject:pair];
		}
	}
	[data addObject:locationData];
	
	// get aircrafts
	NSArray *aircrafts = [[[RepositoryManager instance] aircraftRepository] loadEntities];
	KeyValueArray *aircraftData = [KeyValueArray arrayWithName:NSLocalizedString(@"PerAircraft", @"")];
	for (Aircraft *aircraft in aircrafts)
	{
		int count = [aircraft.LogEntries count];
		if (count > 0)
		{
			NSString *countStr = [UIUtility formatNumber:[NSNumber numberWithInt:count]];
			KeyValuePair *pair = [KeyValuePair pairWithKey:aircraft.Name andValue:countStr];
			[aircraftData.keyValues addObject:pair];
		}
	}
	[data addObject:aircraftData];
	
	// get rigs
	NSArray *rigs = [[[RepositoryManager instance] rigRepository] loadEntities];
	KeyValueArray *rigData = [KeyValueArray arrayWithName:NSLocalizedString(@"PerRig", @"")];
	for (Rig *rig in rigs)
	{
		int count = [rig.LogEntries count];
		if (count > 0)
		{
			NSString *countStr = [UIUtility formatNumber:[NSNumber numberWithInt:count]];
			KeyValuePair *pair = [KeyValuePair pairWithKey:rig.Name andValue:countStr];
			[rigData.keyValues addObject:pair];
		}
	}
	[data addObject:rigData];
	
	// get skydive types
	NSArray *skydiveTypes = [[[RepositoryManager instance] skydiveTypeRepository] loadEntities];
	KeyValueArray *skydiveTypeData = [KeyValueArray arrayWithName:NSLocalizedString(@"PerSkydiveType", @"")];
	for (SkydiveType *skydiveType in skydiveTypes)
	{
		int count = [skydiveType.LogEntries count];
		if (count > 0)
		{
			NSString *countStr = [UIUtility formatNumber:[NSNumber numberWithInt:count]];
			KeyValuePair *pair = [KeyValuePair pairWithKey:skydiveType.Name andValue:countStr];
			[skydiveTypeData.keyValues addObject:pair];
		}
	}
	[data addObject:skydiveTypeData];
	
	// get year-range
	NSCalendar *calendar = [NSCalendar currentCalendar];
	int toYear = [[calendar components:NSYearCalendarUnit fromDate:[NSDate date]] year];
	int fromYear = toYear - 30;
	// get years
	NSDictionary *yearlyJumpCounts = [[[RepositoryManager instance] summaryRepository] yearlyJumpCount:fromYear toYear:toYear];
	KeyValueArray *yearlyData = [KeyValueArray arrayWithName:@"Per Year"];
	for (int year = toYear; year >= fromYear; year--)
	{
		NSString *yearKey = [[NSNumber numberWithInt:year] stringValue];
		NSNumber *countNum = [yearlyJumpCounts valueForKey:yearKey]; 
		int count = [countNum intValue];
		if (count > 0)
		{
			NSString *countStr = [UIUtility formatNumber:countNum];
			KeyValuePair *pair = [KeyValuePair pairWithKey:yearKey andValue:countStr];
			[yearlyData.keyValues addObject:pair];
		}
	}
	[data addObject:yearlyData];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [data count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	KeyValueArray *kvArray = (KeyValueArray*)[data objectAtIndex:section];
	return kvArray.name;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	KeyValueArray *kvArray = (KeyValueArray*)[data objectAtIndex:section];
	return [kvArray.keyValues count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    NameValueCell *cell = (NameValueCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[NameValueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Set up the cell...
	KeyValueArray *kvArray = (KeyValueArray*)[data objectAtIndex:indexPath.section];
	KeyValuePair *pair = (KeyValuePair*)[kvArray.keyValues objectAtIndex:indexPath.row];
	
	cell.nameLabel.text = pair.key;
	cell.valueLabel.text = pair.value;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

