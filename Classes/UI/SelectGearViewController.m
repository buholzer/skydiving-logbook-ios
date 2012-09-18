//
//  SelectGearViewController.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/4/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "SelectGearViewController.h"
#import "RepositoryManager.h"
#import "GearViewController.h"

@implementation SelectGearViewController

@synthesize selectedGear;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
		// init selected gear
		selectedGear = [NSMutableArray arrayWithCapacity:0];
	}
	
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// set title
	self.title = NSLocalizedString(@"SelectGearTitle", @"");
}

- (void)addItem
{
	// create new
    RigRepository *repository = [[RepositoryManager instance] rigRepository];
	Rig *rig = [repository createNewRig];
	
	// create/show viewcontroller
	GearViewController *controller = [[GearViewController alloc] initWithRig:rig isNew:YES];
	[self.navigationController pushViewController:controller animated:YES];
}

- (BOOL)isMultiSelect
{
    return TRUE;
}

- (void)loadData
{
	// init items
    RigRepository *repository = [[RepositoryManager instance] rigRepository];
	self.items = [repository loadRigs];
}

- (NSString *)itemName:(id)item
{
	return [item Name];
}

- (BOOL)isSelected:(id)item
{
	return [selectedGear containsObject:item];
}

- (void)setSelected:(id)item
{
	if ([selectedGear containsObject:item])
	{
		[selectedGear removeObject:item];
	}
	else
	{
		[selectedGear addObject:item];
	}
}

@end