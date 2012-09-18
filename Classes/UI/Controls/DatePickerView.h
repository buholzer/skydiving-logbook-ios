//
//  DatePickerView.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasePickerView.h"

@protocol DatePickerDelegate<NSObject>
- (void)datePickerChanged:(NSDate *)selectedDate;
@end

@interface DatePickerView : BasePickerView
{
    UIDatePicker *picker;
    id<DatePickerDelegate> delegate;
}

- (id)initForView:(UIView *)view table:(UITableView *)tableView delegate:(id<DatePickerDelegate>)delegate;
- (void)setDate:(NSDate *)date;
- (NSDate *)getDate;

@end
