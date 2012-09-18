//
//  PickerModel.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/27/10.
//  Copyright 2010 NA. All rights reserved.
//

@protocol PickerModelDelegate<NSObject>
- (void)pickerModelChanged;
@end

@interface PickerModel : NSObject<UIPickerViewDelegate,
									UIPickerViewDataSource>
{
	NSArray *keys;
	float width;
}

@property (strong) id<PickerModelDelegate> delegate;
@property (strong) NSString *selectedKey;

- (id)initWithKeys:(NSArray *)theKeys width:(float)theWidth;
- (void)updatePicker:(UIPickerView *)picker;

@end
