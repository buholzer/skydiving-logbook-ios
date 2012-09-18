//
//  NumberPickerModel.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 4/25/10.
//  Copyright 2010 NA. All rights reserved.
//


@protocol NumberPickerModelDelegate<NSObject>

- (void)numberPickerModelChanged:(id)source;

@end

@interface NumberPickerModel : NSObject<UIPickerViewDelegate,
										UIPickerViewDataSource>
{
	int digitCount;
	int maxSignificantDigit;
	NSArray *unitKeys;
	float unitWidth;
}

@property (strong) id<NumberPickerModelDelegate> delegate;
@property (strong) NSNumber *selectedNumber;
@property (strong) NSString *selectedUnitKey;

- (id)initWithDigitCount:(int)theDigitCount;

- (id)initWithDigitCount:(int)theDigitCount
	 maxSignificantDigit:(int)theMaxSignificantDigit;

- (id)initWithDigitCount:(int)theDigitCount
	 maxSignificantDigit:(int)theMaxSignificantDigit
				unitKeys:(NSArray *)theUnitKeys
			   unitWidth:(float)theUnitWidth;

- (void)updatePicker:(UIPickerView *)picker;

@end

