//
//  NumberPickerModel.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 4/25/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "NumberPickerModel.h"

static float DigitWidth = 44;

@implementation NumberPickerModel

@synthesize delegate;
@synthesize selectedNumber;
@synthesize selectedUnitKey;

- (id)initWithDigitCount:(int)theDigitCount
{
	if (self = [super init])
	{
		// set fields
		digitCount = theDigitCount;
		maxSignificantDigit = 9;
		self.selectedNumber = [NSNumber numberWithInt:0];
	}
	return self;
}

- (id)initWithDigitCount:(int)theDigitCount
	 maxSignificantDigit:(int)theMaxSignificantDigit
{
	if (self = [super init])
	{
		// set fields
		digitCount = theDigitCount;
		maxSignificantDigit = theMaxSignificantDigit;
		self.selectedNumber = [NSNumber numberWithInt:0];
	}
	return self;
}

- (id)initWithDigitCount:(int)theDigitCount
	 maxSignificantDigit:(int)theMaxSignificantDigit
				unitKeys:(NSArray *)theUnitKeys
			   unitWidth:(float)theUnitWidth
{
	if (self = [super init])
	{
		// set fields
		digitCount = theDigitCount;
		maxSignificantDigit = theMaxSignificantDigit;
		self.selectedNumber = [NSNumber numberWithInt:0];
		if (theUnitKeys != nil)
		{
			unitKeys = [[NSArray alloc] initWithArray:theUnitKeys];
			unitWidth = theUnitWidth;
			self.selectedUnitKey = [unitKeys objectAtIndex:0];
		}
	}
	return self;
}

- (void)updatePicker:(UIPickerView *)picker
{
	int intValue = [self.selectedNumber intValue];
	int compValue = 0;
	int rowCount = 0;
	int rowValue = 0;
	// update each picker component for selected number
	for (int i = 0; i < digitCount; i++)
	{
		// get the actual component value
		compValue = intValue / pow(10, digitCount - i - 1);
		// get number of rows for component
		rowCount = [self pickerView:picker numberOfRowsInComponent:i];
		// get row value based on component value and row count
		rowValue = (rowCount/2) + compValue; // start in the middle
		
		// update picker
		[picker selectRow:rowValue inComponent:i animated:YES];

		// decrement intValue for next component
		intValue -= compValue * pow(10, digitCount - i - 1);
	}

	// update unit picker component
	if (unitKeys != nil)
	{
		int row = [unitKeys indexOfObject:self.selectedUnitKey];
		[picker selectRow:row inComponent:digitCount animated:YES];
	}
}

#pragma mark -
#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	// get selected number
	int value = 0;
	int compValue = 0;
	int modValue = 0;
	for (int i = 0; i < digitCount; i++)
	{
		modValue = (i == 0) ? (maxSignificantDigit + 1) : 10;
		compValue = [pickerView selectedRowInComponent:i] % modValue;
		value += compValue * pow(10, digitCount - i - 1);
	}
	// update selected number
	self.selectedNumber = [NSNumber numberWithInt:value];

	// update selected unit
	if (unitKeys != nil)
	{
		int row = [pickerView selectedRowInComponent:digitCount];
		self.selectedUnitKey = [unitKeys objectAtIndex:row];
	}	
	
	// notify delegate
	if (delegate != NULL)
	{
		[delegate numberPickerModelChanged:self];
	}
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	if (component < digitCount)
	{
		return DigitWidth;
	}
	else
	{
		return unitWidth;
	}
}

#pragma mark -
#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return (unitKeys == nil) ? digitCount : digitCount + 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	if (component == 0)
	{
		// return large number that is evenly divisible to fake circular look
		return (maxSignificantDigit + 1 ) * 100;
	}
	else if (component < digitCount)
	{
		// return large number to fake circular look
		return 1000;
	}
	else
	{
		return [unitKeys count];
	}
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	if (component == 0)
	{
		// row mod maxSig + 1
		return [[NSNumber numberWithInt:(row % (maxSignificantDigit + 1))] stringValue];
	}
	else if (component < digitCount)
	{
		// row mod 10
		return [[NSNumber numberWithInt:(row % 10)] stringValue];		
	}
	else
	{
		NSString *key = [unitKeys objectAtIndex:row];
		return NSLocalizedString(key, @"");
	}
	return @"";
}

@end
