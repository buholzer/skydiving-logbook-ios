//
//  WingLoadCalcViewController.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/19/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "WingLoadCalcViewController.h"
#import "SettingsRepository.h"
#import "Calculator.h"
#import "Units.h"

// calc type constants
static NSString *WingLoading = @"WingLoadingCalculatorType";
static NSString *CanopySize = @"CanopySizeCalculatorType";
static NSString *ExtraWeight = @"ExtraWeightCalculatorType";

@interface WingLoadCalcViewController(Private)
- (enum CalculatorType)currentCalculatorType;
- (void)recalculateResult;
- (void)updateUIForCalculatorType;
- (void)initPlaceholders;
- (void)hideKeyboard;
@end

@implementation WingLoadCalcViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder])
	{
		self.hidesBottomBarWhenPushed = YES;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // init picker view
    pickerView = [[PickerView alloc] initForView:self.view table:nil];

	// init picker model
	NSArray *calcTypes = [NSArray arrayWithObjects:WingLoading, CanopySize, ExtraWeight, nil];
	pickerModel = [[PickerModel alloc] initWithKeys:calcTypes
											  width:250];
	pickerModel.selectedKey = WingLoading;
	pickerModel.delegate = self;
	
	// init placeholders
	[self initPlaceholders];
	
	// init ui
	[self updateUIForCalculatorType];
	
	// init result
	[self recalculateResult];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// init placeholders
	[self initPlaceholders];
}

- (void)viewWillDisappear:(BOOL)animated
{
	// hide picker
    [pickerView hidePicker];
	// hide keyboard
	[self hideKeyboard];
}

- (void)initPlaceholders
{
	WeightUnit weightUnit = [SettingsRepository weightUnit];
	yourWeightField.placeholder = NSLocalizedString([Units weightToString:weightUnit], @"");
	rigWeightField.placeholder = NSLocalizedString([Units weightToString:weightUnit], @"");	
}

- (void)recalculateResult
{
	// get values
	CGFloat yourWeight = [yourWeightField.text floatValue];
	CGFloat equipWeight = [rigWeightField.text floatValue];
	CGFloat canopySize = [canopySizeField.text floatValue];
	CGFloat wingLoad = [wingLoadField.text floatValue];
	
	// get default/preferred weight unit
	WeightUnit weightUnit = [SettingsRepository weightUnit];
	NSString *weightUnitStr = NSLocalizedString([Units weightToString:weightUnit], @"");
	
	// calc result
	CGFloat result = [Calculator calculate:[self currentCalculatorType]
								yourWeight:yourWeight
							   equipWeight:equipWeight
								weightUnit:weightUnit
								canopySize:canopySize
								  wingLoad:wingLoad];
	
	// update ui
	resultField.text = [NSString localizedStringWithFormat:resultFormat, result, weightUnitStr];
}

- (void)updateUIForCalculatorType
{
	// get selected calc type
	enum CalculatorType calcType = [self currentCalculatorType];
	
	// update button text
	NSString *calcTypeStr = pickerModel.selectedKey;
	[calcTypeButton setTitle:NSLocalizedString(calcTypeStr, @"") forState:UIControlStateNormal];
	
	[UIView beginAnimations:nil context:NULL];
	
	if (calcType == WingLoadingCalculator)
	{
		// show/hide fields
		canopySizeLabel.hidden = NO;
		canopySizeField.hidden = NO;
		wingLoadLabel.hidden = YES;
		wingLoadField.hidden = YES;
		wingLoadLabel.transform = CGAffineTransformIdentity;
		wingLoadField.transform = CGAffineTransformIdentity;
		resultLabel.transform = CGAffineTransformMakeTranslation(0, -40);
		resultField.transform = CGAffineTransformMakeTranslation(0, -40);
		// update reslut format
		resultFormat = NSLocalizedString(@"WingLoadingResultFormat", @"");
	}
	else if (calcType == CanopySizeCalculator)
	{
		// show/hide fields
		canopySizeLabel.hidden = YES;
		canopySizeField.hidden = YES;
		wingLoadLabel.hidden = NO;
		wingLoadField.hidden = NO;
		wingLoadLabel.transform = CGAffineTransformMakeTranslation(0, -40);
		wingLoadField.transform = CGAffineTransformMakeTranslation(0, -40);
		resultLabel.transform = CGAffineTransformMakeTranslation(0, -40);
		resultField.transform = CGAffineTransformMakeTranslation(0, -40);
		// update result format
		resultFormat = NSLocalizedString(@"CanopySizeResultFormat", @"");
	}
	else if (calcType == ExtraWeightCalculator)
	{
		// show/hide fields
		canopySizeLabel.hidden = NO;
		canopySizeField.hidden = NO;
		wingLoadLabel.hidden = NO;
		wingLoadField.hidden = NO;
		wingLoadLabel.transform = CGAffineTransformIdentity;
		wingLoadField.transform = CGAffineTransformIdentity;
		resultLabel.transform = CGAffineTransformIdentity;
		resultField.transform = CGAffineTransformIdentity;
		// update result format
		resultFormat = NSLocalizedString(@"ExtraWeightResultFormat", @"");
	}
	
	[UIView commitAnimations];
}
		 
-(void)hideKeyboard
{
	[yourWeightField resignFirstResponder];
	[rigWeightField resignFirstResponder];
	[canopySizeField resignFirstResponder];
	[wingLoadField resignFirstResponder];
}

- (IBAction)selectCalculatorType:(id)sender
{
	// show picker
    [pickerView showPicker:pickerModel forView:calcTypeButton toolbarItems:nil];
}

- (enum CalculatorType)currentCalculatorType
{
	NSString *calcType = pickerModel.selectedKey;
	if ([calcType isEqualToString:WingLoading])
	{
		return WingLoadingCalculator;
	}
	else if ([calcType isEqualToString:CanopySize])
	{
		return CanopySizeCalculator;
	}
	else
	{
		return ExtraWeightCalculator;
	}
}

#pragma mark -
#pragma mark UITextFieldDelegate

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
	// hide picker
    [pickerView hidePicker];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// dismiss the keyboard
	[textField resignFirstResponder];
	
	// recalculate result
	[self recalculateResult];
	
	return YES;
}

#pragma mark -
#pragma mark PickerModelDelegate

- (void)pickerModelChanged
{
	// update UI
	[self updateUIForCalculatorType];
	
	// hide picker
    [pickerView hidePicker];
	
	// recalculate result
	[self recalculateResult];
}

@end
