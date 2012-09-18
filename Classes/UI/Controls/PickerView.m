//
//  PickerView.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PickerView.h"

@implementation PickerView

- (UIView *)protected_createPickerView:(CGRect)frame;
{
    picker = [[UIPickerView alloc] initWithFrame:frame];
    return picker;
}

- (void)showPicker:(PickerModel *)model forView:(UIView *)view toolbarItems:(NSArray *)toolbarItems
{
    // set model
    picker.dataSource = model;
    picker.delegate = model;
    [model updatePicker:picker];
    // reload picker
    [picker reloadAllComponents];
    
    // show picker
    [self showPicker:view toolbarItems:toolbarItems];
}

- (void)showNumberPicker:(NumberPickerModel *)model forView:(UIView *)view toolbarItems:(NSArray *)toolbarItems
{
    // set model
    picker.dataSource = model;
    picker.delegate = model;
    [model updatePicker:picker];
    // reload picker
    [picker reloadAllComponents];
    
    // show picker
    [self showPicker:view toolbarItems:toolbarItems];
}

- (UIPickerView *)getPicker
{
    return picker;
}

@end
