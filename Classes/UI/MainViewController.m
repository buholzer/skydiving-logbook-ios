//
//  MainTabBarViewController.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/16/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "MainViewController.h"
#import "LogbookListViewController.h"

@implementation MainViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	UIViewController *controller = self.selectedViewController;
	if ([self.selectedViewController isKindOfClass:[UINavigationController class]])
	{
		UINavigationController *navController = (UINavigationController *)self.selectedViewController;
		controller = navController.topViewController;
	}

	return [controller shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

@end
