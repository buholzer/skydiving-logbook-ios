//
//  PickerView.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasePickerView.h"
#import "PickerModel.h"
#import "NumberPickerModel.h"

@interface PickerView : BasePickerView
{
    UIPickerView *picker;
}

- (void)showNumberPicker:(NumberPickerModel *)model forView:(UIView *)view toolbarItems:(NSArray *)toolbarItems;
- (void)showPicker:(PickerModel *)model forView:(UIView *)view toolbarItems:(NSArray *)toolbarItems;
- (UIPickerView *)getPicker;

@end
