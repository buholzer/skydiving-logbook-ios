//
//  WingLoadCalcViewController.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/19/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickerModel.h"
#import "PickerView.h"

@interface WingLoadCalcViewController : UIViewController <UITextFieldDelegate,
														  PickerModelDelegate>
{
	IBOutlet UIButton *calcTypeButton;
	IBOutlet UITextField *yourWeightField;
	IBOutlet UITextField *rigWeightField;
	IBOutlet UILabel *canopySizeLabel;
	IBOutlet UITextField *canopySizeField;
	IBOutlet UILabel *wingLoadLabel;
	IBOutlet UITextField *wingLoadField;
	IBOutlet UILabel *resultLabel;
	IBOutlet UILabel *resultField;
	
    PickerView *pickerView;
	PickerModel *pickerModel;
	NSString *resultFormat;
}

- (IBAction)selectCalculatorType:(id)sender;

@end
