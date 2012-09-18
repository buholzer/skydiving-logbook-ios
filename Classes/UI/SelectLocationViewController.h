//
//  ListSelectionViewController.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/3/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseListSelectionViewController.h"
#import "Location.h"

@interface SelectLocationViewController : BaseListSelectionViewController
{
}

@property (strong) Location *selectedLocation;

@end
