//
//  SettingsViewController.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/19/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableModel.h"
#import "NumberPickerModel.h"
#import "PickerView.h"

@interface SettingsViewController : UIViewController<UITableViewDelegate,
														UITableViewDataSource,
														NumberPickerModelDelegate>
{
	IBOutlet UITableView *tableView;
	IBOutlet UITableViewCell *unitsUSCell;
	IBOutlet UITableViewCell *unitsMetricCell;
	IBOutlet UILabel *freefallTimeLabel;
	IBOutlet UITableViewCell *freefallTimeCell;
	IBOutlet UILabel *cutawayLabel;
	IBOutlet UITableViewCell *cutawayCell;
	IBOutlet UITableViewCell *defaultExitAltCell;
	IBOutlet UILabel *defaultExitAltLabel;
	IBOutlet UITableViewCell *defaultDeplAltCell;
	IBOutlet UILabel *defaultDeplAltLabel;
	
    PickerView *pickerView;
	
	UIBarButtonItem *pickerDoneButton;
	UIBarButtonItem *pickerSpacerButton;
	UIBarButtonItem *pickerHourButton;
	UIBarButtonItem *pickerMinuteButton;
	UIBarButtonItem *pickerSecondButton;
	
	TableModel *tableModel;
	NumberPickerModel *hourModel;
	NumberPickerModel *minuteModel;
	NumberPickerModel *secondModel;
	NumberPickerModel *cutawayModel;
	NumberPickerModel *defaultExitAltModel;
	NumberPickerModel *defaultDeplAltModel;
}

@end
