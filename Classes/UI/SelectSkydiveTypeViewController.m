//
//  SelectSkydiveTypeViewController.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/4/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "SelectSkydiveTypeViewController.h"
#import "RepositoryManager.h"
#import "SkydiveTypeViewController.h"

@implementation SelectSkydiveTypeViewController

@synthesize selectedType;

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.title = NSLocalizedString(@"SelectSkydiveTypeTitle", @"");
}

- (void)addItem
{
	// create new
    SkydiveTypeRepository *repository = [[RepositoryManager instance] skydiveTypeRepository];
	SkydiveType *skydiveType = [repository createNewSkydiveType];
	
	// init viewcontroller
	SkydiveTypeViewController *controller = [[SkydiveTypeViewController alloc] initWithSkydiveType:skydiveType isNew:YES];
	[self.navigationController pushViewController:controller animated:YES];
}

- (void)loadData
{
	// init items
    SkydiveTypeRepository *repository = [[RepositoryManager instance] skydiveTypeRepository];
	self.items = [repository loadEntities];
}

- (NSString *)itemName:(id)item
{
	return [item Name];
}

- (BOOL)isSelected:(id)item
{
	return [item isEqual:selectedType];
}

- (void)setSelected:(id)item
{
	if ([item isEqual:selectedType])
	{
		selectedType = nil;
	}
	else
	{
		selectedType = item;
	}
}

@end
