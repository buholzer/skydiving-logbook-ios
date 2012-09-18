//
//  SelectSkydiveTypeViewController.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 3/4/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseListSelectionViewController.h"
#import "SkydiveType.h"

@interface SelectSkydiveTypeViewController : BaseListSelectionViewController
{
}

@property (strong) SkydiveType *selectedType;

@end

