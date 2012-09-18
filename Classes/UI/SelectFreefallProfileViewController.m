//
//  SelectFreefallProfileViewController.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 9/3/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "SelectFreefallProfileViewController.h"
#import "FreefallProfile.h"

@implementation SelectFreefallProfileViewController

@synthesize selectedProfile;

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.title = NSLocalizedString(@"SelectFreefallProfileTitle", @"");
	
	// hide add button
	self.navigationItem.rightBarButtonItem = nil;
}

- (void)loadData
{
	// init items
	self.items = [FreefallProfileUtil freefallProfileStrings];
}

- (NSString *)itemName:(id)item
{
	return NSLocalizedString(item, @"");
}

- (BOOL)isSelected:(id)item
{
	return [item isEqual:selectedProfile];
}

- (void)setSelected:(id)item
{
	if ([item isEqual:selectedProfile])
	{
		selectedProfile = nil;
	}
	else
	{
		selectedProfile = item;
	}
}

@end
