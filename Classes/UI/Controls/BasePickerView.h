//
//  BasePickerView.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BasePickerView: NSObject
{
    UIView *mainView;
    UITableView *tableView;
    UIView *pickerViewContainer;
    UIToolbar *toolbar;
    
    // used for iPad popover
    UIViewController *pickerController;
    UIPopoverController *popoverController;
}

- (id)initForView:(UIView *)view table:(UITableView *)tableView;
- (void)showPicker:(UIView *)forView toolbarItems:(NSArray *)toolbarItems;
- (void)hidePicker;

// protected methods
- (UIView *)protected_createPickerView:(CGRect)frame;

@end
