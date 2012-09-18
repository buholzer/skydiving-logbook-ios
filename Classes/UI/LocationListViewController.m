//
//  LocationListViewController.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/19/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "LocationListViewController.h"
#import "RepositoryManager.h"
#import "LocationViewController.h"
#import "Location.h"

// private interface
@interface LocationListViewController(Private)
- (void)addLocation;
- (void)loadData;
- (void)showLocationViewController:(Location *)location isNew:(BOOL)isNew;
@end

@implementation LocationListViewController

@synthesize locations;

- (void)viewDidLoad
{
    [super viewDidLoad];

	// add add button
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addLocation)];
	self.navigationItem.rightBarButtonItem = addButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	// refresh data
	[self loadData];
}

- (void)showLocationViewController:(Location *)location isNew:(BOOL)isNew
{
	// create/show controller
	LocationViewController *controller = [[LocationViewController alloc] initWithLocation:location isNew:isNew];
	[self.navigationController pushViewController:controller animated:YES];
}

- (void)loadData
{
	// get locations
    LocationRepository *repository = [[RepositoryManager instance] locationRepository];
	self.locations = [repository loadEntities];
	[self.tableView reloadData];
}

- (void)addLocation
{
	// create new
    LocationRepository *repository = [[RepositoryManager instance] locationRepository];
	Location *location = [repository createNewLocation];
	[self showLocationViewController:location isNew:YES];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [locations count];
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
    
    // update cell
	Location *location = [locations objectAtIndex:indexPath.row];
	cell.textLabel.text = location.Name;
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// show aircraft controller
	Location *location = [locations objectAtIndex:indexPath.row];
	[self showLocationViewController:location isNew:NO];
}
@end

