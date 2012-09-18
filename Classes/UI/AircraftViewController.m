//
//  AircraftViewController.m
//  SkydiveLogbook
//
//  Created by Tom Cain on 2/19/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "RepositoryManager.h"
#import "AircraftViewController.h"
#import "UIUtility.h"
#import "DataUtil.h"

@implementation AircraftViewController

- (id)initWithAircraft:(Aircraft *)newAircraft isNew:(BOOL)isNew
{
	if (self = [super initWithNibName:@"AircraftViewController" bundle:nil])
	{
		aircraft = newAircraft;
		isNewAircraft = isNew;
		self.hidesBottomBarWhenPushed = YES;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// set title
	if (isNewAircraft == YES)
	{
		self.title = NSLocalizedString(@"NewAircraftTitle", @"");
	}
	else
	{
		self.title = NSLocalizedString(@"AircraftInfoTitle", @"");
	}	
	
	// add done button
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save)];
	self.navigationItem.leftBarButtonItem = saveButton;
    
    // add cancel button if is new
    if (isNewAircraft)
    {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
        self.navigationItem.rightBarButtonItem = cancelButton;
    }
		
	// init delete button
	deleteCell = [[DeleteButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DeleteCell"];
	[deleteCell.button addTarget:self action:@selector(deleteAircraft:) forControlEvents:UIControlEventTouchUpInside];
	deleteCell.hidden = isNewAircraft;
	
	// init notes cell
	notesCell = [[NotesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NotesCell"];
	
	// init section array
	tableModel = [[TableModel alloc] init];
	[tableModel addSection:@""];
	[tableModel addRow:0 cell:nameCell];
    [tableModel addRow:0 cell:defaultCell];
	[tableModel addSection:NSLocalizedString(@"Notes", @"")];
	[tableModel addRowWithSelectMethod:1 cell:notesCell methodName:@"showNotesController"];
	[tableModel addSection:@""];
	[tableModel addRow:2 cell:deleteCell];
	
	// update UI
	nameField.text = aircraft.Name;
    defaultField.on = [aircraft.Default boolValue];
	notesCell.textView.text = aircraft.Notes;
}

- (void)showNotesController
{
	NotesViewController *controller = [[NotesViewController alloc] initWithNotes:notesCell.textView.text delegate:self];
	[self.navigationController pushViewController:controller animated:YES];
}

- (void)save
{
    // get repository
    AircraftRepository *repository = [[RepositoryManager instance] aircraftRepository];

    // if default set
	if (defaultField.on)
	{
        // clear default aircrafts
        [repository clearDefaultAircrafts];
	}
    
	// update aircraft
    if (![UIUtility stringsAreEqual:aircraft.Name str2:nameField.text])
        aircraft.Name = nameField.text;
    
    NSNumber *isDefault = [NSNumber numberWithBool:defaultField.on];
    if (![UIUtility numbersAreEqual:aircraft.Default num2:isDefault])
        aircraft.Default = isDefault;
    
    if (![UIUtility stringsAreEqual:aircraft.Notes str2:notesCell.textView.text])
        aircraft.Notes = notesCell.textView.text;
    
    // update last modified
    if ([aircraft hasChanges] || isNewAircraft)
        aircraft.LastModifiedUTC = [DataUtil currentDate];

	// save
	[repository save];
	
	// navigate to prev view
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)cancel
{
	// rollback any changes
    AircraftRepository *repository = [[RepositoryManager instance] aircraftRepository];
	[repository rollback];
    
	// return to prev view
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteAircraft:(id)sender
{
	// show delete prompt
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
						message:NSLocalizedString(@"AircraftDeleteConfirmation", @"")
						delegate:self
						cancelButtonTitle:NSLocalizedString(@"NoButton", @"")
						otherButtonTitles:NSLocalizedString(@"YesButton", @""), nil];
	[alert show];
}

#pragma mark -
#pragma mark - NotesDelegate

- (void)notesUpdated:(NSString *)notes
{
	// update cell
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
        AircraftRepository *repository = [[RepositoryManager instance] aircraftRepository];
		[repository deleteAircraft:aircraft];

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
	
	// check if empty
	if ([methodName length] > 0)
	{
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
