//
//  BasePickerView.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BasePickerView.h"
#import "UIUtility.h"

@interface BasePickerView (Private)
- (void)showiPadPicker:(UIView *)forView;
- (void)hideiPadPicker;
- (void)showiPhonePicker;
- (void)hideiPhonePicker;
@end

@implementation BasePickerView

- (id)initForView:(UIView *)view table:(UITableView *)table
{
    if (self = [super init])
	{
        // assign main view and table view
        mainView = view;
        tableView = table;
        
        // create toolbar
        CGRect toolbarFrame = CGRectMake(0, 0, 320, 44);
        toolbar = [[UIToolbar alloc] initWithFrame:toolbarFrame];
        toolbar.barStyle = UIBarStyleBlack;
        
        // create picker
        CGRect pickerFrame = CGRectMake(0, 44, 320, 180);
        UIView *picker = [self protected_createPickerView:pickerFrame];        
        // create picker/toolbar container
        CGRect containerFrame = CGRectMake(0, 0,
                                           toolbarFrame.size.width,
                                           toolbarFrame.size.height + pickerFrame.size.height);
        pickerViewContainer = [[UIView alloc] initWithFrame:containerFrame];
        [pickerViewContainer addSubview:picker];
        [pickerViewContainer addSubview:toolbar];
    }
    return self;
}

- (UIView *)protected_createPickerView:(CGRect)frame;
{
    return [[UIView alloc] initWithFrame:frame];
}

- (void)showPicker:(UIView *)forView toolbarItems:(NSArray *)toolbarItems
{
    // set toolbar items
    toolbar.items = toolbarItems;

    if ([UIUtility isiPad])
    {
        [self showiPadPicker:forView];
    }
    else
    {
        [self showiPhonePicker];
    }
}

- (void)hidePicker
{
    if ([UIUtility isiPad])
    {
        [self hideiPadPicker];
    }
    else
    {
        [self hideiPhonePicker];
    }
}

- (void)showiPadPicker:(UIView *)forView
{
    // create picker controller
    if (pickerController == nil)
    {
        pickerController = [[UIViewController alloc] initWithCoder:nil];
        pickerController.view = pickerViewContainer;
        pickerController.contentSizeForViewInPopover = pickerViewContainer.frame.size;
    }
    
    // create popover controller
    if (popoverController == nil)
    {
        popoverController = [[UIPopoverController alloc] initWithContentViewController:pickerController];
    }
    
    // show popover controller
    CGRect rect = CGRectMake(1, 1, forView.frame.size.width, forView.frame.size.height);
    [popoverController presentPopoverFromRect:rect inView:forView
                     permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)hideiPadPicker
{
    [popoverController dismissPopoverAnimated:YES];
}

- (void)showiPhonePicker
{
    // picker container size
    CGSize pickerSize = pickerViewContainer.bounds.size;
    
    // add view container to main view
    if (![pickerViewContainer isDescendantOfView:mainView])
    {
        [mainView addSubview:pickerViewContainer];
        // place picker container off screen
        CGSize viewSize = mainView.frame.size;
        pickerViewContainer.frame = CGRectMake(0, viewSize.height, pickerSize.width, pickerSize.height);
    }
    
    // animate
	[UIView beginAnimations:nil context:NULL];
	
	CGFloat viewHeight = mainView.bounds.size.height;
	CGFloat viewWidth = mainView.bounds.size.width;
    
    // transform up
    pickerViewContainer.transform = CGAffineTransformMakeTranslation(0, -1 * pickerSize.height);
    // shrink tableView
    if (tableView)
        tableView.frame = CGRectMake(0, 0, viewWidth, viewHeight - pickerSize.height);
	
	[UIView commitAnimations];
}

- (void)hideiPhonePicker
{
    // animate
	[UIView beginAnimations:nil context:NULL];
	
	CGFloat viewHeight = mainView.bounds.size.height;
	CGFloat viewWidth = mainView.bounds.size.width;
    
    // clear transform
    pickerViewContainer.transform = CGAffineTransformIdentity;
    // restore tableView size
    if (tableView)
        tableView.frame = CGRectMake(0, 0, viewWidth, viewHeight);
	
	[UIView commitAnimations];
}

@end