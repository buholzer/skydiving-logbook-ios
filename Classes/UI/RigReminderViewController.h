//
//  RigReminderViewController.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/26/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeleteButtonCell.h"
#import "RigReminder.h"
#import "TableModel.h"
#import "NumberPickerModel.h"
#import "PickerView.h"
#import "DatePickerView.h"

@protocol RigReminderDelegate <NSObject>

- (void)reminderUpdated;

@end


@interface RigReminderViewController : UIViewController <UITableViewDelegate,
															UITableViewDataSource,
															UITextFieldDelegate,
															UIAlertViewDelegate,
															NumberPickerModelDelegate,
                                                            DatePickerDelegate>
{
	IBOutlet UITableView *tableView;
	IBOutlet UITableViewCell *nameCell;
	IBOutlet UITextField *nameField;
	IBOutlet UITableViewCell *intervalCell;
	IBOutlet UILabel *intervalField;
	IBOutlet UITableViewCell *lastDoneCell;
	IBOutlet UILabel *lastDoneField;
	IBOutlet UITableViewCell *nextDueCell;
	IBOutlet UILabel *nextDueField;
	DeleteButtonCell *deleteCell;
	
	TableModel *tableModel;
    
    PickerView *pickerView;
    DatePickerView *datePickerView;
	NumberPickerModel *intervalPickerModel;
	UIBarButtonItem *pickerDoneButton;
    UIBarButtonItem *pickerSpacerButton;
	
	RigReminder *reminder;
	BOOL isNewReminder;
	
	id<RigReminderDelegate> delegate;
}

- (id)initWithReminder:(RigReminder *)newReminder isNew:(BOOL)isNew delegate:(id<RigReminderDelegate>)theDelegate;

@end
