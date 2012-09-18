//
//  GearViewController.m
//  SkydiveLogbook
//
//  Created by Tom Cain on 2/19/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "NotificationManager.h"
#import "RepositoryManager.h"
#import "GearViewController.h"
#import "UIUtility.h"
#import "RigReminderUtil.h"
#import "DataUtil.h"

static NSInteger RemindersSectionIndex = 2;
static NSInteger ComponentsSectionIndex = 1;

@interface GearViewController(Private)
- (void)initComponentRows;
- (void)initReminderRows;
@end

@implementation GearViewController

- (id)initWithRig:(Rig *)newRig isNew:(BOOL)isNew
{
	if (self = [super initWithNibName:@"GearViewController" bundle:nil])
	{
		rig = newRig;
		isNewRig = isNew;
		
		self.hidesBottomBarWhenPushed = YES;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// set title
	if (isNewRig == YES)
	{
		self.title = NSLocalizedString(@"NewRigTitle", @"");
	}
	else
	{
		self.title = NSLocalizedString(@"RigInfoTitle", @"");
	}
	
	// add done button
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save)];
	self.navigationItem.leftBarButtonItem = saveButton;
    
	// add cancel button
    if (isNewRig)
    {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
        self.navigationItem.rightBarButtonItem = cancelButton;
    }
	
	// init delete button
    deleteCell = [[DeleteButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DeleteCell"];
	[deleteCell.button addTarget:self action:@selector(deleteRig:) forControlEvents:UIControlEventTouchUpInside];
	deleteCell.hidden = isNewRig;
	
	// init notes cell
	notesCell = [[NotesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NotesCell"];
	
	// init section array
	tableModel = [[TableModel alloc] init];
	[tableModel addSection:@""];
	[tableModel addRow:0 cell:nameCell];
	[tableModel addRow:0 cell:primaryCell];
	[tableModel addRow:0 cell:archiveCell];
	[tableModel addRow:0 cell:jumpCountCell];
	[tableModel addSection:NSLocalizedString(@"RigComponents", @"")];
	[tableModel addSection:NSLocalizedString(@"RigReminders", @"")];
	[tableModel addSection:NSLocalizedString(@"Notes", @"")];
	[tableModel addRowWithSelectMethod:3 cell:notesCell methodName:@"showNotesController"];
	[tableModel addSection:@""];
	[tableModel addRow:4 cell:deleteCell];
	
	// update UI
	nameField.text = rig.Name;
	primaryField.on = [rig.Primary boolValue];
	archiveField.on = [rig.Archived boolValue];
	jumpCountField.text = [UIUtility formatNumber:[NSNumber numberWithInt:[rig.LogEntries count]]];
	notesCell.textView.text = rig.Notes;
	
	// init component/reminder rows
	[self initComponentRows];
	[self initReminderRows];
}

- (void)initComponentRows
{
	// clear all current rows
	[tableModel clearSection:ComponentsSectionIndex];
	
	// for each component
	UITableViewCell *cell;
	for (RigComponent *component in rig.Components)
	{
		// create cell, add row
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:component.Name];
		cell.textLabel.text = component.Name;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		[tableModel addRowWithSelectMethodAndObject:ComponentsSectionIndex
											   cell:cell
										 methodName:@"editComponent:"
											 object:component];
	}
	
	// add "add component" row
	[tableModel addRowWithSelectMethod:ComponentsSectionIndex cell:addComponentCell methodName:@"addComponent"];
}

- (void)initReminderRows
{
	// clear all current rows
	[tableModel clearSection:RemindersSectionIndex];
	
	// for each reminder
	UITableViewCell *cell;
	for (RigReminder *reminder in rig.Reminders)
	{
		// get due status
		enum DueStatus dueStatus = [RigReminderUtil dueStatus:reminder.LastCompletedDate 
												interval:[reminder.Interval intValue]
											intervalUnit:[Units stringToTimeIntervalUnit:reminder.IntervalUnit]];
		// create cell, add row
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reminder.Name];
		cell.textLabel.text = reminder.Name;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.textColor = [UIUtility colorForDueStatus:dueStatus];
		cell.imageView.image = [UIUtility imageForDueStatus:dueStatus];
		[tableModel addRowWithSelectMethodAndObject:RemindersSectionIndex
											   cell:cell
										 methodName:@"editReminder:"
											 object:reminder];
	}
	
	// add "add reminder" row
	[tableModel addRowWithSelectMethod:RemindersSectionIndex cell:addReminderCell methodName:@"addReminder"];
}

- (void)showComponentController:(RigComponent *)component isNew:(BOOL)isNew
{
	// init/show controller
	RigComponentViewController *controller = [[RigComponentViewController alloc] initWithComponent:component isNew:isNew delegate:self];
	[self.navigationController pushViewController:controller animated:YES];
}

- (void)addComponent
{
	// create new component
    RigRepository *repository = [[RepositoryManager instance] rigRepository];
	RigComponent *component = [repository createNewComponentForRig:rig];
	// show controller
	[self showComponentController:component isNew:YES];
}

- (void)editComponent:(id)sender
{
	[self showComponentController:(RigComponent *)sender isNew:NO];
}

- (void)showReminderController:(RigReminder *)reminder isNew:(BOOL)isNew
{
	// init/show controller
	RigReminderViewController *controller = [[RigReminderViewController alloc] initWithReminder:reminder isNew:isNew delegate:self];
	[self.navigationController pushViewController:controller animated:YES];
}

- (void)addReminder
{
	// create new reminder
    RigRepository *repository = [[RepositoryManager instance] rigRepository];
	RigReminder *reminder = [repository createNewReminderForRig:rig];
	// show controller
	[self showReminderController:reminder isNew:YES];
}

- (void)editReminder:(id)sender
{
	[self showReminderController:(RigReminder *)sender isNew:NO];
}

- (void)showNotesController
{
	NotesViewController *controller = [[NotesViewController alloc] initWithNotes:notesCell.textView.text delegate:self];
	[self.navigationController pushViewController:controller animated:YES];
}

- (void)save
{
	// update
    if (![UIUtility stringsAreEqual:rig.Name str2:nameField.text])
        rig.Name = nameField.text;
    
    NSNumber *isPrimary = [NSNumber numberWithBool:primaryField.on];
    if (![UIUtility numbersAreEqual:rig.Primary num2:isPrimary])
        rig.Primary = isPrimary;
    
    NSNumber *isArchived = [NSNumber numberWithBool:archiveField.on];
    if (![UIUtility numbersAreEqual:rig.Archived num2:isArchived])
        rig.Archived = [NSNumber numberWithBool:archiveField.on];
    
    if (![UIUtility stringsAreEqual:rig.Notes str2:notesCell.textView.text])
        rig.Notes = notesCell.textView.text;
    
    // update last modified
    if ([rig hasChanges] || isNewRig)
        rig.LastModifiedUTC = [DataUtil currentDate];
	
	// save
    RigRepository *repository = [[RepositoryManager instance] rigRepository];
	[repository save];
	
	// update badges
    [[NotificationManager instance] updateRigReminderBadges];
	
	// navigate to prev view
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)cancel
{
	// rollback any changes
    RigRepository *repository = [[RepositoryManager instance] rigRepository];
	[repository rollback];

	// return to prev view
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteRig:(id)sender
{
	// show delete prompt
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
													message:NSLocalizedString(@"RigDeleteConfirmation", @"")
												   delegate:self
										  cancelButtonTitle:NSLocalizedString(@"NoButton", @"")
										  otherButtonTitles:NSLocalizedString(@"YesButton", @""), nil];
	[alert show];
}

#pragma mark -
#pragma mark - RigComponentDelegate

- (void)componentUpdated
{
	[self initComponentRows];
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark - RigReminderDelegate

- (void)reminderUpdated
{
	[self initReminderRows];
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark - NotesDelegate

- (void)notesUpdated:(NSString *)notes
{
	// update
	notesCell.textView.text = notes;
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		// delete
        RigRepository *repository = [[RepositoryManager instance] rigRepository];
		[repository deleteRig:rig];
		// update badges
        [[NotificationManager instance] updateRigReminderBadges];
		// return to prev view
		[self.navigationController popViewControllerAnimated:YES];
	}
}

#pragma mark -
#pragma mark UITextFieldDelegate

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// get method
	NSString *methodName = [tableModel rowMethodName:indexPath.section rowIndex:indexPath.row];
	id object = [tableModel rowMethodObject:indexPath.section rowIndex:indexPath.row];
	
	// check if empty
	if ([methodName length] > 0)
	{
		SEL methodSelector = NSSelectorFromString(methodName);
		if (object != NULL)
		{
			[self performSelector:methodSelector withObject:object];
		}
		else
		{
			[self performSelector:methodSelector];
		}
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
