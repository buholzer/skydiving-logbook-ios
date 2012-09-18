//
//  RigReminderViewController.m
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/26/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "RigReminderViewController.h"
#import "RepositoryManager.h"
#import "UIUtility.h"
#import "Units.h"
#import "RigReminderUtil.h"
#import "UITableViewCellAdditions.h"

@interface RigReminderViewController(Private)
- (void)showLastDonePicker;
- (void)showIntervalPicker;
- (void)hidePickers;
- (void)updateDateLabels;
@end

@implementation RigReminderViewController

- (id)initWithReminder:(RigReminder *)newReminder isNew:(BOOL)isNew delegate:(id<RigReminderDelegate>)theDelegate
{
	if (self = [super initWithNibName:@"RigReminderViewController" bundle:nil])
	{
		reminder = newReminder;
		isNewReminder = isNew;
		delegate = theDelegate;
		
		self.hidesBottomBarWhenPushed = YES;
	}
	
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// set title
	self.title = NSLocalizedString(@"RigReminderTitle", @"");
    	
	// add done button
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save)];
	self.navigationItem.leftBarButtonItem = saveButton;
	
	// add cancel button
    if (isNewReminder)
    {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
        self.navigationItem.rightBarButtonItem = cancelButton;
    }
	
	// init delete button
	deleteCell = [[DeleteButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DeleteCell"];
	[deleteCell.button addTarget:self action:@selector(deleteReminder:) forControlEvents:UIControlEventTouchUpInside];
	deleteCell.hidden = isNewReminder;
	
	// init table model
	tableModel = [[TableModel alloc] init];
	[tableModel addSection:@""];
	[tableModel addRow:0 cell:nameCell];
	[tableModel addRowWithSelectMethod:0 cell:intervalCell methodName:@"showIntervalPicker"];
	[tableModel addSection:@""];
	[tableModel addRowWithSelectMethod:1 cell:lastDoneCell methodName:@"showLastDonePicker"];
	[tableModel addRow:1 cell:nextDueCell];
	[tableModel addSection:@""];
	[tableModel addRow:2 cell:deleteCell];
	
	// init interval picker model
	intervalPickerModel = [[NumberPickerModel alloc] initWithDigitCount:3
													maxSignificantDigit:9
															   unitKeys:[NSArray arrayWithObjects:
																		 [Units timeIntervalToString:Days],
																		 [Units timeIntervalToString:Months],
																		 [Units timeIntervalToString:Years],
																		 nil]
															  unitWidth:140];
	intervalPickerModel.delegate = self;
	// init pickers
    pickerView = [[PickerView alloc] initForView:self.view table:tableView];
	datePickerView = [[DatePickerView alloc] initForView:self.view table:tableView delegate:self];
    
	// create toolbar buttons
    pickerDoneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(hidePickers)];
	pickerSpacerButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
	// update UI
	nameField.text = reminder.Name;
	intervalField.text = [NSString localizedStringWithFormat:@"%d %@", [reminder.Interval intValue], reminder.IntervalUnit];	
	intervalPickerModel.selectedNumber = reminder.Interval;
	intervalPickerModel.selectedUnitKey = reminder.IntervalUnit;
    [datePickerView setDate:reminder.LastCompletedDate];
	// update date labels
	[self updateDateLabels];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [pickerView hidePicker];
	[super viewWillDisappear:animated];
}

