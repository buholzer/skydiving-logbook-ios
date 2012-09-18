//
//  SelectAircraftViewController.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/4/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "SelectAircraftViewController.h"
#import "RepositoryManager.h"
#import "AircraftViewController.h"

@implementation SelectAircraftViewController

@synthesize selectedAircraft;

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.title = NSLocalizedString(@"SelectAircraftTitle", @"");
}

- (void)addItem
{
	// create new
    AircraftRepository *repository = [[RepositoryManager instance] aircraftRepository];
	Aircraft *aircraft = [repository createNewAircraft];
	
	// init viewcontroller
	AircraftViewController *controller = [[AircraftViewController alloc] initWithAircraft:aircraft isNew:YES];
	[self.navigationController pushViewController:controller animated:YES];
}

- (void)loadData
{
	// init items
    AircraftRepository *repository = [[RepositoryManager instance] aircraftRepository];
	self.items = [repository loadEntities];
}

- (NSString *)itemName:(id)item
{
	return [item Name];
}

- (BOOL)isSelected:(id)item
{
	return [item isEqual:selectedAircraft];
}

- (void)setSelected:(id)item
{
	if ([item isEqual:selectedAircraft])
	{
		selectedAircraft = nil;
	}
	else
	{
		selectedAircraft = item;
	}
}

@end
