//
//  AircraftListViewController.m
//  SkydiveLogbook
//
//  Created by Tom Cain on 2/19/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "AircraftListViewController.h"
#import "RepositoryManager.h"
#import "AircraftViewController.h"
#import "Aircraft.h"

// private interface
@interface AircraftListViewController(Private)
- (void)addAircraft;
- (void)loadData;
- (void)showAircraftViewController:(Aircraft *)aircraft isNew:(BOOL)isNew;
@end

@implementation AircraftListViewController

@synthesize aircrafts;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// add add button
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAircraft)];
	self.navigationItem.rightBarButtonItem = addButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	// refresh data
	[self loadData];
}

- (void)showAircraftViewController:(Aircraft *)aircraft isNew:(BOOL)isNew
{
	AircraftViewController *controller = [[AircraftViewController alloc] initWithAircraft:aircraft isNew:isNew];
	[self.navigationController pushViewController:controller animated:YES];
}

- (void)loadData
{
	// get aircrafts
    AircraftRepository *repository = [[RepositoryManager instance] aircraftRepository];
	self.aircrafts = [repository loadEntities];
	[self.tableView reloadData];
}

- (void)addAircraft
{
	// create new aircraft
    AircraftRepository *repository = [[RepositoryManager instance] aircraftRepository];
	Aircraft *aircraft = [repository createNewAircraft];
	[self showAircraftViewController:aircraft isNew:YES];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [aircrafts count];
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
    
    // get aircraft, update cell
	Aircraft *aircraft = [aircrafts objectAtIndex:indexPath.row];
	cell.textLabel.text = aircraft.Name;
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// show aircraft controller
	Aircraft *aircraft = [aircrafts objectAtIndex:indexPath.row];
	[self showAircraftViewController:aircraft isNew:NO];
}

@end

