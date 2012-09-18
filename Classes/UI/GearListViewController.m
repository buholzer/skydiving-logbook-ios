//
//  GearListViewController.m
//  SkydiveLogbook
//
//  Created by Tom Cain on 2/19/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "GearListViewController.h"
#import "RepositoryManager.h"
#import "GearViewController.h"
#import "Rig.h"
#import "RigReminderUtil.h"
#import "UIUtility.h"

// private interface
@interface GearListViewController(Private)
- (void)addGear;
- (void)loadData;
- (void)showGearViewController:(Rig *)rig isNew:(BOOL)isNew;
@end

@implementation GearListViewController

@synthesize rigs, archivedRigs;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// add add button
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addRig)];
	self.navigationItem.rightBarButtonItem = addButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	// refresh data
	[self loadData];
}

- (void)showGearViewController:(Rig *)rig isNew:(BOOL)isNew
{
	// create/show viewcontroller
	GearViewController *controller = [[GearViewController alloc] initWithRig:rig isNew:isNew];
	[self.navigationController pushViewController:controller animated:YES];
}

- (void)loadData
{
	// get rigs
    RigRepository *repository = [[RepositoryManager instance] rigRepository];
	self.rigs = [repository loadRigs];
	self.archivedRigs = [repository loadArchivedRigs];
	[self.tableView reloadData];
}

- (void)addRig
{
	// create new
    RigRepository *repository = [[RepositoryManager instance] rigRepository];
	Rig *rig = [repository createNewRig];
	[self showGearViewController:rig isNew:YES];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (self.archivedRigs.count == 0)
		return 1;
	else
		return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (self.archivedRigs.count == 0)
	{
		return @"";
	}
	else
	{
		return section == 0 ? NSLocalizedString(@"ActiveRigsHeader", @"") :
						NSLocalizedString(@"ArchivedRigsHeader", @"");
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? self.rigs.count : self.archivedRigs.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// get cell
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section == 0)
	{
		Rig *rig = [rigs objectAtIndex:indexPath.row];
		cell.textLabel.text = rig.Name;
		// update color/image based on due status
		enum DueStatus dueStatus = [RigReminderUtil dueStatusForRig:rig];
		cell.textLabel.textColor = [UIUtility colorForDueStatus:dueStatus];
		cell.imageView.image = [UIUtility imageForDueStatus:dueStatus];
	}
	else
	{
		Rig *rig = [archivedRigs objectAtIndex:indexPath.row];
		cell.textLabel.text = rig.Name;
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// show controller
	Rig *rig;
	if (indexPath.section == 0)
	{
		rig = [rigs objectAtIndex:indexPath.row];
	}
	else
	{
		rig = [archivedRigs objectAtIndex:indexPath.row];
	}

	[self showGearViewController:rig isNew:NO];
}

@end