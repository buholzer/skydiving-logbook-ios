//
//  PickerModel.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/27/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "PickerModel.h"

@implementation PickerModel

@synthesize delegate;
@synthesize selectedKey;

- (id)initWithKeys:(NSArray *)theKeys width:(float)theWidth
{
	if (self = [super init])
	{
		keys = [[NSArray alloc] initWithArray:theKeys];
		width = theWidth;
		self.selectedKey = [keys objectAtIndex:0];
	}
	return self;
}
					 
- (void)updatePicker:(UIPickerView *)picker
{
	int row = [keys indexOfObject:self.selectedKey];
	[picker selectRow:row inComponent:0 animated:YES];
}

#pragma mark -
#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	// update selection
	self.selectedKey = [keys objectAtIndex:row];
	
	// notify delegate
	if (delegate != NULL)
	{
		[delegate pickerModelChanged];
	}
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	return width;
}

#pragma mark -
#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [keys count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	NSString *key = [keys objectAtIndex:row];
	return NSLocalizedString(key, @"");
}

@end