- (void)showLastDonePicker
{
	// hide keyboard
	[nameField resignFirstResponder];
	// show picker
    NSArray *toolbarItems = [NSArray arrayWithObjects:pickerSpacerButton, pickerDoneButton, nil];
    [datePickerView showPicker:lastDoneCell toolbarItems:toolbarItems];
	// scroll to field
	[tableView scrollToRowAtIndexPath:[tableView indexPathForCell:lastDoneCell] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)showIntervalPicker
{
	// hide keyboard
	[nameField resignFirstResponder];
	// show picker
    NSArray *toolbarItems = [NSArray arrayWithObjects:pickerSpacerButton, pickerDoneButton, nil];
    [pickerView showNumberPicker:intervalPickerModel forView:intervalCell toolbarItems:toolbarItems];
	// scroll to field
	[tableView scrollToRowAtIndexPath:[tableView indexPathForCell:intervalCell] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)hidePickers
{
    [pickerView hidePicker];
    [datePickerView hidePicker];
}

- (void)updateDateLabels
{
    NSDate *lastDoneDate = [datePickerView getDate];
	NSInteger interval = [intervalPickerModel.selectedNumber intValue];
	enum TimeIntervalUnit intervalUnit = [Units stringToTimeIntervalUnit:intervalPickerModel.selectedUnitKey];
	NSDate *nextDueDate = [RigReminderUtil dueDate:lastDoneDate
										  interval:interval
									  intervalUnit:intervalUnit];
	
	lastDoneField.text = [UIUtility formatDate:lastDoneDate];
	nextDueField.text = [UIUtility formatDate:nextDueDate];
	
	// set next due color
	enum DueStatus dueStatus = [RigReminderUtil dueStatus:lastDoneDate interval:interval intervalUnit:intervalUnit];
	nextDueField.textColor = [UIUtility colorForDueStatus:dueStatus];
}

- (void)save
{
	// update
    
    if (![UIUtility stringsAreEqual:reminder.Name str2:nameField.text])
        reminder.Name = nameField.text;
    
    NSDate *lastCompleted = [datePickerView getDate];
    if (![reminder.LastCompletedDate isEqualToDate:lastCompleted])
        reminder.LastCompletedDate = lastCompleted;
    
    if (![reminder.Interval isEqualToNumber:intervalPickerModel.selectedNumber])
        reminder.Interval = intervalPickerModel.selectedNumber;
    
    if (![reminder.IntervalUnit isEqualToString:intervalPickerModel.selectedUnitKey])
        reminder.IntervalUnit = intervalPickerModel.selectedUnitKey;
	
	// notify delegate
	if (delegate != NULL)
	{
		[delegate reminderUpdated];
	}
	
	// navigate to prev view
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)cancel
{
	// if new
	if (isNewReminder == YES)
	{
		// delete
        RigRepository *repository = [[RepositoryManager instance] rigRepository];
		[repository deleteReminder:reminder];
	}
	// return to prev view
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteReminder:(id)sender
{
	// show delete prompt
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
													message:NSLocalizedString(@"RigReminderDeleteConfirmation", @"")
												   delegate:self
										  cancelButtonTitle:NSLocalizedString(@"NoButton", @"")
										  otherButtonTitles:NSLocalizedString(@"YesButton", @""), nil];
	[alert show];
}

#pragma mark -
#pragma mark - NumberPickerModelDelegate

- (void)numberPickerModelChanged:(id)source
{
	// update label
	intervalField.text = [NSString localizedStringWithFormat:@"%d %@",
						  [intervalPickerModel.selectedNumber intValue],
						  intervalPickerModel.selectedUnitKey];
	// update date labels
	[self updateDateLabels];
}

#pragma mark -
#pragma mark - DatePickerDelegate

- (void)datePickerChanged:(NSDate *)selectedDate
{
	[self updateDateLabels];
}

#pragma mark -
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		// delete
        RigRepository *repository = [[RepositoryManager instance] rigRepository];
		[repository deleteReminder:reminder];		

		// notify delegate
		if (delegate != NULL)
		{
			[delegate reminderUpdated];
		}
		
		// return to prev view
		[self.navigationController popViewControllerAnimated:YES];
	}
}

#pragma mark -
#pragma mark UITextFieldDelegate

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
	// hide picker
	[self hidePickers];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// the user pressed the "Done" button, so dismiss the keyboard
	[textField resignFirstResponder];
	return YES;
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [tableModel sectionCount];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [tableModel sectionTitle:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [tableModel rowCount:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [tableModel rowCell:indexPath.section rowIndex:indexPath.row];
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// deselect cell
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	// get method
	NSString *methodName = [tableModel rowMethodName:indexPath.section rowIndex:indexPath.row];
	
	// check if empty
	if ([methodName length] > 0)
	{
		// invoke method
		SEL methodSelector = NSSelectorFromString(methodName);
		[self performSelector:methodSelector];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// get cell
	UITableViewCell *cell = [tableModel rowCell:indexPath.section rowIndex:indexPath.row];
	
	// return calculated height
	return [cell getCellHeight];
}

@end