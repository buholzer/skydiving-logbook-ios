//
//  BaseListSelectionViewController.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/4/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "BaseListSelectionViewController.h"
#import "UIUtility.h"

@implementation BaseListSelectionViewController

@synthesize delegate;
@synthesize items;

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.title = NSLocalizedString(@"SelectLocationTitle", "");
	
	// set table style
	self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
	
	// add add button
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem)];
	self.navigationItem.rightBarButtonItem = addButton;
	
	// load data
	[self loadData];	
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// reload data
	[self loadData];
	[self.tableView reloadData];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	self.items = nil;
}

- (void)addItem
{
	// to be overridden be derived class
}

- (BOOL)isMultiSelect
{
    return FALSE;
}

- (void)loadData
{
	// to be overridden by derived class
}

- (NSString *)itemName:(id)item
{
	// to be overridden by derived class
	return @"";
}

- (BOOL)isSelected:(id)item
{
	// to be overridden by derived class
	return NO;
}

- (void)setSelected:(id)item
{
	// to be overridden by derived class
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
    
    // Set up the cell...
	id item = [items objectAtIndex:indexPath.row];
	cell.textLabel.text = [self itemName:item];
	
	// update selection
	if ([self isSelected:item])
	{
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	else
	{
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// get selected item
	id item = [items objectAtIndex:indexPath.row];
	// set selection
	[self setSelected:item];
	
	// notify delegate
	if (delegate != nil)
	{
		[delegate listSelectionChanged];
	}
    
    if ([self isMultiSelect])
    {
        [self.tableView reloadData];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)dealloc
{
    self.delegate = nil;
}

@end

