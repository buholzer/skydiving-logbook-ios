//
//  SkydiveTypeListViewController.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 9/2/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "SkydiveTypeListViewController.h"
#import "RepositoryManager.h"
#import "SkydiveTypeViewController.h"
#import "SkydiveType.h"

// private interface
@interface SkydiveTypeListViewController(Private)
- (void)addSkydiveType;
- (void)loadData;
- (void)showSkydiveTypeViewController:(SkydiveType *)skydiveType isNew:(BOOL)isNew;
@end

@implementation SkydiveTypeListViewController

@synthesize skydiveTypes;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// add add button
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSkydiveType)];
	self.navigationItem.rightBarButtonItem = addButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	// refresh data
	[self loadData];
}

- (void)showSkydiveTypeViewController:(SkydiveType *)skydiveType isNew:(BOOL)isNew
{
	// create/show controller
	SkydiveTypeViewController *controller = [[SkydiveTypeViewController alloc] initWithSkydiveType:skydiveType isNew:isNew];
	[self.navigationController pushViewController:controller animated:YES];
}

- (void)loadData
{
	// get skydive types
    SkydiveTypeRepository *repository = [[RepositoryManager instance] skydiveTypeRepository];
	self.skydiveTypes = [repository loadEntities];
	[self.tableView reloadData];
}

- (void)addSkydiveType
{
	// create new
    SkydiveTypeRepository *repository = [[RepositoryManager instance] skydiveTypeRepository];
	SkydiveType *skydiveType = [repository createNewSkydiveType];
	[self showSkydiveTypeViewController:skydiveType isNew:YES];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [skydiveTypes count];
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
	SkydiveType *skydiveType = [skydiveTypes objectAtIndex:indexPath.row];
	cell.textLabel.text = skydiveType.Name;
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// show edit controller
	SkydiveType *skydiveType = [skydiveTypes objectAtIndex:indexPath.row];
	[self showSkydiveTypeViewController:skydiveType isNew:NO];
}
@end
