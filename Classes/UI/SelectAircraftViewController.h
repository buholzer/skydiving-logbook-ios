//
//  SelectAircraftViewController.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/4/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseListSelectionViewController.h"
#import "Aircraft.h"

@interface SelectAircraftViewController : BaseListSelectionViewController
{
	Aircraft *selectedAircraft;
}

@property (strong) Aircraft *selectedAircraft;

@end
