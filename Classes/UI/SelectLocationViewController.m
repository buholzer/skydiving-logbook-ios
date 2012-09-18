//
//  ListSelectionViewController.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/3/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "SelectLocationViewController.h"
#import "RepositoryManager.h"
#import "LocationViewController.h"

@implementation SelectLocationViewController

@synthesize selectedLocation;

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.title = NSLocalizedString(@"SelectLocationTitle", @"");
}

- (void)addItem
{
	// create new
    LocationRepository *repository = [[RepositoryManager instance] locationRepository];
	Location *location = [repository createNewLocation];
	
	// init viewcontroller
	LocationViewController *controller = [[LocationViewController alloc] initWithLocation:location isNew:YES];
	[self.navigationController pushViewController:controller animated:YES];
}

- (void)loadData
{
	// init items
    LocationRepository *repository = [[RepositoryManager instance] locationRepository];
	self.items = [repository loadEntities];
}

- (NSString *)itemName:(id)item
{
	return [item Name];
}

- (BOOL)isSelected:(id)item
{
	return [item isEqual:selectedLocation];
}

- (void)setSelected:(id)item
{
	if ([item isEqual:selectedLocation])
	{
		selectedLocation = nil;
	}
	else
	{
		selectedLocation = item;
	}
}

@end