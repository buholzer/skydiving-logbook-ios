//
//  DatePickerView.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DatePickerView.h"

@interface DatePickerView (Private)
- (void)datePickerUpdated;
@end

@implementation DatePickerView

- (id)initForView:(UIView *)view table:(UITableView *)theTable delegate:(id<DatePickerDelegate>)theDelegate
{
    if (self = [super initForView:view table:theTable])
	{
        delegate = theDelegate;
    }
    return self;
}

- (void)setDate:(NSDate *)date
{
    picker.date = date;
}

- (NSDate *)getDate
{
    return picker.date;
}

- (UIView *)protected_createPickerView:(CGRect)frame;
{
    picker = [[UIDatePicker alloc] initWithFrame:frame];
    [picker addTarget:self action:@selector(datePickerUpdated) forControlEvents:UIControlEventValueChanged];
    picker.datePickerMode = UIDatePickerModeDate;

    return picker;
}

- (void)datePickerUpdated
{
    if (delegate)
        [delegate datePickerChanged:picker.date];
}

@end
